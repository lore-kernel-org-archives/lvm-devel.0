From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Apr 2010 14:46:29 -0000
Subject: LVM2/test Makefile.in lvm-utils.sh t-000-basic ...
Message-ID: <20100407144629.29115.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-07 14:46:27

Modified files:
	test           : Makefile.in lvm-utils.sh t-000-basic.sh 
	                 t-fsadm.sh t-lvcreate-operation.sh 
	                 t-lvcreate-pvtags.sh t-mirror-basic.sh 
	                 t-pvcreate-operation.sh t-pvmove-basic.sh 
	                 t-read-ahead.sh t-snapshot-merge.sh 
	                 t-topology-support.sh t-vgsplit-stacked.sh 
	                 test-utils.sh 
Removed files:
	test           : test-lib.sh 

Log message:
	Refactor the test utilities, dropping the legacy test-lib.sh and curtailing
	lvm-utils.sh. Clears up lots of unused code, should have little observable
	impact (it does change test directory layout slightly).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-fsadm.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-topology-support.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-stacked.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-lib.sh.diff?cvsroot=lvm2&r1=1.5&r2=NONE

--- LVM2/test/Makefile.in	2010/03/31 23:05:20	1.33
+++ LVM2/test/Makefile.in	2010/04/07 14:46:26	1.34
@@ -30,7 +30,7 @@
 
 SCRIPTS := $(wildcard $(srcdir)/t-*.sh) \
  $(srcdir)/test-utils.sh \
- $(srcdir)/test-lib.sh
+ $(srcdir)/lvm-utils.sh
 
 ifeq ("@UDEV_SYNC@", "yes")
 dm_udev_synchronisation = 1
--- LVM2/test/lvm-utils.sh	2010/03/26 13:21:28	1.23
+++ LVM2/test/lvm-utils.sh	2010/04/07 14:46:26	1.24
@@ -16,40 +16,6 @@
 ME=$(basename "$0")
 warn() { echo >&2 "$ME: $@"; }
 
-unsafe_losetup_()
-{
-  f=$1
-
-  test -n "$G_dev_" \
-    || error "Internal error: unsafe_losetup_ called before init_root_dir_"
-
-  # Iterate through $G_dev_/loop{,/}{0,1,2,3,4,5,6,7,8,9}
-  for slash in '' /; do
-    for i in 0 1 2 3 4 5 6 7 8 9; do
-      dev=$G_dev_/loop$slash$i
-      losetup $dev > /dev/null 2>&1 && continue;
-      losetup "$dev" "$f" > /dev/null && { echo "$dev"; return 0; }
-      break
-    done
-  done
-
-  return 1
-}
-
-loop_setup_()
-{
-  file=$1
-  dd if=/dev/zero of="$file" bs=1M count=1 seek=1000 > /dev/null 2>&1 \
-    || { warn "loop_setup_ failed: Unable to create tmp file $file"; return 1; }
-
-  # NOTE: this requires a new enough version of losetup
-  dev=$(unsafe_losetup_ "$file" 2>/dev/null) \
-    || { warn "loop_setup_ failed: Unable to create loopback device"; return 1; }
-
-  echo "$dev"
-  return 0;
-}
-
 compare_two_fields_()
 {
     local cmd1=$1;
@@ -176,61 +142,3 @@
   test "$?:$out" = "1:Invalid DM_DEV_DIR envvar value." -o \
        "$?:$out" = "1:Invalid DM_DEV_DIR environment variable value."
 }
