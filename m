From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:07 +0000 (UTC)
Subject: master - lvconvert: snapshot: use command definitions
Message-ID: <20170213181007.BC74360EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa2a728a395639a32707bb75e6bb4197b02769de
Commit:        fa2a728a395639a32707bb75e6bb4197b02769de
Parent:        254bffb95d6330662632eda472991b2fc0008d94
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 18 13:16:04 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvconvert: snapshot: use command definitions

Lift all the snapshot utilities (merge, split, combine)
out of the monolithic lvconvert implementation, using
the command definitions.  The old code associated with
these commands is now unused and will be removed separately.
---
 test/shell/lvconvert-cache-snapshot.sh             |    2 +-
 .../shell/lvmetad-pvscan-autoactivation-polling.sh |    2 +-
 test/shell/snapshot-merge-stack.sh                 |    2 +-
 test/shell/snapshot-merge.sh                       |   16 +-
 test/shell/thin-merge.sh                           |    2 +-
 tools/args.h                                       |    1 +
 tools/command-lines.in                             |   64 +++--
 tools/lvconvert.c                                  |  313 +++++++++++++-------
 tools/lvmcmdline.c                                 |   11 +-
 tools/tools.h                                      |    4 +
 10 files changed, 277 insertions(+), 140 deletions(-)

diff --git a/test/shell/lvconvert-cache-snapshot.sh b/test/shell/lvconvert-cache-snapshot.sh
index 8f0ab53..4ecec70 100644
--- a/test/shell/lvconvert-cache-snapshot.sh
+++ b/test/shell/lvconvert-cache-snapshot.sh
@@ -33,7 +33,7 @@ lvcreate -L3 -n cow $vg
 not lvconvert -s cow $vg/$lv1
 
 # Use cached LV with 'striped' cow volume
-lvconvert -y -s $vg/$lv1 cow
+lvconvert -y -s $vg/$lv1 $vg/cow
 check lv_field $vg/cow segtype linear
 check lv_field $vg/$lv1 segtype cache
 
diff --git a/test/shell/lvmetad-pvscan-autoactivation-polling.sh b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
index 34139df..58afbed 100644
--- a/test/shell/lvmetad-pvscan-autoactivation-polling.sh
+++ b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
@@ -54,7 +54,7 @@ mkdir test_mnt
 
 setup_merge_ $vg1 $lv1
 mount "$(lvdev_ $vg1 $lv1)" test_mnt
-lvconvert --merge $vg1/$(snap_lv_name_ $lv1)
+lvconvert --mergesnapshot $vg1/$(snap_lv_name_ $lv1)
 umount test_mnt
 vgchange -an $vg1
 
diff --git a/test/shell/snapshot-merge-stack.sh b/test/shell/snapshot-merge-stack.sh
index 2fdfaa4..f9d2e62 100644
--- a/test/shell/snapshot-merge-stack.sh
+++ b/test/shell/snapshot-merge-stack.sh
@@ -32,7 +32,7 @@ snap_and_merge() {
 	SLEEP_PID=$(aux hold_device_open $vg $lv1 20)
 
 	# initiate background merge
-	lvconvert -b --merge $vg/$lv2
+	lvconvert -b --mergesnapshot $vg/$lv2
 
 	lvs -a -o+lv_merging,lv_merge_failed $vg
 	get lv_field $vg/$lv1 lv_attr | grep "Owi-ao"
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index a301d22..0d3e1cb 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -51,15 +51,15 @@ mkdir test_mnt
 # test full merge of a single LV
 setup_merge_ $vg $lv1
 
-# make sure lvconvert --merge requires explicit LV listing
-not lvconvert --merge
-lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+# make sure lvconvert --mergesnapshot requires explicit LV listing
+not lvconvert --mergesnapshot
+lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
 
 # test that an actively merging snapshot may not be removed
 setup_merge_ $vg $lv1
-lvconvert -i+100 --merge --background $vg/$(snap_lv_name_ $lv1)
+lvconvert -i+100 --mergesnapshot --background $vg/$(snap_lv_name_ $lv1)
 not lvremove -f $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
@@ -67,7 +67,7 @@ lvremove -f $vg/$lv1
 # "onactivate merge" test
 setup_merge_ $vg $lv1
 mount "$(lvdev_ $vg $lv1)" test_mnt
-lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
 # -- refresh LV while FS is still mounted (merge must not start),
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
@@ -88,7 +88,7 @@ lvremove -f $vg/$lv1
 #    to make sure preload of origin's metadata is _not_ performed
 setup_merge_ $vg $lv1
 mount "$(lvdev_ $vg $lv1)" test_mnt
-lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
 # -- refresh LV while FS is still mounted (merge must not start),
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
@@ -99,7 +99,7 @@ lvremove -f $vg/$lv1
 
 # test multiple snapshot merge; tests copy out that is driven by merge
 setup_merge_ $vg $lv1 1
-lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+lvconvert --mergesnapshot $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
 
@@ -108,7 +108,7 @@ setup_merge_ $vg $lv1
 setup_merge_ $vg $lv2
 lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv1)
 lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv2)
