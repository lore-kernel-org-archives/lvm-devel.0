From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 21 Mar 2017 13:18:12 -0400
Subject: master - raid: adjust to misordered raid table line output
Message-ID: <201703211718.v2LHICP0029713@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e4462dbfbd2bbe3590936df24b3ccd83110b158
Commit:        1e4462dbfbd2bbe3590936df24b3ccd83110b158
Parent:        642d682d8ddcc3152f68b3ec8518902a0ef448ac
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 21 18:17:42 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 21 18:17:42 2017 +0100

raid: adjust to misordered raid table line output

The libdevmapper interface compares existing table line retrieved from
the kernel to new table line created to decide if it can suppress a reload.
Any difference between input and output of the table line is taken to be a
change thus causing a table reload.

The dm-raid target started to misorder the raid parameters (e.g. 'raid10_copies')
starting with dm-raid target version 1.9.0 up to (excluding) 1.11.0.  This causes
runtime failures (limited to raid10 as of tests) and needs to be reversed to allow
e.g. old lvm2 uspace to run properly.

Check for the aforementioned version range and adjust creation of the table line
to the respective (mis)ordered sequence inside and correct order outside the range
(as described for the raid target in the kernels Documentation/device-mapper/dm-raid.txt).
---
 lib/metadata/segtype.h |    1 +
 lib/raid/raid.c        |   23 ++++++++++-
 libdm/libdevmapper.h   |   10 +++++
 libdm/libdm-deptree.c  |  102 +++++++++++++++++++++++++++++++++---------------
 4 files changed, 103 insertions(+), 33 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 2364db8..a6093e8 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -288,6 +288,7 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 #define RAID_FEATURE_RAID4			(1U << 3) /* ! version 1.8 or 1.9.0 */
 #define RAID_FEATURE_SHRINK			(1U << 4) /* version 1.9.0 */
 #define RAID_FEATURE_RESHAPE			(1U << 5) /* version 1.10.1 */
+#define RAID_FEATURE_PROPER_TABLE_ORDER		(1U << 6) /* version >= 1.9.0 and < 1.11.0 had wrong parameter order */
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index df9796d..7e9f0d3 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -228,6 +228,9 @@ static int _raid_text_export(const struct lv_segment *seg, struct formatter *f)
 	return _raid_text_export_raid(seg, f);
 }
 
+static int _raid_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg __attribute__((unused)),
+				unsigned *attributes);
 static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 				 struct dm_pool *mem __attribute__((unused)),
 				 struct cmd_context *cmd __attribute__((unused)),
@@ -238,6 +241,7 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	int delta_disks = 0, delta_disks_minus = 0, delta_disks_plus = 0, data_offset = 0;
+	unsigned attrs;
 	uint32_t s;
 	uint64_t flags = 0;
 	uint64_t rebuilds[RAID_BITMAP_SIZE];
@@ -300,6 +304,13 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 			flags = DM_NOSYNC;
 	}
 
