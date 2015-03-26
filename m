From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Mar 2015 21:15:31 +0000 (UTC)
Subject: master - alloc: Log PV tags when reserving areas.
Message-ID: <20150326211531.9F8F8601C4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1e3e9916966a2ebdaf9315f929c1f34e326f6e0
Commit:        f1e3e9916966a2ebdaf9315f929c1f34e326f6e0
Parent:        e8fa3354f09c137b14fe2d11f0892de5f7cedec6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 26 21:13:26 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 26 21:13:26 2015 +0000

alloc: Log PV tags when reserving areas.

---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   80 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 75 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f2d5b80..0a5d797 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Log relevant PV tags when using cling allocation.
   Add str_list_add_list() to combine two lists.
   Fix LV processing with selection to always do the selection on initial state.
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b80bcae..11a46e1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1976,15 +1976,24 @@ static int _is_same_pv(struct pv_match *pvmatch __attribute((unused)), struct pv
 /*
  * Does PV area have a tag listed in allocation/cling_tag_list that 
  * matches a tag of the PV of the existing segment?
+ * If tags_list_str is set, then instead we generate a list of matching tags for printing.
  */
 static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 			  struct physical_volume *pv1,
 			  struct physical_volume *pv2,
-			  unsigned validate_only)
+			  unsigned validate_only, 
+			  struct dm_pool *mem, const char **tags_list_str)
 {
 	const struct dm_config_value *cv;
 	const char *str;
 	const char *tag_matched;
+	struct dm_str_list *sl;
+	unsigned first_tag = 1;
+
+	if (tags_list_str && !dm_pool_begin_object(mem, 256)) {
+		log_error("PV tags string allocation failed");
+		return 0;
+	}
 
 	for (cv = cling_tag_list_cn->v; cv; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
@@ -2022,6 +2031,22 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 
 		/* Wildcard matches any tag against any tag. */
 		if (!strcmp(str, "*")) {
+			if (tags_list_str) {
+				dm_list_iterate_items(sl, &pv1->tags) {
+					if (!first_tag && !dm_pool_grow_object(mem, ",", 0)) {
+						dm_pool_abandon_object(mem);
+						log_error("PV tags string extension failed.");
+						return 0;
+					}
+					first_tag = 0;
+					if (!dm_pool_grow_object(mem, sl->str, 0)) {
+						dm_pool_abandon_object(mem);
+						log_error("PV tags string extension failed.");
+						return 0;
+					}
+				}
+				continue;
+			}
 			if (!str_list_match_list(&pv1->tags, &pv2->tags, &tag_matched))
 				continue;
 			else {
@@ -2032,21 +2057,55 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 		}
 
 		if (!str_list_match_item(&pv1->tags, str) ||
-		    !str_list_match_item(&pv2->tags, str))
+		    (pv2 && !str_list_match_item(&pv2->tags, str)))
 			continue;
 		else {
+			if (tags_list_str) {
+				if (!first_tag && !dm_pool_grow_object(mem, ",", 0)) {
+					dm_pool_abandon_object(mem);
+					log_error("PV tags string extension failed.");
+					return 0;
+				}
+				first_tag = 0;
+				if (!dm_pool_grow_object(mem, str, 0)) {
+					dm_pool_abandon_object(mem);
+					log_error("PV tags string extension failed.");
+					return 0;
+				}
+				continue;
+			}
 			log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
 					str, pv_dev_name(pv1), pv_dev_name(pv2));
 			return 1;
 		}
 	}
 
+	if (tags_list_str) {
+		if (!dm_pool_grow_object(mem, "\0", 1)) {
+			dm_pool_abandon_object(mem);
+			log_error("PV tags string extension failed.");
+			return 0;
+		}
+		*tags_list_str = dm_pool_end_object(mem);
+		return 1;
+	}
+
 	return 0;
 }
 
 static int _validate_tag_list(const struct dm_config_node *cling_tag_list_cn)
 {
-	return _match_pv_tags(cling_tag_list_cn, NULL, NULL, 1);
+	return _match_pv_tags(cling_tag_list_cn, NULL, NULL, 1, NULL, NULL);
+}
+
+static const char *_tags_list_str(struct alloc_handle *ah, struct physical_volume *pv1)
+{
+	const char *tags_list_str;
+
+	if (!_match_pv_tags(ah->cling_tag_list_cn, pv1, NULL, 0, ah->mem, &tags_list_str))
+		return_NULL;
+
+	return tags_list_str;
 }
 
 /*
@@ -2056,7 +2115,7 @@ static int _validate_tag_list(const struct dm_config_node *cling_tag_list_cn)
 static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn,
 				  struct physical_volume *pv1, struct physical_volume *pv2)
 {
-	return _match_pv_tags(cling_tag_list_cn, pv1, pv2, 0);
+	return _match_pv_tags(cling_tag_list_cn, pv1, pv2, 0, NULL, NULL);
 }
 
 static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
@@ -2082,12 +2141,21 @@ static void _reserve_area(struct alloc_handle *ah, struct alloc_state *alloc_sta
 			  uint32_t required, uint32_t ix_pva, uint32_t unreserved)
 {
 	struct pv_area_used *area_used = &alloc_state->areas[ix_pva];
+	const char *pv_tag_list = NULL;
+
+	if (ah->cling_tag_list_cn)
+		pv_tag_list = _tags_list_str(ah, pva->map->pv);
 
 	log_debug_alloc("%s allocation area %" PRIu32 " %s %s start PE %" PRIu32
-			" length %" PRIu32 " leaving %" PRIu32 ".",
+			" length %" PRIu32 " leaving %" PRIu32 "%s%s.",
 			area_used->pva ? "Changing   " : "Considering", 
 			ix_pva, area_used->pva ? "to" : "as", 
-			dev_name(pva->map->pv->dev), pva->start, required, unreserved);
+			dev_name(pva->map->pv->dev), pva->start, required, unreserved,
+			pv_tag_list ? " with PV tags: " : "",
+			pv_tag_list ? : "");
+
+	if (pv_tag_list)
+		dm_pool_free(ah->mem, (void *)pv_tag_list);
 
 	area_used->pva = pva;
 	area_used->used = required;


