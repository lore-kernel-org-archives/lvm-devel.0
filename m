From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 May 2014 15:11:47 +0000 (UTC)
Subject: master - raid: cleanup error messages
Message-ID: <20140527151147.9200460E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9240aca369e210dddb3435433a3c9ac4fe35d357
Commit:        9240aca369e210dddb3435433a3c9ac4fe35d357
Parent:        ae43d1afa205c53e0068cb23b386594e16bbb6a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 27 16:56:33 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 27 17:08:49 2014 +0200

raid: cleanup error messages

Add log_error messages on error paths.
---
 lib/metadata/raid_manip.c |   25 +++++++++++--------------
 1 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f1cb012..ac0f948 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -544,16 +544,10 @@ static int _raid_add_images(struct logical_volume *lv,
 		log_error("Unable to add RAID images to %s of segment type %s",
 			  lv->name, seg->segtype->ops->name(seg));
 		return 0;
-	} else if (!_raid_in_sync(lv)) {
-		log_error("Unable to add RAID images until %s is in-sync",
-			  lv->name);
-		return 0;
 	}
 
-	if (!_alloc_image_components(lv, pvs, count, &meta_lvs, &data_lvs)) {
-		log_error("Failed to allocate new image components");
-		return 0;
-	}
+	if (!_alloc_image_components(lv, pvs, count, &meta_lvs, &data_lvs))
+		return_0;
 
 	/*
 	 * If linear, we must correct data LV names.  They are off-by-one
@@ -570,7 +564,7 @@ static int _raid_add_images(struct logical_volume *lv,
 		dm_list_iterate(l, &data_lvs) {
 			if (l == dm_list_last(&data_lvs)) {
 				lvl = dm_list_item(l, struct lv_list);
-				len = strlen(lv->name) + strlen("_rimage_XXX");
+				len = strlen(lv->name) + sizeof("_rimage_XXX");
 				if (!(name = dm_pool_alloc(lv->vg->vgmem, len))) {
 					log_error("Failed to allocate rimage name.");
 					return 0;
@@ -607,8 +601,7 @@ static int _raid_add_images(struct logical_volume *lv,
 			log_very_verbose("Setting RAID1 region_size to %uS",
 					 seg->region_size);
 		}
-		seg->segtype = get_segtype_from_string(lv->vg->cmd, "raid1");
-		if (!seg->segtype)
+		if (!(seg->segtype = get_segtype_from_string(lv->vg->cmd, "raid1")))
 			return_0;
 	}
 /*
@@ -624,15 +617,19 @@ to be left for these sub-lvs.
 */
 	/* Expand areas array */
 	if (!(new_areas = dm_pool_zalloc(lv->vg->cmd->mem,
-					 new_count * sizeof(*new_areas))))
+					 new_count * sizeof(*new_areas)))) {
+		log_error("Allocation of new areas failed.");
 		goto fail;
+	}
 	memcpy(new_areas, seg->areas, seg->area_count * sizeof(*seg->areas));
 	seg->areas = new_areas;
 
 	/* Expand meta_areas array */
 	if (!(new_areas = dm_pool_zalloc(lv->vg->cmd->mem,
-					 new_count * sizeof(*new_areas))))
+					 new_count * sizeof(*new_areas)))) {
+		log_error("Allocation of new meta areas failed.");
 		goto fail;
+	}
 	if (seg->meta_areas)
 		memcpy(new_areas, seg->meta_areas,
 		       seg->area_count * sizeof(*seg->meta_areas));
@@ -738,7 +735,7 @@ fail:
 	dm_list_iterate_items(lvl, &data_lvs)
 		if (!lv_remove(lvl->lv))
 			return_0;
-	return_0;
+	return 0;
 }
 
 /*