-
-# set up private /dev and /etc
-init_root_dir_()
-{
-  test -n "$test_dir_rand_" \
-    || error "Internal error: called init_root_dir_ before" \
-      "defining \$test_dir_rand_"
-
-  # Define these two globals.
-  G_root_=$test_dir_rand_/root
-  G_dev_=$G_root_/dev
-
-  export LVM_SYSTEM_DIR=$G_root_/etc
-  export DM_DEV_DIR=$G_dev_
-
-  # Only the first caller does anything.
-  mkdir -p $G_root_/etc $G_dev_ $G_dev_/mapper $G_root_/lib
-  for i in 0 1 2 3 4 5 6 7; do
-    mknod $G_root_/dev/loop$i b 7 $i
-  done
-  for i in $abs_top_builddir/daemons/dmeventd/plugins/*/*.so
-  do
-    # NOTE: This check is necessary because the loop above will give us the value
-    # "$abs_top_builddir/daemons/dmeventd/plugins/*/*.so" if no files ending in 'so' exist.
-    # This is the best way I could quickly determine to skip over this bogus value.
-    if [ -f $i ]; then
-      echo Setting up symlink from $i to $G_root_/lib
-      ln -s $i $G_root_/lib
-    fi
-  done
-  cat > $G_root_/etc/lvm.conf <<-EOF
-  devices {
-    dir = "$G_dev_"
-    scan = "$G_dev_"
-    filter = [ "a/loop/", "a/mirror/", "a/mapper/", "r/.*/" ]
-    cache_dir = "$G_root_/etc"
-    sysfs_scan = 0
-  }
-  log {
-    verbose = $verboselevel
-    syslog = 0
-    indent = 1
-  }
-  backup {
-    backup = 0
-    archive = 0
-  }
-  global {
-    library_dir = "$G_root_/lib"
-  }
-  activation {
-    udev_sync = 1
-    udev_rules = 1
-  }
-EOF
-}
-
-init_root_dir_
--- LVM2/test/t-000-basic.sh	2009/07/13 12:42:26	1.7
+++ LVM2/test/t-000-basic.sh	2010/04/07 14:46:26	1.8
@@ -20,7 +20,7 @@
 # ensure they are the same
 diff -u actual expected
 
-mknod $G_root_/dev/null c 1 3 ||
+mknod $DM_DEV_DIR/null c 1 3 ||
   error "Can't create nodes on filesystem"
-echo >$G_root_/dev/null || 
+echo >$DM_DEV_DIR/null || 
   error "Filesystem for tests does not allow using device nodes (check nodev)"
--- LVM2/test/t-fsadm.sh	2009/01/15 17:14:38	1.1
+++ LVM2/test/t-fsadm.sh	2010/04/07 14:46:26	1.2
@@ -19,7 +19,7 @@
 
 # Test for block sizes != 1024 (rhbz #480022)
 lvcreate -n$lv1 -L 64M $vg
-mke2fs -b4096 -j $G_dev_/$vg/$lv1
-e2fsck -f -y $G_dev_/$vg/$lv1
-fsadm --lvresize resize $G_dev_/$vg/$lv1 128M
+mke2fs -b4096 -j $DM_DEV_DIR/$vg/$lv1
+e2fsck -f -y $DM_DEV_DIR/$vg/$lv1
+fsadm --lvresize resize $DM_DEV_DIR/$vg/$lv1 128M
 vgremove -ff $vg
--- LVM2/test/t-lvcreate-operation.sh	2010/04/06 14:24:13	1.4
+++ LVM2/test/t-lvcreate-operation.sh	2010/04/07 14:46:26	1.5
@@ -21,7 +21,7 @@
 	fi
 }
 
-aux prepare_pvs 2
+prepare_pvs 2
 aux pvcreate --metadatacopies 0 $dev1
 aux vgcreate -c n $vg $devs
 
--- LVM2/test/t-lvcreate-pvtags.sh	2009/12/28 18:33:04	1.6
+++ LVM2/test/t-lvcreate-pvtags.sh	2010/04/07 14:46:26	1.7
@@ -24,7 +24,7 @@
 not lvcreate -l4 -i4 $vg @fast
 
 # 2 stripes is too many with just one PV
-not lvcreate -l2 -i2 $vg $G_dev_/mapper/pv1
+not lvcreate -l2 -i2 $vg $DM_DEV_DIR/mapper/pv1
 
 # lvcreate mirror
 lvcreate -l1 -m1 $vg @fast
--- LVM2/test/t-mirror-basic.sh	2010/02/17 15:41:28	1.7
+++ LVM2/test/t-mirror-basic.sh	2010/04/07 14:46:26	1.8
@@ -21,7 +21,7 @@
 
 lvdev_()
 {
-  echo "$G_dev_/$1/$2"
+  echo "$DM_DEV_DIR/$1/$2"
 }
 
 mimages_are_redundant_ ()
