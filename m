From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 18:31:12 -0000
Subject: LVM2/test t-vgmerge-usage.sh t-vgrename-usage. ...
Message-ID: <20090902183112.18984.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 18:31:11

Modified files:
	test           : t-vgmerge-usage.sh t-vgrename-usage.sh 
	                 t-vgsplit-usage.sh 

Log message:
	Add alphabetical vgname ordering tests for vgsplit, vgmerge, vgrename.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgrename-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/t-vgmerge-usage.sh	2008/10/06 16:47:07	1.5
+++ LVM2/test/t-vgmerge-usage.sh	2009/09/02 18:31:11	1.6
@@ -16,10 +16,15 @@
 aux prepare_pvs 4
 
 # 'vgmerge normal operation'
+# ensure ordering does not matter
 vgcreate $vg1 $dev1 $dev2 
 vgcreate $vg2 $dev3 $dev4 
 vgmerge $vg1 $vg2 
 vgremove $vg1
+vgcreate $vg2 $dev1 $dev2
+vgcreate $vg1 $dev3 $dev4
+vgmerge $vg2 $vg1
+vgremove $vg2
 
 # 'vgmerge rejects duplicate vg name'
 vgcreate $vg1 $dev1 $dev2 
--- LVM2/test/t-vgrename-usage.sh	2009/06/05 10:42:22	1.4
+++ LVM2/test/t-vgrename-usage.sh	2009/09/02 18:31:11	1.5
@@ -15,10 +15,14 @@
 pvcreate --metadatacopies 0 $dev3 $dev4
 
 # vgrename normal operation - rename vg1 to vg2
+# vgrename normal operation - rename vg2 to vg1
+# ensure name ordering does not matter
 vgcreate $vg1 $dev1 $dev2
 vgrename $vg1 $vg2
 check_vg_field_ $vg2 vg_name $vg2
-vgremove $vg2
+vgrename $vg2 $vg1
+check_vg_field_ $vg1 vg_name $vg1
+vgremove $vg1
 
 # vgrename by uuid (bz231187)
 vgcreate $vg1 $dev1 $dev3
--- LVM2/test/t-vgsplit-usage.sh	2008/11/10 12:43:35	1.12
+++ LVM2/test/t-vgsplit-usage.sh	2009/09/02 18:31:11	1.13
@@ -15,15 +15,21 @@
 
 aux prepare_devs 5
 
-# FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
-# fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
-# metadata
-
 for mdatype in 1 2
 do
 
 pvcreate -M$mdatype $devs
 
+# ensure name order does not matter
+vgcreate -M$mdatype $vg1 $devs
+vgsplit $vg1 $vg2 $dev1
+vgremove $vg1
+vgremove $vg2
+vgcreate -M$mdatype $vg2 $devs
+vgsplit $vg2 $vg1 $dev1
+vgremove $vg1
+vgremove $vg2
+
 # vgsplit accepts new vg as destination of split
 # lvm1 -- bz244792
 vgcreate -M$mdatype $vg1 $devs


