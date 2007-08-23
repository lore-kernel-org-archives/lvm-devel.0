From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Thu, 23 Aug 2007 15:36:29 -0000
Subject: [PATCH] LVM patch to mirror a mirror log
Message-ID: <20070823153607.GA12382@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds '--mirroredlog' option to lvcreate to create a mirror
with mirrored log device.

Signed-off-by: Jens Wilke (jens.wilke at de.ibm.com)
               Malahal Naineni (malahal at us.ibm.com)


Thanks, Malahal.

diff -r ed2be334a73a tools/args.h
--- a/tools/args.h	Wed Aug 01 13:54:18 2007 -0700
+++ b/tools/args.h	Wed Aug 01 17:30:34 2007 -0700
@@ -52,6 +52,7 @@ arg(config_ARG, '\0', "config", string_a
 arg(config_ARG, '\0', "config", string_arg)
 arg(trustcache_ARG, '\0', "trustcache", NULL)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL)
+arg(mirroredlog_ARG, '\0', "mirroredlog", NULL)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg)
diff -r ed2be334a73a tools/commands.h
--- a/tools/commands.h	Wed Aug 01 13:54:18 2007 -0700
+++ b/tools/commands.h	Tue Aug 07 14:58:20 2007 -0700
@@ -123,7 +123,7 @@ xx(lvcreate,
    "\t{-l|--extents LogicalExtentsNumber |\n"
    "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
-   "\t[-m|--mirrors Mirrors [--nosync] [--corelog]]\n"
+   "\t[-m|--mirrors Mirrors [--nosync] [--corelog] [--mirroredlog]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors]\n"
@@ -159,7 +159,7 @@ xx(lvcreate,
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrors_ARG, name_ARG,
    nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG,
    size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
-   zero_ARG)
+   zero_ARG, mirroredlog_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
diff -r ed2be334a73a tools/lvconvert.c
--- a/tools/lvconvert.c	Wed Aug 01 13:54:18 2007 -0700
+++ b/tools/lvconvert.c	Tue Aug 14 18:34:51 2007 -0700
@@ -237,6 +237,7 @@ static int lvconvert_mirrors(struct cmd_
 	struct list *parallel_areas;
 	struct segment_type *segtype;  /* FIXME: could I just use lp->segtype */
 	float sync_percent;
+	int logextents;
 
 	seg = first_seg(lv);
 	existing_mirrors = seg->area_count;
@@ -368,24 +369,56 @@ static int lvconvert_mirrors(struct cmd_
 			if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
 				return_0;
 
+			logextents = 1;
+			if (!(lp->segtype = get_segtype_from_string(cmd,
+								    "mirror")))
+				return_0;
+
+			log_lv = NULL;
+
+			/* create log on mirror */
+			if (arg_count(cmd, mirroredlog_ARG)) {
+				if (!(ah = allocate_extents(lv->vg, NULL,
+						lp->segtype, 0,
+						lp->mirrors, 0, logextents,
+						NULL, 0, 0, lp->pvh, lp->alloc,
+						NULL))) {
+					stack;
+					return_0;
+				}
+
+				if (!(log_lv = create_mirror_log_mirrored(cmd,
+							lv->vg, ah, lp->alloc,
+							lv->name, 0, &lv->tags,
+							lp->mirrors))) {
+					log_error("Failed to create mirror "
+						  "log.");
+					return_0;
+				}
+				alloc_destroy(ah);
+			}
+
 			if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype,
-						    1, lp->mirrors - 1,
-						    arg_count(cmd, corelog_ARG) ? 0 : 1,
-						    lv->le_count * (lp->mirrors - 1),
-						    NULL, 0, 0, lp->pvh,
-						    lp->alloc,
-						    parallel_areas)))
+					    1, lp->mirrors - 1,
+					    (arg_count(cmd, corelog_ARG) ||
+					     arg_count(cmd, mirroredlog_ARG)) ?
+						     0 : logextents,
+					    lv->le_count * (lp->mirrors - 1),
+					    NULL, 0, 0, lp->pvh,
+					    lp->alloc,
+					    parallel_areas)))
 				return_0;
 
-			lp->region_size = adjusted_mirror_region_size(lv->vg->extent_size,
-								      lv->le_count,
-								      lp->region_size);
-
-			log_lv = NULL;
-			if (!arg_count(cmd, corelog_ARG) &&
+			lp->region_size = adjusted_mirror_region_size(
+						lv->vg->extent_size,
+						lv->le_count,
+						lp->region_size);
+
+			/* create normal (linear) log */
+			if (!log_lv && !arg_count(cmd, corelog_ARG) &&
 			    !(log_lv = create_mirror_log(cmd, lv->vg, ah,
-							 lp->alloc,
-							 lv->name, 0, &lv->tags))) {
+						 lp->alloc,
+						 lv->name, 0, &lv->tags))) {
 				log_error("Failed to create mirror log.");
 				return 0;
 			}
