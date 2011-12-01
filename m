From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Dec 2011 00:09:38 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20111201000938.24032.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-12-01 00:09:35

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h raid_manip.c 
	tools          : lvrename.c 

Log message:
	Do not allow users to change the name of RAID sub-LVs or the name of the
	RAID LV if it is tracking changes for a split image.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2200&r2=1.2201
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.224&r2=1.225
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2011/12/01 00:05:40	1.2200
+++ LVM2/WHATS_NEW	2011/12/01 00:09:34	1.2201
@@ -1,5 +1,7 @@
 Version 2.02.89 - 
 ==================================
+  Don't allow name change of RAID LV while tracking a split image.
+  Do not allow users to change the name of RAID sub-LVs
   Do not allow users to change permissions on RAID sub-LVs
   Support the ability to replace specific devices in a RAID array via lvconvert.
   Add activation/use_linear_target enabled by default.
--- LVM2/lib/metadata/metadata-exported.h	2011/11/30 02:20:13	1.224
+++ LVM2/lib/metadata/metadata-exported.h	2011/12/01 00:09:35	1.225
@@ -780,6 +780,7 @@
 /* --  metadata/replicator_manip.c */
 
 /* ++  metadata/raid_manip.c */
+int lv_is_raid_with_tracking(const struct logical_volume *lv);
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,
 			       uint32_t new_count, struct dm_list *pvs);
--- LVM2/lib/metadata/raid_manip.c	2011/11/30 02:02:11	1.18
+++ LVM2/lib/metadata/raid_manip.c	2011/12/01 00:09:35	1.19
@@ -26,6 +26,22 @@
 
 #define RAID_REGION_SIZE 1024
 
+int lv_is_raid_with_tracking(const struct logical_volume *lv)
+{
+	uint32_t s;
+	struct lv_segment *seg;
+
+	if (lv->status & RAID) {
+		seg = first_seg(lv);
+
+		for (s = 0; s < seg->area_count; s++)
+			if (lv_is_visible(seg_lv(seg, s)) &&
+			    !(seg_lv(seg, s)->status & LVM_WRITE))
+				return 1;
+	}
+	return 0;
+}
+
 uint32_t lv_raid_image_count(const struct logical_volume *lv)
 {
 	struct lv_segment *seg = first_seg(lv);
--- LVM2/tools/lvrename.c	2011/08/10 20:25:31	1.58
+++ LVM2/tools/lvrename.c	2011/12/01 00:09:35	1.59
@@ -115,6 +115,21 @@
 		goto error;
 	}
 
+	if (lvl->lv->status & (RAID_IMAGE | RAID_META)) {
+		log_error("Cannot rename a RAID %s directly",
+			  (lvl->lv->status & RAID_IMAGE) ? "image" :
+			  "metadata area");
+		r = ECMD_FAILED;
+		goto error;
+	}
+
+	if (lv_is_raid_with_tracking(lvl->lv)) {
+		log_error("Cannot rename %s while it is tracking a split image",
+			  lvl->lv->name);
+		r = ECMD_FAILED;
+		goto error;
+	}
+
 	if (!lv_rename(cmd, lvl->lv, lv_name_new))
 		goto error;
 