--- LVM2/test/t-pvcreate-operation.sh	2010/02/22 14:47:55	1.17
+++ LVM2/test/t-pvcreate-operation.sh	2010/04/07 14:46:26	1.18
@@ -15,9 +15,9 @@
 for mdatype in 1 2
 do
 # pvcreate (lvm$mdatype) refuses to overwrite an mounted filesystem (bz168330)
-	test ! -d $G_root_/mnt && mkdir $G_root_/mnt 
+	test ! -d $TESTDIR/mnt && mkdir $TESTDIR/mnt
 	if mke2fs $dev1; then
-		mount $dev1 $G_root_/mnt
+		mount $dev1 $TESTDIR/mnt
 		not pvcreate -M$mdatype $dev1 2>err
 		grep "Can't open $dev1 exclusively.  Mounted filesystem?" err
 		umount $dev1
@@ -89,7 +89,7 @@
 # pvcreate (lvm2) fails writing LVM label at sector 4
 not pvcreate --labelsector 4 $dev1
 
-backupfile=mybackupfile-$(this_test_)
+backupfile=$PREFIX.mybackupfile
 uuid1=freddy-fred-fred-fred-fred-fred-freddy
 uuid2=freddy-fred-fred-fred-fred-fred-fredie
 bogusuuid=fred
