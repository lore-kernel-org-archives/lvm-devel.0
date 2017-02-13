From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:11 +0000 (UTC)
Subject: master - lvconvert: use command defs for thin/cache/pool creation
Message-ID: <20170213181011.E4E586039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e3e611a137a264a343335d18d500fce7af8e0f7
Commit:        0e3e611a137a264a343335d18d500fce7af8e0f7
Parent:        d71aaca07b2c14049130ab368221510c65236af7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 7 14:30:57 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvconvert: use command defs for thin/cache/pool creation

Everything related to thin and cache.
---
 test/shell/lvconvert-thin.sh |   18 +-
 test/shell/thin-merge.sh     |    4 +-
 test/shell/thin-vglock.sh    |    2 +-
 tools/args.h                 |    2 +
 tools/command-lines.in       |   45 +-
 tools/lvconvert.c            | 1361 ++++++++++++++++++++++++++++++++++++++++--
 tools/lvmcmdline.c           |   39 +-
 tools/toollib.c              |    6 +-
 tools/toollib.h              |    2 +
 tools/tools.h                |    9 +
 10 files changed, 1404 insertions(+), 84 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 3878fcb..2a54614 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -81,9 +81,9 @@ grep "Pool zeroing and large" err
 UUID=$(get lv_field $vg/$lv2 uuid)
 # Fail is pool is active
 # TODO  maybe detect inactive pool and deactivate
-fail lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $lv2
+fail lvconvert --swapmetadata --yes --poolmetadata $lv2 $vg/$lv1
 lvchange -an $vg
-lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $lv2
+lvconvert --swapmetadata --yes --poolmetadata $lv2 $vg/$lv1
 check lv_field $vg/${lv1}_tmeta uuid "$UUID"
 lvremove -f $vg
 
@@ -96,20 +96,20 @@ lvcreate -L1M -n $lv3 $vg
 # chunk size is bigger then size of thin pool data
 fail lvconvert --yes -c 1G --thinpool $vg/$lv3
 # stripes can't be used with poolmetadata
-invalid lvconvert --stripes 2 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+not lvconvert --stripes 2 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # too small metadata (<2M)
 fail lvconvert --yes -c 64 --thinpool $vg/$lv1 --poolmetadata $vg/$lv3
 # too small chunk size fails
-invalid lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+not lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # too big chunk size fails
-invalid lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+not lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # negative chunk size fails
-invalid lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+not lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # non multiple of 64KiB fails
-invalid lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+not lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
 # cannot use same LV for pool and convertion
-invalid lvconvert --yes --thinpool $vg/$lv3 -T $vg/$lv3
+not lvconvert --yes --thinpool $vg/$lv3 -T $vg/$lv3
 
 # Warning about smaller then suggested
 lvconvert --yes -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 2>&1 | tee err
@@ -129,7 +129,7 @@ if test "$TSIZE" = 64T; then
 lvcreate -L24T -n $lv1 $vg
 # Warning about bigger then needed (24T data and 16G -> 128K chunk)
 lvconvert --yes -c 64 --thinpool $vg/$lv1 2>&1 | tee err
-grep "WARNING: Chunk size is too small" err
+grep "too small" err
 lvremove -f $vg
 fi
 
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index b3ad007..d932924 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -44,7 +44,7 @@ touch mntsnap/test_snap
 
 lvs -o+tags,thin_id $vg
 
-lvconvert --merge $vg/snap
+lvconvert --mergethin $vg/snap
 
 umount mnt
 
@@ -107,7 +107,7 @@ fsck -n "$DM_DEV_DIR/$vg/$lv1"
 check lv_not_exists $vg oldsnapof_${lv1}
 # Add old snapshot to thin snapshot
 lvcreate -s -L10 -n oldsnapof_snap $vg/snap
-lvconvert --merge $vg/snap
+lvconvert --mergethin $vg/snap
 lvremove -f $vg/oldsnapof_snap
 
 vgremove -ff $vg
diff --git a/test/shell/thin-vglock.sh b/test/shell/thin-vglock.sh
index 40f3adf..0b96b4b 100644
--- a/test/shell/thin-vglock.sh
+++ b/test/shell/thin-vglock.sh
@@ -34,7 +34,7 @@ mount "$DM_DEV_DIR/$vg/$lv1" mnt
 lvcreate -s -n snap $vg/$lv1
 check lv_field $vg/snap thin_id "3"
 
-lvconvert --merge $vg/snap
+lvconvert --mergethin $vg/snap
 
 umount mnt
 
