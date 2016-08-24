From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Aug 2016 18:41:40 +0000 (UTC)
Subject: master - alloc: Avoid PV tags too when avoiding parallel PV allocation.
Message-ID: <20160824184140.5C8FB6103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ba77681116ce702dc31827ca6d3db6bfd56a269
Commit:        7ba77681116ce702dc31827ca6d3db6bfd56a269
Parent:        bff470f83f7c68ab0cf9b0c23751a5eb8e1d0e43
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 24 19:37:50 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 24 19:41:11 2016 +0100

alloc: Avoid PV tags too when avoiding parallel PV allocation.

Also add debug messages for parallel PVs.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   56 ++++++++++++++++++++++++++++++----------------
 2 files changed, 37 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b94810c..60e052e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Avoid PV tags when checking allocation against parallel PVs.
   Disallow mirror conversions of raid10 volumes.
   Fix dmeventd unmonitoring when segment type (and dso) changes.
   Don't allow lvconvert --repair on raid0 devices or attempt to monitor them.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 80ccb91..dcc8d86 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1992,7 +1992,7 @@ static int _is_same_pv(struct pv_match *pvmatch __attribute((unused)), struct pv
 static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 			  struct physical_volume *pv1, uint32_t pv1_start_pe, uint32_t area_num,
 			  struct physical_volume *pv2, struct dm_list *pv_tags, unsigned validate_only,
-			  struct dm_pool *mem)
+			  struct dm_pool *mem, unsigned parallel_pv)
 {
 	const struct dm_config_value *cv;
 	const char *str;
@@ -2054,10 +2054,14 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 			if (!str_list_match_list(&pv1->tags, tags_to_match, &tag_matched))
 				continue;
 			else {
-				if (!pv_tags)
-					log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
-							tag_matched, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
-				else
+				if (!pv_tags) {
+					if (parallel_pv)
+						log_debug_alloc("Not using free space on %s: Matched allocation PV tag %s on existing parallel PV %s.",
+								pv_dev_name(pv1), tag_matched, pv2 ? pv_dev_name(pv2) : "-");
+					else
+						log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
+								tag_matched, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
+				} else
 					log_debug_alloc("Eliminating allocation area %" PRIu32 " at PV %s start PE %" PRIu32
 							" from consideration: PV tag %s already used.",
 							area_num, pv_dev_name(pv1), pv1_start_pe, tag_matched);
@@ -2081,10 +2085,14 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 				}
 				continue;
 			}
-			if (!pv_tags)
-				log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
-						str, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
-			else
+			if (!pv_tags) {
+				if (parallel_pv)
+					log_debug_alloc("Not using free space on %s: Matched allocation PV tag %s on existing parallel PV %s.",
+ 							pv2 ? pv_dev_name(pv2) : "-", str, pv_dev_name(pv1));
+				else
+					log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
+							str, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
+			} else
 				log_debug_alloc("Eliminating allocation area %" PRIu32 " at PV %s start PE %" PRIu32
 						" from consideration: PV tag %s already used.",
 						area_num, pv_dev_name(pv1), pv1_start_pe, str);
