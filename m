From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 22 Mar 2017 20:19:00 -0400
Subject: master - raid: adjust to misordered raid table line output
Message-ID: <201703230019.v2N0J0Po009390@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de79c1937135026d2f5738d1c2a91cab503d2f99
Commit:        de79c1937135026d2f5738d1c2a91cab503d2f99
Parent:        735425eb9d513cf9293c77a0e618a9c248af14bc
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 23 01:14:19 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 23 01:14:19 2017 +0100

raid: adjust to misordered raid table line output

This commit supersedes reverted 1e4462dbfbd2bbe3590936df24b3ccd83110b158
to avoid changes to liblvm and the libdm API completely.

The libdevmapper interface compares existing table line retrieved from
the kernel to new table line created to decide if it can suppress a reload.
Any difference between input and output of the table line is taken to be a
change thus causing a table reload.

The dm-raid target started to misorder the raid parameters (e.g. 'raid10_copies')
starting with dm-raid target version 1.9.0 up to (excluding) 1.11.0.  This causes
runtime failures (limited to raid10 as of tests) and needs to be reversed to allow
e.g. old lvm2 uspace to run properly.

Check for the aforementioned version range in libdm and adjust creation of the table line
to the respective (mis)ordered sequence inside and correct order outside the range
(as described for the raid target in the kernels Documentation/device-mapper/dm-raid.txt).
---
 libdm/libdm-deptree.c |  152 ++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 120 insertions(+), 32 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 832d8de..9bc7674 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2375,6 +2375,51 @@ static int _get_params_count(uint64_t *bits)
 	return r;
 }
 
