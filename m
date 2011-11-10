From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 12:44:33 -0000
Subject: LVM2/test t-lvcreate-thin.sh
Message-ID: <20111110124433.8498.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 12:44:33

Modified files:
	test           : t-lvcreate-thin.sh 

Log message:
	Thin update testing script

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-thin.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-lvcreate-thin.sh	2011/09/16 12:23:59	1.1
+++ LVM2/test/t-lvcreate-thin.sh	2011/11/10 12:44:33	1.2
@@ -12,91 +12,109 @@
 
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
-exit 200
 
 . lib/test
 
-aux prepare_vg 4
-
-# FIXME: !!!disabled activation for testing for now!!!
-aux lvmconf "global/activation = 0"
-
 check_lv_exists_()
 {
 	for d in $*; do
 		check lv_exists $vg $d
-        done
+	done
+}
+
+check_lv_field_modules_()
+{
+	mod=$1
+	shift
+
+	for d in $*; do
+		check lv_field $vg/$d modules $mod
+	done
 }
 
 
+#
+# Main
+#
+aux target_at_least dm-thin-pool 1 0 0 || skip
+
+aux prepare_devs 2 64
+
+pvcreate $dev1 $dev2
+
+clustered=
+test -e LOCAL_CLVMD && clustered="--clustered y"
+
+vgcreate $clustered $vg -s 64K $dev1 $dev2
+
 # Create named pool only
-lvcreate -L4M -T $vg/pool1
-lvcreate -L4M -T --thinpool $vg/pool2
-lvcreate -L4M -T --thinpool pool3 $vg
-lvcreate -L4M --type thin $vg/pool4
-lvcreate -L4M --type thin --thinpool $vg/pool5
-lvcreate -L4M --type thin --thinpool pool6 $vg
-lvcreate -L4M --type thin_pool $vg/pool7
-lvcreate -L4M --type thin_pool --thinpool $vg/pool8
-lvcreate -L4M --type thin_pool --thinpool pool9 $vg
+lvcreate -l1 -T $vg/pool1
+lvcreate -l1 -T --thinpool $vg/pool2
+lvcreate -l1 -T --thinpool pool3 $vg
+lvcreate -l1 --type thin $vg/pool4
+lvcreate -l1 --type thin --thinpool $vg/pool5
+lvcreate -l1 --type thin --thinpool pool6 $vg
+lvcreate -l1 --type thin_pool $vg/pool7
+lvcreate -l1 --type thin_pool --thinpool $vg/pool8
+lvcreate -l1 --type thin_pool --thinpool pool9 $vg
 
-lvremove $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool4 $vg/pool5 $vg/pool6 $vg/pool7 $vg/pool8 $vg/pool9
+lvremove -ff $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool4 $vg/pool5 $vg/pool6 $vg/pool7 $vg/pool8 $vg/pool9
+check vg_field $vg lv_count 0
 
 
 # Create default pool name
-lvcreate -L8M -T $vg
-lvcreate -L8M --type thin $vg
-lvcreate -L8M --type thin_pool $vg
+lvcreate -l1 -T $vg
+lvcreate -l1 --type thin $vg
+lvcreate -l1 --type thin_pool $vg
 
-lvremove $vg/lvol0 $vg/lvol1 $vg/lvol2
+lvremove -ff $vg/lvol0 $vg/lvol1 $vg/lvol2
+check vg_field $vg lv_count 0
 
 
 # Create default pool and default thin LV
-lvcreate -L8M -V2G -T $vg
-lvcreate -L8M -V2G --type thin $vg
+lvcreate -l1 -V2G -T $vg
+lvcreate -l1 -V2G --type thin $vg
 
-lvremove -ff $vg/lvol0 $vg/lvol2
+lvremove -ff $vg
 
 
-# Create given pool and default thin LV
-lvcreate -L8M -V2G -T $vg/pool1
-lvcreate -L8M -V2G -T --thinpool $vg/pool2
-lvcreate -L8M -V2G -T --thinpool pool3 $vg
-lvcreate -L8M -V2G --type thin $vg/pool4
-lvcreate -L8M -V2G --type thin --thinpool $vg/pool5
-lvcreate -L8M -V2G --type thin --thinpool pool6 $vg
+# Create named pool and default thin LV
+lvcreate -L4M -V2G -T $vg/pool1
+lvcreate -L4M -V2G -T --thinpool $vg/pool2
+lvcreate -L4M -V2G -T --thinpool pool3 $vg
+lvcreate -L4M -V2G --type thin $vg/pool4
+lvcreate -L4M -V2G --type thin --thinpool $vg/pool5
+lvcreate -L4M -V2G --type thin --thinpool pool6 $vg
 
 check_lv_exists_ lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
-lvremove -ff $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool4 $vg/pool5 $vg/pool6
+lvremove -ff $vg
 
 
-# Create given pool and given thin LV
-lvcreate -L8M -V2G -T $vg/pool1 --name lv1
-lvcreate -L8M -V2G -T $vg/pool2 --name $vg/lv2
-lvcreate -L8M -V2G -T --thinpool $vg/pool3 --name lv3
-lvcreate -L8M -V2G -T --thinpool $vg/pool4 --name $vg/lv4
-lvcreate -L8M -V2G -T --thinpool pool5 --name lv5 $vg
-lvcreate -L8M -V2G -T --thinpool pool6 --name $vg/lv6 $vg
+# Create named pool and named thin LV
+lvcreate -L4M -V2G -T $vg/pool1 --name lv1
+lvcreate -L4M -V2G -T $vg/pool2 --name $vg/lv2
+lvcreate -L4M -V2G -T --thinpool $vg/pool3 --name lv3
+lvcreate -L4M -V2G -T --thinpool $vg/pool4 --name $vg/lv4
+lvcreate -L4M -V2G -T --thinpool pool5 --name lv5 $vg
+lvcreate -L4M -V2G -T --thinpool pool6 --name $vg/lv6 $vg
 
 check_lv_exists_ lv1 lv2 lv3 lv4 lv5 lv6
