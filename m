From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 06:19:04 -0400
Subject: master - tidy: else after continue
Message-ID: <201707201019.v6KAJ4lH016503@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4ef6cfc882fd89ee23a12be11d631b691f7e8ddf
Commit:        4ef6cfc882fd89ee23a12be11d631b691f7e8ddf
Parent:        0bf836aa14f98eb83969a6e81695a024f56a5eb5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 19 23:12:48 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 11:18:29 2017 +0200

tidy: else after continue

Similar as with 'else' after 'return'  unindent whole block
for better readability of code.
---
 lib/activate/activate.c      |    8 ++--
 lib/format1/import-extents.c |   58 +++++++++++++++++------------------
 lib/metadata/lv_manip.c      |   69 +++++++++++++++++++++--------------------
 3 files changed, 67 insertions(+), 68 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1bbd1b5..d00e61e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -150,15 +150,15 @@ static int _lv_passes_volumes_filter(struct cmd_context *cmd, const struct logic
 				    || str_list_match_list(&cmd->tags,
 							   &lv->vg->tags, NULL))
 					    return 1;
-				else
-					continue;
+
+				continue;
 			}
 			/* If supplied tag matches LV or VG tag, activate */
 			if (str_list_match_item(&lv->tags, str) ||
 			    str_list_match_item(&lv->vg->tags, str))
 				return 1;
-			else
-				continue;
+
+			continue;
 		}
 
 		/* If supplied name is vgname[/lvname] */
diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index 4c259c1..c583741 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -134,37 +134,35 @@ static int _fill_maps(struct dm_hash_table *maps, struct volume_group *vg,
 			if (lv_num == UNMAPPED_EXTENT)
 				continue;
 
-			else {
-				lv_num--;
-				lvm = lvms[lv_num];
-
-				if (!lvm) {
-					log_error("Invalid LV in extent map "
-						  "(PV %s, PE %" PRIu32
-						  ", LV %" PRIu32
-						  ", LE %" PRIu32 ")",
-						  dev_name(pv->dev), i,
-						  lv_num, e[i].le_num);
-					return 0;
-				}
-
-				le = e[i].le_num;
-
-				if (le >= lvm->lv->le_count) {
-					log_error("logical extent number "
-						  "out of bounds");
-					return 0;
-				}
-
-				if (lvm->map[le].pv) {
-					log_error("logical extent (%u) "
-						  "already mapped.", le);
-					return 0;
-				}
-
-				lvm->map[le].pv = pv;
-				lvm->map[le].pe = i;
+			lv_num--;
+			lvm = lvms[lv_num];
+
+			if (!lvm) {
+				log_error("Invalid LV in extent map "
+					  "(PV %s, PE %" PRIu32
+					  ", LV %" PRIu32
+					  ", LE %" PRIu32 ")",
+					  dev_name(pv->dev), i,
+					  lv_num, e[i].le_num);
+				return 0;
 			}
+
+			le = e[i].le_num;
+
+			if (le >= lvm->lv->le_count) {
+				log_error("logical extent number "
+					  "out of bounds");
+				return 0;
+			}
+
+			if (lvm->map[le].pv) {
+				log_error("logical extent (%u) "
+					  "already mapped.", le);
+				return 0;
+			}
+
+			lvm->map[le].pv = pv;
+			lvm->map[le].pe = i;
 		}
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5c2e722..1851783 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2155,53 +2155,54 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 				}
 				continue;
 			}
+
 			if (!str_list_match_list(&pv1->tags, tags_to_match, &tag_matched))
 				continue;
-			else {
-				if (!pv_tags) {
-					if (parallel_pv)
-						log_debug_alloc("Not using free space on %s: Matched allocation PV tag %s on existing parallel PV %s.",
-								pv_dev_name(pv1), tag_matched, pv2 ? pv_dev_name(pv2) : "-");
-					else
-						log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
-								tag_matched, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
-				} else
-					log_debug_alloc("Eliminating allocation area %" PRIu32 " at PV %s start PE %" PRIu32
-							" from consideration: PV tag %s already used.",
-							area_num, pv_dev_name(pv1), pv1_start_pe, tag_matched);
-				return 1;
-			}
-		}
 
-		if (!str_list_match_item(&pv1->tags, str) ||
-		    (tags_to_match && !str_list_match_item(tags_to_match, str)))
-			continue;
-		else {
-			if (mem) {
-				if (!first_tag && !dm_pool_grow_object(mem, ",", 0)) {
-					log_error("PV tags string extension failed.");
-					return 0;
-				}
-				first_tag = 0;
-				if (!dm_pool_grow_object(mem, str, 0)) {
-					log_error("PV tags string extension failed.");
-					return 0;
-				}
-				continue;
-			}
 			if (!pv_tags) {
 				if (parallel_pv)
 					log_debug_alloc("Not using free space on %s: Matched allocation PV tag %s on existing parallel PV %s.",
- 							pv2 ? pv_dev_name(pv2) : "-", str, pv_dev_name(pv1));
+							pv_dev_name(pv1), tag_matched, pv2 ? pv_dev_name(pv2) : "-");
 				else
 					log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
-							str, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
+							tag_matched, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
 			} else
 				log_debug_alloc("Eliminating allocation area %" PRIu32 " at PV %s start PE %" PRIu32
 						" from consideration: PV tag %s already used.",
-						area_num, pv_dev_name(pv1), pv1_start_pe, str);
+						area_num, pv_dev_name(pv1), pv1_start_pe, tag_matched);
 			return 1;
 		}
+
+		if (!str_list_match_item(&pv1->tags, str) ||
+		    (tags_to_match && !str_list_match_item(tags_to_match, str)))
+			continue;
+
+		if (mem) {
+			if (!first_tag && !dm_pool_grow_object(mem, ",", 0)) {
+				log_error("PV tags string extension failed.");
+				return 0;
+			}
+			first_tag = 0;
+			if (!dm_pool_grow_object(mem, str, 0)) {
+				log_error("PV tags string extension failed.");
+				return 0;
+			}
+			continue;
+		}
+
+		if (!pv_tags) {
+			if (parallel_pv)
+				log_debug_alloc("Not using free space on %s: Matched allocation PV tag %s on existing parallel PV %s.",
+						pv2 ? pv_dev_name(pv2) : "-", str, pv_dev_name(pv1));
+			else
+				log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
+						str, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
+		} else
+			log_debug_alloc("Eliminating allocation area %" PRIu32 " at PV %s start PE %" PRIu32
+					" from consideration: PV tag %s already used.",
+					area_num, pv_dev_name(pv1), pv1_start_pe, str);
+
+		return 1;
 	}
 
 	if (mem)


