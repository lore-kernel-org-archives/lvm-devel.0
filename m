From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat, 10 Dec 2016 12:22:11 +0000 (UTC)
Subject: master - libdm: split off internal _stats_delete_region()
Message-ID: <20161210122211.76A6460CE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97c4490cc53157adde6da84933524f22149f449f
Commit:        97c4490cc53157adde6da84933524f22149f449f
Parent:        c459f23565e86eb9a8a116995cda7dcaed858b9f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Dec 9 22:58:25 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Dec 10 11:57:14 2016 +0000

libdm: split off internal _stats_delete_region()

Split dm_stats_delete_region() so that internal callers can manage
the handle state themselves.

dm_stats_delete_region() now just handles checking the state of the
handle, reporting validation errors, and calling dm_stats_list() if
necessary, before calling _stats_delete_region().

The new _stats_delete_region() function performs the actual group
member removal and region deletion, and requires a fully listed
handle to operate.

Callers that repeatedly delete regions can use a single listed
handle for many operations on the same device, avoiding one
message ioctl per region deleted: since @stats_list with many
regions is expensive, this yields large runtime improvements.
---
 libdm/libdm-stats.c |   43 ++++++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 438a1ed..1cabd9a 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2018,10 +2018,34 @@ static int _stats_remove_region_id_from_group(struct dm_stats *dms,
 	return _stats_set_aux(dms, group_id, dms->regions[group_id].aux_data);
 }
 
-int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
+static int _stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 {
 	char msg[STATS_MSG_BUF_LEN];
 	struct dm_task *dmt;
+
+	if (_stats_region_is_grouped(dms, region_id))
+		if (!_stats_remove_region_id_from_group(dms, region_id)) {
+			log_error("Could not remove region ID " FMTu64 " from "
+				  "group ID " FMTu64,
+				  region_id, dms->regions[region_id].group_id);
+			return 0;
+		}
+
+	if (!dm_snprintf(msg, sizeof(msg), "@stats_delete " FMTu64, region_id)) {
+		log_error("Could not prepare @stats_delete message.");
+		return 0;
+	}
+
+	dmt = _stats_send_message(dms, msg);
+	if (!dmt)
+		return_0;
+	dm_task_destroy(dmt);
+
+	return 1;
+}
+
+int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
+{
 	int listed = 0;
 
 	if (!_stats_bound(dms))
@@ -2065,23 +2089,8 @@ int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 		goto bad;
 	}
 
-	if(_stats_region_is_grouped(dms, region_id))
-		if (!_stats_remove_region_id_from_group(dms, region_id)) {
-			log_error("Could not remove region ID " FMTu64 " from "
-				  "group ID " FMTu64,
-				  region_id, dms->regions[region_id].group_id);
-			goto bad;
-		}
-
-	if (!dm_snprintf(msg, sizeof(msg), "@stats_delete " FMTu64, region_id)) {
-		log_error("Could not prepare @stats_delete message.");
+	if (!_stats_delete_region(dms, region_id))
 		goto bad;
-	}
-
-	dmt = _stats_send_message(dms, msg);
-	if (!dmt)
-		return_0;
-	dm_task_destroy(dmt);
 
 	if (!listed)
 		/* wipe region and mark as not present */


