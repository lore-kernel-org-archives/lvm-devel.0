From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:36:06 -0000
Subject: LVM2/test t-metadata-balance.sh
Message-ID: <20100628203606.17215.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:36:06

Added files:
	test           : t-metadata-balance.sh 

Log message:
	Add tests for phase 1 of metadata balance - manage per-PV ignore bit.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata-balance.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-metadata-balance.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-metadata-balance.sh
+++ -	2010-06-28 20:36:06.438697000 +0000
@@ -0,0 +1,41 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+aux prepare_devs 5
+
+#  Make sure we can ignore / un-ignore mdas on a per-PV basis
+for pv_in_vg in 1 0; do
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2
+        pvcreate --metadatacopies 0 $dev3
+	if [ $pv_in_vg = 1 ]; then
+		vgcreate -c n "$vg" $dev1 $dev2 $dev3
+	fi
+	pvchange --metadataignore y $dev1
+	check_pv_field_ $dev1 pv_mda_count $mdacp
+	check_pv_field_ $dev1 pv_mda_used_count 0
+	check_pv_field_ $dev2 pv_mda_count $mdacp
+	check_pv_field_ $dev2 pv_mda_used_count $mdacp
+	if [ $pv_in_vg = 1 ]; then
+		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
+		check_vg_field_ $vg vg_mda_used_count $mdacp
+	fi
+	pvchange --metadataignore n $dev1
+	check_pv_field_ $dev1 pv_mda_count $mdacp
+	check_pv_field_ $dev1 pv_mda_used_count $mdacp
+	if [ $pv_in_vg = 1 ]; then
+		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
+		check_vg_field_ $vg vg_mda_used_count $(($mdacp * 2))
+		vgremove -f $vg
+	fi
+done
+done


