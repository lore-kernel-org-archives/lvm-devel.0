From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:50 +0000 (UTC)
Subject: master - thin: use discards as plural rather than singular
Message-ID: <20120807203050.676A13454@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=701b4a8363417b7d72a7255ca663991f3be95859
Commit:        701b4a8363417b7d72a7255ca663991f3be95859
Parent:        df452b47a1ae0288e737cfcdc171f8fe31e4a876
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 21:24:41 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 21:24:41 2012 +0100

thin: use discards as plural rather than singular

Global change from --discard to --discards, as that feels more natural.
---
 WHATS_NEW                        |    4 +-
 WHATS_NEW_DM                     |    2 +-
 lib/activate/activate.h          |    2 +-
 lib/metadata/metadata-exported.h |   14 +++++-----
 lib/metadata/thin_manip.c        |   22 +++++++++---------
 lib/report/columns.h             |    2 +-
 lib/report/properties.c          |    4 +-
 lib/report/report.c              |   12 +++++-----
 lib/thin/thin.c                  |   46 +++++++++++++++++++-------------------
 libdm/libdevmapper.h             |    4 +-
 man/lvchange.8.in                |   10 ++++----
 man/lvcreate.8.in                |    6 ++--
 tools/args.h                     |    2 +-
 tools/commands.h                 |    8 +++---
 tools/lvchange.c                 |   28 +++++++++++-----------
 tools/lvmcmdline.c               |   10 ++++----
 tools/tools.h                    |    2 +-
 17 files changed, 89 insertions(+), 89 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 97f3150..25f4a9c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -11,9 +11,9 @@ Version 2.02.97 - 7th August 2012
   Recognise Micron PCIe SSDs in filter and move array out to device-types.h.
   Fix dumpconfig <node> to print only <node> without its siblings. (2.02.89)
   Do not issue "Failed to handle a client connection" error if lvmetad killed.
-  Support lvchange --discard and -Z with thin pools.
+  Support lvchange --discards and -Z with thin pools.
   Add discard LV segment field to reports.
-  Add --discard to lvcreate --thin.
+  Add --discards to lvcreate --thin.
   Set discard and external snapshot features if thin pool target is vsn 1.1+.
   Count percentage of completeness upwards not downwards when merging snapshot.
   Skip activation when using vg/lvchange --sysinit -a ay and lvmetad is active.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b18c10c..3890ea4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -4,7 +4,7 @@ Version 1.02.76 - 7th August 2012
   Allow --noflush with dmsetup status and wait (for thin target).
   Add dm_config_write_one_node to libdevmapper.
   Support thin pool message release/reserve_metadata_snap in libdevmapper.
