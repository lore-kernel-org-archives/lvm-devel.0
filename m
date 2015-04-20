From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 20 Apr 2015 10:14:10 +0000 (UTC)
Subject: master - tests: use new debug logging feature
Message-ID: <20150420101410.04F9560DA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf4df9e3496d60e7183952e44863250e64618748
Commit:        cf4df9e3496d60e7183952e44863250e64618748
Parent:        bff3a1651d1b5b6b83a978f5896655b8df84ffc0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 20 10:05:27 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 20 12:12:22 2015 +0200

tests: use new debug logging feature

Enhance 'not' to manage autodeletion of log files in right cases.
Use separately marked epoch log files for clvmd and dmeventd.
Properly manage stack tracing for new debug.log names.
---
 test/lib/aux.sh      |    8 +++-----
 test/lib/inittest.sh |    2 ++
 test/lib/not.c       |   12 ++++++++++++
 test/lib/utils.sh    |   17 ++++++++---------
 4 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c28ac7b..3c00470 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -44,16 +44,14 @@ prepare_clvmd() {
 	test "${LVM_VALGRIND_CLVMD:-0}" -eq 0 || run_valgrind="run_valgrind"
 	rm -f "$CLVMD_PIDFILE"
 	echo "<======== Starting CLVMD ========>"
-	$run_valgrind clvmd -Isinglenode -d 1 -f &
+	LVM_LOG_FILE_EPOCH=CLVMD $run_valgrind clvmd -Isinglenode -d 1 -f &
 	echo $! > LOCAL_CLVMD
 
 	for i in $(seq 1 100) ; do
 		test $i -eq 100 && die "Startup of clvmd is too slow."
-		test -e "$CLVMD_PIDFILE" -a -e debug.log && break
+		test -e "$CLVMD_PIDFILE" && break
 		sleep .2
 	done
-	# Keep log of clvmd in separate debug file
-	mv debug.log clvmddebug.log
 }
 
 prepare_dmeventd() {
@@ -70,7 +68,7 @@ prepare_dmeventd() {
 
 	local run_valgrind=
 	test "${LVM_VALGRIND_DMEVENTD:-0}" -eq 0 || run_valgrind="run_valgrind"
-	$run_valgrind dmeventd -f "$@" &
+	LVM_LOG_FILE_EPOCH=DMEVENTD $run_valgrind dmeventd -f "$@" &
 	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 3a0d332..b096c9e 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -35,6 +35,8 @@ TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-/tmp}" "$PREFIX.XXXXXXXXXX") || \
 RUNNING_DMEVENTD=$(pgrep dmeventd) || true
 
 export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
+export LVM_LOG_FILE_EPOCH=DEBUG
+export LVM_LOG_FILE_UNLINK_STATUS=1
 
 test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
 trap 'aux teardown' EXIT # don't forget to clean up
diff --git a/test/lib/not.c b/test/lib/not.c
index 1cb12f9..1e00fe3 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -14,6 +14,7 @@
 
 #include <unistd.h>
 #include <stdio.h>
+#include <stdlib.h>
 #include <stdarg.h>
 #include <string.h>
 #include <sys/types.h>
@@ -39,6 +40,7 @@ static int finished(const char *cmd, int status) {
 }
 
 int main(int args, char **argv) {
+	const char *val = NULL;
 	pid_t pid;
 	int status;
 	int FAILURE = 6;
@@ -53,6 +55,16 @@ int main(int args, char **argv) {
 		fprintf(stderr, "Could not fork\n");
 		return FAILURE;
 	} else if (pid == 0) { 	/* child */
+		if (!strcmp(argv[0], "not"))
+			val = "!1";
+		else if (!strcmp(argv[0], "invalid"))
+			val = "3";
+		else if (!strcmp(argv[0], "fail"))
+			val = "5";
+
+		if (val)
+			setenv("LVM_LOG_FILE_UNLINK_STATUS", val, 1);
+
 		execvp(argv[1], &argv[1]);
 		/* should not be accessible */
 		return FAILURE;
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index e2b257d..87152a4 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -134,17 +134,16 @@ STACKTRACE() {
 
 	test -f SKIP_THIS_TEST && exit 200
 
-	test -z "$LVM_TEST_NODEBUG" -a -f debug.log && {
-		IDX=
+	test -z "$LVM_TEST_NODEBUG" && {
+		local name
+		local idx
 		for i in debug.log* ; do
-			echo "<======== Last traced lvm2 command $i ========>"
-			sed -e "s,^,## DEBUG${IDX}: ," $i
-			IDX=$(($IDX + 1))
+			name=${i##debug.log_}
+			name=${name%%_*}
+			test "$name" = "DEBUG" && { name="$name$idx" ; idx=$(($idx + 1)) ; }
+			echo "<======== Debug log $i ========>"
+			sed -e "s,^,## $name: ," $i
 		done
-		if test -e clvmddebug.log ; then
-			echo "<======== CLVMD debug log ========>"
-			sed -e "s,^,## CLVMD: ," clvmddebug.log
-		fi
 		if test -e strace.log ; then
 			echo "<======== Strace debug log ========>"
 			sed -e "s,^,## STRACE: ," strace.log


