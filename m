From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:05:00 -0400
Subject: master - cachevol: move flag setting after taking archive
Message-ID: <201910171105.x9HB50wb023600@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dab4a2c893ef48636809b75b2ee225e195073fe0
Commit:        dab4a2c893ef48636809b75b2ee225e195073fe0
Parent:        f63e20ebcc0488a574fcfb65ea015fb2f988212a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 21:22:20 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:50 2019 +0200

cachevol: move flag setting after taking archive

Before 'archive()' is called, lvm2 must not touch/modify metadata.
So move setting  CACHE_VOL related flags past this point.

Also make sure reading of cache segtype always restores this
flag properly (even if compatible flag would be lost).
---
 lib/cache_segtype/cache.c |    7 ++++---
 lib/metadata/pool_manip.c |   16 ++++++++++++++--
 tools/lvconvert.c         |   13 ++-----------
 3 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 4699070..69b46a5 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -504,9 +504,6 @@ static int _cache_text_import(struct lv_segment *seg,
 
 	seg->lv->status |= strstr(seg->lv->name, "_corig") ? LV_PENDING_DELETE : 0;
 
-	if (!attach_pool_lv(seg, pool_lv, NULL, NULL, NULL))
-		return_0;
-
 	if (!_settings_text_import(seg, sn))
 		return_0;
 
@@ -547,6 +544,7 @@ static int _cache_text_import(struct lv_segment *seg,
 			if (!id_read_format(seg->data_id, uuid))
 				return SEG_LOG_ERROR("Couldn't format data_id in");
 		}
+		pool_lv->status |= LV_CACHE_VOL; /* Mark as cachevol LV */
 	} else {
 		/* Do not call this when LV is cache_vol. */
 		/* load order is unknown, could be cache origin or pool LV, so check for both */
@@ -554,6 +552,9 @@ static int _cache_text_import(struct lv_segment *seg,
 			_fix_missing_defaults(first_seg(pool_lv));
 	}
 
+	if (!attach_pool_lv(seg, pool_lv, NULL, NULL, NULL))
+		return_0;
+
 	return 1;
 }
 
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 8d0aa83..bed51f1 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -106,8 +106,20 @@ int attach_pool_lv(struct lv_segment *seg,
 	seg->origin = origin;
 	seg->lv->status |= seg_is_cache(seg) ? CACHE : THIN_VOLUME;
 
-	if (seg_is_cache(seg))
-		lv_set_hidden(pool_lv); /* Used cache-pool is hidden */
+	if (seg_is_cache(seg)) {
+		lv_set_hidden(pool_lv); /* Used cache-pool/cachevol is hidden */
+
+		if (lv_is_cache_vol(pool_lv))
+			/*
+			 * This flag is added to the segtype name so that old versions of lvm
+			 * (if they happen to be used with new metadata with a cache LV using a
+			 * cachevol) will report an error when they see the unknown
+			 * cache+CACHE_USES_CACHEVOL segment type.  Otherwise the old version
+			 * would expect to find a cache pool and fail.
+			 */
+			seg->lv->status |= LV_CACHE_USES_CACHEVOL;
+	}
+
 
 	if (origin && !add_seg_to_segs_using_this_lv(origin, seg))
 		return_0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5a3c1c4..48ff8e1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3475,6 +3475,8 @@ static int _cache_vol_attach(struct cmd_context *cmd,
 	if (!archive(vg))
 		goto_out;
 
+	lv_fast->status |= LV_CACHE_VOL; /* Mark as cachevol LV */
+
 	/*
 	 * Changes the vg struct to match the desired state.
 	 *
@@ -4271,17 +4273,6 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 	if (!lv_rename_update(cmd, cachevol_lv, cvol_name, 0))
 		return_0;
 
-	/*
-	 * This flag is added to the segtype name so that old versions of lvm
-	 * (if they happen to be used with new metadata with a cache LV using a
-	 * cachevol) will report an error when they see the unknown
-	 * cache+CACHE_USES_CACHEVOL segment type.  Otherwise the old version
-	 * would expect to find a cache pool and fail.
-	 */
-	lv->status |= LV_CACHE_USES_CACHEVOL;
-
-	cachevol_lv->status |= LV_CACHE_VOL;
-
 	/* Attach the cache to the main LV. */
 
 	if (!_cache_vol_attach(cmd, lv, cachevol_lv))


