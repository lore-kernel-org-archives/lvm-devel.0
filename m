From: Bryn Reeves <bmr@sourceware.org>
Date: Mon, 30 Sep 2019 12:12:36 -0400
Subject: stable-2.02 - dmsetup: do not treat no groups as an error in dmstats list --group
Message-ID: <201909301612.x8UGCaBR022355@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f970f590f969d5a3d8b9d458ae257bf93c00432
Commit:        1f970f590f969d5a3d8b9d458ae257bf93c00432
Parent:        61358d92cbf202dbb483d63a63d5adf0463bb934
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 30 17:10:05 2019 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 30 17:12:21 2019 +0100

dmsetup: do not treat no groups as an error in dmstats list --group

Analogous to the case of a device with no regions, it is not an
error to attempt to list the stats groups on a device that has no
configured groups: just return success and continue.
---
 tools/dmsetup.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 60e0638..15a09c6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -941,10 +941,12 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		}
 	}
 
-	/* group report with no groups? */
+	/* Group report with no groups is not an error */
 	if ((walk_flags == DM_STATS_WALK_GROUP)
-	    && !dm_stats_get_nr_groups(obj.stats))
+	    && !dm_stats_get_nr_groups(obj.stats)) {
+		r = 1;
 		goto out;
+	}
 
 	dm_stats_walk_init(obj.stats, walk_flags);
 	dm_stats_walk_do(obj.stats) {


