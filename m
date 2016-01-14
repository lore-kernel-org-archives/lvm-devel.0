From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:29 +0000 (UTC)
Subject: master - cleanup: spaces
Message-ID: <20160114103529.3250B60DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9a813bff8828e379f9be963a49a9201a3484ec6
Commit:        c9a813bff8828e379f9be963a49a9201a3484ec6
Parent:        7d2b7f2bd8c318ed65097d4cb7141b3035e43e2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 11 14:11:37 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:05 2016 +0100

cleanup: spaces

---
 lib/metadata/lv_manip.c |   46 +++++++++++++++++++++++-----------------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 99f3661..ca9e0a1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1666,7 +1666,7 @@ static void _init_alloc_parms(struct alloc_handle *ah,
 		alloc_parms->flags |= A_PARTITION_BY_TAGS;
 
 	/*
-	 * For normal allocations, if any extents have already been found 
+	 * For normal allocations, if any extents have already been found
 	 * for allocation, prefer to place further extents on the same disks as
 	 * have already been used.
 	 */
@@ -2010,7 +2010,7 @@ static int _is_same_pv(struct pv_match *pvmatch __attribute((unused)), struct pv
 }
 
 /*
- * Does PV area have a tag listed in allocation/cling_tag_list that 
+ * Does PV area have a tag listed in allocation/cling_tag_list that
  * matches EITHER a tag of the PV of the existing segment OR a tag in pv_tags?
  * If tags_list_str is set, then instead we generate a list of matching tags for printing.
  */
@@ -2166,7 +2166,7 @@ static int _pv_has_matching_tag(const struct dm_config_node *cling_tag_list_cn,
 }
 
 /*
- * Does PV area have a tag listed in allocation/cling_tag_list that 
+ * Does PV area have a tag listed in allocation/cling_tag_list that
  * matches a tag of the PV of the existing segment?
  */
 static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn,
@@ -2205,8 +2205,8 @@ static void _reserve_area(struct alloc_handle *ah, struct alloc_state *alloc_sta
 
 	log_debug_alloc("%s allocation area %" PRIu32 " %s %s start PE %" PRIu32
 			" length %" PRIu32 " leaving %" PRIu32 "%s%s.",
-			area_used->pva ? "Changing   " : "Considering", 
-			ix_pva, area_used->pva ? "to" : "as", 
+			area_used->pva ? "Changing   " : "Considering",
+			ix_pva, area_used->pva ? "to" : "as",
 			dev_name(pva->map->pv->dev), pva->start, required, unreserved,
 			pv_tag_list ? " with PV tags: " : "",
 			pv_tag_list ? : "");
@@ -2468,7 +2468,7 @@ static uint32_t _calc_required_extents(struct alloc_handle *ah, struct pv_area *
 	uint32_t required = max_to_allocate / ah->area_multiple;
 
 	/*
-	 * Update amount unreserved - effectively splitting an area 
+	 * Update amount unreserved - effectively splitting an area
 	 * into two or more parts.  If the whole stripe doesn't fit,
 	 * reduce amount we're looking for.
 	 */
@@ -2669,7 +2669,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 					goto next_pv;
 
 				/*
-				 * Avoid PVs already set aside for log.  
+				 * Avoid PVs already set aside for log.
 				 * We only reach here if there were enough PVs for the main areas but
 				 * not enough for the logs.
 				 */
@@ -2697,7 +2697,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 				 *
 				 * USE_AREA are stored for later, then sorted and chosen from.
 				 */
-				switch(_check_pva(ah, pva, max_to_allocate, 
+				switch(_check_pva(ah, pva, max_to_allocate,
 						  alloc_state, already_found_one, iteration_count, log_iteration_count)) {
 
 				case PREFERRED:
@@ -2802,7 +2802,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 		return 1;
 
 	/*
-	 * FIXME We should change the code to do separate calls for the log allocation 
+	 * FIXME We should change the code to do separate calls for the log allocation
 	 * and the data allocation so that _limit_to_one_area_per_tag doesn't have to guess
 	 * where the split is going to occur.
 	 */
@@ -2853,7 +2853,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 }
 
 /*
- * Choose sets of parallel areas to use, respecting any constraints 
+ * Choose sets of parallel areas to use, respecting any constraints
  * supplied in alloc_parms.
  */
 static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, struct alloc_parms *alloc_parms,
@@ -4600,7 +4600,7 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 	return 1;
 }
 
-static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv, 
+static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvresize_params *lp)
 {
 	struct volume_group *vg = lv->vg;
@@ -4674,7 +4674,7 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 	return 1;
 }
 
-static int _lvresize_adjust_size(struct cmd_context *cmd, struct logical_volume *lv, 
+static int _lvresize_adjust_size(struct cmd_context *cmd, struct logical_volume *lv,
 				 struct lvresize_params *lp)
 {
 	struct volume_group *vg = lv->vg;
@@ -4845,7 +4845,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 
 	/* Initial decision on whether we are extending or reducing */
 	if (lp->sign == SIGN_MINUS ||
-	    (lp->sign == SIGN_NONE && 
+	    (lp->sign == SIGN_NONE &&
 	     ((lp->extents_are_pes && lp->extents < existing_physical_extents) ||
 	      (!lp->extents_are_pes && lp->extents < existing_logical_extents))))
 		reducing = 1;
@@ -4886,10 +4886,10 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 				    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
 				    !seg_is_raid10(seg))
 					continue;
-	
+
 				sz = seg->stripe_size;
 				str = seg->area_count - lp->segtype->parity_devs;
-	
+
 				if ((seg_stripesize && seg_stripesize != sz &&
 				     sz && !lp->stripe_size) ||
 				    (seg_stripes && seg_stripes != str && !lp->stripes)) {
@@ -4897,11 +4897,11 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 						  "stripes (-i) and stripesize (-I)");
 					return 0;
 				}
-	
+
 				seg_stripesize = sz;
 				seg_stripes = str;
 			}
-	
+
 			if (!lp->stripes)
 				lp->stripes = seg_stripes;
 			else if (seg_is_raid(first_seg(lv)) &&
@@ -4910,7 +4910,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 					  lvseg_name(first_seg(lv)));
 				return 0;
 			}
-	
+
 			if (!lp->stripe_size && lp->stripes > 1) {
 				if (seg_stripesize) {
 					log_print_unless_silent("Using stripesize of last segment %s",
@@ -5022,7 +5022,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 				}
 			}
 		}
-	} 
+	}
 
 	/* At this point, lp->extents should hold the correct NEW logical size required. */
 
@@ -5259,7 +5259,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 	return lock_lv;
 }
 
-int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv, 
+int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct lvresize_params *lp, struct dm_list *pvh)
 {
 	if (!_lvresize_check_lv(cmd, lv, lp))
@@ -5291,7 +5291,7 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 }
 
 /* lv_resize_prepare MUST be called before this */
-int lv_resize(struct cmd_context *cmd, struct logical_volume *lv, 
+int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	      struct lvresize_params *lp, struct dm_list *pvh)
 {
 	struct volume_group *vg = lv->vg;
@@ -5479,13 +5479,13 @@ struct logical_volume *lv_create_empty(const char *name,
 
 	if (!lv_set_creation(lv, NULL, 0))
 		goto_bad;
- 
+
 	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv))
 		goto_bad;
 
 	if (vg->fid->fmt->features & FMT_CONFIG_PROFILE)
 		lv->profile = vg->cmd->profile_params->global_metadata_profile;
- 
+
 	return lv;
 bad:
 	dm_pool_free(vg->vgmem, lv);


