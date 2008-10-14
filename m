From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Oct 2008 19:48:02 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20081014194802.30218.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-10-14 19:48:02

Modified files:
	test           : test-utils.sh 

Log message:
	Re-indent test-utils.sh consistently, using tabs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/test-utils.sh	2008/10/06 16:55:30	1.3
+++ LVM2/test/test-utils.sh	2008/10/14 19:48:01	1.4
@@ -12,8 +12,8 @@
 . ./test-lib.sh
 
 aux() {
-    # use just "$@" for verbose operation
-    "$@" > /dev/null 2> /dev/null
+        # use just "$@" for verbose operation
+	"$@" > /dev/null 2> /dev/null
 	#"$@"
 }
 
@@ -29,37 +29,37 @@
 }	
 
 teardown() {
-    echo $LOOP
-    echo $PREFIX
+	echo $LOOP
+	echo $PREFIX
 
-    test -n "$PREFIX" && {
-	rm -rf /dev/$PREFIX*
-	while dmsetup table | grep -q ^$PREFIX; do
-            for s in `dmsetup table | grep ^$PREFIX| cut -f1 -d:`; do
-		dmsetup resume $s 2>/dev/null > /dev/null || true
-		dmsetup remove $s 2>/dev/null > /dev/null || true
-            done
-	done
-    }
+	test -n "$PREFIX" && {
+		rm -rf /dev/$PREFIX*
+		while dmsetup table | grep -q ^$PREFIX; do
+			for s in `dmsetup table | grep ^$PREFIX| cut -f1 -d:`; do
+				dmsetup resume $s 2>/dev/null > /dev/null || true
+				dmsetup remove $s 2>/dev/null > /dev/null || true
+			done
+		done
+	}
 
-    test -n "$LOOP" && losetup -d $LOOP
-    test -n "$LOOPFILE" && rm -f $LOOPFILE
+	test -n "$LOOP" && losetup -d $LOOP
+	test -n "$LOOPFILE" && rm -f $LOOPFILE
 
-    cleanup_ # user-overridable cleanup
-    testlib_cleanup_ # call test-lib cleanup routine, too
+	cleanup_ # user-overridable cleanup
+	testlib_cleanup_ # call test-lib cleanup routine, too
 }
 
 make_ioerror() {
-    echo 0 10000000 error | dmsetup create ioerror
-    dmsetup resume ioerror
-    ln -s /dev/mapper/ioerror /dev/ioerror
+	echo 0 10000000 error | dmsetup create ioerror
+	dmsetup resume ioerror
+	ln -s /dev/mapper/ioerror /dev/ioerror
 }
 
 prepare_loop() {
-    size=$1
-    test -n "$size" || size=32
+	size=$1
+	test -n "$size" || size=32
 
-    test -n "$LOOP" && return 0
+	test -n "$LOOP" && return 0
 	trap 'aux teardown' EXIT # don't forget to clean up
 	trap 'set +vex; STACKTRACE; set -vex' ERR
 	#trap - ERR
@@ -89,68 +89,68 @@
 }
 
 prepare_devs() {
-    local n="$1"
-    test -z "$n" && n=3
-    local devsize="$2"
-    test -z "$devsize" && devsize=33
-
-    prepare_loop $(($n*$devsize))
-
-    PREFIX="LVMTEST$$"
-
-    local loopsz=`blockdev --getsz $LOOP`
-    local size=$(($loopsz/$n))
-
-    for i in `seq 1 $n`; do
-	local name="${PREFIX}pv$i"
-	local dev="$G_dev_/mapper/$name"
-	eval "dev$i=$dev"
-	devs="$devs $dev"
-	echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
-	dmsetup create $name $name.table
-	dmsetup resume $name
-    done
+	local n="$1"
+	test -z "$n" && n=3
+	local devsize="$2"
+	test -z "$devsize" && devsize=33
+
+	prepare_loop $(($n*$devsize))
+
+	PREFIX="LVMTEST$$"
+
+	local loopsz=`blockdev --getsz $LOOP`
+	local size=$(($loopsz/$n))
+
+	for i in `seq 1 $n`; do
+		local name="${PREFIX}pv$i"
+		local dev="$G_dev_/mapper/$name"
+		eval "dev$i=$dev"
+		devs="$devs $dev"
+		echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
+		dmsetup create $name $name.table
+		dmsetup resume $name
+	done
 
     # set up some default names
-    vg=${PREFIX}vg
-    vg1=${PREFIX}vg1
-    vg2=${PREFIX}vg2
-    lv=LV
-    lv1=LV1
-    lv2=LV2
-    lv3=LV3
+	vg=${PREFIX}vg
+	vg1=${PREFIX}vg1
+	vg2=${PREFIX}vg2
+	lv=LV
+	lv1=LV1
+	lv2=LV2
+	lv3=LV3
 }
 
 disable_dev() {
-    for dev in "$@"; do
+	for dev in "$@"; do
         # first we make the device inaccessible
-	echo 0 10000000 error | dmsetup load $dev
-	dmsetup resume $dev
+		echo 0 10000000 error | dmsetup load $dev
+		dmsetup resume $dev
         # now let's try to get rid of it if it's unused
         #dmsetup remove $dev
-    done
+	done
 }
 
 enable_dev() {
-    for dev in "$@"; do
-	local name=`echo "$dev" | sed -e 's,.*/,,'`
-	dmsetup create $name $name.table || dmsetup load $name $name.table
-	dmsetup resume $dev
-    done
+	for dev in "$@"; do
+		local name=`echo "$dev" | sed -e 's,.*/,,'`
+		dmsetup create $name $name.table || dmsetup load $name $name.table
+		dmsetup resume $dev
+	done
 }
 
 prepare_pvs() {
-    prepare_devs "$@"
-    pvcreate $devs
+	prepare_devs "$@"
+	pvcreate $devs
 }
 
 prepare_vg() {
-    prepare_pvs "$@"
-    vgcreate $vg $devs
+	prepare_pvs "$@"
+	vgcreate $vg $devs
 }
 
 prepare_lvmconf() {
-  cat > $G_root_/etc/lvm.conf <<-EOF
+	cat > $G_root_/etc/lvm.conf <<-EOF
   devices {
     dir = "$G_dev_"
     scan = "$G_dev_"