diff --git a/tools/args.h b/tools/args.h
index 3560c9c..c904609 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -61,6 +61,7 @@ arg(logonly_ARG, '\0', "logonly", 0, 0, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", sizekb_VAL, 0, 0)
 arg(merge_ARG, '\0', "merge", 0, 0, 0)
 arg(mergesnapshot_ARG, '\0', "mergesnapshot", 0, 0, 0)
+arg(mergethin_ARG, '\0', "mergethin", 0, 0, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", 0, 0, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_VAL, 0, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", bool_VAL, 0, 0)
@@ -120,6 +121,7 @@ arg(showdeprecated_ARG, '\0', "showdeprecated", 0, 0, 0)
 arg(showunsupported_ARG, '\0', "showunsupported", 0, 0, 0)
 arg(startpoll_ARG, '\0', "startpoll", 0, 0, 0)
 arg(stripes_long_ARG, '\0', "stripes", number_VAL, 0, 0)
+arg(swapmetadata_ARG, '\0', "swapmetadata", 0, 0, 0)
 arg(syncaction_ARG, '\0', "syncaction", syncaction_VAL, 0, 0)
 arg(sysinit_ARG, '\0', "sysinit", 0, 0, 0)
 arg(systemid_ARG, '\0', "systemid", string_VAL, 0, 0)
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 4704747..5804723 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -384,18 +384,22 @@ DESC: Change the type of mirror log used by a mirror LV.
 # lvconvert utilities for creating/maintaining thin and cache objects.
 # Create a new command set for these and migrate them out of lvconvert?
 
-lvconvert --type thin --thinpool LV LV_linear_striped_raid
+lvconvert --type thin --thinpool LV LV_linear_striped_raid_cache
 OO: --thin, --originname LV_new, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
-DESC: Convert LV to type thin with an external origin.
+DESC: Convert LV to a thin LV, using the original LV as an external origin.
+RULE: all and lv_is_visible
+RULE: all not lv_is_locked
 
 # alternate form of lvconvert --type thin
-lvconvert --thin --thinpool LV LV_linear_striped_raid
+lvconvert --thin --thinpool LV LV_linear_striped_raid_cache
 OO: --type thin, --originname LV_new, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
-DESC: Convert LV to type thin with an external origin
+DESC: Convert LV to a thin LV, using the original LV as an external origin.
 DESC: (variant, infers --type thin).
 FLAGS: SECONDARY_SYNTAX
+RULE: all and lv_is_visible
+RULE: all not lv_is_locked
 
 ---
 
@@ -404,6 +408,7 @@ OO: --cache, --cachemode CacheMode, --cachepolicy String,
 --cachesettings String, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
 DESC: Convert LV to type cache.
+RULE: all and lv_is_visible
 
 # alternate form of lvconvert --type cache
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
@@ -412,6 +417,7 @@ OO: --type cache, --cachemode CacheMode, --cachepolicy String,
 ID: lvconvert_to_cache_vol
 DESC: Convert LV to type cache (variant, infers --type cache).
 FLAGS: SECONDARY_SYNTAX
+RULE: all and lv_is_visible
 
 ---
 
@@ -421,14 +427,18 @@ OO: --stripes_long Number, --stripesize SizeKB,
 OP: PV ...
 ID: lvconvert_to_thinpool
 DESC: Convert LV to type thin-pool.
+RULE: all and lv_is_visible
+RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual
 
 # alternate form of lvconvert --type thin-pool
 # deprecated because of non-standard syntax (missing positional arg)
+# Commands in this form are converted to standard form so that
+# the validation of LV types and rules specified above will apply.
 lvconvert --thinpool LV_linear_striped_raid_cache
 OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
 --discards Discards, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
-ID: lvconvert_to_thinpool
+ID: lvconvert_to_thinpool_noarg
 DESC: Convert LV to type thin-pool (variant, use --type thin-pool).
 FLAGS: SECONDARY_SYNTAX
 
@@ -443,10 +453,13 @@ DESC: Convert LV to type cache-pool.
 
 # alternate form of lvconvert --type cache-pool
 # deprecated because of non-standard syntax (missing positional arg)
+# Commands in this form are converted to standard form so that
+# the validation of LV types and rules specified above will apply.
 lvconvert --cachepool LV_linear_striped_raid
 OO: --type cache-pool, OO_LVCONVERT_POOL, OO_LVCONVERT,
 --cachemode CacheMode, --cachepolicy String, --cachesettings String
-ID: lvconvert_to_cachepool
+OP: PV ...
+ID: lvconvert_to_cachepool_noarg
 DESC: Convert LV to type cache-pool (variant, use --type cache-pool).
 FLAGS: SECONDARY_SYNTAX
 
@@ -461,18 +474,15 @@ DESC: Separate and keep the cache pool from a cache LV.
 
 lvconvert --uncache LV_cache_thinpool
 OO: OO_LVCONVERT
-ID: lvconvert_split_and_delete_cachepool
+ID: lvconvert_split_and_remove_cachepool
 DESC: Separate and delete the cache pool from a cache LV.
 
 ---
 
-# FIXME: add a new option defining this operation, e.g. --swapmetadata
-
-lvconvert --poolmetadata LV LV_thinpool_cachepool
-OO: OO_LVCONVERT
+lvconvert --swapmetadata --poolmetadata LV LV_thinpool_cachepool
+OO: --chunksize SizeKB, OO_LVCONVERT
 ID: lvconvert_swap_pool_metadata
-DESC: Swap metadata LV in a thin pool or cache pool (temporary command).
-FLAGS: SECONDARY_SYNTAX
+DESC: Swap metadata LV in a thin pool or cache pool (for repair only).
 
 ---
 
@@ -879,6 +889,15 @@ DESC: (infers --type thin).
 
 ---
 
+lvconvert --mergethin LV_thin ...
+OO: --background, --interval Number, OO_LVCONVERT
+ID: lvconvert_merge_thin
+DESC: Merge thin LV into its origin LV.
+RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
+RULE: all and lv_is_visible
+
+---
+
 # stripes option is not intuitive when creating a thin LV,
 # but here it applies to creating the new thin pool that
 # is used for the thin LV
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b7621b5..979d94d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -17,6 +17,7 @@
 #include "polldaemon.h"
 #include "lv_alloc.h"
 #include "lvconvert_poll.h"
+#include "command-lines-count.h"
 
 /*
  * Guidelines for mapping options to operations.
@@ -2051,14 +2052,12 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	return 1;
 }
 
-
-static int _lvconvert_split_cached(struct cmd_context *cmd,
-				   struct logical_volume *lv)
+static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
+				   struct logical_volume *lv,
+				   struct logical_volume *cachepool_lv)
 {
-	struct logical_volume *cache_pool_lv = first_seg(lv)->pool_lv;
-
-	log_debug("Detaching cache pool %s from cached LV %s.",
-		  display_lvname(cache_pool_lv), display_lvname(lv));
+	log_debug("Detaching cache pool %s from cache LV %s.",
+		  display_lvname(cachepool_lv), display_lvname(lv));
 
 	if (!archive(lv->vg))
 		return_0;
@@ -2072,27 +2071,18 @@ static int _lvconvert_split_cached(struct cmd_context *cmd,
 	backup(lv->vg);
 
 	log_print_unless_silent("Logical volume %s is not cached and cache pool %s is unused.",
-				display_lvname(lv), display_lvname(cache_pool_lv));
+				display_lvname(lv), display_lvname(cachepool_lv));
 
 	return 1;
 }
 
-static int _lvconvert_uncache(struct cmd_context *cmd,
-			      struct logical_volume *lv,
-			      struct lvconvert_params *lp)
+static int _lvconvert_split_and_remove_cachepool(struct cmd_context *cmd,
+				   struct logical_volume *lv,
+				   struct logical_volume *cachepool_lv)
 {
 	struct lv_segment *seg;
 	struct logical_volume *remove_lv;
 
-	if (lv_is_thin_pool(lv))
-		lv = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
-
-	if (!lv_is_cache(lv)) {
-		log_error("Cannot uncache non-cached logical volume %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	seg = first_seg(lv);
 
 	if (lv_is_partial(seg_lv(seg, 0))) {
@@ -2113,7 +2103,7 @@ static int _lvconvert_uncache(struct cmd_context *cmd,
 	/* TODO: Check for failed cache as well to get prompting? */
 	if (lv_is_partial(lv)) {
 		if (first_seg(seg->pool_lv)->cache_mode != CACHE_MODE_WRITETHROUGH) {
-			if (!lp->force) {
+			if (!arg_count(cmd, force_ARG)) {
 				log_error("Conversion aborted.");
 				log_error("Cannot uncache writethrough cache volume %s without --force.",
 					  display_lvname(lv));
@@ -2123,14 +2113,12 @@ static int _lvconvert_uncache(struct cmd_context *cmd,
 				 display_lvname(lv));
 		}
 
-		if (!lp->yes &&
+		if (!arg_count(cmd, yes_ARG) &&
 		    yes_no_prompt("Do you really want to uncache %s with missing LVs? [y/n]: ",
 				  display_lvname(lv)) == 'n') {
 			log_error("Conversion aborted.");
 			return 0;
 		}
-		cmd->handles_missing_pvs = 1;
-		cmd->partial_activation = 1;
 	}
 
 	if (lvremove_single(cmd, remove_lv, NULL) != ECMD_PROCESSED)
@@ -2348,8 +2336,7 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 }
 
 static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
-					  struct logical_volume *lv,
-					  struct lvconvert_params *lp)
+					  struct logical_volume *lv)
 {
 	int origin_is_active = 0, r = 0;
 	struct lv_segment *snap_seg = first_seg(lv);
@@ -2765,6 +2752,144 @@ revert_new_lv:
 	return 0;
 }
 
+static int _lvconvert_to_thin_with_external(struct cmd_context *cmd,
+			   struct logical_volume *lv,
+			   struct logical_volume *thinpool_lv)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *thin_lv;
+	const char *origin_name;
+
+	struct lvcreate_params lvc = {
+		.activate = CHANGE_AEY,
+		.alloc = ALLOC_INHERIT,
+		.major = -1,
+		.minor = -1,
+		.suppress_zero_warn = 1, /* Suppress warning for this thin */
+		.permission = LVM_READ,
+		.pool_name = thinpool_lv->name,
+		.pvh = &vg->pvs,
+		.read_ahead = DM_READ_AHEAD_AUTO,
+		.stripes = 1,
+		.virtual_extents = lv->le_count,
+	};
+
+	if (lv == thinpool_lv) {
+		log_error("Can't use same LV %s for thin pool and thin volume.",
+			  display_lvname(thinpool_lv));
+		return 0;
+	}
+
+	if ((origin_name = arg_str_value(cmd, originname_ARG, NULL)))
+		if (!validate_restricted_lvname_param(cmd, &vg->name, &origin_name))
+			return_0;
+
+	/*
+	 * If NULL, an auto-generated 'lvol' name is used.
+	 * If set, the lv create code checks the name isn't used.
+	 */
+	lvc.lv_name = origin_name;
+
+	if (is_lockd_type(vg->lock_type)) {
+		/*
+		 * FIXME: external origins don't work in lockd VGs.
+		 * Prior to the lvconvert, there's a lock associated with
+		 * the uuid of the external origin LV.  After the convert,
+		 * that uuid belongs to the new thin LV, and a new LV with
+		 * a new uuid exists as the non-thin, readonly external LV.
+		 * We'd need to remove the lock for the previous uuid
+		 * (the new thin LV will have no lock), and create a new
+		 * lock for the new LV uuid used by the external LV.
+		 */
+		log_error("Can't use lock_type %s LV as external origin.",
+			  vg->lock_type);
+		return 0;
+	}
+
+	dm_list_init(&lvc.tags);
+
+	if (!pool_supports_external_origin(first_seg(thinpool_lv), lv))
+		return_0;
+
+	if (!(lvc.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN)))
+		return_0;
+
+	if (!archive(vg))
+		return_0;
+
+	/*
+	 * New thin LV needs to be created (all messages sent to pool) In this
+	 * case thin volume is created READ-ONLY and also warn about not
+	 * zeroing is suppressed.
+	 *
+	 * The new thin LV is created with the origin_name, or an autogenerated
+	 * 'lvol' name.  Then the names and ids are swapped between the thin LV
+	 * and the original/external LV.  So, the thin LV gets the name and id
+	 * of the original LV arg, and the original LV arg gets the origin_name
+	 * or the autogenerated name.
+	 */
+
+	if (!(thin_lv = lv_create_single(vg, &lvc)))
+		return_0;
+
+	if (!deactivate_lv(cmd, thin_lv)) {
+		log_error("Aborting. Unable to deactivate new LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	/*
+	 * Crashing till this point will leave plain thin volume
+	 * which could be easily removed by the user after i.e. power-off
+	 */
+
+	if (!swap_lv_identifiers(cmd, thin_lv, lv)) {
+		stack;
+		goto revert_new_lv;
+	}
+
+	/* Preserve read-write status of original LV here */
+	thin_lv->status |= (lv->status & LVM_WRITE);
+
+	if (!attach_thin_external_origin(first_seg(thin_lv), lv)) {
+		stack;
+		goto revert_new_lv;
+	}
+
+	if (!lv_update_and_reload(thin_lv)) {
+		stack;
+		goto deactivate_and_revert_new_lv;
+	}
+
+	log_print_unless_silent("Converted %s to thin volume with external origin %s.",
+				display_lvname(thin_lv), display_lvname(lv));
+
+	return 1;
+
+deactivate_and_revert_new_lv:
+	if (!swap_lv_identifiers(cmd, thin_lv, lv))
+		stack;
+
+	if (!deactivate_lv(cmd, thin_lv)) {
+		log_error("Unable to deactivate failed new LV. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	if (!detach_thin_external_origin(first_seg(thin_lv)))
+		return_0;
+
+revert_new_lv:
+	/* FIXME Better to revert to backup of metadata? */
+	if (!lv_remove(thin_lv) || !vg_write(vg) || !vg_commit(vg))
+		log_error("Manual intervention may be required to remove "
+			  "abandoned LV(s) before retrying.");
+	else
+		backup(vg);
+
+	return 0;
+}
+
 static int _lvconvert_update_pool_params(struct logical_volume *pool_lv,
 					 struct lvconvert_params *lp)
 {
@@ -3340,31 +3465,732 @@ revert_new_lv:
 #endif
 }
 
+static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct logical_volume *metadata_lv)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *prev_metadata_lv;
+	struct lv_segment *seg;
+	struct lv_types *lvtype;
+	char meta_name[NAME_LEN];
+	const char *swap_name;
+	uint32_t chunk_size;
+	int is_thinpool;
+	int is_cachepool;
+	int lvt_enum;
+
+	is_thinpool = lv_is_thin_pool(lv);
+	is_cachepool = lv_is_cache_pool(lv);
+	lvt_enum = get_lvt_enum(metadata_lv);
+	lvtype = get_lv_type(lvt_enum);
+
+	if (lvt_enum != striped_LVT && lvt_enum != linear_LVT && lvt_enum != raid_LVT) {
+		log_error("LV %s with type %s cannot be used as a metadata LV.",
+			  display_lvname(metadata_lv), lvtype ? lvtype->name : "unknown");
+		return 0;
+	}
+
+	if (!lv_is_visible(metadata_lv)) {
+		log_error("Can't convert internal LV %s.",
+			  display_lvname(metadata_lv));
+		return 0;
+	}
+
+	if (lv_is_locked(metadata_lv)) {
+		log_error("Can't convert locked LV %s.",
+			  display_lvname(metadata_lv));
+		return 0;
+	}
+
+	if (lv_is_origin(metadata_lv) ||
+	    lv_is_merging_origin(metadata_lv) ||
+	    lv_is_external_origin(metadata_lv) ||
+	    lv_is_virtual(metadata_lv)) {
+		log_error("Pool metadata LV %s is of an unsupported type.",
+			  display_lvname(metadata_lv));
+		return 0;
+	}
+
+	/* FIXME cache pool */
+	if (is_thinpool && pool_is_active(lv)) {
+		/* If any volume referencing pool active - abort here */
+		log_error("Cannot convert pool %s with active volumes.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	if ((dm_snprintf(meta_name, sizeof(meta_name), "%s%s", lv->name, is_cachepool ? "_cmeta" : "_tmeta") < 0)) {
+                log_error("Failed to create internal lv names, pool name is too long.");
+                return 0;
+        }
+
+	seg = first_seg(lv);
+
+	/* Normally do NOT change chunk size when swapping */
+
+	if (arg_is_set(cmd, chunksize_ARG)) {
+		chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
+
+		if ((chunk_size != seg->chunk_size) && !dm_list_empty(&lv->segs_using_this_lv)) {
+			if (arg_count(cmd, force_ARG) == PROMPT) {
+				log_error("Chunk size can be only changed with --force. Conversion aborted.");
+				return 0;
+			}
+
+			if (!validate_pool_chunk_size(cmd, seg->segtype, chunk_size))
+				return_0;
+
+			log_warn("WARNING: Changing chunk size %s to %s for %s pool volume.",
+				 display_size(cmd, seg->chunk_size),
+				 display_size(cmd, chunk_size),
+				 display_lvname(lv));
+
+			/* Ok, user has likely some serious reason for this */
+			if (!arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Do you really want to change chunk size for %s pool volume? [y/n]: ",
+					  display_lvname(lv)) == 'n') {
+				log_error("Conversion aborted.");
+				return 0;
+			}
+		}
+
+		seg->chunk_size = chunk_size;
+	}
+
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Do you want to swap metadata of %s pool with metadata volume %s? [y/n]: ",
+			  display_lvname(lv),
+			  display_lvname(metadata_lv)) == 'n') {
+		log_error("Conversion aborted.");
+		return 0;
+	}
+
+	if (!deactivate_lv(cmd, metadata_lv)) {
+		log_error("Aborting. Failed to deactivate %s.",
+			  display_lvname(metadata_lv));
+		return 0;
+	}
+
+	if (!archive(vg))
+		return_0;
+
+	/* Swap names between old and new metadata LV */
+
+	if (!detach_pool_metadata_lv(seg, &prev_metadata_lv))
+		return_0;
+
+	swap_name = metadata_lv->name;
+
+	if (!lv_rename_update(cmd, metadata_lv, "pvmove_tmeta", 0))
+		return_0;
+
+	/* Give the previous metadata LV the name of the LV replacing it. */
+
+	if (!lv_rename_update(cmd, prev_metadata_lv, swap_name, 0))
+		return_0;
+
+	/* Rename deactivated metadata LV to have _tmeta suffix */
+
+	if (!lv_rename_update(cmd, metadata_lv, meta_name, 0))
+		return_0;
+
+	if (!attach_pool_metadata_lv(seg, metadata_lv))
+		return_0;
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	backup(vg);
+	return 1;
+}
+
 /*
- * Convert origin into a cache LV by attaching a cache pool.
+ * Create a new pool LV, using the lv arg as the data sub LV.
+ * The metadata sub LV is either a new LV created here, or an
+ * existing LV specified by --poolmetadata.
  */