+/*
+ * Get target version (major, minor and patchlevel) for @target_name
+ *
+ * FIXEM: this function is derived from liblvm.
+ *        Integrate with move of liblvm functions
+ *        to libdm in future library layer purge
+ *        (e.g. expose as API dm_target_version()?)
+ */
+static int _target_version(const char *target_name, uint32_t *maj,
+			   uint32_t *min, uint32_t *patchlevel)
+{
+	int r = 0;
+	struct dm_task *dmt;
+	struct dm_versions *target, *last_target = NULL;
+
+	log_very_verbose("Getting target version for %s", target_name);
+	if (!(dmt = dm_task_create(DM_DEVICE_LIST_VERSIONS)))
+		return_0;
+
+	if (!dm_task_run(dmt)) {
+		log_debug_activation("Failed to get %s target versions", target_name);
+		/* Assume this was because LIST_VERSIONS isn't supported */
+		maj = min = patchlevel = 0;
+		r = 1;
+
+	} else
+		for (target = dm_task_get_versions(dmt);
+		     target != last_target;
+		     last_target = target, target = (struct dm_versions *)((char *) target + target->next))
+			if (!strcmp(target_name, target->name)) {
+				*maj = target->version[0];
+				*min = target->version[1];
+				*patchlevel = target->version[2];
+				log_very_verbose("Found %s target "
+						 "v%" PRIu32 ".%" PRIu32 ".%" PRIu32 ".",
+						 target_name, *maj, *min, *patchlevel);
+				r = 1;
+				break;
+			}
+
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 				   uint32_t minor, struct load_segment *seg,
 				   uint64_t *seg_start, char *params,
@@ -2382,6 +2427,7 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 {
 	uint32_t i;
 	uint32_t area_count = seg->area_count / 2;
+	uint32_t maj, min, patchlevel;
 	int param_count = 1; /* mandatory 'chunk size'/'stripe size' arg */
 	int pos = 0;
 	unsigned type;
@@ -2425,53 +2471,95 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 		    type == SEG_RAID10 ? "raid10" : _dm_segtypes[type].target,
 		    param_count, seg->stripe_size);
 
+	if (!_target_version("raid", &maj, &min, &patchlevel))
+		return_0;
+
+	/*
+	 * Target version prior to 1.9.0 and >= 1.11.0 emit
+	 * order of parameters as of kernel target documentation
+	 */
+	if (maj > 1 || (maj == 1 && (min < 9 || min >= 11))) {
+		if (seg->flags & DM_NOSYNC)
+			EMIT_PARAMS(pos, " nosync");
+		else if (seg->flags & DM_FORCESYNC)
+			EMIT_PARAMS(pos, " sync");
+
+		for (i = 0; i < area_count; i++)
+			if (seg->rebuilds[i/64] & (1ULL << (i%64)))
+				EMIT_PARAMS(pos, " rebuild %u", i);
+
+		if (seg->min_recovery_rate)
+			EMIT_PARAMS(pos, " min_recovery_rate %u",
+				    seg->min_recovery_rate);
+
+		if (seg->max_recovery_rate)
+			EMIT_PARAMS(pos, " max_recovery_rate %u",
+				    seg->max_recovery_rate);
+
+		for (i = 0; i < area_count; i++)
+			if (seg->writemostly[i/64] & (1ULL << (i%64)))
+				EMIT_PARAMS(pos, " write_mostly %u", i);
+
+		if (seg->writebehind)
+			EMIT_PARAMS(pos, " max_write_behind %u", seg->writebehind);
+
+		if (seg->region_size)
+			EMIT_PARAMS(pos, " region_size %u", seg->region_size);
+
+		if (seg->data_copies > 1 && type == SEG_RAID10)
+			EMIT_PARAMS(pos, " raid10_copies %u", seg->data_copies);
 #if 0
 	if (seg->type == SEG_RAID10_FAR)
 		EMIT_PARAMS(pos, " raid10_format far");
 	else if (seg->type == SEG_RAID10_OFFSET)
 		EMIT_PARAMS(pos, " raid10_format offset");
 #endif
+		if (seg->delta_disks)
+			EMIT_PARAMS(pos, " delta_disks %d", seg->delta_disks);
 
-	if (seg->data_copies > 1 && type == SEG_RAID10)
-		EMIT_PARAMS(pos, " raid10_copies %u", seg->data_copies);
+		/* If seg-data_offset == 1, kernel needs a zero offset to adjust to it */
+		if (seg->data_offset)
+			EMIT_PARAMS(pos, " data_offset %d", seg->data_offset == 1 ? 0 : seg->data_offset);
 
-	if (seg->flags & DM_NOSYNC)
-		EMIT_PARAMS(pos, " nosync");
-	else if (seg->flags & DM_FORCESYNC)
-		EMIT_PARAMS(pos, " sync");
+	/* Target version >= 1.9.0 && < 1.11.0 had a table line parameter ordering flaw */
+	} else {
+		if (seg->data_copies > 1 && type == SEG_RAID10)
+			EMIT_PARAMS(pos, " raid10_copies %u", seg->data_copies);
 
-	if (seg->region_size)
-		EMIT_PARAMS(pos, " region_size %u", seg->region_size);
+		if (seg->flags & DM_NOSYNC)
+			EMIT_PARAMS(pos, " nosync");
+		else if (seg->flags & DM_FORCESYNC)
+			EMIT_PARAMS(pos, " sync");
 
-	/* If seg-data_offset == 1, kernel needs a zero offset to adjust to it */
-	if (seg->data_offset)
-		EMIT_PARAMS(pos, " data_offset %d", seg->data_offset == 1 ? 0 : seg->data_offset);
+		if (seg->region_size)
+			EMIT_PARAMS(pos, " region_size %u", seg->region_size);
 
-	if (seg->delta_disks)
-		EMIT_PARAMS(pos, " delta_disks %d", seg->delta_disks);
+		/* If seg-data_offset == 1, kernel needs a zero offset to adjust to it */
+		if (seg->data_offset)
+			EMIT_PARAMS(pos, " data_offset %d", seg->data_offset == 1 ? 0 : seg->data_offset);
 
-	for (i = 0; i < area_count; i++)
-		if (seg->rebuilds[i/64] & (1ULL << (i%64)))
-			EMIT_PARAMS(pos, " rebuild %u", i);
+		if (seg->delta_disks)
+			EMIT_PARAMS(pos, " delta_disks %d", seg->delta_disks);
 
-	for (i = 0; i < area_count; i++)
-		if (seg->writemostly[i/64] & (1ULL << (i%64)))
-			EMIT_PARAMS(pos, " write_mostly %u", i);
+		for (i = 0; i < area_count; i++)
+			if (seg->rebuilds[i/64] & (1ULL << (i%64)))
+				EMIT_PARAMS(pos, " rebuild %u", i);
 
-	if (seg->writebehind)
-		EMIT_PARAMS(pos, " max_write_behind %u", seg->writebehind);
+		for (i = 0; i < area_count; i++)
+			if (seg->writemostly[i/64] & (1ULL << (i%64)))
+				EMIT_PARAMS(pos, " write_mostly %u", i);
 
-	/*
-	 * Has to be before "min_recovery_rate" or the kernels
-	 * check will fail when both set and min > previous max
-	 */
-	if (seg->max_recovery_rate)
-		EMIT_PARAMS(pos, " max_recovery_rate %u",
-			    seg->max_recovery_rate);
+		if (seg->writebehind)
+			EMIT_PARAMS(pos, " max_write_behind %u", seg->writebehind);
 
-	if (seg->min_recovery_rate)
-		EMIT_PARAMS(pos, " min_recovery_rate %u",
-			    seg->min_recovery_rate);
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
@@ -2742,7 +2830,7 @@ static int _emit_segment(struct dm_task *dmt, uint32_t major, uint32_t minor,
 			 struct load_segment *seg, uint64_t *seg_start)
 {
 	char *params;
-	size_t paramsize = 4096;
+	size_t paramsize = 4096; /* FIXME: too small for long RAID lines when > 64 devices supported */
 	int ret;
 
 	do {


