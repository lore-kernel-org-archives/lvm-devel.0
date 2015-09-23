From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 23 Sep 2015 14:59:01 +0000 (UTC)
Subject: master - raid: Fix raid target write_behind parameter.
Message-ID: <20150923145901.9A29260282@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e60e6244456785c88dcd5bc0998a348a639c17b
Commit:        4e60e6244456785c88dcd5bc0998a348a639c17b
Parent:        96a621019871c5fcde42aeae9df465231302b859
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Sep 23 15:53:27 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 23 15:53:27 2015 +0100

raid: Fix raid target write_behind parameter.

Now uses correct "max_write_behind" instead of "writebehind".
(Includes some tidying up.)
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   27 +++++++++++++++------------
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f198a50..b665bbc 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Correct use of max_write_behind parameter when generating raid target line.
   Fix dm-event systemd service to make sure it is executed before mounting.
 
 Version 1.02.109 - 22nd September 2016
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 1a66d98..7bc098f 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -86,7 +86,7 @@ static const struct {
 	{ SEG_RAID6_NC, "raid6_nc"},
 
 	/*
-	 *WARNING: Since 'raid' target overloads this 1:1 mapping table
+	 * WARNING: Since 'raid' target overloads this 1:1 mapping table
 	 * for search do not add new enum elements past them!
 	 */
 	{ SEG_RAID5_LS, "raid5"}, /* same as "raid5_ls" (default for MD also) */
@@ -2369,7 +2369,7 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 
 	return 1;
 }
- 
+
 /* Is parameter non-zero? */
 #define PARAM_IS_SET(p) (p) ? 1 : 0
 
@@ -2396,9 +2396,12 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	if ((seg->flags & DM_NOSYNC) || (seg->flags & DM_FORCESYNC))
 		param_count++;
 
-	param_count += 2 * (PARAM_IS_SET(seg->region_size) + PARAM_IS_SET(seg->writebehind) +
-			    PARAM_IS_SET(seg->min_recovery_rate) + PARAM_IS_SET(seg->max_recovery_rate));
+	param_count += 2 * (PARAM_IS_SET(seg->region_size) +
+			    PARAM_IS_SET(seg->writebehind) +
+			    PARAM_IS_SET(seg->min_recovery_rate) +
+			    PARAM_IS_SET(seg->max_recovery_rate));
 
+	/* rebuilds and writemostly are 64 bits */
 	param_count += _get_params_count(seg->rebuilds);
 	param_count += _get_params_count(seg->writemostly);
 
@@ -2420,13 +2423,6 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 		if (seg->rebuilds & (1ULL << i))
 			EMIT_PARAMS(pos, " rebuild %u", i);
 
-	for (i = 0; i < (seg->area_count / 2); i++)
-		if (seg->writemostly & (1ULL << i))
-			EMIT_PARAMS(pos, " write_mostly %u", i);
-
-	if (seg->writebehind)
-		EMIT_PARAMS(pos, " writebehind %u", seg->writebehind);
-
 	if (seg->min_recovery_rate)
 		EMIT_PARAMS(pos, " min_recovery_rate %u",
 			    seg->min_recovery_rate);
@@ -2435,6 +2431,13 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 		EMIT_PARAMS(pos, " max_recovery_rate %u",
 			    seg->max_recovery_rate);
 
+	for (i = 0; i < (seg->area_count / 2); i++)
+		if (seg->writemostly & (1ULL << i))
+			EMIT_PARAMS(pos, " write_mostly %u", i);
+
+	if (seg->writebehind)
+		EMIT_PARAMS(pos, " max_write_behind %u", seg->writebehind);
+
 	/* Print number of metadata/data device pairs */
 	EMIT_PARAMS(pos, " %u", seg->area_count/2);
 


