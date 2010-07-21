From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jul 2010 19:44:28 -0000
Subject: LVM2 lib/report/columns.h ./WHATS_NEW
Message-ID: <20100721194428.6019.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-21 19:44:25

Modified files:
	lib/report     : columns.h 
	.              : WHATS_NEW 

Log message:
	Clarify help text for vg_mda_count.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1669&r2=1.1670

--- LVM2/lib/report/columns.h	2010/06/28 20:37:23	1.41
+++ LVM2/lib/report/columns.h	2010/07/21 19:44:25	1.42
@@ -112,7 +112,7 @@
 FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, "snap_count", "Number of snapshots.")
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
-FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas in use by this VG.")
+FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas on this VG.")
 FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, "vg_mda_used_count", "Number of metadata areas in use on this VG.")
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.")
--- LVM2/WHATS_NEW	2010/07/21 13:40:21	1.1669
+++ LVM2/WHATS_NEW	2010/07/21 19:44:25	1.1670
@@ -1,8 +1,10 @@
 Version 2.02.71 -
 ===============================
+  Clarify help text for vg_mda_count.
   Check if cluster log daemon is running before allowing cmirror create.
   Check if LV with specified name already exists when splitting a mirror.
   Fix suspend/resume logic for LVs resulting from splitting a mirror.
+  Update pvcreate, {pv|vg}change, and lvm.conf man pages about metadataignore.
   Switch cmirrord and clvmd to use dm_create_lockfile.
   Allow clvmd pidfile to be configurable.
   Update comments about memory handling in lvm2app.h.


