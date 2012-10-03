From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:58 +0000 (UTC)
Subject: master - thin: lvconvert
Message-ID: <20121003131458.4268FF7A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a27650cc983d54767316998e1df472325d169617
Commit:        a27650cc983d54767316998e1df472325d169617
Parent:        e9f83147d5da3120604c67354b4d6f027ac10ed0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 14 13:57:30 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 15:13:33 2012 +0200

thin: lvconvert

Update code for lvconvert.
Change the lvconvert user interface a bit - now we require 2 specifiers
--thinpool   takes LV name for data device (and makes the name)
--poolmetadata  takes LV name for metadata device.

Fix type in thin help text -z -> -Z.

Supported is also new flag --discards for thinpools.
---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |   10 +--
 tools/args.h       |    1 +
 tools/commands.h   |    7 +-
 tools/lvconvert.c  |  176 ++++++++++++++++++++++++++++++++-------------------
 5 files changed, 119 insertions(+), 76 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0927c49..cd325b9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Update lvconvert to support stacking of devs for thin meta/data devs.
   Support changes of permissions for thin snapshot volumes.
   Enhance insert_layer_for_lv() with recursive rename for _tdata LVs.
   Skip building dm tree for thin pool when called with origin_only flag.
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 2a47da8..2659719 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -63,16 +63,12 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .IR ThinPoolLogicalVolume { Name | Path }
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize ]
-.RB [[ \-\-poolmetadatasize
-.IR MetadataSize [ bBsSkKmMgG ]
-.RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]]
-|
-.IR ThinMetadataLogicalVolume { Name | Path }]
-.RB [ \-Z | \-\-zero
-.RI { y | n }]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
+.RB [ \-Z | \-\-zero
+.RI { y | n }]
+.IR ThinMetadataLogicalVolume { Name | Path }
 .sp
 .B lvconvert \-\-repair
 .RB [ \-h | \-? | \-\-help ]
diff --git a/tools/args.h b/tools/args.h
index d436db4..0d9605a 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -70,6 +70,7 @@ arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
+arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
 arg(discards_ARG, '\0', "discards", discards_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 602fe81..6415d34 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -146,15 +146,16 @@ xx(lvconvert,
    "lvconvert "
    "--thinpool ThinPoolLogicalVolume[Path]\n"
    "\t[--chunksize size]\n"
-   "\t[[--poolmetadatasize size] | ThinMetadataLogicalVolume[Path]]\n"
-   "\t[-z|--zero {y|n}]\n"
+   "\t[--discards {ignore|nopassdown|passdown}]\n"
+   "\t[[--poolmetadatasize size] | --poolmetadata ThinMetadataLogicalVolume[Path]]\n"
+   "\t[-Z|--zero {y|n}]\n"
    "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
    merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
    regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
    trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
-   chunksize_ARG, poolmetadatasize_ARG, thinpool_ARG,
+   chunksize_ARG, discards_ARG, poolmetadata_ARG, poolmetadatasize_ARG, thinpool_ARG,
    use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7b284f0..41bc585 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -54,9 +54,10 @@ struct lvconvert_params {
 
 	struct logical_volume *lv_to_poll;
 
-	uint64_t poolmetadata_size; /* thin pool */
+	uint64_t poolmetadata_size;
 	const char *pool_data_lv_name;
-	/* pool_metadata_lv_name is lv_name */
+	const char *pool_metadata_lv_name;
+	thin_discards_t discards;
 };
 
 static int _lvconvert_name_params(struct lvconvert_params *lp,
@@ -125,7 +126,10 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	if ((ptr = strrchr(lp->lv_name_full, '/')))
 		lp->lv_name = ptr + 1;
 
-	if (!lp->merge_mirror && !apply_lvname_restrictions(lp->lv_name))
+	if (!lp->merge_mirror &&
+	    !strstr(lp->lv_name, "_tdata") &&
+	    !strstr(lp->lv_name, "_tmeta") &&
+	    !apply_lvname_restrictions(lp->lv_name))
 		return_0;
 
 	if (*pargc && lp->snapshot) {
@@ -198,6 +202,10 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			log_error("--thinpool and --splitmirrors are mutually exlusive.");
 			return 0;
 		}
+		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
+	} else if (arg_count(cmd, discards_ARG)) {
+		log_error("--discards is only valid with --thinpool.");
+		return 0;
 	}
 
 	/*
@@ -327,7 +335,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (arg_count(cmd, poolmetadatasize_ARG)) {
+		if (arg_count(cmd, poolmetadata_ARG)) {
+			lp->pool_metadata_lv_name = arg_str_value(cmd, poolmetadata_ARG, "");
+		} else if (arg_count(cmd, poolmetadatasize_ARG)) {
 			if (arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
 				log_error("Negative pool metadata size is invalid.");
 				return 0;
@@ -365,6 +375,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			}
 		} else
 			lp->chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+
 		log_verbose("Setting pool metadata chunk size to %u sectors.",
 			    lp->chunk_size);
 
@@ -385,12 +396,12 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	} else { /* Mirrors (and some RAID functions) */
 		if (arg_count(cmd, chunksize_ARG)) {
 			log_error("--chunksize is only available with "
-				  "snapshots");
+				  "snapshots or thin pools.");
 			return 0;
 		}
 
 		if (arg_count(cmd, zero_ARG)) {
-			log_error("--zero is only available with snapshots");
+			log_error("--zero is only available with snapshots or thin pools.");
 			return 0;
 		}
 
@@ -1796,68 +1807,109 @@ out:
 	return r;
 }
 
