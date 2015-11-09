From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:55 +0000 (UTC)
Subject: master - cleanup: use NAME_LEN
Message-ID: <20151109092855.D355760EC1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04f76d9020dc1301540c949e0a0212e1ad44ff6d
Commit:        04f76d9020dc1301540c949e0a0212e1ad44ff6d
Parent:        5c48ef993b372397716dc6f1cf81aec5b5ef2188
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 5 11:58:03 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:51 2015 +0100

cleanup: use NAME_LEN

Let's have instant check for max name len when creating
subLV name.
---
 lib/metadata/lv_manip.c |   47 ++++++++++++++++++++++++++---------------------
 1 files changed, 26 insertions(+), 21 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 48f470e..fbb5322 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3718,8 +3718,7 @@ static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 	uint32_t i;
 	uint64_t sub_lv_status = 0;
 	const char *layer_name;
-	size_t len = strlen(lv->name) + 32;
-	char img_name[len];
+	char img_name[NAME_LEN];
 	struct lv_segment *mapseg;
 
 	if (lv->le_count || !dm_list_empty(&lv->segments)) {
@@ -3745,7 +3744,8 @@ static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 	if (!(mapseg = alloc_lv_segment(segtype, lv, 0, 0, lv->status,
 					stripe_size, NULL,
 					devices, 0, 0, region_size, 0, NULL))) {
-		log_error("Failed to create mapping segment for %s", lv->name);
+		log_error("Failed to create mapping segment for %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -3755,19 +3755,19 @@ static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 	for (i = 0; i < devices; i++) {
 		/* Data LVs */
 		if (devices > 1) {
-			if (dm_snprintf(img_name, len, "%s_%s_%u",
+			if (dm_snprintf(img_name, sizeof(img_name), "%s_%s_%u",
 					lv->name, layer_name, i) < 0)
-				return_0;
+				goto_bad;
 		} else {
-			if (dm_snprintf(img_name, len, "%s_%s",
+			if (dm_snprintf(img_name, sizeof(img_name), "%s_%s",
 					lv->name, layer_name) < 0)
-				return_0;
+				goto_bad;
 		}
 
 		/* FIXME Should use ALLOC_INHERIT here and inherit from parent LV */
 		if (!(sub_lv = lv_create_empty(img_name, NULL,
-					 LVM_READ | LVM_WRITE,
-					 lv->alloc, lv->vg)))
+					       LVM_READ | LVM_WRITE,
+					       lv->alloc, lv->vg)))
 			return_0;
 
 		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, sub_lv_status))
@@ -3775,24 +3775,29 @@ static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 
 		/* Metadata LVs for raid */
 		if (segtype_is_raid(segtype)) {
-			if (dm_snprintf(img_name, len, "%s_rmeta_%u", lv->name, i) < 0)
+			if (dm_snprintf(img_name, sizeof(img_name), "%s_rmeta_%u",
+					lv->name, i) < 0)
+				goto_bad;
+			/* FIXME Should use ALLOC_INHERIT here and inherit from parent LV */
+			if (!(sub_lv = lv_create_empty(img_name, NULL,
+						       LVM_READ | LVM_WRITE,
+						       lv->alloc, lv->vg)))
 				return_0;
-		} else
-			continue;
 
-		/* FIXME Should use ALLOC_INHERIT here and inherit from parent LV */
-		if (!(sub_lv = lv_create_empty(img_name, NULL,
-					       LVM_READ | LVM_WRITE,
-					       lv->alloc, lv->vg)))
-			return_0;
-
-		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, RAID_META))
+			if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, RAID_META))
 				return_0;
+		}
 	}
 
 	dm_list_add(&lv->segments, &mapseg->list);
 
 	return 1;
+
+bad:
+	log_error("Failed to create sub LV name for LV %s.",
+		  display_lvname(lv));
+
+	return 0;
 }
 
 static int _lv_extend_layered_lv(struct alloc_handle *ah,
@@ -3880,8 +3885,8 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 				return 0;
 			}
 
-			log_verbose("Clearing metadata area of %s/%s",
-				    meta_lv->vg->name, meta_lv->name);
+			log_verbose("Clearing metadata area of %s",
+				    display_lvname(meta_lv));
 			/*
 			 * Rather than wiping meta_lv->size, we can simply
 			 * wipe '1' to remove the superblock of any previous


