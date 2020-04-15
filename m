From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Apr 2020 18:10:01 +0000 (GMT)
Subject: master - Allow dm-integrity to be used for raid images
Message-ID: <20200415181001.AE490384A023@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d9e8895a96539d75166c0f74e58f5ed4e729e551
Commit:        d9e8895a96539d75166c0f74e58f5ed4e729e551
Parent:        b6b4ad8e28eff7476cb04c4cb93312b06605b82f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 20 16:07:27 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 15 12:10:32 2020 -0500

Allow dm-integrity to be used for raid images

dm-integrity stores checksums of the data written to an
LV, and returns an error if data read from the LV does
not match the previously saved checksum.  When used on
raid images, dm-raid will correct the error by reading
the block from another image, and the device user sees
no error.  The integrity metadata (checksums) are stored
on an internal LV allocated by lvm for each linear image.
The internal LV is allocated on the same PV as the image.

Create a raid LV with an integrity layer over each
raid image (for raid levels 1,4,5,6,10):

lvcreate --type raidN --raidintegrity y [options]

Add an integrity layer to images of an existing raid LV:

lvconvert --raidintegrity y LV

Remove the integrity layer from images of a raid LV:

lvconvert --raidintegrity n LV

Settings

Use --raidintegritymode journal|bitmap (journal is default)
to configure the method used by dm-integrity to ensure
crash consistency.

Initialization

When integrity is added to an LV, the kernel needs to
initialize the integrity metadata/checksums for all blocks
in the LV.  The data corruption checking performed by
dm-integrity will only operate on areas of the LV that
are already initialized.  The progress of integrity
initialization is reported by the "syncpercent" LV
reporting field (and under the Cpy%Sync lvs column.)

Example: create a raid1 LV with integrity:

$ lvcreate --type raid1 -m1 --raidintegrity y -n rr -L1G foo
  Creating integrity metadata LV rr_rimage_0_imeta with size 12.00 MiB.
  Logical volume "rr_rimage_0_imeta" created.
  Creating integrity metadata LV rr_rimage_1_imeta with size 12.00 MiB.
  Logical volume "rr_rimage_1_imeta" created.
  Logical volume "rr" created.
$ lvs -a foo
  LV                  VG  Attr       LSize  Origin              Cpy%Sync
  rr                  foo rwi-a-r---  1.00g                     4.93
  [rr_rimage_0]       foo gwi-aor---  1.00g [rr_rimage_0_iorig] 41.02
  [rr_rimage_0_imeta] foo ewi-ao---- 12.00m
  [rr_rimage_0_iorig] foo -wi-ao----  1.00g
  [rr_rimage_1]       foo gwi-aor---  1.00g [rr_rimage_1_iorig] 39.45
  [rr_rimage_1_imeta] foo ewi-ao---- 12.00m
  [rr_rimage_1_iorig] foo -wi-ao----  1.00g
  [rr_rmeta_0]        foo ewi-aor---  4.00m
  [rr_rmeta_1]        foo ewi-aor---  4.00m
---
 configure                           |  27 ++
 configure.ac                        |  18 +
 device_mapper/all.h                 |  39 ++
 device_mapper/ioctl/libdm-iface.c   |  31 +-
 device_mapper/ioctl/libdm-targets.h |   1 +
 device_mapper/libdm-deptree.c       | 154 ++++++-
 device_mapper/libdm-targets.c       |  27 ++
 include/configure.h.in              |   3 +
 lib/Makefile.in                     |   2 +
 lib/activate/activate.c             |   7 +
 lib/activate/activate.h             |   4 +
 lib/activate/dev_manager.c          |  18 +-
 lib/commands/toolcontext.c          |   5 +
 lib/device/dev-type.c               |  39 ++
 lib/device/dev-type.h               |   2 +
 lib/format_text/flags.c             |   2 +
 lib/integrity/integrity.c           | 343 +++++++++++++++
 lib/metadata/integrity_manip.c      | 821 ++++++++++++++++++++++++++++++++++++
 lib/metadata/lv.c                   |  18 +-
 lib/metadata/lv_manip.c             | 150 ++++++-
 lib/metadata/merge.c                |   2 +
 lib/metadata/metadata-exported.h    |  26 ++
 lib/metadata/raid_manip.c           |  85 +++-
 lib/metadata/segtype.h              |   6 +
 lib/metadata/snapshot_manip.c       |   2 +
 lib/misc/lvm-string.c               |   4 +-
 lib/report/report.c                 |   2 +-
 man/lvmraid.7_main                  |  83 ++++
 test/lib/aux.sh                     |   8 +
 test/shell/integrity-blocksize.sh   | 183 ++++++++
 test/shell/integrity-dmeventd.sh    | 289 +++++++++++++
 test/shell/integrity-large.sh       | 175 ++++++++
 test/shell/integrity-misc.sh        | 228 ++++++++++
 test/shell/integrity.sh             | 735 ++++++++++++++++++++++++++++++++
 tools/args.h                        |  20 +
 tools/command-lines.in              |  45 +-
 tools/lv_props.h                    |   1 +
 tools/lv_types.h                    |   1 +
 tools/lvchange.c                    |   5 +
 tools/lvconvert.c                   | 137 ++++++
 tools/lvcreate.c                    |  15 +-
 tools/lvmcmdline.c                  |   3 +
 tools/pvmove.c                      |  10 +
 tools/toollib.c                     |  47 +++
 tools/tools.h                       |   4 +
 45 files changed, 3790 insertions(+), 37 deletions(-)

diff --git a/configure b/configure
index 6dd7edac3..716ee9ca7 100755
--- a/configure
+++ b/configure
@@ -918,6 +918,7 @@ enable_cache_check_needs_check
 with_vdo
 with_vdo_format
 with_writecache
+with_integrity
 enable_readline
 enable_realtime
 enable_ocf
@@ -1716,6 +1717,7 @@ Optional Packages:
   --with-vdo=TYPE         vdo support: internal/none [internal]
   --with-vdo-format=PATH  vdoformat tool: [autodetect]
   --with-writecache=TYPE  writecache support: internal/none [none]
+  --with-integrity=TYPE   integrity support: internal/none [none]
   --with-ocfdir=DIR       install OCF files in
                           [PREFIX/lib/ocf/resource.d/lvm2]
   --with-default-pid-dir=PID_DIR
@@ -9761,6 +9763,31 @@ $as_echo "#define WRITECACHE_INTERNAL 1" >>confdefs.h
  *) as_fn_error $? "--with-writecache parameter invalid" "$LINENO" 5 ;;
 esac
 
+################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include integrity" >&5
+$as_echo_n "checking whether to include integrity... " >&6; }
+
+# Check whether --with-integrity was given.
+if test "${with_integrity+set}" = set; then :
+  withval=$with_integrity; INTEGRITY=$withval
+else
+  INTEGRITY="none"
+fi
+
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $INTEGRITY" >&5
+$as_echo "$INTEGRITY" >&6; }
+
+case "$INTEGRITY" in
+ none) ;;
+ internal)
+
+$as_echo "#define INTEGRITY_INTERNAL 1" >>confdefs.h
+
+	;;
+ *) as_fn_error $? "--with-integrity parameter invalid" "$LINENO" 5 ;;
+esac
+
 ################################################################################
 # Check whether --enable-readline was given.
 if test "${enable_readline+set}" = set; then :
diff --git a/configure.ac b/configure.ac
index 74ca20191..9a0e41a81 100644
--- a/configure.ac
+++ b/configure.ac
@@ -667,6 +667,24 @@ case "$WRITECACHE" in
  *) AC_MSG_ERROR([--with-writecache parameter invalid]) ;;
 esac
 
+################################################################################
+dnl -- integrity inclusion type
+AC_MSG_CHECKING(whether to include integrity)
+AC_ARG_WITH(integrity,
+	    AC_HELP_STRING([--with-integrity=TYPE],
+			   [integrity support: internal/none [none]]),
+			   INTEGRITY=$withval, INTEGRITY="none")
+
+AC_MSG_RESULT($INTEGRITY)
+
+case "$INTEGRITY" in
+ none) ;;
+ internal)
+	AC_DEFINE([INTEGRITY_INTERNAL], 1, [Define to 1 to include built-in support for integrity.])
+	;;
+ *) AC_MSG_ERROR([--with-integrity parameter invalid]) ;;
+esac
+
 ################################################################################
 dnl -- Disable readline
 AC_ARG_ENABLE([readline],
diff --git a/device_mapper/all.h b/device_mapper/all.h
index b23485f00..f00b6a5dc 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -234,6 +234,7 @@ int dm_task_suppress_identical_reload(struct dm_task *dmt);
 int dm_task_secure_data(struct dm_task *dmt);
 int dm_task_retry_remove(struct dm_task *dmt);
 int dm_task_deferred_remove(struct dm_task *dmt);
+void dm_task_skip_reload_params_compare(struct dm_task *dmt);
 
 /*
  * Record timestamp immediately after the ioctl returns.
@@ -392,6 +393,15 @@ struct dm_status_writecache {
 int dm_get_status_writecache(struct dm_pool *mem, const char *params,
                              struct dm_status_writecache **status);
 
+struct dm_status_integrity {
+	uint64_t number_of_mismatches;
+	uint64_t provided_data_sectors;
+	uint64_t recalc_sector;
+};
+
+int dm_get_status_integrity(struct dm_pool *mem, const char *params,
+                            struct dm_status_integrity **status);
+
 /*
  * Parse params from STATUS call for snapshot target
  *
@@ -970,6 +980,35 @@ int dm_tree_node_add_writecache_target(struct dm_tree_node *node,
 				uint32_t writecache_block_size,
 				struct writecache_settings *settings);
 
+struct integrity_settings {
+	char mode[8];
+	uint32_t tag_size;
+	uint32_t block_size;       /* optional table param always set by lvm */
+	const char *internal_hash; /* optional table param always set by lvm */
+
+	uint32_t journal_sectors;
+	uint32_t interleave_sectors;
+	uint32_t buffer_sectors;
+	uint32_t journal_watermark;
+	uint32_t commit_time;
+	uint32_t bitmap_flush_interval;
+	uint64_t sectors_per_bit;
+
+	unsigned journal_sectors_set:1;
+	unsigned interleave_sectors_set:1;
+	unsigned buffer_sectors_set:1;
+	unsigned journal_watermark_set:1;
+	unsigned commit_time_set:1;
+	unsigned bitmap_flush_interval_set:1;
+	unsigned sectors_per_bit_set:1;
+};
+
+int dm_tree_node_add_integrity_target(struct dm_tree_node *node,
+				uint64_t size,
+				const char *origin_uuid,
+				const char *meta_uuid,
+				struct integrity_settings *settings,
+				int recalculate);
 
 /*
  * VDO target
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index fe04af8bf..25e7d1a75 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -805,6 +805,11 @@ int dm_task_suppress_identical_reload(struct dm_task *dmt)
 	return 1;
 }
 
+void dm_task_skip_reload_params_compare(struct dm_task *dmt)
+{
+	dmt->skip_reload_params_compare = 1;
+}
+
 int dm_task_set_add_node(struct dm_task *dmt, dm_add_node_t add_node)
 {
 	switch (add_node) {
@@ -1575,11 +1580,29 @@ static int _reload_with_suppression_v4(struct dm_task *dmt)
 		len = strlen(t2->params);
 		while (len-- > 0 && t2->params[len] == ' ')
 			t2->params[len] = '\0';
-		if ((t1->start != t2->start) ||
-		    (t1->length != t2->length) ||
-		    (strcmp(t1->type, t2->type)) ||
-		    (strcmp(t1->params, t2->params)))
+
+		if (t1->start != t2->start) {
+			log_debug("reload %u:%u start diff", task->major, task->minor);
+			goto no_match;
+		}
+		if (t1->length != t2->length) {
+			log_debug("reload %u:%u length diff", task->major, task->minor);
 			goto no_match;
+		}
+		if (strcmp(t1->type, t2->type)) {
+			log_debug("reload %u:%u type diff %s %s", task->major, task->minor, t1->type, t2->type);
+			goto no_match;
+		}
+		if (strcmp(t1->params, t2->params)) {
+			if (dmt->skip_reload_params_compare)
+				log_debug("reload %u:%u skip params ignore %s %s",
+					  task->major, task->minor, t1->params, t2->params);
+			else {
+				log_debug("reload %u:%u params diff", task->major, task->minor);
+				goto no_match;
+			}
+		}
+
 		t1 = t1->next;
 		t2 = t2->next;
 	}
diff --git a/device_mapper/ioctl/libdm-targets.h b/device_mapper/ioctl/libdm-targets.h
index b5b20d5e9..9786a7eda 100644
--- a/device_mapper/ioctl/libdm-targets.h
+++ b/device_mapper/ioctl/libdm-targets.h
@@ -59,6 +59,7 @@ struct dm_task {
 	int skip_lockfs;
 	int query_inactive_table;
 	int suppress_identical_reload;
+	int skip_reload_params_compare;
 	dm_add_node_t add_node;
 	uint64_t existing_table_size;
 	int cookie_set;
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 7fac6ab20..9ba24cbbf 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -38,6 +38,7 @@ enum {
 	SEG_STRIPED,
 	SEG_ZERO,
 	SEG_WRITECACHE,
+	SEG_INTEGRITY,
 	SEG_THIN_POOL,
 	SEG_THIN,
 	SEG_VDO,
@@ -78,6 +79,7 @@ static const struct {
 	{ SEG_STRIPED, "striped" },
 	{ SEG_ZERO, "zero"},
 	{ SEG_WRITECACHE, "writecache"},
+	{ SEG_INTEGRITY, "integrity"},
 	{ SEG_THIN_POOL, "thin-pool"},
 	{ SEG_THIN, "thin"},
 	{ SEG_VDO, "vdo" },
@@ -221,6 +223,11 @@ struct load_segment {
 	int writecache_pmem;				/* writecache, 1 if pmem, 0 if ssd */
 	uint32_t writecache_block_size;			/* writecache, in bytes */
 	struct writecache_settings writecache_settings;	/* writecache */
+
+	uint64_t integrity_data_sectors;		/* integrity (provided_data_sectors) */
+	struct dm_tree_node *integrity_meta_node;	/* integrity */
+	struct integrity_settings integrity_settings;	/* integrity */
+	int integrity_recalculate;			/* integrity */
 };
 
 /* Per-device properties */
@@ -267,6 +274,16 @@ struct load_properties {
 	 */
 	unsigned delay_resume_if_extended;
 
+	/*
+	 * When comparing table lines to decide if a reload is
+	 * needed, ignore any differences betwen the lvm device
+	 * params and the kernel-reported device params.
+	 * dm-integrity reports many internal parameters on the
+	 * table line when lvm does not explicitly set them,
+	 * causing lvm and the kernel to have differing params.
+	 */
+	unsigned skip_reload_params_compare;
+
 	/*
 	 * Call node_send_messages(), set to 2 if there are messages
 	 * When != 0, it validates matching transaction id, thus thin-pools
@@ -2705,6 +2722,84 @@ static int _writecache_emit_segment_line(struct dm_task *dmt,
 	return 1;
 }
 
+static int _integrity_emit_segment_line(struct dm_task *dmt,
+				    struct load_segment *seg,
+				    char *params, size_t paramsize)
+{
+	struct integrity_settings *set = &seg->integrity_settings;
+	int pos = 0;
+	int count;
+	char origin_dev[DM_FORMAT_DEV_BUFSIZE];
+	char meta_dev[DM_FORMAT_DEV_BUFSIZE];
+
+	if (!_build_dev_string(origin_dev, sizeof(origin_dev), seg->origin))
+		return_0;
+
+	if (seg->integrity_meta_node &&
+	    !_build_dev_string(meta_dev, sizeof(meta_dev), seg->integrity_meta_node))
+		return_0;
+
+	count = 3; /* block_size, internal_hash, fix_padding options are always passed */
+
+	if (seg->integrity_meta_node)
+		count++;
+
+	if (seg->integrity_recalculate)
+		count++;
+
+	if (set->journal_sectors_set)
+		count++;
+	if (set->interleave_sectors_set)
+		count++;
+	if (set->buffer_sectors_set)
+		count++;
+	if (set->journal_watermark_set)
+		count++;
+	if (set->commit_time_set)
+		count++;
+	if (set->bitmap_flush_interval_set)
+		count++;
+	if (set->sectors_per_bit_set)
+		count++;
+
+	EMIT_PARAMS(pos, "%s 0 %u %s %d fix_padding block_size:%u internal_hash:%s",
+		    origin_dev,
+		    set->tag_size,
+		    set->mode,
+		    count,
+		    set->block_size,
+		    set->internal_hash);
+
+	if (seg->integrity_meta_node)
+		EMIT_PARAMS(pos, " meta_device:%s", meta_dev);
+
+	if (seg->integrity_recalculate)
+		EMIT_PARAMS(pos, " recalculate");
+
+	if (set->journal_sectors_set)
+		EMIT_PARAMS(pos, " journal_sectors:%u", set->journal_sectors);
+
+	if (set->interleave_sectors_set)
+		EMIT_PARAMS(pos, " ineterleave_sectors:%u", set->interleave_sectors);
+
+	if (set->buffer_sectors_set)
+		EMIT_PARAMS(pos, " buffer_sectors:%u", set->buffer_sectors);
+
+	if (set->journal_watermark_set)
+		EMIT_PARAMS(pos, " journal_watermark:%u", set->journal_watermark);
+
+	if (set->commit_time_set)
+		EMIT_PARAMS(pos, " commit_time:%u", set->commit_time);
+
+	if (set->bitmap_flush_interval_set)
+		EMIT_PARAMS(pos, " bitmap_flush_interval:%u", set->bitmap_flush_interval);
+
+	if (set->sectors_per_bit_set)
+		EMIT_PARAMS(pos, " sectors_per_bit:%llu", (unsigned long long)set->sectors_per_bit);
+
+	return 1;
+}
+
 static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 					struct load_segment *seg,
 					char *params, size_t paramsize)
@@ -2889,6 +2984,10 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		if (!_writecache_emit_segment_line(dmt, seg, params, paramsize))
 			return_0;
 		break;
