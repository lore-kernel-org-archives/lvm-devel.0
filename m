From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Mar 2009 13:16:37 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archiver.c te ...
Message-ID: <20090324131637.11119.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-03-24 13:16:35

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archiver.c 
	test           : t-covercmd.sh 

Log message:
	Fix segfault for vgcfgrestore on VG with missing PVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1072&r2=1.1073
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2009/03/24 11:49:15	1.1072
+++ LVM2/WHATS_NEW	2009/03/24 13:16:34	1.1073
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix segfault for vgcfgrestore on VG with missing PVs.
   Block SIGTERM & SIGINT in clvmd subthreads.
   Detect and conditionally wipe swapspace signatures in pvcreate.
   Fix maximal volume count check for snapshots if max_lv set for volume group.
--- LVM2/lib/format_text/archiver.c	2009/03/23 22:57:27	1.20
+++ LVM2/lib/format_text/archiver.c	2009/03/24 13:16:35	1.21
@@ -333,6 +333,12 @@
 	if (!(vg = backup_read_vg(cmd, vg_name, file)))
 		return_0;
 
+	/*
+	 * If PV is missing, there is already message from read above
+	 */
+	if (vg_missing_pv_count(vg))
+		return_0;
+
 	return backup_restore_vg(cmd, vg);
 }
 
--- LVM2/test/t-covercmd.sh	2008/10/06 16:47:07	1.5
+++ LVM2/test/t-covercmd.sh	2009/03/24 13:16:35	1.6
@@ -14,6 +14,8 @@
 
 . ./test-utils.sh
 
+TEST_UUID="aaaaaa-aaaa-aaaa-aaaa-aaaa-aaaa-aaaaaa"
+
 get_lvs_()
 {
   case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
@@ -28,7 +30,7 @@
 pvcreate --metadatacopies 0 $dev2
 pvcreate --metadatacopies 0 $dev3
 pvcreate $dev4
-pvcreate --metadatacopies 0 $dev5
+pvcreate -u $TEST_UUID --metadatacopies 0 $dev5
 vgcreate -c n $vg $devs
 lvcreate -n $lv -l 5 -i5 -I256 $vg
 
@@ -67,6 +69,9 @@
 vgcfgbackup -f "$(pwd)/backup.$$" "$vg"
 vgchange -an "$vg"
 vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"
+pvremove -y -ff $dev5
+not vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"
+pvcreate -u $TEST_UUID --restorefile  "$(pwd)/backup.$$" $dev5
 vgremove -f "$vg"
 pvresize --setphysicalvolumesize 10M "$dev1"
 


