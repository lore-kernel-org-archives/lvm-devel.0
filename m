From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:59 +0000 (UTC)
Subject: dev-dct-process-latest - cleanup: update _alloc_image_component function
Message-ID: <20140922153759.6706460D38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76c3c94bd2a2ac4d3e255541da515cae8e823621
Commit:        76c3c94bd2a2ac4d3e255541da515cae8e823621
Parent:        126463ad1fd653f76d5cd112e02d5214e0433587
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 12 11:48:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:30 2014 +0200

cleanup: update _alloc_image_component function

Return allocated volume directly instead of 1/0.
---
 lib/metadata/raid_manip.c |   60 +++++++++++++++++++++++---------------------
 1 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2369f5f..b670058 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -349,37 +349,41 @@ static char *_generate_raid_name(struct logical_volume *lv,
  * Create an LV of specified type.  Set visible after creation.
  * This function does not make metadata changes.
  */
-static int _alloc_image_component(struct logical_volume *lv,
-				  const char *alt_base_name,
-				  struct alloc_handle *ah, uint32_t first_area,
-				  uint64_t type, struct logical_volume **new_lv)
+static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
+						     const char *alt_base_name,
+						     struct alloc_handle *ah, uint32_t first_area,
+						     uint64_t type)
 {
 	uint64_t status;
-	size_t len = strlen(lv->name) + 32;
-	char img_name[len];
-	const char *base_name = (alt_base_name) ? alt_base_name : lv->name;
+	char img_name[NAME_LEN];
+	const char *type_suffix;
 	struct logical_volume *tmp_lv;
 	const struct segment_type *segtype;
 
-	if (type == RAID_META) {
-		if (dm_snprintf(img_name, len, "%s_rmeta_%%d", base_name) < 0)
-			return_0;
-	} else if (type == RAID_IMAGE) {
-		if (dm_snprintf(img_name, len, "%s_rimage_%%d", base_name) < 0)
-			return_0;
-	} else {
+	if (!ah) {
 		log_error(INTERNAL_ERROR
-			  "Bad type provided to _alloc_raid_component");
+			  "Stand-alone %s area allocation not implemented",
+			  (type == RAID_META) ? "metadata" : "data");
 		return 0;
 	}
 
-	if (!ah) {
+	switch (type) {
+	case RAID_META:
+		type_suffix = "rmeta";
+		break;
+	case RAID_IMAGE:
+		type_suffix = "rimage";
+		break;
+	default:
 		log_error(INTERNAL_ERROR
-			  "Stand-alone %s area allocation not implemented",
-			  (type == RAID_META) ? "metadata" : "data");
+			  "Bad type provided to _alloc_raid_component.");
 		return 0;
 	}
 
+	if (dm_snprintf(img_name, sizeof(img_name), "%s_%s_%%d",
+			(alt_base_name) ? : lv->name, type_suffix) < 0)
+		return_0;
+
 	status = LVM_READ | LVM_WRITE | LV_REBUILD | type;
 	if (!(tmp_lv = lv_create_empty(img_name, NULL, status, ALLOC_INHERIT, lv->vg))) {
 		log_error("Failed to allocate new raid component, %s.", img_name);
@@ -395,8 +399,8 @@ static int _alloc_image_component(struct logical_volume *lv,
 	}
 
 	lv_set_visible(tmp_lv);
-	*new_lv = tmp_lv;
-	return 1;
+
+	return tmp_lv;
 }
 
 static int _alloc_image_components(struct logical_volume *lv,
@@ -411,7 +415,6 @@ static int _alloc_image_components(struct logical_volume *lv,
 	const struct segment_type *segtype;
 	struct alloc_handle *ah;
 	struct dm_list *parallel_areas;
-	struct logical_volume *tmp_lv;
 	struct lv_list *lvl_array;
 
 	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem,
@@ -455,16 +458,16 @@ static int _alloc_image_components(struct logical_volume *lv,
 		 * allocated areas.  Thus, the metadata areas are pulled
 		 * from 's + count'.
 		 */
-		if (!_alloc_image_component(lv, NULL, ah, s + count,
-					    RAID_META, &tmp_lv))
+		if (!(lvl_array[s + count].lv =
+		      _alloc_image_component(lv, NULL, ah, s + count, RAID_META)))
 			return_0;
-		lvl_array[s + count].lv = tmp_lv;
+
 		dm_list_add(new_meta_lvs, &(lvl_array[s + count].list));
 
-		if (!_alloc_image_component(lv, NULL, ah, s,
-					    RAID_IMAGE, &tmp_lv))
+		if (!(lvl_array[s].lv =
+		      _alloc_image_component(lv, NULL, ah, s, RAID_IMAGE)))
 			return_0;
-		lvl_array[s].lv = tmp_lv;
+
 		dm_list_add(new_data_lvs, &(lvl_array[s].list));
 	}
 
@@ -514,8 +517,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 				    &allocatable_pvs, data_lv->alloc, 0, NULL)))
 		return_0;
 
-	if (!_alloc_image_component(data_lv, base_name, ah, 0,
-				    RAID_META, meta_lv))
+	if (!(*meta_lv = _alloc_image_component(data_lv, base_name, ah, 0, RAID_META)))
 		return_0;
 
 	alloc_destroy(ah);


