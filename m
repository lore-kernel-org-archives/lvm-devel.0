From: Bryn Reeves <bmr@sourceware.org>
Date: Mon, 30 Sep 2019 12:11:26 -0400
Subject: master - dmsetup: do not treat no groups as an error in dmstats list --group
Message-ID: <201909301611.x8UGBQiO022182@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8f02f8dcd72571ce3bc6538f1cd23807e2b6a64d
Commit:        8f02f8dcd72571ce3bc6538f1cd23807e2b6a64d
Parent:        5c0264d68954e5677f21459bb18d50704b2b9d77
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 30 17:10:05 2019 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 30 17:10:05 2019 +0100

dmsetup: do not treat no groups as an error in dmstats list --group

Analogous to the case of a device with no regions, it is not an
error to attempt to list the stats groups on a device that has no
configured groups: just return success and continue.
---
 libdm/dm-tools/dmsetup.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 2f8a1be..7267d0d 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -942,10 +942,12 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
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


