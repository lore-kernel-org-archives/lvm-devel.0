From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 16:10:44 +0000 (UTC)
Subject: master - tests: monitor debug.log size
Message-ID: <20131204161044.488F360EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c6b14b74f88a58a9589922a3fa7be18334f3936
Commit:        7c6b14b74f88a58a9589922a3fa7be18334f3936
Parent:        598c82fc077c8a3edfbdb664b41efd89d05b5a10
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 4 17:01:59 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 17:10:31 2013 +0100

tests: monitor debug.log size

Show testing directory from test and monitor it in
harness - so when it gets too big - kill test.
---
 test/lib/harness.c |   15 +++++++++++++++
 test/lib/test.sh   |    1 +
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index dca0198..47a331d 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -21,6 +21,7 @@
 #include <sys/resource.h> /* rusage */
 #include <sys/select.h>
 #include <sys/socket.h>
+#include <sys/stat.h>
 #include <sys/time.h>
 #include <sys/types.h>
 #include <sys/wait.h>
@@ -55,6 +56,7 @@ static const char *results;
 static unsigned fullbuffer = 0;
 
 static FILE *outfile = NULL;
+char testdirdebug[PATH_MAX];
 
 struct subst {
 	const char *key;
@@ -100,6 +102,9 @@ static int outline(FILE *out, char *buf, int start, int force) {
 		subst[1].key = "@PREFIX@";
 		free(subst[1].value);
 		subst[1].value = strndup(from + 8, next - from - 8 - 1);
+	} else if (!testdirdebug[0] && !strncmp(from, "RUNTESTDIR=", 11)) {
+		from[strlen(from) - 1] = '\0'; /* Cut \n */
+		snprintf(testdirdebug, sizeof(testdirdebug), "%s/debug.log", from + 11);
 	} else {
 		char *line = strndup(from, next - from);
 		char *a = line, *b;
@@ -366,6 +371,7 @@ static void run(int i, char *f) {
 		char outpath[PATH_MAX];
 		char *c = outpath + strlen(results) + 1;
 		struct timeval selectwait;
+		struct stat statbuf;
 		fd_set set;
 		int runaway = 0;
 		int no_write = 0;
@@ -373,6 +379,7 @@ static void run(int i, char *f) {
 		int fd_vlm = -1;
 
 		//close(fds[1]);
+		testdirdebug[0] = '\0'; /* Capture RUNTESTDIR */
 		snprintf(buf, sizeof(buf), "%s ...", f);
 		printf("Running %-60s ", buf);
 		fflush(stdout);
@@ -409,6 +416,14 @@ static void run(int i, char *f) {
 			selectwait.tv_sec = 0;
 			selectwait.tv_usec = 500000; /* timeout 0.5s */
 			if (select(fds[0] + 1, &set, NULL, NULL, &selectwait) <= 0) {
+				/* Still checking debug log size if it's not growing too much */
+				if (testdirdebug[0] && (stat(testdirdebug, &statbuf) == 0) &&
+				    statbuf.st_size > 8 * 1024 * 1024) { /* 8MB command log size */
+					fprintf(stderr, "Killing test since debug.log has gone wild (size %ld)\n",
+						statbuf.st_size);
+					kill(-pid, SIGINT);
+				}
+
 				no_write++;
 				continue;
 			}
diff --git a/test/lib/test.sh b/test/lib/test.sh
index 265d61d..9e25e26 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -39,6 +39,7 @@ test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
 trap 'aux teardown' EXIT # don't forget to clean up
 
 cd "$TESTDIR"
+echo "RUNTESTDIR=$TESTDIR"
 
 if test -n "$LVM_TEST_FLAVOUR"; then
 	touch flavour_overrides


