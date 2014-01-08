From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  8 Jan 2014 16:14:49 +0000 (UTC)
Subject: master - test: Use klogctl in the harness instead of reading /var/log/messages.
Message-ID: <20140108161449.AB53760E0F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af8580d756d3d4ed56a00d377fd6bfb18d5bed41
Commit:        af8580d756d3d4ed56a00d377fd6bfb18d5bed41
Parent:        1937715d2ccdd46122da862c6d7c1ef0ed7d1230
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 15 21:10:57 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jan 8 17:11:32 2014 +0100

test: Use klogctl in the harness instead of reading /var/log/messages.

---
 test/lib/harness.c |   45 +++++++++++++++++++++++++++------------------
 1 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index f27fbeb..19859a0 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -25,6 +25,7 @@
 #include <sys/time.h>
 #include <sys/types.h>
 #include <sys/wait.h>
+#include <sys/klog.h>
 #include <time.h>
 #include <unistd.h>
 #include <stdint.h>
@@ -260,6 +261,23 @@ static void drain(int fd, size_t size_limit)
 	}
 }
 
+#define SYSLOG_ACTION_READ_CLEAR     4
+#define SYSLOG_ACTION_CLEAR          5
+
+static void clear_dmesg(void)
+{
+	klogctl(SYSLOG_ACTION_CLEAR, 0, 0);
+}
+
+static void drain_dmesg(void)
+{
+	char buf[16392 + 1];
+	size_t sz = klogctl(SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1);
+	buf[sz] = 0;
+	_append_buf(buf, sz);
+}
+
+
 static const char *duration(time_t start, const struct rusage *usage)
 {
 	static char buf[100];
@@ -345,6 +363,7 @@ static void run(int i, char *f) {
 	struct rusage usage;
 	char flavour[512], script[512];
 
+	clear_dmesg();
 	pid = fork();
 	if (pid < 0) {
 		perror("Fork failed.");
@@ -382,8 +401,7 @@ static void run(int i, char *f) {
 		int runaway = 0;
 		int no_write = 0;
 		int collect_debug = 0;
-		FILE *varlogmsg;
-		int fd_vlm = -1;
+		int fd_debuglog = -1;
 
 		//close(fds[1]);
 		testdirdebug[0] = '\0'; /* Capture RUNTESTDIR */
@@ -396,13 +414,6 @@ static void run(int i, char *f) {
 		if (!(outfile = fopen(outpath, "w")))
 			perror("fopen");
 
-		/* Mix in kernel log message */
-		if (!(varlogmsg = fopen("/var/log/messages", "r")))
-			perror("fopen");
-		else if (((fd_vlm = fileno(varlogmsg)) >= 0) &&
-			 fseek(varlogmsg, 0L, SEEK_END))
-			perror("fseek");
-
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
 			    (no_write > 180 * 2)) /* a 3 minute timeout */
@@ -446,24 +457,22 @@ static void run(int i, char *f) {
 			}
 			drain(fds[0], INT32_MAX);
 			no_write = 0;
-			if (fd_vlm >= 0)
-				drain(fd_vlm, INT32_MAX);
+			drain_dmesg();
 		}
 		if (w != pid) {
 			perror("waitpid");
 			exit(206);
 		}
 		drain(fds[0], INT32_MAX);
-		if (fd_vlm >= 0)
-			drain(fd_vlm, INT32_MAX);
+		drain_dmesg();
 		if (die == 2)
 			interrupted(i, f);
 		else if (runaway) {
 			if (collect_debug &&
-			    (fd_vlm = open(testdirdebug, O_RDONLY)) != -1) {
+			    (fd_debuglog = open(testdirdebug, O_RDONLY)) != -1) {
 				/* Normally read only first 4MB */
-				drain(fd_vlm, unlimited ? INT32_MAX : 4 * 1024 * 1024);
-				close(fd_vlm);
+				drain(fd_debuglog, unlimited ? INT32_MAX : 4 * 1024 * 1024);
+				close(fd_debuglog);
 			}
 			timeout(i, f);
 		} else if (WIFEXITED(st)) {
@@ -476,8 +485,8 @@ static void run(int i, char *f) {
 		} else
 			failed(i, f, st);
 
-		if (varlogmsg)
-			fclose(varlogmsg);
+		if (fd_debuglog >= 0)
+			close(fd_debuglog);
 		if (outfile)
 			fclose(outfile);
 		if (fullbuffer)


