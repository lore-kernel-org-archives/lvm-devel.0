From: Milan Broz <mbroz@redhat.com>
Date: Mon, 28 Dec 2009 20:55:34 +0100
Subject: [PATCH 2/2] Add cluster-check to provide basic cluster locking (using fake cluster).
In-Reply-To: <1262030134-24125-1-git-send-email-mbroz@redhat.com>
References: <1262030134-24125-1-git-send-email-mbroz@redhat.com>
Message-ID: <1262030134-24125-2-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Every test starts of instance of clvmd, and must properly kill it afterwards.
(This requires to not skip test with simple "exit 200".)

For using "make cluster-check" target the source must be compiled using
configure --with-clvmd=fake --with-cluster=internal ...

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 Makefile.in                             |    5 ++++
 test/Makefile.in                        |    2 +
 test/lvm-utils.sh                       |    3 ++
 test/t-fsadm.sh                         |    2 +-
 test/t-mirror-basic.sh                  |    2 +-
 test/t-mirror-lvconvert-usage.sh        |    2 +-
 test/t-mirror-lvconvert.sh              |    2 +-
 test/t-mirror-names.sh                  |    2 +-
 test/t-mirror-vgreduce-removemissing.sh |    2 +-
 test/t-pool-labels.sh                   |    2 +-
 test/t-pvcreate-operation-md.sh         |   14 +++++-----
 test/t-pvmove-basic.sh                  |    2 +-
 test/test-utils.sh                      |   41 +++++++++++++++++++++++++++----
 13 files changed, 61 insertions(+), 20 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 556d1ff..d21542a 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -86,8 +86,13 @@ all: cscope.out
 endif
 
 check: all
+	$(MAKE) -C test clean
 	$(MAKE) -C test all
 
+cluster-check: all
+	$(MAKE) -C test clean
+	$(MAKE) -C test all LVM_TEST_LOCKING=3
+
 ifneq ("@LCOV@", "")
 .PHONY: lcov-reset lcov lcov-dated
 
diff --git a/test/Makefile.in b/test/Makefile.in
index 75366fd..5bf6b75 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -56,6 +56,7 @@ init.sh: $(srcdir)/Makefile.in $(srcdir)/test-utils.sh .bin-dir-stamp bin/not bi
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t
+	echo 'export LVM_TEST_LOCKING=$(LVM_TEST_LOCKING)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
 	if test "$(srcdir)" != "."; then cp $(srcdir)/test-utils.sh \
@@ -72,6 +73,7 @@ Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	  ln -s ../lvm-wrapper bin/$$i; \
 	done
 	ln -s "$(abs_top_builddir)/tools/dmsetup" bin/dmsetup
+	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" bin/clvmd
 	touch $@
 
 lvm-wrapper: Makefile
diff --git a/test/lvm-utils.sh b/test/lvm-utils.sh
index 5ad8872..8d2a4e9 100644
--- a/test/lvm-utils.sh
+++ b/test/lvm-utils.sh
@@ -12,6 +12,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 export LVM_SUPPRESS_FD_WARNINGS=1
+test -n "$LVM_TEST_LOCKING" || export LVM_TEST_LOCKING=1
 
 ME=$(basename "$0")
 warn() { echo >&2 "$ME: $@"; }
@@ -201,6 +202,8 @@ init_root_dir_()
   }
   global {
     library_dir = "$G_root_/lib"
+    locking_type = $LVM_TEST_LOCKING
+    fallback_to_local_locking = 0
   }
 EOF
 }
diff --git a/test/t-fsadm.sh b/test/t-fsadm.sh
index 421ec6b..25367dd 100644
--- a/test/t-fsadm.sh
+++ b/test/t-fsadm.sh
@@ -11,7 +11,7 @@
 
 . ./test-utils.sh
 
-exit 200
+skip_test
 # doesn't work right now
 aux prepare_pvs 2
 aux pvcreate --metadatacopies 0 $dev1
diff --git a/test/t-mirror-basic.sh b/test/t-mirror-basic.sh
index a68007c..a7c4592 100755
--- a/test/t-mirror-basic.sh
+++ b/test/t-mirror-basic.sh
@@ -14,7 +14,7 @@ test_description="ensure that basic operations on mirrored LV works"
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
+dmsetup_has_dm_devdir_support_ || skip_test
 
 # ---------------------------------------------------------------------
 # Utilities
diff --git a/test/t-mirror-lvconvert-usage.sh b/test/t-mirror-lvconvert-usage.sh
index d27c1b3..f8322a1 100644
--- a/test/t-mirror-lvconvert-usage.sh
+++ b/test/t-mirror-lvconvert-usage.sh
@@ -10,7 +10,7 @@
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
+dmsetup_has_dm_devdir_support_ || skip_test
 
 aux prepare_vg 5
 