-  Support thin pool discard and external origin features in libdevmapper.
+  Support thin pool discards and external origin features in libdevmapper.
   Add configure --enable-udev-rule-exec-detection to detect exec path in rules.
   Use sbindir in udev rules by default and remove executable path detection.
   Remove hard-coded paths for dmeventd fifos and use default-dm-run-dir.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 6497eea..ba24d2a 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -47,7 +47,7 @@ struct lv_activate_opts {
 /* thin target attribute flags */
 enum {
 	/* bitfields - new features from 1.1 version */
-	THIN_FEATURE_DISCARD			= (1 << 0),
+	THIN_FEATURE_DISCARDS			= (1 << 0),
 	THIN_FEATURE_EXTERNAL_ORIGIN		= (1 << 1),
 	THIN_FEATURE_HELD_ROOT			= (1 << 2),
 	THIN_FEATURE_BLOCK_SIZE			= (1 << 3),
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 35ffa93..74edb58 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -167,10 +167,10 @@ typedef enum {
 } force_t;
 
 typedef enum {
-	THIN_DISCARD_IGNORE,
-	THIN_DISCARD_NO_PASSDOWN,
-	THIN_DISCARD_PASSDOWN,
-} thin_discard_t;
+	THIN_DISCARDS_IGNORE,
+	THIN_DISCARDS_NO_PASSDOWN,
+	THIN_DISCARDS_PASSDOWN,
+} thin_discards_t;
 
 struct cmd_context;
 struct format_handler;
@@ -353,7 +353,7 @@ struct lv_segment {
 	uint64_t transaction_id;		/* For thin_pool, thin */
 	uint64_t low_water_mark;		/* For thin_pool */
 	unsigned zero_new_blocks;		/* For thin_pool */
-	thin_discard_t discard;			/* For thin_pool */
+	thin_discards_t discards;		/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
 	struct logical_volume *pool_lv;		/* For thin */
 	uint32_t device_id;			/* For thin, 24bit */
@@ -565,8 +565,8 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 
 int update_pool_lv(struct logical_volume *lv, int activate);
-int get_pool_discard(const char *str, thin_discard_t *discard);
-const char *get_pool_discard_name(thin_discard_t discard);
+int get_pool_discards(const char *str, thin_discards_t *discards);
+const char *get_pool_discards_name(thin_discards_t discards);
 
 /*
  * Activation options
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 0395b48..c1fa8b2 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -429,34 +429,34 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	return 1;
 }
 
-int get_pool_discard(const char *str, thin_discard_t *discard)
+int get_pool_discards(const char *str, thin_discards_t *discards)
 {
 	if (!strcasecmp(str, "passdown"))
-		*discard = THIN_DISCARD_PASSDOWN;
+		*discards = THIN_DISCARDS_PASSDOWN;
 	else if (!strcasecmp(str, "nopassdown"))
-		*discard = THIN_DISCARD_NO_PASSDOWN;
+		*discards = THIN_DISCARDS_NO_PASSDOWN;
 	else if (!strcasecmp(str, "ignore"))
-		*discard = THIN_DISCARD_IGNORE;
+		*discards = THIN_DISCARDS_IGNORE;
 	else {
-		log_error("Thin pool discard type %s is unknown.", str);
+		log_error("Thin pool discards type %s is unknown.", str);
 		return 0;
 	}
 
 	return 1;
 }
 
-const char *get_pool_discard_name(thin_discard_t discard)
+const char *get_pool_discards_name(thin_discards_t discards)
 {
-	switch (discard) {
-	case THIN_DISCARD_PASSDOWN:
+	switch (discards) {
+	case THIN_DISCARDS_PASSDOWN:
                 return "passdown";
-	case THIN_DISCARD_NO_PASSDOWN:
+	case THIN_DISCARDS_NO_PASSDOWN:
 		return "nopassdown";
-	case THIN_DISCARD_IGNORE:
+	case THIN_DISCARDS_IGNORE:
 		return "ignore";
 	}
 
-	log_error(INTERNAL_ERROR "Uknown discard type encountered.");
+	log_error(INTERNAL_ERROR "Uknown discards type encountered.");
 
 	return "unknown";
 }
diff --git a/lib/report/columns.h b/lib/report/columns.h
index c869d14..6299a2b 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -140,7 +140,7 @@ FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, region_size, "For mirror
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunksize, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "#Thins", list, 4, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
-FIELD(SEGS, seg, NUM, "Discard", list, 7, discard, discard, "For thin pools, how discards are handled.", 0)
+FIELD(SEGS, seg, NUM, "Discards", list, 8, discards, discards, "For thin pools, how discards are handled.", 0)
 FIELD(SEGS, seg, NUM, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
 FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index d78ad64..d2eac5e 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -277,8 +277,8 @@ GET_LVSEG_NUM_PROPERTY_FN(zero, lvseg->zero_new_blocks)
 #define _zero_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(transaction_id, lvseg->transaction_id)
 #define _transaction_id_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(discard, lvseg->discard)
-#define _discard_set _not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(discards, lvseg->discards)
+#define _discards_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start, lvseg_start(lvseg))
 #define _seg_start_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
diff --git a/lib/report/report.c b/lib/report/report.c
index b66be4f..a8553d2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -564,19 +564,19 @@ static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 	return  dm_report_field_uint64(rh, field, &seg->transaction_id);
 }
 
-static int _discard_disp(struct dm_report *rh, struct dm_pool *mem,
-			 struct dm_report_field *field,
-			 const void *data, void *private)
+static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-	const char *discard_str;
+	const char *discards_str;
 
 	if (seg_is_thin_volume(seg))
 		seg = first_seg(seg->pool_lv);
 
 	if (seg_is_thin_pool(seg)) {
-		discard_str = get_pool_discard_name(seg->discard);
-		return dm_report_field_string(rh, field, &discard_str);
+		discards_str = get_pool_discards_name(seg->discards);
+		return dm_report_field_string(rh, field, &discards_str);
 	}
 
 	dm_report_field_set_value(field, "", NULL);
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 3e562ef..5a044ee 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -87,7 +87,7 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 {
 	const char *lv_name;
 	struct logical_volume *pool_data_lv, *pool_metadata_lv;
-	const char *discard_str = NULL;
+	const char *discards_str = NULL;
 
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Metadata must be a string in");
@@ -114,14 +114,14 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 	if (!dm_config_get_uint32(sn, "chunk_size", &seg->chunk_size))
 		return SEG_LOG_ERROR("Could not read chunk_size");
 
-	if (dm_config_has_node(sn, "discard") &&
-	    !dm_config_get_str(sn, "discard", &discard_str))
-		return SEG_LOG_ERROR("Could not read discard for");
+	if (dm_config_has_node(sn, "discards") &&
+	    !dm_config_get_str(sn, "discards", &discard_str))
+		return SEG_LOG_ERROR("Could not read discards for");
 
-	if (!discard_str)
-		seg->discard = THIN_DISCARD_PASSDOWN;
-	else if (!get_pool_discard(discard_str, &seg->discard))
-		return SEG_LOG_ERROR("Discard option unsupported for");
+	if (!discards_str)
+		seg->discards = THIN_DISCARDS_PASSDOWN;
+	else if (!get_pool_discards(discards_str, &seg->discards))
+		return SEG_LOG_ERROR("Discards option unsupported for");
 
 	if (dm_config_has_node(sn, "low_water_mark") &&
 	    !dm_config_get_uint64(sn, "low_water_mark", &seg->low_water_mark))
@@ -163,14 +163,14 @@ static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter
 	outsize(f, (uint64_t) seg->chunk_size,
 		"chunk_size = %u", seg->chunk_size);
 
-	switch (seg->discard) {
-	case THIN_DISCARD_PASSDOWN:
-	case THIN_DISCARD_NO_PASSDOWN:
-	case THIN_DISCARD_IGNORE:
-		outf(f, "discard = \"%s\"", get_pool_discard_name(seg->discard));
+	switch (seg->discards) {
+	case THIN_DISCARDS_PASSDOWN:
+	case THIN_DISCARDS_NO_PASSDOWN:
+	case THIN_DISCARDS_IGNORE:
+		outf(f, "discards = \"%s\"", get_pool_discards_name(seg->discards));
 		break;
 	default:
-		log_error(INTERNAL_ERROR "Invalid discard value %d.", seg->discard);
+		log_error(INTERNAL_ERROR "Invalid discards value %d.", seg->discards);
 		return 0;
 	}
 
@@ -232,7 +232,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 				      struct dm_tree_node *node, uint64_t len,
 				      uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
-	static int _no_discard = 0;
+	static int _no_discards = 0;
 	char *metadata_dlid, *pool_dlid;
 	const struct lv_thin_message *lmsg;
 	const struct logical_volume *origin;
@@ -276,16 +276,16 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 
-	if (seg->discard != THIN_DISCARD_PASSDOWN)
-		if (attr & THIN_FEATURE_DISCARD) {
-			/* FIXME: Check whether underlying dev supports discard */
+	if (seg->discards != THIN_DISCARDS_PASSDOWN)
+		if (attr & THIN_FEATURE_DISCARDS) {
+			/* FIXME: Check whether underlying dev supports discards */
 			if (!dm_tree_node_set_thin_pool_discard(node,
-								seg->discard == THIN_DISCARD_IGNORE,
-								seg->discard == THIN_DISCARD_NO_PASSDOWN))
+								seg->discards == THIN_DISCARDS_IGNORE,
+								seg->discards == THIN_DISCARDS_NO_PASSDOWN))
 				return_0;
 		} else
