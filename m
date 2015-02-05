From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:17 +0000 (UTC)
Subject: master - test: Add support for running LVM commands in tests through strace.
Message-ID: <20150205134317.277DB60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d833fd4587ce30eb1fb4e20363ede07c40bc2f0
Commit:        5d833fd4587ce30eb1fb4e20363ede07c40bc2f0
Parent:        a6d006d9db033e8251fd58848f8876b3e3d0fe90
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 17:09:26 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:50:34 2015 +0100

test: Add support for running LVM commands in tests through strace.

---
 test/lib/aux.sh         |   18 +++++++++---------
 test/lib/lvm-wrapper.sh |   23 ++++++++++++++---------
 test/lib/utils.sh       |    1 +
 3 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index fd537bd..ca06c69 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -22,7 +22,7 @@ expect_failure() {
 }
 
 prepare_clvmd() {
-	rm -f debug.log
+	rm -f debug.log strace.log
 	test "${LVM_TEST_LOCKING:-0}" -ne 3 && return # not needed
 
 	if pgrep clvmd ; then
@@ -54,7 +54,7 @@ prepare_clvmd() {
 }
 
 prepare_dmeventd() {
-	rm -f debug.log
+	rm -f debug.log strace.log
 	if pgrep dmeventd ; then
 		echo "Cannot test dmeventd with real dmeventd ($(pgrep dmeventd)) running."
 		skip
@@ -81,7 +81,7 @@ prepare_dmeventd() {
 
 prepare_lvmetad() {
 	test $# -eq 0 && default_opts="-l wire,debug"
-	rm -f debug.log
+	rm -f debug.log strace.log
 	# skip if we don't have our own lvmetad...
 	(which lvmetad 2>/dev/null | grep "$abs_builddir") || skip
 
@@ -227,7 +227,7 @@ teardown() {
 		# Avoid activation of dmeventd if there is no pid
 		cfg=$(test -s LOCAL_DMEVENTD || echo "--config activation{monitoring=0}")
 		vgremove -ff $cfg  \
-			$vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log
+			$vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log strace.log
 	}
 
 	kill_sleep_kill_ LOCAL_CLVMD ${LVM_VALGRIND_CLVMD:-0}
@@ -478,7 +478,7 @@ enable_dev() {
 	    shift
 	fi
 
-	rm -f debug.log
+	rm -f debug.log strace.log
 	init_udev_transaction
 	for dev in "$@"; do
 		local name=$(echo "$dev" | sed -e 's,.*/,,')
@@ -601,7 +601,7 @@ unhide_dev() {
 }
 
 mkdev_md5sum() {
-	rm -f debug.log
+	rm -f debug.log strace.log
 	mkfs.ext2 "$DM_DEV_DIR/$1/$2" || return 1
 	md5sum "$DM_DEV_DIR/$1/$2" > "md5.$1-$2"
 }
@@ -704,12 +704,12 @@ apitest() {
 	local t=$1
 	shift
 	test -x "$abs_top_builddir/test/api/$t.t" || skip
-	"$abs_top_builddir/test/api/$t.t" "$@" && rm -f debug.log
+	"$abs_top_builddir/test/api/$t.t" "$@" && rm -f debug.log strace.log
 }
 
 api() {
 	test -x "$abs_top_builddir/test/api/wrapper" || skip
-	"$abs_top_builddir/test/api/wrapper" "$@" && rm -f debug.log
+	"$abs_top_builddir/test/api/wrapper" "$@" && rm -f debug.log strace.log
 }
 
 mirror_recovery_works() {
@@ -820,7 +820,7 @@ version_at_least() {
 #
 # i.e.   dm_target_at_least  dm-thin-pool  1 0
 target_at_least() {
-	rm -f debug.log
+	rm -f debug.log strace.log
 	case "$1" in
 	  dm-*) modprobe "$1" || true ;;
 	esac
diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index 013bc13..3eb0d99 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -24,17 +24,22 @@ test -z "$LVM_GDB" || exec gdb --readnow --args "$abs_top_builddir/tools/lvm" $C
 # Multiple level of LVM_VALGRIND support
 # the higher level the more commands are traced
 if test -n "$LVM_VALGRIND"; then
-	RUN_VALGRIND="aux run_valgrind";
-	case "$CMD" in
-	  lvs|pvs|vgs|vgck|vgscan)
-		test "$LVM_VALGRIND" -gt 2 || unset RUN_VALGRIND ;;
-	  pvcreate|pvremove|lvremove|vgcreate|vgremove)
-		test "$LVM_VALGRIND" -gt 1 || unset RUN_VALGRIND ;;
-	  *)
-		test "$LVM_VALGRIND" -gt 0 || unset RUN_VALGRIND ;;
-	esac
+	RUN_DBG="aux run_valgrind";
 fi
 
+if test -n "$LVM_STRACE"; then
+	RUN_DBG="strace $LVM_STRACE -o strace.log"
+fi
+
+set -x
+
+case "$CMD" in
+  lvs|pvs|vgs|vgck|vgscan)
+	test ${LVM_DEBUG_LEVEL:-0} -lt 2 && RUN_DBG= ;;
+  pvcreate|pvremove|lvremove|vgcreate|vgremove)
+	test ${LVM_DEBUG_LEVEL:-0} -lt 1 && RUN_DBG= ;;
+esac
+
 # the exec is important, because otherwise fatal signals inside "not" go unnoticed
 if test -n "$abs_top_builddir"; then
     exec $RUN_DBG "$abs_top_builddir/tools/lvm" $CMD "$@"
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 70f8ca5..0599f4d 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -129,6 +129,7 @@ STACKTRACE() {
 
 	test -z "$LVM_TEST_NODEBUG" -a -f debug.log && {
 		sed -e "s,^,## DEBUG: ,;s,$top_srcdir/\?,," < debug.log
+		test -e strace.log && sed -e "s,^,## STRACE: ,;s,$top_srcdir/\?,," < strace.log
 	}
 
 	test -f SKIP_THIS_TEST && exit 200