diff --git a/test/t-mirror-lvconvert.sh b/test/t-mirror-lvconvert.sh
index e223d2b..914fefc 100755
--- a/test/t-mirror-lvconvert.sh
+++ b/test/t-mirror-lvconvert.sh
@@ -11,7 +11,7 @@
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
+dmsetup_has_dm_devdir_support_ || skip_test
 
 mimages_are_redundant_ ()
 {
diff --git a/test/t-mirror-names.sh b/test/t-mirror-names.sh
index b73fd25..5165502 100644
--- a/test/t-mirror-names.sh
+++ b/test/t-mirror-names.sh
@@ -14,7 +14,7 @@ test_description="check namings of mirrored LV"
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
+dmsetup_has_dm_devdir_support_ || skip_test
 
 # ---------------------------------------------------------------------
 # Utilities
diff --git a/test/t-mirror-vgreduce-removemissing.sh b/test/t-mirror-vgreduce-removemissing.sh
index efd6b5d..3ddb41c 100755
--- a/test/t-mirror-vgreduce-removemissing.sh
+++ b/test/t-mirror-vgreduce-removemissing.sh
@@ -13,7 +13,7 @@ test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
+dmsetup_has_dm_devdir_support_ || skip_test
 
 lv_is_on_ ()
 {
diff --git a/test/t-pool-labels.sh b/test/t-pool-labels.sh
index 57f4f9a..cc202f5 100755
--- a/test/t-pool-labels.sh
+++ b/test/t-pool-labels.sh
@@ -20,7 +20,7 @@ create_pool_label_()
   env printf "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
 }
 
-env printf "" || exit 200 # skip if printf is not available
+env printf "" || skip_test # skip if printf is not available
 
 aux prepare_devs 2
 
diff --git a/test/t-pvcreate-operation-md.sh b/test/t-pvcreate-operation-md.sh
index 42895a1..382700d 100644
--- a/test/t-pvcreate-operation-md.sh
+++ b/test/t-pvcreate-operation-md.sh
@@ -9,12 +9,12 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # skip this test if mdadm or sfdisk (or others) aren't available
-which mdadm || exit 200
-which sfdisk || exit 200
-which perl || exit 200
-which awk || exit 200
-which cut || exit 200
-test -f /proc/mdstat || exit 200
+which mdadm || skip_test
+which sfdisk || skip_test
+which perl || skip_test
+which awk || skip_test
+which cut || skip_test
+test -f /proc/mdstat || skip_test
 
 . ./test-utils.sh
 
@@ -43,7 +43,7 @@ cleanup_md() {
 }
 
 # create 2 disk MD raid0 array (stripe_width=128K)
-[ -b "$mddev" ] && exit 200
+[ -b "$mddev" ] && skip_test
 mdadm --create $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
 trap 'aux cleanup_md' EXIT # cleanup this MD device at the end of the test
 
diff --git a/test/t-pvmove-basic.sh b/test/t-pvmove-basic.sh
index 5070b72..ebd5661 100755
--- a/test/t-pvmove-basic.sh
+++ b/test/t-pvmove-basic.sh
@@ -14,7 +14,7 @@ test_description="ensure that pvmove works with basic options"
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
+dmsetup_has_dm_devdir_support_ || skip_test
 
 # ---------------------------------------------------------------------
 # Utilities
diff --git a/test/test-utils.sh b/test/test-utils.sh
index 119a549..c9c9635 100644
--- a/test/test-utils.sh
+++ b/test/test-utils.sh
@@ -17,6 +17,25 @@ aux() {
 	#"$@"
 }
 
+prepare_clvmd() {
+	if test "$LVM_TEST_LOCKING" -ne 3 ; then
+		return 0
+	fi
+
+	if pgrep clvmd ; then
+		return 1
+	fi
+
+	clvmd -Ifake -d 1 >clvmd.log 2>&1 &
+}
+
+stop_clvmd() {
+	if test "$LVM_TEST_LOCKING" -eq 3 ; then
+		pkill -9 clvmd
+		sleep 1
+	fi
+}
+
 STACKTRACE() {
 	trap - ERR;
 	i=0;
@@ -24,7 +43,7 @@ STACKTRACE() {
 		echo "$i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
 		i=$(($i + 1));
 	done
-}	
+}
 
 teardown() {
 	echo $LOOP
@@ -42,14 +61,22 @@ teardown() {
 
 	test -n "$LOOP" && losetup -d $LOOP
 	test -n "$LOOPFILE" && rm -f $LOOPFILE
+	return 0
 }
 
 teardown_() {
+	stop_clvmd
 	teardown
 	cleanup_ # user-overridable cleanup
 	testlib_cleanup_ # call test-lib cleanup routine, too
 }
 
+skip_test() {
+	trap - exit
+	teardown_
+	exit 200
+}
+
 make_ioerror() {
 	echo 0 10000000 error | dmsetup create ioerror
 	dmsetup resume ioerror
@@ -61,9 +88,6 @@ prepare_loop() {
 	test -n "$size" || size=32
 
 	test -n "$LOOP" && return 0
-	trap 'aux teardown_' EXIT # don't forget to clean up
-	trap 'set +vex; STACKTRACE; set -vex' ERR
-	#trap - ERR
 
 	LOOPFILE="$PWD/test.img"
 	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=1 seek=$(($size-1))
@@ -202,10 +226,17 @@ prepare_lvmconf() {
     abort_on_internal_errors = 1
     library_dir = "$G_root_/lib"
     locking_dir = "$G_root_/var/lock/lvm"
+    locking_type = $LVM_TEST_LOCKING
+    fallback_to_local_locking = 0
   }
 EOF
 }
 
 set -vexE
 aux prepare_lvmconf
-
+aux prepare_clvmd || {
+	echo "Cannot use fake cluster locking with real clvmd running."
+	exit 200
+}
+trap 'aux teardown_' EXIT # don't forget to clean up
+trap 'set +vex; STACKTRACE; set -vex' ERR
-- 
1.6.5.7


