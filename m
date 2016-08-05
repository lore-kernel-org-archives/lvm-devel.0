From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri,  5 Aug 2016 14:01:57 +0000 (UTC)
Subject: master - lvchange: Allow device specification when requesting a repair
Message-ID: <20160805140157.EC4B160BAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2c3b23e6dc39565093256c97ff66984e8648bda
Commit:        d2c3b23e6dc39565093256c97ff66984e8648bda
Parent:        91f866f7866eed6eb8ead5a876efcac5a58511da
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Aug 5 15:54:49 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Aug 5 16:01:46 2016 +0200

lvchange: Allow device specification when requesting a repair

'lvchange --resync LV' or 'lvchange --syncaction repair LV' request the
RAID layout specific parity blocks in raid4/5/6 to be recreated or the
mirrored blocks to be copied again from the master leg/copy for raid1/10,
thus not allowing a rebuild of a particular PV.

Introduce repeatable option '--[raid]rebuild PV' to allow to request
rebuilds of specific PVs in a RaidLV which are known to contain corrupt
data (e.g. rebuild a raid1 master leg).

Add test lvchange-rebuild-raid.sh to test/shell doing rebuild
variations on raid1/10 and 5; add aux function check_status_chars
to support the new test.

 - Resolves rhbz1064592
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |   99 +++++++++++++++++++++++++++++---------
 man/lvchange.8.in                |   27 ++++++++++
 test/lib/aux.sh                  |    6 ++
 tools/args.h                     |    2 +
 tools/commands.h                 |   10 ++--
 tools/lvchange.c                 |   63 ++++++++++++++++++++++++
 tools/lvmcmdline.c               |    1 +
 8 files changed, 182 insertions(+), 27 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e1a3538..3329535 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1204,6 +1204,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		    const unsigned new_stripe_size,
 		    const uint32_t new_region_size,
 		    struct dm_list *allocate_pvs);
+int lv_raid_rebuild(struct logical_volume *lv, struct dm_list *rebuild_pvs);
 int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs);
 int lv_raid_remove_missing(struct logical_volume *lv);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a2bf832..1e2f018 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2889,16 +2889,24 @@ has_enough_space:
 }
 
 /*
- * lv_raid_replace
+ * Helper:
+ *
+ * _lv_raid_rebuild_or_replace
  * @lv
  * @remove_pvs
  * @allocate_pvs
+ * @rebuild
+ *
+ * Rebuild the specified PVs on @remove_pvs if rebuild != 0;
+ * @allocate_pvs not accessed for rebuild.
  *
- * Replace the specified PVs.
+ * Replace the specified PVs on @remove_pvs if rebuild == 0;
+ * new SubLVS are allocated on PVs on list @allocate_pvs.
  */
