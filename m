From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Jul 2012 12:39:19 +0000 (UTC)
Subject: master - thin: add discard support for thin pool
Message-ID: <20120718123919.CF0EF8A1@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ebbf7d8e68f37c1a1e448a07676cca0a6e7f1430
Commit:        ebbf7d8e68f37c1a1e448a07676cca0a6e7f1430
Parent:        260e8f24768d7a6e7c6a8018b5c2b08e7a35e35c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 28 14:47:34 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 18 14:36:57 2012 +0200

thin: add discard support for thin pool

Add arg support for discard.
Add discard ignore, nopassdown, passdown (=default) support.
Flags could be set per pool.

lvcreate [--discard {ignore|no_passdown|passdown}]  vg/thinlv
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    9 +++++++
 lib/metadata/thin_manip.c        |   35 ++++++++++++++++++++++++++++++
 lib/thin/thin.c                  |   44 ++++++++++++++++++++++++++++++++++++++
 man/lvcreate.8.in                |    6 +++++
 tools/args.h                     |    1 +
 tools/commands.h                 |    6 ++++-
 tools/lvmcmdline.c               |   13 +++++++++++
 tools/tools.h                    |    1 +
 9 files changed, 115 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 54ae73b..41b52be 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add support for controlling discard behavior of thin pool.
   Detect features for new 1.1 thin pool target.
   Count percentage of completeness upwards when merging a snapshot volume.
   Skip activation when using vg/lvchange --sysinit -a ay and lvmetad is active.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8c655c7..d2afdb1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -166,6 +166,12 @@ typedef enum {
 	DONT_PROMPT_OVERRIDE = 2 /* Skip prompt + override a second condition */
 } force_t;
 
+typedef enum {
+	THIN_DISCARD_PASSDOWN,
+	THIN_DISCARD_NO_PASSDOWN,
+	THIN_DISCARD_IGNORE,
+} thin_discard_t;
+
 struct cmd_context;
 struct format_handler;
 struct labeller;
@@ -347,6 +353,7 @@ struct lv_segment {
 	uint64_t transaction_id;		/* For thin_pool, thin */
 	uint64_t low_water_mark;		/* For thin_pool */
 	unsigned zero_new_blocks;		/* For thin_pool */
+	thin_discard_t discard;			/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
 	struct logical_volume *pool_lv;		/* For thin */
 	uint32_t device_id;			/* For thin, 24bit */
@@ -558,6 +565,8 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 
 int update_pool_lv(struct logical_volume *lv, int activate);
+int get_pool_discard(const char *str, thin_discard_t *discard);
+const char *get_pool_discard_name(thin_discard_t discard);
 
 /*
  * Activation options
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index ae8d509..8d1744c 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -428,3 +428,38 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 
 	return 1;
 }
+
+int get_pool_discard(const char *str, thin_discard_t *discard)
+{
+	if (!strcasecmp(str, "passdown"))
+		*discard = THIN_DISCARD_PASSDOWN;
+        /* Allow some variation in thin parameter */
+	else if (!strcasecmp(str, "nopassdown") ||
+		 !strcasecmp(str, "no-passdown") ||
+		 !strcasecmp(str, "no_passdown"))
+		*discard = THIN_DISCARD_NO_PASSDOWN;
+	else if (!strcasecmp(str, "ignore"))
+		*discard = THIN_DISCARD_IGNORE;
+	else {
+		log_error("Thin pool discard type %s is unknown.", str);
+		return 0;
+	}
+
+	return 1;
+}
+
+const char *get_pool_discard_name(thin_discard_t discard)
+{
+	switch (discard) {
+	case THIN_DISCARD_PASSDOWN:
+                return "passdown";
+	case THIN_DISCARD_NO_PASSDOWN:
+		return "nopassdown";
+	case THIN_DISCARD_IGNORE:
+		return "ignore";
+	}
+
+	log_error(INTERNAL_ERROR "Uknown discard type.");
+
+	return NULL;
+}
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 974293c..27ce6f5 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -39,6 +39,10 @@
 	log_error(t " segment %s of logical volume %s.", ## p, \
 		  dm_config_parent_name(sn), seg->lv->name), 0;
 
