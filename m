From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 30 May 2013 16:15:07 -0500
Subject: [PATCH] DM RAID: Add ability to throttle sync operations for RAID LVs.
Message-ID: <1369948507.8964.3.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Please take a look at the following patch that adds throttling for RAID
sync operations.  Any feedback on what the 'lvs' header should look like
when reporting the min/max recovery rate would be helpful also.  (Right
now it is MinSync and MaxSync.)

 brassow


This patch adds the ability to set the minimum and maximum I/O rate for
sync operations in RAID LVs.  The options are available for 'lvcreate' and
'lvchange' and are as follows:
  --minrecoveryrate <Rate>
  --maxrecoveryrate <Rate>
The rate is specified in kiB/sec/disk.  Setting the rate to 0 removes the
preference.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: lvm2/lib/metadata/metadata-exported.h
===================================================================
--- lvm2.orig/lib/metadata/metadata-exported.h
+++ lvm2/lib/metadata/metadata-exported.h
@@ -337,6 +337,8 @@ struct lv_segment {
 	/* FIXME Fields depend on segment type */
 	uint32_t stripe_size;	/* For stripe and RAID - in sectors */
 	uint32_t writebehind;   /* For RAID (RAID1 only) */
+	uint32_t min_recovery_rate; /* For RAID */
+	uint32_t max_recovery_rate; /* For RAID */
 	uint32_t area_count;
 	uint32_t area_len;
 	uint32_t chunk_size;	/* For snapshots/thin_pool.  In sectors. */
@@ -631,6 +633,9 @@ struct lvcreate_params {
 
 	uint32_t mirrors; /* mirror */
 
+	uint32_t min_recovery_rate; /* RAID */
+	uint32_t max_recovery_rate; /* RAID */
+
 	const struct segment_type *segtype; /* all */
 	unsigned target_attr; /* all */
 
Index: lvm2/lib/raid/raid.c
===================================================================
--- lvm2.orig/lib/raid/raid.c
+++ lvm2/lib/raid/raid.c
@@ -129,6 +129,24 @@ static int _raid_text_import(struct lv_s
 			return 0;
 		}
 	}
+	if (dm_config_has_node(sn, "min_recovery_rate")) {
+		if (!dm_config_get_uint32(sn, "min_recovery_rate",
+					  &seg->min_recovery_rate)) {
+			log_error("Couldn't read 'min_recovery_rate' for "
+				  "segment %s of logical volume %s.",
+				  dm_config_parent_name(sn), seg->lv->name);
+			return 0;
+		}
+	}
+	if (dm_config_has_node(sn, "max_recovery_rate")) {
+		if (!dm_config_get_uint32(sn, "max_recovery_rate",
+					  &seg->max_recovery_rate)) {
+			log_error("Couldn't read 'max_recovery_rate' for "
+				  "segment %s of logical volume %s.",
+				  dm_config_parent_name(sn), seg->lv->name);
+			return 0;
+		}
+	}
 	if (!dm_config_get_list(sn, "raids", &cv)) {
 		log_error("Couldn't find RAID array for "
 			  "segment %s of logical volume %s.",
@@ -155,6 +173,10 @@ static int _raid_text_export(const struc
 		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
 	if (seg->writebehind)
 		outf(f, "writebehind = %" PRIu32, seg->writebehind);
+	if (seg->min_recovery_rate)
+		outf(f, "min_recovery_rate = %" PRIu32, seg->min_recovery_rate);
+	if (seg->max_recovery_rate)
+		outf(f, "max_recovery_rate = %" PRIu32, seg->max_recovery_rate);
 
 	return out_areas(f, seg, "raid");
 }
@@ -227,6 +249,8 @@ static int _raid_add_target_line(struct
 	params.stripe_size = seg->stripe_size;
 	params.rebuilds = rebuilds;
 	params.writemostly = writemostly;
+	params.min_recovery_rate = seg->min_recovery_rate;
+	params.max_recovery_rate = seg->max_recovery_rate;
 	params.flags = flags;
 
 	if (!dm_tree_node_add_raid_target_with_params(node, len, &params))
Index: lvm2/lib/report/columns.h
===================================================================
--- lvm2.orig/lib/report/columns.h
+++ lvm2/lib/report/columns.h
@@ -83,6 +83,8 @@ FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8,
 FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, mismatch_count, mismatches, "For RAID, number of mismatches found or repaired.", 0)
 FIELD(LVS, lv, STR, "SyncAction", lvid, 10, sync_action, syncaction, "For RAID, the current synchronization action being performed.", 0)
 FIELD(LVS, lv, NUM, "WBehind", lvid, 7, write_behind, writebehind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
+FIELD(LVS, lv, NUM, "MinSync", lvid, 7, min_recovery_rate, minrecoveryrate, "For RAID1, the minimum recovery I/O load in kiB/sec/disk.", 0)
+FIELD(LVS, lv, NUM, "MaxSync", lvid, 7, max_recovery_rate, maxrecoveryrate, "For RAID1, the maximum recovery I/O load in kiB/sec/disk.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
Index: lvm2/lib/report/properties.c
===================================================================
--- lvm2.orig/lib/report/properties.c
+++ lvm2/lib/report/properties.c
@@ -113,6 +113,14 @@ static uint32_t _writebehind(const struc
 	return first_seg(lv)->writebehind;
 }
 
+static uint32_t _minrecoveryrate(const struct logical_volume *lv) {
+	return first_seg(lv)->min_recovery_rate;
+}
+
+static uint32_t _maxrecoveryrate(const struct logical_volume *lv) {
+	return first_seg(lv)->max_recovery_rate;
+}
+
 static percent_t _snap_percent(const struct logical_volume *lv) {
 	percent_t perc;
 
@@ -219,6 +227,10 @@ GET_LV_NUM_PROPERTY_FN(mismatches, _mism
 #define _mismatches_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(writebehind, _writebehind(lv))
 #define _writebehind_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(minrecoveryrate, _minrecoveryrate(lv))
+#define _minrecoveryrate_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(maxrecoveryrate, _maxrecoveryrate(lv))
+#define _maxrecoveryrate_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(syncaction, _sync_action(lv))
 #define _syncaction_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
Index: lvm2/lib/report/report.c
===================================================================
--- lvm2.orig/lib/report/report.c
+++ lvm2/lib/report/report.c
@@ -1002,6 +1002,40 @@ static int _write_behind_disp(struct dm_
 	return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
 }
 
+static int _min_recovery_rate_disp(struct dm_report *rh __attribute__((unused)),
+				   struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data,
+				   void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (!lv_is_raid_type(lv) || !first_seg(lv)->min_recovery_rate) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	return dm_report_field_uint32(rh, field,
+				      &first_seg(lv)->min_recovery_rate);
+}
+
+static int _max_recovery_rate_disp(struct dm_report *rh __attribute__((unused)),
+				   struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data,
+				   void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (!lv_is_raid_type(lv) || !first_seg(lv)->max_recovery_rate) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	return dm_report_field_uint32(rh, field,
+				      &first_seg(lv)->max_recovery_rate);
+}
+
 static int _dtpercent_disp(int metadata, struct dm_report *rh,
 			   struct dm_pool *mem,
 			   struct dm_report_field *field,
Index: lvm2/libdm/libdm-deptree.c
===================================================================
--- lvm2.orig/libdm/libdm-deptree.c
+++ lvm2/libdm/libdm-deptree.c
@@ -183,9 +183,11 @@ struct load_segment {
 	struct dm_tree_node *replicator;/* Replicator-dev */
 	uint64_t rdevice_index;		/* Replicator-dev */
 
-	uint64_t rebuilds;	      /* raid */
-	uint64_t writemostly;	      /* raid */
-	uint32_t writebehind;	      /* raid */
+	uint64_t rebuilds;		/* raid */
+	uint64_t writemostly;		/* raid */
+	uint32_t writebehind;		/* raid */
+	uint32_t max_recovery_rate;	/* raid kB/sec/disk */
+	uint32_t min_recovery_rate;	/* raid kB/sec/disk */
 
 	struct dm_tree_node *metadata;	/* Thin_pool */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
@@ -2133,6 +2135,12 @@ static int _raid_emit_segment_line(struc
 	if (seg->writebehind)
 		param_count += 2;
 
+	if (seg->min_recovery_rate)
+		param_count += 2;
+
+	if (seg->max_recovery_rate)
+		param_count += 2;
+
 	/* rebuilds is 64-bit */
 	param_count += 2 * hweight32(seg->rebuilds & 0xFFFFFFFF);
 	param_count += 2 * hweight32(seg->rebuilds >> 32);
@@ -2166,6 +2174,14 @@ static int _raid_emit_segment_line(struc
 	if (seg->writebehind)
 		EMIT_PARAMS(pos, " writebehind %u", seg->writebehind);
 
+	if (seg->min_recovery_rate)
+		EMIT_PARAMS(pos, " min_recovery_rate %u",
+			    seg->min_recovery_rate);
+
+	if (seg->max_recovery_rate)
+		EMIT_PARAMS(pos, " max_recovery_rate %u",
+			    seg->max_recovery_rate);
+
 	/* Print number of metadata/data device pairs */
 	EMIT_PARAMS(pos, " %u", seg->area_count/2);
 
@@ -2901,6 +2917,8 @@ int dm_tree_node_add_raid_target_with_pa
 	seg->rebuilds = p->rebuilds;
 	seg->writemostly = p->writemostly;
 	seg->writebehind = p->writebehind;
+	seg->min_recovery_rate = p->min_recovery_rate;
+	seg->max_recovery_rate = p->max_recovery_rate;
 	seg->flags = p->flags;
 
 	return 1;
Index: lvm2/lib/metadata/lv_manip.c
===================================================================
--- lvm2.orig/lib/metadata/lv_manip.c
+++ lvm2/lib/metadata/lv_manip.c
@@ -4714,6 +4714,9 @@ static struct logical_volume *_lv_create
 			stack;
 			goto revert_new_lv;
 		}
+	} else if (seg_is_raid(lp)) {
+		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
+		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
 	}
 
 	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
Index: lvm2/man/lvchange.8.in
===================================================================
--- lvm2.orig/man/lvchange.8.in
+++ lvm2/man/lvchange.8.in
@@ -26,6 +26,8 @@ lvchange \- change attributes of a logic
 .RI { y | n }]
 .RB [ \-\-poll
 .RI { y | n }]
+.RB [ \-\-maxrecoveryrate " " \fIRate\fP ]
+.RB [ \-\-minrecoveryrate " " \fIRate\fP ]
 .RB [ \-\-syncaction
 .RI { check | repair }]
 .RB [ \-\-sysinit ]
@@ -111,6 +113,16 @@ process from its last checkpoint.  Howev
 immediately poll a logical volume when it is activated, use
 \fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
 .TP
+.IR \fB\-\-maxrecoveryrate " " \fIRate
+Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
+is specified in kiB/sec/device.  Setting the recovery rate to 0 means
+it will be unbounded.
+.TP
+.IR \fB\-\-minrecoveryrate " " \fIRate
+Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
+is specified in kiB/sec/device.  Setting the recovery rate to 0 means
+it will be unbounded.
+.TP
 .BR \-\-syncaction " {" \fIcheck | \fIrepair }
 This argument is used to initiate various RAID synchronization operations.
 The \fIcheck\fP and \fIrepair\fP options provide a way to check the
Index: lvm2/man/lvcreate.8.in
===================================================================
--- lvm2.orig/man/lvcreate.8.in
+++ lvm2/man/lvcreate.8.in
@@ -19,6 +19,8 @@ lvcreate \- create a logical volume in a
 .RB [ \-\-ignoremonitoring ]
 .RB [ \-\-monitor
 .RI { y | n }]
+.RB [ \-\-maxrecoveryrate " " \fIRate\fP ]
+.RB [ \-\-minrecoveryrate " " \fIRate\fP ]
 .RB [ \-i | \-\-stripes
 .IR Stripes
 .RB [ \-I | \-\-stripesize
@@ -243,6 +245,16 @@ Sets the name for the new logical volume
 Without this option a default name of "lvol#" will be generated where
 # is the LVM internal number of the logical volume.
 .TP
+.IR \fB\-\-maxrecoveryrate " " \fIRate
+Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
+is specified in kiB/sec/device.  Setting the recovery rate to 0 means
+it will be unbounded.
+.TP
+.IR \fB\-\-minrecoveryrate " " \fIRate
+Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
+is specified in kiB/sec/device.  Setting the recovery rate to 0 means
+it will be unbounded.
+.TP
 .B \-\-noudevsync
 Disables udev synchronisation. The
 process will not wait for notification from udev.
Index: lvm2/tools/args.h
===================================================================
--- lvm2.orig/tools/args.h
+++ lvm2/tools/args.h
@@ -89,6 +89,8 @@ arg(validate_ARG, '\0', "validate", NULL
 arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)
 arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE)
 arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
+arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", int_arg, 0)
+arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", int_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
Index: lvm2/tools/commands.h
===================================================================
--- lvm2.orig/tools/commands.h
+++ lvm2/tools/commands.h
@@ -84,6 +84,8 @@ xx(lvchange,
    "\t[--monitor {y|n}]\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
+   "\t[--minrecoveryrate Rate]\n"
+   "\t[--maxrecoveryrate Rate]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[-P|--partial] " "\n"
    "\t[-p|--permission r|rw]\n"
@@ -95,7 +97,7 @@ xx(lvchange,
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
-   "\t[--writebehind BehindCount\n"
+   "\t[--writebehind BehindCount]\n"
    "\t[--writemostly PhysicalVolume]\n"
    "\t[-y|--yes]\n"
    "\t[-Z|--zero {y|n}]\n"
@@ -103,7 +105,8 @@ xx(lvchange,
 
    alloc_ARG, autobackup_ARG, activate_ARG, available_ARG, contiguous_ARG,
    discards_ARG, force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
-   major_ARG, minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG,
+   major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG,
+   noudevsync_ARG, partial_ARG,
    permission_ARG, persistent_ARG, poll_ARG, readahead_ARG, resync_ARG,
    refresh_ARG, addtag_ARG, deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
    writebehind_ARG, writemostly_ARG, zero_ARG)
@@ -194,6 +197,8 @@ xx(lvcreate,
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
+   "\t[--minrecoveryrate Rate]\n"
+   "\t[--maxrecoveryrate Rate]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
@@ -244,7 +249,8 @@ xx(lvcreate,
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
    chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, extents_ARG,
    ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
-   monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG,
+   monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
+   noudevsync_ARG, permission_ARG,
    persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG,
    stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,
    virtualoriginsize_ARG, poolmetadatasize_ARG, virtualsize_ARG, zero_ARG)
Index: lvm2/tools/lvchange.c
===================================================================
--- lvm2.orig/tools/lvchange.c
+++ lvm2/tools/lvchange.c
@@ -810,6 +810,55 @@ static int lvchange_writemostly(struct l
 	return 1;
 }
 
+static int lvchange_recovery_rate(struct logical_volume *lv)
+{
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct lv_segment *raid_seg = first_seg(lv);
+
+	if (strcmp(raid_seg->segtype->name, "raid1")) {
+		log_error("Unable to change the recovery rate of non-RAID"
+			  " logical volume.");
+		return 0;
+	}
+
+	if (arg_count(cmd, minrecoveryrate_ARG))
+		raid_seg->min_recovery_rate =
+			arg_uint_value(cmd, minrecoveryrate_ARG, 0);
+	if (arg_count(cmd, maxrecoveryrate_ARG))
+		raid_seg->max_recovery_rate =
+			arg_uint_value(cmd, maxrecoveryrate_ARG, 0);
+
+	if (raid_seg->max_recovery_rate &&
+	    (raid_seg->max_recovery_rate < raid_seg->min_recovery_rate)) {
+		log_error("Minumum recovery rate cannot"
+			  " be set higher than maximum.");
+		return 0;
+	}
+
+	if (!vg_write(lv->vg))
+		return_0;
+
+	if (!suspend_lv(cmd, lv)) {
+		vg_revert(lv->vg);
+		return_0;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		if (!resume_lv(cmd, lv))
+			stack;
+		return_0;
+	}
+
+	log_very_verbose("Updating recovery rate for \"%s\" in kernel",
+			 lv->name);
+	if (!resume_lv(cmd, lv)) {
+		log_error("Problem reactivating %s", lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute__((unused)))
 {
@@ -992,6 +1041,18 @@ static int lvchange_single(struct cmd_co
 		docmds++;
 	}
 
+	/* change [min|max]_recovery_rate */
+	if (arg_count(cmd, minrecoveryrate_ARG) ||
+	    arg_count(cmd, maxrecoveryrate_ARG)) {
+		if (!archived && !archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		archived = 1;
+		doit += lvchange_recovery_rate(lv);
+		docmds++;
+	}
+
 	if (doit)
 		log_print_unless_silent("Logical volume \"%s\" changed", lv->name);
 
Index: lvm2/tools/lvcreate.c
===================================================================
--- lvm2.orig/tools/lvcreate.c
+++ lvm2/tools/lvcreate.c
@@ -558,6 +558,18 @@ static int _read_raid_params(struct lvcr
 		return 0;
 	}
 
+	if (arg_count(cmd, minrecoveryrate_ARG))
+		lp->min_recovery_rate = arg_uint_value(cmd,
+						       minrecoveryrate_ARG, 0);
+	if (arg_count(cmd, maxrecoveryrate_ARG))
+		lp->max_recovery_rate = arg_uint_value(cmd,
+						       maxrecoveryrate_ARG, 0);
+
+	if (lp->max_recovery_rate &&
+	    (lp->max_recovery_rate < lp->min_recovery_rate)) {
+		log_error("Minumum recovery rate cannot be higher than maximum.");
+		return 0;
+	}
 	return 1;
 }
 