--- LVM2/test/t-pvmove-basic.sh	2009/12/28 18:33:04	1.6
+++ LVM2/test/t-pvmove-basic.sh	2010/04/07 14:46:26	1.7
@@ -20,7 +20,7 @@
 # Utilities
 
 lvdev_() {
-  echo "$G_dev_/$1/$2"
+  echo "$DM_DEV_DIR/$1/$2"
 }
 
 lv_is_on_() {
--- LVM2/test/t-read-ahead.sh	2010/02/17 15:41:28	1.11
+++ LVM2/test/t-read-ahead.sh	2010/04/07 14:46:26	1.12
@@ -47,7 +47,7 @@
 blockdev --setra 768 $dev1
 vgscan
 lvcreate -n $lv -L4m $vg $dev1
-test $(blockdev --getra $G_dev_/$vg/$lv) -eq 768
+test $(blockdev --getra $DM_DEV_DIR/$vg/$lv) -eq 768
 lvremove -ff $vg
 
 # Check default, active/inactive values for read_ahead / kernel_read_ahead
--- LVM2/test/t-snapshot-merge.sh	2010/02/05 22:44:38	1.2
+++ LVM2/test/t-snapshot-merge.sh	2010/04/07 14:46:26	1.3
@@ -16,7 +16,7 @@
 
 lvdev_()
 {
-    echo "$G_dev_/$1/$2"
+    echo "$DM_DEV_DIR/$1/$2"
 }
 
 snap_lv_name_() {
--- LVM2/test/t-topology-support.sh	2010/01/19 17:06:50	1.2
+++ LVM2/test/t-topology-support.sh	2010/04/07 14:46:27	1.3
@@ -31,7 +31,7 @@
 
 lvdev_()
 {
-    echo "$G_dev_/$1/$2"
+    echo "$DM_DEV_DIR/$1/$2"
 }
 
 test_snapshot_mount()
--- LVM2/test/t-vgsplit-stacked.sh	2010/03/17 14:44:19	1.2
+++ LVM2/test/t-vgsplit-stacked.sh	2010/04/07 14:46:27	1.3
@@ -8,8 +8,8 @@
 lvcreate -n $lv1 -l 100%FREE $vg1
 
 #top VG
-pvcreate $G_dev_/$vg1/$lv1
-vgcreate $vg $G_dev_/$vg1/$lv1 $dev3
+pvcreate $DM_DEV_DIR/$vg1/$lv1
+vgcreate $vg $DM_DEV_DIR/$vg1/$lv1 $dev3
 
 vgchange -a n $vg
 vgchange -a n $vg1
--- LVM2/test/test-utils.sh	2010/04/06 17:36:43	1.29
+++ LVM2/test/test-utils.sh	2010/04/07 14:46:27	1.30
@@ -8,9 +8,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description="foo" # silence test-lib for now
-. ./test-lib.sh
-
 aux() {
         # use just "$@" for verbose operation
 	"$@" > /dev/null 2> /dev/null
@@ -71,12 +68,30 @@
 	# skip if we don't have our own clvmd...
 	(which clvmd | grep $abs_builddir) || exit 200
 
-	trap 'aux teardown_' EXIT # don't forget to clean up
+	trap_teardown
 
 	clvmd -Isinglenode -d 1 &
 	LOCAL_CLVMD="$!"
 }
 
+prepare_testroot() {
+	PWD="`pwd`"
+	PREFIX="LVMTEST$$"
+
+	trap_teardown
+	TESTDIR=$($abs_srcdir/mkdtemp ${LVM_TEST_DIR-$(pwd)} $PREFIX.XXXXXXXXXX) \
+		|| { echo "failed to create temporary directory in $test_dir_"; exit 1; }
+
+	export LVM_SYSTEM_DIR=$TESTDIR/etc
+	export DM_DEV_DIR=$TESTDIR/dev
+	mkdir $LVM_SYSTEM_DIR $DM_DEV_DIR $DM_DEV_DIR/mapper $TESTDIR/lib
+
+	for i in `find $abs_top_builddir/daemons/dmeventd/plugins/ -name \*.so`; do
+		echo Setting up symlink from $i to $TESTDIR/lib
+		ln -s $i $TESTDIR/lib
+	done
+}
+
 teardown() {
 	echo $LOOP
 	echo $PREFIX
@@ -84,12 +99,12 @@
 	test -n "$LOCAL_CLVMD" && kill -9 "$LOCAL_CLVMD"
 
 	test -n "$PREFIX" && {
-		rm -rf $G_root_/dev/$PREFIX*
+		rm -rf $TESTDIR/dev/$PREFIX*
 
 		init_udev_transaction
 		while dmsetup table | grep -q ^$PREFIX; do
-			for s in `dmsetup table | grep ^$PREFIX| awk '{ print substr($1,1,length($1)-1) }'`; do
-				dmsetup remove $s 2>/dev/null > /dev/null || true
+			for s in `dmsetup info -c -o name --noheading | grep ^$PREFIX`; do
+				dmsetup remove $s >& /dev/null || true
 			done
 		done
 		finish_udev_transaction
@@ -105,27 +120,35 @@
 		test -n "$LOOPFILE" && rm -f $LOOPFILE
 	fi
 	unset devs # devs is set in prepare_devs()
+
+	test -n "$TESTDIR" && {
+		cd $PWD
+		rm -rf $TESTDIR || echo BLA
+	}
 }
 
-teardown_() {
-	teardown
-	cleanup_ # user-overridable cleanup
-	testlib_cleanup_ # call test-lib cleanup routine, too
+trap_teardown() {
+	trap 'set +vex; STACKTRACE; set -vex' ERR
+	trap 'aux teardown' EXIT # don't forget to clean up
 }
 
 make_ioerror() {
 	echo 0 10000000 error | dmsetup create ioerror
-	ln -s $G_dev_/mapper/ioerror $G_dev_/ioerror
+	ln -s $DM_DEV_DIR/mapper/ioerror $DM_DEV_DIR/ioerror
 }
 
 prepare_loop() {
 	size=$1
 	test -n "$size" || size=32
 
-	test -n "$LOOP" && return 0
-	trap 'aux teardown_' EXIT # don't forget to clean up
-	trap 'set +vex; STACKTRACE; set -vex' ERR
-	#trap - ERR
+	test -z "$LOOP"
+	test -n "$DM_DEV_DIR"
+
+	trap_teardown
+
+	for i in 0 1 2 3 4 5 6 7; do
+		mknod $DM_DEV_DIR/loop$i b 7 $i
+	done
 
 	LOOPFILE="$PWD/test.img"
 	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=1 seek=$(($size-1))
@@ -136,10 +159,10 @@
 		return 0
 	else
 		# no -f support 
-		# Iterate through $G_dev_/loop{,/}{0,1,2,3,4,5,6,7}
+		# Iterate through $DM_DEV_DIR/loop{,/}{0,1,2,3,4,5,6,7}
 		for slash in '' /; do
 			for i in 0 1 2 3 4 5 6 7; do
-				local dev=$G_dev_/loop$slash$i
+				local dev=$DM_DEV_DIR/loop$slash$i
 				! losetup $dev >/dev/null 2>&1 || continue
 				# got a free
 				losetup "$dev" "$LOOPFILE"
@@ -174,8 +197,7 @@
     local SCSI_DEBUG_PARAMS="$@"
 
     test -n "$SCSI_DEBUG_DEV" && return 0
-    trap 'aux teardown_' EXIT # don't forget to clean up
-    trap 'set +vex; STACKTRACE; set -vex' ERR
+    trap_teardown
 
     # Skip test if awk isn't available (required for get_sd_devs_)
     which awk || exit 200
@@ -201,8 +223,8 @@
 	    fi
 	done
 	if [ $FOUND -eq 0 ]; then
-	    # Create symlink to scsi_debug device in $G_dev_
-	    SCSI_DEBUG_DEV=$G_dev_/$(basename $dev1)
+	    # Create symlink to scsi_debug device in $DM_DEV_DIR
+	    SCSI_DEBUG_DEV=$DM_DEV_DIR/$(basename $dev1)
 	    # Setting $LOOP provides means for prepare_devs() override
 	    LOOP=$SCSI_DEBUG_DEV
 	    ln -snf $dev1 $SCSI_DEBUG_DEV
@@ -228,8 +250,6 @@
 
 	prepare_loop $(($n*$devsize))
 
-	PREFIX="LVMTEST$$"
-
 	if ! loopsz=`blockdev --getsz $LOOP 2>/dev/null`; then
   		loopsz=`blockdev --getsize $LOOP 2>/dev/null`
 	fi
@@ -239,7 +259,7 @@
 	init_udev_transaction
 	for i in `seq 1 $n`; do
 		local name="${PREFIX}$pvname$i"
-		local dev="$G_dev_/mapper/$name"
+		local dev="$DM_DEV_DIR/mapper/$name"
 		eval "dev$i=$dev"
 		devs="$devs $dev"
 		echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
@@ -325,13 +345,13 @@
 		filter='[ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]'
         locktype=
 	if test -n "$LVM_TEST_LOCKING"; then locktype="locking_type = $LVM_TEST_LOCKING"; fi
-	cat > $G_root_/etc/lvm.conf <<-EOF
+	cat > $TESTDIR/etc/lvm.conf <<-EOF
   $LVM_TEST_CONFIG
   devices {
-    dir = "$G_dev_"
-    scan = "$G_dev_"
+    dir = "$DM_DEV_DIR"
+    scan = "$DM_DEV_DIR"
     filter = $filter
-    cache_dir = "$G_root_/etc"
+    cache_dir = "$TESTDIR/etc"
     sysfs_scan = 0
   }
   log {
@@ -344,8 +364,8 @@
   }
   global {
     abort_on_internal_errors = 1
-    library_dir = "$G_root_/lib"
-    locking_dir = "$G_root_/var/lock/lvm"
+    library_dir = "$TESTDIR/lib"
+    locking_dir = "$TESTDIR/var/lock/lvm"
     $locktype
   }
   activation {
@@ -353,9 +373,22 @@
     udev_rules = 1
   }
 EOF
+	cat $TESTDIR/etc/lvm.conf
 }
 
-set -vexE -o pipefail
-aux prepare_lvmconf
-prepare_clvmd
+prepare() {
+	prepare_testroot
+	prepare_lvmconf
+	prepare_clvmd
+	source ./lvm-utils.sh
+}
+
+LANG=C
+LC_ALL=C
+TZ=UTC
+unset CDPATH
 
+. ./init.sh || { echo >&2 you must run make first; exit 1; }
+
+set -vexE -o pipefail
+aux prepare