-			log_warn_suppress(_no_discard++, "WARNING: Thin pool target does "
-					  "not support discard (needs kernel >= 3.4).");
+			log_warn_suppress(_no_discards++, "WARNING: Thin pool target does "
+					  "not support discards (needs kernel >= 3.4).");
 
 	/*
 	 * Add messages only for activation tree.
@@ -544,7 +544,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 		}
 
 		if (maj >=1 && min >= 1)
-			_attrs |= THIN_FEATURE_DISCARD;
+			_attrs |= THIN_FEATURE_DISCARDS;
 		else
 		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
 			log_debug("Target " THIN_MODULE " does not support discards.");
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 28685b2..6d24102 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -660,8 +660,8 @@ int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
 
 /*
  * Set thin pool discard features
- *   ignore      - Disable discard support
- *   no_passdown - Don't pass discard down to underlaying data device,
+ *   ignore      - Disable support for discards
+ *   no_passdown - Don't pass discards down to underlying data device,
  *                 just remove the mapping
  * Feature is available since version 1.1 of the thin target.
  */
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index e58d79c..32a0580 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -16,7 +16,7 @@ lvchange \- change attributes of a logical volume
 .RB [ \-d | \-\-debug ]
 .RB [ \-\-deltag
 .IR Tag ]
-.RB [ \-\-discard
+.RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
 .RB [ \-\-resync ]
 .RB [ \-h | \-? | \-\-help ]
@@ -72,13 +72,13 @@ logical volumes. It's only possible to change a non-contiguous
 logical volume's allocation policy to contiguous, if all of the
 allocated physical extents are already contiguous.
 .TP
-.BR \-\-discard " {" \fIignore | \fInopassdown | \fIpassdown }
+.BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
 Set this to \fIignore\fP to ignore any discards received by a
 thin pool Logical Volume.  Set to \fInopassdown\fP to process such
 discards within the thin pool itself and allow the no-longer-needed