+	case SEG_INTEGRITY:
+		if (!_integrity_emit_segment_line(dmt, seg, params, paramsize))
+			return_0;
+		break;
 	}
 
 	switch(seg->type) {
@@ -2901,6 +3000,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_THIN:
 	case SEG_CACHE:
 	case SEG_WRITECACHE:
+	case SEG_INTEGRITY:
 		break;
 	case SEG_CRYPT:
 	case SEG_LINEAR:
@@ -3005,6 +3105,9 @@ static int _load_node(struct dm_tree_node *dnode)
 	if (!dm_task_suppress_identical_reload(dmt))
 		log_warn("WARNING: Failed to suppress reload of identical tables.");
 
+	if (dnode->props.skip_reload_params_compare)
+		dm_task_skip_reload_params_compare(dmt);
+
 	if ((r = dm_task_run(dmt))) {
 		r = dm_task_get_info(dmt, &dnode->info);
 		if (r && !dnode->info.inactive_table)
@@ -3023,8 +3126,8 @@ static int _load_node(struct dm_tree_node *dnode)
 			if (!existing_table_size && dnode->props.delay_resume_if_new)
 				dnode->props.size_changed = 0;
 
-			log_debug_activation("Table size changed from %" PRIu64 " to %"
-					     PRIu64 " for %s.%s", existing_table_size,
+			log_debug_activation("Table size changed from %" PRIu64 " to %" PRIu64 " for %s.%s",
+					     existing_table_size,
 					     seg_start, _node_name(dnode),
 					     dnode->props.size_changed ? "" : " (Ignoring.)");
 
@@ -3136,7 +3239,10 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		}
 
 		/* No resume for a device without parents or with unchanged or smaller size */
-		if (!dm_tree_node_num_children(child, 1) || (child->props.size_changed <= 0))
+		if (!dm_tree_node_num_children(child, 1))
+			continue;
+
+		if (child->props.size_changed <= 0)
 			continue;
 
 		if (!child->info.inactive_table && !child->info.suspended)
@@ -3738,6 +3844,48 @@ int dm_tree_node_add_writecache_target(struct dm_tree_node *node,
 	return 1;
 }
 
+int dm_tree_node_add_integrity_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  const char *origin_uuid,
+				  const char *meta_uuid,
+				  struct integrity_settings *settings,
+				  int recalculate)
+{
+	struct load_segment *seg;
+
+	if (!(seg = _add_segment(node, SEG_INTEGRITY, size)))
+		return_0;
+
+	if (!meta_uuid) {
+		log_error("No integrity meta uuid.");
+		return 0;
+	}
+
+	if (!(seg->integrity_meta_node = dm_tree_find_node_by_uuid(node->dtree, meta_uuid))) {
+		log_error("Missing integrity's meta uuid %s.", meta_uuid);
+		return 0;
+	}
+
+	if (!_link_tree_nodes(node, seg->integrity_meta_node))
+		return_0;
+
+	if (!(seg->origin = dm_tree_find_node_by_uuid(node->dtree, origin_uuid))) {
+		log_error("Missing integrity's origin uuid %s.", origin_uuid);
+		return 0;
+	}
+
+	if (!_link_tree_nodes(node, seg->origin))
+		return_0;
+
+	memcpy(&seg->integrity_settings, settings, sizeof(struct integrity_settings));
+
+	seg->integrity_recalculate = recalculate;
+
+	node->props.skip_reload_params_compare = 1;
+
+	return 1;
+}
+
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       const char *rlog_uuid,
diff --git a/device_mapper/libdm-targets.c b/device_mapper/libdm-targets.c
index 86cb84713..bfe76c5ff 100644
--- a/device_mapper/libdm-targets.c
+++ b/device_mapper/libdm-targets.c
@@ -380,6 +380,33 @@ int dm_get_status_writecache(struct dm_pool *mem, const char *params,
 	return 1;
 }
 
+int dm_get_status_integrity(struct dm_pool *mem, const char *params,
+			     struct dm_status_integrity **status)
+{
+	struct dm_status_integrity *s;
+	char recalc_str[16] = "\0";
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(*s))))
+		return_0;
+
+	if (sscanf(params, "%llu %llu %s",
+		   (unsigned long long *)&s->number_of_mismatches,
+		   (unsigned long long *)&s->provided_data_sectors,
+		   recalc_str) != 3) {
+		log_error("Failed to parse integrity params: %s.", params);
+		dm_pool_free(mem, s);
+		return 0;
+	}
+
+	if (recalc_str[0] == '-')
+		s->recalc_sector = 0;
+	else
+		s->recalc_sector = strtoull(recalc_str, NULL, 0);
+
+	*status = s;
+	return 1;
+}
+
 int parse_thin_pool_status(const char *params, struct dm_status_thin_pool *s)
 {
 	int pos;
diff --git a/include/configure.h.in b/include/configure.h.in
index 91a3a7ddb..57736cc3b 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -678,6 +678,9 @@
 /* Define to 1 to include built-in support for writecache. */
 #undef WRITECACHE_INTERNAL
 
+/* Define to 1 to include built-in support for integrity. */
+#undef INTEGRITY_INTERNAL
+
 /* Define to get access to GNU/Linux extension */
 #undef _GNU_SOURCE
 
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 2a064f381..8e50ec45c 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -20,6 +20,7 @@ SOURCES =\
 	activate/activate.c \
 	cache/lvmcache.c \
 	writecache/writecache.c \
+	integrity/integrity.c \
 	cache_segtype/cache.c \
 	commands/toolcontext.c \
 	config/config.c \
@@ -67,6 +68,7 @@ SOURCES =\
 	log/log.c \
 	metadata/cache_manip.c \
 	metadata/writecache_manip.c \
+	metadata/integrity_manip.c \
 	metadata/lv.c \
 	metadata/lv_manip.c \
 	metadata/merge.c \
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a82a5cbc4..22c4e6318 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2535,6 +2535,13 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
+	if ((cmd->partial_activation || cmd->degraded_activation) &&
+	    lv_is_partial(lv) && lv_is_raid(lv) && lv_raid_has_integrity((struct logical_volume *)lv)) {
+		cmd->partial_activation = 0;
+		cmd->degraded_activation = 0;
+		log_print("No degraded or partial activation for raid with integrity.");
+	}
+
 	if ((!lv->vg->cmd->partial_activation) && lv_is_partial(lv)) {
 		if (!lv_is_raid_type(lv) || !partial_raid_lv_supports_degraded_activation(lv)) {
 			log_error("Refusing activation of partial LV %s.  "
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index a5ee438ad..e3c1bb35e 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -39,6 +39,7 @@ typedef enum {
 	SEG_STATUS_THIN_POOL,
 	SEG_STATUS_VDO_POOL,
 	SEG_STATUS_WRITECACHE,
+	SEG_STATUS_INTEGRITY,
 	SEG_STATUS_UNKNOWN
 } lv_seg_status_type_t;
 
@@ -53,6 +54,7 @@ struct lv_seg_status {
 		struct dm_status_thin *thin;
 		struct dm_status_thin_pool *thin_pool;
 		struct dm_status_writecache *writecache;
+		struct dm_status_integrity *integrity;
 		struct lv_status_vdo vdo_pool;
 	};
 };
@@ -260,6 +262,7 @@ void fs_unlock(void);
 
 #define TARGET_NAME_CACHE "cache"
 #define TARGET_NAME_WRITECACHE "writecache"
+#define TARGET_NAME_INTEGRITY "integrity"
 #define TARGET_NAME_ERROR "error"
 #define TARGET_NAME_ERROR_OLD "erro"	/* Truncated in older kernels */
 #define TARGET_NAME_LINEAR "linear"
@@ -277,6 +280,7 @@ void fs_unlock(void);
 #define MODULE_NAME_CLUSTERED_MIRROR "clog"
 #define MODULE_NAME_CACHE TARGET_NAME_CACHE
 #define MODULE_NAME_WRITECACHE TARGET_NAME_WRITECACHE
+#define MODULE_NAME_INTEGRITY TARGET_NAME_INTEGRITY
 #define MODULE_NAME_ERROR TARGET_NAME_ERROR
 #define MODULE_NAME_LOG_CLUSTERED "log-clustered"
 #define MODULE_NAME_LOG_USERSPACE "log-userspace"
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 75d4df0e6..a626b000a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -46,7 +46,7 @@ typedef enum {
 } action_t;
 
 /* This list must match lib/misc/lvm-string.c:build_dm_uuid(). */
-const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "cvol", "tdata", "tmeta", "vdata", "vpool", NULL};
+const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "cvol", "tdata", "tmeta", "vdata", "vpool", "imeta", NULL};
 
 struct dlid_list {
 	struct dm_list list;
@@ -222,6 +222,10 @@ static int _get_segment_status_from_target_params(const char *target_name,
 		if (!dm_get_status_writecache(seg_status->mem, params, &(seg_status->writecache)))
 			return_0;
 		seg_status->type = SEG_STATUS_WRITECACHE;
+	} else if (segtype_is_integrity(segtype)) {
+		if (!dm_get_status_integrity(seg_status->mem, params, &(seg_status->integrity)))
+			return_0;
+		seg_status->type = SEG_STATUS_INTEGRITY;
 	} else
 		/*
 		 * TODO: Add support for other segment types too!
@@ -299,6 +303,9 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 		if (lv_is_vdo_pool(seg_status->seg->lv))
 			length = get_vdo_pool_virtual_size(seg_status->seg);
 
+		if (lv_is_integrity(seg_status->seg->lv))
+			length = seg_status->seg->integrity_data_sectors;
+
 		do {
 			target = dm_get_next_target(dmt, target, &target_start,
 						    &target_length, &target_name, &target_params);
@@ -2620,6 +2627,10 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			if (!_add_lv_to_dtree(dm, dtree, seg->writecache, dm->activation ? origin_only : 1))
 				return_0;
 		}
+		if (seg->integrity_meta_dev && seg_is_integrity(seg)) {
+			if (!_add_lv_to_dtree(dm, dtree, seg->integrity_meta_dev, dm->activation ? origin_only : 1))
+				return_0;
+		}
 		if (seg->pool_lv &&
 		    (lv_is_cache_pool(seg->pool_lv) || lv_is_cache_vol(seg->pool_lv) || dm->track_external_lv_deps) &&
 		    /* When activating and not origin_only detect linear 'overlay' over pool */
@@ -3076,6 +3087,11 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 				  lv_layer(seg->writecache)))
 		return_0;
 
+	if (seg->integrity_meta_dev && !laopts->origin_only &&
+	    !_add_new_lv_to_dtree(dm, dtree, seg->integrity_meta_dev, laopts,
+				  lv_layer(seg->integrity_meta_dev)))
+		return_0;
+
 	/* Add any LVs used by this segment */
 	for (s = 0; s < seg->area_count; ++s) {
 		if ((seg_type(seg, s) == AREA_LV) &&
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 479d4991c..88d5b3eb0 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1362,6 +1362,11 @@ static int _init_segtypes(struct cmd_context *cmd)
 		return 0;
 #endif
 
+#ifdef INTEGRITY_INTERNAL
+	if (!init_integrity_segtypes(cmd, &seglib))
+		return 0;
+#endif
+
 	return 1;
 }
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index d225d4d90..deb5d6a0f 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -646,6 +646,45 @@ out:
 	return ret;
 }
 
+#ifdef BLKID_WIPING_SUPPORT
+int get_fs_block_size(struct device *dev, uint32_t *fs_block_size)
+{
+	blkid_probe probe = NULL;
+	const char *block_size_str = NULL;
+	uint64_t block_size_val;
+	int r = 0;
+
+	*fs_block_size = 0;
+
+	if (!(probe = blkid_new_probe_from_filename(dev_name(dev)))) {
+		log_error("Failed to create a new blkid probe for device %s.", dev_name(dev));
+		goto out;
+	}
+
+	blkid_probe_enable_partitions(probe, 1);
+
+	(void) blkid_probe_lookup_value(probe, "BLOCK_SIZE", &block_size_str, NULL);
+
+	if (!block_size_str)
+		goto out;
+
+	block_size_val = strtoull(block_size_str, NULL, 10);
+
+	*fs_block_size = (uint32_t)block_size_val;
+	r = 1;
+out:
+	if (probe)
+		blkid_free_probe(probe);
+	return r;
+}
+#else
+int get_fs_block_size(struct device *dev, uint32_t *fs_block_size)
+{
+	*fs_block_size = 0;
+	return 0;
+}
+#endif
+
 #ifdef BLKID_WIPING_SUPPORT
 
 static inline int _type_in_flag_list(const char *type, uint32_t flag_list)
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index e090050a1..fdf7791cf 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -97,4 +97,6 @@ int dev_is_pmem(struct device *dev);
 
 int dev_is_lv(struct device *dev);
 
