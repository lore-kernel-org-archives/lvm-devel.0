From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 16 Aug 2010 23:21:20 -0000
Subject: LVM2/test t-metadata.sh
Message-ID: <20100816232120.25384.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-08-16 23:21:20

Modified files:
	test           : t-metadata.sh 

Log message:
	Add some v1 to v2 metadata upgrade testing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-metadata.sh	2009/12/28 18:33:04	1.4
+++ LVM2/test/t-metadata.sh	2010/08/16 23:21:20	1.5
@@ -51,5 +51,32 @@
 pvcreate -M1 $dev1
 pvcreate -M1 $dev2
 pvcreate -M1 $dev3
+pv3_uuid=$(pvs --noheadings -o pv_uuid $dev3)
 vgcreate -M1 -c n $vg $dev1 $dev2 $dev3
 pvchange --uuid $dev1
+
+# verify pe_start of all M1 PVs
+pv_align="128.00k"
+check_pv_field_ $dev1 pe_start $pv_align
+check_pv_field_ $dev2 pe_start $pv_align
+check_pv_field_ $dev3 pe_start $pv_align
+
+pvs --units k -o name,pe_start,vg_mda_size,vg_name
+
+# upgrade from v1 to v2 metadata
+vgconvert -M2 $vg
+
+# verify pe_start of all M2 PVs
+check_pv_field_ $dev1 pe_start $pv_align
+check_pv_field_ $dev2 pe_start $pv_align
+check_pv_field_ $dev3 pe_start $pv_align
+
+pvs --units k -o name,pe_start,vg_mda_size,vg_name
+
+# create backup and then restore $dev3
+vgcfgbackup -f $TESTDIR/bak-%s $vg
+pvcreate -ff -y --restorefile $TESTDIR/bak-$vg --uuid $pv3_uuid $dev3
+vgcfgrestore -f $TESTDIR/bak-$vg $vg
+
+# verify pe_start of $dev3
+check_pv_field_ $dev3 pe_start $pv_align


