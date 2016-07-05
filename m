From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:05 +0000 (UTC)
Subject: master - dmstats: convert 'clear' to dm_stats_foreach_region()
Message-ID: <20160705185505.5E5DC61399@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2047b8e5658a0f6816d2e940b82e1684b5698aa6
Commit:        2047b8e5658a0f6816d2e940b82e1684b5698aa6
Parent:        f403ac8bf0ce5e1419dc2e5b37f143e3cd3a3740
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 10:54:23 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:16 2016 +0100

dmstats: convert 'clear' to dm_stats_foreach_region()

---
 tools/dmsetup.c |   39 +++++++++++++++++++++++----------------
 1 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index d003c3b..c121f45 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4609,6 +4609,22 @@ static int _bind_stats_device(struct dm_stats *dms, const char *name)
 	return 1;
 }
 
+static int _stats_clear_one_region(struct dm_stats *dms, uint64_t region_id)
+{
+
+	if (!dm_stats_region_present(dms, region_id)) {
+		log_error("No such region: %"PRIu64".", region_id);
+		return 0;
+	}
+	if (!dm_stats_clear_region(dms, region_id)) {
+		log_error("Clearing statistics region %"PRIu64" failed.",
+			  region_id);
+		return 0;
+	}
+	log_info("Cleared statistics region %"PRIu64".", region_id);
+	return 1;
+}
+
 static int _stats_clear_regions(struct dm_stats *dms, uint64_t region_id)
 {
 	int allregions = (region_id == DM_STATS_REGIONS_ALL);
@@ -4619,23 +4635,14 @@ static int _stats_clear_regions(struct dm_stats *dms, uint64_t region_id)
 	if (!dm_stats_get_nr_regions(dms))
 		return 1;
 
-	dm_stats_walk_init(dms, DM_STATS_WALK_REGION);
-	dm_stats_walk_do(dms) {
-		if (allregions)
-			region_id = dm_stats_get_current_region(dms);
+	if (!allregions)
+		return _stats_clear_one_region(dms, region_id);
 
-		if (!dm_stats_region_present(dms, region_id)) {
-			log_error("No such region: %"PRIu64".", region_id);
-			return 0;
-		}
-		if (!dm_stats_clear_region(dms, region_id)) {
-			log_error("Clearing statistics region %"PRIu64" failed.",
-				  region_id);
-			return 0;
-		}
-		log_info("Cleared statistics region %"PRIu64".", region_id);
-		dm_stats_walk_next(dms);
-	} dm_stats_walk_while(dms);
+	dm_stats_foreach_region(dms) {
+		region_id = dm_stats_get_current_region(dms);
+		if (!_stats_clear_one_region(dms, region_id))
+			return_0;
+	}
 
 	return 1;
 }


