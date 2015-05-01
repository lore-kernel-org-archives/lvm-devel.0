From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:40 +0000 (UTC)
Subject: master - tests: no lvmetad reload for debugless output
Message-ID: <20150501130840.31CE760366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3473e60db68a4d122f68dd66625ee35ac1021be
Commit:        a3473e60db68a4d122f68dd66625ee35ac1021be
Parent:        dd4e6b4e7e1afc959f054732f5388b915f62ab18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 1 14:45:47 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:58 2015 +0200

tests: no lvmetad reload for debugless output

Introduce LVM_TEST_LVMETAD_DEBUG_OPTS to allow to override
default debug opts for lvmetad.

However could be still overloaded on command line:

make check_lvmetad LVM_TEST_LVMETAD_DEBUG_OPTS="-l all"...
---
 test/Makefile.in                            |    1 +
 test/lib/aux.sh                             |    6 ++++--
 test/shell/lvconvert-mirror-basic.sh        |    6 +++---
 test/shell/lvconvert-mirror.sh              |    6 +++---
 test/shell/lvconvert-raid.sh                |    6 +++---
 test/shell/mirror-vgreduce-removemissing.sh |    6 +++---
 test/shell/process-each-lv.sh               |    6 +++---
 test/shell/pvmove-basic.sh                  |    6 +++---
 test/shell/vgsplit-operation.sh             |    6 +++---
 9 files changed, 26 insertions(+), 23 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 04fbea0..4144d14 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -82,6 +82,7 @@ help:
 	@echo "  LVM_TEST_DIR		Where to create test files  [$(LVM_TEST_DIR)]."
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
 	@echo "  LVM_TEST_LVMETAD	Start lvmetad (1)."
+	@echo "  LVM_TEST_LVMETAD_DEBUG_OPTS  Allows to override debug opts [-l all]."
 	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
 	@echo "  LVM_TEST_PARALLEL	May skip agresive wipe of LVMTEST resources."
 	@echo "  LVM_TEST_RESULTS	Where to create result files [results]."
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e6fd9fa..329c086 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -84,7 +84,6 @@ prepare_dmeventd() {
 }
 
 prepare_lvmetad() {
-	test $# -eq 0 && default_opts="-l all"
 	rm -f debug.log strace.log
 	# skip if we don't have our own lvmetad...
 	if test -z "${installed_testsuite+varset}"; then
@@ -96,8 +95,11 @@ prepare_lvmetad() {
 
 	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
 
+        # Default debug is "-l all" and could be override
+        # by setting LVM_TEST_LVMETAD_DEBUG_OPTS before calling inittest.
 	echo "preparing lvmetad..."
-	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" $default_opts "$@" &
+	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" \
+		${LVM_TEST_LVMETAD_DEBUG_OPTS--l all} "$@" &
 	echo $! > LOCAL_LVMETAD
 	while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
 	echo ok
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index ce5b344..4a3e62f 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -9,6 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+# disable lvmetad logging as it bogs down test systems
+export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
+
 . lib/inittest
 
 log_name_to_count() {
@@ -110,9 +113,6 @@ test_lvconvert() {
 	fi
 }
 
-# disable lvmetad logging as it bogs down test systems
-test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
-
 aux prepare_pvs 5 5
 vgcreate -s 32k $vg $(cat DEVICES)
 
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 5dde921..844f8e9 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
-
 # disable lvmetad logging as it bogs down test systems
-test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
+
+. lib/inittest
 
 aux prepare_pvs 5 10
 # proper DEVRANGE needs to be set according to extent size
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 34c94bf..d3253eb 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/inittest
-
 # disable lvmetad logging as it bogs down test systems
-test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
+
+. lib/inittest
 
 get_image_pvs() {
 	local d
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 8891369..e4791f8 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -12,10 +12,10 @@
 
 test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
 
-. lib/inittest
-
 # disable lvmetad logging as it bogs down test systems
-test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
+
+. lib/inittest
 
 lv_is_on_ ()
 {
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index 355e92e..bd9e042 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -11,10 +11,10 @@
 
 test_description='Exercise toollib process_each_lv'
 
-. lib/inittest
-
 # disable lvmetad logging as it bogs down test systems
-test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
+
+. lib/inittest
 
 aux prepare_devs 10
 
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index f7830da..42b004d 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -12,13 +12,13 @@
 
 test_description="ensure that pvmove works with basic options"
 
+# disable lvmetad logging as it bogs down test systems
+export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
+
 . lib/inittest
 
 which md5sum || skip
 
-# disable lvmetad logging as it bogs down test systems
-test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
-
 # ---------------------------------------------------------------------
 # Utilities
 
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index f2baafd..91cdcdc 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -11,10 +11,10 @@
 
 # Test vgsplit operation, including different LV types
 
-. lib/inittest
-
 # disable lvmetad logging as it bogs down test systems
-test -e LOCAL_LVMETAD && aux prepare_lvmetad ""
+export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
+
+. lib/inittest
 
 COMM() {
 	LAST_TEST="$@"