-static int _lvconvert_cache(struct cmd_context *cmd,
-			    struct logical_volume *origin_lv,
-			    struct lvconvert_params *lp)
+
+static int _lvconvert_to_pool(struct cmd_context *cmd,
+			      struct logical_volume *lv,
+			      int to_thinpool,
+			      int to_cachepool,
+			      struct dm_list *use_pvh)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *metadata_lv = NULL;  /* existing or created */
+	struct logical_volume *data_lv;             /* lv arg renamed */
+	struct logical_volume *pool_lv;             /* new lv created here */
+	const char *pool_metadata_name;             /* user-specified lv name */
+	const char *pool_name;                      /* name of original lv arg */
+	char meta_name[NAME_LEN];                   /* generated sub lv name */
+	char data_name[NAME_LEN];                   /* generated sub lv name */
+	struct segment_type *pool_segtype;          /* thinpool or cachepool */
+	struct lv_segment *seg;
+	unsigned int target_attr = ~0;
+	unsigned int passed_args = 0;
+	unsigned int activate_pool;
+	unsigned int zero_metadata;
+	uint64_t meta_size;
+	uint32_t meta_extents;
+	uint32_t chunk_size;
+	int chunk_calc;
+	int r = 0;
+
+	/* for handling lvmlockd cases */
+	char *lockd_data_args = NULL;
+	char *lockd_meta_args = NULL;
+	char *lockd_data_name = NULL;
+	char *lockd_meta_name = NULL;
+	struct id lockd_data_id;
+	struct id lockd_meta_id;
+
+
+	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
+		log_error(INTERNAL_ERROR "LV %s is already a pool.", display_lvname(lv));
+		return 0;
+	}
+
+	pool_segtype = to_cachepool ? get_segtype_from_string(cmd, SEG_TYPE_NAME_CACHE_POOL) :
+				      get_segtype_from_string(cmd, SEG_TYPE_NAME_THIN_POOL);
+
+	if (!pool_segtype->ops->target_present(cmd, NULL, &target_attr)) {
+		log_error("%s: Required device-mapper target(s) not detected in your kernel.", pool_segtype->name);
+		return 0;
+	}
+
+	/* Allow to have only thinpool active and restore it's active state. */
+	activate_pool = to_thinpool && lv_is_active(lv);
+
+	/* Wipe metadata_lv by default, but allow skipping this for cache pools. */
+	zero_metadata = to_cachepool ? arg_int_value(cmd, zero_ARG, 1) : 1;
+
+	/* An existing LV needs to have its lock freed once it becomes a data LV. */
+	if (is_lockd_type(vg->lock_type) && lv->lock_args) {
+		lockd_data_args = dm_pool_strdup(cmd->mem, lv->lock_args);
+		lockd_data_name = dm_pool_strdup(cmd->mem, lv->name);
+		memcpy(&lockd_data_id, &lv->lvid.id[1], sizeof(struct id));
+	}
+
+	/*
+	 * If an existing LV is to be used as the metadata LV,
+	 * verify that it's in a usable state.  These checks are
+	 * not done by command def rules because this LV is not
+	 * processed by process_each_lv.
+	 */
+
+	if ((pool_metadata_name = arg_str_value(cmd, poolmetadata_ARG, NULL))) {
+		if (!(metadata_lv = find_lv(vg, pool_metadata_name))) {
+			log_error("Unknown pool metadata LV %s.", pool_metadata_name);
+			return 0;
+		}
+
+		/* An existing LV needs to have its lock freed once it becomes a meta LV. */
+		if (is_lockd_type(vg->lock_type) && metadata_lv->lock_args) {
+			lockd_meta_args = dm_pool_strdup(cmd->mem, metadata_lv->lock_args);
+			lockd_meta_name = dm_pool_strdup(cmd->mem, metadata_lv->name);
+			memcpy(&lockd_meta_id, &metadata_lv->lvid.id[1], sizeof(struct id));
+		}
+
+		if (metadata_lv == lv) {
+			log_error("Can't use same LV for pool data and metadata LV %s.",
+				  display_lvname(metadata_lv));
+			return 0;
+		}
+
+		if (!lv_is_visible(metadata_lv)) {
+			log_error("Can't convert internal LV %s.",
+				  display_lvname(metadata_lv));
+			return 0;
+		}
+
+		if (lv_is_locked(metadata_lv)) {
+			log_error("Can't convert locked LV %s.",
+				  display_lvname(metadata_lv));
+			return 0;
+		}
+
+		if (lv_is_mirror(metadata_lv)) {
+			log_error("Mirror logical volumes cannot be used for pool metadata.");
+			log_print_unless_silent("Try \"%s\" segment type instead.", SEG_TYPE_NAME_RAID1);
+			return 0;
+		}
+
+		/* FIXME Tidy up all these type restrictions. */
+		if (lv_is_cache_type(metadata_lv) ||
+		    lv_is_thin_type(metadata_lv) ||
+		    lv_is_cow(metadata_lv) || lv_is_merging_cow(metadata_lv) ||
+		    lv_is_origin(metadata_lv) || lv_is_merging_origin(metadata_lv) ||
+		    lv_is_external_origin(metadata_lv) ||
+		    lv_is_virtual(metadata_lv)) {
+			log_error("Pool metadata LV %s is of an unsupported type.",
+				  display_lvname(metadata_lv));
+			return 0;
+		}
+	}
+
+	/*
+	 * Determine the size of the metadata LV and the chunk size.  When an
+	 * existing LV is to be used for metadata, this introduces some
+	 * constraints/defaults.  When chunk_size=0 and/or meta_extents=0 are
+	 * passed to the "update params" function, defaults are calculated and
+	 * returned.
+	 */
+
+	if (arg_is_set(cmd, chunksize_ARG)) {
+		passed_args |= PASS_ARG_CHUNK_SIZE;
+		chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
+		if (!validate_pool_chunk_size(cmd, pool_segtype, chunk_size))
+			return_0;
+	} else {
+		/* A default will be chosen by the "update" function. */
+		chunk_size = 0;
+	}
+
+	if (arg_is_set(cmd, poolmetadatasize_ARG)) {
+		meta_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
+		meta_extents = extents_from_size(cmd, meta_size, vg->extent_size);
+		passed_args |= PASS_ARG_POOL_METADATA_SIZE;
+	} else if (metadata_lv) {
+		meta_extents = metadata_lv->le_count;
+		passed_args |= PASS_ARG_POOL_METADATA_SIZE;
+	} else {
+		/* A default will be chosen by the "update" function. */
+		meta_extents = 0;
+	}
+
+	/* Tell the "update" function to ignore these, they are handled below. */
+	passed_args |= PASS_ARG_DISCARDS | PASS_ARG_ZERO;
+
+	/*
+	 * Validate and/or choose defaults for meta_extents and chunk_size,
+	 * this involves some complicated calculations.
+	 */
+
+	if (to_cachepool) {
+		if (!update_cache_pool_params(pool_segtype, vg, target_attr,
+					      passed_args, lv->le_count,
+					      &meta_extents,
+					      &chunk_calc,
+					      &chunk_size))
+			return_0;
+	} else {
+		if (!update_thin_pool_params(pool_segtype, vg, target_attr,
+					     passed_args, lv->le_count,
+					     &meta_extents,
+					     &chunk_calc,
+					     &chunk_size,
+					     NULL, NULL))
+			return_0;
+	}
+
+	if ((uint64_t)chunk_size > ((uint64_t)lv->le_count * vg->extent_size)) {
+		log_error("Pool data LV %s is too small (%s) for specified chunk size (%s).",
+			  display_lvname(lv),
+			  display_size(cmd, (uint64_t)lv->le_count * vg->extent_size),
+			  display_size(cmd, chunk_size));
+		return 0;
+	}
+
+	if (metadata_lv && (meta_extents > metadata_lv->le_count)) {
+		log_error("Pool metadata LV %s is too small (%u extents) for required metadata (%u extents).",
+			  display_lvname(metadata_lv), metadata_lv->le_count, meta_extents);
+		return 0;
+	}
+
+	log_verbose("Pool metadata extents %u chunk_size %u", meta_extents, chunk_size);
+
+
+	/*
+	 * Verify that user wants to use these LVs.
+	 */
+
+	log_warn("WARNING: Converting logical volume %s%s%s to %s pool's data%s %s metadata wiping.",
+		 display_lvname(lv),
+		 metadata_lv ? " and " : "",
+		 metadata_lv ? display_lvname(metadata_lv) : "",
+		 to_cachepool ? "cache" : "thin",
+		 metadata_lv ? " and metadata volumes" : " volume",
+		 zero_metadata ? "with" : "WITHOUT");
+
+	if (zero_metadata)
+		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+	else if (to_cachepool)
+		log_warn("WARNING: Using mismatched cache pool metadata MAY DESTROY YOUR DATA!");
+
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Do you really want to convert %s%s%s? [y/n]: ",
+			  display_lvname(lv),
+			  metadata_lv ? " and " : "",
+			  metadata_lv ? display_lvname(metadata_lv) : "") == 'n') {
+		log_error("Conversion aborted.");
+		return 0;
+	}
+
+	/*
+	 * The internal LV names for pool data/meta LVs.
+	 */
+
+	if ((dm_snprintf(meta_name, sizeof(meta_name), "%s%s", lv->name, to_cachepool ? "_cmeta" : "_tmeta") < 0) ||
+	    (dm_snprintf(data_name, sizeof(data_name), "%s%s", lv->name, to_cachepool ? "_cdata" : "_tdata") < 0)) {
+		log_error("Failed to create internal lv names, pool name is too long.");
+		return 0;
+	}
+
+	/*
+	 * If a new metadata LV needs to be created, collect the settings for
+	 * the new LV and create it.
+	 *
+	 * If an existing LV is used for metadata, deactivate/activate/wipe it.
+	 */
+
+	if (!metadata_lv) {
+		uint32_t meta_stripes;
+		uint32_t meta_stripe_size;
+		uint32_t meta_readahead;
+		alloc_policy_t meta_alloc;
+		unsigned meta_stripes_supplied;
+		unsigned meta_stripe_size_supplied;
+
+		if (!get_stripe_params(cmd, get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED),
+				       &meta_stripes,
+				       &meta_stripe_size,
+				       &meta_stripes_supplied,
+				       &meta_stripe_size_supplied))
+			return_0;
+
+		meta_readahead = arg_uint_value(cmd, readahead_ARG, cmd->default_settings.read_ahead);
+		meta_alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
+
+		if (!archive(vg))
+			return_0;
+
+		if (!(metadata_lv = alloc_pool_metadata(lv,
+							meta_name,
+							meta_readahead,
+							meta_stripes,
+							meta_stripe_size,
+							meta_extents,
+							meta_alloc,
+							use_pvh)))
+			return_0;
+	} else {
+		if (!deactivate_lv(cmd, metadata_lv)) {
+			log_error("Aborting. Failed to deactivate %s.",
+				  display_lvname(metadata_lv));
+			return 0;
+		}
+
+		if (!archive(vg))
+			return_0;
+
+		if (zero_metadata) {
+			metadata_lv->status |= LV_TEMPORARY;
+			if (!activate_lv_local(cmd, metadata_lv)) {
+				log_error("Aborting. Failed to activate metadata lv.");
+				return 0;
+			}
+
+			if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
+				log_error("Aborting. Failed to wipe metadata lv.");
+				return 0;
+			}
+		}
+	}
+
+	/*
+	 * Deactivate the data LV and metadata LV.
+	 * We are changing target type, so deactivate first.
+	 */
+
+	if (!deactivate_lv(cmd, metadata_lv)) {
+		log_error("Aborting. Failed to deactivate metadata lv. "
+			  "Manual intervention required.");
+		return 0;
+	}
+
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Aborting. Failed to deactivate logical volume %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	/*
+	 * When the LV referenced by the original function arg "lv"
+	 * is renamed, it is then referenced as "data_lv".
+	 *
+	 * pool_name    pool name taken from lv arg
+	 * data_name    sub lv name, generated
+	 * meta_name    sub lv name, generated
+	 *
+	 * pool_lv      new lv for pool object, created here
+	 * data_lv      sub lv, was lv arg, now renamed
+	 * metadata_lv  sub lv, existing or created here
+	 */
+
+	data_lv = lv;
+	pool_name = lv->name; /* Use original LV name for pool name */
+
+	/*
+	 * Rename the original LV arg to the internal data LV naming scheme.
+	 *
+	 * Since we wish to have underlaying devs to match _[ct]data
+	 * rename data LV to match pool LV subtree first,
+	 * also checks for visible LV.
+	 *
+	 * FIXME: any more types prohibited here?
+	 */
+
+	if (!lv_rename_update(cmd, data_lv, data_name, 0))
+		return_0;
+
+	/*
+	 * Create LV structures for the new pool LV object,
+	 * and connect it to the data/meta LVs.
+	 */
+
+	if (!(pool_lv = lv_create_empty(pool_name, NULL,
+					(to_cachepool ? CACHE_POOL : THIN_POOL) | VISIBLE_LV | LVM_READ | LVM_WRITE,
+					ALLOC_INHERIT, vg))) {
+		log_error("Creation of pool LV failed.");
+		return 0;
+	}
+
+	/* Allocate a new pool segment */
+	if (!(seg = alloc_lv_segment(pool_segtype, pool_lv, 0, data_lv->le_count,
+				     pool_lv->status, 0, NULL, 1,
+				     data_lv->le_count, 0, 0, 0, NULL)))
+		return_0;
+
+	/* Add the new segment to the layer LV */
+	dm_list_add(&pool_lv->segments, &seg->list);
+	pool_lv->le_count = data_lv->le_count;
+	pool_lv->size = data_lv->size;
+
+	if (!attach_pool_data_lv(seg, data_lv))
+		return_0;
+
+	/*
+	 * Create a new lock for a thin pool LV.  A cache pool LV has no lock.
+	 * Locks are removed from existing LVs that are being converted to
+	 * data and meta LVs (they are unlocked and deleted below.)
+	 */
+	if (is_lockd_type(vg->lock_type)) {
+		if (to_cachepool) {
+			data_lv->lock_args = NULL;
+			metadata_lv->lock_args = NULL;
+		} else {
+			data_lv->lock_args = NULL;
+			metadata_lv->lock_args = NULL;
+
+			if (!strcmp(vg->lock_type, "sanlock"))
+				pool_lv->lock_args = "pending";
+			else if (!strcmp(vg->lock_type, "dlm"))
+				pool_lv->lock_args = "dlm";
+			/* The lock_args will be set in vg_write(). */
+		}
+	}
+
+	/*
+	 * Apply settings to the new pool seg, from command line, from
+	 * defaults, sometimes adjusted.
+	 */
+
+	seg->transaction_id = 0;
+	seg->chunk_size = chunk_size;
+
+	if (to_cachepool) {
+		cache_mode_t cache_mode = 0;
+		const char *policy_name = NULL;
+		struct dm_config_tree *policy_settings = NULL;
+
+		if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
+			return_0;
+
+		if (cache_mode &&
+		    !cache_set_cache_mode(seg, cache_mode))
+			return_0;
+
+		if ((policy_name || policy_settings) &&
+		    !cache_set_policy(seg, policy_name, policy_settings))
+			return_0;
+
+		if (policy_settings)
+			dm_config_destroy(policy_settings);
+	} else {
+		const char *discards_name;
+
+		if (arg_is_set(cmd, zero_ARG))
+			seg->zero_new_blocks = arg_int_value(cmd, zero_ARG, 0);
+		else
+			seg->zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, vg->profile);
+
+		if (arg_is_set(cmd, discards_ARG))
+			seg->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
+		else {
+			if (!(discards_name = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, vg->profile)))
+				return_0;
+			if (!set_pool_discards(&seg->discards, discards_name))
+				return_0;
+		}
+	}
+
+	/*
+	 * Rename deactivated metadata LV to have _tmeta suffix.
+	 * Implicit checks if metadata_lv is visible.
+	 */
+	if (pool_metadata_name &&
+	    !lv_rename_update(cmd, metadata_lv, meta_name, 0))
+		return_0;
+
+	if (!attach_pool_metadata_lv(seg, metadata_lv))
+		return_0;
+
+	if (!handle_pool_metadata_spare(vg,
+					metadata_lv->le_count,
+					use_pvh,
+					arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE)))
+		return_0;
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	if (seg->zero_new_blocks &&
+	    seg->chunk_size >= DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2)
+		log_warn("WARNING: Pool zeroing and large %s chunk size slows down provisioning.",
+			 display_size(cmd, seg->chunk_size));
+
+	if (activate_pool && !lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
+		log_error("Failed to lock pool LV %s.", display_lvname(pool_lv));
+		goto out;
+	}
+
+	if (activate_pool &&
+	    !activate_lv_excl(cmd, pool_lv)) {
+		log_error("Failed to activate pool logical volume %s.",
+			  display_lvname(pool_lv));
+		/* Deactivate subvolumes */
+		if (!deactivate_lv(cmd, seg_lv(seg, 0)))
+			log_error("Failed to deactivate pool data logical volume %s.",
+				  display_lvname(seg_lv(seg, 0)));
+		if (!deactivate_lv(cmd, seg->metadata_lv))
+			log_error("Failed to deactivate pool metadata logical volume %s.",
+				  display_lvname(seg->metadata_lv));
+		goto out;
+	}
+
+	r = 1;
+
+out:
+	backup(vg);
+
+	if (r)
+		log_print_unless_silent("Converted %s to %s pool.",
+					display_lvname(lv),
+					to_cachepool ? "cache" : "thin");
+
+	/*
+	 * Unlock and free the locks from existing LVs that became pool data
+	 * and meta LVs.
+	 */
+	if (lockd_data_name) {
+		if (!lockd_lv_name(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args, "un", LDLV_PERSISTENT))
+			log_error("Failed to unlock pool data LV %s/%s", vg->name, lockd_data_name);
+		lockd_free_lv(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args);
+	}
+
+	if (lockd_meta_name) {
+		if (!lockd_lv_name(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args, "un", LDLV_PERSISTENT))
+			log_error("Failed to unlock pool metadata LV %s/%s", vg->name, lockd_meta_name);
+		lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args);
+	}
+
+	return r;
+#if 0
+revert_new_lv:
+	/* TBD */
+	if (!pool_metadata_lv_name) {
+		if (!deactivate_lv(cmd, metadata_lv)) {
+			log_error("Failed to deactivate metadata lv.");
+			return 0;
+		}
+		if (!lv_remove(metadata_lv) || !vg_write(vg) || !vg_commit(vg))
+			log_error("Manual intervention may be required to remove "
+				  "abandoned LV(s) before retrying.");
+		else
+			backup(vg);
+	}
+
+	return 0;
+#endif
+}
+
+/*
+ * Convert origin into a cache LV by attaching a cache pool.
+ */
+static int _lvconvert_cache(struct cmd_context *cmd,
+			    struct logical_volume *origin_lv,
+			    struct lvconvert_params *lp)
+{
+	struct logical_volume *pool_lv = lp->pool_data_lv;
+	struct logical_volume *cache_lv;
+
+	if (!validate_lv_cache_create_pool(pool_lv))
+		return_0;
+
+	if (!archive(origin_lv->vg))
+		return_0;
+
+	if (!(cache_lv = lv_cache_create(pool_lv, origin_lv)))
+		return_0;
+
+	if (!cache_set_cache_mode(first_seg(cache_lv), lp->cache_mode))
+		return_0;
+
+	if (!cache_set_policy(first_seg(cache_lv), lp->policy_name, lp->policy_settings))
+		return_0;
+
+	cache_check_for_warns(first_seg(cache_lv));
+
+	if (!lv_update_and_reload(cache_lv))
+		return_0;
+
+	log_print_unless_silent("Logical volume %s is now cached.",
+				display_lvname(cache_lv));
+
+	return 1;
+}
+
+static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
+			    struct logical_volume *lv,
+			    struct logical_volume *cachepool_lv)
 {
-	struct logical_volume *pool_lv = lp->pool_data_lv;
 	struct logical_volume *cache_lv;
+	cache_mode_t cache_mode = 0;
+	const char *policy_name = NULL;
+	struct dm_config_tree *policy_settings = NULL;
 
-	if (!validate_lv_cache_create_pool(pool_lv))
+	if (!validate_lv_cache_create_pool(cachepool_lv))
 		return_0;
 
-	if (!archive(origin_lv->vg))
+	if (!get_cache_params(cmd, &cache_mode, &policy_name, &policy_settings))
 		return_0;
 
-	if (!(cache_lv = lv_cache_create(pool_lv, origin_lv)))
+	if (!archive(lv->vg))
 		return_0;
 
-	if (!cache_set_cache_mode(first_seg(cache_lv), lp->cache_mode))
+	if (!(cache_lv = lv_cache_create(cachepool_lv, lv)))
 		return_0;
 
-	if (!cache_set_policy(first_seg(cache_lv), lp->policy_name, lp->policy_settings))
+	if (!cache_set_cache_mode(first_seg(cache_lv), cache_mode))
+		return_0;
+
+	if (!cache_set_policy(first_seg(cache_lv), policy_name, policy_settings))
 		return_0;
 
+	if (policy_settings)
+		dm_config_destroy(policy_settings);
+
 	cache_check_for_warns(first_seg(cache_lv));
 
 	if (!lv_update_and_reload(cache_lv))
@@ -3420,7 +4246,7 @@ static int _convert_cow_snapshot_merge(struct cmd_context *cmd, struct logical_v
 static int _convert_thin_volume_merge(struct cmd_context *cmd, struct logical_volume *lv,
 				      struct lvconvert_params *lp)
 {
-	return _lvconvert_merge_thin_snapshot(cmd, lv, lp);
+	return _lvconvert_merge_thin_snapshot(cmd, lv);
 }
 
 /*
@@ -3439,7 +4265,8 @@ static int _convert_thin_pool_splitcache(struct cmd_context *cmd, struct logical
 		return 0;
 	}
 
-	return _lvconvert_split_cached(cmd, sublv1);
+	/* return _lvconvert_split_cached(cmd, sublv1); */
+	return 0;
 }
 
 /*
@@ -3458,7 +4285,8 @@ static int _convert_thin_pool_uncache(struct cmd_context *cmd, struct logical_vo
 		return 0;
 	}
 
-	return _lvconvert_uncache(cmd, sublv1, lp);
+	/* return _lvconvert_uncache(cmd, sublv1, lp); */
+	return 0;
 }
 
 /*
@@ -3507,7 +4335,8 @@ static int _convert_thin_pool_swapmetadata(struct cmd_context *cmd, struct logic
 static int _convert_cache_volume_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
 					    struct lvconvert_params *lp)
 {
-	return _lvconvert_split_cached(cmd, lv);
+	/* return _lvconvert_split_cached(cmd, lv); */
+	return 0;
 }
 
 /*
@@ -3517,7 +4346,8 @@ static int _convert_cache_volume_splitcache(struct cmd_context *cmd, struct logi
 static int _convert_cache_volume_uncache(struct cmd_context *cmd, struct logical_volume *lv,
 					 struct lvconvert_params *lp)
 {
-	return _lvconvert_uncache(cmd, lv, lp);
+	/* return _lvconvert_uncache(cmd, lv, lp); */
+	return 0;
 }
 
 /*
@@ -3630,7 +4460,8 @@ static int _convert_cache_pool_splitcache(struct cmd_context *cmd, struct logica
 		return 0;
 	}
 
-	return _lvconvert_split_cached(cmd, sublv1);
+	/* return _lvconvert_split_cached(cmd, sublv1); */
+	return 0;
 }
 
 /*
@@ -5120,3 +5951,449 @@ int lvconvert_start_poll_cmd(struct cmd_context *cmd, int argc, char **argv)
 	return ret;
 }
 
+static int _lvconvert_to_pool_single(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct processing_handle *handle)
+{
+	struct dm_list *use_pvh = NULL;
+	int to_thinpool = 0;
+	int to_cachepool = 0;
+
+	switch (cmd->command->command_line_enum) {
+	case lvconvert_to_thinpool_CMD:
+		to_thinpool = 1;
+		break;
+	case lvconvert_to_cachepool_CMD:
+		to_cachepool = 1;
+		break;
+	default:
+		log_error(INTERNAL_ERROR "Invalid lvconvert pool command");
+		return 0;
+	};
+
+	if (cmd->position_argc > 1) {
+		/* First pos arg is required LV, remaining are optional PVs. */
+		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))
+			return_ECMD_FAILED;
+	} else
+		use_pvh = &lv->vg->pvs;
+
+	if (!_lvconvert_to_pool(cmd, lv, to_thinpool, to_cachepool, use_pvh))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+/*
+ * The LV position arg is used as thinpool/cachepool data LV.
+ */
+
+int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_to_pool_single);
+}
+
+/*
+ * Reformats non-standard command form into standard command form.
+ *
+ * In the command variants with no position LV arg, the LV arg is taken from
+ * the --thinpool/--cachepool arg, and the position args are modified to match
+ * the standard command form.
+ */
+
+int lvconvert_to_pool_noarg_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct command *new_command;
+	char *pool_data_name;
+	int i, p;
+
+	switch (cmd->command->command_line_enum) {
+	case lvconvert_to_thinpool_noarg_CMD:
+		pool_data_name = (char *)arg_str_value(cmd, thinpool_ARG, NULL);
+		new_command = get_command(lvconvert_to_thinpool_CMD);
+		break;
+	case lvconvert_to_cachepool_noarg_CMD:
+		pool_data_name = (char *)arg_str_value(cmd, cachepool_ARG, NULL);
+		new_command = get_command(lvconvert_to_cachepool_CMD);
+		break;
+	default:
+		log_error(INTERNAL_ERROR "Unknown pool conversion.");
+		return 0;
+	};
+
+	log_debug("Changing command line id %s %d to standard form %s %d",
+		  cmd->command->command_line_id, cmd->command->command_line_enum,
+		  new_command->command_line_id, new_command->command_line_enum);
+
+	/* Make the LV the first position arg. */
+
+	p = cmd->position_argc;
+	for (i = 0; i < cmd->position_argc; i++)
+		cmd->position_argv[p] = cmd->position_argv[p-1];
+
+	cmd->position_argv[0] = pool_data_name;
+	cmd->position_argc++;
+	cmd->command = new_command;
+
+	return lvconvert_to_pool_cmd(cmd, argc, argv);
+}
+
+static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct processing_handle *handle)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *cachepool_lv;
+	const char *cachepool_name;
+	uint32_t chunk_size = 0;
+
+	if (!(cachepool_name = arg_str_value(cmd, cachepool_ARG, NULL)))
+		goto_out;
+
+	if (!validate_lvname_param(cmd, &vg->name, &cachepool_name))
+		goto_out;
+
+	if (!(cachepool_lv = find_lv(vg, cachepool_name))) {
+		log_error("Cache pool %s not found.", cachepool_name);
+		goto out;
+	}
+
+	/*
+	 * If cachepool_lv is not yet a cache pool, convert it to one.
+	 * If using an existing cache pool, wipe it.
+	 */
+
+	if (!lv_is_cache_pool(cachepool_lv)) {
+		int lvt_enum = get_lvt_enum(cachepool_lv);
+		struct lv_types *lvtype = get_lv_type(lvt_enum);
+
+		if (lvt_enum != striped_LVT && lvt_enum != linear_LVT && lvt_enum != raid_LVT) {
+			log_error("LV %s with type %s cannot be converted to a cache pool.",
+				  display_lvname(cachepool_lv), lvtype ? lvtype->name : "unknown");
+			goto out;
+		}
+
+		if (!_lvconvert_to_pool(cmd, cachepool_lv, 0, 1, &vg->pvs)) {
+			log_error("LV %s could not be converted to a cache pool.",
+				  display_lvname(cachepool_lv));
+			goto out;
+		}
+
+		if (!(cachepool_lv = find_lv(vg, cachepool_name))) {
+			log_error("LV %s cannot be found.", display_lvname(cachepool_lv));
+			goto out;
+		}
+
+		if (!lv_is_cache_pool(cachepool_lv)) {
+			log_error("LV %s is not a cache pool.", display_lvname(cachepool_lv));
+			goto out;
+		}
+	} else {
+		if (!dm_list_empty(&cachepool_lv->segs_using_this_lv)) {
+			log_error("Cache pool %s is already in use.", cachepool_name);
+			goto out;
+		}
+
+		if (arg_is_set(cmd, chunksize_ARG))
+			chunk_size = arg_uint_value(cmd, chunksize_ARG, 0);
+		if (!chunk_size)
+			chunk_size = first_seg(cachepool_lv)->chunk_size;
+
+		/* FIXME: why is chunk_size read and checked if it's not used? */
+
+		if (!validate_lv_cache_chunk_size(cachepool_lv, chunk_size))
+			goto_out;
+
+		/* Note: requires rather deep know-how to skip zeroing */
+		if (!arg_is_set(cmd, zero_ARG)) {
+		       	if (!arg_is_set(cmd, yes_ARG) &&
+			    yes_no_prompt("Do you want wipe existing metadata of cache pool %s? [y/n]: ",
+					  display_lvname(cachepool_lv)) == 'n') {
+				log_error("Conversion aborted.");
+				log_error("To preserve cache metadata add option \"--zero n\".");
+				log_warn("WARNING: Reusing mismatched cache pool metadata MAY DESTROY YOUR DATA!");
+				goto out;
+			}
+			/* Wiping confirmed, go ahead */
+			if (!wipe_cache_pool(cachepool_lv))
+				goto_out;
+		} else if (arg_int_value(cmd, zero_ARG, 0)) {
+			if (!wipe_cache_pool(cachepool_lv))
+				goto_out;
+		} else {
+			log_warn("WARNING: Reusing cache pool metadata %s for volume caching.",
+				 display_lvname(cachepool_lv));
+		}
+
+	}
+
+	/* When the lv arg is a thinpool, redirect command to data sub lv. */
+
+	if (lv_is_thin_pool(lv)) {
+		lv = seg_lv(first_seg(lv), 0);
+		log_verbose("Redirecting operation to data sub LV %s.", display_lvname(lv));
+	}
+
+	/* Convert lv to cache vol using cachepool_lv. */
+
+	if (!_lvconvert_to_cache_vol(cmd, lv, cachepool_lv))
+		goto_out;
+
+	return ECMD_PROCESSED;
+
+ out:
+	return ECMD_FAILED;
+}
+
+int lvconvert_to_cache_vol_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_to_cache_vol_single);
+}
+
+static int _lvconvert_to_thin_with_external_single(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct processing_handle *handle)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *thinpool_lv;
+	const char *thinpool_name;
+
+	if (!(thinpool_name = arg_str_value(cmd, thinpool_ARG, NULL)))
+		goto_out;
+
+	if (!validate_lvname_param(cmd, &vg->name, &thinpool_name))
+		goto_out;
+
+	if (!(thinpool_lv = find_lv(vg, thinpool_name))) {
+		log_error("Thin pool %s not found.", thinpool_name);
+		goto out;
+	}
+
+	/* If thinpool_lv is not yet a thin pool, convert it to one. */
+
+	if (!lv_is_thin_pool(thinpool_lv)) {
+		int lvt_enum = get_lvt_enum(thinpool_lv);
+		struct lv_types *lvtype = get_lv_type(lvt_enum);
+
+		if (lvt_enum != striped_LVT && lvt_enum != linear_LVT && lvt_enum != raid_LVT) {
+			log_error("LV %s with type %s cannot be converted to a thin pool.",
+				  display_lvname(thinpool_lv), lvtype ? lvtype->name : "unknown");
+			goto out;
+		}
+
+		if (!_lvconvert_to_pool(cmd, thinpool_lv, 1, 0, &vg->pvs)) {
+			log_error("LV %s could not be converted to a thin pool.",
+				  display_lvname(thinpool_lv));
+			goto out;
+		}
+
+		if (!(thinpool_lv = find_lv(vg, thinpool_name))) {
+			log_error("LV %s cannot be found.", display_lvname(thinpool_lv));
+			goto out;
+		}
+
+		if (!lv_is_thin_pool(thinpool_lv)) {
+			log_error("LV %s is not a thin pool.", display_lvname(thinpool_lv));
+			goto out;
+		}
+	}
+
+	/* If lv is a cache volume, all data must be flushed. */
+
+	if (lv_is_cache(lv)) {
+		const struct lv_segment *pool_seg = first_seg(first_seg(lv)->pool_lv);
+		int is_clean;
+
+		if (pool_seg->cache_mode != CACHE_MODE_WRITETHROUGH) {
+			log_error("Cannot convert cache volume %s with %s cache mode to external origin.",
+				  display_lvname(lv), get_cache_mode_name(pool_seg));
+			log_error("To proceed, run 'lvchange --cachemode writethrough %s'.",
+				  display_lvname(lv));
+			goto out;
+		}
+
+		if (!lv_cache_wait_for_clean(lv, &is_clean))
+			goto_out;
+
+		if (!is_clean) {
+			log_error("Cache %s is not clean, refusing to convert to external origin.",
+				  display_lvname(lv));
+			goto out;
+		}
+	}
+
+	/* Convert lv to thin with external origin using thinpool_lv. */
+
+	if (!_lvconvert_to_thin_with_external(cmd, lv, thinpool_lv))
+		goto_out;
+
+	return ECMD_PROCESSED;
+
+ out:
+	return ECMD_FAILED;
+}
+
+int lvconvert_to_thin_with_external_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_to_thin_with_external_single);
+}
+
+static int _lvconvert_swap_pool_metadata_single(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct processing_handle *handle)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *metadata_lv;
+	const char *metadata_name;
+
+	if (!(metadata_name = arg_str_value(cmd, poolmetadata_ARG, NULL)))
+		goto_out;
+
+	if (!validate_lvname_param(cmd, &vg->name, &metadata_name))
+		goto_out;
+
+	if (!(metadata_lv = find_lv(vg, metadata_name))) {
+		log_error("Metadata LV %s not found.", metadata_name);
+		goto out;
+	}
+
+	if (metadata_lv == lv) {
+		log_error("Can't use same LV for pool data and metadata LV %s.",
+			  display_lvname(metadata_lv));
+		goto out;
+	}
+
+	if (!_lvconvert_swap_pool_metadata(cmd, lv, metadata_lv))
+		goto_out;
+
+	return ECMD_PROCESSED;
+
+ out:
+	return ECMD_FAILED;
+}
+
+int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_swap_pool_metadata_single);
+}
+
+#if 0
+int lvconvert_swap_pool_metadata_noarg_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct command *new_command;
+	char *pool_name;
+
+	switch (cmd->command->command_line_enum) {
+	case lvconvert_swap_thinpool_metadata_CMD:
+		pool_name = (char *)arg_str_value(cmd, thinpool_ARG, NULL);
+		break;
+	case lvconvert_swap_cachepool_metadata_CMD:
+		pool_name = (char *)arg_str_value(cmd, cachepool_ARG, NULL);
+		break;
+	default:
+		log_error(INTERNAL_ERROR "Unknown pool conversion.");
+		return 0;
+	};
+
+	new_command = get_command(lvconvert_swap_pool_metadata_CMD);
+
+	log_debug("Changing command line id %s %d to standard form %s %d",
+		  cmd->command->command_line_id, cmd->command->command_line_enum,
+		  new_command->command_line_id, new_command->command_line_enum);
+
+	/* Make the LV the first position arg. */
+
+	cmd->position_argv[0] = pool_name;
+	cmd->position_argc++;
+	cmd->command = new_command;
+
+	return lvconvert_swap_pool_metadata_cmd(cmd, argc, argv);
+}
+#endif
+
+static int _lvconvert_merge_thin_single(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct processing_handle *handle)
+{
+	if (!_lvconvert_merge_thin_snapshot(cmd, lv))
+		return ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_merge_thin_single);
+}
+
+static int _lvconvert_split_cachepool_single(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct processing_handle *handle)
+{
+	struct logical_volume *cache_lv = NULL;
+	struct logical_volume *cachepool_lv = NULL;
+	struct lv_segment *seg;
+	int ret;
+
+	if (lv_is_cache(lv)) {
+		cache_lv = lv;
+		cachepool_lv = first_seg(cache_lv)->pool_lv;
+
+	} else if (lv_is_cache_pool(lv)) {
+		cachepool_lv = lv;
+
+		if ((dm_list_size(&cachepool_lv->segs_using_this_lv) == 1) &&
+		    (seg = get_only_segment_using_this_lv(cachepool_lv)) &&
+		    seg_is_cache(seg))
+			cache_lv = seg->lv;
+
+	} else if (lv_is_thin_pool(lv)) {
+		cache_lv = seg_lv(first_seg(lv), 0); /* cached _tdata */
+		cachepool_lv = first_seg(cache_lv)->pool_lv;
+	}
+
+	if (!cache_lv) {
+		log_error("Cannot find cache LV from %s.", display_lvname(lv));
+		return ECMD_FAILED;
+	}
+
+	if (!cachepool_lv) {
+		log_error("Cannot find cache pool LV from %s.", display_lvname(lv));
+		return ECMD_FAILED;
+	}
+
+	switch (cmd->command->command_line_enum) {
+	case lvconvert_split_and_keep_cachepool_CMD:
+		ret = _lvconvert_split_and_keep_cachepool(cmd, cache_lv, cachepool_lv);
+		break;
+
+	case lvconvert_split_and_remove_cachepool_CMD:
+		ret = _lvconvert_split_and_remove_cachepool(cmd, cache_lv, cachepool_lv);
+		break;
+	default:
+		log_error(INTERNAL_ERROR "Unknown cache pool split.");
+		ret = 0;
+	}
+
+	if (!ret)
+		return ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	if (cmd->command->command_line_enum == lvconvert_split_and_remove_cachepool_CMD) {
+		cmd->handles_missing_pvs = 1;
+		cmd->partial_activation = 1;
+	}
+
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_split_cachepool_single);
+}
+
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 83deaf1..85fd1b8 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -134,30 +134,29 @@ struct command_function command_functions[COMMAND_ID_COUNT] = {
 
 	/* lvconvert utility to trigger polling on an LV. */
 	{ lvconvert_start_poll_CMD, lvconvert_start_poll_cmd },
+
+	/* lvconvert utilities for creating/maintaining thin and cache objects. */
+	{ lvconvert_to_thinpool_CMD,			lvconvert_to_pool_cmd },
+	{ lvconvert_to_thinpool_noarg_CMD,		lvconvert_to_pool_noarg_cmd },
+	{ lvconvert_to_cachepool_CMD,			lvconvert_to_pool_cmd },
+	{ lvconvert_to_cachepool_noarg_CMD,		lvconvert_to_pool_noarg_cmd },
+	{ lvconvert_to_thin_with_external_CMD,		lvconvert_to_thin_with_external_cmd },
+	{ lvconvert_to_cache_vol_CMD,			lvconvert_to_cache_vol_cmd },
+	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_cmd },
+	{ lvconvert_merge_thin_CMD,			lvconvert_merge_thin_cmd },
+	{ lvconvert_split_and_keep_cachepool_CMD,	lvconvert_split_cachepool_cmd },
+	{ lvconvert_split_and_remove_cachepool_CMD,	lvconvert_split_cachepool_cmd },
 };
 
 #if 0
 	/* all raid-related type conversions */
