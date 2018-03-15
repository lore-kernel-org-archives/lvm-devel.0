From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:32 -0400
Subject: master - libdm-stats: fix error messages
Message-ID: <201803151004.w2FA4WRH023619@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=043f58452a0a2c136dd6a90f1d60b063ae17a866
Commit:        043f58452a0a2c136dd6a90f1d60b063ae17a866
Parent:        a082ce2613f3a9587b0109df0bbc3ebb7e6b1e75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 14 21:00:46 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 10:56:31 2018 +0100

libdm-stats: fix error messages

When function dm_stats_populate() returns 0 it's an error and needs
log_error() message -  function can't have 'success' returning 0 or
error without reasons.
---
 WHATS_NEW_DM        |    1 +
 libdm/libdm-stats.c |   11 ++++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2fafe74..34c6833 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 - 
 =====================================
+  Add missing log_error() into dm_stats_populate() returning 0.
   Avoid calling dm_stats_populat() for DM devices without any stats regions.
   Support DM_DEBUG_WITH_LINE_NUMBERS envvar for debug msg with source:line.
   Configured command for thin pool threshold handling gets whole environment.
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index c74444a..94ad380 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -403,7 +403,7 @@ static int _stats_bound(const struct dm_stats *dms)
 	if (dms->bind_major > 0 || dms->bind_name || dms->bind_uuid)
 		return 1;
 	/* %p format specifier expects a void pointer. */
-	log_debug("Stats handle at %p is not bound.", dms);
+	log_error("Stats handle at %p is not bound.", dms);
 	return 0;
 }
 
@@ -2336,6 +2336,11 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 		return 0;
 	}
 
+	if (!dms->nr_regions) {
+		log_error("No regions registered.");
+		return 0;
+	}
+
 	/* allow zero-length program_id for populate */
 	if (!program_id)
 		program_id = dms->program_id;
@@ -2347,10 +2352,6 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 		goto_bad;
 	}
 
-	/* successful list but no regions registered */
-	if (!dms->nr_regions)
-		return 0;
-
 	dms->walk_flags = DM_STATS_WALK_REGION;
 	dm_stats_walk_start(dms);
 	do {


