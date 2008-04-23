From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Apr 2008 14:33:06 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20080423143306.7289.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-23 14:33:06

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit internal counting of snapshot LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.859&r2=1.860
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/WHATS_NEW	2008/04/23 12:53:10	1.859
+++ LVM2/WHATS_NEW	2008/04/23 14:33:05	1.860
@@ -1,5 +1,6 @@
 Version 2.02.36 - 
 =================================
+  Fix vgsplit internal counting of snapshot LVs.
   Fix internal snapshot_count when vgmerge with snapshots in source VG.
   Simply clvmd-openais by using non-async saLckResourceLock.
   Check lv_count in vg_validate.
--- LVM2/lib/metadata/metadata-exported.h	2008/04/10 17:09:31	1.47
+++ LVM2/lib/metadata/metadata-exported.h	2008/04/23 14:33:05	1.48
@@ -202,7 +202,23 @@
 	uint32_t pv_count;
 	struct list pvs;
 
-	/* logical volumes */
+	/*
+	 * logical volumes
+	 * The following relationship should always hold:
+	 * list_size(lvs) = lv_count + 2 * snapshot_count
+	 *
+	 * Snapshots consist of 2 instances of "struct logical_volume":
+	 * - cow (lv_name is visible to the user)
+	 * - snapshot (lv_name is 'snapshotN')
+	 * Neither of these instances is reflected in lv_count, but we
+	 * multiply the snapshot_count by 2.
+	 *
+	 * Mirrors consist of multiple instances of "struct logical_volume":
+	 * - one for the mirror log
+	 * - one for each mirror leg
+	 * - one for the user-visible mirror LV
+	 * all of the instances are reflected in lv_count.
+	 */
 	uint32_t lv_count;
 	uint32_t snapshot_count;
 	struct list lvs;
--- LVM2/tools/vgsplit.c	2008/04/15 14:57:12	1.66
+++ LVM2/tools/vgsplit.c	2008/04/23 14:33:06	1.67
@@ -109,7 +109,7 @@
 	if (lv->status & SNAPSHOT) {
 		vg_from->snapshot_count--;
 		vg_to->snapshot_count++;
-	} else {
+	} else if (!lv_is_cow(lv)) {
 		vg_from->lv_count--;
 		vg_to->lv_count++;
 	}


