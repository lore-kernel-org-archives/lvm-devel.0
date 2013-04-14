From: Jonathan Brassow <jbrassow@redhat.com>
Date: Sun, 14 Apr 2013 11:39:44 -0500
Subject: [PATCH] LVM RAID: Add writemostly/writebehind support for RAID1
Message-ID: <1365957584.17070.13.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

LVM RAID:  Add writemostly/writebehind support for RAID1

'lvchange' is used to alter a RAID 1 logical volume's write-mostly and
write-behind characteristics.  The '--writemostly' parameter takes a
PV as an argument with an optional trailing character to specify whether
to set ('y'), unset ('n'), or toggle ('t') the value.  If no trailing
character is given, it will set the flag.
Synopsis:
        lvchange [--writemostly <PV>:{t|y|n}] [--writebehind <count>] vg/lv
Example:
	lvchange --writemostly /dev/sdb1:y --writebehind 512 vg/raid1_lv

The last character in the 'lv_attr' field is used to show whether a device
has the WriteMostly flag set.  It is signified with a 'w'.  If the device
has failed, the 'p'artial flag has priority.

Example ("nosync" raid1 with mismatch_cnt and writemostly):
[~]# lvs -a --segment vg
  LV                VG   Attr      #Str Type   SSize  
  raid1             vg   Rwi---r-m    2 raid1  500.00m
  [raid1_rimage_0]  vg   Iwi---r--    1 linear 500.00m
  [raid1_rimage_1]  vg   Iwi---r-w    1 linear 500.00m
  [raid1_rmeta_0]   vg   ewi---r--    1 linear   4.00m
  [raid1_rmeta_1]   vg   ewi---r--    1 linear   4.00m

Example (raid1 with mismatch_cnt, writemostly - but failed drive):
[~]# lvs -a --segment vg
  LV                VG   Attr      #Str Type   SSize  
  raid1             vg   rwi---r-p    2 raid1  500.00m
  [raid1_rimage_0]  vg   Iwi---r--    1 linear 500.00m
  [raid1_rimage_1]  vg   Iwi---r-p    1 linear 500.00m
  [raid1_rmeta_0]   vg   ewi---r--    1 linear   4.00m
  [raid1_rmeta_1]   vg   ewi---r-p    1 linear   4.00m

A new reportable field has been added for writebehind as well.  If
write-behind has not been set or the LV is not RAID1, the field will
be blank.
Example (writebehind is set):
[~]# lvs -a -o name,attr,writebehind vg
  LV            Attr      WBehind   
  lv            rwi-a-r--     512
  [lv_rimage_0] iwi-aor-w        
  [lv_rimage_1] iwi-aor--        
  [lv_rmeta_0]  ewi-aor--        
  [lv_rmeta_1]  ewi-aor--        