-lvconvert --merge @this_is_a_test
+lvconvert --mergesnapshot @this_is_a_test
 lvs $vg | tee out
 not grep $(snap_lv_name_ $lv1) out
 not grep $(snap_lv_name_ $lv2) out
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index f044f57..b3ad007 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -102,7 +102,7 @@ lvcreate -s -n snap $vg/$lv1
 lvcreate -s -L10 -n oldsnapof_${lv1} $vg/$lv1
 not lvconvert --merge $vg/snap
 $MKFS "$DM_DEV_DIR/$vg/oldsnapof_${lv1}"
-lvconvert --merge $vg/oldsnapof_${lv1}
+lvconvert --mergesnapshot $vg/oldsnapof_${lv1}
 fsck -n "$DM_DEV_DIR/$vg/$lv1"
 check lv_not_exists $vg oldsnapof_${lv1}
 # Add old snapshot to thin snapshot
diff --git a/tools/args.h b/tools/args.h
index 8f5f0ec..a015318 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -60,6 +60,7 @@ arg(locktype_ARG, '\0', "locktype", locktype_VAL, 0, 0)
 arg(logonly_ARG, '\0', "logonly", 0, 0, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", sizekb_VAL, 0, 0)
 arg(merge_ARG, '\0', "merge", 0, 0, 0)
+arg(mergesnapshot_ARG, '\0', "mergesnapshot", 0, 0, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", 0, 0, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_VAL, 0, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", bool_VAL, 0, 0)
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 597ebc5..98623a1 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -476,9 +476,6 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-# lvconvert utilities related to snapshots and repair.
-# Create a new command set for these and migrate them out of lvconvert?
-
 # FIXME: lvconvert --merge is an extremely ambiguous command.
 # It can do very different operations, but which one depends
 # on knowing the LV type.  So, the command doesn't know what
@@ -509,29 +506,61 @@ ID: lvconvert_merge
 DESC: Merge LV that was previously split from a mirror.
 DESC: Merge thin LV into its origin LV.
 DESC: Merge COW snapshot LV into its origin.
-RULE: all not lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
+RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
+
+---
+
+# lvconvert snapshot-related utilities
+# Create a new command set for these and migrate them out of lvconvert?
+
+lvconvert --mergesnapshot LV_snapshot ...
+OO: --background, --interval Number, OO_LVCONVERT
+ID: lvconvert_merge_snapshot
+DESC: Merge LV that was previously split from a mirror.
+RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
+RULE: all and lv_is_visible
+
+---
+
+lvconvert --splitsnapshot LV_snapshot
+OO: OO_LVCONVERT
+ID: lvconvert_split_cow_snapshot
+DESC: Separate a COW snapshot from its origin LV.
+RULE: all not lv_is_locked lv_is_pvmove lv_is_origin lv_is_external_origin lv_is_merging_cow
 
 ---
 
-# FIXME: by using two different positional args, this is the
-# single violation of the standard method of using process_each_lv().
-# Before calling process_each, it steals the first positional arg
-# and adjusts argv/argc so it's not seen by process_each.
+# NB: an unsual use of position args here, the first pos arg
+# (will become origin LV) is not passed to process_each,
+# the second pos arg (will become cow LV) is given to
+# process_each.  Because the first pos LV is not handled
+# by process_each_lv, it cannot be checked against this
+# command def, so a specific LV type in the first pos
+# will not be checked.
 
 # alternate form of lvconvert --snapshot
-lvconvert --type snapshot LV_linear_striped_raid LV_snapshot
+lvconvert --type snapshot LV LV_linear
 OO: --snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT
 ID: lvconvert_combine_split_snapshot
-DESC: Combine LV with a previously split snapshot LV.
+DESC: Combine a former COW snapshot (second arg) with a former
+DESC: origin LV (first arg) to reverse a splitsnapshot command.
 FLAGS: SECONDARY_SYNTAX
+RULE: all not lv_is_locked lv_is_pvmove
+RULE: all and lv_is_visible
 
-lvconvert --snapshot LV_linear_striped_raid LV_snapshot
+lvconvert --snapshot LV LV_linear
 OO: --type snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT
 ID: lvconvert_combine_split_snapshot
-DESC: Combine LV with a previously split snapshot LV.
+DESC: Combine a former COW snapshot (second arg) with a former
+DESC: origin LV (first arg) to reverse a splitsnapshot command.
+RULE: all not lv_is_locked lv_is_pvmove
+RULE: all and lv_is_visible
 
 ---
 
+# lvconvert repair/replace utilitiles
+# Create a new command set for these and migrate them out of lvconvert?
+
 # FIXME: use specific option names to distinguish these two
 # very different commands, e.g.
 #
@@ -552,21 +581,14 @@ OP: PV ...
 ID: lvconvert_repair_pvs_or_thinpool
 DESC: Replace failed PVs in a raid or mirror LV.
 DESC: Repair a thin pool.
-
----
+RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --replace PV LV_raid
 OO: OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_replace_pv
 DESC: Replace specific PV(s) in a raid* LV with another PV.
-
----
-
-lvconvert --splitsnapshot LV_snapshot
-OO: OO_LVCONVERT
-ID: lvconvert_split_cow_snapshot
-DESC: Separate a COW snapshot from its origin LV.
+RULE: all not lv_is_locked lv_is_pvmove
 
 ---
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1c5c6ff..9f3a475 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1999,37 +1999,16 @@ try_new_takeover_or_reshape:
 	return 0;
 }
 