-
 	{ lvconvert_raid_types_CMD,			lvconvert_raid_types_fn },
 
 	/* raid-related utilities (move into lvconvert_raid_types?) */
-
 	{ lvconvert_split_mirror_images_CMD,		lvconvert_split_mirror_images_fn },
 	{ lvconvert_change_mirrorlog_CMD,		lvconvert_change_mirrorlog_fn },
 
-	/* utilities for creating/maintaining thin and cache objects. */
-
-	{ lvconvert_to_thin_with_external_CMD,		lvconvert_to_thin_with_external_fn },
-	{ lvconvert_to_cache_vol_CMD,			lvconvert_to_cache_vol_fn },
-	{ lvconvert_to_thinpool_CMD,			lvconvert_to_thinpool_fn },
-	{ lvconvert_to_cachepool_CMD,			lvconvert_to_cachepool_fn },
-	{ lvconvert_split_and_keep_cachepool_CMD,	lvconvert_split_and_keep_cachepool_fn },
-	{ lvconvert_split_and_delete_cachepool_CMD,	lvconvert_split_and_delete_cachepool_fn },
-	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_fn },
-
-	/* other misc. */
-
+	/* directed to one of the other merges (snap,thin,mirror) when all are implemented */
 	{ lvconvert_merge_CMD,				lvconvert_merge_fn },
 #endif
 