-int lv_raid_replace(struct logical_volume *lv,
-		    struct dm_list *remove_pvs,
-		    struct dm_list *allocate_pvs)
+static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
+				       struct dm_list *remove_pvs,
+				       struct dm_list *allocate_pvs,
+				       int rebuild)
 {
 	int partial_segment_removed = 0;
 	uint32_t s, sd, match_count = 0;
@@ -2907,6 +2915,7 @@ int lv_raid_replace(struct logical_volume *lv,
 	struct lv_segment *raid_seg = first_seg(lv);
 	struct lv_list *lvl;
 	char *tmp_names[raid_seg->area_count * 2];
+	const char *action_str = rebuild ? "rebuild" : "replace";
 
 	if (seg_is_any_raid0(raid_seg)) {
 		log_error("Can't replace any devices in %s LV %s",
@@ -2951,28 +2960,33 @@ int lv_raid_replace(struct logical_volume *lv,
 		if (lv_is_virtual(seg_lv(raid_seg, s)) ||
 		    lv_is_virtual(seg_metalv(raid_seg, s)) ||
 		    lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
-		    lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs))
+		    lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs)) {
 			match_count++;
+			if (rebuild) {
+				seg_lv(raid_seg, s)->status |= LV_REBUILD;
+				seg_metalv(raid_seg, s)->status |= LV_REBUILD;
+			}
+		}
 	}
 
 	if (!match_count) {
-		log_verbose("%s/%s does not contain devices specified"
-			    " for replacement", lv->vg->name, lv->name);
+		log_print_unless_silent("%s/%s does not contain devices specified"
+					" to %s", display_lvname(lv), action_str);
 		return 1;
 	} else if (match_count == raid_seg->area_count) {
-		log_error("Unable to remove all PVs from %s/%s at once.",
-			  lv->vg->name, lv->name);
+		log_error("Unable to %s all PVs from %s/%s at once.",
+			  action_str, lv->vg->name, lv->name);
 		return 0;
 	} else if (raid_seg->segtype->parity_devs &&
 		   (match_count > raid_seg->segtype->parity_devs)) {
-		log_error("Unable to replace more than %u PVs from (%s) %s/%s",
-			  raid_seg->segtype->parity_devs,
+		log_error("Unable to %s more than %u PVs from (%s) %s/%s",
+			  action_str, raid_seg->segtype->parity_devs,
 			  lvseg_name(raid_seg),
 			  lv->vg->name, lv->name);
 		return 0;
 	} else if (seg_is_raid10(raid_seg)) {
 		uint32_t i, rebuilds_per_group = 0;
-		/* FIXME: We only support 2-way mirrors in RAID10 currently */
+		/* FIXME: We only support 2-way mirrors (i.e. 2 data copies) in RAID10 currently */
 		uint32_t copies = 2;
 
 		for (i = 0; i < raid_seg->area_count * copies; i++) {
@@ -2985,13 +2999,16 @@ int lv_raid_replace(struct logical_volume *lv,
 			    lv_is_virtual(seg_metalv(raid_seg, s)))
 				rebuilds_per_group++;
 			if (rebuilds_per_group >= copies) {
-				log_error("Unable to replace all the devices "
-					  "in a RAID10 mirror group.");
+				log_error("Unable to %s all the devices "
+					  "in a RAID10 mirror group.", action_str);
 				return 0;
 			}
 		}
 	}
 
+	if (rebuild)
+		goto skip_alloc;
+
 	/* Prevent any PVs holding image components from being used for allocation */
 	if (!_avoid_pvs_with_other_images_of_lv(lv, allocate_pvs)) {
 		log_error("Failed to prevent PVs holding image components "
@@ -3122,9 +3139,11 @@ try_again:
 			tmp_names[s] = tmp_names[sd] = NULL;
 	}
 
+skip_alloc:
 	if (!lv_update_and_reload_origin(lv))
 		return_0;
 
+	/* @old_lvs is empty in case of a rebuild */
 	dm_list_iterate_items(lvl, &old_lvs) {
 		if (!deactivate_lv(lv->vg->cmd, lvl->lv))
 			return_0;
@@ -3132,23 +3151,57 @@ try_again:
 			return_0;
 	}
 
-	/* Update new sub-LVs to correct name and clear REBUILD flag */
+	/* Clear REBUILD flag */
 	for (s = 0; s < raid_seg->area_count; s++) {
-		sd = s + raid_seg->area_count;
-		if (tmp_names[s] && tmp_names[sd]) {
-			seg_metalv(raid_seg, s)->name = tmp_names[s];
-			seg_lv(raid_seg, s)->name = tmp_names[sd];
-			seg_metalv(raid_seg, s)->status &= ~LV_REBUILD;
-			seg_lv(raid_seg, s)->status &= ~LV_REBUILD;
-		}
+		seg_lv(raid_seg, s)->status &= ~LV_REBUILD;
+		seg_metalv(raid_seg, s)->status &= ~LV_REBUILD;
 	}
 
+	/* If replace, correct name(s) */
+	if (!rebuild)
+		for (s = 0; s < raid_seg->area_count; s++) {
+			sd = s + raid_seg->area_count;
+			if (tmp_names[s] && tmp_names[sd]) {
+				seg_metalv(raid_seg, s)->name = tmp_names[s];
+				seg_lv(raid_seg, s)->name = tmp_names[sd];
+			}
+		}
+
 	if (!lv_update_and_reload_origin(lv))
 		return_0;
 
 	return 1;
 }
 
+/*
+ * lv_raid_rebuild
+ * @lv
+ * @remove_pvs
+ *
+ * Rebuild the specified PVs of @lv on @remove_pvs.
+ */
+int lv_raid_rebuild(struct logical_volume *lv,
+		    struct dm_list *rebuild_pvs)
+{
+	return _lv_raid_rebuild_or_replace(lv, rebuild_pvs, NULL, 1);
+}
+
+/*
+ * lv_raid_replace
+ * @lv
+ * @remove_pvs
+ * @allocate_pvs
+ *
+ * Replace the specified PVs on @remove_pvs of @lv
+ * allocating new SubLVs from PVs on list @allocate_pvs.
+ */
+int lv_raid_replace(struct logical_volume *lv,
+		    struct dm_list *remove_pvs,
+		    struct dm_list *allocate_pvs)
+{
+	return _lv_raid_rebuild_or_replace(lv, remove_pvs, allocate_pvs, 0);
+}
+
 int lv_raid_remove_missing(struct logical_volume *lv)
 {
 	uint32_t s;
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 3800369..8da9f2d 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -25,6 +25,8 @@ lvchange \(em change attributes of a logical volume
 .IR AllocationPolicy ]
 .RB [ \-A | \-\-autobackup
 .RB { y | n }]
+.RB [ \-\-rebuild
+.IR PhysicalVolume ]
 .RB [ \-\-cachemode
 .RB { passthrough | writeback | writethrough }]
 .RB [ \-\-cachepolicy
@@ -326,6 +328,31 @@ immediately poll a logical volume when it is activated, use
 \fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
 .
 .HP
+.BR \-\- [ raid ] rebuild 
+.BR \fIPhysicalVolume
+.br
+Option can be repeated multiple times.
+Selects PhysicalVolume(s) to be rebuild in a RaidLV.
+Use this option instead of
+.BR \-\-resync
+or
+.BR \-\- [ raid ] syncaction
+\fBrepair\fP in case the PVs with corrupted data are known and their data
+should be reconstructed rather than reconstructing default (rotating) data.
+.br
+E.g. in a raid1 mirror, the master leg on /dev/sda may hold corrupt data due
+to a known transient disk error, thus
+.br
+\fBlvchange --rebuild /dev/sda LV\fP
+.br
+will request the master leg to be rebuild rather than rebuilding
+all other legs from the master.
+On a raid5 with rotating data and parity
+.br
+\fBlvchange --rebuild /dev/sda LV\fP
+.br
+will rebuild all data and parity blocks in the stripe on /dev/sda.
+.HP
 .BR \-\- [ raid ] maxrecoveryrate
 .BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
 .br
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 90f2ab1..726cfe3 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1265,6 +1265,12 @@ wait_for_sync() {
 	return 1
 }
 
+# aux check_status_chars $vg $lv "Aaaaa"
+check_status_chars() {
+	[ `dmsetup status $1-$2|awk '{print $6}'` = $3 ] && return
+	return 1
+}
+
 # Check if tests are running on 64bit architecture
 can_use_16T() {
 	test "$(getconf LONG_BIT)" -eq 64
diff --git a/tools/args.h b/tools/args.h
index 5902513..a04d81d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -88,6 +88,7 @@ arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0, 0)
 arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", yes_no_arg, 0, 0)
 arg(profile_ARG, '\0', "profile", string_arg, 0, 0)
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0, 0)
+arg(raidrebuild_ARG, '\0', "raidrebuild", string_arg, ARG_GROUPABLE, 0)
 arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", size_kb_arg, 0, 0)
 arg(raidminrecoveryrate_ARG, '\0', "raidminrecoveryrate", size_kb_arg, 0, 0)
 arg(raidsyncaction_ARG, '\0', "raidsyncaction", string_arg, 0, 0)
@@ -96,6 +97,7 @@ arg(raidwritemostly_ARG, '\0', "raidwritemostly", string_arg, ARG_GROUPABLE, 0)
 arg(readonly_ARG, '\0', "readonly", NULL, 0, 0)
 arg(refresh_ARG, '\0', "refresh", NULL, 0, 0)
 arg(removemissing_ARG, '\0', "removemissing", NULL, 0, 0)
+arg(rebuild_ARG, '\0', "rebuild", string_arg, ARG_GROUPABLE, 0)
 arg(repair_ARG, '\0', "repair", NULL, 0, 0)
 arg(replace_ARG, '\0', "replace", string_arg, ARG_GROUPABLE, 0)
 arg(reportformat_ARG, '\0', "reportformat", string_arg, 0, 0)
diff --git a/tools/commands.h b/tools/commands.h
index c348753..baf89b1 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -195,6 +195,7 @@ xx(lvchange,
    "\t[--activationmode {complete|degraded|partial}"
    "\t[--addtag <Tag>]\n"
    "\t[--alloc <AllocationPolicy>]\n"
+   "\t[--rebuild PhysicalVolume]\n"
    "\t[-C|--contiguous {y|n}]\n"
    "\t[--cachemode <CacheMode>]\n"
    "\t[--cachepolicy <policyname>] [--cachesettings <parameter=value>]\n"
@@ -244,10 +245,10 @@ xx(lvchange,
    ignoreskippedcluster_ARG, major_ARG, metadataprofile_ARG, minor_ARG,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, noudevsync_ARG,
    partial_ARG, permission_ARG, persistent_ARG, poll_ARG,
-   raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG, raidsyncaction_ARG,
-   raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG, reportformat_ARG,
-   resync_ARG, refresh_ARG, select_ARG, setactivationskip_ARG, syncaction_ARG,
-   sysinit_ARG, test_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
+   raidrebuild_ARG, raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
+   raidsyncaction_ARG, raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG,
+   reportformat_ARG, rebuild_ARG, resync_ARG, refresh_ARG, select_ARG, setactivationskip_ARG,
+   syncaction_ARG, sysinit_ARG, test_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
 
 #define COMMON_OPTS \
 	"\t[--commandprofile <ProfileName>] [-d|--debug] [-h|-?|--help]\n" \
@@ -259,6 +260,7 @@ xx(lvconvert,
    "lvconvert "
    "[-m|--mirrors <Mirrors> [--mirrorlog {disk|core|mirrored}|--corelog]]\n"
    "\t[--type <SegmentType>]\n"
+   "\t[--rebuild PhysicalVolume]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[--replace PhysicalVolume]\n"
    "\t[-R|--regionsize <MirrorLogRegionSize>]\n"
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 9194cd6..e0d91fc 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -750,6 +750,60 @@ static int _lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int
 	return 1;
 }
 
+static int _lvchange_rebuild(struct logical_volume *lv)
+{
+	int pv_count, i = 0;
+	char **rebuild_pvs;
+	const char *tmp_str;
+	struct dm_list *rebuild_pvh = NULL;
+	struct arg_value_group_list *group;
+	struct volume_group *vg = lv->vg;
+	struct cmd_context *cmd = vg->cmd;
+	struct lv_segment *raid_seg = first_seg(lv);
+
+	if (!seg_is_raid(raid_seg) || seg_is_any_raid0(raid_seg)) {
+		log_error("--rebuild can only be used with 'raid4/5/6/10' segment types.");
+		return 0;
+	}
+
+	if (!(pv_count = arg_count(cmd, rebuild_ARG))) {
+		log_error("No --rebuild found!");
+		return 0;
+	}
+
+	if (!arg_is_set(cmd, yes_ARG) &&
+	    yes_no_prompt("Do you really want to rebuild %u PVs "
+			  "of logical volume %s [y/n]: ",
+			  pv_count, display_lvname(lv)) == 'n') {
+		log_error("Logical volume %s not rebuild.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	/* rebuild can be specified more than once */
+	if (!(rebuild_pvs = dm_pool_alloc(vg->vgmem, sizeof(char *) * pv_count)))
+		return_0;
+
+	dm_list_iterate_items(group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(group->arg_values, rebuild_ARG))
+			continue;
+
+		if (!(tmp_str = grouped_arg_str_value(group->arg_values,
+						      rebuild_ARG, NULL)))
+			return_0;
+
+		if (!(rebuild_pvs[i++] = dm_pool_strdup(cmd->mem, tmp_str)))
+                               return_0;
+	}
+
+	if (!(rebuild_pvh = create_pv_list(cmd->mem, vg,
+					   pv_count, rebuild_pvs, 0)))
+		return_ECMD_FAILED;
+
+	/* Rebuild PVs listed on @rebuild_pvh */
+	return lv_raid_rebuild(lv, rebuild_pvh);
+}
+
 static int _lvchange_writemostly(struct logical_volume *lv)
 {
 	int s, pv_count, i = 0;
@@ -1132,6 +1186,14 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		docmds++;
 	}
 
+	/* rebuild selected PVs */
+	if (arg_is_set(cmd, rebuild_ARG)) {
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+		doit += _lvchange_rebuild(lv);
+		docmds++;
+	}
+
 	/* change writemostly/writebehind */
 	if (arg_is_set(cmd, writemostly_ARG) || arg_is_set(cmd, writebehind_ARG)) {
 		if (!archive(lv->vg))
@@ -1245,6 +1307,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 				     errorwhenfull_ARG,
 				     maxrecoveryrate_ARG,
 				     minrecoveryrate_ARG,
+				     rebuild_ARG,
 				     resync_ARG,
 				     syncaction_ARG,
 				     writebehind_ARG,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index fd00ce6..4ad2ea6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1167,6 +1167,7 @@ static int _get_settings(struct cmd_context *cmd)
 	    !_merge_synonym(cmd, allocation_ARG, resizeable_ARG) ||
 	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG) ||
 	    !_merge_synonym(cmd, available_ARG, activate_ARG) ||
+	    !_merge_synonym(cmd, raidrebuild_ARG, rebuild_ARG) ||
 	    !_merge_synonym(cmd, raidsyncaction_ARG, syncaction_ARG) ||
 	    !_merge_synonym(cmd, raidwritemostly_ARG, writemostly_ARG) ||
 	    !_merge_synonym(cmd, raidminrecoveryrate_ARG, minrecoveryrate_ARG) ||