-lvremove -ff $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool4 $vg/pool5 $vg/pool6
+lvremove -ff $vg
 
 
-lvcreate -L8M -V2G --type thin $vg/pool1 --name lv1
-lvcreate -L8M -V2G --type thin $vg/pool2 --name $vg/lv2
-lvcreate -L8M -V2G --type thin --thinpool $vg/pool3 --name lv3
-lvcreate -L8M -V2G --type thin --thinpool $vg/pool4 --name $vg/lv4
-lvcreate -L8M -V2G --type thin --thinpool pool5 --name lv5 $vg
-lvcreate -L8M -V2G --type thin --thinpool pool6 --name $vg/lv6 $vg
+lvcreate -L4M -V2G --type thin $vg/pool1 --name lv1
+lvcreate -L4M -V2G --type thin $vg/pool2 --name $vg/lv2
+lvcreate -L4M -V2G --type thin --thinpool $vg/pool3 --name lv3
+lvcreate -L4M -V2G --type thin --thinpool $vg/pool4 --name $vg/lv4
+lvcreate -L4M -V2G --type thin --thinpool pool5 --name lv5 $vg
+lvcreate -L4M -V2G --type thin --thinpool pool6 --name $vg/lv6 $vg
 
 check_lv_exists_ lv1 lv2 lv3 lv4 lv5 lv6
-lvremove -ff $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool4 $vg/pool5 $vg/pool6
-
+lvremove -ff $vg
 
-check vg_field $vg lv_count 0
 
-# Create thin LV in existing pool
-lvcreate -L8M -T $vg/pool
+# Create default thin LV in existing pool
+lvcreate -L4M -T $vg/pool
 lvcreate -V2G -T $vg/pool
 lvcreate -V2G -T --thinpool $vg/pool
 lvcreate -V2G -T --thinpool pool $vg
@@ -107,6 +125,7 @@
 check_lv_exists_ lvol0 lvol1 lvol2 lvol3 lvol4 lvol5
 
 
+# Create named thin LV in existing pool
 lvcreate -V2G -T $vg/pool --name lv1
 lvcreate -V2G -T $vg/pool --name $vg/lv2
 lvcreate -V2G -T --thinpool $vg/pool --name lv3
@@ -122,25 +141,45 @@
 
 check_lv_exists_ lv1 lv2 lv3 lv4 lv5 lv6 lv7 lv8 lv9 lv10 lv11 lv12
 check vg_field $vg lv_count 19
-lvremove -ff $vg/pool
 
+lvremove -ff $vg
+check vg_field $vg lv_count 0
+
+
+# Create thin snapshot of thinLV
+lvcreate -L4M -V2G -T $vg/pool --name lv1
+lvcreate -s $vg/lv1
+lvcreate -s $vg/lv1 --name lv2
+lvcreate -s $vg/lv1 --name $vg/lv3
+lvcreate --type snapshot $vg/lv1
+lvcreate --type snapshot $vg/lv1 --name lv4
+lvcreate --type snapshot $vg/lv1 --name $vg/lv5
+
+check_lv_field_modules_ thin-pool lv1 lvol0 lv2 lv3 lvol1 lv4 lv5
+check vg_field $vg lv_count 8
+lvremove -ff $vg
+
+
+# Normal Snapshots of thinLV
+lvcreate -L4M -V2G -T $vg/pool --name lv1
+lvcreate -s $vg/lv1 -l1
+lvcreate -s $vg/lv1 -l1 --name lv2
+lvcreate -s $vg/lv1 -l1 --name $vg/lv3
+lvcreate -s lv1 -L4M --name $vg/lv4
+
+check_lv_field_modules_ snapshot lvol0 lv2 lv3 lv4
+check vg_field $vg lv_count 6
 
+lvremove -ff $vg
 check vg_field $vg lv_count 0
 
-exit 0
-# FIXME: !!!Unsupported yet!!!
 
-# Create snapshot of thinLV
-lvcreate -L8M -V2G -T $vg/pool --name lv1
-should lvcreate -s $vg/lv1
-should lvcreate -s $vg/lv1 --name lv2
-should lvcreate -s $vg/lv1 --name $vg/lv3
-should lvcreate --type snapshot $vg/lv1
-should lvcreate --type snapshot $vg/lv1 --name lv4
-should lvcreate --type snapshot $vg/lv1 --name $vg/lv5
-
-# Normal Snapshots
-should lvcreate -s $vg/lv0 -L8M
-should lvcreate -s $vg/lv0 -L8M --name lv6
-should lvcreate -s $vg/lv0 -L8M --name $vg/lv7
-should lvcreate -s lv0 -L12M --name $vg/lv8
+# Fail cases
+# Too small pool size (1 extent 64KB) for given chunk size
+not lvcreate --chunksize 256 -l1 -T $vg/pool1
+# Too small chunk size (min is 64KB -  128 sectors)
+not lvcreate --chunksize 32 -l1 -T $vg/pool1
+
+lvcreate -L4M -V2G --name lv1 -T $vg/pool1
+# Origin name is not accepted
+not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4