@@ -2100,12 +2108,12 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 
 static int _validate_tag_list(const struct dm_config_node *cling_tag_list_cn)
 {
-	return _match_pv_tags(cling_tag_list_cn, NULL, 0, 0, NULL, NULL, 1, NULL);
+	return _match_pv_tags(cling_tag_list_cn, NULL, 0, 0, NULL, NULL, 1, NULL, 0);
 }
 
 static int _tags_list_str(struct dm_pool *mem, struct physical_volume *pv1, const struct dm_config_node *cling_tag_list_cn)
 {
-	if (!_match_pv_tags(cling_tag_list_cn, pv1, 0, 0, NULL, NULL, 0, mem)) {
+	if (!_match_pv_tags(cling_tag_list_cn, pv1, 0, 0, NULL, NULL, 0, mem, 0)) {
 		dm_pool_abandon_object(mem);
 		return_0;
 	}
@@ -2121,7 +2129,7 @@ static int _pv_has_matching_tag(const struct dm_config_node *cling_tag_list_cn,
 				struct physical_volume *pv1, uint32_t pv1_start_pe, uint32_t area_num,
 				struct dm_list *pv_tags)
 {
-	return _match_pv_tags(cling_tag_list_cn, pv1, pv1_start_pe, area_num, NULL, pv_tags, 0, NULL);
+	return _match_pv_tags(cling_tag_list_cn, pv1, pv1_start_pe, area_num, NULL, pv_tags, 0, NULL, 0);
 }
 
 /*
@@ -2129,14 +2137,15 @@ static int _pv_has_matching_tag(const struct dm_config_node *cling_tag_list_cn,
  * matches a tag of the PV of the existing segment?
  */
 static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn,
-				  struct physical_volume *pv1, struct physical_volume *pv2)
+				  struct physical_volume *pv1, struct physical_volume *pv2,
+				  unsigned parallel_pv)
 {
-	return _match_pv_tags(cling_tag_list_cn, pv1, 0, 0, pv2, NULL, 0, NULL);
+	return _match_pv_tags(cling_tag_list_cn, pv1, 0, 0, pv2, NULL, 0, NULL, parallel_pv);
 }
 
 static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
 {
-	return _pvs_have_matching_tag(pvmatch->cling_tag_list_cn, pvseg->pv, pva->map->pv);
+	return _pvs_have_matching_tag(pvmatch->cling_tag_list_cn, pvseg->pv, pva->map->pv, 0);
 }
 
 static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_areas,
@@ -2395,7 +2404,7 @@ static int _check_cling_to_alloced(struct alloc_handle *ah, const struct dm_conf
 			continue;	/* Area already assigned */
 		dm_list_iterate_items(aa, &ah->alloced_areas[s]) {
 			if ((!cling_tag_list_cn && (pva->map->pv == aa[0].pv)) ||
-			    (cling_tag_list_cn && _pvs_have_matching_tag(cling_tag_list_cn, pva->map->pv, aa[0].pv))) {
+			    (cling_tag_list_cn && _pvs_have_matching_tag(cling_tag_list_cn, pva->map->pv, aa[0].pv, 0))) {
 				if (positional)
 					_reserve_required_area(ah, alloc_state, pva, pva->count, s, 0);
 				return 1;
@@ -2406,13 +2415,20 @@ static int _check_cling_to_alloced(struct alloc_handle *ah, const struct dm_conf
 	return 0;
 }
 
-static int _pv_is_parallel(struct physical_volume *pv, struct dm_list *parallel_pvs)
+static int _pv_is_parallel(struct physical_volume *pv, struct dm_list *parallel_pvs, const struct dm_config_node *cling_tag_list_cn)
 {
 	struct pv_list *pvl;
 
-	dm_list_iterate_items(pvl, parallel_pvs)
-		if (pv == pvl->pv)
+	dm_list_iterate_items(pvl, parallel_pvs) {
+		if (pv == pvl->pv) {
+			log_debug_alloc("Not using free space on existing parallel PV %s.",
+					pv_dev_name(pvl->pv));
+			return 1;
+		}
+		if (cling_tag_list_cn && _pvs_have_matching_tag(cling_tag_list_cn, pvl->pv, pv, 1))
 			return 1;
+	}
+
 
 	return 0;
 }
@@ -2700,7 +2716,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 				/* FIXME Split into log and non-log parallel_pvs and only check the log ones if log_iteration? */
 				/* (I've temporatily disabled the check.) */
 				/* Avoid PVs used by existing parallel areas */
-				if (!log_iteration_count && parallel_pvs && _pv_is_parallel(pvm->pv, parallel_pvs))
+				if (!log_iteration_count && parallel_pvs && _pv_is_parallel(pvm->pv, parallel_pvs, ah->cling_tag_list_cn))
 					goto next_pv;
 
 				/*


