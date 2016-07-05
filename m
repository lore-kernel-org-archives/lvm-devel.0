From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:09 +0000 (UTC)
Subject: master - dmstats: convert 'delete' to dm_stats_foreach_region()
Message-ID: <20160705185509.7B46E61399@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0964acadf47aca1769138607338c5ea56570398
Commit:        b0964acadf47aca1769138607338c5ea56570398
Parent:        01cc11d9f85dc624ee2536120d7e1e1fabeadbe5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 11:26:24 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

dmstats: convert 'delete' to dm_stats_foreach_region()

---
 tools/dmsetup.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 9d3d0a5..6900ba2 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5029,16 +5029,14 @@ static int _stats_delete(CMD_ARGS)
 			goto out;
 		}
 	} else if (_switches[ALL_REGIONS_ARG]) {
-		dm_stats_walk_init(dms, DM_STATS_WALK_REGION);
-		dm_stats_walk_do(dms) {
+		dm_stats_foreach_region(dms) {
 			region_id = dm_stats_get_current_region(dms);
 			if (!dm_stats_delete_region(dms, region_id)) {
 				log_error("Could not delete statistics region.");
 				goto out;
 			}
 			log_info("Deleted statistics region %" PRIu64, region_id);
-			dm_stats_walk_next(dms);
-		} dm_stats_walk_while(dms);
+		}
 	} else {
 		dm_stats_delete_region(dms, region_id);
 		log_info("Deleted statistics region " FMTu64 ".\n", region_id);


