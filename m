From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:02 +0000 (GMT)
Subject: main - cache: fix parentheses for migration_threshold
Message-ID: <20210913103602.733ED3858003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c4cd7b2f22a86a74f49104926ab96a24755e697
Commit:        6c4cd7b2f22a86a74f49104926ab96a24755e697
Parent:        30050769b1490e293d9e0f7ed37d83c3e56bb6b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 10 23:02:09 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cache: fix parentheses for migration_threshold

When generating table line for cache target line,
the estimation of added arguments was incorrectly
calculated as the evaluation order of "?" is
made after "+".

However the result was 'masked' by the

Reported-by: Jian Cai jcai19
---
 WHATS_NEW_DM                  | 1 +
 device_mapper/libdm-deptree.c | 2 +-
 libdm/libdm-deptree.c         | 2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 68920d888..7632ae4fd 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.181 - 
 ===================================
+  Fix bug in construction of cache table line (regression from 1.02.159).
 
 Version 1.02.179 - 11th August 2021
 ===================================
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index c759c4e46..4f2d79ee1 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2644,7 +2644,7 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 	EMIT_PARAMS(pos, " %s", name);
 
 	/* Do not pass migration_threshold 2048 which is default */
-	EMIT_PARAMS(pos, " %u", (seg->policy_argc + (seg->migration_threshold != 2048) ? 1 : 0) * 2);
+	EMIT_PARAMS(pos, " %u", (seg->policy_argc + ((seg->migration_threshold != 2048) ? 1 : 0)) * 2);
 	if (seg->migration_threshold != 2048)
 		    EMIT_PARAMS(pos, " migration_threshold %u", seg->migration_threshold);
 	if (seg->policy_settings)
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 06ebdc0c0..881558e44 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2489,7 +2489,7 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 	EMIT_PARAMS(pos, " %s", name);
 
 	/* Do not pass migration_threshold 2048 which is default */
-	EMIT_PARAMS(pos, " %u", (seg->policy_argc + (seg->migration_threshold != 2048) ? 1 : 0) * 2);
+	EMIT_PARAMS(pos, " %u", (seg->policy_argc + ((seg->migration_threshold != 2048) ? 1 : 0)) * 2);
 	if (seg->migration_threshold != 2048)
 		    EMIT_PARAMS(pos, " migration_threshold %u", seg->migration_threshold);
 	if (seg->policy_settings)


