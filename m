From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:07 +0000 (UTC)
Subject: master - dmstats: do not walk regions if deleting a single id
Message-ID: <20160705183507.4CD7960FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d94c9569032d654a58cc6693c8a2a28e6e3b33f1
Commit:        d94c9569032d654a58cc6693c8a2a28e6e3b33f1
Parent:        3626cf025dbb0e17a4bda7fabd4b081021eaddcc
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Jun 19 14:40:03 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:50 2016 +0100

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
 


