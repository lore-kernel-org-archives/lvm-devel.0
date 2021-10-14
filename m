From: David Teigland <teigland@sourceware.org>
Date: Thu, 14 Oct 2021 19:04:19 +0000 (GMT)
Subject: main - fix segfault handling duplicate PVs
Message-ID: <20211014190419.9104B3858412@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c38473548e546c8e94d41587714f350a11362c84
Commit:        c38473548e546c8e94d41587714f350a11362c84
Parent:        e88163ceac0ca7d78ab728867a6e84d0e535ad1d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 14 14:02:59 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 14 14:02:59 2021 -0500

fix segfault handling duplicate PVs

cmd arg was missing when switching to use an alternative
duplicate dev.
---
 lib/cache/lvmcache.c | 2 +-
 lib/label/label.c    | 4 ++--
 lib/label/label.h    | 2 +-
 tools/toollib.c      | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2c4254324..bee63ebb4 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1349,7 +1349,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 		dm_list_iterate_items(devl, &add_cache_devs) {
 			log_debug_cache("Adding chosen duplicate %s", dev_name(devl->dev));
-			label_scan_dev(devl->dev);
+			label_scan_dev(cmd, devl->dev);
 		}
 
 		dm_list_splice(&_unused_duplicates, &del_cache_devs);
diff --git a/lib/label/label.c b/lib/label/label.c
index b8f0dc84d..3cd912270 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1488,7 +1488,7 @@ void label_scan_destroy(struct cmd_context *cmd)
  * device, this is not a commonly used function.
  */
 
-int label_scan_dev(struct device *dev)
+int label_scan_dev(struct cmd_context *cmd, struct device *dev)
 {
 	struct dm_list one_dev;
 	struct device_list *devl;
@@ -1503,7 +1503,7 @@ int label_scan_dev(struct device *dev)
 
 	label_scan_invalidate(dev);
 
-	_scan_list(NULL, NULL, &one_dev, 0, &failed);
+	_scan_list(cmd, NULL, &one_dev, 0, &failed);
 
 	free(devl);
 
diff --git a/lib/label/label.h b/lib/label/label.h
index 32ceebc34..8b510eb79 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -107,7 +107,7 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
 int label_scan_devs_cached(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_excl(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
-int label_scan_dev(struct device *dev);
+int label_scan_dev(struct cmd_context *cmd, struct device *dev);
 void label_scan_invalidate(struct device *dev);
 void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
 void label_scan_drop(struct cmd_context *cmd);
diff --git a/tools/toollib.c b/tools/toollib.c
index c05a973d5..5b67669e1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1481,7 +1481,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 			/*
 			 * add info to lvmcache from the duplicate dev.
 			 */
-			label_scan_dev(devl->dev);
+			label_scan_dev(cmd, devl->dev);
 
 			/*
 			 * the info/label should now be found because


