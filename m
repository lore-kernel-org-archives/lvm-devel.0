From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Sep 2011 15:17:56 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv.c
Message-ID: <20110923151756.19057.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-23 15:17:54

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv.c 

Log message:
	Add 'Volume Type' lv_attr characters for RAID and RAID_IMAGE.
	
	RAID_META is already handled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2132&r2=1.2133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2011/09/22 17:39:56	1.2132
+++ LVM2/WHATS_NEW	2011/09/23 15:17:54	1.2133
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add 'Volume Type' lv_attr characters for RAID and RAID_IMAGE.
   Add activation/retry_deactivation to lvm.conf to retry deactivation of an LV.
   Replace open_count check with holders/mounted_fs check on lvremove path.
   Disallow the creation of mirrors (mirror or raid1 segtype) with only one leg.
--- LVM2/lib/metadata/lv.c	2011/09/14 10:03:15	1.28
+++ LVM2/lib/metadata/lv.c	2011/09/23 15:17:54	1.29
@@ -304,6 +304,48 @@
 	return (percent == PERCENT_100) ? 1 : 0;
 }
 
+static int _lv_raid_image_in_sync(const struct logical_volume *lv)
+{
+	percent_t percent;
+	struct lv_segment *raid_seg;
+
+	if (!(lv->status & RAID_IMAGE)) {
+		log_error(INTERNAL_ERROR "%s is not a RAID image", lv->name);
+		return 0;
+	}
+
+	raid_seg = get_only_segment_using_this_lv(first_seg(lv)->lv);
+	if (!raid_seg) {
+		log_error("Failed to find RAID segment for %s", lv->name);
+		return 0;
+	}
+
+	if (!seg_is_raid(raid_seg)) {
+		log_error("%s on %s is not a RAID segment",
+			  raid_seg->lv->name, lv->name);
+		return 0;
+	}
+
+	if (!lv_raid_percent(raid_seg->lv, &percent))
+		return_0;
+
+	if (percent == PERCENT_100)
+		return 1;
+
+	/*
+	 * FIXME:  Get individual RAID image status.
+	 * The status health characters reported from a RAID target
+	 * indicate whether the whole array or just individual devices
+	 * are in-sync.  If the corresponding character for this image
+	 * was 'A', we could report a more accurate status.  This is
+	 * especially so in the case of failures or rebuildings.
+	 *
+	 * We need to test the health characters anyway to report
+	 * the correct 4th attr character.  Just need to figure out
+	 * where to put this functionality.
+	 */
+	return 0;
+}
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	percent_t snap_percent;
@@ -327,6 +369,8 @@
 	/* Origin takes precedence over mirror and thin volume */
 	else if (lv_is_origin(lv))
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
+	else if (lv->status & RAID)
+		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'R' : 'r';
 	else if (lv->status & MIRRORED)
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'M' : 'm';
 	else if (lv_is_thin_volume(lv))
@@ -341,6 +385,8 @@
 		repstr[0] = 'e';
 	else if (lv->status & MIRROR_IMAGE)
 		repstr[0] = (_lv_mimage_in_sync(lv)) ? 'i' : 'I';
+	else if (lv->status & RAID_IMAGE)
+		repstr[0] = (_lv_raid_image_in_sync(lv)) ? 'i' : 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
 	else if (lv_is_cow(lv)) {


