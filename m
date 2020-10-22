From: David Teigland <teigland@sourceware.org>
Date: Thu, 22 Oct 2020 20:43:15 +0000 (GMT)
Subject: master - lvmcache: rename label_read label_scan_dev
Message-ID: <20201022204315.9136239874CA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c7311d472203614b229cf17606d14fb53df85945
Commit:        c7311d472203614b229cf17606d14fb53df85945
Parent:        b3cdf0d881e63f16b8a29b26bbe3439798f44184
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 15 12:56:36 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 16:24:16 2020 -0500

lvmcache: rename label_read label_scan_dev

for consistent naming with other similar functions
---
 lib/cache/lvmcache.c | 2 +-
 lib/label/label.c    | 2 +-
 lib/label/label.h    | 3 +--
 tools/toollib.c      | 4 ++--
 4 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4b2590c4d..495748f22 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1116,7 +1116,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 		dm_list_iterate_items(devl, &add_cache_devs) {
 			log_debug_cache("Adding chosen duplicate %s", dev_name(devl->dev));
-			label_read(devl->dev);
+			label_scan_dev(devl->dev);
 		}
 
 		dm_list_splice(&_unused_duplicates, &del_cache_devs);
diff --git a/lib/label/label.c b/lib/label/label.c
index b06aaae00..a47cd1731 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1394,7 +1394,7 @@ void label_scan_destroy(struct cmd_context *cmd)
  * device, this is not a commonly used function.
  */
 
-int label_read(struct device *dev)
+int label_scan_dev(struct device *dev)
 {
 	struct dm_list one_dev;
 	struct device_list *devl;
diff --git a/lib/label/label.h b/lib/label/label.h
index 25913bb6d..8778c17a8 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -106,12 +106,11 @@ int label_scan(struct cmd_context *cmd);
 int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_excl(struct dm_list *devs);
+int label_scan_dev(struct device *dev);
 void label_scan_invalidate(struct device *dev);
 void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
 void label_scan_drop(struct cmd_context *cmd);
 void label_scan_destroy(struct cmd_context *cmd);
-int label_read(struct device *dev);
-int label_read_sector(struct device *dev, uint64_t scan_sector);
 void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
 int label_scan_open(struct device *dev);
diff --git a/tools/toollib.c b/tools/toollib.c
index f2372e095..0fbb0b6ec 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1451,7 +1451,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 			/*
 			 * add info to lvmcache from the duplicate dev.
 			 */
-			label_read(devl->dev);
+			label_scan_dev(devl->dev);
 
 			/*
 			 * the info/label should now be found because
@@ -4892,7 +4892,7 @@ static int _pvcreate_check_used(struct cmd_context *cmd,
 	 * If a VG is using the dev, it adds basic VG info for it to
 	 * lvmcache.
 	 */
-	label_read(pd->dev);
+	label_scan_dev(pd->dev);
 
 	if (!pd->dev->pvid[0]) {
 		log_debug("Check pvcreate arg %s no PVID found", dev_name(pd->dev));


