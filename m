From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 23 Sep 2015 14:43:32 +0000 (UTC)
Subject: master - raid: Fix raid target write_behind parameter.
Message-ID: <20150923144332.21B4561291@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6747665bd7cc9b8e332f48aa4be56716876f5231
Commit:        6747665bd7cc9b8e332f48aa4be56716876f5231
Parent:        96a621019871c5fcde42aeae9df465231302b859
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 23 15:43:00 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 23 15:43:00 2015 +0100

raid: Fix raid target write_behind parameter.

Now uses correct "write_behind" instead of "writebehind".
Patch also includes some tidying up.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   15 +++++++++------
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f198a50..52dfc01 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Correct use of write_behind parameter when generating raid target line.
   Fix dm-event systemd service to make sure it is executed before mounting.
 
 Version 1.02.109 - 22nd September 2016
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 1a66d98..cba4ea0 100644
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
 
@@ -2425,7 +2428,7 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 			EMIT_PARAMS(pos, " write_mostly %u", i);
 
 	if (seg->writebehind)
-		EMIT_PARAMS(pos, " writebehind %u", seg->writebehind);
+		EMIT_PARAMS(pos, " write_behind %u", seg->writebehind);
 
 	if (seg->min_recovery_rate)
 		EMIT_PARAMS(pos, " min_recovery_rate %u",