diff -r ed2be334a73a tools/lvcreate.c
--- a/tools/lvcreate.c	Wed Aug 01 13:54:18 2007 -0700
+++ b/tools/lvcreate.c	Tue Aug 14 18:22:31 2007 -0700
@@ -37,6 +37,7 @@ struct lvcreate_params {
 	uint32_t region_size;
 
 	uint32_t mirrors;
+	uint32_t mirroredlog;
 
 	const struct segment_type *segtype;
 
@@ -286,6 +287,9 @@ static int _read_mirror_params(struct lv
 
 	lp->corelog = arg_count(cmd, corelog_ARG) ? 1 : 0;
 	lp->nosync = arg_count(cmd, nosync_ARG) ? 1 : 0;
+
+	if (arg_count(cmd, mirroredlog_ARG))
+		lp->mirroredlog = 1;
 
 	return 1;
 }
@@ -479,6 +483,7 @@ static int _lvcreate(struct cmd_context 
 	struct list *pvh, tags;
 	const char *tag = NULL;
 	int consistent = 1, origin_active = 0;
+	int logextents = 1;
 	struct alloc_handle *ah = NULL;
 	char lv_name_buf[128];
 	const char *lv_name;
@@ -684,20 +689,6 @@ static int _lvcreate(struct cmd_context 
 	}
 
 	if (lp->mirrors > 1) {
-		/* FIXME Calculate how many extents needed for the log */
-
-		if (!(ah = allocate_extents(vg, NULL, lp->segtype, lp->stripes,
-					    lp->mirrors, lp->corelog ? 0 : 1,
-					    lp->extents, NULL, 0, 0,
-					    pvh, lp->alloc, NULL))) {
-			stack;
-			return 0;
-		}
-
-		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
-							      lp->extents,
-							      lp->region_size);
-
 		init_mirror_in_sync(lp->nosync);
 
 		if (lp->nosync) {
@@ -706,16 +697,66 @@ static int _lvcreate(struct cmd_context 
 			status |= MIRROR_NOTSYNCED;
 		}
 
+		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
+							      lp->extents,
+							      lp->region_size);
+
+
+
 		list_init(&tags);
 		if (tag)
 			str_list_add(cmd->mem, &tags, tag);
 
-		if (!lp->corelog &&
-		    !(log_lv = create_mirror_log(cmd, vg, ah, lp->alloc,
-						 lv_name, lp->nosync, &tags))) {
-			log_error("Failed to create mirror log.");
-			return 0;
-		}
+		if (!lp->mirroredlog) {
+			/* FIXME allocates always one extent for log  */
+			if (!(ah = allocate_extents(vg, NULL, lp->segtype,
+						    lp->stripes, lp->mirrors,
+						    logextents, lp->extents,
+						    NULL, 0, 0, pvh, lp->alloc,
+						    NULL))) {
+				stack;
+				return 0;
+			}
+
+			if (!lp->corelog &&
+			    !(log_lv = create_mirror_log(cmd, vg, ah, lp->alloc,
+							 lv_name, lp->nosync,
+							 &tags))) {
+				log_error("Failed to create mirror log.");
+				return 0;
+			}
+		} else {
+			if (!(ah = allocate_extents(vg, NULL, lp->segtype,
+						    lp->stripes,
+						    lp->mirrors, 0, logextents,
+						    NULL, 0, 0, pvh, lp->alloc,
+						    NULL))) {
+				stack;
+				return 0;
+			}
+
+			if (!lp->corelog &&
+			    !(log_lv = create_mirror_log_mirrored(cmd, vg, ah,
+						lp->alloc, lv_name, lp->nosync,
+						&tags, lp->mirrors))) {
+				log_error("Failed to create mirror log.");
+				return 0;
+			}
+
+			/* new allocation for data extents */
+			alloc_destroy(ah);
+
+			if (!(ah = allocate_extents(vg, NULL, lp->segtype,
+						    lp->stripes,
+						    lp->mirrors, 0, lp->extents,
+						    NULL, 0, 0, pvh, lp->alloc,
+						    NULL))) {
+				stack;
+				goto error;
+			}
+
+		}
+
 	}
 
 	if (!(lv = lv_create_empty(vg->fid, lv_name ? lv_name : "lvol%d", NULL,
diff -r ed2be334a73a tools/toollib.c
--- a/tools/toollib.c	Wed Aug 01 13:54:18 2007 -0700
+++ b/tools/toollib.c	Tue Aug 14 18:26:21 2007 -0700
@@ -1328,36 +1328,97 @@ struct logical_volume *create_mirror_log
 					 struct list *tags)
 {
 	struct logical_volume *log_lv;
+
+	if (!(log_lv = create_mirror_log_create_lv(vg, alloc, lv_name))) {
+		stack;
+		return  NULL;
+	}
+
+	if (!lv_add_log_segment(ah, log_lv)) {
+		stack;
+		return NULL;
+	}
+
+	if (!activate_new_mirror_log(cmd, log_lv, in_sync, tags)) {
+		stack;
+		return NULL;
+	}
+
+	return log_lv;
+}
+
+struct logical_volume *create_mirror_log_mirrored(struct cmd_context *cmd,
+					 struct volume_group *vg,
+					 struct alloc_handle *ah,
+					 alloc_policy_t alloc,
+					 const char *lv_name,
+					 int in_sync,
+					 struct list *tags,
+					 int mirrors)
+{
+	struct logical_volume *log_lv;
+	struct segment_type *segtype;
+
+	if (!(log_lv = create_mirror_log_create_lv(vg, alloc, lv_name))) {
+		stack;
+		return NULL;
+	}
+
+	segtype = get_segtype_from_string(cmd, "mirror");
+	if (!create_mirror_layers(ah, 0, mirrors, log_lv,
+				  segtype, 0,
+				  DEFAULT_MIRROR_REGION_SIZE,
+				  NULL)) {
+		stack;
+		return NULL;
+	}
+
+	if (!activate_new_mirror_log(cmd, log_lv, in_sync, tags)) {
+		stack;
+		return NULL;
+	}
+
+	return log_lv;
+}
+
+struct logical_volume *create_mirror_log_create_lv(
+					 struct volume_group *vg,
+					 alloc_policy_t alloc,
+					 const char *lv_name)
+{
+	struct logical_volume *log_lv;
 	char *log_name;
 	size_t len;
-	struct str_list *sl;
 
 	len = strlen(lv_name) + 32;
 	if (!(log_name = alloca(len)) ||
 	    !(generate_log_name_format(vg, lv_name, log_name, len))) {
 		log_error("log_name allocation failed. "
 			  "Remove new LV and retry.");
+		stack;
 		return NULL;
 	}
 
 	if (!(log_lv = lv_create_empty(vg->fid, log_name, NULL,
 				       VISIBLE_LV | LVM_READ | LVM_WRITE,
 				       alloc, 0, vg))) {
+		log_error("lv_create_empty failed.");
 		stack;
 		return NULL;
 	}
-
-	if (!lv_add_log_segment(ah, log_lv)) {
-		stack;
-		goto error;
-	}
-
-	/* Temporary tag mirror log */
-	list_iterate_items(sl, tags)
-		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
-			log_error("Aborting. Unable to tag mirror log.");
-			goto error;
-		}
+	return log_lv;
+}
+
+int activate_new_mirror_log(struct cmd_context *cmd,
+			    struct logical_volume *log_lv, int in_sync,
+			    struct list *tags)
+{
+	struct volume_group *vg = log_lv->vg;
+
+	/* FIXME: if I see it correctly we only have to commit our
+	 * changes now to activate the log_lv and zero it out
+	 * maybe we should do this directly?! ;jw
+	 */
 
 	/* store mirror log on disk(s) */
 	if (!vg_write(vg)) {
@@ -1383,11 +1444,6 @@ struct logical_volume *create_mirror_log
 			  "Remove new LVs and retry.");
 		goto error;
 	}
-
-	list_iterate_items(sl, tags)
-		if (!str_list_del(&log_lv->tags, sl->str))
-			log_error("Failed to remove tag %s from mirror log.",
-				  sl->str);
 
 	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
 				    in_sync ? -1 : 0)) {
@@ -1410,8 +1466,8 @@ struct logical_volume *create_mirror_log
 
 	log_lv->status &= ~VISIBLE_LV;
 
-	return log_lv;
+	return 1;
 error:
 	/* FIXME Attempt to clean up. */
-	return NULL;
-}
+	return 0;
+}
diff -r ed2be334a73a tools/toollib.h
--- a/tools/toollib.h	Wed Aug 01 13:54:18 2007 -0700
+++ b/tools/toollib.h	Wed Aug 01 18:34:24 2007 -0700
@@ -95,6 +95,15 @@ int generate_log_name_format(struct volu
 int generate_log_name_format(struct volume_group *vg, const char *lv_name,
                              char *buffer, size_t size);
 
+struct logical_volume *create_mirror_log_create_lv(
+					 struct volume_group *vg,
+					 alloc_policy_t alloc,
+					 const char *lv_name);
+
+int activate_new_mirror_log(struct cmd_context *cmd,
+			    struct logical_volume *log_lv, int in_sync,
+			    struct list *tags);
+
 struct logical_volume *create_mirror_log(struct cmd_context *cmd,
 					 struct volume_group *vg,
 					 struct alloc_handle *ah,
@@ -103,6 +112,15 @@ struct logical_volume *create_mirror_log
 					 int in_sync,
 					 struct list *tags);
 
+struct logical_volume *create_mirror_log_mirrored(struct cmd_context *cmd,
+					 struct volume_group *vg,
+					 struct alloc_handle *ah,
+					 alloc_policy_t alloc,
+					 const char *lv_name,
+					 int in_sync,
+					 struct list *tags,
+					 int mirrors);
+
 int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	   uint64_t sectors, int value);
 


