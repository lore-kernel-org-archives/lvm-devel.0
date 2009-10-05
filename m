From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:04:41 -0000
Subject: LVM2 ./WHATS_NEW test/t-vgcreate-usage.sh
Message-ID: <20091005200441.425.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:04:41

Modified files:
	.              : WHATS_NEW 
	test           : t-vgcreate-usage.sh 

Log message:
	Add implicit tests for implicit pvcreate during vgcreate and vgextend.
	
	Update tests and WHATS_NEW for implicit pvcreate support.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1290&r2=1.1291
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2009/10/05 12:44:20	1.1290
+++ LVM2/WHATS_NEW	2009/10/05 20:04:40	1.1291
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Add implict pvcreate support to vgcreate and vgextend.
   Correct example.conf to indicate that lvm2 not lvm1 is the default format.
   Remove an unused stray LVM1_SUPPORT ifdef.
   Only include selinux libs in libdevmapper.pc when selinux build enabled.
--- LVM2/test/t-vgcreate-usage.sh	2009/09/30 16:13:53	1.10
+++ LVM2/test/t-vgcreate-usage.sh	2009/10/05 20:04:40	1.11
@@ -87,3 +87,60 @@
 check_vg_field_ $vg max_pv 0
 check_vg_field_ $vg vg_attr "wz--n-"
 vgremove -ff $vg
+
+# Implicit pvcreate tests, test pvcreate options on vgcreate
+# --force, --yes, --metadata{size|copies|type}, --zero
+# --dataalignment[offset]
+pvremove $dev1 $dev2
+vgcreate --force --yes --zero y $vg $dev1 $dev2
+vgremove -f $vg
+pvremove -f $dev1
+
+for i in 0 1 2 3
+do
+# vgcreate (lvm2) succeeds writing LVM label at sector $i
+    vgcreate --labelsector $i $vg $dev1
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
+    vgremove -f $vg
+    pvremove -f $dev1
+done
+
+# metadatacopies
+for i in 1 2
+do
+    vgcreate --metadatacopies $i $vg $dev1
+    check_pv_field_ $dev1 pv_mda_count $i
+    vgremove -f $vg
+    pvremove -f $dev1
+done
+not vgcreate --metadatacopies 0 $vg $dev1
+pvcreate --metadatacopies 1 $dev2
+vgcreate --metadatacopies 0 $vg $dev1 $dev2
+check_pv_field_ $dev1 pv_mda_count 0
+check_pv_field_ $dev2 pv_mda_count 1
+vgremove -f $vg
+pvremove -f $dev1
+
+# metadatasize, dataalignment, dataalignmentoffset
+#COMM 'pvcreate sets data offset next to mda area'
+vgcreate --metadatasize 100k --dataalignment 100k $vg $dev1
+check_pv_field_ $dev1 pe_start 200.00k
+vgremove -f $vg
+pvremove -f $dev1
+
+# data area is aligned to 64k by default,
+# data area start is shifted by the specified alignment_offset
+pv_align="195.50k"
+vgcreate --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
+check_pv_field_ $dev1 pe_start $pv_align
+vgremove -f $vg
+pvremove -f $dev1
+
+# metadatatype
+for i in 1 2
+do
+    vgcreate -M $i $vg $dev1
+    check_vg_field_ $vg vg_fmt lvm$i
+    vgremove -f $vg
+    pvremove -f $dev1
+done


