From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 12:17:57 -0000
Subject: LVM2/test t-pvcreate-usage.sh
Message-ID: <20100630121757.18716.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 12:17:56

Modified files:
	test           : t-pvcreate-usage.sh 

Log message:
	Update pvcreate tests for --metadataignore.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/test/t-pvcreate-usage.sh	2009/10/05 20:55:57	1.14
+++ LVM2/test/t-pvcreate-usage.sh	2010/06/30 12:17:55	1.15
@@ -158,3 +158,34 @@
 check_pv_field_ $dev1 pe_start 0
 check_pv_field_ $dev2 pe_start 0
 vgremove $vg
+
+echo test pvcreate --metadataignore
+for pv_in_vg in 1 0; do
+for mdacp in 1 2; do
+for ignore in y n; do
+	echo pvcreate --metadataignore has proper mda_count and mda_used_count
+	pvcreate --metadatacopies $mdacp --metadataignore $ignore $dev1 $dev2
+	check_pv_field_ $dev1 pv_mda_count $mdacp
+	check_pv_field_ $dev2 pv_mda_count $mdacp
+	if [ $ignore = y ]; then
+		check_pv_field_ $dev1 pv_mda_used_count 0
+		check_pv_field_ $dev2 pv_mda_used_count 0
+	else
+		check_pv_field_ $dev1 pv_mda_used_count $mdacp
+		check_pv_field_ $dev2 pv_mda_used_count $mdacp
+	fi
+	echo vgcreate has proper vg_mda_count and vg_mda_used_count
+	if [ $pv_in_vg = 1 ]; then
+		vgcreate -c n "$vg" $dev1 $dev2
+		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
+		if [ $ignore = y ]; then
+			check_vg_field_ $vg vg_mda_used_count 1
+		else
+			check_vg_field_ $vg vg_mda_used_count $(($mdacp * 2))
+		fi
+		check_vg_field_ $vg vg_mda_copies unmanaged
+		vgremove $vg
+	fi
+done
+done
+done