+static int _thin_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg,
+				unsigned *attributes);
+
 static const char *_thin_pool_name(const struct lv_segment *seg)
 {
 	return seg->segtype->name;
@@ -83,6 +87,7 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 {
 	const char *lv_name;
 	struct logical_volume *pool_data_lv, *pool_metadata_lv;
+	const char *discard = NULL;
 
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Metadata must be a string in");
@@ -109,6 +114,15 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 	if (!dm_config_get_uint32(sn, "chunk_size", &seg->chunk_size))
 		return SEG_LOG_ERROR("Could not read chunk_size");
 
+	if (dm_config_has_node(sn, "discard") &&
+	    !dm_config_get_str(sn, "discard", &discard))
+		return SEG_LOG_ERROR("Could not read discard for");
+
+	if (!discard)
+		seg->discard = THIN_DISCARD_PASSDOWN;
+	else if (!get_pool_discard(discard, &seg->discard))
+		return SEG_LOG_ERROR("Discard option unsupported for");
+
 	if (dm_config_has_node(sn, "low_water_mark") &&
 	    !dm_config_get_uint64(sn, "low_water_mark", &seg->low_water_mark))
 		return SEG_LOG_ERROR("Could not read low_water_mark");
@@ -149,6 +163,19 @@ static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter
 	outsize(f, (uint64_t) seg->chunk_size,
 		"chunk_size = %u", seg->chunk_size);
 
+	switch (seg->discard) {
+	case THIN_DISCARD_PASSDOWN:
+		/* nothing to do */
+		break;
+	case THIN_DISCARD_NO_PASSDOWN:
+	case THIN_DISCARD_IGNORE:
+		outf(f, "discard = \"%s\"", get_pool_discard_name(seg->discard));
+		break;
+	default:
+		log_error(INTERNAL_ERROR "Unexportable discard.");
+		return 0;
+	}
+
 	if (seg->low_water_mark)
 		outf(f, "low_water_mark = %" PRIu64, seg->low_water_mark);
 
@@ -207,11 +234,16 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 				      struct dm_tree_node *node, uint64_t len,
 				      uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
+	static int _no_discard = 0;
 	char *metadata_dlid, *pool_dlid;
 	const struct lv_thin_message *lmsg;
 	const struct logical_volume *origin;
 	struct lvinfo info;
 	uint64_t transaction_id = 0;
+	unsigned attr;
+
+	if (!_thin_target_present(cmd, seg, &attr))
+		return_0;
 
 	if (!laopts->real_pool) {
 		if (!(pool_dlid = build_dm_uuid(mem, seg->lv->lvid.s, "tpool"))) {
@@ -246,6 +278,18 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 
+	if (seg->discard != THIN_DISCARD_PASSDOWN) {
+		if (attr & THIN_FEATURE_DISCARD) {
+			/* FIXME: Check whether underlaying dev supports discard */
+			if (!dm_tree_node_set_thin_pool_discard(node,
+								seg->discard == THIN_DISCARD_IGNORE,
+								seg->discard == THIN_DISCARD_NO_PASSDOWN))
+				return_0;
+		} else
+			log_warn_suppress(_no_discard++, "WARNING: Thin pool target does "
+					  "not support discard (needs kernel >= 3.4).");
+	}
+
 	/*
 	 * Add messages only for activation tree.
 	 * Otherwise avoid checking for existence of suspended origin.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 2917775..1911605 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -54,6 +54,8 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-T | \-\-thin
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize ]
+.RB [ \-\-discard
+.RI { ignore | nopassdown | passdown }]
 .RB [ \-\-poolmetadatasize
 .IR MetadataSize [ bBsSkKmMgG ]]]
 .RB [ \-\-thinpool
@@ -138,6 +140,10 @@ Sets or resets the contiguous allocation policy for
 logical volumes. Default is no contiguous allocation based
 on a next free principle.
 .TP
+.BR \-\-discard " {" \fIignore | \fInopassdown | \fIpassdown }
+Set discard behavior.
+Default is \fIpassdown\fP.
+.TP
 .BR \-i ", " \-\-stripes " " \fIStripes
 Gives the number of stripes.
 This is equal to the number of physical volumes to scatter
diff --git a/tools/args.h b/tools/args.h
index 2ce3c36..4909f9e 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -72,6 +72,7 @@ arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
+arg(discard_ARG, '\0', "discard", discard_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 3454951..fe7403d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -177,6 +177,10 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
+   "\t[-T|--thin  [-c|--chunksize  ChunkSize]\n"
+   "\t  [--discard {ignore|nopassdown|passdown}]\n"
+   "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]]\n"
+   "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
@@ -215,7 +219,7 @@ xx(lvcreate,
    "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
-   chunksize_ARG, contiguous_ARG, corelog_ARG, extents_ARG,
+   chunksize_ARG, contiguous_ARG, corelog_ARG, extents_ARG, discard_ARG,
    ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG,
    persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 16e15a1..0e6a51c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -216,6 +216,19 @@ int activation_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_v
 	return 1;
 }
 
+int discard_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
+{
+	thin_discard_t discard;
+
+	if (!get_pool_discard(av->value, &discard))
+		return_0;
+
+	av->i_value = discard;
+	av->ui_value = discard;
+
+	return 1;
+}
+
 int metadatatype_arg(struct cmd_context *cmd, struct arg_values *av)
 {
 	return get_format_by_name(cmd, av->value) ? 1 : 0;
diff --git a/tools/tools.h b/tools/tools.h
index 7a44651..f92abd5 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -139,6 +139,7 @@ void usage(const char *name);
 /* the argument verify/normalise functions */
 int yes_no_arg(struct cmd_context *cmd, struct arg_values *av);
 int activation_arg(struct cmd_context *cmd, struct arg_values *av);
+int discard_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);
 int size_mb_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);


