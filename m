From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 17:37:47 +0000 (UTC)
Subject: master - pools: prefetch pool_lv and origin_lv
Message-ID: <20141026173747.A7D8160282@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25307e4add1e3f25cf5ae00d942df61afa46fe60
Commit:        25307e4add1e3f25cf5ae00d942df61afa46fe60
Parent:        618d818c0d31bbfa1ed4af2e8954c8a4b53127af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 18:17:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 18:37:13 2014 +0100

pools: prefetch pool_lv and origin_lv

Load pool_lv and origin_lv at a single place and
use it for more types as they need them.
---
 lib/metadata/lv_manip.c |  105 ++++++++++++++++++++++++----------------------
 1 files changed, 55 insertions(+), 50 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 335a1bd..8523b58 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6602,7 +6602,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 					       const char *new_lv_name)
 {
 	struct cmd_context *cmd = vg->cmd;
-	uint32_t size_rest;
+	uint32_t size_rest, size;
 	uint64_t status = lp->permission | VISIBLE_LV;
 	const struct segment_type *create_segtype = lp->segtype;
 	struct logical_volume *lv, *origin_lv = NULL;
@@ -6702,18 +6702,46 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (seg_is_pool(lp))
 		status |= LVM_WRITE; /* Pool is always writable */
+        else if (seg_is_cache(lp) || seg_is_thin_volume(lp)) {
+		/* Resolve pool volume */
+		if (!lp->pool_name) {
+			/* Should be already checked */
+			log_error(INTERNAL_ERROR "Cannot create %s volume without %s pool.",
+				  lp->segtype->name, lp->segtype->name);
+			return NULL;
+		}
 
-	if (seg_is_cache_pool(lp) && lp->origin_name) {
-		/* Converting exiting origin and creating cache pool */
-		if (!(origin_lv = find_lv(vg, lp->origin_name))) {
-			log_error("Cache origin volume %s not found in Volume group %s.",
-				  lp->origin_name, vg->name);
+		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
+			log_error("Couldn't find volume %s in Volume group %s.",
+				  lp->pool_name, vg->name);
 			return NULL;
 		}
 
+		if (lv_is_locked(pool_lv)) {
+			log_error("Cannot use locked pool volume %s.",
+				  display_lvname(pool_lv));
+			return NULL;
+		}
+	}
+
+	/* Resolve origin volume */
+	if (lp->origin_name &&
+	    !(origin_lv = find_lv(vg, lp->origin_name))) {
+		log_error("Origin volume %s not found in Volume group %s.",
+			  lp->origin_name, vg->name);
+		return NULL;
+	}
+
+	if (origin_lv && seg_is_cache_pool(lp)) {
+		/* Converting exiting origin and creating cache pool */
 		if (!validate_lv_cache_create_origin(origin_lv))
 			return_NULL;
 
+		if (origin_lv->size < lp->chunk_size) {
+			log_error("Caching of origin cache volume smaller then chunk size is unsupported.");
+			return NULL;
+		}
+
 		/* Validate cache origin is exclusively active */
 		if (vg_is_clustered(origin_lv->vg) &&
 		    locking_is_clustered() &&
@@ -6724,29 +6752,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				  display_lvname(origin_lv));
 			return NULL;
 		}
-	} else if (seg_is_cache(lp)) {
-		if (!lp->pool_name) {
-			log_error(INTERNAL_ERROR "Cannot create thin volume without thin pool.");
-			return NULL;
-		}
-		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
-			log_error("Couldn't find volume %s in Volume group %s.",
-				  lp->pool_name, vg->name);
-			return NULL;
-		}
-
+	} else if (pool_lv && seg_is_cache(lp)) {
 		if (!lv_is_cache_pool(pool_lv)) {
 			log_error("Logical volume %s is not a cache pool.",
 				  display_lvname(pool_lv));
 			return NULL;
 		}
-
-		if (lv_is_locked(pool_lv)) {
-			log_error("Cannot use locked cache pool %s.",
-				  display_lvname(pool_lv));
-			return NULL;
-		}
-
 		/* Create cache origin for cache pool */
 		/* TODO: eventually support raid/mirrors with -m */
 		if (!(create_segtype = get_segtype_from_string(vg->cmd, "striped")))
@@ -6765,39 +6776,16 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
 							      lp->extents,
 							      lp->region_size, 0);
-	} else if (seg_is_thin_volume(lp)) {
-		if (!lp->pool_name) {
-			log_error(INTERNAL_ERROR "Cannot create thin volume without thin pool.");
-			return NULL;
-		}
-
-		if (!(pool_lv = find_lv(vg, lp->pool_name))) {
-			log_error("Unable to find existing pool LV %s in VG %s.",
-				  lp->pool_name, vg->name);
-			return NULL;
-		}
-
+	} else if (pool_lv && seg_is_thin_volume(lp)) {
 		if (!lv_is_thin_pool(pool_lv)) {
 			log_error("Logical volume %s is not a thin pool.",
 				  display_lvname(pool_lv));
 			return NULL;
 		}
 
-		if (lv_is_locked(pool_lv)) {
-			log_error("Cannot use locked thin pool %s.",
-				  display_lvname(pool_lv));
-			return NULL;
-		}
-
 		thin_name = lp->pool_name;
 
-		if (lp->origin_name) {
-			if (!(origin_lv = find_lv(vg, lp->origin_name))) {
-				log_error("Couldn't find origin volume '%s'.",
-					  lp->origin_name);
-				return NULL;
-			}
-
+		if (origin_lv) {
 			if (lv_is_locked(origin_lv)) {
 				log_error("Snapshots of locked devices are not supported.");
 				return NULL;
@@ -6809,10 +6797,27 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				thin_name = origin_lv->name;
 
 			lp->voriginextents = origin_lv->le_count;
+
+			/*
+			 * Check if using 'external origin' or the 'normal' snapshot
+			 * within the same thin pool
+			 */
+			if (first_seg(origin_lv)->pool_lv != pool_lv) {
+				if (!pool_supports_external_origin(first_seg(pool_lv), origin_lv))
+					return_NULL;
+				if (origin_lv->status & LVM_WRITE) {
+					log_error("Cannot use writable LV as the external origin.");
+					return NULL; // TODO conversion for inactive
+				}
+				if (lv_is_active(origin_lv) && !lv_is_external_origin(origin_lv)) {
+					log_error("Cannot use active LV for the external origin.");
+					return NULL; // We can't be sure device is read-only
+				}
+			}
 		}
 	} else if (lp->snapshot) {
 		if (!lp->voriginsize) {
-			if (!(origin_lv = find_lv(vg, lp->origin_name))) {
+			if (!origin_lv) {
 				log_error("Couldn't find origin volume '%s'.",
 					  lp->origin_name);
 				return NULL;


