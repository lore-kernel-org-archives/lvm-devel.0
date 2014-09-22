From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:58 +0000 (UTC)
Subject: dev-dct-process-latest - lvconvert: Further restrictions on cache/pools.
Message-ID: <20140922153858.4717561087@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab2dacf6f6aa18328a848238e45aeaac2ed0d064
Commit:        ab2dacf6f6aa18328a848238e45aeaac2ed0d064
Parent:        a2a869afc8f55409fca0f2079facaf57f2539f24
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 17 23:00:41 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 17 23:00:41 2014 +0100

lvconvert: Further restrictions on cache/pools.

Would be better to define what is supported not what isn't, but this'll
have to do for now.
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.h          |    2 +-
 lib/metadata/snapshot_manip.c    |    2 +-
 tools/lvconvert.c                |   45 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0a307ab..9dac46a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -66,7 +66,7 @@
 #define PVMOVE			UINT64_C(0x0000000000002000)	/* VG LV SEG */
 #define LOCKED			UINT64_C(0x0000000000004000)	/* LV */
 #define MIRRORED		UINT64_C(0x0000000000008000)	/* LV - internal use only */
-//#define VIRTUAL		UINT64_C(0x0000000000010000)	/* LV - internal use only */
+#define VIRTUAL			UINT64_C(0x0000000000010000)	/* LV - internal use only */
 #define MIRROR			UINT64_C(0x0002000000000000)    /* LV - Internal use only */
 #define MIRROR_LOG		UINT64_C(0x0000000000020000)	/* LV - Internal use only */
 #define MIRROR_IMAGE		UINT64_C(0x0000000000040000)	/* LV - Internal use only */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 439f6b7..f847ddb 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -55,7 +55,7 @@
 
 #define SPINDOWN_LV          	UINT64_C(0x00000010)	/* LV */
 #define BADBLOCK_ON       	UINT64_C(0x00000020)	/* LV */
-#define VIRTUAL			UINT64_C(0x00010000)	/* LV - internal use only */
+//#define VIRTUAL			UINT64_C(0x00010000)	/* LV - internal use only */
 #define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
 #define POSTORDER_FLAG		UINT64_C(0x02000000) /* Not real flags, reserved for  */
 #define POSTORDER_OPEN_FLAG	UINT64_C(0x04000000) /* temporary use inside vg_read_internal. */
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index dfad615..36a685f 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -193,7 +193,7 @@ void init_snapshot_merge(struct lv_segment *snap_seg,
 
 	if (seg_is_thin_volume(snap_seg)) {
 		snap_seg->merge_lv = origin;
-		/* Making thin LV inivisible with regular log */
+		/* Making thin LV invisible with regular log */
 		lv_set_hidden(snap_seg->lv);
 		return;
 	}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index eb96bc4..4291a9e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2633,10 +2633,14 @@ static int _lvconvert_update_pool_params(struct logical_volume *pool_lv,
 }
 
 /*
+ * Converts a data lv and a metadata lv into a thin or cache pool lv.
+ *
  * Thin lvconvert version which
  *  rename metadata
  *  convert/layers thinpool over data
  *  attach metadata
+ *
+ * pool_lv might or might not already be a pool.
  */
 static int _lvconvert_pool(struct cmd_context *cmd,
 			   struct logical_volume *pool_lv,
@@ -2658,6 +2662,18 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/*
+	 * Only linear, striped and raid supported.
+	 * FIXME Tidy up all these type restrictions.
+	 */
+	if (!lv_is_pool(pool_lv) &&
+	    (lv_is_external_origin(pool_lv) || lv_is_origin(pool_lv) || lv_is_thin_type(pool_lv) ||
+	     lv_is_mirror_type(pool_lv) || lv_is_cache_type(pool_lv) || lv_is_virtual(pool_lv) ||
+	     lv_is_cache_origin(pool_lv) || lv_is_merging_origin(pool_lv) || lv_is_merging_cow(pool_lv))) {
+		log_error("Pool data LV %s is of an unsupported type.", display_lvname(pool_lv));
+		return 0;
+	}
+
 	if (lp->pool_metadata_lv_name) {
 		if (!(lp->pool_metadata_lv = find_lv(vg, lp->pool_metadata_lv_name))) {
 			log_error("Unknown pool metadata LV %s.", lp->pool_metadata_lv_name);
@@ -2671,22 +2687,26 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 				  display_lvname(metadata_lv));
 			return 0;
 		}
+
 		if (lv_is_mirror(metadata_lv)) {
 			log_error("Mirror logical volumes cannot be used "
 				  "for pool metadata.");
 			log_error("Try \"raid1\" segment type instead.");
 			return 0;
 		}
+
 		if (lv_is_locked(metadata_lv)) {
 			log_error("Can't convert locked LV %s.",
 				  display_lvname(metadata_lv));
 			return 0;
 		}
+
 		if (metadata_lv == pool_lv) {
 			log_error("Can't use same LV for pool data and metadata LV %s.",
 				  display_lvname(metadata_lv));
 			return 0;
 		}
+
 		if (lv_is_thin_type(metadata_lv) ||
 		    lv_is_cache_type(metadata_lv)) {
 			log_error("Can't use thin or cache type LV %s for pool metadata.",
@@ -2694,6 +2714,16 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 			return 0;
 		}
 
+		/* FIXME Tidy up all these type restrictions. */
+		if (lv_is_external_origin(metadata_lv) || lv_is_virtual(metadata_lv) ||
+		    lv_is_origin(metadata_lv) || lv_is_thin_origin(metadata_lv, NULL) ||
+		    lv_is_cache_origin(metadata_lv) || lv_is_cow(metadata_lv) ||
+		    lv_is_merging_origin(metadata_lv) || lv_is_merging_cow(metadata_lv)) {
+			log_error("Pool metadata LV %s is of an unsupported type.",
+				  display_lvname(metadata_lv));
+			return 0;
+		}
+
 		if (!lv_is_pool(pool_lv)) {
 			if (!_lvconvert_update_pool_params(pool_lv, lp))
 				return_0;
@@ -3016,6 +3046,9 @@ revert_new_lv:
 #endif
 }
 
+/*
+ * Convert origin into a cache LV by attaching a cache pool.
+ */
 static int _lvconvert_cache(struct cmd_context *cmd,
 			    struct logical_volume *origin,
 			    struct lvconvert_params *lp)
@@ -3035,6 +3068,18 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/*
+	 * Only linear, striped or raid supported.
+	 * FIXME Tidy up all these type restrictions.
+	 */
+	if (lv_is_external_origin(origin) || lv_is_origin(origin) || lv_is_thin_type(origin) ||
+	    lv_is_mirror_type(origin) || lv_is_cache_origin(origin) || lv_is_virtual(origin) ||
+	    lv_is_cow(origin) || lv_is_merging_origin(origin) || lv_is_merging_cow(origin)) {
+		log_error("Cache is not supported with origin LV type.",
+			  display_lvname(origin));
+		return 0;
+	}
+
 	if (!archive(origin->vg))
 		return_0;
 


