From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 1 Jun 2009 12:43:33 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20090601124333.11757.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-01 12:43:32

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c dev_manager.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Fix readahead calculation problems.
	
	During vgreduce is failed mirror image replaced with error segment,
	this segmant type has always area_count == 0.
	Current code expects that there is at least one area with device,
	patch fixes it by additional check (fixes segfault during vgreduce).
	
	Also do not calculate readahead in every lv_info call, we only need
	to cache PV readahead before activation calls which locks memory.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1135&r2=1.1136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.223&r2=1.224
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.195&r2=1.196

--- LVM2/WHATS_NEW	2009/05/30 01:54:29	1.1135
+++ LVM2/WHATS_NEW	2009/06/01 12:43:31	1.1136
@@ -1,5 +1,7 @@
 Version 2.02.48 - 
 ===============================
+  Cache underlying device readahead only before activation calls.
+  Fix segfault when calculating readahead on missing device in vgreduce.
   Remove verbose 'visited' messages.
   Handle multi-extent mirror log allocation when smallest PV has only 1 extent.
   Add LSB standard headers and functions (incl. reload) to clvmd initscript.
--- LVM2/lib/activate/activate.c	2009/05/21 03:04:52	1.152
+++ LVM2/lib/activate/activate.c	2009/06/01 12:43:32	1.153
@@ -469,11 +469,6 @@
 	info->live_table = dminfo.live_table;
 	info->inactive_table = dminfo.inactive_table;
 
-	/*
-	 * Cache read ahead value for PV devices now (before possible suspend)
-	 */
-	(void)lv_calculate_readhead(lv);
-
 	if (name)
 		dm_pool_free(cmd->mem, name);
 
@@ -879,6 +874,8 @@
 		goto out;
 	}
 
+	lv_calculate_readahead(lv, NULL);
+
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
 		if (!_lv_preload(lv_pre, &flush_required)) {
@@ -1010,6 +1007,8 @@
 		goto out;
 	}
 
+	lv_calculate_readahead(lv, NULL);
+
 	if (!monitor_dev_for_events(cmd, lv, 0))
 		stack;
 
@@ -1093,6 +1092,8 @@
 		goto out;
 	}
 
+	lv_calculate_readahead(lv, NULL);
+
 	if (exclusive)
 		lv->status |= ACTIVATE_EXCL;
 
--- LVM2/lib/activate/dev_manager.c	2009/05/28 01:11:30	1.151
+++ LVM2/lib/activate/dev_manager.c	2009/06/01 12:43:32	1.152
@@ -1023,7 +1023,7 @@
 		/* we need RA at least twice a whole stripe - see the comment in md/raid0.c */
 		read_ahead = max_stripe_size * 2;
 		if (!read_ahead)
-			read_ahead = lv_calculate_readhead(lv);
+			lv_calculate_readahead(lv, &read_ahead);
 		read_ahead_flags = DM_READ_AHEAD_MINIMUM_FLAG;
 	}
 
--- LVM2/lib/metadata/metadata.c	2009/05/30 01:54:29	1.223
+++ LVM2/lib/metadata/metadata.c	2009/06/01 12:43:32	1.224
@@ -1422,7 +1422,7 @@
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t seg_read_ahead = 0, *read_ahead = data;
 
-	if (seg && seg_type(seg, 0) == AREA_PV)
+	if (seg && seg->area_count && seg_type(seg, 0) == AREA_PV)
 		dev_get_read_ahead(seg_pv(seg, 0)->dev, &seg_read_ahead);
 
 	if (seg_read_ahead > *read_ahead)
@@ -1431,15 +1431,22 @@
 	return 1;
 }
 
-uint32_t lv_calculate_readhead(const struct logical_volume *lv)
+/*
+ * Calculate readahead for logical volume from underlying PV devices.
+ * If read_ahead is NULL, only ensure that readahead of PVs are preloaded
+ * into PV struct device in dev cache.
+ */
+void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahead)
 {
-	uint32_t read_ahead = 0;
+	uint32_t _read_ahead = 0;
 
 	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
-		_lv_postorder((struct logical_volume *)lv, _lv_read_ahead_single, &read_ahead);
+		_lv_postorder((struct logical_volume *)lv, _lv_read_ahead_single, &_read_ahead);
 
-	log_debug("Calculated readahead of LV %s is %u", lv->name, read_ahead);
-	return read_ahead;
+	if (read_ahead) {
+		log_debug("Calculated readahead of LV %s is %u", lv->name, _read_ahead);
+		*read_ahead = _read_ahead;
+	}
 }
 
 int vg_validate(struct volume_group *vg)
--- LVM2/lib/metadata/metadata.h	2009/05/20 11:09:49	1.195
+++ LVM2/lib/metadata/metadata.h	2009/06/01 12:43:32	1.196
@@ -347,7 +347,7 @@
 /*
  * Calculate readahead from underlying PV devices
  */
-uint32_t lv_calculate_readhead(const struct logical_volume *lv);
+void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahead);
 
 /*
  * For internal metadata caching.