+int get_fs_block_size(struct device *dev, uint32_t *fs_block_size);
+
 #endif
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 2873ba632..bc93a5dcf 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -104,6 +104,8 @@ static const struct flag _lv_flags[] = {
 	{LV_VDO_POOL, NULL, 0},
 	{LV_VDO_POOL_DATA, NULL, 0},
 	{WRITECACHE, NULL, 0},
+	{INTEGRITY, NULL, 0},
+	{INTEGRITY_METADATA, NULL, 0},
 	{LV_PENDING_DELETE, NULL, 0}, /* FIXME Display like COMPATIBLE_FLAG */
 	{LV_REMOVED, NULL, 0},
 	{0, NULL, 0}
diff --git a/lib/integrity/integrity.c b/lib/integrity/integrity.c
new file mode 100644
index 000000000..d5ad86b63
--- /dev/null
+++ b/lib/integrity/integrity.c
@@ -0,0 +1,343 @@
+/*
+ * Copyright (C) 2013-2016 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "base/memory/zalloc.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/format_text/text_export.h"
+#include "lib/config/config.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/activate/activate.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/config/defaults.h"
+
+#define SEG_LOG_ERROR(t, p...) \
+        log_error(t " segment %s of logical volume %s.", ## p,	\
+                  dm_config_parent_name(sn), seg->lv->name), 0;
+
+static void _integrity_display(const struct lv_segment *seg)
+{
+	/* TODO: lvdisplay segments */
+}
+
+static int _integrity_text_import(struct lv_segment *seg,
+				   const struct dm_config_node *sn,
+				   struct dm_hash_table *pv_hash __attribute__((unused)))
+{
+	struct integrity_settings *set;
+	struct logical_volume *origin_lv = NULL;
+	struct logical_volume *meta_lv = NULL;
+	const char *origin_name = NULL;
+	const char *meta_dev = NULL;
+	const char *mode = NULL;
+	const char *hash = NULL;
+
+	memset(&seg->integrity_settings, 0, sizeof(struct integrity_settings));
+	set = &seg->integrity_settings;
+
+	/* origin always set */
+
+	if (!dm_config_has_node(sn, "origin"))
+		return SEG_LOG_ERROR("origin not specified in");
+
+	if (!dm_config_get_str(sn, "origin", &origin_name))
+		return SEG_LOG_ERROR("origin must be a string in");
+
+	if (!(origin_lv = find_lv(seg->lv->vg, origin_name)))
+		return SEG_LOG_ERROR("Unknown LV specified for integrity origin %s in", origin_name);
+
+	if (!set_lv_segment_area_lv(seg, 0, origin_lv, 0, 0))
+		return_0;
+
+	/* data_sectors always set */
+
+	if (!dm_config_get_uint64(sn, "data_sectors", &seg->integrity_data_sectors))
+		return SEG_LOG_ERROR("integrity data_sectors must be set in");
+
+	/* mode always set */
+
+	if (!dm_config_get_str(sn, "mode", &mode))
+		return SEG_LOG_ERROR("integrity mode must be set in");
+
+	if (strlen(mode) > 7)
+		return SEG_LOG_ERROR("integrity mode invalid in");
+
+	strncpy(set->mode, mode, 7);
+
+	/* tag_size always set */
+
+	if (!dm_config_get_uint32(sn, "tag_size", &set->tag_size))
+		return SEG_LOG_ERROR("integrity tag_size must be set in");
+
+	/* block_size always set */
+
+	if (!dm_config_get_uint32(sn, "block_size", &set->block_size))
+		return SEG_LOG_ERROR("integrity block_size invalid in");
+
+	/* internal_hash always set */
+
+	if (!dm_config_get_str(sn, "internal_hash", &hash))
+		return SEG_LOG_ERROR("integrity internal_hash must be set in");
+
+	if (!(set->internal_hash = dm_pool_strdup(seg->lv->vg->vgmem, hash)))
+		return SEG_LOG_ERROR("integrity internal_hash failed to be set in");
+
+	/* meta_dev optional */
+
+	if (dm_config_has_node(sn, "meta_dev")) {
+		if (!dm_config_get_str(sn, "meta_dev", &meta_dev))
+			return SEG_LOG_ERROR("meta_dev must be a string in");
+
+		if (!(meta_lv = find_lv(seg->lv->vg, meta_dev)))
+			return SEG_LOG_ERROR("Unknown logical volume %s specified for integrity in", meta_dev);
+	}
+
+	if (dm_config_has_node(sn, "recalculate")) {
+		if (!dm_config_get_uint32(sn, "recalculate", &seg->integrity_recalculate))
+			return SEG_LOG_ERROR("integrity recalculate error in");
+	}
+
+	/* the rest are optional */
+
+	if (dm_config_has_node(sn, "journal_sectors")) {
+		if (!dm_config_get_uint32(sn, "journal_sectors", &set->journal_sectors))
+			return SEG_LOG_ERROR("Unknown integrity_setting in");
+		set->journal_sectors_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "interleave_sectors")) {
+		if (!dm_config_get_uint32(sn, "interleave_sectors", &set->interleave_sectors))
+			return SEG_LOG_ERROR("Unknown integrity_setting in");
+		set->interleave_sectors_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "buffer_sectors")) {
+		if (!dm_config_get_uint32(sn, "buffer_sectors", &set->buffer_sectors))
+			return SEG_LOG_ERROR("Unknown integrity_setting in");
+		set->buffer_sectors_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "journal_watermark")) {
+		if (!dm_config_get_uint32(sn, "journal_watermark", &set->journal_watermark))
+			return SEG_LOG_ERROR("Unknown integrity_setting in");
+		set->journal_watermark_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "commit_time")) {
+		if (!dm_config_get_uint32(sn, "commit_time", &set->commit_time))
+			return SEG_LOG_ERROR("Unknown integrity_setting in");
+		set->commit_time_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "bitmap_flush_interval")) {
+		if (!dm_config_get_uint32(sn, "bitmap_flush_interval", &set->bitmap_flush_interval))
+			return SEG_LOG_ERROR("Unknown integrity_setting in");
+		set->bitmap_flush_interval_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "sectors_per_bit")) {
+		if (!dm_config_get_uint64(sn, "sectors_per_bit", &set->sectors_per_bit))
+			return SEG_LOG_ERROR("Unknown integrity_setting in");
+		set->sectors_per_bit_set = 1;
+	}
+
+	seg->origin = origin_lv;
+	seg->integrity_meta_dev = meta_lv;
+	seg->lv->status |= INTEGRITY;
+
+	if (meta_lv)
+		meta_lv->status |= INTEGRITY_METADATA;
+
+	if (meta_lv && !add_seg_to_segs_using_this_lv(meta_lv, seg))
+		return_0;
+
+	return 1;
+}
+
+static int _integrity_text_import_area_count(const struct dm_config_node *sn,
+					      uint32_t *area_count)
+{
+	*area_count = 1;
+
+	return 1;
+}
+
+static int _integrity_text_export(const struct lv_segment *seg,
+				   struct formatter *f)
+{
+	const struct integrity_settings *set = &seg->integrity_settings;
+
+	outf(f, "origin = \"%s\"", seg_lv(seg, 0)->name);
+	outf(f, "data_sectors = %llu", (unsigned long long)seg->integrity_data_sectors);
+
+	outf(f, "mode = \"%s\"", set->mode);
+	outf(f, "tag_size = %u", set->tag_size);
+	outf(f, "block_size = %u", set->block_size);
+	outf(f, "internal_hash = \"%s\"", set->internal_hash);
+
+	if (seg->integrity_meta_dev)
+		outf(f, "meta_dev = \"%s\"", seg->integrity_meta_dev->name);
+
+	if (seg->integrity_recalculate)
+		outf(f, "recalculate = %u", seg->integrity_recalculate);
+
+	if (set->journal_sectors_set)
+		outf(f, "journal_sectors = %u", set->journal_sectors);
+
+	if (set->interleave_sectors_set)
+		outf(f, "interleave_sectors = %u", set->interleave_sectors);
+
+	if (set->buffer_sectors_set)
+		outf(f, "buffer_sectors = %u", set->buffer_sectors);
+
+	if (set->journal_watermark_set)
+		outf(f, "journal_watermark = %u", set->journal_watermark);
+
+	if (set->commit_time_set)
+		outf(f, "commit_time = %u", set->commit_time);
+
+	if (set->bitmap_flush_interval)
+		outf(f, "bitmap_flush_interval = %u", set->bitmap_flush_interval);
+
+	if (set->sectors_per_bit)
+		outf(f, "sectors_per_bit = %llu", (unsigned long long)set->sectors_per_bit);
+
+	return 1;
+}
+
+static void _destroy(struct segment_type *segtype)
+{
+	free((void *) segtype);
+}
+
+#ifdef DEVMAPPER_SUPPORT
+
+static int _target_present(struct cmd_context *cmd,
+			   const struct lv_segment *seg __attribute__((unused)),
+			   unsigned *attributes __attribute__((unused)))
+{
+	static int _integrity_checked = 0;
+	static int _integrity_present = 0;
+	uint32_t maj, min, patchlevel;
+
+	if (!activation())
+		return 0;
+
+	if (!_integrity_checked) {
+		_integrity_checked = 1;
+		_integrity_present =  target_present(cmd, TARGET_NAME_INTEGRITY, 1);
+
+		if (!target_version(TARGET_NAME_INTEGRITY, &maj, &min, &patchlevel))
+			return 0;
+
+		if (maj < 1 || min < 6) {
+			log_error("Integrity target version older than minimum 1.6.0");
+			return 0;
+		}
+	}
+
+	return _integrity_present;
+}
+
+static int _modules_needed(struct dm_pool *mem,
+			   const struct lv_segment *seg __attribute__((unused)),
+			   struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, MODULE_NAME_INTEGRITY)) {
+		log_error("String list allocation failed for integrity module.");
+		return 0;
+	}
+
+	return 1;
+}
+#endif /* DEVMAPPER_SUPPORT */
+
+#ifdef DEVMAPPER_SUPPORT
+static int _integrity_add_target_line(struct dev_manager *dm,
+				 struct dm_pool *mem,
+				 struct cmd_context *cmd __attribute__((unused)),
+				 void **target_state __attribute__((unused)),
+				 struct lv_segment *seg,
+				 const struct lv_activate_opts *laopts,
+				 struct dm_tree_node *node, uint64_t len,
+				 uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	char *origin_uuid;
+	char *meta_uuid = NULL;
+
+	if (!seg_is_integrity(seg)) {
+		log_error(INTERNAL_ERROR "Passed segment is not integrity.");
+		return 0;
+	}
+
+	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), NULL)))
+		return_0;
+
+	if (seg->integrity_meta_dev) {
+		if (!(meta_uuid = build_dm_uuid(mem, seg->integrity_meta_dev, NULL)))
+			return_0;
+	}
+
+	if (!seg->integrity_data_sectors) {
+		log_error("_integrity_add_target_line zero size");
+		return_0;
+	}
+
+	if (!dm_tree_node_add_integrity_target(node, seg->integrity_data_sectors,
+					       origin_uuid, meta_uuid,
+					       &seg->integrity_settings,
+					       seg->integrity_recalculate))
+		return_0;
+
+	return 1;
+}
+#endif /* DEVMAPPER_SUPPORT */
+
+static struct segtype_handler _integrity_ops = {
+	.display = _integrity_display,
+	.text_import = _integrity_text_import,
+	.text_import_area_count = _integrity_text_import_area_count,
+	.text_export = _integrity_text_export,
+#ifdef DEVMAPPER_SUPPORT
+	.add_target_line = _integrity_add_target_line,
+	.target_present = _target_present,
+	.modules_needed = _modules_needed,
+#endif
+	.destroy = _destroy,
+};
+
+int init_integrity_segtypes(struct cmd_context *cmd,
+			struct segtype_library *seglib)
+{
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
+
+	if (!segtype) {
+		log_error("Failed to allocate memory for integrity segtype");
+		return 0;
+	}
+
+	segtype->name = SEG_TYPE_NAME_INTEGRITY;
+	segtype->flags = SEG_INTEGRITY;
+	segtype->ops = &_integrity_ops;
+
+	if (!lvm_register_segtype(seglib, segtype))
+		return_0;
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return 1;
+}
diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
new file mode 100644
index 000000000..7942be0d6
--- /dev/null
+++ b/lib/metadata/integrity_manip.c
@@ -0,0 +1,821 @@
+/*
+ * Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/locking/locking.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/display/display.h"
+#include "lib/metadata/segtype.h"
+#include "lib/activate/activate.h"
+#include "lib/config/defaults.h"
+#include "lib/activate/dev_manager.h"
+
+#define DEFAULT_TAG_SIZE 4 /* bytes */
+#define DEFAULT_MODE 'J'
+#define DEFAULT_INTERNAL_HASH "crc32c"
+#define DEFAULT_BLOCK_SIZE 512
+
+#define ONE_MB_IN_BYTES 1048576
+
+int lv_is_integrity_origin(const struct logical_volume *lv)
+{
+	struct seg_list *sl;
+
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		if (!sl->seg || !sl->seg->lv || !sl->seg->origin)
+			continue;
+		if (lv_is_integrity(sl->seg->lv) && (sl->seg->origin == lv))
+			return 1;
+	}
+	return 0;
+}
+
+/*
+ * Every 500M of data needs 4M of metadata.
+ * (From trial and error testing.)
+ */
+static uint64_t _lv_size_bytes_to_integrity_meta_bytes(uint64_t lv_size_bytes)
+{
+	return ((lv_size_bytes / (500 * ONE_MB_IN_BYTES)) + 1) * (4 * ONE_MB_IN_BYTES);
+}
+
+/*
+ * The user wants external metadata, but did not specify an existing
+ * LV to hold metadata, so create an LV for metadata.
+ */
+static int _lv_create_integrity_metadata(struct cmd_context *cmd,
+				struct volume_group *vg,
+				struct lvcreate_params *lp,
+				struct logical_volume **meta_lv)
+{
+	char metaname[NAME_LEN];
+	uint64_t lv_size_bytes, meta_bytes, meta_sectors;
+	struct logical_volume *lv;
+	struct lvcreate_params lp_meta = {
+		.activate = CHANGE_AN,
+		.alloc = ALLOC_INHERIT,
+		.major = -1,
+		.minor = -1,
+		.permission = LVM_READ | LVM_WRITE,
+		.pvh = &vg->pvs,
+		.read_ahead = DM_READ_AHEAD_NONE,
+		.stripes = 1,
+		.vg_name = vg->name,
+		.zero = 0,
+		.wipe_signatures = 0,
+		.suppress_zero_warn = 1,
+	};
+
+	if (lp->lv_name &&
+	    dm_snprintf(metaname, NAME_LEN, "%s_imeta", lp->lv_name) < 0) {
+		log_error("Failed to create metadata LV name.");
+		return 0;
+	}
+
+	lp_meta.lv_name = metaname;
+	lp_meta.pvh = lp->pvh;
+
+	lv_size_bytes = (uint64_t)lp->extents * (uint64_t)vg->extent_size * 512;
+	meta_bytes = _lv_size_bytes_to_integrity_meta_bytes(lv_size_bytes);
+	meta_sectors = meta_bytes / 512;
+	lp_meta.extents = meta_sectors / vg->extent_size;
+
+	log_print_unless_silent("Creating integrity metadata LV %s with size %s.",
+		  metaname, display_size(cmd, meta_sectors));
+
+	dm_list_init(&lp_meta.tags);
+
+	if (!(lp_meta.segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	if (!(lv = lv_create_single(vg, &lp_meta))) {
+		log_error("Failed to create integrity metadata LV");
+		return 0;
+	}
+
+	if (dm_list_size(&lv->segments) > 1) {
+		log_error("Integrity metadata uses more than one segment.");
+		return 0;
+	}
+
+	*meta_lv = lv;
+	return 1;
+}
+
+int lv_extend_integrity_in_raid(struct logical_volume *lv, struct dm_list *pvh)
+{
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct volume_group *vg = lv->vg;
+	const struct segment_type *segtype;
+	struct lv_segment *seg_top, *seg_image;
+	struct logical_volume *lv_image;
+	struct logical_volume *lv_iorig;
+	struct logical_volume *lv_imeta;
+	struct dm_list allocatable_pvs;
+	struct dm_list *use_pvh;
+	uint64_t lv_size_bytes, meta_bytes, meta_sectors, prev_meta_sectors;
+	uint32_t meta_extents, prev_meta_extents;
+	uint32_t area_count, s;
+
+	seg_top = first_seg(lv);
+		                
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	area_count = seg_top->area_count;
+
+	for (s = 0; s < area_count; s++) {
+		lv_image = seg_lv(seg_top, s);
+		seg_image = first_seg(lv_image);
+
+		if (!(lv_imeta = seg_image->integrity_meta_dev)) {
+			log_error("LV %s segment has no integrity metadata device.", display_lvname(lv));
+			return 0;
+		}
+
+		if (!(lv_iorig = seg_lv(seg_image, 0))) {
+			log_error("LV %s integrity segment has no origin", display_lvname(lv));
+			return 0;
+		}
+
+		lv_size_bytes = lv_iorig->size * 512;
+		meta_bytes = _lv_size_bytes_to_integrity_meta_bytes(lv_size_bytes);
+		meta_sectors = meta_bytes / 512;
+		meta_extents = meta_sectors / vg->extent_size;
+
+		prev_meta_sectors = lv_imeta->size;
+		prev_meta_extents = prev_meta_sectors / vg->extent_size;
+
+		if (meta_extents <= prev_meta_extents) {
+			log_debug("extend not needed for imeta LV %s", lv_imeta->name);
+			continue;
+		}
+
+		/*
+		 * We only allow lv_imeta to exist on a single PV (for now),
+		 * so the allocatable_pvs is the one PV currently used by
+		 * lv_imeta.
+		 */
+		dm_list_init(&allocatable_pvs);
+
+		if (!get_pv_list_for_lv(cmd->mem, lv_imeta, &allocatable_pvs)) {
+			log_error("Failed to build list of PVs for extending %s.", display_lvname(lv_imeta));
+			return 0;
+		}
+
+		use_pvh = &allocatable_pvs;
+
+		if (!lv_extend(lv_imeta, segtype, 1, 0, 0, 0,
+			       meta_extents - prev_meta_extents,
+			       use_pvh, lv_imeta->alloc, 0)) {
+			log_error("Failed to extend integrity metadata LV %s", lv_imeta->name);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+int lv_remove_integrity_from_raid(struct logical_volume *lv)
+{
+	struct logical_volume *iorig_lvs[DEFAULT_RAID_MAX_IMAGES];
+	struct logical_volume *imeta_lvs[DEFAULT_RAID_MAX_IMAGES];
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct volume_group *vg = lv->vg;
+	struct lv_segment *seg_top, *seg_image;
+	struct logical_volume *lv_image;
+	struct logical_volume *lv_iorig;
+	struct logical_volume *lv_imeta;
+	uint32_t area_count, s;
+	int is_active = lv_is_active(lv);
+
+	seg_top = first_seg(lv);
+
+	if (!seg_is_raid1(seg_top) && !seg_is_raid4(seg_top) &&
+	    !seg_is_any_raid5(seg_top) && !seg_is_any_raid6(seg_top) &&
+	    !seg_is_any_raid10(seg_top)) {
+		log_error("LV %s segment is unsupported raid for integrity.", display_lvname(lv));
+		return 0;
+	}
+
+	area_count = seg_top->area_count;
+
+	for (s = 0; s < area_count; s++) {
+		lv_image = seg_lv(seg_top, s);
+		seg_image = first_seg(lv_image);
+
+		if (!(lv_imeta = seg_image->integrity_meta_dev)) {
+			log_error("LV %s segment has no integrity metadata device.", display_lvname(lv));
+			return 0;
+		}
+
+		if (!(lv_iorig = seg_lv(seg_image, 0))) {
+			log_error("LV %s integrity segment has no origin", display_lvname(lv));
+			return 0;
+		}
+
+		if (!remove_seg_from_segs_using_this_lv(seg_image->integrity_meta_dev, seg_image))
+			return_0;
+
+		iorig_lvs[s] = lv_iorig;
+		imeta_lvs[s] = lv_imeta;
+
+		lv_image->status &= ~INTEGRITY;
+		seg_image->integrity_meta_dev = NULL;
+		seg_image->integrity_data_sectors = 0;
+		memset(&seg_image->integrity_settings, 0, sizeof(seg_image->integrity_settings));
+
+		if (!remove_layer_from_lv(lv_image, lv_iorig))
+			return_0;
+	}
+
+	if (is_active) {
+		/* vg_write(), suspend_lv(), vg_commit(), resume_lv() */
+		if (!lv_update_and_reload(lv)) {
+			log_error("Failed to update and reload LV after integrity remove.");
+			return 0;
+                }
+	}
+
+	for (s = 0; s < area_count; s++) {
+		lv_iorig = iorig_lvs[s];
+		lv_imeta = imeta_lvs[s];
+
+		if (is_active) {
+			if (!deactivate_lv(cmd, lv_iorig))
+				log_error("Failed to deactivate unused iorig LV %s.", lv_iorig->name);
+
+			if (!deactivate_lv(cmd, lv_imeta))
+				log_error("Failed to deactivate unused imeta LV %s.", lv_imeta->name);
+		}
+
+		lv_imeta->status &= ~INTEGRITY_METADATA;
+		lv_set_visible(lv_imeta);
+
+		if (!lv_remove(lv_iorig))
+			log_error("Failed to remove unused iorig LV %s.", lv_iorig->name);
+
+		if (!lv_remove(lv_imeta))
+			log_error("Failed to remove unused imeta LV %s.", lv_imeta->name);
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	return 1;
+}
+
+static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_volume *lv,
+				     struct integrity_settings *settings,
+				     int lbs_4k, int lbs_512, int pbs_4k, int pbs_512)
+{
+	char pathname[PATH_MAX];
+	struct device *fs_dev;
+	uint32_t fs_block_size = 0;
+	int rv;
+
+	if (lbs_4k && lbs_512) {
+		log_error("Integrity requires consistent logical block size for LV devices.");
+		goto_bad;
+	}
+
+	if (settings->block_size &&
+	    (settings->block_size != 512 && settings->block_size != 1024 &&
+	     settings->block_size != 2048 && settings->block_size != 4096)) {
+		log_error("Invalid integrity block size, possible values are 512, 1024, 2048, 4096");
+		goto_bad;
+	}
+
+	if (lbs_4k && settings->block_size && (settings->block_size < 4096)) {
+		log_error("Integrity block size %u not allowed with device logical block size 4096.",
+			  settings->block_size);
+		goto_bad;
+	}
+
+	if (!strcmp(cmd->name, "lvcreate")) {
+		if (lbs_4k) {
+			settings->block_size = 4096;
+		} else if (lbs_512 && pbs_4k && !pbs_512) {
+			settings->block_size = 4096;
+		} else if (lbs_512) {
+			if (!settings->block_size)
+				settings->block_size = 512;
+		} else if (!lbs_4k && !lbs_512) {
+			if (!settings->block_size)
+				settings->block_size = 512;
+			log_print("Using integrity block size %u with unknown device logical block size.",
+				  settings->block_size);
+		} else {
+			goto_bad;
+		}
+
+	} else if (!strcmp(cmd->name, "lvconvert")) {
+		if (dm_snprintf(pathname, sizeof(pathname), "%s%s/%s", cmd->dev_dir,
+				lv->vg->name, lv->name) < 0) {
+			log_error("Path name too long to get LV block size %s", display_lvname(lv));
+			goto_bad;
+		}
+		if (!(fs_dev = dev_cache_get(cmd, pathname, NULL))) {
+			log_error("Device for LV not found to check block size %s", display_lvname(lv));
+			goto_bad;
+		}
+
+		/*
+		 * get_fs_block_size() returns the libblkid BLOCK_SIZE value,
+		 * where libblkid has fs-specific code to set BLOCK_SIZE to the
+		 * value we need here.
+		 *
+		 * The term "block size" here may not equate directly to what the fs
+		 * calls the block size, e.g. xfs calls this the sector size (and
+		 * something different the block size); while ext4 does call this
+		 * value the block size, but it's possible values are not the same
+		 * as xfs's, and do not seem to relate directly to the device LBS.
+		 */
+		rv = get_fs_block_size(fs_dev, &fs_block_size);
+		if (!rv || !fs_block_size) {
+			int use_bs;
+
+			if (lbs_4k && pbs_4k) {
+				use_bs = 4096;
+			} else if (lbs_512 && pbs_512) {
+				use_bs = 512;
+			} else if (lbs_512 && pbs_4k) {
+				if (settings->block_size == 4096)
+					use_bs = 4096;
+				else
+					use_bs = 512;
+			} else {
+				use_bs = 512;
+			}
+
+			if (settings->block_size && (settings->block_size != use_bs)) {
+				log_error("Cannot use integrity block size %u with unknown file system block size, logical block size %u, physical block size %u.",
+					   settings->block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
+				goto bad;
+			}
+
+			settings->block_size = use_bs;
+
+			log_print("Using integrity block size %u for unknown file system block size, logical block size %u, physical block size %u.",
+				  settings->block_size, lbs_4k ? 4096 : 512, pbs_4k ? 4096 : 512);
+			goto out;
+		}
+
+		if (!settings->block_size) {
+			if (fs_block_size <= 4096)
+				settings->block_size = fs_block_size;
+			else
+				settings->block_size = 4096; /* dm-integrity max is 4096 */
+			log_print("Using integrity block size %u for file system block size %u.",
+				  settings->block_size, fs_block_size);
+		} else {
+			/* let user specify integrity block size that is less than fs block size */
+			if (settings->block_size > fs_block_size) {
+				log_error("Integrity block size %u cannot be larger than file system block size %u.",
+					  settings->block_size, fs_block_size);
+				goto_bad;
+			}
+			log_print("Using integrity block size %u for file system block size %u.",
+				  settings->block_size, fs_block_size);
+		}
+	}
+out:
+	return 1;
+bad:
+	return 0;
+}
+
+/*
+ * Add integrity to each raid image.
+ *
+ * for each rimage_N:
+ * . create and allocate a new linear LV rimage_N_imeta
+ * . move the segments from rimage_N to a new rimage_N_iorig
+ * . add an integrity segment to rimage_N with
+ *   origin=rimage_N_iorig, meta_dev=rimage_N_imeta
+ *
+ * Before:
+ * rimage_0
+ *   segment1: striped: pv0:A
+ * rimage_1
+ *   segment1: striped: pv1:B
+ *
+ * After:
+ * rimage_0
+ *   segment1: integrity: rimage_0_iorig, rimage_0_imeta
+ * rimage_1
+ *   segment1: integrity: rimage_1_iorig, rimage_1_imeta
+ * rimage_0_iorig
+ *   segment1: striped: pv0:A
+ * rimage_1_iorig
+ *   segment1: striped: pv1:B
+ * rimage_0_imeta
+ *   segment1: striped: pv2:A
+ * rimage_1_imeta
+ *   segment1: striped: pv2:B
+ *    
+ */
+
+int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_settings *settings,
+			     struct dm_list *pvh, struct logical_volume *lv_imeta_0)
+{
+	char imeta_name[NAME_LEN];
+	char *imeta_name_dup;
+	struct lvcreate_params lp;
+	struct dm_list allocatable_pvs;
+	struct logical_volume *imeta_lvs[DEFAULT_RAID_MAX_IMAGES];
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *lv_image, *lv_imeta, *lv_iorig;
+	struct lv_segment *seg_top, *seg_image;
+	struct pv_list *pvl;
+	const struct segment_type *segtype;
+	struct integrity_settings *set = NULL;
+	struct dm_list *use_pvh = NULL;
+	uint32_t area_count, s;
+	uint32_t revert_meta_lvs = 0;
+	int lbs_4k = 0, lbs_512 = 0, lbs_unknown = 0;
+	int pbs_4k = 0, pbs_512 = 0, pbs_unknown = 0;
+	int is_active;
+
+	memset(imeta_lvs, 0, sizeof(imeta_lvs));
+
+	is_active = lv_is_active(lv);
+
+	if (dm_list_size(&lv->segments) != 1)
+		return_0;
+
+	if (!dm_list_empty(&lv->segs_using_this_lv)) {
+		log_error("Integrity can only be added to top level raid LV.");
+		return 0;
+	}
+
+	if (lv_is_origin(lv)) {
+		log_error("Integrity cannot be added to snapshot origins.");
+		return 0;
+	}
+
+	seg_top = first_seg(lv);
+	area_count = seg_top->area_count;
+
+	if (!seg_is_raid1(seg_top) && !seg_is_raid4(seg_top) &&
+	    !seg_is_any_raid5(seg_top) && !seg_is_any_raid6(seg_top) &&
+	    !seg_is_any_raid10(seg_top)) {
+		log_error("Integrity can only be added to raid1,4,5,6,10.");
+		return 0;
+	}
+
+	/*
+	 * For each rimage, create an _imeta LV for integrity metadata.
+	 * Each needs to be zeroed.
+	 */
+	for (s = 0; s < area_count; s++) {
+		struct logical_volume *meta_lv;
+		struct wipe_params wipe = { .do_zero = 1, .zero_sectors = 8 };
+
+		if (s >= DEFAULT_RAID_MAX_IMAGES)
+			goto_bad;
+
+		lv_image = seg_lv(seg_top, s);
+
+		/*
+		 * This function is used to add integrity to new images added
+		 * to the raid, in which case old images will already be
+		 * integrity.
+		 */
+		if (seg_is_integrity(first_seg(lv_image)))
+			continue;
+
+		if (!seg_is_striped(first_seg(lv_image))) {
+			log_error("raid image must be linear to add integrity");
+			goto_bad;
+		}
+
+		/*
+		 * Use an existing lv_imeta from previous linear+integrity LV.
+		 * FIXME: is it guaranteed that lv_image_0 is the existing?
+		 */
+		if (!s && lv_imeta_0) {
+			if (dm_snprintf(imeta_name, sizeof(imeta_name), "%s_imeta", lv_image->name) > 0) {
+				if ((imeta_name_dup = dm_pool_strdup(vg->vgmem, imeta_name)))
+					lv_imeta_0->name = imeta_name_dup;
+			}
+			imeta_lvs[0] = lv_imeta_0;
+			continue;
+		}
+
+		dm_list_init(&allocatable_pvs);
+
+		if (!get_pv_list_for_lv(cmd->mem, lv_image, &allocatable_pvs)) {
+			log_error("Failed to build list of PVs for %s.", display_lvname(lv_image));
+			goto_bad;
+		}
+
+		dm_list_iterate_items(pvl, &allocatable_pvs) {
+			unsigned int pbs = 0;
+			unsigned int lbs = 0;
+
+			if (!dev_get_direct_block_sizes(pvl->pv->dev, &pbs, &lbs)) {
+				lbs_unknown++;
+				pbs_unknown++;
+				continue;
+			}
+			if (lbs == 4096)
+				lbs_4k++;
+			else if (lbs == 512)
+				lbs_512++;
+			else
+				lbs_unknown++;
+			if (pbs == 4096)
+				pbs_4k++;
+			else if (pbs == 512)
+				pbs_512++;
+			else
+				pbs_unknown++;
+		}
+
+		use_pvh = &allocatable_pvs;
+
+		/*
+		 * allocate a new linear LV NAME_rimage_N_imeta
+		 */
+		memset(&lp, 0, sizeof(lp));
+		lp.lv_name = lv_image->name;
+		lp.pvh = use_pvh;
+		lp.extents = lv_image->size / vg->extent_size;
+
+		if (!_lv_create_integrity_metadata(cmd, vg, &lp, &meta_lv))
+			goto_bad;
+
+		revert_meta_lvs++;
+
+		/* Used below to set up the new integrity segment. */
+		imeta_lvs[s] = meta_lv;
+
+		/*
+		 * dm-integrity requires the metadata LV header to be zeroed.
+		 */
+
+		if (!activate_lv(cmd, meta_lv)) {
+			log_error("Failed to activate LV %s to zero", display_lvname(meta_lv));
+			goto_bad;
+		}
+
+		if (!wipe_lv(meta_lv, wipe)) {
+			log_error("Failed to zero LV for integrity metadata %s", display_lvname(meta_lv));
+			if (deactivate_lv(cmd, meta_lv))
+				log_error("Failed to deactivate LV %s after zero", display_lvname(meta_lv));
+			goto_bad;
+		}
+
+		if (!deactivate_lv(cmd, meta_lv)) {
+			log_error("Failed to deactivate LV %s after zero", display_lvname(meta_lv));
+			goto_bad;
+		}
+	}
+
+	/*
+	 * Set settings->block_size which will be copied to segment settings below.
+	 * integrity block size chosen based on device logical block size and
+	 * file system block size.
+	 */
+	if (!_set_integrity_block_size(cmd, lv, settings, lbs_4k, lbs_512, pbs_4k, pbs_512))
+		goto_bad;
+
+	/*
+	 * For each rimage, move its segments to a new rimage_iorig and give
+	 * the rimage a new integrity segment.
+	 */
+	for (s = 0; s < area_count; s++) {
+		lv_image = seg_lv(seg_top, s);
+
+		/* Not adding integrity to this image. */
+		if (!imeta_lvs[s])
+			continue;
+
+		if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_INTEGRITY)))
+			goto_bad;
+
+		log_debug("Adding integrity to raid image %s", lv_image->name);
+
+		/*
+		 * "lv_iorig" is a new LV with new id, but with the segments
+		 * from "lv_image". "lv_image" keeps the existing name and id,
+		 * but gets a new integrity segment, in place of the segments
+		 * that were moved to lv_iorig.
+		 */
+		if (!(lv_iorig = insert_layer_for_lv(cmd, lv_image, INTEGRITY, "_iorig")))
+			goto_bad;
+
+		lv_image->status |= INTEGRITY;
+
+		/*
+		 * Set up the new first segment of lv_image as integrity.
+		 */
+		seg_image = first_seg(lv_image);
+		seg_image->segtype = segtype;
+
+		lv_imeta = imeta_lvs[s];
+		lv_imeta->status |= INTEGRITY_METADATA;
+		lv_set_hidden(lv_imeta);
+		seg_image->integrity_data_sectors = lv_image->size;
+		seg_image->integrity_meta_dev = lv_imeta;
+		seg_image->integrity_recalculate = 1;
+
+		memcpy(&seg_image->integrity_settings, settings, sizeof(struct integrity_settings));
+		set = &seg_image->integrity_settings;
+
+		if (!set->mode[0])
+			set->mode[0] = DEFAULT_MODE;
+
+		if (!set->tag_size)
+			set->tag_size = DEFAULT_TAG_SIZE;
+
+		if (!set->block_size)
+			set->block_size = DEFAULT_BLOCK_SIZE;
+
+		if (!set->internal_hash)
+			set->internal_hash = DEFAULT_INTERNAL_HASH;
+	}
+
+	if (is_active) {
+		log_debug("Writing VG and updating LV with new integrity LV %s", lv->name);
+
+		/* vg_write(), suspend_lv(), vg_commit(), resume_lv() */
+		if (!lv_update_and_reload(lv)) {
+			log_error("LV update and reload failed");
+			goto_bad;
+		}
+		revert_meta_lvs = 0;
+
+	} else {
+		log_debug("Writing VG with new integrity LV %s", lv->name);
+
+		if (!vg_write(vg) || !vg_commit(vg))
+			goto_bad;
+
+		revert_meta_lvs = 0;
+
+		/*
+		 * This first activation includes "recalculate" which starts the
+		 * kernel's recalculating (initialization) process.
+		 */
+
+		log_debug("Activating to start integrity initialization for LV %s", lv->name);
+
+		if (!activate_lv(cmd, lv)) {
+			log_error("Failed to activate integrity LV to initialize.");
+			goto_bad;
+		}
+	}
+
+	/*
+	 * Now that the device is being initialized, update the VG to clear
+	 * integrity_recalculate so that subsequent activations will not
+	 * include "recalculate" and restart initialization.
+	 */
+
+	log_debug("Writing VG with initialized integrity LV %s", lv->name);
+
+	for (s = 0; s < area_count; s++) {
+		lv_image = seg_lv(seg_top, s);
+		seg_image = first_seg(lv_image);
+		seg_image->integrity_recalculate = 0;
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		goto_bad;
+
+	return 1;
+
+bad:
+	log_error("Failed to add integrity.");
+
+	for (s = 0; s < revert_meta_lvs; s++) {
+		if (!lv_remove(imeta_lvs[s]))
+			log_error("New integrity metadata LV may require manual removal.");
+	}
+			       
+	if (!vg_write(vg) || !vg_commit(vg))
+		log_error("New integrity metadata LV may require manual removal.");
+
+	return 0;
+}
+
+/*
+ * This should rarely if ever be used.  A command that adds integrity
+ * to an LV will activate and then clear the flag.  If it fails before
+ * clearing the flag, then this function will be used by a subsequent
+ * activation to clear the flag.
+ */
+void lv_clear_integrity_recalculate_metadata(struct logical_volume *lv)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *lv_image;
+	struct lv_segment *seg, *seg_image;
+	uint32_t s;
+
+	seg = first_seg(lv);
+
+	if (seg_is_raid(seg)) {
+		for (s = 0; s < seg->area_count; s++) {
+			lv_image = seg_lv(seg, s);
+			seg_image = first_seg(lv_image);
+			seg_image->integrity_recalculate = 0;
+		}
+	} else if (seg_is_integrity(seg)) {
+		seg->integrity_recalculate = 0;
+	} else {
+		log_error("Invalid LV type for clearing integrity");
+		return;
+	}
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_warn("WARNING: failed to clear integrity recalculate flag for %s",
+			 display_lvname(lv));
+	}
+}
+
+int lv_has_integrity_recalculate_metadata(struct logical_volume *lv)
+{
+	struct logical_volume *lv_image;
+	struct lv_segment *seg, *seg_image;
+	uint32_t s;
+	int ret = 0;
+
+	seg = first_seg(lv);
+
+	if (seg_is_raid(seg)) {
+		for (s = 0; s < seg->area_count; s++) {
+			lv_image = seg_lv(seg, s);
+			seg_image = first_seg(lv_image);
+
+			if (!seg_is_integrity(seg_image))
+				continue;
+			if (seg_image->integrity_recalculate)
+				ret = 1;
+		}
+	} else if (seg_is_integrity(seg)) {
+		ret = seg->integrity_recalculate;
+	}
+
+	return ret;
+}
+
+int lv_raid_has_integrity(struct logical_volume *lv)
+{
+	struct logical_volume *lv_image;
+	struct lv_segment *seg, *seg_image;
+	uint32_t s;
+
+	seg = first_seg(lv);
+
+	if (seg_is_raid(seg)) {
+		for (s = 0; s < seg->area_count; s++) {
+			lv_image = seg_lv(seg, s);
+			seg_image = first_seg(lv_image);
+
+			if (seg_is_integrity(seg_image))
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
+int lv_get_raid_integrity_settings(struct logical_volume *lv, struct integrity_settings **isettings)
+{
+	struct logical_volume *lv_image;
+	struct lv_segment *seg, *seg_image;
+	uint32_t s;
+
+	seg = first_seg(lv);
+
+	if (seg_is_raid(seg)) {
+		for (s = 0; s < seg->area_count; s++) {
+			lv_image = seg_lv(seg, s);
+			seg_image = first_seg(lv_image);
+
+			if (seg_is_integrity(seg_image)) {
+				*isettings = &seg_image->integrity_settings;
+				return 1;
+			}
+		}
+	}
+
+	return 0;
+}
+
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 17d490716..4ee58b419 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -385,6 +385,17 @@ dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_an
 	 *   Esentially rework  _target_percent API for segtype.
 	 */
 	switch (s->type) {
+	case SEG_STATUS_INTEGRITY:
+		if (type != PERCENT_GET_DIRTY)
+			p = DM_PERCENT_INVALID;
+		else if (!s->integrity->recalc_sector)
+			p = DM_PERCENT_INVALID;
+		else if (s->integrity->recalc_sector == s->integrity->provided_data_sectors)
+			p = DM_PERCENT_100;
+		else
+			p = dm_make_percent(s->integrity->recalc_sector,
+					    s->integrity->provided_data_sectors);
+		break;
 	case SEG_STATUS_CACHE:
 		if (s->cache->fail || s->cache->error)
 			p = DM_PERCENT_INVALID;
@@ -593,6 +604,8 @@ struct logical_volume *lv_origin_lv(const struct logical_volume *lv)
 		origin = first_seg(lv)->external_lv;
 	else if (lv_is_writecache(lv) && first_seg(lv)->origin)
 		origin = first_seg(lv)->origin;
+	else if (lv_is_integrity(lv) && first_seg(lv)->origin)
+		origin = first_seg(lv)->origin;
 
 	return origin;
 }
@@ -1208,10 +1221,13 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
 	else if (lv_is_pool_metadata(lv) ||
 		 lv_is_pool_metadata_spare(lv) ||
-		 lv_is_raid_metadata(lv))
+		 lv_is_raid_metadata(lv) ||
+		 lv_is_integrity_metadata(lv))
 		repstr[0] = 'e';
 	else if (lv_is_cache_type(lv) || lv_is_writecache(lv))
 		repstr[0] = 'C';
+	else if (lv_is_integrity(lv))
+		repstr[0] = 'g';
 	else if (lv_is_raid(lv))
 		repstr[0] = (lv_is_not_synced(lv)) ? 'R' : 'r';
 	else if (lv_is_mirror(lv))
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3090a93f7..1311f70bd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -134,7 +134,9 @@ enum {
 	LV_TYPE_SANLOCK,
 	LV_TYPE_CACHEVOL,
 	LV_TYPE_WRITECACHE,
-	LV_TYPE_WRITECACHEORIGIN
+	LV_TYPE_WRITECACHEORIGIN,
+	LV_TYPE_INTEGRITY,
+	LV_TYPE_INTEGRITYORIGIN
 };
 
 static const char *_lv_type_names[] = {
@@ -190,6 +192,8 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_CACHEVOL] =				"cachevol",
 	[LV_TYPE_WRITECACHE] =				"writecache",
 	[LV_TYPE_WRITECACHEORIGIN] =			"writecacheorigin",
+	[LV_TYPE_INTEGRITY] =				"integrity",
+	[LV_TYPE_INTEGRITYORIGIN] =			"integrityorigin",
 };
 
 static int _lv_layout_and_role_mirror(struct dm_pool *mem,
@@ -461,6 +465,43 @@ bad:
 	return 0;
 }
 
+static int _lv_layout_and_role_integrity(struct dm_pool *mem,
+				     const struct logical_volume *lv,
+				     struct dm_list *layout,
+				     struct dm_list *role,
+				     int *public_lv)
+{
+	int top_level = 0;
+
+	/* non-top-level LVs */
+	if (lv_is_integrity_metadata(lv)) {
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_INTEGRITY]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_METADATA]))
+			goto_bad;
+	} else if (lv_is_integrity_origin(lv)) {
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_INTEGRITY]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_ORIGIN]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_INTEGRITYORIGIN]))
+			goto_bad;
+	} else
+		top_level = 1;
+
+	if (!top_level) {
+		*public_lv = 0;
+		return 1;
+	}
+
+	/* top-level LVs */
+	if (lv_is_integrity(lv)) {
+		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_INTEGRITY]))
+			goto_bad;
+	}
+
+	return 1;
+bad:
+	return 0;
+}
+
 static int _lv_layout_and_role_thick_origin_snapshot(struct dm_pool *mem,
 						     const struct logical_volume *lv,
 						     struct dm_list *layout,
@@ -577,6 +618,11 @@ int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 	    !_lv_layout_and_role_cache(mem, lv, *layout, *role, &public_lv))
 		goto_bad;
 
