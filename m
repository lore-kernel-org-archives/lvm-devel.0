From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Jul 2010 14:43:59 -0000
Subject: LVM2/test t-inconsistent-metadata.sh
Message-ID: <20100707144359.23408.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-07 14:43:58

Modified files:
	test           : t-inconsistent-metadata.sh 

Log message:
	Test failed commit of mda on new pv - failed vgextend.
	
	Test the auto-repair capability when we fail committing to an mda
	on a new pv adding to a vg.  This test should fail until we fix
	the auto-repair in this case.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-inconsistent-metadata.sh	2009/07/01 17:06:04	1.3
+++ LVM2/test/t-inconsistent-metadata.sh	2010/07/07 14:43:57	1.4
@@ -63,3 +63,13 @@
 vgs 2>&1 | tee cmd.out
 not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
+
+echo Check auto-repair of failed vgextend - metadata written to original pv but not new pv
+vgremove -f $vg
+pvremove -ff $devs
+pvcreate $devs
+backup_dev $dev2
+vgcreate $vg $dev1
+vgextend $vg $dev2
+restore_dev $dev2
+should compare_two_fields_ vgs $vg vg_mda_count pvs $dev2 vg_mda_count


