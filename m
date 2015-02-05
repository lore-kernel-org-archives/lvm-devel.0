From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:25 +0000 (UTC)
Subject: master - test: Call $VALGRIND directly in lvm-wrapper.
Message-ID: <20150205134325.8FF0C60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f727f3f3d925af35877ad572ba606965bc6f1e7
Commit:        1f727f3f3d925af35877ad572ba606965bc6f1e7
Parent:        3af008d4051d54d9138933d99ca234ede8ea6b05
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 08:19:05 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: Call $VALGRIND directly in lvm-wrapper.

---
 test/lib/aux.sh         |    2 +-
 test/lib/lvm-wrapper.sh |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ca06c69..88b821a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -14,7 +14,7 @@
 run_valgrind() {
 	# Execute script which may use $TESTNAME for creating individual
 	# log files for each execute command
-	exec "${VALGRIND:-valg}" "$@"
+	exec "${VALGRIND:-valgrind}" "$@"
 }
 
 expect_failure() {
diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index 3eb0d99..496facc 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -24,7 +24,7 @@ test -z "$LVM_GDB" || exec gdb --readnow --args "$abs_top_builddir/tools/lvm" $C
 # Multiple level of LVM_VALGRIND support
 # the higher level the more commands are traced
 if test -n "$LVM_VALGRIND"; then
-	RUN_DBG="aux run_valgrind";
+	RUN_DBG="${VALGRIND:-valgrind}";
 fi
 
 if test -n "$LVM_STRACE"; then


