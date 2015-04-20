From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 20 Apr 2015 17:22:03 +0000 (UTC)
Subject: master - tests: update to renamed envvars
Message-ID: <20150420172203.7302360221@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=caa9223c8549b4a937c2cc13eb7f306f55e4beee
Commit:        caa9223c8549b4a937c2cc13eb7f306f55e4beee
Parent:        85e833c172a0a0403c1de5e6f480a67629e51e36
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 20 19:16:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 20 19:18:56 2015 +0200

tests: update to renamed envvars

Enhance 'not' so 'should' now shows log trace from
command which has failed but should not.
---
 test/lib/aux.sh      |    2 +-
 test/lib/inittest.sh |    2 +-
 test/lib/not.c       |   23 ++++++++++++++++++-----
 3 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3c00470..d0d2aa8 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -124,7 +124,7 @@ lvmetad_dump() {
 
 notify_lvmetad() {
 	if test -e LOCAL_LVMETAD; then
-		pvscan --cache "$@" || true
+		LVM_LOG_FILE_EPOCH= pvscan --cache "$@" || rm -f debug.log
 	fi
 }
 
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index b096c9e..0efbf0d 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -36,7 +36,7 @@ RUNNING_DMEVENTD=$(pgrep dmeventd) || true
 
 export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
 export LVM_LOG_FILE_EPOCH=DEBUG
-export LVM_LOG_FILE_UNLINK_STATUS=1
+export LVM_EXPECTED_EXIT_STATUS=1
 
 test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
 trap 'aux teardown' EXIT # don't forget to clean up
diff --git a/test/lib/not.c b/test/lib/not.c
index 1e00fe3..ce46699 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -20,12 +20,25 @@
 #include <sys/types.h>
 #include <sys/wait.h>
 
-static int finished(const char *cmd, int status) {
+static int _finished(const char *cmd, int status, int pid) {
+	int ret;
 	if (!strcmp(cmd, "not"))
 		return !status;
 	if (!strcmp(cmd, "should")) {
-		if (status)
+		if (status) {
 			fprintf(stderr, "TEST WARNING: Ignoring command failure.\n");
+			/* TODO: avoid using shell here */
+			/* Show log for failing command which should be passing */
+			ret = system("ls debug.log*${LVM_LOG_FILE_EPOCH}* 2>/dev/null");
+			if (WIFEXITED(ret) && WEXITSTATUS(ret) == 0) {
+				printf("## timing off\n<======== Debug log ========>\n"); /* timing off */
+				fflush(stdout);
+				system("sed -e 's,^,## DEBUG: ,' debug.log*${LVM_LOG_FILE_EPOCH}* 2>/dev/null");
+				printf("## timing on\n"); /* timing on */
+				system("rm -f debug.log*${LVM_LOG_FILE_EPOCH}*");
+				fflush(stdout);
+			}
+		}
 		return 0;
 	} else if (!strcmp(cmd, "invalid")) {
 		if (status == 3)
@@ -56,14 +69,14 @@ int main(int args, char **argv) {
 		return FAILURE;
 	} else if (pid == 0) { 	/* child */
 		if (!strcmp(argv[0], "not"))
-			val = "!1";
+			val = ">1";
 		else if (!strcmp(argv[0], "invalid"))
 			val = "3";
 		else if (!strcmp(argv[0], "fail"))
 			val = "5";
 
 		if (val)
-			setenv("LVM_LOG_FILE_UNLINK_STATUS", val, 1);
+			setenv("LVM_EXPECTED_EXIT_STATUS", val, 1);
 
 		execvp(argv[1], &argv[1]);
 		/* should not be accessible */
@@ -79,7 +92,7 @@ int main(int args, char **argv) {
 			return FAILURE;
 		}
 
-		return finished(argv[0], WEXITSTATUS(status));
+		return _finished(argv[0], WEXITSTATUS(status), pid);
 	}
 	/* not accessible */
 	return FAILURE;