-extents to be overwritten by new data.  Set to \fIpassdown\fP to
-process them both within the thin pool itself and to pass them down
-the underlying device.
+extents to be overwritten by new data.  Set to \fIpassdown\fP (the
+default) to process them both within the thin pool itself and to 
+pass them down the underlying device.
 .TP
 .B \-\-resync
 Forces the complete resynchronization of a mirror.  In normal
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 1911605..a87136a 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -54,7 +54,7 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-T | \-\-thin
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize ]
-.RB [ \-\-discard
+.RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
 .RB [ \-\-poolmetadatasize
 .IR MetadataSize [ bBsSkKmMgG ]]]
@@ -140,8 +140,8 @@ Sets or resets the contiguous allocation policy for
 logical volumes. Default is no contiguous allocation based
 on a next free principle.
 .TP
-.BR \-\-discard " {" \fIignore | \fInopassdown | \fIpassdown }
-Set discard behavior.
+.BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
+Set discards behavior.
 Default is \fIpassdown\fP.
 .TP
 .BR \-i ", " \-\-stripes " " \fIStripes
diff --git a/tools/args.h b/tools/args.h
index b195303..796fc51 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -72,7 +72,7 @@ arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
-arg(discard_ARG, '\0', "discard", discard_arg, 0)
+arg(discards_ARG, '\0', "discards", discards_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 47b540e..2a4404e 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -69,7 +69,7 @@ xx(lvchange,
    "\t[--deltag Tag]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
-   "\t[--discard {ignore|nopassdown|passdown}]\n"
+   "\t[--discards {ignore|nopassdown|passdown}]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
@@ -90,7 +90,7 @@ xx(lvchange,
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    alloc_ARG, autobackup_ARG, activate_ARG, available_ARG, contiguous_ARG,
-   discard_ARG, force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
+   discards_ARG, force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    major_ARG, minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG,
    permission_ARG, persistent_ARG, poll_ARG, readahead_ARG, resync_ARG,
    refresh_ARG, addtag_ARG, deltag_ARG, sysinit_ARG, test_ARG, yes_ARG,
@@ -198,7 +198,7 @@ xx(lvcreate,
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous {y|n}]\n"
    "\t[-d|--debug]\n"
-   "\t[--discard {ignore|nopassdown|passdown}]\n"
+   "\t[--discards {ignore|nopassdown|passdown}]\n"
    "\t[-h|-?|--help]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
@@ -219,7 +219,7 @@ xx(lvcreate,
    "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
-   chunksize_ARG, contiguous_ARG, corelog_ARG, discard_ARG, extents_ARG,
+   chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, extents_ARG,
    ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG,
    persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG,
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1a4318f..a0c4a01 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -95,28 +95,28 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 	int r = 0;
 	int update = 0;
 	unsigned val;
-	thin_discard_t discard;
+	thin_discards_t discards;
 
 	if (!lv_is_thin_pool(lv)) {
 		log_error("Logical volume \"%s\" is not a thin pool.", lv->name);
 		return 0;
 	}
 
-	if (arg_count(cmd, discard_ARG)) {
-		discard = arg_uint_value(cmd, discard_ARG, 0);
-		if (discard != first_seg(lv)->discard) {
-			if (((discard == THIN_DISCARD_IGNORE) ||
-			     (first_seg(lv)->discard == THIN_DISCARD_IGNORE)) &&
+	if (arg_count(cmd, discards_ARG)) {
+		discards = arg_uint_value(cmd, discards_ARG, 0);
+		if (discards != first_seg(lv)->discards) {
+			if (((discards == THIN_DISCARDS_IGNORE) ||
+			     (first_seg(lv)->discards == THIN_DISCARDS_IGNORE)) &&
 			    lv_is_active(lv))
-				log_error("Cannot change discard state for active "
+				log_error("Cannot change discards state for active "
 					  "logical volume \"%s\".", lv->name);
 			else {
-				first_seg(lv)->discard = discard;
+				first_seg(lv)->discards = discards;
 				update++;
 			}
 		} else
-			log_error("Logical volume \"%s\" already uses discard %s.",
-				  lv->name, get_pool_discard_name(discard));
+			log_error("Logical volume \"%s\" already uses --discards %s.",
+				  lv->name, get_pool_discards_name(discards));
 	}
 
 	if (arg_count(cmd, zero_ARG)) {
@@ -623,7 +623,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!(lv->vg->status & LVM_WRITE) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
-	     arg_count(cmd, discard_ARG) ||
+	     arg_count(cmd, discards_ARG) ||
 	     arg_count(cmd, zero_ARG) ||
 	     arg_count(cmd, alloc_ARG))) {
 		log_error("Only -a permitted with read-only volume "
@@ -750,7 +750,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (arg_count(cmd, discard_ARG) ||
+	if (arg_count(cmd, discards_ARG) ||
 	    arg_count(cmd, zero_ARG)) {
 		if (!archived && !archive(lv->vg)) {
 			stack;
@@ -839,14 +839,14 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
 		arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG) ||
-		arg_count(cmd, discard_ARG) || arg_count(cmd, zero_ARG);
+		arg_count(cmd, discards_ARG) || arg_count(cmd, zero_ARG);
 
 	if (!update &&
             !arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG) &&
             !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG)) {
 		log_error("Need 1 or more of -a, -C, -M, -p, -r, -Z, "
 			  "--resync, --refresh, --alloc, --addtag, --deltag, "
-			  "--monitor, --poll or --discard");
+			  "--monitor, --poll or --discards");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 50a2ac1..9964817 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -216,15 +216,15 @@ int activation_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_v
 	return 1;
 }
 
-int discard_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
+int discards_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
-	thin_discard_t discard;
+	thin_discards_t discards;
 
-	if (!get_pool_discard(av->value, &discard))
+	if (!get_pool_discards(av->value, &discards))
 		return_0;
 
-	av->i_value = discard;
-	av->ui_value = discard;
+	av->i_value = discards;
+	av->ui_value = discards;
 
 	return 1;
 }
diff --git a/tools/tools.h b/tools/tools.h
index 4d2f5b0..a3ad9fd 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -139,7 +139,7 @@ void usage(const char *name);
 /* the argument verify/normalise functions */
 int yes_no_arg(struct cmd_context *cmd, struct arg_values *av);
 int activation_arg(struct cmd_context *cmd, struct arg_values *av);
-int discard_arg(struct cmd_context *cmd, struct arg_values *av);
+int discards_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);


