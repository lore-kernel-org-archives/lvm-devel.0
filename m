From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 19:35:36 -0000
Subject: LVM2/test t-lvcreate-usage.sh t-pvremove-usage ...
Message-ID: <20090714193536.30991.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 19:35:35

Modified files:
	test           : t-lvcreate-usage.sh t-pvremove-usage.sh 
	                 t-vgcreate-usage.sh 

Log message:
	Add a few negative tests which should fail cleanly if pv, vg, lvs don't exist.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvremove-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-lvcreate-usage.sh	2009/06/01 15:55:07	1.14
+++ LVM2/test/t-lvcreate-usage.sh	2009/07/14 19:35:35	1.15
@@ -21,6 +21,8 @@
 lvcreate -n $lv -l 4 $vg 
 not lvcreate -n $lv -l 4 $vg
 lvremove -ff $vg/$lv
+# try to remove it again - should fail (but not segfault)
+not lvremove -ff $vg/$lv
 
 # "lvcreate rejects a negative stripe_size"
 not lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err;
--- LVM2/test/t-pvremove-usage.sh	2008/11/10 12:41:52	1.3
+++ LVM2/test/t-pvremove-usage.sh	2009/07/14 19:35:35	1.4
@@ -16,9 +16,6 @@
 pvcreate --metadatacopies 0 $dev2
 pvcreate --metadatacopies 2 $dev3
 
-# check pvremove fails when bogus pv given
-not pvremove $dev2 bogus
-
 # failing, but still removing everything what can be removed
 # is somewhat odd as default, what do we have -f for?
 pvs | not grep $dev2
@@ -32,6 +29,8 @@
     # check pvremove truly wipes the label (pvscan wont find) (---metadatacopies $mdacp)
     pvcreate --metadatacopies $mdacp $dev3
     pvremove $dev3
+    # try to remove agail - should fail cleanly
+    not pvremove $dev3
     pvscan | not grep $dev3
 
 	# bz179473 refuse to wipe non-PV device without -f
--- LVM2/test/t-vgcreate-usage.sh	2009/07/09 08:50:55	1.8
+++ LVM2/test/t-vgcreate-usage.sh	2009/07/14 19:35:35	1.9
@@ -21,6 +21,9 @@
 vgcreate $vg --physicalextentsize 8.00M $dev1 $dev2 
 check_vg_field_ $vg vg_extent_size 8.00M 
 vgremove $vg
+# try vgck and to remove it again - should fail (but not segfault)
+not vgremove $vg
+not vgck $vg
 
 #COMM 'vgcreate accepts smaller (128) maxlogicalvolumes for VG'
 vgcreate $vg --maxlogicalvolumes 128 $dev1 $dev2 


