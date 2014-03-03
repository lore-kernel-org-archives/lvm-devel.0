From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Mar 2014 18:32:55 +0000 (UTC)
Subject: master - tests: speedup kmsg processing
Message-ID: <20140303183255.D11866075C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=719261a33a34ff177767324089b6daa128c5c2f0
Commit:        719261a33a34ff177767324089b6daa128c5c2f0
Parent:        52007a9191e67b9b6d83fcf8332aceaa4e0f5e48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 3 19:08:22 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 3 19:30:47 2014 +0100

tests: speedup kmsg processing

Since there could be multiple readers of kmsg (test & journald) it needs
to be fast, to capture things like sysrq trace.

But to capture whole output it would need to prioritize reading of kmsg,
thus we would first log kernel messages and followed by command output.

As a trade-off always log command output first and use large drain
buffer so is captures most of messages, but occasionaly miss some
lines.
---
 test/lib/harness.c |   92 +++++++++++++++++++++++++++-------------------------
 1 files changed, 48 insertions(+), 44 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 5258c04..a9fff9f 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -180,7 +180,7 @@ static void _append_buf(const char *buf, size_t len)
 				kill(-pid, SIGINT);
 			return;
 		}
-		readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 16384;
+		readbuf_sz = 2 * (readbuf_used + len + readbuf_sz);
 		readbuf = realloc(readbuf, readbuf_sz);
 	}
 
@@ -226,19 +226,17 @@ static const char *_append_with_stamp(const char *buf, int stamp)
 	return bb;
 }
 
-static void drain(int fd, size_t size_limit)
+static int drain(int fd)
 {
-	char buf[4096 + 1];
+	char buf[2 * 1024 * 1024 + 1]; /* try to capture large sysrq trace */
 	const char *bp;
 	int stamp = 0;
-	int sz, total_sz = 0;
+	int sz;
 
 	static int stdout_last = -1, stdout_counter = 0;
 	static int outfile_last = -1, outfile_counter = 0;
 
-	while ((sz = read(fd, buf, sizeof(buf) - 1)) > 0) {
-		if (fullbuffer)
-			continue;
+	if ((sz = read(fd, buf, sizeof(buf) - 1)) > 0) {
 		buf[sz] = '\0';
 		bp = (verbose < 2) ? buf : _append_with_stamp(buf, stamp);
 		if (sz > (bp - buf)) {
@@ -253,13 +251,32 @@ static void drain(int fd, size_t size_limit)
 			trickle(stdout, &stdout_last, &stdout_counter);
 		if (outfile)
 			trickle(outfile, &outfile_last, &outfile_counter);
-
-		total_sz += sz;
-		if (total_sz > size_limit) {
-			printf("\n...Trimmed output...\n");
-			break;
-		}
 	}
+
+	return sz;
+}
+
+static int drain_fds(int fd1, int fd2, long timeout)
+{
+	int ret;
+	fd_set set;
+	struct timeval selectwait = { .tv_usec = timeout };
+
+	FD_ZERO(&set);
+	FD_SET(fd1, &set);
+	if (fd2 >= 0)
+		FD_SET(fd2, &set);
+
+	if ((ret = select(fd2 > fd1 ? fd2 + 1 : fd1 + 1, &set, NULL, NULL, &selectwait)) <= 0)
+		return ret;
+
+	if (FD_ISSET(fd1, &set) && drain(fd1) > 0)
+		return fd1 + 1;
+
+	if (fd2 >= 0 && FD_ISSET(fd2, &set) && drain(fd2) > 0)
+		return fd2 + 1;
+
+	return -1;
 }
 
 static const char *duration(time_t start, const struct rusage *usage)
@@ -378,15 +395,13 @@ static void run(int i, char *f) {
 		char buf[128];
 		char outpath[PATH_MAX];
 		char *c = outpath + strlen(results) + 1;
-		struct timeval selectwait;
 		struct stat statbuf;
-		fd_set set;
 		int runaway = 0;
 		int no_write = 0;
 		int collect_debug = 0;
 		int fd_debuglog = -1;
-		int fd_kmsg = -1;
-		FILE *kmsg;
+		int fd_kmsg;
+		int ret;
 
 		//close(fds[1]);
 		testdirdebug[0] = '\0'; /* Capture RUNTESTDIR */
@@ -400,16 +415,10 @@ static void run(int i, char *f) {
 			perror("fopen");
 
 		/* Mix-in kernel log message */
-		if (!(kmsg = fopen("/proc/kmsg", "r")))
-			perror("fopen kmsg");
-		else if ((fd_kmsg = fileno(kmsg)) >= 0) {
-			if ((fcntl(fd_kmsg, F_SETFL, O_NONBLOCK ) == -1)) {
-				perror("fcntl kmsg");
-				fclose(kmsg);
-				kmsg = NULL;
-			} else if (fseek(kmsg, 0L, SEEK_END))
-				perror("fseek kmsg");
-		}
+		if ((fd_kmsg = open("/proc/kmsg", O_RDONLY | O_NONBLOCK)) < 0)
+			perror("open kmsg");
+		else if (lseek(fd_kmsg, 0L, SEEK_END) == (off_t) -1)
+			perror("lseek kmsg");
 
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
@@ -435,11 +444,7 @@ static void run(int i, char *f) {
 				break;
 			}
 
-			FD_ZERO(&set);
-			FD_SET(fds[0], &set);
-			selectwait.tv_sec = 0;
-			selectwait.tv_usec = 500000; /* timeout 0.5s */
-			if (select(fds[0] + 1, &set, NULL, NULL, &selectwait) <= 0) {
+			if ((ret = drain_fds(fds[0], fd_kmsg, 500000)) <= 0) {
 				/* Still checking debug log size if it's not growing too much */
 				if (!unlimited && testdirdebug[0] &&
 				    (stat(testdirdebug, &statbuf) == 0) &&
@@ -451,26 +456,25 @@ static void run(int i, char *f) {
 
 				no_write++;
 				continue;
-			}
-			drain(fds[0], INT32_MAX);
-			no_write = 0;
-			if (fd_kmsg >= 0)
-				drain(fd_kmsg, INT32_MAX);
+			} else if (ret == (fds[0] + 1))
+				no_write = 0;
 		}
 		if (w != pid) {
 			perror("waitpid");
 			exit(206);
 		}
-		drain(fds[0], INT32_MAX);
-		if (fd_kmsg >= 0)
-			drain(fd_kmsg, INT32_MAX);
+
+		while (!fullbuffer && (drain_fds(fds[0], fd_kmsg, 0) > 0))
+			/* read out what was left */;
+
 		if (die == 2)
 			interrupted(i, f);
 		else if (runaway) {
 			if (collect_debug &&
 			    (fd_debuglog = open(testdirdebug, O_RDONLY)) != -1) {
-				/* Normally read only first 4MB */
-				drain(fd_debuglog, unlimited ? INT32_MAX : 4 * 1024 * 1024);
+				runaway = unlimited ? INT32_MAX : 4 * 1024 * 1024;
+				while (!fullbuffer && runaway > 0 && (ret = drain(fd_debuglog)) > 0)
+					runaway -= ret;
 				close(fd_debuglog);
 			}
 			timeout(i, f);
@@ -484,8 +488,8 @@ static void run(int i, char *f) {
 		} else
 			failed(i, f, st);
 
-		if (kmsg)
-			fclose(kmsg);
+		if (fd_kmsg >= 0)
+			close(fd_kmsg);
 		if (outfile)
 			fclose(outfile);
 		if (fullbuffer)


