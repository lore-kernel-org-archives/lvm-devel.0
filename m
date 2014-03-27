From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 12:15:19 +0000 (UTC)
Subject: master - lv_manip: drop cmd pointer from for_each_sub_lv
Message-ID: <20140327121519.AFDD16196E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=356fdda46d673015446e8a0410e9dfe7fa67c66e
Commit:        356fdda46d673015446e8a0410e9dfe7fa67c66e
Parent:        22579b4451b00b50ad7e6acacf9265fa41620449
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 27 10:35:07 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 27 13:10:13 2014 +0100

lv_manip: drop cmd pointer from for_each_sub_lv

Drop unused passed cmd pointer from function.

TODO:

We have two similar functions (though not identical)

lv_manip.c: for_each_sub_lv()
metadata.c: _lv_each_dependency()

They seem to not always match - we should probably convert
to use only a single function.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    4 +-
 lib/metadata/lv_manip.c |   51 +++++++++++++++++++++-------------------------
 lib/metadata/metadata.h |    5 +--
 4 files changed, 28 insertions(+), 33 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 71b074a..9cda1d5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Drop unused cmd pointer for internal function for_each_sub_lv().
   Validate name for renamed sub LVs.
   When lvrename fails on argument parsing return invalid cmd line error (5->3).
   Fix exit code regression in failing pvchange command (2.02.66).
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ff13fe4..2fd1840 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1795,7 +1795,7 @@ struct detached_lv_data {
 	int *flush_required;
 };
 
