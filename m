From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 May 2009 21:50:23 -0000
Subject: LVM2/test t-lvcreate-usage.sh
Message-ID: <20090508215023.14892.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-08 21:50:22

Modified files:
	test           : t-lvcreate-usage.sh 

Log message:
	Update tests for region_size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/t-lvcreate-usage.sh	2009/05/08 04:24:52	1.11
+++ LVM2/test/t-lvcreate-usage.sh	2009/05/08 21:50:20	1.12
@@ -13,7 +13,7 @@
 
 . ./test-utils.sh
 
-aux prepare_pvs 2
+aux prepare_pvs 4
 aux pvcreate --metadatacopies 0 $dev1
 vgcreate -cn $vg $devs
 
@@ -48,10 +48,6 @@
 not lvcreate -L 64M -n $lv -i129 $vg 2>err
 grep "^  Number of stripes (129) must be between 1 and 128\$" err
 
-# 'lvcreate rejects an invalid regionsize (bz186013)' 
-not lvcreate -L 64M -n $lv -R0 $vg 2>err
-grep "Non-zero region size must be supplied." err
-
 # The case on lvdisplay output is to verify that the LV was not created.
 # 'lvcreate rejects an invalid stripe size'
 not lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err
@@ -84,3 +80,18 @@
 lvremove -ff $vg
 vgchange -l 0 $vg
 
+# regionsize must be
+# - nonzero (bz186013)
+# - a power of 2 and a multiple of page size
+# - <= size of LV
+not lvcreate -L 32M -n $lv -R0 $vg 2>err
+grep "Non-zero region size must be supplied." err
+not lvcreate -L 32M -n $lv -R 11k $vg
+not lvcreate -L 32M -n $lv -R 1k $vg
+lvcreate -L 32M -n $lv --regionsize 128M  -m 1 $vg
+check_lv_field_ $vg/$lv regionsize "32.00M"
+lvremove -ff $vg
+lvcreate -L 32M -n $lv --regionsize 4M -m 1 $vg
+check_lv_field_ $vg/$lv regionsize "4.00M"
+lvremove -ff $vg
+


