From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 08:50:56 -0000
Subject: LVM2/test t-vgcreate-usage.sh
Message-ID: <20090709085056.31824.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 08:50:55

Modified files:
	test           : t-vgcreate-usage.sh 

Log message:
	Update t-vgcreate-usage.sh to check for default vg properties.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-vgcreate-usage.sh	2009/05/08 05:15:52	1.7
+++ LVM2/test/t-vgcreate-usage.sh	2009/07/09 08:50:55	1.8
@@ -69,9 +69,6 @@
 
 # Test default (4MB) vg_extent_size as well as limits of extent_size
 not vgcreate --physicalextentsize 0K $vg $dev1 $dev2
-vgcreate $vg $dev1 $dev2
-check_vg_field_ $vg vg_extent_size 4.00M
-vgremove -ff $vg
 vgcreate --physicalextentsize 1K $vg $dev1 $dev2
 check_vg_field_ $vg vg_extent_size 1.00K
 vgremove -ff $vg
@@ -79,3 +76,11 @@
 not vgcreate --physicalextentsize 1024T $vg $dev1 $dev2
 #not vgcreate --physicalextentsize 1T $vg $dev1 $dev2
 # FIXME: vgcreate allows physicalextentsize larger than pv size!
+
+# Test default max_lv, max_pv, extent_size, alloc_policy, clustered
+vgcreate $vg $dev1 $dev2
+check_vg_field_ $vg vg_extent_size 4.00M
+check_vg_field_ $vg max_lv 0
+check_vg_field_ $vg max_pv 0
+check_vg_field_ $vg vg_attr "wz--n-"
+vgremove -ff $vg


