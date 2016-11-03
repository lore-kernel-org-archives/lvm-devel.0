From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 16:49:49 +0000 (UTC)
Subject: master - log_info to log_very_verbose
Message-ID: <20161103164949.6D6B260F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9cbe4c1af935bd4e76fbcc8a8736c6337bfc638b
Commit:        9cbe4c1af935bd4e76fbcc8a8736c6337bfc638b
Parent:        cc19cc07f7a1aa4a45f6044a7eb4686f6d5dcf69
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 1 11:02:01 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 17:49:07 2016 +0100

log_info to log_very_verbose

Translate log_info() into log_very_verbose() which is macro
supposed to be used by our code.

log_info() is internal macro with eventually some 'symbolic' meaning
in syslogging daemons.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    2 +-
 lib/activate/activate.c                       |    2 +-
 lib/label/label.c                             |   24 ++++++++++++------------
 libdm/libdm-stats.c                           |    4 ++--
 4 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index d5a3a59..0c26baf 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -301,7 +301,7 @@ out:
 static int _use_policy(struct dm_task *dmt, struct dso_state *state)
 {
 #if THIN_DEBUG
-	log_info("dmeventd executes: %s.", state->cmd_str);
+	log_debug("dmeventd executes: %s.", state->cmd_str);
 #endif
 	if (!dmeventd_lvm2_run_with_lock(state->cmd_str)) {
 		log_error("Failed to extend thin pool %s.",
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 571f2b2..8fc45b7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1708,7 +1708,7 @@ int target_register_events(struct cmd_context *cmd, const char *dso, const struc
 	if (!r)
 		return_0;
 
-	log_info("%s %s for events", set ? "Monitored" : "Unmonitored", uuid);
+	log_very_verbose("%s %s for events", set ? "Monitored" : "Unmonitored", uuid);
 
 	return 1;
 }
diff --git a/lib/label/label.c b/lib/label/label.c
index b52cb42..c5f4884 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -140,18 +140,18 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 					  sector + scan_sector);
 			}
 			if (xlate64(lh->sector_xl) != sector + scan_sector) {
-				log_info("%s: Label for sector %" PRIu64
-					 " found at sector %" PRIu64
-					 " - ignoring", dev_name(dev),
-					 (uint64_t)xlate64(lh->sector_xl),
-					 sector + scan_sector);
+				log_very_verbose("%s: Label for sector %" PRIu64
+						 " found at sector %" PRIu64
+						 " - ignoring", dev_name(dev),
+						 (uint64_t)xlate64(lh->sector_xl),
+						 sector + scan_sector);
 				continue;
 			}
 			if (calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl, LABEL_SIZE -
 				     ((uint8_t *) &lh->offset_xl - (uint8_t *) lh)) !=
 			    xlate32(lh->crc_xl)) {
-				log_info("Label checksum incorrect on %s - "
-					 "ignoring", dev_name(dev));
+				log_very_verbose("Label checksum incorrect on %s - "
+						 "ignoring", dev_name(dev));
 				continue;
 			}
 			if (found)
@@ -243,8 +243,8 @@ int label_remove(struct device *dev)
 		}
 
 		if (wipe) {
-			log_info("%s: Wiping label at sector %" PRIu64,
-				 dev_name(dev), sector);
+			log_very_verbose("%s: Wiping label at sector %" PRIu64,
+					 dev_name(dev), sector);
 			if (!dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE,
 				       buf)) {
 				log_error("Failed to remove label from %s@"
@@ -333,9 +333,9 @@ int label_write(struct device *dev, struct label *label)
 	if (!dev_open(dev))
 		return_0;
 
-	log_info("%s: Writing label to sector %" PRIu64 " with stored offset %"
-		 PRIu32 ".", dev_name(dev), label->sector,
-		 xlate32(lh->offset_xl));
+	log_very_verbose("%s: Writing label to sector %" PRIu64 " with stored offset %"
+			 PRIu32 ".", dev_name(dev), label->sector,
+			 xlate32(lh->offset_xl));
 	if (!dev_write(dev, label->sector << SECTOR_SHIFT, LABEL_SIZE, buf)) {
 		log_debug_devs("Failed to write label to %s", dev_name(dev));
 		r = 0;
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 3cddae4..73d7ae8 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4006,7 +4006,7 @@ int dm_stats_create_group(struct dm_stats *dms, const char *members,
 			 "precision may be lost");
 
 	if (!_stats_group_check_overlap(dms, regions, count))
-		log_info("Creating group with overlapping regions");
+		log_very_verbose("Creating group with overlapping regions.");
 
 	if (!_stats_create_group(dms, regions, alias, group_id))
 		goto bad;
@@ -4142,7 +4142,7 @@ static int _stats_group_file_regions(struct dm_stats *dms, uint64_t *region_ids,
 	 * returned by FIEMAP imply a kernel bug or a corrupt fs.
 	 */
 	if (!_stats_group_check_overlap(dms, regions, count))
-		log_info("Creating group with overlapping regions.");
+		log_very_verbose("Creating group with overlapping regions.");
 
 	if (!_stats_create_group(dms, regions, alias, &group_id))
 		goto bad;