@@ -1136,6 +1135,18 @@ struct lv_types *get_lv_type(int lvt_enum)
 	return &_lv_types[lvt_enum];
 }
 
+struct command *get_command(int cmd_enum)
+{
+	int i;
+
+	for (i = 0; i < COMMAND_COUNT; i++) {
+		if (commands[i].command_line_enum == cmd_enum)
+			return &commands[i];
+	}
+
+	return NULL;
+}
+
 /*
  * Also see merge_synonym().  The command definitions
  * are written using just one variation of the option
diff --git a/tools/toollib.c b/tools/toollib.c
index 13e9b6f..6f9e294 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2539,7 +2539,7 @@ static int _lv_is_type(struct cmd_context *cmd, struct logical_volume *lv, int l
 	return 0;
 }
 
-static int _get_lvt_enum(struct logical_volume *lv)
+int get_lvt_enum(struct logical_volume *lv)
 {
 	struct lv_segment *seg = first_seg(lv);
 
@@ -2700,7 +2700,7 @@ static int _check_lv_types(struct cmd_context *cmd, struct logical_volume *lv, i
 
 	ret = _lv_types_match(cmd, lv, cmd->command->required_pos_args[pos-1].def.lvt_bits, NULL, NULL);
 	if (!ret) {
-		int lvt_enum = _get_lvt_enum(lv);
+		int lvt_enum = get_lvt_enum(lv);
 		struct lv_types *type = get_lv_type(lvt_enum);
 		log_warn("Operation on LV %s which has invalid type %s.",
 			 display_lvname(lv), type ? type->name : "unknown");
@@ -2723,7 +2723,7 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 	int ret = 1;
 	int i;
 
-	lvt_enum = _get_lvt_enum(lv);
+	lvt_enum = get_lvt_enum(lv);
 	if (lvt_enum)
 		lvtype = get_lv_type(lvt_enum);
 
diff --git a/tools/toollib.h b/tools/toollib.h
index 67e45a2..504721e 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -240,4 +240,6 @@ int validate_restricted_lvname_param(struct cmd_context *cmd, const char **vg_na
 int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
                     struct processing_handle *handle __attribute__((unused)));
 
+int get_lvt_enum(struct logical_volume *lv);
+
 #endif
diff --git a/tools/tools.h b/tools/tools.h
index a152fcf..f310570 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -241,6 +241,7 @@ int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg
 
 struct lv_props *get_lv_prop(int lvp_enum);
 struct lv_types *get_lv_type(int lvt_enum);
+struct command *get_command(int cmd_enum);
 
 int lvchange_properties_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv);
@@ -260,4 +261,12 @@ int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char
 
 int lvconvert_start_poll_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_to_pool_noarg_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_to_cache_vol_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_to_thin_with_external_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 #endif


