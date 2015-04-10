From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 10 Apr 2015 21:01:33 +0000 (UTC)
Subject: master - alloc: Add A_PARTITION_BY_TAGS to avoid sharing.
Message-ID: <20150410210133.D3A9460CD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2872e8c289a04e60e59494b41336ae9e9eb6021e
Commit:        2872e8c289a04e60e59494b41336ae9e9eb6021e
Parent:        0523c718446a13472d9bec8bce61e7ec020d0179
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 10 21:57:52 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 10 21:57:52 2015 +0100

alloc: Add A_PARTITION_BY_TAGS to avoid sharing.

Add A_PARTITION_BY_TAGS set when allocated areas should not share tags
with each other and allow _match_pv_tags to accept an alternative list
of tags.  (Not used yet.)
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   44 ++++++++++++++++++++++++++++++--------------
 2 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1870801..164fe5a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Add A_PARTITION_BY_TAGS set when allocated areas should not share tags.
   Set correct vgid when updating cache when writing PV metadata.
   More efficient clvmd singlenode locking emulation.
   Don't skip invalidation of cached orphans if vg write lck is held (2.02.118).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 11a46e1..ef69e0e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -52,6 +52,7 @@ typedef enum {
 #define A_AREA_COUNT_MATCHES	0x20	/* Existing lvseg has same number of areas as new segment */
 
 #define A_POSITIONAL_FILL	0x40	/* Slots are positional and filled using PREFERRED */
+#define A_PARTITION_BY_TAGS	0x80	/* No allocated area may share any tag with any other */
 
 /*
  * Constant parameters during a single allocation attempt.
@@ -1629,6 +1630,11 @@ static void _init_alloc_parms(struct alloc_handle *ah,
 	if (alloc_parms->alloc == ALLOC_CLING_BY_TAGS)
 		alloc_parms->flags |= A_CLING_BY_TAGS;
 
+	if (!(alloc_parms->alloc & A_POSITIONAL_FILL) &&
+	    (alloc_parms->alloc == ALLOC_CONTIGUOUS) &&
+	    ah->cling_tag_list_cn)
+		alloc_parms->flags |= A_PARTITION_BY_TAGS;
+
 	/*
 	 * For normal allocations, if any extents have already been found 
 	 * for allocation, prefer to place further extents on the same disks as
@@ -1975,18 +1981,18 @@ static int _is_same_pv(struct pv_match *pvmatch __attribute((unused)), struct pv
 
 /*
  * Does PV area have a tag listed in allocation/cling_tag_list that 
- * matches a tag of the PV of the existing segment?
+ * matches EITHER a tag of the PV of the existing segment OR a tag in pv_tags?
  * If tags_list_str is set, then instead we generate a list of matching tags for printing.
  */
 static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
-			  struct physical_volume *pv1,
-			  struct physical_volume *pv2,
-			  unsigned validate_only, 
+			  struct physical_volume *pv1, uint32_t pv1_start_pe, uint32_t area_num,
+			  struct physical_volume *pv2, struct dm_list *pv_tags, unsigned validate_only,
 			  struct dm_pool *mem, const char **tags_list_str)
 {
 	const struct dm_config_value *cv;
 	const char *str;
 	const char *tag_matched;
+	struct dm_list *tags_to_match = tags_list_str ? NULL : pv_tags ? : &pv2->tags;
 	struct dm_str_list *sl;
 	unsigned first_tag = 1;
 
@@ -2047,17 +2053,22 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 				}
 				continue;
 			}
-			if (!str_list_match_list(&pv1->tags, &pv2->tags, &tag_matched))
+			if (!str_list_match_list(&pv1->tags, tags_to_match, &tag_matched))
 				continue;
 			else {
-				log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
-						tag_matched, pv_dev_name(pv1), pv_dev_name(pv2));
+				if (!pv_tags)
+					log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
+							tag_matched, pv_dev_name(pv1), pv_dev_name(pv2));
+				else
+					log_debug_alloc("Eliminating allocation area %" PRIu32 " at PV %s start PE %" PRIu32
+							" from consideration: PV tag %s already used.",
+							area_num, pv_dev_name(pv1), pv1_start_pe, tag_matched);
 				return 1;
 			}
 		}
 
 		if (!str_list_match_item(&pv1->tags, str) ||
-		    (pv2 && !str_list_match_item(&pv2->tags, str)))
+		    (tags_to_match && !str_list_match_item(tags_to_match, str)))
 			continue;
 		else {
 			if (tags_list_str) {
@@ -2074,8 +2085,13 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 				}
 				continue;
 			}
-			log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
-					str, pv_dev_name(pv1), pv_dev_name(pv2));
+			if (!pv_tags)
+				log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
+						str, pv_dev_name(pv1), pv_dev_name(pv2));
+			else
+				log_debug_alloc("Eliminating allocation area %" PRIu32 " at PV %s start PE %" PRIu32
+						" from consideration: PV tag %s already used.",
+						area_num, pv_dev_name(pv1), pv1_start_pe, str);
 			return 1;
 		}
 	}
@@ -2095,14 +2111,14 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 
 static int _validate_tag_list(const struct dm_config_node *cling_tag_list_cn)
 {
-	return _match_pv_tags(cling_tag_list_cn, NULL, NULL, 1, NULL, NULL);
+	return _match_pv_tags(cling_tag_list_cn, NULL, 0, 0, NULL, NULL, 1, NULL, NULL);
 }
 
 static const char *_tags_list_str(struct alloc_handle *ah, struct physical_volume *pv1)
 {
 	const char *tags_list_str;
 
-	if (!_match_pv_tags(ah->cling_tag_list_cn, pv1, NULL, 0, ah->mem, &tags_list_str))
+	if (!_match_pv_tags(ah->cling_tag_list_cn, pv1, 0, 0, NULL, NULL, 0, ah->mem, &tags_list_str))
 		return_NULL;
 
 	return tags_list_str;
@@ -2115,7 +2131,7 @@ static const char *_tags_list_str(struct alloc_handle *ah, struct physical_volum
 static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn,
 				  struct physical_volume *pv1, struct physical_volume *pv2)
 {
-	return _match_pv_tags(cling_tag_list_cn, pv1, pv2, 0, NULL, NULL);
+	return _match_pv_tags(cling_tag_list_cn, pv1, 0, 0, pv2, NULL, 0, NULL, NULL);
 }
 
 static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
@@ -2673,7 +2689,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 		      _comp_area);
 	}
 
-	/* If there are gaps in our preferred areas, fill then from the sorted part of the array */
+	/* If there are gaps in our preferred areas, fill them from the sorted part of the array */
 	if (preferred_count && preferred_count != ix_offset) {
 		for (s = 0; s < devices_needed; s++)
 			if (!alloc_state->areas[s].pva) {


