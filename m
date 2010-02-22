From: Milan Broz <mbroz@redhat.com>
Date: Mon, 22 Feb 2010 15:55:26 +0100
Subject: [PATCH 2/2] Add cluster-check to provide basic cluster locking (using fake cluster).
In-Reply-To: <1266850526-31583-1-git-send-email-mbroz@redhat.com>
References: <1266850526-31583-1-git-send-email-mbroz@redhat.com>
Message-ID: <1266850526-31583-2-git-send-email-mbroz@redhat.com>
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
 test/t-snapshot-merge.sh                |    4 +-
 test/t-topology-support.sh              |    4 +-
 test/test-utils.sh                      |   38 ++++++++++++++++++++++++++++--
 15 files changed, 64 insertions(+), 22 deletions(-)

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
index 7de6f45..13c513a 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -61,6 +61,7 @@ init.sh: $(srcdir)/Makefile.in $(srcdir)/test-utils.sh .bin-dir-stamp bin/not bi
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
+	echo 'export LVM_TEST_LOCKING=$(LVM_TEST_LOCKING)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
 	if test "$(srcdir)" != "."; then cp $(srcdir)/test-utils.sh \
@@ -77,6 +78,7 @@ Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	  ln -s ../lvm-wrapper bin/$$i; \
 	done
 	ln -s "$(abs_top_builddir)/tools/dmsetup" bin/dmsetup
+	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" bin/clvmd
 	touch $@
 
 lvm-wrapper: Makefile
diff --git a/test/lvm-utils.sh b/test/lvm-utils.sh
index 0aae767..017d874 100644
--- a/test/lvm-utils.sh
+++ b/test/lvm-utils.sh
@@ -12,6 +12,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 export LVM_SUPPRESS_FD_WARNINGS=1
+test -n "$LVM_TEST_LOCKING" || export LVM_TEST_LOCKING=1
 
 ME=$(basename "$0")
 warn() { echo >&2 "$ME: $@"; }
@@ -223,6 +224,8 @@ init_root_dir_()
   }
   global {
     library_dir = "$G_root_/lib"
+    locking_type = $LVM_TEST_LOCKING
+    fallback_to_local_locking = 0
   }
   activation {
     udev_sync = 1
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
index 9c3efc4..3a641cc 100755
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
index 6d47ab4..10a1c2f 100755
--- a/test/t-mirror-lvconvert.sh
+++ b/test/t-mirror-lvconvert.sh
@@ -11,7 +11,7 @@
 
 . ./test-utils.sh
 
-dmsetup_has_dm_devdir_support_ || exit 200
+dmsetup_has_dm_devdir_support_ || skip_test
 
 mimages_are_redundant_ ()
 {
diff --git a/test/t-mirror-names.sh b/test/t-mirror-names.sh
index edf9fd7..b3178e8 100644
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
index 6c32ee6..f73a7eb 100644
--- a/test/t-pvcreate-operation-md.sh
+++ b/test/t-pvcreate-operation-md.sh
@@ -9,14 +9,14 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # skip this test if mdadm or sfdisk (or others) aren't available
-which mdadm || exit 200
-which sfdisk || exit 200
-which perl || exit 200
-which awk || exit 200
-which cut || exit 200
+which mdadm || skip_test
+which sfdisk || skip_test
+which perl || skip_test
+which awk || skip_test
+which cut || skip_test
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
-modprobe raid0 || exit 200
+modprobe raid0 || skip_test
 
 . ./test-utils.sh
 
@@ -45,7 +45,7 @@ cleanup_md() {
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
diff --git a/test/t-snapshot-merge.sh b/test/t-snapshot-merge.sh
index 9d953cf..2015505 100755
--- a/test/t-snapshot-merge.sh
+++ b/test/t-snapshot-merge.sh
@@ -10,7 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 set -xv
 
-which mkfs.ext3 || exit 200
+which mkfs.ext3 || skip_test
 
 . ./test-utils.sh
 
@@ -48,7 +48,7 @@ aux prepare_vg 1 100
 setup_merge $vg $lv1
 
 # now that snapshot LV is created: test if snapshot-merge target is available
-$(dmsetup targets | grep -q snapshot-merge) || exit 200
+$(dmsetup targets | grep -q snapshot-merge) || skip_test
 
 lvs -a
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
diff --git a/test/t-topology-support.sh b/test/t-topology-support.sh
index 27ea4f7..f6b4b1e 100644
--- a/test/t-topology-support.sh
+++ b/test/t-topology-support.sh
@@ -8,12 +8,12 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-which mkfs.ext3 || exit 200
+which mkfs.ext3 || skip_test
 
 # Get linux minor version
 linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
 
-test $linux_minor -ge 31 || exit 200
+test $linux_minor -ge 31 || skip_test
 
 . ./test-utils.sh
 
diff --git a/test/test-utils.sh b/test/test-utils.sh
index 6606c56..e13b5b4 100644
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
@@ -65,14 +84,22 @@ teardown() {
 		test -n "$LOOPFILE" && rm -f $LOOPFILE
 	fi
 	unset devs # devs is set in prepare_devs()
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
 	ln -s $G_dev_/mapper/ioerror $G_dev_/ioerror
@@ -83,9 +110,6 @@ prepare_loop() {
 	test -n "$size" || size=32
 
 	test -n "$LOOP" && return 0
-	trap 'aux teardown_' EXIT # don't forget to clean up
-	trap 'set +vex; STACKTRACE; set -vex' ERR
-	#trap - ERR
 
 	LOOPFILE="$PWD/test.img"
 	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=1 seek=$(($size-1))
@@ -294,6 +318,8 @@ prepare_lvmconf() {
     abort_on_internal_errors = 1
     library_dir = "$G_root_/lib"
     locking_dir = "$G_root_/var/lock/lvm"
+    locking_type = $LVM_TEST_LOCKING
+    fallback_to_local_locking = 0
   }
   activation {
     udev_sync = 1
@@ -304,4 +330,10 @@ EOF
 
 set -vexE -o pipefail
 aux prepare_lvmconf
+aux prepare_clvmd || {
+	echo "Cannot use fake cluster locking with real clvmd running."
+	exit 200
+}
+trap 'aux teardown_' EXIT # don't forget to clean up
+trap 'set +vex; STACKTRACE; set -vex' ERR
 
-- 
1.7.0


