From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Aug 2016 14:50:06 +0000 (UTC)
Subject: master - alloc: Record PV tags of parallel PVs in log.
Message-ID: <20160824145006.7D67160960@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40a4f5f38faaa93bf95422f0a12d93df6c484e79
Commit:        40a4f5f38faaa93bf95422f0a12d93df6c484e79
Parent:        68adf2c1999ae57cd50a69ee1047dca6b4877216
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 24 15:49:34 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 24 15:49:34 2016 +0100

alloc: Record PV tags of parallel PVs in log.

---
 lib/metadata/lv_manip.c |   91 ++++++++++++++++++++++++++++-------------------
 1 files changed, 54 insertions(+), 37 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 31b20b0..80ccb91 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1987,25 +1987,20 @@ static int _is_same_pv(struct pv_match *pvmatch __attribute((unused)), struct pv
 /*
  * Does PV area have a tag listed in allocation/cling_tag_list that
  * matches EITHER a tag of the PV of the existing segment OR a tag in pv_tags?
- * If tags_list_str is set, then instead we generate a list of matching tags for printing.
+ * If mem is set, then instead we append a list of matching tags for printing to the object there.
  */
 static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 			  struct physical_volume *pv1, uint32_t pv1_start_pe, uint32_t area_num,
 			  struct physical_volume *pv2, struct dm_list *pv_tags, unsigned validate_only,
-			  struct dm_pool *mem, const char **tags_list_str)
+			  struct dm_pool *mem)
 {
 	const struct dm_config_value *cv;
 	const char *str;
 	const char *tag_matched;
-	struct dm_list *tags_to_match = tags_list_str ? NULL : pv_tags ? : &pv2->tags;
+	struct dm_list *tags_to_match = mem ? NULL : pv_tags ? : &pv2->tags;
 	struct dm_str_list *sl;
 	unsigned first_tag = 1;
 
-	if (tags_list_str && !dm_pool_begin_object(mem, 256)) {
-		log_error("PV tags string allocation failed");
-		return 0;
-	}
-
 	for (cv = cling_tag_list_cn->v; cv; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
 			if (validate_only)
@@ -2042,16 +2037,14 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 
 		/* Wildcard matches any tag against any tag. */
 		if (!strcmp(str, "*")) {
-			if (tags_list_str) {
+			if (mem) {
 				dm_list_iterate_items(sl, &pv1->tags) {
 					if (!first_tag && !dm_pool_grow_object(mem, ",", 0)) {
-						dm_pool_abandon_object(mem);
 						log_error("PV tags string extension failed.");
 						return 0;
 					}
 					first_tag = 0;
 					if (!dm_pool_grow_object(mem, sl->str, 0)) {
-						dm_pool_abandon_object(mem);
 						log_error("PV tags string extension failed.");
 						return 0;
 					}
@@ -2076,15 +2069,13 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 		    (tags_to_match && !str_list_match_item(tags_to_match, str)))
 			continue;
 		else {
-			if (tags_list_str) {
+			if (mem) {
 				if (!first_tag && !dm_pool_grow_object(mem, ",", 0)) {
-					dm_pool_abandon_object(mem);
 					log_error("PV tags string extension failed.");
 					return 0;
 				}
 				first_tag = 0;
 				if (!dm_pool_grow_object(mem, str, 0)) {
-					dm_pool_abandon_object(mem);
 					log_error("PV tags string extension failed.");
 					return 0;
 				}
@@ -2101,32 +2092,25 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 		}
 	}
 
-	if (tags_list_str) {
-		if (!dm_pool_grow_object(mem, "\0", 1)) {
-			dm_pool_abandon_object(mem);
-			log_error("PV tags string extension failed.");
-			return 0;
-		}
-		*tags_list_str = dm_pool_end_object(mem);
+	if (mem)
 		return 1;
-	}
 
 	return 0;
 }
 
 static int _validate_tag_list(const struct dm_config_node *cling_tag_list_cn)
 {
-	return _match_pv_tags(cling_tag_list_cn, NULL, 0, 0, NULL, NULL, 1, NULL, NULL);
+	return _match_pv_tags(cling_tag_list_cn, NULL, 0, 0, NULL, NULL, 1, NULL);
 }
 
-static const char *_tags_list_str(struct alloc_handle *ah, struct physical_volume *pv1)
+static int _tags_list_str(struct dm_pool *mem, struct physical_volume *pv1, const struct dm_config_node *cling_tag_list_cn)
 {
-	const char *tags_list_str;
-
-	if (!_match_pv_tags(ah->cling_tag_list_cn, pv1, 0, 0, NULL, NULL, 0, ah->mem, &tags_list_str))
-		return_NULL;
+	if (!_match_pv_tags(cling_tag_list_cn, pv1, 0, 0, NULL, NULL, 0, mem)) {
+		dm_pool_abandon_object(mem);
+		return_0;
+	}
 
-	return tags_list_str;
+	return 1;
 }
 
 /*
@@ -2137,7 +2121,7 @@ static int _pv_has_matching_tag(const struct dm_config_node *cling_tag_list_cn,
 				struct physical_volume *pv1, uint32_t pv1_start_pe, uint32_t area_num,
 				struct dm_list *pv_tags)
 {
-	return _match_pv_tags(cling_tag_list_cn, pv1, pv1_start_pe, area_num, NULL, pv_tags, 0, NULL, NULL);
+	return _match_pv_tags(cling_tag_list_cn, pv1, pv1_start_pe, area_num, NULL, pv_tags, 0, NULL);
 }
 
 /*
@@ -2147,7 +2131,7 @@ static int _pv_has_matching_tag(const struct dm_config_node *cling_tag_list_cn,
 static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn,
 				  struct physical_volume *pv1, struct physical_volume *pv2)
 {
-	return _match_pv_tags(cling_tag_list_cn, pv1, 0, 0, pv2, NULL, 0, NULL, NULL);
+	return _match_pv_tags(cling_tag_list_cn, pv1, 0, 0, pv2, NULL, 0, NULL);
 }
 
 static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
@@ -2155,32 +2139,56 @@ static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvs
 	return _pvs_have_matching_tag(pvmatch->cling_tag_list_cn, pvseg->pv, pva->map->pv);
 }
 
-static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_areas)
+static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_areas,
+			       const struct dm_config_node *cling_tag_list_cn)
 {
 	struct seg_pvs *spvs;
 	struct pv_list *pvl;
 	char *pvnames;
+	unsigned first;
 
 	if (!parallel_areas)
 		return 1;
 
 	dm_list_iterate_items(spvs, parallel_areas) {
+		first = 1;
+
 		if (!dm_pool_begin_object(mem, 256)) {
 			log_error("dm_pool_begin_object failed");
 			return 0;
 		}
 
 		dm_list_iterate_items(pvl, &spvs->pvs) {
-			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
+			if (!first && !dm_pool_grow_object(mem, " ", 1)) {
 				log_error("dm_pool_grow_object failed");
 				dm_pool_abandon_object(mem);
 				return 0;
 			}
-			if (!dm_pool_grow_object(mem, " ", 1)) {
+
+			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
 				log_error("dm_pool_grow_object failed");
 				dm_pool_abandon_object(mem);
 				return 0;
 			}
+
+			if (cling_tag_list_cn) {
+				if (!dm_pool_grow_object(mem, "(", 1)) {
+					log_error("dm_pool_grow_object failed");
+					dm_pool_abandon_object(mem);
+					return 0;
+				}
+				if (!_tags_list_str(mem, pvl->pv, cling_tag_list_cn)) {
+					dm_pool_abandon_object(mem);
+					return_0;
+				}
+				if (!dm_pool_grow_object(mem, ")", 1)) {
+					log_error("dm_pool_grow_object failed");
+					dm_pool_abandon_object(mem);
+					return 0;
+				}
+			}
+
+			first = 0;
 		}
 
 		if (!dm_pool_grow_object(mem, "\0", 1)) {
@@ -2218,8 +2226,17 @@ static void _reserve_area(struct alloc_handle *ah, struct alloc_state *alloc_sta
 	struct pv_area_used *area_used = &alloc_state->areas[ix_pva];
 	const char *pv_tag_list = NULL;
 
-	if (ah->cling_tag_list_cn)
-		pv_tag_list = _tags_list_str(ah, pva->map->pv);
+	if (ah->cling_tag_list_cn) {
+		if (!dm_pool_begin_object(ah->mem, 256))
+			log_error("PV tags string allocation failed");
+		else if (!_tags_list_str(ah->mem, pva->map->pv, ah->cling_tag_list_cn))
+			dm_pool_abandon_object(ah->mem);
+		else if (!dm_pool_grow_object(ah->mem, "\0", 1)) {
+			dm_pool_abandon_object(ah->mem);
+			log_error("PV tags string extension failed.");
+		} else
+			pv_tag_list = dm_pool_end_object(ah->mem);
+	}
 
 	log_debug_alloc("%s allocation area %" PRIu32 " %s %s start PE %" PRIu32
 			" length %" PRIu32 " leaving %" PRIu32 "%s%s.",
@@ -3001,7 +3018,7 @@ static int _allocate(struct alloc_handle *ah,
 	if (!(pvms = create_pv_maps(ah->mem, vg, allocatable_pvs)))
 		return_0;
 
-	if (!_log_parallel_areas(ah->mem, ah->parallel_areas))
+	if (!_log_parallel_areas(ah->mem, ah->parallel_areas, ah->cling_tag_list_cn))
 		stack;
 
 	alloc_state.areas_size = dm_list_size(pvms);


