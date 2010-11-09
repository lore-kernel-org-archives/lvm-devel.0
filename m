From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Nov 2010 12:34:53 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/activ ...
Message-ID: <20101109123453.7567.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-09 12:34:44

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/activate   : activate.c 
	lib/datastruct : str_list.c str_list.h 
	lib/display    : display.c 
	lib/metadata   : lv_manip.c metadata.c mirror.c vg.h 
	man            : lvm.conf.5.in 
	tools          : toollib.c 

Log message:
	Extend cling allocation policy to recognise PV tags (cling_by_tags).
	Add allocation/cling_tag_list to lvm.conf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1792&r2=1.1793
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.235&r2=1.236
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.408&r2=1.409
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.210&r2=1.211

--- LVM2/WHATS_NEW	2010/11/09 11:15:34	1.1792
+++ LVM2/WHATS_NEW	2010/11/09 12:34:40	1.1793
@@ -1,5 +1,7 @@
 Version 2.02.77 -
 ===================================
+  Extend cling allocation policy to recognise PV tags (cling_by_tags).
+  Add allocation/cling_tag_list to lvm.conf.
   Regenerate configure with 'autoreconf' for --enable-ocf. (2.02.76)
 
 Version 2.02.76 - 8th November 2010
--- LVM2/doc/example.conf.in	2010/10/25 11:20:55	1.16
+++ LVM2/doc/example.conf.in	2010/11/09 12:34:41	1.17
@@ -146,6 +146,25 @@
     require_restorefile_with_uuid = 1
 }
 
+# This section allows you to configure the way in which LVM selects
+# free space for its Logical Volumes.
+#allocation {
+#    When searching for free space to extend an LV, the "cling"
+#    allocation policy will choose space on the same PVs as the last
+#    segment of the existing LV.  If there is insufficient space and a
+#    list of tags is defined here, it will check whether any of them are
+#    attached to the PVs concerned and then seek to match those PV tags
+#    between existing extents and new extents.
+#    Use the special tag "@*" as a wildcard to match any PV tag.
+#    
+#    Example: LVs are mirrored between two sites within a single VG.
+#    PVs are tagged with either @site1 or @site2 to indicate where
+#    they are situated.
+#
+#    cling_tag_list = [ "@site1", "@site2" ]
+#    cling_tag_list = [ "@*" ]
+#}
+
 # This section that allows you to configure the nature of the
 # information that LVM2 reports.
 log {
--- LVM2/lib/activate/activate.c	2010/11/05 18:18:12	1.179
+++ LVM2/lib/activate/activate.c	2010/11/09 12:34:41	1.180
@@ -275,8 +275,8 @@
 			return 1;
 
 		/* If any host tag matches any LV or VG tag, activate */
-		if (str_list_match_list(&cmd->tags, &lv->tags) ||
-		    str_list_match_list(&cmd->tags, &lv->vg->tags))
+		if (str_list_match_list(&cmd->tags, &lv->tags, NULL) ||
+		    str_list_match_list(&cmd->tags, &lv->vg->tags, NULL))
 			return 1;
 
 		log_verbose("No host tag matches %s/%s",
@@ -314,9 +314,9 @@
 			}
 			/* If any host tag matches any LV or VG tag, activate */
 			if (!strcmp(str, "*")) {
-				if (str_list_match_list(&cmd->tags, &lv->tags)
+				if (str_list_match_list(&cmd->tags, &lv->tags, NULL)
 				    || str_list_match_list(&cmd->tags,
-							   &lv->vg->tags))
+							   &lv->vg->tags, NULL))
 					    return 1;
 				else
 					continue;
--- LVM2/lib/datastruct/str_list.c	2009/07/27 11:00:18	1.12
+++ LVM2/lib/datastruct/str_list.c	2010/11/09 12:34:41	1.13
@@ -93,14 +93,18 @@
 
 /*
  * Is at least one item on both lists?
+ * If tag_matched is non-NULL, it is set to the tag that matched.
  */
-int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2)
+int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, char **tag_matched)
 {
 	struct str_list *sl;
 
 	dm_list_iterate_items(sl, sll)
-	    if (str_list_match_item(sll2, sl->str))
-		return 1;
+		if (str_list_match_item(sll2, sl->str)) {
+			if (tag_matched)
+				*tag_matched = sl->str;
+			return 1;
+		}
 
 	return 0;
 }