+/*
+ * Thin lvconvert version which
+ *  rename metadata
+ *  convert/layers thinpool over data
+ *  attach metadata
+ */
 static int _lvconvert_thinpool(struct cmd_context *cmd,
-			       struct logical_volume *metadata_lv,
+			       struct logical_volume *pool_lv,
 			       struct lvconvert_params *lp)
 {
 	int r = 0;
 	char *name;
 	int len;
-	int was_active;
 	struct lv_segment *seg;
 	struct logical_volume *data_lv;
-	struct logical_volume *pool_lv =
-		(lp->pool_data_lv_name == lp->lv_name) ?
-		metadata_lv : find_lv(metadata_lv->vg,
-				      lp->pool_data_lv_name);
+	struct logical_volume *metadata_lv;
+
+	if (lv_is_thin_type(pool_lv)) {
+		log_error("Can't use thin logical volume %s/%s for thin pool data.",
+			  pool_lv->vg->name, pool_lv->name);
+		return 0;
+	}
 
-	if (!pool_lv) {
-		log_error("Can't find pool logical volume %s.", lp->lv_name);
+	/* We are changing target type, so deactivate first */
+	if (!deactivate_lv(cmd, pool_lv)) {
+		log_error("Can't deactivate logical volume %s/%s.",
+			  pool_lv->vg->name, pool_lv->name);
 		return 0;
 	}
 
-	if ((pool_lv != metadata_lv)) {
-		if (!lv_is_visible(metadata_lv)) {
-			log_error("Can't use hidden logical volume %s/%s for thin pool metadata.",
-				  metadata_lv->vg->name, metadata_lv->name);
-			goto out;
+	if (lp->pool_metadata_lv_name) {
+		metadata_lv = find_lv(pool_lv->vg, lp->pool_metadata_lv_name);
+		if (!metadata_lv) {
+			log_error("Unknown metadata LV %s", lp->pool_metadata_lv_name);
+			return 0;
 		}
-		if (lv_is_thin_pool(metadata_lv)) {
-			log_error("Can't use thin pool logical volume %s/%s for thin pool metadata.",
-				  metadata_lv->vg->name, metadata_lv->name);
-			goto out;
+		if (metadata_lv == pool_lv) {
+			log_error("Can't use same LV for thin data and metadata LV %s",
+				  lp->pool_metadata_lv_name);
+			return 0;
 		}
-		/* FIXME: any more types prohibited here ? */
-		if (!deactivate_lv(cmd, metadata_lv)) {
-			log_error("Can't deactivate logical volume %s/%s.",
+		if (lv_is_thin_type(metadata_lv)) {
+			log_error("Can't use thin pool logical volume %s/%s "
+				  "for thin pool metadata.",
 				  metadata_lv->vg->name, metadata_lv->name);
-			goto out;
+			return 0;
 		}
-		/* FIXME: initialize metadata LV! */
+	} else if (arg_count(cmd, poolmetadatasize_ARG)) {
+		/* FIXME: allocate metadata LV! */
+		metadata_lv = NULL;
+		log_error("Uncreated metadata.");
+		return 0;
 	} else {
-		/* FIXME: add creation of metadata LV */
+		log_error("Uknown metadata.");
+		return 0;
 	}
 
-	if (!lv_is_visible(pool_lv)) {
-		log_error("Can't use hidden logical volume %s/%s for thin pool data.",
-			  metadata_lv->vg->name, metadata_lv->name);
-		goto out;
-	}
-	if (lv_is_thin_pool(pool_lv)) {
-		log_error("Can't use thin pool logical volume %s/%s for thin pool data.",
-			  metadata_lv->vg->name, metadata_lv->name);
-		goto out;
+	len = strlen(pool_lv->name) + 16;
+	if (!(name = dm_pool_alloc(pool_lv->vg->vgmem, len))) {
+		log_error("Cannot allocate new name.");
+		return 0;
 	}
-	/* FIXME: any more types prohibited here ? */
-	if ((was_active = lv_is_active(pool_lv))) {
-		if (!deactivate_lv(cmd, pool_lv)) {
+
+	if (!lv_is_active(metadata_lv)) {
+		if (!deactivate_lv(cmd, metadata_lv)) {
 			log_error("Can't deactivate logical volume %s/%s.",
-				  pool_lv->vg->name, pool_lv->name);
-			goto out;
+				  metadata_lv->vg->name, metadata_lv->name);
+			return 0;
+		}
+		if (!activate_lv_local(cmd, metadata_lv)) {
+			log_error("Aborting. Failed to activate thin metadata lv.");
+			return 0;
 		}
 	}
 
+	if (!set_lv(cmd, metadata_lv, UINT64_C(0), 0)) {
+		log_error("Aborting. Failed to wipe thin metadata lv.");
+		return 0;
+	}
+
+	if (!deactivate_lv(cmd, metadata_lv)) {
+		log_error("Aborting. Failed to deactivate thin metadata lv. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
+		return_0;
+
+	/* Rename deactivated metadata LV to have _tmeta suffix */
+	/* Implicit checks if metadata_lv is visible */
+	if (!lv_rename_update(cmd, metadata_lv, name, 0))
+		return_0;
+
+	/*
+	 * Since we wish to have underlaying dev, to match _tdata
+	 * rename data LV first, also checks for visible LV
+	 */
+	/* FIXME: any more types prohibited here? */
+	/* FIXME: revert renamed LVs in fail path? */
+
 	/* FIXME: common code with metadata/thin_manip.c  extend_pool() */
+	/* Create layer _tdata */
 	if (!(data_lv = insert_layer_for_lv(pool_lv->vg->cmd, pool_lv,
 					    pool_lv->status, "_tdata")))
 		return_0;
@@ -1868,17 +1920,9 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 
 	seg->chunk_size = lp->chunk_size;
 	seg->zero_new_blocks = lp->zero ? 1 : 0;
+	seg->discards = lp->discards;
 	seg->low_water_mark = 0;
-
-	len = strlen(pool_lv->name) + 16;
-	if (!(name = dm_pool_alloc(pool_lv->vg->vgmem, len))) {
-		log_error("Cannot allocate new name.");
-		return 0;
-	}
-
-	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
-		return_0;
-	metadata_lv->name = name;
+	seg->transaction_id = 0;
 
 	if (!attach_pool_metadata_lv(seg, metadata_lv))
 		return_0;
@@ -1888,18 +1932,18 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	if (!attach_pool_data_lv(seg, data_lv))
 		return_0;
 
-	/* store vg on disk(s) */
 	if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 		return_0;
 
-	log_print_unless_silent("Converted %s/%s to thin pool.",
-				pool_lv->vg->name, pool_lv->name);
-	if (was_active && !activate_lv(cmd, pool_lv)) {
+	if (!activate_lv_excl(cmd, pool_lv)) {
 		log_error("Failed to activate pool logical volume %s/%s.",
 			  pool_lv->vg->name, pool_lv->name);
 		goto out;
 	}
 
+	log_print_unless_silent("Converted %s/%s to thin pool.",
+				pool_lv->vg->name, pool_lv->name);
+
 	r = 1;
 out:
 	backup(pool_lv->vg);
@@ -1975,6 +2019,15 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			stack;
 			return ECMD_FAILED;
 		}
+	} else if (arg_count(cmd, thinpool_ARG)) {
+		if (!archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		if (!_lvconvert_thinpool(cmd, lv, lp)) {
+			stack;
+			return ECMD_FAILED;
+		}
 	} else if (segtype_is_raid(lp->segtype) ||
 		   (lv->status & RAID) || lp->merge_mirror) {
 		if (!archive(lv->vg)) {
@@ -2014,15 +2067,6 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		/* If repairing and using policies, remove missing PVs from VG */
 		if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
 			_remove_missing_empty_pv(lv->vg, failed_pvs);
-	} else if (arg_count(cmd, thinpool_ARG)) {
-		if (!archive(lv->vg)) {
-			stack;
-			return ECMD_FAILED;
-		}
-		if (!_lvconvert_thinpool(cmd, lv, lp)) {
-			stack;
-			return ECMD_FAILED;
-		}
 	}
 
 	return ECMD_PROCESSED;


