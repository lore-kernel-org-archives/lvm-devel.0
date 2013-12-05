From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Dec 2013 10:19:36 +0000 (UTC)
Subject: master - tests: harness prints debug.log
Message-ID: <20131205101936.326B56105B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa75698a1779c426914fde81bd57a016397017f3
Commit:        aa75698a1779c426914fde81bd57a016397017f3
Parent:        7baf411c9774d8e51ccc8bff9399562da69906a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 5 11:12:56 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 5 11:18:15 2013 +0100

tests: harness prints debug.log

When the test is interrupted because debug.log has got to big,
and the test doesn't react on SIGINT - and needs to be only
killed with SIGKILL - it's still valuable to print at least
a portion of this debug.log (currently 4MB).

LVM_TEST_UNLIMITED  could be set to avoid this limitation
(i.e. when busy-looping lvm command needs to be running
for gdb attachment)
---
 test/lib/harness.c |   35 ++++++++++++++++++++++++++---------
 1 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index 4b7686d..5591f77 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -27,6 +27,7 @@
 #include <sys/wait.h>
 #include <time.h>
 #include <unistd.h>
+#include <stdint.h>
 
 static pid_t pid;
 static int fds[2];
@@ -54,6 +55,7 @@ static int verbose = 0; /* >1 with timestamps */
 static int interactive = 0; /* disable all redirections */
 static const char *results;
 static unsigned fullbuffer = 0;
+static int unlimited = 0;
 
 static FILE *outfile = NULL;
 char testdirdebug[PATH_MAX];
@@ -170,8 +172,7 @@ static int64_t _get_time_us(void)
 static void _append_buf(const char *buf, size_t len)
 {
 	if ((readbuf_used + len) >= readbuf_sz) {
-		if ((readbuf_sz >= MAX_LOG_SIZE) &&
-		    !getenv("LVM_TEST_UNLIMITED")) {
+		if ((readbuf_sz >= MAX_LOG_SIZE) && !unlimited) {
 			if (fullbuffer++ ==  0)
 				kill(-pid, SIGINT);
 			return;
@@ -222,12 +223,12 @@ static const char *_append_with_stamp(const char *buf, int stamp)
 	return bb;
 }
 
-static void drain(int fd)
+static void drain(int fd, size_t size_limit)
 {
 	char buf[4096 + 1];
 	const char *bp;
 	int stamp = 0;
-	int sz;
+	int sz, total_sz = 0;
 
 	static int stdout_last = -1, stdout_counter = 0;
 	static int outfile_last = -1, outfile_counter = 0;
@@ -249,6 +250,12 @@ static void drain(int fd)
 			trickle(stdout, &stdout_last, &stdout_counter);
 		if (outfile)
 			trickle(outfile, &outfile_last, &outfile_counter);
+
+		total_sz += sz;
+		if (total_sz > size_limit) {
+			printf("\n...Trimmed output...\n");
+			break;
+		}
 	}
 }
 
@@ -373,6 +380,7 @@ static void run(int i, char *f) {
 		fd_set set;
 		int runaway = 0;
 		int no_write = 0;
+		int collect_debug = 0;
 		FILE *varlogmsg;
 		int fd_vlm = -1;
 
@@ -403,6 +411,7 @@ static void run(int i, char *f) {
 				kill(pid, SIGINT);
 				sleep(5); /* wait a bit for a reaction */
 				if ((w = waitpid(pid, &st, WNOHANG)) == 0) {
+					collect_debug = 1;
 					kill(-pid, SIGKILL);
 					w = pid; // waitpid(pid, &st, NULL);
 				}
@@ -416,7 +425,8 @@ static void run(int i, char *f) {
 			selectwait.tv_usec = 500000; /* timeout 0.5s */
 			if (select(fds[0] + 1, &set, NULL, NULL, &selectwait) <= 0) {
 				/* Still checking debug log size if it's not growing too much */
-				if (testdirdebug[0] && (stat(testdirdebug, &statbuf) == 0) &&
+				if (!unlimited && testdirdebug[0] &&
+				    (stat(testdirdebug, &statbuf) == 0) &&
 				    statbuf.st_size > 32 * 1024 * 1024) { /* 32MB command log size */
 					printf("Killing test since debug.log has gone wild (size %ld)\n",
 					       statbuf.st_size);
@@ -426,21 +436,27 @@ static void run(int i, char *f) {
 				no_write++;
 				continue;
 			}
-			drain(fds[0]);
+			drain(fds[0], INT32_MAX);
 			no_write = 0;
 			if (fd_vlm >= 0)
-				drain(fd_vlm);
+				drain(fd_vlm, INT32_MAX);
 		}
 		if (w != pid) {
 			perror("waitpid");
 			exit(206);
 		}
-		drain(fds[0]);
+		drain(fds[0], INT32_MAX);
 		if (fd_vlm >= 0)
-			drain(fd_vlm);
+			drain(fd_vlm, INT32_MAX);
 		if (die == 2)
 			interrupted(i, f);
 		else if (runaway) {
+			if (collect_debug &&
+			    (fd_vlm = open(testdirdebug, O_RDONLY)) != -1) {
+				/* Normally read only first 4MB */
+				drain(fd_vlm, unlimited ? INT32_MAX : 4 * 1024 * 1024);
+				close(fd_vlm);
+			}
 			timeout(i, f);
 		} else if (WIFEXITED(st)) {
 			if (WEXITSTATUS(st) == 0)
@@ -485,6 +501,7 @@ int main(int argc, char **argv) {
 		interactive = atoi(be_interactive);
 
 	results = getenv("LVM_TEST_RESULTS") ? : "results";
+	unlimited = getenv("LVM_TEST_UNLIMITED") ? 1 : 0;
 	(void) snprintf(results_list, sizeof(results_list), "%s/list", results);
 
 	//if (pipe(fds)) {