+	/* Integrity related */
+	if ((lv_is_integrity(lv) || lv_is_integrity_origin(lv) || lv_is_integrity_metadata(lv)) &&
+	    !_lv_layout_and_role_integrity(mem, lv, *layout, *role, &public_lv))
+		goto_bad;
+
 	/* VDO and related */
 	if (lv_is_vdo_type(lv) &&
 	    !_lv_layout_and_role_vdo(mem, lv, *layout, *role, &public_lv))
@@ -1457,6 +1503,15 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 					return_0;
 			}
 
+			if (delete && seg_is_integrity(seg)) {
+				/* Remove integrity origin in addition to integrity layer. */
+				if (!lv_remove(seg_lv(seg, 0)))
+					return_0;
+				/* Remove integrity metadata. */
+				if (seg->integrity_meta_dev && !lv_remove(seg->integrity_meta_dev))
+					return_0;
+			}
+
 			if ((pool_lv = seg->pool_lv)) {
 				if (!detach_pool_lv(seg))
 					return_0;
@@ -4111,11 +4166,14 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 				 uint32_t extents, uint32_t first_area,
 				 uint32_t mirrors, uint32_t stripes, uint32_t stripe_size)
 {
+	struct logical_volume *sub_lvs[DEFAULT_RAID_MAX_IMAGES];
 	const struct segment_type *segtype;
-	struct logical_volume *sub_lv, *meta_lv;
+	struct logical_volume *meta_lv, *sub_lv;
 	struct lv_segment *seg = first_seg(lv);
+	struct lv_segment *sub_lv_seg;
 	uint32_t fa, s;
 	int clear_metadata = 0;
+	int integrity_sub_lvs = 0;
 	uint32_t area_multiple = 1;
 
 	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
@@ -4133,16 +4191,28 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 			area_multiple = seg->area_count;
 	}
 