Example (writebehind is not set):
[~]# lvs -a -o name,attr,writebehind vg
  LV            Attr      WBehind   
  lv            rwi-a-r--        
  [lv_rimage_0] iwi-aor-w        
  [lv_rimage_1] iwi-aor--        
  [lv_rmeta_0]  ewi-aor--        
  [lv_rmeta_1]  ewi-aor--        


Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: lvm2/lib/format_text/flags.c
===================================================================
--- lvm2.orig/lib/format_text/flags.c
+++ lvm2/lib/format_text/flags.c
@@ -58,6 +58,7 @@ static const struct flag _lv_flags[] = {
 	{LOCKED, "LOCKED", STATUS_FLAG},
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
+	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
 	{RAID_IMAGE, NULL, 0},
Index: lvm2/lib/metadata/metadata-exported.h
===================================================================
--- lvm2.orig/lib/metadata/metadata-exported.h
+++ lvm2/lib/metadata/metadata-exported.h
@@ -90,6 +90,8 @@
 #define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV */
 #define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV */
 
+#define LV_WRITEMOSTLY		UINT64_C(0x0000010000000000)	/* LV (RAID1) */
+
 #define LVM_READ		UINT64_C(0x00000100)	/* LV, VG */
 #define LVM_WRITE		UINT64_C(0x00000200)	/* LV, VG */
 
@@ -334,6 +336,7 @@ struct lv_segment {
 
 	/* FIXME Fields depend on segment type */
 	uint32_t stripe_size;	/* For stripe and RAID - in sectors */
+	uint32_t writebehind;   /* For RAID (RAID1 only) */
 	uint32_t area_count;
 	uint32_t area_len;
 	uint32_t chunk_size;	/* For snapshots/thin_pool.  In sectors. */
Index: lvm2/lib/raid/raid.c
===================================================================
--- lvm2.orig/lib/raid/raid.c
+++ lvm2/lib/raid/raid.c
@@ -121,6 +121,14 @@ static int _raid_text_import(struct lv_s
 			return 0;
 		}
 	}
+	if (dm_config_has_node(sn, "writebehind")) {
+		if (!dm_config_get_uint32(sn, "writebehind", &seg->writebehind)) {
+			log_error("Couldn't read 'writebehind' for "
+				  "segment %s of logical volume %s.",
+				  dm_config_parent_name(sn), seg->lv->name);
+			return 0;
+		}
+	}
 	if (!dm_config_get_list(sn, "raids", &cv)) {
 		log_error("Couldn't find RAID array for "
 			  "segment %s of logical volume %s.",
@@ -145,6 +153,8 @@ static int _raid_text_export(const struc
 		outf(f, "region_size = %" PRIu32, seg->region_size);
 	if (seg->stripe_size)
 		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
+	if (seg->writebehind)
+		outf(f, "writebehind = %" PRIu32, seg->writebehind);
 
 	return out_areas(f, seg, "raid");
 }
@@ -161,6 +171,10 @@ static int _raid_add_target_line(struct
 	uint32_t s;
 	uint64_t flags = 0;
 	uint64_t rebuilds = 0;
+	uint64_t writemostly = 0;
+	struct dm_tree_node_raid_params params;
+
+	memset(&params, 0, sizeof(params));
 
 	if (!seg->area_count) {
 		log_error(INTERNAL_ERROR "_raid_add_target_line called "
@@ -187,12 +201,35 @@ static int _raid_add_target_line(struct
 		if (seg_lv(seg, s)->status & LV_REBUILD)
 			rebuilds |= 1 << s;
 
+	for (s = 0; s < seg->area_count; s++)
+		if (seg_lv(seg, s)->status & LV_WRITEMOSTLY)
+			writemostly |= 1 << s;
+
 	if (mirror_in_sync())
 		flags = DM_NOSYNC;
 
-	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
-					  seg->region_size, seg->stripe_size,
-					  rebuilds, flags))
+	params.raid_type = _raid_name(seg);
+	if (seg->segtype->parity_devs) {
+		/* RAID 4/5/6 */
+		params.mirrors = 1;
+		params.stripes = seg->area_count - seg->segtype->parity_devs;
+	} else if (strcmp(seg->segtype->name, "raid10")) {
+		/* RAID 10 only supports 2 mirrors now */
+		params.mirrors = 2;
+		params.stripes = seg->area_count / 2;
+	} else {
+		/* RAID 1 */
+		params.mirrors = seg->area_count;
+		params.stripes = 1;
+		params.writebehind = seg->writebehind;
+	}
+	params.region_size = seg->region_size;
+	params.stripe_size = seg->stripe_size;
+	params.rebuilds = rebuilds;
+	params.writemostly = writemostly;
+	params.flags = flags;
+
+	if (!dm_tree_node_add_raid_target_with_params(node, len, &params))
 		return_0;
 
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
Index: lvm2/libdm/libdevmapper.h
===================================================================
--- lvm2.orig/libdm/libdevmapper.h
+++ lvm2/libdm/libdevmapper.h
@@ -643,6 +643,35 @@ int dm_tree_node_add_raid_target(struct
 				 uint64_t rebuilds,
 				 uint64_t flags);
 
+struct dm_tree_node_raid_params {
+	const char *raid_type;
+
+	uint32_t stripes;
+	uint32_t mirrors;
+	uint32_t region_size;
+	uint32_t stripe_size;
+
+	/*
+	 * 'rebuilds' and 'writemostly' are bitfields that signify
+	 * which devices in the array are to be rebuilt or marked
+	 * writemostly.  By choosing a 'uint64_t', we limit ourself
+	 * to RAID arrays with 64 devices.
+	 */
+	uint64_t rebuilds;
+	uint64_t writemostly;
+	uint32_t writebehind;       /* I/Os */
+	uint32_t max_recovery_rate; /* kB/sec/disk */
+	uint32_t min_recovery_rate; /* kB/sec/disk */
+	uint32_t stripe_cache;      /* sectors */
+
+	uint64_t flags;             /* [no]sync */
+	uint64_t reserved2;
+};
+
+int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
+					     uint64_t size,
+					     struct dm_tree_node_raid_params *p);
+
 /*
  * Replicator operation mode
  * Note: API for Replicator is not yet stable
Index: lvm2/libdm/libdm-deptree.c
===================================================================
--- lvm2.orig/libdm/libdm-deptree.c
+++ lvm2/libdm/libdm-deptree.c
@@ -184,6 +184,8 @@ struct load_segment {
 	uint64_t rdevice_index;		/* Replicator-dev */
 
 	uint64_t rebuilds;	      /* raid */
+	uint64_t writemostly;	      /* raid */
+	uint32_t writebehind;	      /* raid */
 
 	struct dm_tree_node *metadata;	/* Thin_pool */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
@@ -2128,10 +2130,17 @@ static int _raid_emit_segment_line(struc
 	if (seg->region_size)
 		param_count += 2;
 
+	if (seg->writebehind)
+		param_count += 2;
+
 	/* rebuilds is 64-bit */
 	param_count += 2 * hweight32(seg->rebuilds & 0xFFFFFFFF);
 	param_count += 2 * hweight32(seg->rebuilds >> 32);
 
+	/* rebuilds is 64-bit */
+	param_count += 2 * hweight32(seg->writemostly & 0xFFFFFFFF);
+	param_count += 2 * hweight32(seg->writemostly >> 32);
+
 	if ((seg->type == SEG_RAID1) && seg->stripe_size)
 		log_error("WARNING: Ignoring RAID1 stripe size");
 
@@ -2150,6 +2159,13 @@ static int _raid_emit_segment_line(struc
 		if (seg->rebuilds & (1 << i))
 			EMIT_PARAMS(pos, " rebuild %u", i);
 
+	for (i = 0; i < (seg->area_count / 2); i++)
+		if (seg->writemostly & (1 << i))
+			EMIT_PARAMS(pos, " write_mostly %u", i);
+
+	if (seg->writebehind)
+		EMIT_PARAMS(pos, " writebehind %u", seg->writebehind);
+
 	/* Print number of metadata/data device pairs */
 	EMIT_PARAMS(pos, " %u", seg->area_count/2);
 
@@ -2826,19 +2842,15 @@ int dm_tree_node_add_mirror_target(struc
 	return 1;
 }
 
-int dm_tree_node_add_raid_target(struct dm_tree_node *node,
-				 uint64_t size,
-				 const char *raid_type,
-				 uint32_t region_size,
-				 uint32_t stripe_size,
-				 uint64_t rebuilds,
-				 uint64_t flags)
+int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
+					     uint64_t size,
+					     struct dm_tree_node_raid_params *p)
 {
 	int i;
 	struct load_segment *seg = NULL;
 
 	for (i = 0; dm_segtypes[i].target && !seg; i++)
-		if (!strcmp(raid_type, dm_segtypes[i].target))
+		if (!strcmp(p->raid_type, dm_segtypes[i].target))
 			if (!(seg = _add_segment(node,
 						 dm_segtypes[i].type, size)))
 				return_0;
@@ -2846,15 +2858,37 @@ int dm_tree_node_add_raid_target(struct
 	if (!seg)
 		return_0;
 
-	seg->region_size = region_size;
-	seg->stripe_size = stripe_size;
+	seg->region_size = p->region_size;
+	seg->stripe_size = p->stripe_size;
 	seg->area_count = 0;
-	seg->rebuilds = rebuilds;
-	seg->flags = flags;
+	seg->rebuilds = p->rebuilds;
+	seg->writemostly = p->writemostly;
+	seg->writebehind = p->writebehind;
+	seg->flags = p->flags;
 
 	return 1;
 }
 
+int dm_tree_node_add_raid_target(struct dm_tree_node *node,
+				 uint64_t size,
+				 const char *raid_type,
+				 uint32_t region_size,
+				 uint32_t stripe_size,
+				 uint64_t rebuilds,
+				 uint64_t flags)
+{
+	struct dm_tree_node_raid_params params;
+
+	memset(&params, 0, sizeof(params));
+	params.raid_type = raid_type;
+	params.region_size = region_size;
+	params.stripe_size = stripe_size;
+	params.rebuilds = rebuilds;
+	params.flags = flags;
+
+	return dm_tree_node_add_raid_target_with_params(node, size, &params);
+}
+
 
 /*
  * Various RAID status versions include:
Index: lvm2/man/lvchange.8.in
===================================================================
--- lvm2.orig/man/lvchange.8.in
+++ lvm2/man/lvchange.8.in
@@ -42,6 +42,8 @@ lvchange \- change attributes of a logic
 .RB [ \-\-refresh ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
+.RB [ \-\-writebehind BehindCount ]
+.RB [ \-\-writemostly PhysicalVolume ]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
 .I LogicalVolumePath
@@ -169,6 +171,25 @@ This is not necessary in normal operatio
 if something has gone wrong or if you're doing clustering
 manually without a clustered lock manager.
 .TP
+.BR \-\-writebehind " BehindCount"
+Specify the maximum number of outstanding writes that are allowed to
+devices in a RAID 1 logical volume that are marked as \fIwrite-mostly\fP.
+Once this value is exceeded, writes become synchronous (i.e. all writes
+to the constituent devices must complete before the array signals the
+write has completed).  Setting the value to zero clears the preference
+and allows the system to choose the value arbitrarily.
+.TP
+.BR \-\-writemostly " PhysicalVolume[:{t|y|n}]"
+Mark a device in a RAID1 logical volume as \fIwrite-mostly\fP.  All reads
+to these drives will be avoided unless absolutely necessary.  This keeps
+the number of I/Os to the drive to a minimum.  The default behavior is to
+set the write-mostly attribute for the specified physical volume in the
+logical volume.  It is possible to also remove the write-mostly flag by
+appending a ":n" to the physical volume or to toggle the value by specifying
+":t".  The \fI--writemostly\fP argument can be specified more than one time
+in a single command; making it possible to toggle the write-mostly attributes
+for all the physical volumes in a logical volume at once.
+.TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting zero to
Index: lvm2/tools/args.h
===================================================================
--- lvm2.orig/tools/args.h
+++ lvm2/tools/args.h
@@ -87,6 +87,8 @@ arg(ignoreunsupported_ARG, '\0', "ignore
 arg(atversion_ARG, '\0', "atversion", string_arg, 0)
 arg(validate_ARG, '\0', "validate", NULL, 0)
 arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)
+arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE)
+arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
Index: lvm2/tools/commands.h
===================================================================
--- lvm2.orig/tools/commands.h
+++ lvm2/tools/commands.h
@@ -96,6 +96,8 @@ xx(lvchange,
    "\t[-v|--verbose]\n"
    "\t[-y|--yes]\n"
    "\t[--version]\n"
+   "\t[--writebehind BehindCount\n"
+   "\t[--writemostly PhysicalVolume]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
@@ -104,7 +106,7 @@ xx(lvchange,
    major_ARG, minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG,
    permission_ARG, persistent_ARG, poll_ARG, readahead_ARG, resync_ARG,
    refresh_ARG, addtag_ARG, deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
-   yes_ARG, zero_ARG)
+   yes_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
Index: lvm2/tools/lvchange.c
===================================================================
--- lvm2.orig/tools/lvchange.c
+++ lvm2/tools/lvchange.c
@@ -699,6 +699,125 @@ static int lvchange_tag(struct cmd_conte
 	return 1;
 }
 
+static int lvchange_writemostly(struct logical_volume *lv)
+{
+	int s, pv_count, i = 0;
+	char **pv_names;
+	const char *tmp_str;
+	struct pv_list *pvl;
+	struct arg_value_group_list *group;
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct lv_segment *raid_seg = first_seg(lv);
+
+	if (strcmp(raid_seg->segtype->name, "raid1")) {
+		log_error("--write%s can only be used with 'raid1' segment type",
+			  arg_count(cmd, writemostly_ARG) ? "mostly" : "behind");
+		return 0;
+	}
+
+	if (arg_count(cmd, writebehind_ARG))
+		raid_seg->writebehind = arg_uint_value(cmd, writebehind_ARG, 0);
+
+	if (arg_count(cmd, writemostly_ARG)) {
+		/* writemostly can be specified more than once */
+		pv_count = arg_count(cmd, writemostly_ARG);
+		pv_names = dm_pool_alloc(cmd->mem, sizeof(char *) * pv_count);
+		if (!pv_names)
+			return_0;
+
+		dm_list_iterate_items(group, &cmd->arg_value_groups) {
+			if (!grouped_arg_is_set(group->arg_values,
+						writemostly_ARG))
+				continue;
+
+			if (!(tmp_str = grouped_arg_str_value(group->arg_values,
+							      writemostly_ARG,
+							      NULL)))
+				return_0;
+
+			/*
+			 * Writemostly PV specifications can be:
+			 *   <PV>   - Turn on writemostly
+			 *   <PV>:t - Toggle writemostly
+			 *   <PV>:n - Turn off writemostly
+			 *   <PV>:y - Turn on writemostly
+			 *
+			 * We allocate strlen + 3 to add our own ':{t|n|y}' if
+			 * not present plus the trailing '\0'.
+			 */
+			if (!(pv_names[i] = dm_pool_zalloc(cmd->mem,
+							   strlen(tmp_str) + 3)))
+				return_0;
+
+			if ((tmp_str[strlen(tmp_str) - 2] != ':') &&
+			    ((tmp_str[strlen(tmp_str) - 1] != 't') ||
+			     (tmp_str[strlen(tmp_str) - 1] != 'y') ||
+			     (tmp_str[strlen(tmp_str) - 1] != 'n')))
+				/* Default to 'y' if no mode specified */
+				sprintf(pv_names[i], "%s:y", tmp_str);
+			else
+				sprintf(pv_names[i], "%s", tmp_str);
+			i++;
+		}
+
+		for (i = 0; i < pv_count; i++)
+			pv_names[i][strlen(pv_names[i]) - 2] = '\0';
+
+		for (i = 0; i < pv_count; i++) {
+			if (!(pvl = find_pv_in_vg(lv->vg, pv_names[i]))) {
+				log_error("%s not found in volume group, %s",
+					  pv_names[i], lv->vg->name);
+				return 0;
+			}
+
+			for (s = 0; s < raid_seg->area_count; s++) {
+				/*
+				 * We don't bother checking the metadata area,
+				 * since writemostly only affects the data areas.
+				 */
+				if ((seg_type(raid_seg, s) == AREA_UNASSIGNED))
+					continue;
+
+				if (lv_is_on_pv(seg_lv(raid_seg, s), pvl->pv)) {
+					if (pv_names[i][strlen(pv_names[i]) + 1] == 'y')
+						seg_lv(raid_seg, s)->status |=
+							LV_WRITEMOSTLY;
+					else if (pv_names[i][strlen(pv_names[i]) + 1] == 'n')
+						seg_lv(raid_seg, s)->status &=
+							~LV_WRITEMOSTLY;
+					else if (pv_names[i][strlen(pv_names[i]) + 1] == 't')
+						seg_lv(raid_seg, s)->status ^=
+							LV_WRITEMOSTLY;
+					else
+						return_0;
+				}
+			}
+		}
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
+	log_very_verbose("Updating writemostly for \"%s\" in kernel", lv->name);
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
@@ -870,6 +989,17 @@ static int lvchange_single(struct cmd_co
 		docmds++;
 	}
 
+	/* change writemostly/writebehind */
+	if (arg_count(cmd, writemostly_ARG) || arg_count(cmd, writebehind_ARG)) {
+		if (!archived && !archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		archived = 1;
+		doit += lvchange_writemostly(lv);
+		docmds++;
+	}
+
 	if (doit)
 		log_print_unless_silent("Logical volume \"%s\" changed", lv->name);
 
@@ -945,6 +1075,8 @@ int lvchange(struct cmd_context *cmd, in
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, discards_ARG) ||
 		arg_count(cmd, syncaction_ARG) ||
+		arg_count(cmd, writebehind_ARG) ||
+		arg_count(cmd, writemostly_ARG) ||
 		arg_count(cmd, zero_ARG);
 	int update = update_partial_safe || update_partial_unsafe;
 
Index: lvm2/lib/metadata/lv.c
===================================================================
--- lvm2.orig/lib/metadata/lv.c
+++ lvm2/lib/metadata/lv.c
@@ -604,9 +604,11 @@ char *lv_attr_dup(struct dm_pool *mem, c
 		uint64_t n;
 		if (!_lv_raid_healthy(lv))
 			repstr[8] = 'r';  /* RAID needs 'r'efresh */
-		else if ((lv->status & RAID) &&
-			 lv_raid_mismatch_count(lv, &n) && n)
-			repstr[8] = 'm';  /* RAID contains 'm'ismatches */
+		else if (lv->status & RAID) {
+			if (lv_raid_mismatch_count(lv, &n) && n)
+				repstr[8] = 'm';  /* RAID has 'm'ismatches */
+		} else if (lv->status & LV_WRITEMOSTLY)
+			repstr[8] = 'w';  /* sub-LV has 'w'ritemostly */
 	}
 
 out:
Index: lvm2/man/lvs.8.in
===================================================================
--- lvm2.orig/man/lvs.8.in
+++ lvm2/man/lvs.8.in
@@ -118,6 +118,7 @@ sync_action,
 sync_percent,
 thin_count,
 transaction_id,
+writebehind,
 zero.
 .IP
 With \fB\-\-segments\fP, any "seg_" prefixes are optional;
@@ -161,7 +162,7 @@ snapshots of thin volumes using the new
 .IP 8 3
 Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
 .IP 9 3
-Volume Health: (p)artial, (r)efresh needed, (m)ismatches exist.
+Volume Health: (p)artial, (r)efresh needed, (m)ismatches exist, (w)ritemostly.
 (p)artial signifies that one or more of the Physical Volumes this Logical
 Volume uses is missing from the system.  (r)efresh signifies that one or
 more of the Physical Volumes this RAID Logical Volume uses had suffered a
@@ -172,7 +173,8 @@ has portions of the array that are not c
 recently repaired inconsistencies.  An additional "check" after a "repair"
 of a RAID logical volume will clear this flag if no additional discrepancies
 are found.  ("check" and "repair" of a RAID Logical Volume can be done via
-the 'lvchange' command.)
+the 'lvchange' command.)  (w)ritemostly signifies the devices in a RAID 1
+logical volume that have been marked write-mostly.
 .RE
 .TP
 .BR \-O ", " \-\-sort
Index: lvm2/lib/metadata/raid_manip.c
===================================================================
--- lvm2.orig/lib/metadata/raid_manip.c
+++ lvm2/lib/metadata/raid_manip.c
@@ -994,7 +994,8 @@ static int _raid_remove_images(struct lo
 				  " after linear conversion");
 			return 0;
 		}
-		lv->status &= ~LV_NOTSYNCED;
+		lv->status &= ~(LV_NOTSYNCED | LV_WRITEMOSTLY);
+		first_seg(lv)->writebehind = 0;
 	}
 
 	if (!vg_write(lv->vg)) {
Index: lvm2/lib/report/columns.h
===================================================================
--- lvm2.orig/lib/report/columns.h
+++ lvm2/lib/report/columns.h
@@ -82,6 +82,7 @@ FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8,
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, mismatch_count, mismatches, "For RAID, number of mismatches found or repaired.", 0)
 FIELD(LVS, lv, STR, "SyncAction", lvid, 10, sync_action, syncaction, "For RAID, the current synchronization action being performed.", 0)
+FIELD(LVS, lv, NUM, "WBehind", lvid, 7, write_behind, writebehind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
Index: lvm2/lib/report/properties.c
===================================================================
--- lvm2.orig/lib/report/properties.c
+++ lvm2/lib/report/properties.c
@@ -109,6 +109,10 @@ static char *_sync_action(const struct l
 	return action;
 }
 
+static uint32_t _writebehind(const struct logical_volume *lv) {
+	return first_seg(lv)->writebehind;
+}
+
 static percent_t _snap_percent(const struct logical_volume *lv) {
 	percent_t perc;
 
@@ -213,6 +217,8 @@ GET_LV_NUM_PROPERTY_FN(sync_percent, _co
 #define _sync_percent_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(mismatches, _mismatches(lv))
 #define _mismatches_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(writebehind, _writebehind(lv))
+#define _writebehind_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(syncaction, _sync_action(lv))
 #define _syncaction_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
Index: lvm2/lib/report/report.c
===================================================================
--- lvm2.orig/lib/report/report.c
+++ lvm2/lib/report/report.c
@@ -969,7 +969,24 @@ static int _mismatch_count_disp(struct d
 		return 1;
 	}
 
-	return  dm_report_field_uint64(rh, field, &mismatch_count);
+	return dm_report_field_uint64(rh, field, &mismatch_count);
+}
+
+static int _write_behind_disp(struct dm_report *rh __attribute__((unused)),
+			      struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data,
+			      void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (strcmp(first_seg(lv)->segtype->name, "raid1") ||
+	    !first_seg(lv)->writebehind) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
 }
 
 static int _dtpercent_disp(int metadata, struct dm_report *rh,
Index: lvm2/test/shell/lvchange-raid.sh
===================================================================
--- lvm2.orig/test/shell/lvchange-raid.sh
+++ lvm2/test/shell/lvchange-raid.sh
@@ -14,11 +14,102 @@
 
 . lib/test
 
-# dm-raid v1.5.0+ contains RAID scrubbing support
-aux target_at_least dm-raid 1 5 0 || skip
+# dm-raid v1.4.1+ contains RAID10 support
+aux target_at_least dm-raid 1 4 1 || skip
 
 aux prepare_vg 5
 
+# run_writemostly_check <VG> <LV>
+run_writemostly_check() {
+	d0=`lvs -a --noheadings -o devices $1/${2}_rimage_0 | sed s/\(.\)//`
+	d0=$(sed s/^[[:space:]]*// <<< "$d0")
+	d1=`lvs -a --noheadings -o devices $1/${2}_rimage_1 | sed s/\(.\)//`
+	d1=$(sed s/^[[:space:]]*// <<< "$d1")
+
+	# No writemostly flag should be there yet.
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+
+	if [ `lvs --noheadings -o segtype $1/$2` != "raid1" ]; then
+		not lvchange --writemostly $d0 $1/$2
+		return
+	fi
+
+	# Set the flag
+	lvchange --writemostly $d0 $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# Running again should leave it set (not toggle)
+	lvchange --writemostly $d0 $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# Running again with ':y' should leave it set
+	lvchange --writemostly $d0:y $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# ':n' should unset it
+	lvchange --writemostly $d0:n $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+
+	# ':n' again should leave it unset
+	lvchange --writemostly $d0:n $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+
+	# ':t' toggle to set
+	lvchange --writemostly $d0:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# ':t' toggle to unset
+	lvchange --writemostly $d0:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+
+	# ':y' to set
+	lvchange --writemostly $d0:y $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# Toggle both at once
+	lvchange --writemostly $d0:t --writemostly $d1:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w$'
+
+	# Toggle both@once again
+	lvchange --writemostly $d0:t --writemostly $d1:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+
+	# Toggle one, unset the other
+	lvchange --writemostly $d0:n --writemostly $d1:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w$'
+
+	# Toggle one, set the other
+	lvchange --writemostly $d0:y --writemostly $d1:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+
+	# Partial flag supercedes writemostly flag
+	aux disable_dev $d0
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*p$'
+	aux enable_dev $d0
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# Catch Bad writebehind values
+	not lvchange --writebehind "invalid" $1/$2
+	not lvchange --writebehind -256 $1/$2
+
+	# Set writebehind
+	[ ! `lvs --noheadings -o writebehind $1/$2` ]
+	lvchange --writebehind 512 $1/$2
+	[ `lvs --noheadings -o writebehind $1/$2` -eq 512 ]
+
+	# Converting to linear should clear flags and writebehind
+	lvconvert -m 0 $1/$2 $d1
+	lvconvert --type raid1 -m 1 $1/$2 $d1
+	[ ! `lvs --noheadings -o writebehind $1/$2` ]
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+}
+
 # run_syncaction_check <VG> <LV>
 run_syncaction_check() {
 	local device
@@ -109,6 +200,10 @@ run_refresh_check() {
 }
 
 run_checks() {
+	if aux target_at_least dm-raid 1 1 0; then
+		run_writemostly_check $1 $2
+	fi
+
 	if aux target_at_least dm-raid 1 5 0; then
 		run_syncaction_check $1 $2
 	fi
Index: lvm2/scripts/gdbinit
===================================================================
--- lvm2.orig/scripts/gdbinit
+++ lvm2/scripts/gdbinit
@@ -324,6 +324,11 @@ define __status
 		set $_s_status = $_s_status & ~0x10000000U
 		printf " MERGING"
 	end
+#	if ($_s_status & LV_WRITEMOSTLY)
+	if ($_s_status & 0x10000000000U)
+		set $_s_status = $_s_status & ~0x10000000000U
+		printf " LV_WRITEMOSTLY"
+	end
 
 	if ($_s_status)
 		printf " 0x%x", $_s_status



