From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 13:05:00 -0000
Subject: LVM2/test t-vgextend-usage.sh
Message-ID: <20100630130500.14565.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 13:04:59

Modified files:
	test           : t-vgextend-usage.sh 

Log message:
	Update nightly tests for vgextend --metadataignore.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-vgextend-usage.sh	2009/10/31 16:43:07	1.3
+++ LVM2/test/t-vgextend-usage.sh	2010/06/30 13:04:59	1.4
@@ -99,3 +99,31 @@
 check_pv_field_ $dev3 vg_name $vg1
 vgremove -f $vg1
 pvremove -f $dev1 $dev2 $dev3
+
+echo test vgextend --metadataignore
+for mdacp in 1 2; do
+for ignore in y n; do
+	echo vgextend --metadataignore has proper mda_count and mda_used_count
+	vgcreate $vg $dev3
+	vgextend --metadataignore $ignore --pvmetadatacopies $mdacp $vg $dev1 $dev2
+	check_pv_field_ $dev1 pv_mda_count $mdacp
+	check_pv_field_ $dev2 pv_mda_count $mdacp
+	if [ $ignore = y ]; then
+		check_pv_field_ $dev1 pv_mda_used_count 0
+		check_pv_field_ $dev2 pv_mda_used_count 0
+	else
+		check_pv_field_ $dev1 pv_mda_used_count $mdacp
+		check_pv_field_ $dev2 pv_mda_used_count $mdacp
+	fi
+	echo vg has proper vg_mda_count and vg_mda_used_count
+	check_vg_field_ $vg vg_mda_count $(($mdacp * 2 + 1))
+	if [ $ignore = y ]; then
+		check_vg_field_ $vg vg_mda_used_count 1
+	else
+		check_vg_field_ $vg vg_mda_used_count $(($mdacp * 2 + 1))
+	fi
+	check_vg_field_ $vg vg_mda_copies unmanaged
+	vgremove $vg
+	pvremove -ff $dev1 $dev2 $dev3
+done
+done