-static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volume *cow,
-				    struct lvconvert_params *lp)
+static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volume *cow)
 {
 	struct volume_group *vg = cow->vg;
 	const char *cow_name = display_lvname(cow);
 
-	if (!lv_is_cow(cow)) {
-		log_error("%s is not a snapshot.", cow_name);
-		return 0;
-	}
-
-	if (lv_is_origin(cow) || lv_is_external_origin(cow)) {
-		log_error("Unable to split LV %s that is a snapshot origin.", cow_name);
-		return 0;
-	}
-
-	if (lv_is_merging_cow(cow)) {
-		log_error("Unable to split off snapshot %s being merged into its origin.", cow_name);
-		return 0;
-	}
-
 	if (lv_is_virtual_origin(origin_from_cow(cow))) {
 		log_error("Unable to split off snapshot %s with virtual origin.", cow_name);
 		return 0;
 	}
 
-	if (lv_is_thin_pool(cow) || lv_is_pool_metadata_spare(cow)) {
-		log_error("Unable to split off LV %s needed by thin volume(s).", cow_name);
-		return 0;
-	}
-
 	if (!(vg->fid->fmt->features & FMT_MDAS)) {
 		log_error("Unable to split off snapshot %s using old LVM1-style metadata.", cow_name);
 		return 0;
@@ -2041,19 +2020,12 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		return 0;
 	}
 
-	if (!vg_check_status(vg, LVM_WRITE))
-		return_0;
-
-	if (lv_is_pvmove(cow) || lv_is_mirror_type(cow) || lv_is_raid_type(cow) || lv_is_thin_type(cow)) {
-		log_error("LV %s type is unsupported with --splitsnapshot.", display_lvname(cow));
-		return 0;
-	}
-
 	if (lv_is_active_locally(cow)) {
 		if (!lv_check_not_in_use(cow, 1))
 			return_0;
 
-		if ((lp->force == PROMPT) && !lp->yes &&
+		if ((arg_count(cmd, force_ARG) == PROMPT) &&
+		    !arg_count(cmd, yes_ARG) &&
 		    lv_is_visible(cow) &&
 		    lv_is_active(cow)) {
 			if (yes_no_prompt("Do you really want to split off active "
@@ -2172,60 +2144,54 @@ static int _lvconvert_uncache(struct cmd_context *cmd,
 
 static int _lvconvert_snapshot(struct cmd_context *cmd,
 			       struct logical_volume *lv,
-			       struct lvconvert_params *lp)
+			       const char *origin_name)
 {
 	struct logical_volume *org;
 	const char *snap_name = display_lvname(lv);
+	uint32_t chunk_size;
+	int zero;
 
-	if (lv_is_cache_type(lv)) {
-		log_error("Snapshots are not yet supported with cache type LVs %s.",
-			  snap_name);
-		return 0;
-	}
-
-	if (lv_is_mirrored(lv)) {
-		log_error("Unable to convert mirrored LV %s into a snapshot.", snap_name);
+	if (!(org = find_lv(lv->vg, origin_name))) {
+		log_error("Couldn't find origin volume %s in Volume group %s.",
+			  origin_name, lv->vg->name);
 		return 0;
 	}
 
-	if (lv_is_origin(lv)) {
-		/* Unsupported stack */
-		log_error("Unable to convert origin %s into a snapshot.", snap_name);
+	if (org == lv) {
+		log_error("Unable to use %s as both snapshot and origin.", snap_name);
 		return 0;
 	}
 
-	if (lv_is_pool(lv)) {
-		log_error("Unable to convert pool LVs %s into a snapshot.", snap_name);
+	chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
+	if (chunk_size < 8 || chunk_size > 1024 || !is_power_of_2(chunk_size)) {
+		log_error("Chunk size must be a power of 2 in the range 4K to 512K.");
 		return 0;
 	}
+	log_verbose("Setting chunk size to %s.", display_size(cmd, chunk_size));
 
-	if (!(org = find_lv(lv->vg, lp->origin_name))) {
-		log_error("Couldn't find origin volume %s in Volume group %s.",
-			  lp->origin_name, lv->vg->name);
-		return 0;
-	}
+	if (!cow_has_min_chunks(lv->vg, lv->le_count, chunk_size))
+		return_0;
 
-	if (org == lv) {
-		log_error("Unable to use %s as both snapshot and origin.", snap_name);
+	/*
+	 * check_lv_rules() checks cannot be done via command definition
+	 * rules because this LV is not processed by process_each_lv.
+	 */
+	if (lv_is_locked(org) || lv_is_pvmove(org)) {
+		log_error("Unable to use LV %s as snapshot origin: LV is %s.",
+			  display_lvname(lv), lv_is_locked(org) ? "locked" : "pvmove");
 		return 0;
 	}
 
-	if (!cow_has_min_chunks(lv->vg, lv->le_count, lp->chunk_size))
-		return_0;
-
-	if (lv_is_locked(org) ||
-	    (lv_is_cache_type(org) && !lv_is_cache(org)) ||
+	/*
+	 * check_lv_types() checks cannot be done via command definition
+	 * LV_foo specification because this LV is not processed by process_each_lv.
+	 */
+	if ((lv_is_cache_type(org) && !lv_is_cache(org)) ||
 	    lv_is_thin_type(org) ||
-	    lv_is_pvmove(org) ||
 	    lv_is_mirrored(org) ||
 	    lv_is_cow(org)) {
-		log_error("Unable to convert an LV into a snapshot of a %s LV.",
-			  lv_is_locked(org) ? "locked" :
-			  lv_is_cache_type(org) ? "cache type" :
-			  lv_is_thin_type(org) ? "thin type" :
-			  lv_is_pvmove(org) ? "pvmove" :
-			  lv_is_mirrored(org) ? "mirrored" :
-			  "snapshot");
+		log_error("Unable to use LV %s as snapshot origin: invald LV type.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2233,7 +2199,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		 snap_name);
 	log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
 
-	if (!lp->yes &&
+	if (!arg_count(cmd, yes_ARG) &&
 	    yes_no_prompt("Do you really want to convert %s? [y/n]: ",
 			  snap_name) == 'n') {
 		log_error("Conversion aborted.");
@@ -2245,7 +2211,12 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!lp->zero || !(lv->status & LVM_WRITE))
+	if (first_seg(lv)->segtype->flags & SEG_CANNOT_BE_ZEROED)
+		zero = 0;
+	else
+		zero = arg_int_value(cmd, zero_ARG, 1);
+
+	if (!zero || !(lv->status & LVM_WRITE))
 		log_warn("WARNING: %s not zeroed.", snap_name);
 	else {
 		lv->status |= LV_TEMPORARY;
@@ -2265,7 +2236,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	if (!archive(lv->vg))
 		return_0;
 
-	if (!vg_add_snapshot(org, lv, NULL, org->le_count, lp->chunk_size)) {
+	if (!vg_add_snapshot(org, lv, NULL, org->le_count, chunk_size)) {
 		log_error("Couldn't create snapshot.");
 		return 0;
 	}
@@ -2281,7 +2252,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 
 static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 					 struct logical_volume *lv,
-					 struct lvconvert_params *lp)
+					 struct logical_volume **lv_to_poll)
 {
 	int merge_on_activate = 0;
 	struct logical_volume *origin = origin_from_cow(lv);
@@ -2289,29 +2260,6 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	struct lvinfo info;
 	dm_percent_t snap_percent;
 
-	/* Check if merge is possible */
-	if (!lv_is_cow(lv)) {
-		log_error("\"%s\" is not a mergeable logical volume.",
-			  lv->name);
-		return 0;
-	}
-
-	if (lv_is_merging_cow(lv)) {
-		log_error("Snapshot %s is already merging.", lv->name);
-		return 0;
-	}
-
-	if (lv_is_merging_origin(origin)) {
-		log_error("Snapshot %s is already merging into the origin.",
-			  find_snapshot(origin)->cow->name);
-		return 0;
-	}
-
-	if (lv_is_virtual_origin(origin)) {
-		log_error("Snapshot %s has virtual origin.", lv->name);
-		return 0;
-	}
-
 	if (lv_is_external_origin(origin_from_cow(lv))) {
 		log_error("Cannot merge snapshot \"%s\" into "
 			  "the read-only external origin \"%s\".",
@@ -2375,13 +2323,17 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 		if (!lv_update_and_reload(origin))
 			return_0;
 
-		if (lv_has_target_type(origin->vg->vgmem, origin, NULL,
+		if (!lv_has_target_type(origin->vg->vgmem, origin, NULL,
 				       TARGET_NAME_SNAPSHOT_MERGE)) {
-			lp->need_polling = 1;
-			lp->lv_to_poll = origin;
-		} else
 			/* Race during table reload prevented merging */
 			merge_on_activate = 1;
+
+		} else if (!lv_info(cmd, origin, 0, &info, 0, 0) || !info.exists) {
+			log_print_unless_silent("Conversion starts after activation.");
+			merge_on_activate = 1;
+		} else {
+			*lv_to_poll = origin;
+		}
 	}
 
 	if (merge_on_activate)
@@ -3447,7 +3399,7 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 static int _convert_cow_snapshot_splitsnapshot(struct cmd_context *cmd, struct logical_volume *lv,
 					       struct lvconvert_params *lp)
 {
-	return _lvconvert_splitsnapshot(cmd, lv, lp);
+	return _lvconvert_splitsnapshot(cmd, lv);
 }
 
 /*
@@ -3457,7 +3409,7 @@ static int _convert_cow_snapshot_splitsnapshot(struct cmd_context *cmd, struct l
 static int _convert_cow_snapshot_merge(struct cmd_context *cmd, struct logical_volume *lv,
 				       struct lvconvert_params *lp)
 {
-	return _lvconvert_merge_old_snapshot(cmd, lv, lp);
+	/* return _lvconvert_merge_old_snapshot(cmd, lv, lp); */
 }
 
 /*
@@ -3797,7 +3749,7 @@ static int _convert_raid_merge(struct cmd_context *cmd, struct logical_volume *l
 static int _convert_raid_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
 				  struct lvconvert_params *lp)
 {
-	return _lvconvert_snapshot(cmd, lv, lp);
+	return _lvconvert_snapshot(cmd, lv, lp->origin_name);
 }
 
 /*
@@ -3936,7 +3888,7 @@ static int _convert_striped_merge(struct cmd_context *cmd, struct logical_volume
 static int _convert_striped_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
 				     struct lvconvert_params *lp)
 {
-	return _lvconvert_snapshot(cmd, lv, lp);
+	return _lvconvert_snapshot(cmd, lv, lp->origin_name);
 }
 
 /*
@@ -4681,6 +4633,11 @@ struct lvconvert_result {
 	struct dm_list poll_idls;
 };
 
+
+/*
+ * repair-related lvconvert utilities
+ */
+
 static int _lvconvert_repair_pvs_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 			struct processing_handle *handle,
 			struct dm_list *use_pvh)
@@ -4878,11 +4835,12 @@ int lvconvert_repair_pvs_or_thinpool_cmd(struct cmd_context *cmd, int argc, char
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 
 	if (lr.need_polling) {
-		dm_list_iterate_items(idl, &lr.poll_idls)
+		dm_list_iterate_items(idl, &lr.poll_idls) {
 			poll_ret = _lvconvert_poll_by_id(cmd, idl->id,
 						arg_is_set(cmd, background_ARG), 0, 0);
-		if (poll_ret > ret)
-			ret = poll_ret;
+			if (poll_ret > ret)
+				ret = poll_ret;
+		}
 	}
 
 	destroy_processing_handle(cmd, handle);
@@ -4956,3 +4914,152 @@ int lvconvert_replace_pv_cmd(struct cmd_context *cmd, int argc, char **argv)
 	return ret;
 }
 
+
+/*
+ * snapshot-related lvconvert utilities
+ */
+
+
+/*
+ * Merge a COW snapshot LV into its origin.
+ */
+
+static int _lvconvert_merge_snapshot_single(struct cmd_context *cmd,
+                                       struct logical_volume *lv,
+                                       struct processing_handle *handle)
+{
+	struct lvconvert_result *lr = (struct lvconvert_result *) handle->custom_handle;
+	struct logical_volume *lv_to_poll = NULL;
+	struct convert_poll_id_list *idl;
+
+	if (!_lvconvert_merge_old_snapshot(cmd, lv, &lv_to_poll))
+		return_ECMD_FAILED;
+
+	if (lv_to_poll) {
+		if (!(idl = _convert_poll_id_list_create(cmd, lv_to_poll)))
+			return_ECMD_FAILED;
+		dm_list_add(&lr->poll_idls, &idl->list);
+		lr->need_polling = 1;
+	}
+
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_merge_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct lvconvert_result lr = { 0 };
+	struct convert_poll_id_list *idl;
+	int ret, poll_ret;
+
+	dm_list_init(&lr.poll_idls);
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lr;
+
+	ret = process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			      handle, NULL, &_lvconvert_merge_snapshot_single);
+
+	if (lr.need_polling) {
+		dm_list_iterate_items(idl, &lr.poll_idls) {
+			poll_ret = _lvconvert_poll_by_id(cmd, idl->id,
+						arg_is_set(cmd, background_ARG), 1, 0);
+			if (poll_ret > ret)
+				ret = poll_ret;
+		}
+	}
+
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
+/*
+ * Separate a COW snapshot from its origin.
+ *
+ * lvconvert --splitsnapshot LV_snapshot
+ * lvconvert_split_cow_snapshot
+ */
+
+static int _lvconvert_split_snapshot_single(struct cmd_context *cmd,
+                                       struct logical_volume *lv,
+                                       struct processing_handle *handle)
+{
+	if (!_lvconvert_splitsnapshot(cmd, lv))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_split_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_split_snapshot_single);
+}
+
+/*
+ * Combine two LVs that were once an origin/cow pair of LVs, were then
+ * separated with --splitsnapshot, and now with this command are combined again
+ * into the origin/cow pair.
+ *
+ * This is an obscure command that has little to no real uses.
+ *
+ * The command has unusual handling of position args.  The first position arg
+ * will become the origin LV, and is not processed by process_each_lv.  The
+ * second position arg will become the cow LV and is processed by
+ * process_each_lv.
+ *
+ * The single function can grab the origin LV from position_argv[0].
+ *
+ * begin with an ordinary LV foo:
+ * lvcreate -n foo -L 1 vg
+ *
+ * create a cow snapshot of foo named foosnap:
+ * lvcreate -s -L 1 -n foosnap vg/foo
+ *
+ * now, foo is an "origin LV" and foosnap is a "cow LV"
+ * (foosnap matches LV_snapshot aka lv_is_cow)
+ *
+ * split the two LVs apart:
+ * lvconvert --splitsnapshot vg/foosnap
+ *
+ * now, foo is *not* an origin LV and foosnap is *not* a cow LV
+ * (foosnap does not match LV_snapshot)
+ *
+ * now, combine the two LVs again:
+ * lvconvert --snapshot vg/foo vg/foosnap
+ *
+ * after this, foosnap will match LV_snapshot again.
+ *
+ * FIXME: when splitsnapshot is run, the previous cow LV should be
+ * flagged in the metadata somehow, and then that flag should be
+ * required here.  As it is now, the first and second args
+ * (origin and cow) can be swapped and nothing catches it.
+ */
+
+static int _lvconvert_combine_split_snapshot_single(struct cmd_context *cmd,
+                                       struct logical_volume *lv,
+                                       struct processing_handle *handle)
+{
+	const char *origin_name = cmd->position_argv[0];
+
+	/* If origin_name includes VG name, the VG name is removed. */
+	if (!validate_lvname_param(cmd, &lv->vg->name, &origin_name))
+		return_ECMD_FAILED;
+
+	if (!_lvconvert_snapshot(cmd, lv, origin_name))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, 1, cmd->position_argv + 1, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_combine_split_snapshot_single);
+}
+
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 866b2ae..e3904d6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -123,9 +123,14 @@ struct command_function command_functions[COMMAND_ID_COUNT] = {
 	{ lvchange_poll_CMD, lvchange_monitor_poll_cmd },
 	{ lvchange_persistent_CMD, lvchange_persistent_cmd },
 
-	/* lvconvert utilities related to snapshots and repair. */
+	/* lvconvert utilities related to repair. */
 	{ lvconvert_repair_pvs_or_thinpool_CMD,	lvconvert_repair_pvs_or_thinpool_cmd },
 	{ lvconvert_replace_pv_CMD, lvconvert_replace_pv_cmd },
+
+	/* lvconvert utilities related to snapshots. */
+	{ lvconvert_split_cow_snapshot_CMD, lvconvert_split_snapshot_cmd },
+	{ lvconvert_merge_snapshot_CMD, lvconvert_merge_snapshot_cmd },
+	{ lvconvert_combine_split_snapshot_CMD, lvconvert_combine_split_snapshot_cmd },
 };
 #if 0
 	/* all raid-related type conversions */
@@ -147,11 +152,9 @@ struct command_function command_functions[COMMAND_ID_COUNT] = {
 	{ lvconvert_split_and_delete_cachepool_CMD,	lvconvert_split_and_delete_cachepool_fn },
 	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_fn },
 
-	/* utilities related to snapshots and repair. */
+	/* other misc. */
 
 	{ lvconvert_merge_CMD,				lvconvert_merge_fn },
-	{ lvconvert_combine_split_snapshot_CMD,		lvconvert_combine_split_snapshot_fn },
-	{ lvconvert_split_cow_snapshot_CMD,		lvconvert_split_cow_snapshot_fn },
 	{ lvconvert_poll_start_CMD,			lvconvert_poll_start_fn },
 
 #endif
diff --git a/tools/tools.h b/tools/tools.h
index 9be1233..8ac98e8 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -254,4 +254,8 @@ int lvchange_persistent_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_repair_pvs_or_thinpool_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_replace_pv_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int lvconvert_merge_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_split_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 #endif


