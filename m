From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 27 Sep 2016 16:58:17 +0000 (UTC)
Subject: master - libdm: fix dm_stats_delete_region() backwards compat
Message-ID: <20160927165817.DF80360D22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56c90ffa5e7d7c69c5230ac3bbee3ed03e7bae62
Commit:        56c90ffa5e7d7c69c5230ac3bbee3ed03e7bae62
Parent:        6ec8854fdb051b092d5e262dc6c6d4c2ea075cd1
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Sep 27 17:46:52 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Sep 27 17:58:05 2016 +0100

libdm: fix dm_stats_delete_region() backwards compat

The dm_stats_delete_region() call removes a region from the bound
device, and, if the region is grouped, from the group leader
group descriptor stored in aux_data.

To do this requires a listed handle: previous versions of the
library do not since no dependencies exist between regions without
grouping.

This leads to strange behaviour when a command built against an old
version of the library is used with one supporting groups. Deleting
a region with dmstats succeeds, but logs errors:

  # dmstats list
  Name             RgID RgSta RgSiz #Areas ArSize ProgID
  vg_hex-root         0     0 1.00g      1  1.00g dmstats
  vg_hex-root         1 1.00g 1.00g      1  1.00g dmstats
  vg_hex-root         2 2.00g 1.00g      1  1.00g dmstats
  # dmstats delete --regionid 2 vg_hex/root
  Region ID 2 does not exist
  Could not delete statistics region.
  Command failed
  # dmstats list
  Name             RgID RgSta RgSiz #Areas ArSize ProgID
  vg_hex-root         0     0 1.00g      1  1.00g dmstats
  vg_hex-root         1 1.00g 1.00g      1  1.00g dmstats

This happens because the call to dm_stats_delete_region() is inside
a dm_stats_walk_*() iterator: upon entry to the call, the iterator
is at its end conditions and about to terminate. Due to the call to
dm_stats_list() inside the function, it returns with an iterator at
the beginning of a walk and performs a further iteration before
exiting. This final loop makes a further attempt to delete the
(already deleted) region, leading to the confusing error messages.
---
 WHATS_NEW_DM        |    1 +
 libdm/libdm-stats.c |   48 +++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b048f7a..ed07307 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Fix 'dmstats delete' with dmsetup older than v1.02.129
   Fix stats walk segfault with dmsetup older than v1.02.129
 
 Version 1.02.135 - 26th September 2016
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 75e0144..a033861 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1550,7 +1550,7 @@ out:
 
 int dm_stats_walk_end(struct dm_stats *dms)
 {
-	if (!dms || !dms->regions)
+	if (!dms)
 		return 1;
 
 	if (_stats_walk_end(dms, &dms->cur_flags,
@@ -2020,26 +2020,47 @@ int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 {
 	char msg[STATS_MSG_BUF_LEN];
 	struct dm_task *dmt;
+	int listed = 0;
 
 	if (!_stats_bound(dms))
 		return_0;
 
-	if (!dms->regions && !dm_stats_list(dms, dms->program_id)) {
+	/*
+	 * To correctly delete a region, that may be part of a group, a
+	 * listed handle is required, since the region may need to be
+	 * removed from another region's group descriptor; earlier
+	 * versions of the region deletion interface do not have this
+	 * requirement since there are no dependencies between regions.
+	 *
+	 * Listing a previously unlisted handle has numerous
+	 * side-effects on other calls and operations (e.g. stats
+	 * walks), especially when returning to a function that depends
+	 * on the state of the region table, or statistics cursor.
+	 *
+	 * To avoid changing the semantics of the API, and the need for
+	 * a versioned symbol, maintain a flag indicating when a listing
+	 * has been carried out, and drop the region table before
+	 * returning.
+	 *
+	 * This ensures compatibility with programs compiled against
+	 * earlier versions of libdm.
+	 */
+	if (!dms->regions && !(listed = dm_stats_list(dms, dms->program_id))) {
 		log_error("Could not obtain region list while deleting "
 			  "region ID " FMTu64, region_id);
-		return 0;
+		goto bad;
 	}
 
 	if (!dm_stats_get_nr_areas(dms)) {
 		log_error("Could not delete region ID " FMTu64 ": "
 			  "no regions found", region_id);
-		return 0;
+		goto bad;
 	}
 
 	/* includes invalid and special region_id values */
 	if (!dm_stats_region_present(dms, region_id)) {
 		log_error("Region ID " FMTu64 " does not exist", region_id);
-		return 0;
+		goto bad;
 	}
 
 	if(_stats_region_is_grouped(dms, region_id))
@@ -2047,12 +2068,12 @@ int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 			log_error("Could not remove region ID " FMTu64 " from "
 				  "group ID " FMTu64,
 				  region_id, dms->regions[region_id].group_id);
-			return 0;
+			goto bad;
 		}
 
 	if (!dm_snprintf(msg, sizeof(msg), "@stats_delete " FMTu64, region_id)) {
 		log_error("Could not prepare @stats_delete message.");
-		return 0;
+		goto bad;
 	}
 
 	dmt = _stats_send_message(dms, msg);
@@ -2060,10 +2081,19 @@ int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 		return_0;
 	dm_task_destroy(dmt);
 
-	/* wipe region and mark as not present */
-	_stats_region_destroy(&dms->regions[region_id]);
+	if (!listed)
+		/* wipe region and mark as not present */
+		_stats_region_destroy(&dms->regions[region_id]);
+	else
+		/* return handle to prior state */
+		_stats_regions_destroy(dms);
 
 	return 1;
+bad:
+	if (listed)
+		_stats_regions_destroy(dms);
+
+	return 0;
 }
 
 int dm_stats_clear_region(struct dm_stats *dms, uint64_t region_id)


