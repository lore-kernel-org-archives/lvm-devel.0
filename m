From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 1 Nov 2018 12:53:33 -0400
Subject: 2018-06-01-stable - libdm-stats: move no regions warning after dm_stats_list()
Message-ID: <201811011653.wA1GrXRa008890@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=813a83b2d6d9a35ead4f7b424fa39e513cb8b49e
Commit:        813a83b2d6d9a35ead4f7b424fa39e513cb8b49e
Parent:        fa8d5e4e8132ec6d601a9642abfbdcc044880c27
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Nov 1 16:47:56 2018 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Nov 1 16:47:56 2018 +0000

libdm-stats: move no regions warning after dm_stats_list()

It doesn't make sense to test or warn about the region count until
the stats handle has been listed: at this point it may or may not
contain valid information (but is guaranteed to be correct after
the list).
---
 libdm/libdm-stats.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 94ad380..6b4e3d8 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2336,11 +2336,6 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 		return 0;
 	}
 
-	if (!dms->nr_regions) {
-		log_error("No regions registered.");
-		return 0;
-	}
-
 	/* allow zero-length program_id for populate */
 	if (!program_id)
 		program_id = dms->program_id;
@@ -2352,6 +2347,11 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 		goto_bad;
 	}
 
+	if (!dms->nr_regions) {
+		log_verbose("No stats regions registered: %s", dms->name);
+		return 0;
+	}
+
 	dms->walk_flags = DM_STATS_WALK_REGION;
 	dm_stats_walk_start(dms);
 	do {


