From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Mar 2014 20:56:02 +0000 (UTC)
Subject: master - tests: restore usage of reading kmsg
Message-ID: <20140302205602.ECC4A611B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c377f5b3c36cc0514210821b3d0b72c10d2a819
Commit:        6c377f5b3c36cc0514210821b3d0b72c10d2a819
Parent:        33d69162e4b45e7926d4c0e4a425fedb4246088e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 2 21:30:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 2 21:30:26 2014 +0100

tests: restore usage of reading kmsg

Basically reverts commit af8580d756d3d4ed56a00d377fd6bfb18d5bed41.
"test: Use klogctl in the harness instead of reading /var/log/messages."

Problem is - this interface clears dmesg buffer
(just like call of dmesg -c)
Thus after running lvm2 test suitedmesg is empty - while all the
messages are usually logged in the journal/message, it's still not nice to
clear dmesg buffer.

It's not a pure revert, but switch to use /proc/kmsg directly instead of
reading /var/log/messages.
---
 test/lib/harness.c |   45 +++++++++++++++++++++------------------------
 1 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index ded86f0..5258c04 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -25,7 +25,6 @@
 #include <sys/time.h>
 #include <sys/types.h>
 #include <sys/wait.h>
-#include <sys/klog.h>
 #include <time.h>
 #include <unistd.h>
 #include <stdint.h>
@@ -263,23 +262,6 @@ static void drain(int fd, size_t size_limit)
 	}
 }
 
-#define SYSLOG_ACTION_READ_CLEAR     4
-#define SYSLOG_ACTION_CLEAR          5
-
-static void clear_dmesg(void)
-{
-	klogctl(SYSLOG_ACTION_CLEAR, 0, 0);
-}
-
-static void drain_dmesg(void)
-{
-	char buf[16392 + 1];
-	size_t sz = klogctl(SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1);
-	buf[sz] = 0;
-	_append_buf(buf, sz);
-}
-
-
 static const char *duration(time_t start, const struct rusage *usage)
 {
 	static char buf[100];
@@ -365,7 +347,6 @@ static void run(int i, char *f) {
 	struct rusage usage;
 	char flavour[512], script[512];
 
-	clear_dmesg();
 	pid = fork();
 	if (pid < 0) {
 		perror("Fork failed.");
@@ -404,11 +385,13 @@ static void run(int i, char *f) {
 		int no_write = 0;
 		int collect_debug = 0;
 		int fd_debuglog = -1;
+		int fd_kmsg = -1;
+		FILE *kmsg;
 
 		//close(fds[1]);
 		testdirdebug[0] = '\0'; /* Capture RUNTESTDIR */
 		snprintf(buf, sizeof(buf), "%s ...", f);
-		printf("Running %-60s ", buf);
+		printf("Running %-60s%c", buf, verbose ? '\n' : ' ');
 		fflush(stdout);
 		snprintf(outpath, sizeof(outpath), "%s/%s.txt", results, f);
 		while ((c = strchr(c, '/')))
@@ -416,6 +399,18 @@ static void run(int i, char *f) {
 		if (!(outfile = fopen(outpath, "w")))
 			perror("fopen");
 
+		/* Mix-in kernel log message */
+		if (!(kmsg = fopen("/proc/kmsg", "r")))
+			perror("fopen kmsg");
+		else if ((fd_kmsg = fileno(kmsg)) >= 0) {
+			if ((fcntl(fd_kmsg, F_SETFL, O_NONBLOCK ) == -1)) {
+				perror("fcntl kmsg");
+				fclose(kmsg);
+				kmsg = NULL;
+			} else if (fseek(kmsg, 0L, SEEK_END))
+				perror("fseek kmsg");
+		}
+
 		while ((w = wait4(pid, &st, WNOHANG, &usage)) == 0) {
 			if ((fullbuffer && fullbuffer++ == 8000) ||
 			    (no_write > 180 * 2)) /* a 3 minute timeout */
@@ -459,14 +454,16 @@ static void run(int i, char *f) {
 			}
 			drain(fds[0], INT32_MAX);
 			no_write = 0;
-			drain_dmesg();
+			if (fd_kmsg >= 0)
+				drain(fd_kmsg, INT32_MAX);
 		}
 		if (w != pid) {
 			perror("waitpid");
 			exit(206);
 		}
 		drain(fds[0], INT32_MAX);
-		drain_dmesg();
+		if (fd_kmsg >= 0)
+			drain(fd_kmsg, INT32_MAX);
 		if (die == 2)
 			interrupted(i, f);
 		else if (runaway) {
@@ -487,8 +484,8 @@ static void run(int i, char *f) {
 		} else
 			failed(i, f, st);
 
-		if (fd_debuglog >= 0)
-			close(fd_debuglog);
+		if (kmsg)
+			fclose(kmsg);
 		if (outfile)
 			fclose(outfile);
 		if (fullbuffer)


