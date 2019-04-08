From: David Teigland <teigland@sourceware.org>
Date: Mon, 8 Apr 2019 11:39:46 -0400
Subject: master - pvscan: print more reasons for ignoring devices
Message-ID: <201904081539.x38FdkLA023037@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6f18186bfd1a67ab0758a987ec53631bf19b0cb7
Commit:        6f18186bfd1a67ab0758a987ec53631bf19b0cb7
Parent:        48e9f116ae5bc0d8444936ffc263542c80d6fa17
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 5 14:03:38 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 5 15:48:12 2019 -0500

pvscan: print more reasons for ignoring devices

---
 lib/device/dev-cache.c |    7 ++++++-
 lib/device/dev-cache.h |    3 +--
 lib/label/label.c      |    2 +-
 tools/pvscan.c         |   28 +++++++++++++++++++++++-----
 4 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 8afebfe..1492181 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1505,7 +1505,7 @@ static struct device *_dev_cache_seek_devt(dev_t dev)
  * TODO This is very inefficient. We probably want a hash table indexed by
  * major:minor for keys to speed up these lookups.
  */
-struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct dev_filter *f)
+struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct dev_filter *f, int *filtered)
 {
 	char path[PATH_MAX];
 	const char *sysfs_dir;
@@ -1513,6 +1513,9 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 	struct device *d = _dev_cache_seek_devt(dev);
 	int ret;
 
+	if (filtered)
+		*filtered = 0;
+
 	if (d && (d->flags & DEV_REGULAR))
 		return d;
 
@@ -1557,6 +1560,8 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 	if (ret)
 		return d;
 
+	if (filtered)
+		*filtered = 1;
 	return NULL;
 }
 
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 9233c52..8a1c277 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -55,8 +55,7 @@ int dev_cache_add_dir(const char *path);
 struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct dev_filter *f);
 const char *dev_cache_filtered_reason(const char *name);
 
-// TODO
-struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t device, struct dev_filter *f);
+struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t device, struct dev_filter *f, int *filtered);
 
 void dev_set_preferred_name(struct dm_str_list *sl, struct device *dev);
 
diff --git a/lib/label/label.c b/lib/label/label.c
index f356e18..6b3d16c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1091,7 +1091,7 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 		return;
 
 	devt = MKDEV(lvinfo.major, lvinfo.minor);
-	if ((dev = dev_cache_get_by_devt(cmd, devt, NULL)))
+	if ((dev = dev_cache_get_by_devt(cmd, devt, NULL, NULL)))
 		label_scan_invalidate(dev);
 }
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index e3fd53a..376919b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -785,6 +785,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	int all_devs;
 	struct arg_value_group_list *current_group;
 	dev_t devno;
+	int filtered;
 	int do_activate = arg_is_set(cmd, activate_ARG);
 	int add_errors = 0;
 	int add_single_count = 0;
@@ -840,6 +841,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 				log_debug("pvscan arg %s not found.", pv_name);
 				if ((dev = dev_cache_get(cmd, pv_name, NULL))) {
 					/* nothing to do for this dev name */
+					log_print("pvscan[%d] device %s excluded by filter.", getpid(), dev_name(dev));
 				} else {
 					log_error("Physical Volume %s not found.", pv_name);
 					ret = ECMD_FAILED;
@@ -863,8 +865,15 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 			}
 			devno = MKDEV(major, minor);
 
-			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter))) {
-				log_debug("pvscan arg %d:%d not found.", major, minor);
+			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter, &filtered))) {
+				if (filtered) {
+					if ((dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL)))
+						log_print("pvscan[%d] device %d:%d %s excluded by filter.", getpid(), major, minor, dev_name(dev));
+					else
+						log_print("pvscan[%d] device %d:%d excluded by filter.", getpid(), major, minor);
+				} else
+					log_print("pvscan[%d] device %d:%d not found.", getpid(), major, minor);
+
 				if (!(dev = dm_pool_zalloc(cmd->mem, sizeof(struct device))))
 					return_0;
 				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
@@ -897,8 +906,15 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 		devno = MKDEV(major, minor);
 
-		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter))) {
-			log_debug("pvscan arg %d:%d not found.", major, minor);
+		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter, &filtered))) {
+			if (filtered) {
+				if ((dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL)))
+					log_print("pvscan[%d] device %d:%d %s excluded by filter.", getpid(), major, minor, dev_name(dev));
+				else
+					log_print("pvscan[%d] device %d:%d excluded by filter.", getpid(), major, minor);
+			} else
+				log_print("pvscan[%d] device %d:%d not found.", getpid(), major, minor);
+
 			if (!(dev = dm_pool_zalloc(cmd->mem, sizeof(struct device))))
 				return_0;
 			if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
@@ -969,8 +985,10 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		dm_list_iterate_items(devl, &add_devs) {
 			dev = devl->dev;
 
-			if (dev->flags & DEV_FILTER_OUT_SCAN)
+			if (dev->flags & DEV_FILTER_OUT_SCAN) {
+				log_print("pvscan[%d] device %s excluded by filter.", getpid(), dev_name(dev));
 				continue;
+			}
 
 			add_single_count++;
 


