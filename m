From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 Oct 2009 16:43:07 -0000
Subject: LVM2/test t-vgcreate-usage.sh t-vgextend-usage.sh
Message-ID: <20091031164307.6813.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-31 16:43:07

Modified files:
	test           : t-vgcreate-usage.sh t-vgextend-usage.sh 

Log message:
	Add to vgcreate and vgextend nightly tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-vgcreate-usage.sh	2009/10/05 20:55:57	1.12
+++ LVM2/test/t-vgcreate-usage.sh	2009/10/31 16:43:07	1.13
@@ -144,3 +144,18 @@
     vgremove -f $vg
     pvremove -f $dev1
 done
+
+# vgcreate fails if pv belongs to existing vg
+vgcreate $vg1 $dev1 $dev2
+not vgcreate $vg2 $dev2
+vgremove -f $vg1
+pvremove -f $dev1 $dev2
+
+# all PVs exist in the VG after created
+pvcreate $dev1
+vgcreate $vg1 $dev1 $dev2 $dev3
+check_pv_field_ $dev1 vg_name $vg1
+check_pv_field_ $dev2 vg_name $vg1
+check_pv_field_ $dev3 vg_name $vg1
+vgremove -f $vg1
+pvremove -f $dev1 $dev2 $dev3
--- LVM2/test/t-vgextend-usage.sh	2009/10/05 20:55:57	1.2
+++ LVM2/test/t-vgextend-usage.sh	2009/10/31 16:43:07	1.3
@@ -75,3 +75,27 @@
 vgremove -f $vg
 pvremove -f $dev1
 
+# vgextend fails if pv belongs to existing vg
+vgcreate $vg1 $dev1 $dev3
+vgcreate $vg2 $dev2
+not vgextend $vg2 $dev3
+vgremove -f $vg1
+vgremove -f $vg2
+pvremove -f $dev1 $dev2 $dev3
+
+#vgextend fails if vg is not resizeable
+vgcreate $vg1 $dev1 $dev2
+vgchange --resizeable n $vg1
+not vgextend $vg1 $dev3
+vgremove -f $vg1
+pvremove -f $dev1 $dev2
+
+# all PVs exist in the VG after extended
+pvcreate $dev1
+vgcreate $vg1 $dev2
+vgextend $vg1 $dev1 $dev3
+check_pv_field_ $dev1 vg_name $vg1
+check_pv_field_ $dev2 vg_name $vg1
+check_pv_field_ $dev3 vg_name $vg1
+vgremove -f $vg1
+pvremove -f $dev1 $dev2 $dev3