+	if (!_raid_target_present(seg->lv->vg->cmd, seg, &attrs))
+		return_0;
+
+	/* RAID target line parameters are in kernel documented order */
+	if (attrs & RAID_FEATURE_PROPER_TABLE_ORDER)
+		flags |= DM_RAID_TABLE_ORDERED;
+
 	params.raid_type = lvseg_name(seg);
 
 	if (seg->segtype->parity_devs) {
@@ -479,7 +490,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 
 	static int _raid_checked = 0;
 	static int _raid_present = 0;
-	static unsigned _raid_attrs = 0;
+	static unsigned _raid_attrs;
 	uint32_t maj, min, patchlevel;
 	unsigned i;
 
@@ -488,6 +499,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 
 	if (!_raid_checked) {
 		_raid_checked = 1;
+		_raid_attrs = RAID_FEATURE_PROPER_TABLE_ORDER;
 
 		if (!(_raid_present = target_present(cmd, TARGET_NAME_RAID, 1)))
 			return 0;
@@ -514,6 +526,15 @@ static int _raid_target_present(struct cmd_context *cmd,
 		else
 			log_very_verbose("Target raid does not support %s.",
 					 SEG_TYPE_NAME_RAID4);
+
+		/*
+		 * Target version range check:
+		 *
+		 * raid target line parameters were misordered (e.g. 'raid10_copies')
+		 * in target version >= 1.9.0 and < 1.11.0
+		 */
+		if (maj == 1 && min >= 9 && min < 11)
+			_raid_attrs &= ~RAID_FEATURE_PROPER_TABLE_ORDER;
 	}
 
 	if (attributes)
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 4bd32b4..ff84785 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1775,6 +1775,16 @@ int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 #define DM_BLOCK_ON_ERROR	0x00000004	/* On error, suspend I/O */
 #define DM_CORELOG		0x00000008	/* In-memory log */
 
+/*
+ * RAID flag: table line is in kernel documented order.
+ *
+ * Target version >= 1.9.0 and < 1.11.0 misordered e.g. 'raid10_copies'
+ *
+ * Keep distinct from mirror log ones above because it
+ * can be passed together with those in load segment flags!
+ */
+#define DM_RAID_TABLE_ORDERED	0x00000010
+
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 				       uint32_t region_size,
 				       unsigned clustered,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 832d8de..2dced75 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2432,46 +2432,84 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 		EMIT_PARAMS(pos, " raid10_format offset");
 #endif
 
-	if (seg->data_copies > 1 && type == SEG_RAID10)
-		EMIT_PARAMS(pos, " raid10_copies %u", seg->data_copies);
+	if (seg->flags & DM_RAID_TABLE_ORDERED) {
+		/* Emit order of paramters as of kernel target documentation */
+		if (seg->flags & DM_NOSYNC)
+			EMIT_PARAMS(pos, " nosync");
+		else if (seg->flags & DM_FORCESYNC)
+			EMIT_PARAMS(pos, " sync");
 
-	if (seg->flags & DM_NOSYNC)
-		EMIT_PARAMS(pos, " nosync");
-	else if (seg->flags & DM_FORCESYNC)
-		EMIT_PARAMS(pos, " sync");
+		for (i = 0; i < area_count; i++)
+			if (seg->rebuilds[i/64] & (1ULL << (i%64)))
+				EMIT_PARAMS(pos, " rebuild %u", i);
 
-	if (seg->region_size)
-		EMIT_PARAMS(pos, " region_size %u", seg->region_size);
+		if (seg->min_recovery_rate)
+			EMIT_PARAMS(pos, " min_recovery_rate %u",
+				    seg->min_recovery_rate);
 
-	/* If seg-data_offset == 1, kernel needs a zero offset to adjust to it */
-	if (seg->data_offset)
-		EMIT_PARAMS(pos, " data_offset %d", seg->data_offset == 1 ? 0 : seg->data_offset);
+		if (seg->max_recovery_rate)
+			EMIT_PARAMS(pos, " max_recovery_rate %u",
+				    seg->max_recovery_rate);
 
-	if (seg->delta_disks)
-		EMIT_PARAMS(pos, " delta_disks %d", seg->delta_disks);
+		for (i = 0; i < area_count; i++)
+			if (seg->writemostly[i/64] & (1ULL << (i%64)))
+				EMIT_PARAMS(pos, " write_mostly %u", i);
 
-	for (i = 0; i < area_count; i++)
-		if (seg->rebuilds[i/64] & (1ULL << (i%64)))
-			EMIT_PARAMS(pos, " rebuild %u", i);
+		if (seg->writebehind)
+			EMIT_PARAMS(pos, " max_write_behind %u", seg->writebehind);
 
-	for (i = 0; i < area_count; i++)
-		if (seg->writemostly[i/64] & (1ULL << (i%64)))
-			EMIT_PARAMS(pos, " write_mostly %u", i);
+		if (seg->region_size)
+			EMIT_PARAMS(pos, " region_size %u", seg->region_size);
 
-	if (seg->writebehind)
-		EMIT_PARAMS(pos, " max_write_behind %u", seg->writebehind);
+		if (seg->data_copies > 1 && type == SEG_RAID10)
+			EMIT_PARAMS(pos, " raid10_copies %u", seg->data_copies);
 
-	/*
-	 * Has to be before "min_recovery_rate" or the kernels
-	 * check will fail when both set and min > previous max
-	 */
-	if (seg->max_recovery_rate)
-		EMIT_PARAMS(pos, " max_recovery_rate %u",
-			    seg->max_recovery_rate);
+		if (seg->delta_disks)
+			EMIT_PARAMS(pos, " delta_disks %d", seg->delta_disks);
+
+		/* If seg-data_offset == 1, kernel needs a zero offset to adjust to it */
+		if (seg->data_offset)
+			EMIT_PARAMS(pos, " data_offset %d", seg->data_offset == 1 ? 0 : seg->data_offset);
+
+	} else {
+		/* Target version >= 1.9.0 && < 1.11.0 had a table line parameter ordering flaw */
+		if (seg->data_copies > 1 && type == SEG_RAID10)
+			EMIT_PARAMS(pos, " raid10_copies %u", seg->data_copies);
+
+		if (seg->flags & DM_NOSYNC)
+			EMIT_PARAMS(pos, " nosync");
+		else if (seg->flags & DM_FORCESYNC)
+			EMIT_PARAMS(pos, " sync");
 
-	if (seg->min_recovery_rate)
-		EMIT_PARAMS(pos, " min_recovery_rate %u",
-			    seg->min_recovery_rate);
+		if (seg->region_size)
+			EMIT_PARAMS(pos, " region_size %u", seg->region_size);
+
+		/* If seg-data_offset == 1, kernel needs a zero offset to adjust to it */
+		if (seg->data_offset)
+			EMIT_PARAMS(pos, " data_offset %d", seg->data_offset == 1 ? 0 : seg->data_offset);
+
+		if (seg->delta_disks)
+			EMIT_PARAMS(pos, " delta_disks %d", seg->delta_disks);
+
+		for (i = 0; i < area_count; i++)
+			if (seg->rebuilds[i/64] & (1ULL << (i%64)))
+				EMIT_PARAMS(pos, " rebuild %u", i);
+
+		for (i = 0; i < area_count; i++)
+			if (seg->writemostly[i/64] & (1ULL << (i%64)))
+				EMIT_PARAMS(pos, " write_mostly %u", i);
+
+		if (seg->writebehind)
+			EMIT_PARAMS(pos, " max_write_behind %u", seg->writebehind);
+
+		if (seg->max_recovery_rate)
+			EMIT_PARAMS(pos, " max_recovery_rate %u",
+				    seg->max_recovery_rate);
+
+		if (seg->min_recovery_rate)
+			EMIT_PARAMS(pos, " min_recovery_rate %u",
+				    seg->min_recovery_rate);
+	}
 
 	/* Print number of metadata/data device pairs */
 	EMIT_PARAMS(pos, " %u", area_count);
@@ -2742,7 +2780,7 @@ static int _emit_segment(struct dm_task *dmt, uint32_t major, uint32_t minor,
 			 struct load_segment *seg, uint64_t *seg_start)
 {
 	char *params;
-	size_t paramsize = 4096;
+	size_t paramsize = 4096; /* FIXME: too small for long RAID lines when > 64 devices supported */
 	int ret;
 
 	do {


