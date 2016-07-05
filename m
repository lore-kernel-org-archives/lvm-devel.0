From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:54:50 +0000 (UTC)
Subject: master - dmstats: do not walk regions if deleting a single id
Message-ID: <20160705185450.C0C3261253@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b179e09a4b921d2be925c997dd1125176e616c5
Commit:        8b179e09a4b921d2be925c997dd1125176e616c5
Parent:        402d840aa726277a10ed026c7c3a660800669b6d
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Jun 19 14:40:03 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

dmstats: do not walk regions if deleting a single id

---
 tools/dmsetup.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f7a3f74..dfb362b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4965,16 +4965,20 @@ static int _stats_delete(CMD_ARGS)
 		goto out;
 	}
 
-	dm_stats_walk_do(dms) {
-		if (_switches[ALL_REGIONS_ARG])
+	if (_switches[ALL_REGIONS_ARG]) {
+		dm_stats_walk_do(dms) {
 			region_id = dm_stats_get_current_region(dms);
-		if (!dm_stats_delete_region(dms, region_id)) {
-			log_error("Could not delete statistics region.");
-			goto out;
-		}
+			if (!dm_stats_delete_region(dms, region_id)) {
+				log_error("Could not delete statistics region.");
+				goto out;
+			}
+			log_info("Deleted statistics region %" PRIu64, region_id);
+			dm_stats_walk_next_region(dms);
+		} dm_stats_walk_while(dms);
+	} else {
+		dm_stats_delete_region(dms, region_id);
 		log_info("Deleted statistics region %" PRIu64, region_id);
-		dm_stats_walk_next_region(dms);
-	} dm_stats_walk_while(dms);
+	}
 
 	r = 1;
 


