From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:34 +0000 (GMT)
Subject: main - debug: more use of display_lvname
Message-ID: <20210310003634.391C93858038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d01c17ff229beb1cfe9d6331fbd35637866412ec
Commit:        d01c17ff229beb1cfe9d6331fbd35637866412ec
Parent:        7342ab06fcce5f386e1fd58fa9e82352d570398e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 13:13:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:11:52 2021 +0100

debug: more use of display_lvname

---
 lib/metadata/pool_manip.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 1975cb418..9ceec3a7e 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -177,7 +177,7 @@ static struct glv_list *_init_historical_glvl(struct dm_pool *mem, struct lv_seg
 	return glvl;
 bad:
 	log_error("Initialization of historical LV representation for removed logical "
-		  "volume %s/%s failed.", seg->lv->vg->name, seg->lv->name);
+		  "volume %s failed.", display_lvname(seg->lv));
 	if (glvl)
 		dm_pool_free(mem, glvl);
 	return NULL;
@@ -214,7 +214,7 @@ static struct generic_logical_volume *_create_historical_glv(struct lv_segment *
 	return historical_glvl->glv;
 bad:
 	log_error("Failed to create historical LV representation for removed logical "
-		  "volume %s/%s.", seg_to_remove->lv->vg->name, seg_to_remove->lv->name);
+		  "volume %s.", display_lvname(seg_to_remove->lv));
 	if (origin_glv_created)
 		seg_to_remove->origin->this_glv = NULL;
 	if (historical_glvl)
@@ -257,7 +257,7 @@ int detach_pool_lv(struct lv_segment *seg)
 	if (!seg->pool_lv) {
 		log_error(INTERNAL_ERROR
 			  "No pool associated with %s LV, %s.",
-			  lvseg_name(seg), seg->lv->name);
+			  lvseg_name(seg), display_lvname(seg->lv));
 		return 0;
 	}
 
@@ -273,9 +273,8 @@ int detach_pool_lv(struct lv_segment *seg)
 	}
 
 	if (!lv_is_thin_pool(seg->pool_lv)) {
-		log_error(INTERNAL_ERROR
-			  "Cannot detach pool from LV %s.",
-			  seg->lv->name);
+		log_error(INTERNAL_ERROR "Cannot detach pool from LV %s.",
+			  display_lvname(seg->lv));
 		return 0;
 	}
 
@@ -286,7 +285,7 @@ int detach_pool_lv(struct lv_segment *seg)
 		case DM_THIN_MESSAGE_CREATE_THIN:
 			if (tmsg->u.lv == seg->lv) {
 				log_debug_metadata("Discarding message for LV %s.",
-						   tmsg->u.lv->name);
+						   display_lvname(tmsg->u.lv));
 				dm_list_del(&tmsg->list);
 				no_update = 1; /* Replacing existing */
 			}
@@ -397,7 +396,7 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 
 	if ((lv_is_thin_type(seg->lv) && !seg_is_pool(pool_seg))) {
 		log_error("%s on %s is not a %s pool segment",
-			  pool_seg->lv->name, seg->lv->name,
+			  display_lvname(pool_seg->lv), display_lvname(seg->lv),
 			  lv_is_thin_type(seg->lv) ? "thin" : "cache");
 		return NULL;
 	}
@@ -494,7 +493,7 @@ int create_pool(struct logical_volume *pool_lv,
 
 	if (pool_lv->le_count) {
 		log_error(INTERNAL_ERROR "Pool %s already has extents.",
-			  pool_lv->name);
+			  display_lvname(pool_lv));
 		return 0;
 	}
 
@@ -523,7 +522,7 @@ int create_pool(struct logical_volume *pool_lv,
 
 	if (!activation())
 		log_warn("WARNING: Pool %s is created without initialization.",
-			 pool_lv->name);
+			 display_lvname(pool_lv));
 	else if (!test_mode()) {
 		if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 			return_0;