+	for (s = 0; s < seg->area_count; s++) {
+		sub_lv = seg_lv(seg, s);
+		sub_lv_seg = sub_lv ? first_seg(sub_lv) : NULL;
+
+		if (sub_lv_seg && seg_is_integrity(sub_lv_seg)) {
+			sub_lvs[s] = seg_lv(sub_lv_seg, 0);
+			integrity_sub_lvs = 1;
+		} else
+			sub_lvs[s] = sub_lv;
+	}
+
 	for (fa = first_area, s = 0; s < seg->area_count; s++) {
-		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
-			if (!_lv_extend_layered_lv(ah, seg_lv(seg, s), extents / area_multiple,
+		sub_lv = sub_lvs[s];
+
+		if (is_temporary_mirror_layer(sub_lv)) {
+			if (!_lv_extend_layered_lv(ah, sub_lv, extents / area_multiple,
 						   fa, mirrors, stripes, stripe_size))
 				return_0;
-			fa += lv_mirror_count(seg_lv(seg, s));
+			fa += lv_mirror_count(sub_lv);
 			continue;
 		}
 
-		sub_lv = seg_lv(seg, s);
 		if (!lv_add_segment(ah, fa, stripes, sub_lv, segtype,
 				    stripe_size, sub_lv->status, 0)) {
 			log_error("Aborting. Failed to extend %s in %s.",
@@ -4184,6 +4254,41 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		fa += stripes;
 	}
 
+	/*
+	 * In raid+integrity, the lv_iorig raid images have been extended above.
+	 * Now propagate the new lv_iorig sizes up to the integrity LV layers
+	 * that are referencing the lv_iorig.
+	 */
+	if (integrity_sub_lvs) {
+		for (s = 0; s < seg->area_count; s++) {
+			struct logical_volume *lv_image;
+			struct logical_volume *lv_iorig;
+			struct logical_volume *lv_imeta;
+			struct lv_segment *seg_image;
+
+			lv_image = seg_lv(seg, s);
+			seg_image = first_seg(lv_image);
+
+			if (!(lv_imeta = seg_image->integrity_meta_dev)) {
+				log_error("1");
+				return_0;
+			}
+
+			if (!(lv_iorig = seg_lv(seg_image, 0))) {
+				log_error("2");
+				return_0;
+			}
+
+			/* new size in sectors */
+			lv_image->size = lv_iorig->size;
+			seg_image->integrity_data_sectors = lv_iorig->size;
+			/* new size in extents */
+			lv_image->le_count = lv_iorig->le_count;
+			seg_image->len = lv_iorig->le_count;
+			seg_image->area_len = lv_iorig->le_count;
+		}
+	}
+
 	seg->len += extents;
 	if (seg_is_raid(seg))
 		seg->area_len = seg->len;
@@ -4345,6 +4450,13 @@ int lv_extend(struct logical_volume *lv,
 						mirrors, stripes, stripe_size)))
 			goto_out;
 
+		if (lv_raid_has_integrity(lv)) {
+			if (!lv_extend_integrity_in_raid(lv, allocatable_pvs)) {
+				r = 0;
+				goto_out;
+			}
+		}
+
 		/*
 		 * If we are expanding an existing mirror, we can skip the
 		 * resync of the extension if the LV is currently in-sync
@@ -4538,6 +4650,9 @@ static int _for_each_sub_lv(struct logical_volume *lv, int level,
 		if (!_for_each_sub_lv(seg->writecache, level, fn, data))
 			return_0;
 
+		if (!_for_each_sub_lv(seg->integrity_meta_dev, level, fn, data))
+			return_0;
+
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
@@ -5064,6 +5179,12 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_integrity(lv) || lv_raid_has_integrity(lv)) {
+		if (lp->resize == LV_REDUCE) {
+			log_error("Cannot reduce LV with integrity.");
+			return 0;
+		}
+	}
 	return 1;
 }
 
@@ -5613,6 +5734,9 @@ static int _lvresize_prepare(struct logical_volume **lv,
 	if (lv_is_thin_pool(*lv) || lv_is_vdo_pool(*lv))
 		*lv = seg_lv(first_seg(*lv), 0); /* switch to data LV */
 
+	if (lv_is_integrity(*lv))
+		*lv = seg_lv(first_seg(*lv), 0);
+
 	/* Resolve extents from size */
 	if (lp->size && !_lvresize_adjust_size(vg, lp->size, lp->sign, &lp->extents))
 		return_0;
@@ -7948,6 +8072,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		/* FIXME Eventually support raid/mirrors with -m */
 		if (!(create_segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))
 			return_0;
+
+	} else if (seg_is_integrity(lp)) {
+		if (!(create_segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))
+			return_0;
+
 	} else if (seg_is_mirrored(lp) || (seg_is_raid(lp) && !seg_is_any_raid0(lp))) {
 		if (!(lp->region_size = adjusted_mirror_region_size(vg->cmd,
 								    vg->extent_size,
@@ -8198,6 +8327,15 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		goto out;
 	}
 
+	if (seg_is_raid(lp) && lp->raidintegrity) {
+		log_debug("Adding integrity to new LV");
+
+		if (!lv_add_integrity_to_raid(lv, &lp->integrity_settings, lp->pvh, NULL))
+			goto revert_new_lv;
+
+		backup(vg);
+	}
+
 	/* Do not scan this LV until properly zeroed/wiped. */
 	if (_should_wipe_lv(lp, lv, 0))
 		lv->status |= LV_NOSCAN;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 11b26b469..ecd55efdd 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -742,6 +742,8 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			seg_found++;
 		if (seg->metadata_lv == lv || seg->pool_lv == lv || seg->writecache == lv)
 			seg_found++;
+		if (seg->integrity_meta_dev == lv)
+			seg_found++;
 		if (seg_is_thin_volume(seg) && (seg->origin == lv || seg->external_lv == lv))
 			seg_found++;
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 35c12318f..52bc77673 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -84,12 +84,14 @@
 #define CONVERTING		UINT64_C(0x0000000000400000)	/* LV */
 
 #define MISSING_PV		UINT64_C(0x0000000000800000)	/* PV */
+#define INTEGRITY		UINT64_C(0x0000000000800000)	/* LV - Internal use only */
 #define PV_MOVED_VG		UINT64_C(0x4000000000000000)	/* PV - Moved to a new VG */
 #define PARTIAL_LV		UINT64_C(0x0000000001000000)	/* LV - derived flag, not
 							   written out in metadata*/
 
 //#define POSTORDER_FLAG	UINT64_C(0x0000000002000000) /* Not real flags, reserved for
 //#define POSTORDER_OPEN_FLAG	UINT64_C(0x0000000004000000)    temporary use inside vg_read_internal. */
+#define INTEGRITY_METADATA	UINT64_C(0x0000000004000000)    /* LV - Internal use only */
 #define VIRTUAL_ORIGIN		UINT64_C(0x0000000008000000)	/* LV - internal use only */
 
 #define MERGING			UINT64_C(0x0000000010000000)	/* LV SEG */
@@ -261,6 +263,8 @@
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
 #define lv_is_lockd_sanlock_lv(lv)	(((lv)->status & LOCKD_SANLOCK_LV) ? 1 : 0)
 #define lv_is_writecache(lv)   (((lv)->status & WRITECACHE) ? 1 : 0)
+#define lv_is_integrity(lv)            (((lv)->status & INTEGRITY) ? 1 : 0)
+#define lv_is_integrity_metadata(lv)   (((lv)->status & INTEGRITY_METADATA) ? 1 : 0)
 
 #define lv_is_vdo(lv)		(((lv)->status & LV_VDO) ? 1 : 0)
 #define lv_is_vdo_pool(lv)	(((lv)->status & LV_VDO_POOL) ? 1 : 0)
@@ -272,9 +276,11 @@
 /* Recognize component LV (matching lib/misc/lvm-string.c _lvname_has_reserved_component_string()) */
 #define lv_is_component(lv) (lv_is_cache_origin(lv) || \
 			     lv_is_writecache_origin(lv) || \
+			     lv_is_integrity_origin(lv) || \
 			     ((lv)->status & (\
 					      CACHE_POOL_DATA |\
 					      CACHE_POOL_METADATA |\
+					      INTEGRITY_METADATA |\
 					      LV_CACHE_VOL |\
 					      LV_VDO_POOL_DATA |\
 					      MIRROR_IMAGE |\
@@ -519,6 +525,11 @@ struct lv_segment {
 	uint32_t writecache_block_size;		/* For writecache */
 	struct writecache_settings writecache_settings; /* For writecache */
 
+	uint64_t integrity_data_sectors;
+	struct logical_volume *integrity_meta_dev;
+	struct integrity_settings integrity_settings;
+	uint32_t integrity_recalculate;
+
 	struct dm_vdo_target_params vdo_params;	/* For VDO-pool */
 	uint32_t vdo_pool_header_size;		/* For VDO-pool */
 	uint32_t vdo_pool_virtual_extents;	/* For VDO-pool */
@@ -992,6 +1003,10 @@ struct lvcreate_params {
 	alloc_policy_t alloc; /* all */
 	struct dm_vdo_target_params vdo_params; /* vdo */
 
+	int raidintegrity;
+	const char *raidintegritymode;
+	struct integrity_settings integrity_settings;
+
 	struct dm_list tags;	/* all */
 
 	int yes;
@@ -1086,6 +1101,8 @@ int lv_is_cache_origin(const struct logical_volume *lv);
 int lv_is_writecache_origin(const struct logical_volume *lv);
 int lv_is_writecache_cachevol(const struct logical_volume *lv);
 
+int lv_is_integrity_origin(const struct logical_volume *lv);
+
 int lv_is_merging_cow(const struct logical_volume *cow);
 uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size);
 int cow_has_min_chunks(const struct volume_group *vg, uint32_t cow_extents, uint32_t chunk_size);
@@ -1389,4 +1406,13 @@ struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int
 		                                            char **argv, int allocatable_only);
 struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl);
 
+int lv_add_integrity_to_raid(struct logical_volume *lv, struct integrity_settings *settings, struct dm_list *pvh,
+			     struct logical_volume *lv_imeta_0);
+int lv_remove_integrity_from_raid(struct logical_volume *lv);
+void lv_clear_integrity_recalculate_metadata(struct logical_volume *lv);
+int lv_has_integrity_recalculate_metadata(struct logical_volume *lv);
+int lv_raid_has_integrity(struct logical_volume *lv);
+int lv_extend_integrity_in_raid(struct logical_volume *lv, struct dm_list *pvh);
+int lv_get_raid_integrity_settings(struct logical_volume *lv, struct integrity_settings **isettings);
+
 #endif
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index fa1b91a7e..3b3e1d373 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3119,6 +3119,11 @@ static int _raid_remove_images(struct logical_volume *lv, int yes,
 
 	/* Convert to linear? */
 	if (new_count == 1) {
+		if (lv_raid_has_integrity(lv)) {
+			log_error("Integrity must be removed before converting raid to linear.");
+			return 0;
+		}
+
 		if (!yes && yes_no_prompt("Are you sure you want to convert %s LV %s to type %s losing all resilience? [y/n]: ",
 					  lvseg_name(first_seg(lv)), display_lvname(lv), SEG_TYPE_NAME_LINEAR) == 'n') {
 			log_error("Logical volume %s NOT converted to \"%s\".",
@@ -3265,6 +3270,11 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 		return 0;
 	}
 
+	if (lv_raid_has_integrity(lv)) {
+		log_error("Integrity must be removed before splitting.");
+		return 0;
+	}
+
 	if ((old_count - new_count) != 1) {
 		log_error("Unable to split more than one image from %s.",
 			  display_lvname(lv));
@@ -3328,9 +3338,11 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 	}
 
 	/* Convert to linear? */
-	if ((new_count == 1) && !_raid_remove_top_layer(lv, &removal_lvs)) {
-		log_error("Failed to remove RAID layer after linear conversion.");
-		return 0;
+	if (new_count == 1) {
+		if (!_raid_remove_top_layer(lv, &removal_lvs)) {
+			log_error("Failed to remove RAID layer after linear conversion.");
+			return 0;
+		}
 	}
 
 	/* Get first item */
@@ -3432,6 +3444,11 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_raid_has_integrity(lv)) {
+		log_error("Integrity must be removed before splitting.");
+		return 0;
+	}
+
 	if (!seg_is_mirrored(seg)) {
 		log_error("Unable to split images from non-mirrored RAID.");
 		return 0;
@@ -6727,7 +6744,17 @@ static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
 	struct lv_segment *raid_seg = first_seg(lv);
 	struct lv_list *lvl;
 	char *tmp_names[raid_seg->area_count * 2];
+	char tmp_name_buf[NAME_LEN];
+	char *tmp_name_dup;
 	const char *action_str = rebuild ? "rebuild" : "replace";
+	int has_integrity;
+
+	if ((has_integrity = lv_raid_has_integrity(lv))) {
+		if (rebuild) {
+			log_error("Can't rebuild raid with integrity.");
+			return 0;
+		}
+	}
 
 	if (seg_is_any_raid0(raid_seg)) {
 		log_error("Can't replace any devices in %s LV %s.",
@@ -6992,6 +7019,15 @@ try_again:
 			tmp_names[s] = tmp_names[sd] = NULL;
 	}
 
+	/* Add integrity layer to any new images. */
+	if (has_integrity) {
+		struct integrity_settings *isettings = NULL;
+		if (!lv_get_raid_integrity_settings(lv, &isettings))
+			return_0;
+		if (!lv_add_integrity_to_raid(lv, isettings, NULL, NULL))
+			return_0;
+	}
+
 skip_alloc:
 	if (!lv_update_and_reload_origin(lv))
 		return_0;
@@ -7014,9 +7050,43 @@ skip_alloc:
 	if (!rebuild)
 		for (s = 0; s < raid_seg->area_count; s++) {
 			sd = s + raid_seg->area_count;
+
 			if (tmp_names[s] && tmp_names[sd]) {
-				seg_metalv(raid_seg, s)->name = tmp_names[s];
-				seg_lv(raid_seg, s)->name = tmp_names[sd];
+				struct logical_volume *lv_image = seg_lv(raid_seg, s);
+				struct logical_volume *lv_rmeta = seg_metalv(raid_seg, s);
+
+				lv_rmeta->name = tmp_names[s];
+				lv_image->name = tmp_names[sd];
+
+				if (lv_is_integrity(lv_image)) {
+					struct logical_volume *lv_imeta;
+					struct logical_volume *lv_iorig;
+					struct lv_segment *seg_image;
+
+					seg_image = first_seg(lv_image);
+					lv_imeta = seg_image->integrity_meta_dev;
+					lv_iorig = seg_lv(seg_image, 0);
+
+					if (dm_snprintf(tmp_name_buf, NAME_LEN, "%s_imeta", lv_image->name) < 0) {
+						stack;
+						continue;
+					}
+					if (!(tmp_name_dup = dm_pool_strdup(lv->vg->vgmem, tmp_name_buf))) {
+						stack;
+						continue;
+					}
+					lv_imeta->name = tmp_name_dup;
+
+					if (dm_snprintf(tmp_name_buf, NAME_LEN, "%s_iorig", lv_image->name) < 0) {
+						stack;
+						continue;
+					}
+					if (!(tmp_name_dup = dm_pool_strdup(lv->vg->vgmem, tmp_name_buf))) {
+						stack;
+						continue;
+					}
+					lv_iorig->name = tmp_name_dup;
+				}
 			}
 		}
 
@@ -7192,6 +7262,11 @@ int partial_raid_lv_supports_degraded_activation(const struct logical_volume *cl
 {
 	int not_capable = 0;
 	struct logical_volume * lv = (struct logical_volume *)clv; /* drop const */
+	
+	if (lv_raid_has_integrity(lv)) {
+		log_error("Integrity must be removed before degraded or partial activation of raid.");
+		return 0;
+	}
 
 	if (!_lv_may_be_activated_in_degraded_mode(lv, &not_capable) || not_capable)
 		return_0;
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 22a511eac..08ddc3565 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -67,6 +67,7 @@ struct dev_manager;
 #define SEG_RAID6_N_6		(1ULL << 35)
 #define SEG_RAID6		SEG_RAID6_ZR
 #define SEG_WRITECACHE		(1ULL << 36)
+#define SEG_INTEGRITY		(1ULL << 37)
 
 #define SEG_STRIPED_TARGET	(1ULL << 39)
 #define SEG_LINEAR_TARGET	(1ULL << 40)
@@ -84,6 +85,7 @@ struct dev_manager;
 #define SEG_TYPE_NAME_CACHE		"cache"
 #define SEG_TYPE_NAME_CACHE_POOL	"cache-pool"
 #define SEG_TYPE_NAME_WRITECACHE	"writecache"
+#define SEG_TYPE_NAME_INTEGRITY		"integrity"
 #define SEG_TYPE_NAME_ERROR		"error"
 #define SEG_TYPE_NAME_FREE		"free"
 #define SEG_TYPE_NAME_ZERO		"zero"
@@ -117,6 +119,7 @@ struct dev_manager;
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
 #define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)
 #define segtype_is_writecache(segtype)	((segtype)->flags & SEG_WRITECACHE ? 1 : 0)
+#define segtype_is_integrity(segtype)	((segtype)->flags & SEG_INTEGRITY ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define segtype_is_mirror(segtype)	((segtype)->flags & SEG_MIRROR ? 1 : 0)
 #define segtype_is_pool(segtype)	((segtype)->flags & (SEG_CACHE_POOL | SEG_THIN_POOL)  ? 1 : 0)
@@ -179,6 +182,7 @@ struct dev_manager;
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)
 #define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)
 #define seg_is_writecache(seg)	segtype_is_writecache((seg)->segtype)
+#define seg_is_integrity(seg)	segtype_is_integrity((seg)->segtype)
 #define seg_is_used_cache_pool(seg) (seg_is_cache_pool(seg) && (!dm_list_empty(&(seg->lv)->segs_using_this_lv)))
 #define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
 #define seg_is_mirror(seg)	segtype_is_mirror((seg)->segtype)
@@ -347,6 +351,8 @@ int init_vdo_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 
 int init_writecache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 
+int init_integrity_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
+
 #define CACHE_FEATURE_POLICY_MQ			(1U << 0)
 #define CACHE_FEATURE_POLICY_SMQ		(1U << 1)
 #define CACHE_FEATURE_METADATA2			(1U << 2)
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 64e27ae83..3faea0eb8 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -387,6 +387,8 @@ int validate_snapshot_origin(const struct logical_volume *origin_lv)
 		}
 	} else if (lv_is_raid_type(origin_lv) && !lv_is_raid(origin_lv)) {
 		err = "raid subvolumes";
+	} else if (lv_is_raid(origin_lv) && lv_raid_has_integrity((struct logical_volume *)origin_lv)) {
+		err = "raid with integrity";
 	} else if (lv_is_writecache(origin_lv)) {
 		err = "writecache";
 	}
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 0ee3403d5..959a6a16e 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -166,7 +166,9 @@ static const char *_lvname_has_reserved_component_string(const char *lvname)
 		"_rmeta",
 		"_tdata",
 		"_tmeta",
-		"_vdata"
+		"_vdata",
+		"_imeta",
+		"_iorig"
 	};
 	unsigned i;
 
diff --git a/lib/report/report.c b/lib/report/report.c
index d379e2a27..170df6995 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3173,7 +3173,7 @@ static int _copypercent_disp(struct dm_report *rh,
 	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	/* TODO: just cache passes through lvseg_percent... */
-	if (lv_is_cache(lv) || lv_is_used_cache_pool(lv) ||
+	if (lv_is_integrity(lv) || lv_is_cache(lv) || lv_is_used_cache_pool(lv) ||
 	    (!lv_is_merging_origin(lv) && lv_is_raid(lv) && !seg_is_any_raid0(first_seg(lv))))
 		percent = lvseg_percent_with_info_and_seg_status(lvdm, PERCENT_GET_DIRTY);
 	else if (lv_is_raid(lv) && !seg_is_any_raid0(first_seg(lv)))
diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 498de9024..aedd16a27 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -785,6 +785,89 @@ configuration file itself.
         activation_mode
 
 
+.SH Data Integrity
+
+The device mapper integrity target can be used in combination with RAID
+levels 1,4,5,6,10 to detect and correct data corruption in RAID images. A
+dm-integrity layer is placed above each RAID image, and an extra sub LV is
+created to hold integrity metadata (data checksums) for each RAID image.
+When data is read from an image, integrity checksums are used to detect
+corruption. If detected, dm-raid reads the data from another (good) image
+to return to the caller.  dm-raid will also automatically write the good
+data back to the image with bad data to correct the corruption.
+
+When creating a RAID LV with integrity, or adding integrity, space is
+required for integrity metadata.  Every 500MB of LV data requires an
+additional 4MB to be allocated for integrity metadata, for each RAID
+image.
+
+Create a RAID LV with integrity:
+
+.B lvcreate \-\-type raidN \-\-raidintegrity y
+
+Add integrity to an existing RAID LV:
+
+.B lvconvert --raidintegrity y
+.I LV
+
+Remove integrity from a RAID LV:
+
+.B lvconvert --raidintegrity n
+.I LV
+
+.SS Integrity options
+
+.B --raidintegritymode journal|bitmap
+
+Use a journal (default) or bitmap for keeping integrity checksums
+consistent in case of a crash. The bitmap areas are recalculated after a
+crash, so corruption in those areas would not be detected. A journal does
+not have this problem.  The journal mode doubles writes to storage, but
+can improve performance for scattered writes packed into a single journal
+write.  bitmap mode can in theory achieve full write throughput of the
+device, but would not benefit from the potential scattered write
+optimization.
+
+.B --raidintegrityblocksize 512|1024|2048|4096
+
+The block size to use for dm-integrity on raid images.  The integrity
+block size should usually match the device logical block size, or the file
+system sector/block sizes.  It may be less than the file system
+sector/block size, but not less than the device logical block size.
+Possible values: 512, 1024, 2048, 4096.
+
+.SS Integrity initialization
+
+When integrity is added to an LV, the kernel needs to initialize the
+integrity metadata (checksums) for all blocks in the LV.  The data
+corruption checking performed by dm-integrity will only operate on areas
+of the LV that are already initialized.  The progress of integrity
+initialization is reported by the "syncpercent" LV reporting field (and
+under the Cpy%Sync lvs column.)
+
+.SS Integrity limitations
+
+To work around some limitations, it is possible to remove integrity from
+the LV, make the change, then add integrity again.  (Integrity metadata
+would need to initialized when added again.)
+
+LVM must be able to allocate the integrity metadata sub LV on a single PV
+that is already in use by the associated RAID image. This can potentially
+cause a problem during lvextend if the original PV holding the image and
+integrity metadata is full.  To work around this limitation, remove
+integrity, extend the LV, and add integrity again.
+
+Additional RAID images can be added to raid1 LVs, but not to other raid
+levels.
+
+A raid1 LV with integrity cannot be converted to linear (remove integrity
+to do this.)
+
+RAID LVs with integrity cannot yet be used as sub LVs with other LV types.
+
+The following are not yet permitted on RAID LVs with integrity: lvreduce,
+pvmove, snapshots, splitmirror, raid syncaction commands, raid rebuild.
+
 .SH RAID1 Tuning
 
 A RAID1 LV can be tuned so that certain devices are avoided for reading
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 83a88a611..e40da9592 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1563,6 +1563,14 @@ have_writecache() {
 	target_at_least dm-writecache "$@"
 }
 
+have_integrity() {
+	lvm segtypes 2>/dev/null | grep -q integrity$ || {
+		echo "integrity is not built-in." >&2
+		return 1
+	}
+	target_at_least dm-integrity "$@"
+}
+
 have_raid() {
 	target_at_least dm-raid "$@"
 
diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
new file mode 100644
index 000000000..444e3db4c
--- /dev/null
+++ b/test/shell/integrity-blocksize.sh
@@ -0,0 +1,183 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_integrity 1 5 0 || skip
+
+losetup -h | grep sector-size || skip
+
+# Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
+aux prepare_devs 1
+vgcreate $vg "$dev1"
+lvcreate -n $lv1 -l8 $vg
+mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+blkid "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+lvchange -an $vg
+vgremove -ff $vg
+
+dd if=/dev/zero of=loopa bs=$((1024*1024)) count=64 2> /dev/null
+dd if=/dev/zero of=loopb bs=$((1024*1024)) count=64 2> /dev/null
+dd if=/dev/zero of=loopc bs=$((1024*1024)) count=64 2> /dev/null
+dd if=/dev/zero of=loopd bs=$((1024*1024)) count=64 2> /dev/null
+LOOP1=$(losetup -f loopa --show)
+LOOP2=$(losetup -f loopb --show)
+LOOP3=$(losetup -f loopc --sector-size 4096 --show)
+LOOP4=$(losetup -f loopd --sector-size 4096 --show)
+
+echo $LOOP1
+echo $LOOP2
+echo $LOOP3
+echo $LOOP4
+
+aux extend_filter "a|$LOOP1|"
+aux extend_filter "a|$LOOP2|"
+aux extend_filter "a|$LOOP3|"
+aux extend_filter "a|$LOOP4|"
+
+aux lvmconf 'devices/scan = "/dev"'
+
+vgcreate $vg1 $LOOP1 $LOOP2
+vgcreate $vg2 $LOOP3 $LOOP4
+
+# lvcreate on dev512, result 512
+lvcreate --type raid1 -m1 --raidintegrity y -l 8 -n $lv1 $vg1
+pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+lvremove -y $vg1/$lv1
+
+# lvcreate on dev4k, result 4k
+lvcreate --type raid1 -m1 --raidintegrity y -l 8 -n $lv1 $vg2
+pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
+lvremove -y $vg2/$lv1
+
+# lvcreate --bs 512 on dev4k, result fail
+not lvcreate --type raid1 -m1 --raidintegrity y --raidintegrityblocksize 512 -l 8 -n $lv1 $vg2
+
+# lvcreate --bs 4096 on dev512, result 4k
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegrityblocksize 4096 -l 8 -n $lv1 $vg1
+pvck --dump metadata $LOOP1 | grep 'block_size = 4096'
+lvremove -y $vg1/$lv1
+
+# Test an unknown fs block size by simply not creating a fs on the lv.
+
+# lvconvert on dev512, fsunknown, result 512
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+# clear any residual fs so that libblkid cannot find an fs block size
+aux wipefs_a /dev/$vg1/$lv1
+lvconvert --raidintegrity y $vg1/$lv1
+pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+lvremove -y $vg1/$lv1
+
+# lvconvert on dev4k, fsunknown, result 4k
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
+# clear any residual fs so that libblkid cannot find an fs block size
+aux wipefs_a /dev/$vg2/$lv1
+lvconvert --raidintegrity y $vg2/$lv1
+pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
+lvremove -y $vg2/$lv1
+
+# lvconvert --bs 4k on dev512, fsunknown, result fail
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+# clear any residual fs so that libblkid cannot find an fs block size
+aux wipefs_a /dev/$vg1/$lv1
+not lvconvert --raidintegrity y --raidintegrityblocksize 4096 $vg1/$lv1
+lvremove -y $vg1/$lv1
+
+# lvconvert --bs 512 on dev4k, fsunknown, result fail
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
+# clear any residual fs so that libblkid cannot find an fs block size
+aux wipefs_a /dev/$vg2/$lv1
+not lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg2/$lv1
+lvremove -y $vg2/$lv1
+
+# lvconvert on dev512, xfs 512, result 512
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+aux wipefs_a /dev/$vg1/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg1/$lv1"
+lvconvert --raidintegrity y $vg1/$lv1
+pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+lvremove -y $vg1/$lv1
+
+# lvconvert on dev4k, xfs 4096, result 4096
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
+aux wipefs_a /dev/$vg2/$lv1
+mkfs.xfs -f "$DM_DEV_DIR/$vg2/$lv1"
+lvconvert --raidintegrity y $vg2/$lv1
+pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
+lvremove -y $vg2/$lv1
+
+# lvconvert on dev512, ext4 1024, result 1024 
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+aux wipefs_a /dev/$vg1/$lv1
+mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
+lvconvert --raidintegrity y $vg1/$lv1
+pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
+lvremove -y $vg1/$lv1
+
+# lvconvert on dev4k, ext4 4096, result 4096
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
+aux wipefs_a /dev/$vg2/$lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
+lvconvert --raidintegrity y $vg2/$lv1
+pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
+lvremove -y $vg2/$lv1
+
+# lvconvert --bs 512 on dev512, xfs 4096, result 512
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+aux wipefs_a /dev/$vg1/$lv1
+mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
+lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
+pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+lvremove -y $vg1/$lv1
+
+# lvconvert --bs 1024 on dev512, xfs 4096, result 1024
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+aux wipefs_a /dev/$vg1/$lv1
+mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
+lvconvert --raidintegrity y --raidintegrityblocksize 1024 $vg1/$lv1
+pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
+lvremove -y $vg1/$lv1
+
+# lvconvert --bs 512 on dev512, ext4 1024, result 512
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
+aux wipefs_a /dev/$vg1/$lv1
+mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
+lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
+pvck --dump metadata $LOOP1 | grep 'block_size = 512'
+lvremove -y $vg1/$lv1
+
+# lvconvert --bs 512 on dev4k, ext4 4096, result fail
+lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
+aux wipefs_a /dev/$vg2/$lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
+not lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg2/$lv1
+lvremove -y $vg2/$lv1
+
+# FIXME: need to use scsi_debug to create devs with LBS 512 PBS 4k
+# FIXME: lvconvert, fsunknown, LBS 512, PBS 4k: result 512
+# FIXME: lvconvert --bs 512, fsunknown, LBS 512, PBS 4k: result 512
+# FIXME: lvconvert --bs 4k, fsunknown, LBS 512, PBS 4k: result 4k
+
+vgremove -ff $vg1
+vgremove -ff $vg2
+
+losetup -d $LOOP1
+losetup -d $LOOP2
+losetup -d $LOOP3
+losetup -d $LOOP4
+rm loopa
+rm loopb
+rm loopc
+rm loopd
+
diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
new file mode 100644
index 000000000..58899ca80
--- /dev/null
+++ b/test/shell/integrity-dmeventd.sh
@@ -0,0 +1,289 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_integrity 1 5 0 || skip
+which mkfs.xfs || skip
+
+mnt="mnt"
+mkdir -p $mnt
+
+aux prepare_devs 6 64
+
+for i in `seq 1 16384`; do echo -n "A" >> fileA; done
+for i in `seq 1 16384`; do echo -n "B" >> fileB; done
+for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+
+# generate random data
+dd if=/dev/urandom of=randA bs=512K count=2
+dd if=/dev/urandom of=randB bs=512K count=3
+dd if=/dev/urandom of=randC bs=512K count=4
+
+_prepare_vg() {
+	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
+	pvs
+}
+
+_add_new_data_to_mnt() {
+        mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+
+        mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+        # add original data
+        cp randA $mnt
+        cp randB $mnt
+        cp randC $mnt
+        mkdir $mnt/1
+        cp fileA $mnt/1
+        cp fileB $mnt/1
+        cp fileC $mnt/1
+        mkdir $mnt/2
+        cp fileA $mnt/2
+        cp fileB $mnt/2
+        cp fileC $mnt/2
+}
+
+_add_more_data_to_mnt() {
+        mkdir $mnt/more
+        cp fileA $mnt/more
+        cp fileB $mnt/more
+        cp fileC $mnt/more
+        cp randA $mnt/more
+        cp randB $mnt/more
+        cp randC $mnt/more
+}
+
+_verify_data_on_mnt() {
+	diff randA $mnt/randA
+	diff randB $mnt/randB
+	diff randC $mnt/randC
+	diff fileA $mnt/1/fileA
+	diff fileB $mnt/1/fileB
+	diff fileC $mnt/1/fileC
+	diff fileA $mnt/2/fileA
+	diff fileB $mnt/2/fileB
+	diff fileC $mnt/2/fileC
+}
+
+_verify_data_on_lv() {
+        lvchange -ay $vg/$lv1
+        mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+        _verify_data_on_mnt
+        rm $mnt/randA
+        rm $mnt/randB
+        rm $mnt/randC
+        rm -rf $mnt/1
+        rm -rf $mnt/2
+        umount $mnt
+        lvchange -an $vg/$lv1
+}
+
+_sync_percent() {
+	local checklv=$1
+	get lv_field "$checklv" sync_percent | cut -d. -f1
+}
+
+_wait_recalc() {
+	local checklv=$1
+
+	for i in $(seq 1 10) ; do
+		sync=$(_sync_percent "$checklv")
+		echo "sync_percent is $sync"
+
+		if test "$sync" = "100"; then
+			return
+		fi
+
+		sleep 1
+	done
+
+	echo "timeout waiting for recalc"
+	return 1
+}
+
+aux lvmconf \
+        'activation/raid_fault_policy = "allocate"'
+
+aux prepare_dmeventd
+
+# raid1, one device fails, dmeventd calls repair
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate --type raid1 -m 2 --raidintegrity y --ignoremonitoring -l 8 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+lvchange --monitor y $vg/$lv1
+lvs -a -o+devices $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+aux wait_for_sync $vg $lv1
+_add_new_data_to_mnt
+
+aux disable_dev "$dev2"
+
+# wait for dmeventd to call lvconvert --repair which should
+# replace dev2 with dev4
+sleep 5
+
+lvs -a -o+devices $vg > out
+cat out
+not grep "$dev2" out
+grep "$dev4" out
+
+_add_more_data_to_mnt
+_verify_data_on_mnt
+
+aux enable_dev "$dev2"
+
+lvs -a -o+devices $vg > out
+cat out
+not grep "$dev2" out
+grep "$dev4" out
+grep "$dev1" out
+grep "$dev3" out
+
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# raid1, two devices fail, dmeventd calls repair
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvcreate --type raid1 -m 2 --raidintegrity y --ignoremonitoring -l 8 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+lvchange --monitor y $vg/$lv1
+lvs -a -o+devices $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+aux wait_for_sync $vg $lv1
+_add_new_data_to_mnt
+
+aux disable_dev "$dev2"
+aux disable_dev "$dev1"
+
+# wait for dmeventd to call lvconvert --repair which should
+# replace dev1 and dev2 with dev4 and dev5
+sleep 5
+
+lvs -a -o+devices $vg > out
+cat out
+not grep "$dev1" out
+not grep "$dev2" out
+grep "$dev4" out
+grep "$dev5" out
+grep "$dev3" out
+
+_add_more_data_to_mnt
+_verify_data_on_mnt
+
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+
+lvs -a -o+devices $vg > out
+cat out
+not grep "$dev1" out
+not grep "$dev2" out
+grep "$dev4" out
+grep "$dev5" out
+grep "$dev3" out
+
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# raid6, one device fails, dmeventd calls repair
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+lvcreate --type raid6 --raidintegrity y --ignoremonitoring -l 8 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvchange --monitor y $vg/$lv1
+lvs -a -o+devices $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
+_wait_recalc $vg/${lv1}_rimage_4
+aux wait_for_sync $vg $lv1
+_add_new_data_to_mnt
+
+aux disable_dev "$dev2"
+
+# wait for dmeventd to call lvconvert --repair which should
+# replace dev2 with dev6
+sleep 5
+
+lvs -a -o+devices $vg > out
+cat out
+not grep "$dev2" out
+grep "$dev6" out
+
+_add_more_data_to_mnt
+_verify_data_on_mnt
+
+aux enable_dev "$dev2"
+
+lvs -a -o+devices $vg > out
+cat out
+not grep "$dev2" out
+grep "$dev6" out
+
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# raid10, one device fails, dmeventd calls repair
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvcreate --type raid10 --raidintegrity y --ignoremonitoring -l 8 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lvchange --monitor y $vg/$lv1
+lvs -a -o+devices $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+_wait_recalc $vg/${lv1}_rimage_3
+aux wait_for_sync $vg $lv1
+_add_new_data_to_mnt
+
+aux disable_dev "$dev1"
+
+# wait for dmeventd to call lvconvert --repair which should
+# replace dev1 with dev5
+sleep 5
+
+lvs -a -o+devices $vg > out
+cat out
+not grep "$dev1" out
+grep "$dev5" out
+
+_add_more_data_to_mnt
+_verify_data_on_mnt
+
+aux enable_dev "$dev1"
+
+lvs -a -o+devices $vg > out
+cat out
+not grep "$dev1" out
+grep "$dev5" out
+
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
new file mode 100644
index 000000000..0c36e4d54
--- /dev/null
+++ b/test/shell/integrity-large.sh
@@ -0,0 +1,175 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test writecache usage
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_integrity 1 5 0 || skip
+which mkfs.xfs || skip
+
+mnt="mnt"
+mkdir -p $mnt
+
+# raid1 LV needs to be extended to 512MB to test imeta being exended
+aux prepare_devs 4 600
+
+for i in `seq 1 16384`; do echo -n "A" >> fileA; done
+for i in `seq 1 16384`; do echo -n "B" >> fileB; done
+for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+
+# generate random data
+dd if=/dev/urandom of=randA bs=512K count=2
+dd if=/dev/urandom of=randB bs=512K count=3
+dd if=/dev/urandom of=randC bs=512K count=4
+
+_prepare_vg() {
+	vgcreate $SHARED $vg "$dev1" "$dev2"
+	pvs
+}
+
+_add_data_to_lv() {
+	mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# add original data
+	cp randA $mnt
+	cp randB $mnt
+	cp randC $mnt
+	mkdir $mnt/1
+	cp fileA $mnt/1
+	cp fileB $mnt/1
+	cp fileC $mnt/1
+	mkdir $mnt/2
+	cp fileA $mnt/2
+	cp fileB $mnt/2
+	cp fileC $mnt/2
+
+	umount $mnt
+}
+
+_verify_data_on_lv() {
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	diff randA $mnt/randA
+	diff randB $mnt/randB
+	diff randC $mnt/randC
+	diff fileA $mnt/1/fileA
+	diff fileB $mnt/1/fileB
+	diff fileC $mnt/1/fileC
+	diff fileA $mnt/2/fileA
+	diff fileB $mnt/2/fileB
+	diff fileC $mnt/2/fileC
+
+	umount $mnt
+}
+
+_sync_percent() {
+	local checklv=$1
+	get lv_field "$checklv" sync_percent | cut -d. -f1
+}
+
+_wait_recalc() {
+	local checklv=$1
+
+	for i in $(seq 1 10) ; do
+		sync=$(_sync_percent "$checklv")
+		echo "sync_percent is $sync"
+
+		if test "$sync" = "100"; then
+			return
+		fi
+
+		sleep 1
+	done
+
+	echo "timeout waiting for recalc"
+	return 1
+}
+
+# lvextend to 512MB is needed for the imeta LV to
+# be extended from 4MB to 8MB.
+
+_prepare_vg
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+_add_data_to_lv
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_verify_data_on_lv
+lvchange -an $vg/$lv1
+lvextend -L 512M $vg/$lv1
+lvs -a -o+devices $vg
+lvchange -ay $vg/$lv1
+_verify_data_on_lv
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+check lv_field $vg/${lv1}_rimage_0_imeta size "8.00m"
+check lv_field $vg/${lv1}_rimage_1_imeta size "8.00m"
+
+# provide space to extend the images onto new devs
+vgextend $vg "$dev3" "$dev4"
+
+# extending the images is possible using dev3,dev4
+# but extending imeta on the existing dev1,dev2 fails
+not lvextend -L +512M $vg/$lv1
+
+# removing integrity will permit extending the images
+# using dev3,dev4 since imeta limitation is gone
+lvconvert --raidintegrity n $vg/$lv1
+lvextend -L +512M $vg/$lv1
+lvs -a -o+devices $vg
+
+# adding integrity again will allocate new 12MB imeta LVs
+# on dev3,dev4
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+check lv_field $vg/${lv1}_rimage_0_imeta size "12.00m"
+check lv_field $vg/${lv1}_rimage_1_imeta size "12.00m"
+
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
+# this succeeds because dev1,dev2 can hold rmeta+rimage
+lvcreate --type raid1 -n $lv1 -L 592M -an $vg "$dev1" "$dev2"
+
+# this fails because dev1,dev2 can hold rmeta+rimage, but not imeta
+# and we require imeta to be on same devs as rmeta/rimeta
+not lvcreate --type raid1 --raidintegrity y -n $lv1 -L 592M -an $vg "$dev1" "$dev2"
+lvs -a -o+devices $vg
+lvremove $vg/$lv1
+
+# this can allocate from more devs so there's enough space for imeta to
+# be allocated in the vg, but lvcreate fails because rmeta+rimage are
+# allocated from dev1,dev2, we restrict imeta to being allocated on the
+# same devs as rmeta/rimage, and dev1,dev2 can't fit imeta.
+not lvcreate --type raid1 --raidintegrity y -n $lv1 -L 592M -an $vg
+lvs -a -o+devices $vg
+
+# counterintuitively, increasing the size will allow lvcreate to succeed
+# because rmeta+rimage are pushed to being allocated on dev1,dev2,dev3,dev4
+# which means imeta is now free to be allocated from dev3,dev4 which have
+# plenty of space
+lvcreate --type raid1 --raidintegrity y -n $lv1 -L 600M -an $vg
+lvs -a -o+devices $vg
+
+vgremove -ff $vg
+
diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
new file mode 100644
index 000000000..73b0a67d8
--- /dev/null
+++ b/test/shell/integrity-misc.sh
@@ -0,0 +1,228 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_integrity 1 5 0 || skip
+which mkfs.xfs || skip
+
+mnt="mnt"
+mkdir -p $mnt
+
+aux prepare_devs 5 64
+
+for i in `seq 1 16384`; do echo -n "A" >> fileA; done
+for i in `seq 1 16384`; do echo -n "B" >> fileB; done
+for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+
+# generate random data
+dd if=/dev/urandom of=randA bs=512K count=2
+dd if=/dev/urandom of=randB bs=512K count=3
+dd if=/dev/urandom of=randC bs=512K count=4
+
+_prepare_vg() {
+	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+	pvs
+}
+
+_add_new_data_to_mnt() {
+        mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+
+        mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+        # add original data
+        cp randA $mnt
+        cp randB $mnt
+        cp randC $mnt
+        mkdir $mnt/1
+        cp fileA $mnt/1
+        cp fileB $mnt/1
+        cp fileC $mnt/1
+        mkdir $mnt/2
+        cp fileA $mnt/2
+        cp fileB $mnt/2
+        cp fileC $mnt/2
+}
+
+_add_more_data_to_mnt() {
+        mkdir $mnt/more
+        cp fileA $mnt/more
+        cp fileB $mnt/more
+        cp fileC $mnt/more
+        cp randA $mnt/more
+        cp randB $mnt/more
+        cp randC $mnt/more
+}
+
+_verify_data_on_mnt() {
+	diff randA $mnt/randA
+	diff randB $mnt/randB
+	diff randC $mnt/randC
+	diff fileA $mnt/1/fileA
+	diff fileB $mnt/1/fileB
+	diff fileC $mnt/1/fileC
+	diff fileA $mnt/2/fileA
+	diff fileB $mnt/2/fileB
+	diff fileC $mnt/2/fileC
+}
+
+_verify_data_on_lv() {
+        lvchange -ay $vg/$lv1
+        mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+        _verify_data_on_mnt
+        rm $mnt/randA
+        rm $mnt/randB
+        rm $mnt/randC
+        rm -rf $mnt/1
+        rm -rf $mnt/2
+        umount $mnt
+        lvchange -an $vg/$lv1
+}
+
+_sync_percent() {
+	local checklv=$1
+	get lv_field "$checklv" sync_percent | cut -d. -f1
+}
+
+_wait_recalc() {
+	local checklv=$1
+
+	for i in $(seq 1 10) ; do
+		sync=$(_sync_percent "$checklv")
+		echo "sync_percent is $sync"
+
+		if test "$sync" = "100"; then
+			return
+		fi
+
+		sleep 1
+	done
+
+	echo "timeout waiting for recalc"
+	return 1
+}
+
+# lvrename
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+umount $mnt
+lvrename $vg/$lv1 $vg/$lv2
+mount "$DM_DEV_DIR/$vg/$lv2" $mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv2
+lvremove $vg/$lv2
+vgremove -ff $vg
+
+# lvconvert --replace
+# an existing dev is replaced with another dev
+# lv must be active
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+lvconvert --replace "$dev1" $vg/$lv1 "$dev3"
+lvs -a -o+devices $vg > out
+cat out
+grep "$dev2" out
+grep "$dev3" out
+not grep "$dev1" out
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# lvconvert --replace
+# same as prev but with bitmap mode
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg "$dev1" "$dev2"
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+lvconvert --replace "$dev1" $vg/$lv1 "$dev3"
+lvs -a -o+devices $vg > out
+cat out
+grep "$dev2" out
+grep "$dev3" out
+not grep "$dev1" out
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# lvconvert --repair
+# while lv is active a device goes missing (with rimage,rmeta,imeta,orig).
+# lvconvert --repair should replace the missing dev with another,
+# (like lvconvert --replace does for a dev that's not missing).
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+aux disable_dev "$dev2"
+lvs -a -o+devices $vg > out
+cat out
+grep unknown out
+lvconvert -vvvv -y --repair $vg/$lv1
+lvs -a -o+devices $vg > out
+cat out
+not grep "$dev2" out
+not grep unknown out
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+aux enable_dev "$dev2"
+vgremove -ff $vg
+
+# lvchange activationmode
+# a device is missing (with rimage,rmeta,imeta,iorig), the lv
+# is already inactive, and it cannot be activated, with
+# activationmode degraded or partial, or in any way,
+# until integrity is removed.
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg "$dev1" "$dev2"
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+aux disable_dev "$dev2"
+lvs -a -o+devices $vg
+not lvchange -ay $vg/$lv1
+not lvchange -ay --activationmode degraded $vg/$lv1
+not lvchange -ay --activationmode partial $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvchange -ay --activationmode degraded $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+aux enable_dev "$dev2"
+vgremove -ff $vg
+
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
new file mode 100644
index 000000000..7e4f2cb0b
--- /dev/null
+++ b/test/shell/integrity.sh
@@ -0,0 +1,735 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_integrity 1 5 0 || skip
+which mkfs.xfs || skip
+which xfs_growfs || skip
+
+mnt="mnt"
+mkdir -p $mnt
+
+aux prepare_devs 5 64
+
+for i in `seq 1 16384`; do echo -n "A" >> fileA; done
+for i in `seq 1 16384`; do echo -n "B" >> fileB; done
+for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+
+# generate random data
+dd if=/dev/urandom of=randA bs=512K count=2
+dd if=/dev/urandom of=randB bs=512K count=3
+dd if=/dev/urandom of=randC bs=512K count=4
+
+_prepare_vg() {
+	# zero devs so we are sure to find the correct file data
+	# on the underlying devs when corrupting it
+	dd if=/dev/zero of="$dev1" || true
+	dd if=/dev/zero of="$dev2" || true
+	dd if=/dev/zero of="$dev3" || true
+	dd if=/dev/zero of="$dev4" || true
+	dd if=/dev/zero of="$dev5" || true
+	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+	pvs
+}
+
+_test_fs_with_error() {
+	mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# add original data
+	cp fileA $mnt
+	cp fileB $mnt
+	cp fileC $mnt
+
+	umount $mnt
+	lvchange -an $vg/$lv1
+
+	# corrupt the original data on the underying dev
+	# flip one bit in fileB, changing a 0x42 to 0x43
+	# the bit is changed in the last 4096 byte block
+	# of the file, so when reading back the file we
+	# will get the first three 4096 byte blocks, for
+	# a total of 12288 bytes before getting an error
+	# on the last 4096 byte block.
+	xxd "$dev1" > dev1.txt
+	tac dev1.txt > dev1.rev
+	sed -e '0,/4242 4242 4242 4242 4242 4242 4242 4242/ s/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.rev > dev1.rev.bad
+	tac dev1.rev.bad > dev1.bad
+	xxd -r dev1.bad > "$dev1"
+	rm dev1.txt dev1.rev dev1.rev.bad dev1.bad
+
+	lvchange -ay $vg/$lv1
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# read complete fileA which was not corrupted
+	dd if=$mnt/fileA of=tmp bs=1k
+	ls -l tmp
+	stat -c %s tmp
+	diff fileA tmp
+	rm tmp
+
+	# read partial fileB which was corrupted
+	not dd if=$mnt/fileB of=tmp bs=1k
+	ls -l tmp
+	stat -c %s tmp | grep 12288
+	not diff fileB tmp
+	rm tmp
+
+	umount $mnt
+}
+
+_test_fs_with_raid() {
+	mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# add original data
+	cp fileA $mnt
+	cp fileB $mnt
+	cp fileC $mnt
+
+	umount $mnt
+	lvchange -an $vg/$lv1
+
+	xxd "$dev1" > dev1.txt
+	tac dev1.txt > dev1.rev
+	sed -e '0,/4242 4242 4242 4242 4242 4242 4242 4242/ s/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.rev > dev1.rev.bad
+	tac dev1.rev.bad > dev1.bad
+	xxd -r dev1.bad > "$dev1"
+	rm dev1.txt dev1.rev dev1.rev.bad dev1.bad
+
+	lvchange -ay $vg/$lv1
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# read complete fileA which was not corrupted
+	dd if=$mnt/fileA of=tmp bs=1k
+	ls -l tmp
+	stat -c %s tmp | grep 16384
+	diff fileA tmp
+	rm tmp
+
+	# read complete fileB, corruption is corrected by raid
+	dd if=$mnt/fileB of=tmp bs=1k
+	ls -l tmp
+	stat -c %s tmp | grep 16384
+	diff fileB tmp
+	rm tmp
+
+	umount $mnt
+}
+
+_add_new_data_to_mnt() {
+	mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
+
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+
+	# add original data
+	cp randA $mnt
+	cp randB $mnt
+	cp randC $mnt
+	mkdir $mnt/1
+	cp fileA $mnt/1
+	cp fileB $mnt/1
+	cp fileC $mnt/1
+	mkdir $mnt/2
+	cp fileA $mnt/2
+	cp fileB $mnt/2
+	cp fileC $mnt/2
+}
+
+_add_more_data_to_mnt() {
+	mkdir $mnt/more
+	cp fileA $mnt/more
+	cp fileB $mnt/more
+	cp fileC $mnt/more
+	cp randA $mnt/more
+	cp randB $mnt/more
+	cp randC $mnt/more
+}
+
+_verify_data_on_mnt() {
+	diff randA $mnt/randA
+	diff randB $mnt/randB
+	diff randC $mnt/randC
+	diff fileA $mnt/1/fileA
+	diff fileB $mnt/1/fileB
+	diff fileC $mnt/1/fileC
+	diff fileA $mnt/2/fileA
+	diff fileB $mnt/2/fileB
+	diff fileC $mnt/2/fileC
+}
+
+_verify_data_on_lv() {
+	lvchange -ay $vg/$lv1
+	mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+	_verify_data_on_mnt
+	rm $mnt/randA
+	rm $mnt/randB
+	rm $mnt/randC
+	rm -rf $mnt/1
+	rm -rf $mnt/2
+	umount $mnt
+	lvchange -an $vg/$lv1
+}
+
+_sync_percent() {
+	local checklv=$1
+	get lv_field "$checklv" sync_percent | cut -d. -f1
+}
+
+_wait_recalc() {
+	local checklv=$1
+
+	for i in $(seq 1 10) ; do
+		sync=$(_sync_percent "$checklv")
+		echo "sync_percent is $sync"
+
+		if test "$sync" = "100"; then
+			return
+		fi
+
+		sleep 1
+	done
+
+	echo "timeout waiting for recalc"
+	return 1
+}
+
+# Test corrupting data on an image and verifying that
+# it is detected by integrity and corrected by raid.
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_test_fs_with_raid
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
+_test_fs_with_raid
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
+_test_fs_with_raid
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+_test_fs_with_raid
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
+_test_fs_with_raid
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
+_test_fs_with_raid
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test removing integrity from an active LV
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+lvconvert --raidintegrity n $vg/$lv1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid4 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+lvconvert --raidintegrity n $vg/$lv1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+lvconvert --raidintegrity n $vg/$lv1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+lvconvert --raidintegrity n $vg/$lv1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+lvconvert --raidintegrity n $vg/$lv1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test adding integrity to an active LV
+
+_prepare_vg
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+_add_new_data_to_mnt
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid4 -n $lv1 -l 8 $vg
+_add_new_data_to_mnt
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid5 -n $lv1 -l 8 $vg
+_add_new_data_to_mnt
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid6 -n $lv1 -l 8 $vg
+_add_new_data_to_mnt
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid10 -n $lv1 -l 8 $vg
+_add_new_data_to_mnt
+lvconvert --raidintegrity y $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test lvextend while inactive
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+lvextend -l 16 $vg/$lv1
+lvchange -ay $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+xfs_growfs $mnt
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid6 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+lvextend -l 16 $vg/$lv1
+lvchange -ay $vg/$lv1
+mount "$DM_DEV_DIR/$vg/$lv1" $mnt
+xfs_growfs $mnt
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test lvextend while active
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+lvextend -l 16 $vg/$lv1
+xfs_growfs $mnt
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid5 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+lvextend -l 16 $vg/$lv1
+xfs_growfs $mnt
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid10 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+lvextend -l 16 $vg/$lv1
+xfs_growfs $mnt
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test adding image to raid1
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+lvconvert -y -m+1 $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+lvs -a -o+devices $vg
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test removing image from raid1
+
+_prepare_vg
+lvcreate --type raid1 -m2 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+lvconvert -y -m-1 $vg/$lv1
+lvs -a -o+devices $vg
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test disallowed operations on raid+integrity
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+not lvconvert -y -m-1 $vg/$lv1
+not lvconvert --splitmirrors 1 -n tmp -y $vg/$lv1
+not lvconvert --splitmirrors 1 --trackchanges -y $vg/$lv1
+not lvchange --syncaction check $vg/$lv1
+not lvchange --syncaction repair $vg/$lv1
+not lvreduce -L4M $vg/$lv1
+not lvcreate -s -n snap -L4M $vg/$lv1
+not pvmove -n $vg/$lv1 "$dev1"
+not pvmove "$dev1"
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Repeat many of the tests above using bitmap mode
+
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+_test_fs_with_raid
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+_prepare_vg
+lvcreate --type raid6 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+_test_fs_with_raid
+lvchange -an $vg/$lv1
+lvconvert --raidintegrity n $vg/$lv1
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# remove from active lv
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_new_data_to_mnt
+lvconvert --raidintegrity n $vg/$lv1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# add to active lv
+_prepare_vg
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+_add_new_data_to_mnt
+lvconvert --raidintegrity y --raidintegritymode bitmap $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# lvextend active
+_prepare_vg
+lvcreate --type raid1 --raidintegrity y --raidintegritymode bitmap -m1 -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+lvextend -l 16 $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+xfs_growfs $mnt
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# add image to raid1
+_prepare_vg
+lvcreate --type raid1 -m1 --raidintegrity y --raidintegritymode bitmap -n $lv1 -l 8 $vg
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+lvs -a -o+devices $vg
+_add_new_data_to_mnt
+lvconvert -y -m+1 $vg/$lv1
+_wait_recalc $vg/${lv1}_rimage_0
+_wait_recalc $vg/${lv1}_rimage_1
+_wait_recalc $vg/${lv1}_rimage_2
+lvs -a -o+devices $vg
+_add_more_data_to_mnt
+_verify_data_on_mnt
+umount $mnt
+lvchange -an $vg/$lv1
+_verify_data_on_lv
+lvremove $vg/$lv1
+vgremove -ff $vg
+
+# Test that raid+integrity cannot be a sublv
+# part1: cannot add integrity to a raid LV that is already a sublv
+
+_prepare_vg
+
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvconvert -y --type thin-pool $vg/$lv1
+not lvconvert --raidintegrity y $vg/$lv1
+not lvconvert --raidintegrity y $vg/${lv1}_tdata
+not lvconvert --raidintegrity y $vg/${lv1}_tmeta
+lvremove -y $vg/$lv1
+
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvconvert -y --type cache-pool $vg/$lv1
+not lvconvert --raidintegrity y $vg/$lv1
+not lvconvert --raidintegrity y $vg/${lv1}_cdata
+not lvconvert --raidintegrity y $vg/${lv1}_cmeta
+lvremove -y $vg/$lv1
+
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvcreate --type cache-pool -n cpool -l 8 $vg
+lvconvert -y --type cache --cachepool cpool $vg/$lv1
+not lvconvert --raidintegrity y $vg/$lv1
+not lvconvert --raidintegrity y $vg/${lv1}_corig
+lvremove -y $vg/$lv1
+
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m1 -n cvol -l 8 $vg
+lvconvert -y --type cache --cachevol cvol $vg/$lv1
+not lvconvert --raidintegrity y $vg/$lv1
+not lvconvert --raidintegrity y $vg/${lv1}_corig
+not lvconvert --raidintegrity y $vg/cvol
+lvremove -y $vg/$lv1
+
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvcreate -n cvol -l 8 $vg
+lvchange -an $vg
+lvconvert -y --type writecache --cachevol cvol $vg/$lv1
+not lvconvert --raidintegrity y $vg/$lv1
+not lvconvert --raidintegrity y $vg/${lv1}_wcorig
+lvremove -y $vg/$lv1
+
+# Test that raid+integrity cannot be a sublv
+# part2: cannot convert an existing raid+integrity LV into a sublv
+
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvconvert -y --type thin-pool $vg/$lv1
+not lvconvert --raidintegrity y $vg/${lv1}_tdata
+lvremove -y $vg/$lv1
+
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m1 -n $lv2 -l 8 $vg
+lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
+not lvconvert --raidintegrity y $vg/${lv1}_corig
+not lvconvert --raidintegrity y $vg/${lv2}_vol
+lvremove -y $vg/$lv1
+
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvcreate --type raid1 -m1 -n $lv2 -l 8 $vg
+lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+not lvconvert --raidintegrity y $vg/${lv1}_corig
+not lvconvert --raidintegrity y $vg/${lv2}_cpool_cdata
+lvremove -y $vg/$lv1
+
+# cannot add integrity to raid that has a snapshot
+
+lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
+lvcreate -s -n $lv2 -l 8 $vg/$lv1
+not lvconvert --raidintegrity y $vg/$lv1
+lvremove -y $vg/$lv1
+
+vgremove -ff $vg
diff --git a/tools/args.h b/tools/args.h
index 999d891f7..d1f604b0c 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -512,6 +512,26 @@ arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", pvmetadatacopies_VAL, 0, 0,
     "This may be useful in VGs containing many PVs (this places limitations\n"
     "on the ability to use vgsplit later.)\n")
 
+arg(raidintegrity_ARG, '\0', "raidintegrity", bool_VAL, 0, 0,
+    "Enable or disable data integrity checksums for raid images.\n")
+
+arg(raidintegrityblocksize_ARG, '\0', "raidintegrityblocksize", number_VAL, 0, 0,
+    "The block size to use for dm-integrity on raid images.\n"
+    "The integrity block size should usually match the device\n"
+    "logical block size, or the file system block size.\n"
+    "It may be less than the file system block size, but not\n"
+    "less than the device logical block size.\n"
+    "Possible values: 512, 1024, 2048, 4096.\n")
+
+arg(raidintegritymode_ARG, '\0', "raidintegritymode", string_VAL, 0, 0,
+    "Use a journal (default) or bitmap for keeping integrity checksums consistent\n"
+    "in case of a crash. The bitmap areas are recalculated after a crash, so corruption\n"
+    "in those areas would not be detected. A journal does not have this problem.\n"
+    "The journal mode doubles writes to storage, but can improve performance for\n"
+    "scattered writes packed into a single journal write.\n"
+    "bitmap mode can in theory achieve full write throughput of the device,\n"
+    "but would not benefit from the potential scattered write optimization.\n")
+
 arg(readonly_ARG, '\0', "readonly", 0, 0, 0,
     "Run the command in a special read-only mode which will read on-disk\n"
     "metadata without needing to take any locks. This can be used to peek\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 37a01cb55..ed3d0413a 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -262,7 +262,7 @@ IO: --ignoreskippedcluster
 ID: lvchange_resync
 DESC: Resyncronize a mirror or raid LV.
 DESC: Use to reset 'R' attribute on a not initially synchronized LV.
-RULE: all not lv_is_pvmove lv_is_locked
+RULE: all not lv_is_pvmove lv_is_locked lv_is_raid_with_integrity
 RULE: all not LV_raid0
 
 lvchange --syncaction SyncAction VG|LV_raid|Tag|Select ...
@@ -359,7 +359,7 @@ OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to raid or change raid layout
 DESC: (a specific raid level must be used, e.g. raid1).
-RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not lv_is_locked lv_is_pvmove lv_is_raid_with_integrity
 
 lvconvert --mirrors SNumber LV
 OO: --regionsize RegionSize, --interval Number, --mirrorlog MirrorLog, OO_LVCONVERT
@@ -373,21 +373,21 @@ OO: OO_LVCONVERT, --interval Number, --regionsize RegionSize, --stripesize SizeK
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert raid LV to change number of stripe images.
-RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not lv_is_locked lv_is_pvmove lv_is_raid_with_integrity
 RULE: all not LV_raid0 LV_raid1
 
 lvconvert --stripesize SizeKB LV_raid
 OO: OO_LVCONVERT, --interval Number, --regionsize RegionSize
 ID: lvconvert_raid_types
 DESC: Convert raid LV to change the stripe size.
-RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not lv_is_locked lv_is_pvmove lv_is_raid_with_integrity
 RULE: all not LV_raid0 LV_raid1
 
 lvconvert --regionsize RegionSize LV_raid
 OO: OO_LVCONVERT
 ID: lvconvert_change_region_size
 DESC: Change the region size of an LV.
-RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not lv_is_locked lv_is_pvmove lv_is_raid_with_integrity
 RULE: all not LV_raid0
 FLAGS: SECONDARY_SYNTAX
 
@@ -401,20 +401,20 @@ OO: OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_split_mirror_images
 DESC: Split images from a raid1 or mirror LV and use them to create a new LV.
-RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not lv_is_locked lv_is_pvmove lv_is_raid_with_integrity
 
 lvconvert --splitmirrors Number --trackchanges LV_raid1_cache
 OO: OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_split_mirror_images
 DESC: Split images from a raid1 LV and track changes to origin for later merge.
-RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not lv_is_locked lv_is_pvmove lv_is_raid_with_integrity
 
 lvconvert --mergemirrors LV_linear_raid|VG|Tag ...
 OO: OO_LVCONVERT
 ID: lvconvert_merge_mirror_images
 DESC: Merge LV images that were split from a raid1 LV.
-RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
+RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow lv_is_raid_with_integrity
 
 lvconvert --mirrorlog MirrorLog LV_mirror
 OO: OO_LVCONVERT
@@ -434,7 +434,7 @@ OO: --thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin.
 RULE: all and lv_is_visible
-RULE: all not lv_is_locked
+RULE: all not lv_is_locked lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type thin
@@ -445,7 +445,7 @@ DESC: Convert LV to a thin LV, using the original LV as an external origin
 DESC: (infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 RULE: all and lv_is_visible
-RULE: all not lv_is_locked
+RULE: all not lv_is_locked lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 ---
@@ -455,6 +455,7 @@ OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_with_cachepool
 DESC: Attach a cache pool to an LV, converts the LV to type cache.
 RULE: all and lv_is_visible
+RULE: all not lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # alternate form of lvconvert --type cache
@@ -463,6 +464,7 @@ OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_with_cachepool
 DESC: Attach a cache pool to an LV (infers --type cache).
 RULE: all and lv_is_visible
+RULE: all not lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 FLAGS: SECONDARY_SYNTAX
 
@@ -473,6 +475,7 @@ OO: OO_LVCONVERT, --cachesettings String
 ID: lvconvert_to_writecache
 DESC: Attach a writecache to an LV, converts the LV to type writecache.
 RULE: all and lv_is_visible
+RULE: all not lv_is_raid_with_integrity
 
 ---
 
@@ -481,6 +484,7 @@ OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT, --poolmetadatasize SizeMB, --chun
 ID: lvconvert_to_cache_with_cachevol
 DESC: Attach a cache to an LV, converts the LV to type cache.
 RULE: all and lv_is_visible
+RULE: all not lv_is_raid_with_integrity
 
 # alternate form of lvconvert --type cache
 lvconvert --cache --cachevol LV LV_linear_striped_raid_thinpool
@@ -488,6 +492,7 @@ OO: OO_LVCONVERT_CACHE, OO_LVCONVERT, --poolmetadatasize SizeMB, --chunksize Siz
 ID: lvconvert_to_cache_with_cachevol
 DESC: Attach a cache to an LV, converts the LV to type cache.
 RULE: all and lv_is_visible
+RULE: all not lv_is_raid_with_integrity
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -499,7 +504,7 @@ OP: PV ...
 ID: lvconvert_to_thinpool
 DESC: Convert LV to type thin-pool.
 RULE: all and lv_is_visible
-RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual
+RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 # This command syntax has two different meanings depending on
@@ -533,6 +538,7 @@ DESC: Convert LV to type thin-pool (variant, use --type thin-pool).
 DESC: Swap metadata LV in a thin pool (variant, use --swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
 RULE: all and lv_is_visible
+RULE: all not lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 ---
@@ -543,6 +549,7 @@ OP: PV ...
 ID: lvconvert_to_cachepool
 DESC: Convert LV to type cache-pool.
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
+RULE: all not lv_is_raid_with_integrity
 
 # This command syntax has two different meanings depending on
 # whether the LV pos arg is already a cache pool or not.
@@ -574,6 +581,7 @@ DESC: Convert LV to type cache-pool (variant, use --type cache-pool).
 DESC: Swap metadata LV in a cache pool (variant, use --swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
 RULE: all and lv_is_visible
+RULE: all not lv_is_raid_with_integrity
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 ---
@@ -583,7 +591,7 @@ OO: --name LV_new, --virtualsize SizeMB, --compression Bool, --deduplication Boo
 ID: lvconvert_to_vdopool
 DESC: Convert LV to type vdopool.
 RULE: all and lv_is_visible
-RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual
+RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual lv_is_raid_with_integrity
 
 lvconvert --vdopool LV_linear_striped_raid_cache
 OO: --type vdo-pool, OO_LVCONVERT,
@@ -591,7 +599,7 @@ OO: --type vdo-pool, OO_LVCONVERT,
 ID: lvconvert_to_vdopool_param
 DESC: Convert LV to type vdopool.
 RULE: all and lv_is_visible
-RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual
+RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual lv_is_raid_with_integrity
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -757,6 +765,14 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
+lvconvert --raidintegrity Bool LV_raid
+OO: --raidintegritymode String, --raidintegrityblocksize Number, OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_integrity
+DESC: Add or remove data integrity checksums to raid images.
+
+---
+
 # --extents is not specified; it's an automatic alternative for --size
 
 OO_LVCREATE: --addtag Tag, --alloc Alloc, --autobackup Bool, --activate Active,
@@ -870,7 +886,8 @@ DESC: Create a raid1 or mirror LV (infers --type raid1|mirror).
 # R9,R10,R11,R12 (--type raid with any use of --stripes/--mirrors)
 lvcreate --type raid --size SizeMB VG
 OO: --mirrors PNumber, --stripes Number, --stripesize SizeKB,
---regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
+--regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB,
+--raidintegrity Bool, --raidintegritymode String, --raidintegrityblocksize Number, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_raid_any
 DESC: Create a raid LV (a specific raid level must be used, e.g. raid1).
diff --git a/tools/lv_props.h b/tools/lv_props.h
index 292502889..60c8c73f2 100644
--- a/tools/lv_props.h
+++ b/tools/lv_props.h
@@ -52,5 +52,6 @@ lvp(is_cow_covering_origin_LVP, "lv_is_cow_covering_origin", NULL)
 lvp(is_visible_LVP, "lv_is_visible", NULL)
 lvp(is_historical_LVP, "lv_is_historical", NULL)
 lvp(is_raid_with_tracking_LVP, "lv_is_raid_with_tracking", NULL)
+lvp(is_raid_with_integrity_LVP, "lv_is_raid_with_integrity", NULL)
 lvp(LVP_COUNT, "", NULL)
 
diff --git a/tools/lv_types.h b/tools/lv_types.h
index 778cd541d..d1c94ccd8 100644
--- a/tools/lv_types.h
+++ b/tools/lv_types.h
@@ -34,5 +34,6 @@ lvt(raid10_LVT, "raid10", NULL)
 lvt(error_LVT, "error", NULL)
 lvt(zero_LVT, "zero", NULL)
 lvt(writecache_LVT, "writecache", NULL)
+lvt(integrity_LVT, "integrity", NULL)
 lvt(LVT_COUNT, "", NULL)
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 5f0fcab81..2d5bb32be 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1573,6 +1573,11 @@ static int _lvchange_syncaction_single(struct cmd_context *cmd,
 				       struct logical_volume *lv,
 				       struct processing_handle *handle)
 {
+	if (lv_raid_has_integrity(lv)) {
+		log_error("Integrity must be removed to use syncaction commands.");
+		return_ECMD_FAILED;
+	}
+
 	/* If LV is inactive here, ensure it's not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))
 		return_ECMD_FAILED;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index bb40930cb..e969b4459 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1391,11 +1391,23 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 					  DEFAULT_RAID1_MAX_IMAGES, lp->segtype->name, display_lvname(lv));
 				return 0;
 			}
+			if (!seg_is_raid1(seg) && lv_raid_has_integrity(lv)) {
+				log_error("Cannot add raid images with integrity for this raid level.");
+				return 0;
+			}
 			if (!lv_raid_change_image_count(lv, lp->yes, image_count,
 							(lp->region_size_supplied || !seg->region_size) ?
 							lp->region_size : seg->region_size , lp->pvh))
 				return_0;
 
+			if (lv_raid_has_integrity(lv)) {
+				struct integrity_settings *isettings = NULL;
+				if (!lv_get_raid_integrity_settings(lv, &isettings))
+					return_0;
+				if (!lv_add_integrity_to_raid(lv, isettings, lp->pvh, NULL))
+					return_0;
+			}
+
 			log_print_unless_silent("Logical volume %s successfully converted.",
 						display_lvname(lv));
 
@@ -1425,6 +1437,12 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
+		if (lv_raid_has_integrity(lv)) {
+			/* FIXME: which conversions are happening here? */
+			log_error("This conversion is not supported for raid with integrity.");
+			return 0;
+		}
+
 		/* FIXME This needs changing globally. */
 		if (!arg_is_set(cmd, stripes_long_ARG))
 			lp->stripes = 0;
@@ -1444,6 +1462,12 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	}
 
 try_new_takeover_or_reshape:
+	if (lv_raid_has_integrity(lv)) {
+		/* FIXME: which conversions are happening here? */
+		log_error("This conversion is not supported for raid with integrity.");
+		return 0;
+	}
+
 	if (!_raid4_conversion_supported(lv, lp))
 		return 0;
 
@@ -5758,6 +5782,119 @@ int lvconvert_to_cache_with_cachevol_cmd(struct cmd_context *cmd, int argc, char
 	return ret;
 }
 
+static int _lvconvert_integrity_remove(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	struct volume_group *vg = lv->vg;
+	int ret = 0;
+
+	if (!lv_is_integrity(lv) && !lv_is_raid(lv)) {
+		log_error("LV does not have integrity.");
+		return 0;
+	}
+
+	/* ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_0;
+
+	if (!archive(vg))
+		return_0;
+
+	if (lv_is_raid(lv))
+		ret = lv_remove_integrity_from_raid(lv);
+	if (!ret)
+		return_0;
+
+	backup(vg);
+
+	log_print_unless_silent("Logical volume %s has removed integrity.", display_lvname(lv));
+	return 1;
+}
+
+static int _lvconvert_integrity_add(struct cmd_context *cmd, struct logical_volume *lv,
+				    struct integrity_settings *set)
+{
+	struct volume_group *vg = lv->vg;
+	struct dm_list *use_pvh;
+	int ret = 0;
+
+	/* ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_0;
+
+	if (cmd->position_argc > 1) {
+		/* First pos arg is required LV, remaining are optional PVs. */
+		if (!(use_pvh = create_pv_list(cmd->mem, vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))
+			return_0;
+	} else
+		use_pvh = &vg->pvs;
+
+	if (!archive(vg))
+		return_0;
+
+	if (lv_is_partial(lv)) {
+		log_error("Cannot add integrity while LV is missing PVs.");
+		return 0;
+	}
+
+	if (lv_is_raid(lv))
+		ret = lv_add_integrity_to_raid(lv, set, use_pvh, NULL);
+	if (!ret)
+		return_0;
+
+	backup(vg);
+
+	log_print_unless_silent("Logical volume %s has added integrity.", display_lvname(lv));
+	return 1;
+}
+
+static int _lvconvert_integrity_single(struct cmd_context *cmd,
+					struct logical_volume *lv,
+					struct processing_handle *handle)
+{
+	struct integrity_settings settings;
+	int ret = 0;
+
+	memset(&settings, 0, sizeof(settings));
+
+	if (!integrity_mode_set(arg_str_value(cmd, raidintegritymode_ARG, NULL), &settings))
+		return_ECMD_FAILED;
+
+	if (arg_is_set(cmd, raidintegrityblocksize_ARG))
+		settings.block_size = arg_int_value(cmd, raidintegrityblocksize_ARG, 0);
+
+	if (arg_int_value(cmd, raidintegrity_ARG, 0))
+		ret = _lvconvert_integrity_add(cmd, lv, &settings);
+	else
+		ret = _lvconvert_integrity_remove(cmd, lv);
+
+	if (!ret)
+		return ECMD_FAILED;
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_integrity_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	int ret;
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	/* Want to be able to remove integrity from partial LV */
+	cmd->handles_missing_pvs = 1;
+
+	cmd->cname->flags &= ~GET_VGNAME_FROM_OPTIONS;
+
+	ret = process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE, handle, NULL,
+			      &_lvconvert_integrity_single);
+
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
 /*
  * All lvconvert command defs have their own function,
  * so the generic function name is unused.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 448f12588..5c978b3cc 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -858,7 +858,10 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	maxrecoveryrate_ARG,\
 	minrecoveryrate_ARG,\
 	raidmaxrecoveryrate_ARG,\
-	raidminrecoveryrate_ARG
+	raidminrecoveryrate_ARG, \
+	raidintegrity_ARG, \
+	raidintegritymode_ARG, \
+	raidintegrityblocksize_ARG
 
 #define SIZE_ARGS \
 	extents_ARG,\
@@ -1227,6 +1230,16 @@ static int _lvcreate_params(struct cmd_context *cmd,
 		}
 	}
 
+	if (seg_is_raid(lp) && arg_int_value(cmd, raidintegrity_ARG, 0)) {
+		lp->raidintegrity = 1;
+		if (arg_is_set(cmd, raidintegrityblocksize_ARG))
+			lp->integrity_settings.block_size = arg_int_value(cmd, raidintegrityblocksize_ARG, 0);
+		if (arg_is_set(cmd, raidintegritymode_ARG)) {
+			if (!integrity_mode_set(arg_str_value(cmd, raidintegritymode_ARG, NULL), &lp->integrity_settings))
+				return_0;
+		}
+	}
+
 	lcp->pv_count = argc;
 	lcp->pvs = argv;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f147be39c..d87a8f053 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -149,6 +149,9 @@ static const struct command_function _command_functions[CMD_COUNT] = {
 	{ lvconvert_to_vdopool_CMD, lvconvert_to_vdopool_cmd },
 	{ lvconvert_to_vdopool_param_CMD, lvconvert_to_vdopool_param_cmd },
 
+	/* lvconvert for integrity */
+	{ lvconvert_integrity_CMD, lvconvert_integrity_cmd },
+
 	{ pvscan_display_CMD, pvscan_display_cmd },
 	{ pvscan_cache_CMD, pvscan_cache_cmd },
 };
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 0419a3d64..a346b5338 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -381,6 +381,11 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			return NULL;
 		}
 
+		if (lv_is_raid(lv) && lv_raid_has_integrity(lv)) {
+			log_error("Unable to pvmove device used for raid with integrity.");
+			return NULL;
+		}
+
 		seg = first_seg(lv);
 		if (!needs_exclusive) {
 			/* Presence of exclusive LV decides whether pvmove must be also exclusive */
@@ -625,6 +630,11 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 			log_error("pvmove not allowed on LV using writecache.");
 			return ECMD_FAILED;
 		}
+
+		if (lv_is_raid(lv) && lv_raid_has_integrity(lv)) {
+			log_error("pvmove not allowed on raid LV with integrity.");
+			return ECMD_FAILED;
+		}
 	}
 
 	/*
diff --git a/tools/toollib.c b/tools/toollib.c
index 6386a6906..96d0d6dff 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -718,11 +718,26 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	return 1;
 }
 
+int integrity_mode_set(const char *mode, struct integrity_settings *settings)
+{
+	if (!mode || !strcmp(mode, "bitmap") || !strcmp(mode, "B"))
+		settings->mode[0] = 'B';
+	else if (!strcmp(mode, "journal") || !strcmp(mode, "J"))
+		settings->mode[0] = 'J';
+	else {
+		/* FIXME: the kernel has other modes, should we allow any of those? */
+		log_error("Invalid raid integrity mode (use \"bitmap\" or \"journal\")");
+		return 0;
+	}
+	return 1;
+}
+
 /* Shared code for changing activation state for vgchange/lvchange */
 int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		       activation_change_t activate)
 {
 	int r = 1;
+	int integrity_recalculate;
 	struct logical_volume *snapshot_lv;
 
 	if (lv_is_cache_pool(lv)) {
@@ -780,9 +795,34 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	if ((integrity_recalculate = lv_has_integrity_recalculate_metadata(lv))) {
+		/* Don't want pvscan to write VG while running from systemd service. */
+		if (!strcmp(cmd->name, "pvscan")) {
+			log_error("Cannot activate uninitialized integrity LV %s from pvscan.",
+				  display_lvname(lv));
+			return 0;
+		}
+
+		if (vg_is_shared(lv->vg)) {
+			uint32_t lockd_state = 0;
+			if (!lockd_vg(cmd, lv->vg->name, "ex", 0, &lockd_state)) {
+				log_error("Cannot activate uninitialized integrity LV %s without lock.",
+					  display_lvname(lv));
+				return 0;
+			}
+		}
+	}
+
 	if (!lv_active_change(cmd, lv, activate))
 		return_0;
 
+	/* Write VG metadata to clear the integrity recalculate flag. */
+	if (integrity_recalculate && lv_is_active(lv)) {
+		log_print_unless_silent("Updating VG to complete initialization of integrity LV %s.",
+			  display_lvname(lv));
+		lv_clear_integrity_recalculate_metadata(lv);
+	}
+
 	set_lv_notify(lv->vg->cmd);
 
 	return r;
@@ -1144,6 +1184,7 @@ out:
 	return ok;
 }
 
+
 /* FIXME move to lib */
 static int _pv_change_tag(struct physical_volume *pv, const char *tag, int addtag)
 {
@@ -2255,6 +2296,8 @@ static int _lv_is_prop(struct cmd_context *cmd, struct logical_volume *lv, int l
 		return lv_is_historical(lv);
 	case is_raid_with_tracking_LVP:
 		return lv_is_raid_with_tracking(lv);
+	case is_raid_with_integrity_LVP:
+		return lv_raid_has_integrity(lv);
 	default:
 		log_error(INTERNAL_ERROR "unknown lv property value lvp_enum %d", lvp_enum);
 	}
@@ -2309,6 +2352,8 @@ static int _lv_is_type(struct cmd_context *cmd, struct logical_volume *lv, int l
 		return seg_is_raid10(seg);
 	case writecache_LVT:
 		return seg_is_writecache(seg);
+	case integrity_LVT:
+		return seg_is_integrity(seg);
 	case error_LVT:
 		return !strcmp(seg->segtype->name, SEG_TYPE_NAME_ERROR);
 	case zero_LVT:
@@ -2367,6 +2412,8 @@ int get_lvt_enum(struct logical_volume *lv)
 		return raid10_LVT;
 	if (seg_is_writecache(seg))
 		return writecache_LVT;
+	if (seg_is_integrity(seg))
+		return integrity_LVT;
 
 	if (!strcmp(seg->segtype->name, SEG_TYPE_NAME_ERROR))
 		return error_LVT;
diff --git a/tools/tools.h b/tools/tools.h
index 3cf4293dd..7f2434d06 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -212,6 +212,8 @@ unsigned grouped_arg_is_set(const struct arg_values *av, int a);
 const char *grouped_arg_str_value(const struct arg_values *av, int a, const char *def);
 int32_t grouped_arg_int_value(const struct arg_values *av, int a, const int32_t def); 
 
+int integrity_mode_set(const char *mode, struct integrity_settings *settings);
+
 const char *command_name(struct cmd_context *cmd);
 
 int pvmove_poll(struct cmd_context *cmd, const char *pv_name, const char *uuid,
@@ -274,6 +276,8 @@ int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_vdopool_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_vdopool_param_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int lvconvert_integrity_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 int pvscan_display_cmd(struct cmd_context *cmd, int argc, char **argv);
 int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv);
 