--- LVM2/lib/datastruct/str_list.h	2008/11/03 22:14:27	1.9
+++ LVM2/lib/datastruct/str_list.h	2010/11/09 12:34:42	1.10
@@ -20,7 +20,7 @@
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str);
 int str_list_del(struct dm_list *sll, const char *str);
 int str_list_match_item(const struct dm_list *sll, const char *str);
-int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2);
+int str_list_match_list(const struct dm_list *sll, const struct dm_list *sll2, char **tag_matched);
 int str_list_lists_equal(const struct dm_list *sll, const struct dm_list *sll2);
 int str_list_dup(struct dm_pool *mem, struct dm_list *sllnew,
 		 const struct dm_list *sllold);
--- LVM2/lib/display/display.c	2010/10/25 13:54:29	1.113
+++ LVM2/lib/display/display.c	2010/11/09 12:34:42	1.114
@@ -26,12 +26,13 @@
 
 static const struct {
 	alloc_policy_t alloc;
-	const char str[12]; /* must be changed when size extends 11 chars */
+	const char str[14]; /* must be changed when size extends 13 chars */
 	const char repchar;
 } _policies[] = {
 	{
 	ALLOC_CONTIGUOUS, "contiguous", 'c'}, {
 	ALLOC_CLING, "cling", 'l'}, {
+	ALLOC_CLING_BY_TAGS, "cling_by_tags", 't'}, {	/* Only used in log mesgs */
 	ALLOC_NORMAL, "normal", 'n'}, {
 	ALLOC_ANYWHERE, "anywhere", 'a'}, {
 	ALLOC_INHERIT, "inherit", 'i'}
@@ -147,12 +148,16 @@
 {
 	int i;
 
+	/* cling_by_tags is part of cling */
+	if (!strcmp("cling_by_tags", str))
+		return ALLOC_CLING;
+
 	for (i = 0; i < _num_policies; i++)
 		if (!strcmp(_policies[i].str, str))
 			return _policies[i].alloc;
 
 	/* Special case for old metadata */
-	if(!strcmp("next free", str))
+	if (!strcmp("next free", str))
 		return ALLOC_NORMAL;
 
 	log_error("Unrecognised allocation policy %s", str);
--- LVM2/lib/metadata/lv_manip.c	2010/11/05 18:18:12	1.235
+++ LVM2/lib/metadata/lv_manip.c	2010/11/09 12:34:42	1.236
@@ -526,6 +526,8 @@
 	uint32_t region_size;		/* Mirror region size */
 	uint32_t total_area_len;	/* Total number of parallel extents */
 
+	const struct config_node *cling_tag_list_cn;
+
 	struct dm_list *parallel_areas;	/* PVs to avoid */
 
 	/*
@@ -640,6 +642,8 @@
 
 	ah->parallel_areas = parallel_areas;
 
+	ah->cling_tag_list_cn = find_config_tree_node(cmd, "allocation/cling_tag_list");
+
 	return ah;
 }
 
@@ -927,18 +931,19 @@
  * Search for pvseg that matches condition
  */
 struct pv_match {
-	int (*condition)(struct pv_segment *pvseg, struct pv_area *pva);
+	int (*condition)(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva);
 
 	struct pv_area_used *areas;
 	struct pv_area *pva;
 	uint32_t areas_size;
+	const struct config_node *cling_tag_list_cn;
 	int s;	/* Area index of match */
 };
 
 /*
  * Is PV area on the same PV?
  */
-static int _is_same_pv(struct pv_segment *pvseg, struct pv_area *pva)
+static int _is_same_pv(struct pv_match *pvmatch __attribute((unused)), struct pv_segment *pvseg, struct pv_area *pva)
 {
 	if (pvseg->pv != pva->map->pv)
 		return 0;
@@ -947,9 +952,70 @@
 }
 
 /*
+ * Does PV area have a tag listed in allocation/cling_tag_list that 
+ * matches a tag of the PV of the existing segment?
+ */
+static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
+{
+	struct config_value *cv;
+	char *str;
+	char *tag_matched;
+
+	for (cv = pvmatch->cling_tag_list_cn->v; cv; cv = cv->next) {
+		if (cv->type != CFG_STRING) {
+			log_error("Ignoring invalid string in config file entry "
+				  "allocation/cling_tag_list");
+			continue;
+		}
+		str = cv->v.str;
+		if (!*str) {
+			log_error("Ignoring empty string in config file entry "
+				  "allocation/cling_tag_list");
+			continue;
+		}
+
+		if (*str != '@') {
+			log_error("Ignoring string not starting with @ in config file entry "
+				  "allocation/cling_tag_list: %s", str);
+			continue;
+		}
+
+		str++;
+
+		if (!*str) {
+			log_error("Ignoring empty tag in config file entry "
+				  "allocation/cling_tag_list");
+			continue;
+		}
+
+		/* Wildcard matches any tag against any tag. */
+		if (!strcmp(str, "*")) {
+			if (!str_list_match_list(&pvseg->pv->tags, &pva->map->pv->tags, &tag_matched))
+				continue;
+			else {
+				log_debug("Matched allocation PV tag %s on existing %s with free space on %s.",
+					  tag_matched, pv_dev_name(pvseg->pv), pv_dev_name(pva->map->pv));
+				return 1;
+			}
+		}
+
+		if (!str_list_match_item(&pvseg->pv->tags, str) ||
+		    !str_list_match_item(&pva->map->pv->tags, str))
+			continue;
+		else {
+			log_debug("Matched allocation PV tag %s on existing %s with free space on %s.",
+				  str, pv_dev_name(pvseg->pv), pv_dev_name(pva->map->pv));
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
+/*
  * Is PV area contiguous to PV segment?
  */
-static int _is_contiguous(struct pv_segment *pvseg, struct pv_area *pva)
+static int _is_contiguous(struct pv_match *pvmatch __attribute((unused)), struct pv_segment *pvseg, struct pv_area *pva)
 {
 	if (pvseg->pv != pva->map->pv)
 		return 0;
@@ -966,7 +1032,7 @@
 {
 	struct pv_match *pvmatch = data;
 
-	if (!pvmatch->condition(pvseg, pvmatch->pva))
+	if (!pvmatch->condition(pvmatch, pvseg, pvmatch->pva))
 		return 1;	/* Continue */
 
 	if (s >= pvmatch->areas_size)
@@ -991,16 +1057,18 @@
  * Is pva on same PV as any existing areas?
  */
 static int _check_cling(struct cmd_context *cmd,
+			const struct config_node *cling_tag_list_cn,
 			struct lv_segment *prev_lvseg, struct pv_area *pva,
 			struct pv_area_used *areas, uint32_t areas_size)
 {
 	struct pv_match pvmatch;
 	int r;
 
-	pvmatch.condition = _is_same_pv;
+	pvmatch.condition = cling_tag_list_cn ? _has_matching_pv_tag : _is_same_pv;
 	pvmatch.areas = areas;
 	pvmatch.areas_size = areas_size;
 	pvmatch.pva = pva;
+	pvmatch.cling_tag_list_cn = cling_tag_list_cn;
 
 	/* FIXME Cope with stacks by flattening */
 	if (!(r = _for_each_pv(cmd, prev_lvseg->lv,
@@ -1029,6 +1097,7 @@
 	pvmatch.areas = areas;
 	pvmatch.areas_size = areas_size;
 	pvmatch.pva = pva;
+	pvmatch.cling_tag_list_cn = NULL;
 
 	/* FIXME Cope with stacks by flattening */
 	if (!(r = _for_each_pv(cmd, prev_lvseg->lv,
@@ -1056,7 +1125,7 @@
 	struct pv_area *pva;
 	struct pv_list *pvl;
 	unsigned already_found_one = 0;
-	unsigned contiguous = 0, cling = 0, preferred_count = 0;
+	unsigned contiguous = 0, cling = 0, use_cling_tags = 0, preferred_count = 0;
 	unsigned ix, last_ix;
 	unsigned ix_offset = 0;	/* Offset for non-preferred allocations */
 	unsigned ix_log_offset; /* Offset to start of areas to use for log */
@@ -1089,7 +1158,10 @@
 			contiguous = 1;
 		else if ((alloc == ALLOC_CLING))
 			cling = 1;
-		else
+		else if ((alloc == ALLOC_CLING_BY_TAGS)) {
+			cling = 1;
+			use_cling_tags = 1;
+		} else
 			ix_offset = 0;
 	}
 
@@ -1176,9 +1248,10 @@
 					if (cling) {
 						if (prev_lvseg &&
 						    _check_cling(ah->cmd,
-								   prev_lvseg,
-								   pva, *areas_ptr,
-								   *areas_size_ptr)) {
+								 use_cling_tags ? ah->cling_tag_list_cn : NULL,
+								 prev_lvseg,
+								 pva, *areas_ptr,
+								 *areas_size_ptr)) {
 							preferred_count++;
 						}
 						goto next_pv;
@@ -1361,8 +1434,18 @@
 		return 0;
 	}
 
+	/*
+	 * cling includes implicit cling_by_tags
+	 * but it does nothing unless the lvm.conf setting is present.
+	 */
+	if (ah->alloc == ALLOC_CLING)
+		ah->alloc = ALLOC_CLING_BY_TAGS;
+
 	/* Attempt each defined allocation policy in turn */
 	for (alloc = ALLOC_CONTIGUOUS; alloc < ALLOC_INHERIT; alloc++) {
+		/* Skip cling_by_tags if no list defined */
+		if (alloc == ALLOC_CLING_BY_TAGS && !ah->cling_tag_list_cn)
+			continue;
 		old_allocated = allocated;
 		log_debug("Trying allocation using %s policy.  "
 			  "Need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log areas of %" PRIu32 " extents. "
@@ -1829,8 +1912,8 @@
 	/*
 	 * Compose a new name for sub lv:
 	 *   e.g. new name is "lvol1_mlog"
-	 *        if the sub LV is "lvol0_mlog" and
-	 *        a new name for main LV is "lvol1"
+	 *	if the sub LV is "lvol0_mlog" and
+	 *	a new name for main LV is "lvol1"
 	 */
 	len = strlen(lv_name_new) + strlen(suffix) + 1;
 	new_name = dm_pool_alloc(cmd->mem, len);
@@ -2339,7 +2422,7 @@
 		}
 	}
 
-        return lv_remove_single(cmd, lv, force);
+	return lv_remove_single(cmd, lv, force);
 }
 
 /*
--- LVM2/lib/metadata/metadata.c	2010/10/25 13:54:29	1.408
+++ LVM2/lib/metadata/metadata.c	2010/11/09 12:34:42	1.409
@@ -2164,6 +2164,12 @@
 	uint32_t num_snapshots = 0;
 	uint32_t loop_counter1, loop_counter2;
 
+	if (vg->alloc == ALLOC_CLING_BY_TAGS) {
+		log_error(INTERNAL_ERROR "VG %s allocation policy set to invalid cling_by_tags.",
+			  vg->name);
+		r = 0;
+	}
+
 	/* FIXME Also check there's no data/metadata overlap */
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (++pv_count > vg->pv_count) {
@@ -2233,6 +2239,12 @@
 			r = 0;
 		}
 
+		if (lvl->lv->alloc == ALLOC_CLING_BY_TAGS) {
+			log_error(INTERNAL_ERROR "LV %s allocation policy set to invalid cling_by_tags.",
+				  lvl->lv->name);
+			r = 0;
+		}
+
 		if (lvl->lv->status & VISIBLE_LV)
 			continue;
 
--- LVM2/lib/metadata/mirror.c	2010/10/14 20:03:13	1.136
+++ LVM2/lib/metadata/mirror.c	2010/11/09 12:34:43	1.137
@@ -400,7 +400,7 @@
 	struct str_list *sl;
 
 	/* Inherit tags - maybe needed for activation */
-	if (!str_list_match_list(&mirror_lv->tags, &lv->tags)) {
+	if (!str_list_match_list(&mirror_lv->tags, &lv->tags, NULL)) {
 		dm_list_iterate_items(sl, &mirror_lv->tags)
 			if (!str_list_add(cmd->mem, &lv->tags, sl->str)) {
 				log_error("Aborting. Unable to tag.");
--- LVM2/lib/metadata/vg.h	2010/10/25 12:01:59	1.7
+++ LVM2/lib/metadata/vg.h	2010/11/09 12:34:43	1.8
@@ -25,6 +25,7 @@
 	ALLOC_INVALID,
 	ALLOC_CONTIGUOUS,
 	ALLOC_CLING,
+	ALLOC_CLING_BY_TAGS,	/* Internal - never written or displayed. */
 	ALLOC_NORMAL,
 	ALLOC_ANYWHERE,
 	ALLOC_INHERIT
--- LVM2/man/lvm.conf.5.in	2010/10/15 16:24:01	1.15
+++ LVM2/man/lvm.conf.5.in	2010/11/09 12:34:43	1.16
@@ -172,6 +172,28 @@
 the respective operation. Setting the parameter to 0 disables the counters
 altogether.
 .TP
+\fBallocation\fP \(em Space allocation policies
+.IP
+\fBcling_tag_list\fP \(em List of PV tags matched by the \fBcling\fP allocation policy.
+.IP
+When searching for free space to extend an LV, the \fBcling\fP
+allocation policy will choose space on the same PVs as the last
+segment of the existing LV.  If there is insufficient space and a
+list of tags is defined here, it will check whether any of them are
+attached to the PVs concerned and then seek to match those PV tags
+between existing extents and new extents.
+.IP 
+The @ prefix for tags is required.
+Use the special tag "@*" as a wildcard to match any PV tag and so use 
+all PV tags for this purpose.
+.IP
+For example, LVs are mirrored between two sites within a single VG.
+PVs are tagged with either @site1 or @site2 to indicate where
+they are situated and these two PV tags are selected for use with this
+allocation policy:
+.IP
+cling_tag_list = [ "@site1", "@site2" ]
+.TP
 \fBlog\fP \(em Default log settings
 .IP
 \fBfile\fP \(em Location of log file.  If this entry is not present, no
--- LVM2/tools/toollib.c	2010/10/25 12:08:15	1.210
+++ LVM2/tools/toollib.c	2010/11/09 12:34:43	1.211
@@ -115,7 +115,7 @@
 
 	/* Or if VG tags match */
 	if (!process_lv && tags_supplied &&
-	    str_list_match_list(tags, &vg->tags)) {
+	    str_list_match_list(tags, &vg->tags, NULL)) {
 		process_all = 1;
 	}
 
@@ -141,7 +141,7 @@
 
 		/* LV tag match? */
 		if (!process_lv && tags_supplied &&
-		    str_list_match_list(tags, &lvl->lv->tags)) {
+		    str_list_match_list(tags, &lvl->lv->tags, NULL)) {
 			process_lv = 1;
 		}
 
@@ -487,7 +487,7 @@
 		if (!dm_list_empty(tags) &&
 		    /* Only process if a tag matches or it's on arg_vgnames */
 		    !str_list_match_item(arg_vgnames, vg_name) &&
-		    !str_list_match_list(tags, &cvl_vg->vg->tags))
+		    !str_list_match_list(tags, &cvl_vg->vg->tags, NULL))
 			break;
 
 		ret = process_single_vg(cmd, vg_name, cvl_vg->vg, handle);
@@ -606,7 +606,7 @@
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (tags && !dm_list_empty(tags) &&
-		    !str_list_match_list(tags, &pvl->pv->tags)) {
+		    !str_list_match_list(tags, &pvl->pv->tags, NULL)) {
 			continue;
 		}
 		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)