-static int _preload_detached_lv(struct cmd_context *cmd, struct logical_volume *lv, void *data)
+static int _preload_detached_lv(struct logical_volume *lv, void *data)
 {
 	struct detached_lv_data *detached = data;
 	struct lv_list *lvl_pre;
@@ -1897,7 +1897,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		detached.laopts = laopts;
 		detached.flush_required = &flush_required;
 
-		if (!for_each_sub_lv(cmd, ondisk_lv, &_preload_detached_lv, &detached))
+		if (!for_each_sub_lv(ondisk_lv, &_preload_detached_lv, &detached))
 			goto_out;
 
 		/*
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ae0bef2..e5ab4f7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -78,8 +78,7 @@ struct pv_and_int {
 	struct physical_volume *pv;
 	int *i;
 };
-static int _lv_is_on_pv(struct cmd_context *cmd,
-			struct logical_volume *lv, void *data)
+static int _lv_is_on_pv(struct logical_volume *lv, void *data)
 {
 	int *is_on_pv = ((struct pv_and_int *)data)->i;
 	struct physical_volume *pv = ((struct pv_and_int *)data)->pv;
@@ -136,8 +135,8 @@ int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
 	int is_on_pv = 0;
 	struct pv_and_int context = { pv, &is_on_pv };
 
-	if (!_lv_is_on_pv(lv->vg->cmd, lv, &context) ||
-	    !for_each_sub_lv(lv->vg->cmd, lv, _lv_is_on_pv, &context))
+	if (!_lv_is_on_pv(lv, &context) ||
+	    !for_each_sub_lv(lv, _lv_is_on_pv, &context))
 		/* Failure only happens if bad arguments are passed */
 		log_error(INTERNAL_ERROR "for_each_sub_lv failure.");
 
@@ -169,8 +168,7 @@ struct dm_list_and_mempool {
 	struct dm_list *list;
 	struct dm_pool *mem;
 };
-static int _get_pv_list_for_lv(struct cmd_context *cmd,
-			       struct logical_volume *lv, void *data)
+static int _get_pv_list_for_lv(struct logical_volume *lv, void *data)
 {
 	int dup_found;
 	uint32_t s;
@@ -233,10 +231,10 @@ int get_pv_list_for_lv(struct dm_pool *mem,
 	log_debug_metadata("Generating list of PVs that %s/%s uses:",
 			   lv->vg->name, lv->name);
 
-	if (!_get_pv_list_for_lv(lv->vg->cmd, lv, &context))
+	if (!_get_pv_list_for_lv(lv, &context))
 		return_0;
 
-	return for_each_sub_lv(lv->vg->cmd, lv, &_get_pv_list_for_lv, &context);
+	return for_each_sub_lv(lv, &_get_pv_list_for_lv, &context);
 }
 
 /*
@@ -3197,8 +3195,7 @@ static int _rename_single_lv(struct logical_volume *lv, char *new_name)
  * Rename sub LV.
  * 'lv_name_old' and 'lv_name_new' are old and new names of the main LV.
  */
-static int _rename_sub_lv(struct cmd_context *cmd,
-			  struct logical_volume *lv,
+static int _rename_sub_lv(struct logical_volume *lv,
 			  const char *lv_name_old, const char *lv_name_new)
 {
 	const char *suffix;
@@ -3246,21 +3243,19 @@ static int _rename_sub_lv(struct cmd_context *cmd,
 }
 
 /* Callback for for_each_sub_lv */
-static int _rename_cb(struct cmd_context *cmd, struct logical_volume *lv,
-		      void *data)
+static int _rename_cb(struct logical_volume *lv, void *data)
 {
 	struct lv_names *lv_names = (struct lv_names *) data;
 
-	return _rename_sub_lv(cmd, lv, lv_names->old, lv_names->new);
+	return _rename_sub_lv(lv, lv_names->old, lv_names->new);
 }
 
 /*
  * Loop down sub LVs and call fn for each.
  * fn is responsible to log necessary information on failure.
  */
-int for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
-		    int (*fn)(struct cmd_context *cmd,
-			      struct logical_volume *lv, void *data),
+int for_each_sub_lv(struct logical_volume *lv,
+		    int (*fn)(struct logical_volume *lv, void *data),
 		    void *data)
 {
 	struct logical_volume *org;
@@ -3268,33 +3263,33 @@ int for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	uint32_t s;
 
 	if (lv_is_cow(lv) && lv_is_virtual_origin(org = origin_from_cow(lv))) {
-		if (!fn(cmd, org, data))
+		if (!fn(org, data))
 			return_0;
-		if (!for_each_sub_lv(cmd, org, fn, data))
+		if (!for_each_sub_lv(org, fn, data))
 			return_0;
 	}
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		if (seg->log_lv) {
-			if (!fn(cmd, seg->log_lv, data))
+			if (!fn(seg->log_lv, data))
 				return_0;
-			if (!for_each_sub_lv(cmd, seg->log_lv, fn, data))
+			if (!for_each_sub_lv(seg->log_lv, fn, data))
 				return_0;
 		}
 
 		if (seg->metadata_lv) {
-			if (!fn(cmd, seg->metadata_lv, data))
+			if (!fn(seg->metadata_lv, data))
 				return_0;
-			if (!for_each_sub_lv(cmd, seg->metadata_lv, fn, data))
+			if (!for_each_sub_lv(seg->metadata_lv, fn, data))
 				return_0;
 		}
 
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
-			if (!fn(cmd, seg_lv(seg, s), data))
+			if (!fn(seg_lv(seg, s), data))
 				return_0;
-			if (!for_each_sub_lv(cmd, seg_lv(seg, s), fn, data))
+			if (!for_each_sub_lv(seg_lv(seg, s), fn, data))
 				return_0;
 		}
 
@@ -3305,9 +3300,9 @@ int for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_metatype(seg, s) != AREA_LV)
 				continue;
-			if (!fn(cmd, seg_metalv(seg, s), data))
+			if (!fn(seg_metalv(seg, s), data))
 				return_0;
-			if (!for_each_sub_lv(cmd, seg_metalv(seg, s), fn, data))
+			if (!for_each_sub_lv(seg_metalv(seg, s), fn, data))
 				return_0;
 		}
 	}
@@ -3352,7 +3347,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	/* rename sub LVs */
 	lv_names.old = lv->name;
 	lv_names.new = new_name;
-	if (!for_each_sub_lv(cmd, lv, _rename_cb, (void *) &lv_names))
+	if (!for_each_sub_lv(lv, _rename_cb, (void *) &lv_names))
 		return 0;
 
 	/* rename main LV */
@@ -5366,7 +5361,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	if (strcmp(layer_suffix, "_tdata") == 0) {
 		lv_names.old = lv_where->name;
 		lv_names.new = layer_lv->name;
-		if (!for_each_sub_lv(cmd, layer_lv, _rename_cb, (void *) &lv_names))
+		if (!for_each_sub_lv(layer_lv, _rename_cb, (void *) &lv_names))
 			return 0;
 	}
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 83959bb..ed78cb6 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -429,9 +429,8 @@ int add_seg_to_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *
 int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
 struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 
-int for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
-                    int (*fn)(struct cmd_context *cmd,
-                              struct logical_volume *lv, void *data),
+int for_each_sub_lv(struct logical_volume *lv,
+                    int (*fn)(struct logical_volume *lv, void *data),
                     void *data);
 int move_lv_segments(struct logical_volume *lv_to,
 		     struct logical_volume *lv_from,


