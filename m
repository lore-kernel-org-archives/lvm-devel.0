From: Milan Broz <mbroz@redhat.com>
Date: Sun, 31 May 2009 22:43:45 +0200
Subject: [PATCH v2] Fix readahead calculation segfault.
In-Reply-To: <4A1F9E59.3010905@redhat.com>
References: <4A1F9E59.3010905@redhat.com>
Message-ID: <4A22EC01.2010403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix readahead calculation problems.

During vgreduce is failed mirror image replaced with error segment,
this segmant type has always area_count == 0.
Current code expects that there is at least one area with device,
patch fixes it by additional check (fixes segfault during vgreduce).

Also do not calculate readahead in every lv_info call, we only need
to cache PV readahead before activation calls which locks memory.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW                  |    2 ++
 lib/activate/activate.c    |   11 ++++++-----
 lib/activate/dev_manager.c |    2 +-
 lib/metadata/metadata.c    |   19 +++++++++++++------
 lib/metadata/metadata.h    |    2 +-
 5 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c0840ca..4370530 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.48 - 
 ===============================
+  Cache underlying device readahead only before activation calls.
+  Fix segfault when calculating readahead on missing device in vgreduce.
   Remove verbose 'visited' messages.
   Handle multi-extent mirror log allocation when smallest PV has only 1 extent.
   Add LSB standard headers and functions (incl. reload) to clvmd initscript.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 12e8b20..aa75e5b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -469,11 +469,6 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv, in
 	info->live_table = dminfo.live_table;
 	info->inactive_table = dminfo.inactive_table;
 
-	/*
-	 * Cache read ahead value for PV devices now (before possible suspend)
-	 */
-	(void)lv_calculate_readhead(lv);
-
 	if (name)
 		dm_pool_free(cmd->mem, name);
 
@@ -879,6 +874,8 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	lv_calculate_readahead(lv, NULL);
+
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
 		if (!_lv_preload(lv_pre, &flush_required)) {
@@ -1010,6 +1007,8 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 		goto out;
 	}
 
+	lv_calculate_readahead(lv, NULL);
+
 	if (!monitor_dev_for_events(cmd, lv, 0))
 		stack;
 
@@ -1093,6 +1092,8 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	lv_calculate_readahead(lv, NULL);
+
 	if (exclusive)
 		lv->status |= ACTIVATE_EXCL;
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5a932a6..ab61817 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1023,7 +1023,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* we need RA at least twice a whole stripe - see the comment in md/raid0.c */
 		read_ahead = max_stripe_size * 2;
 		if (!read_ahead)
-			read_ahead = lv_calculate_readhead(lv);
+			lv_calculate_readahead(lv, &read_ahead);
 		read_ahead_flags = DM_READ_AHEAD_MINIMUM_FLAG;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2b93bfb..1ee8e5d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1422,7 +1422,7 @@ static int _lv_read_ahead_single(struct logical_volume *lv, void *data)
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t seg_read_ahead = 0, *read_ahead = data;
 
-	if (seg && seg_type(seg, 0) == AREA_PV)
+	if (seg && seg->area_count && seg_type(seg, 0) == AREA_PV)
 		dev_get_read_ahead(seg_pv(seg, 0)->dev, &seg_read_ahead);
 
 	if (seg_read_ahead > *read_ahead)
@@ -1431,15 +1431,22 @@ static int _lv_read_ahead_single(struct logical_volume *lv, void *data)
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
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 380e639..ceb089c 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -347,7 +347,7 @@ unsigned snapshot_count(const struct volume_group *vg);
 /*
  * Calculate readahead from underlying PV devices
  */
-uint32_t lv_calculate_readhead(const struct logical_volume *lv);
+void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahead);
 
 /*
  * For internal metadata caching.



