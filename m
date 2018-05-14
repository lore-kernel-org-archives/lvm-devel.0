From: David Teigland <teigland@sourceware.org>
Date: Mon, 14 May 2018 14:47:14 -0400
Subject: master - scan: add some missing frees
Message-ID: <201805141847.w4EIlE01009784@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=517d6cc418da0ba08a971b6d537cdfada7a5b1cb
Commit:        517d6cc418da0ba08a971b6d537cdfada7a5b1cb
Parent:        0e56fa6892093700273cf3501f6ad589545628a9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 14 13:38:16 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 14 13:38:16 2018 -0500

scan: add some missing frees

some objects had been moved out of mem pools.
---
 lib/cache/lvmcache.c |   10 +++++++++-
 lib/label/label.c    |    9 ++++++++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 382edcd..12c1c99 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1001,6 +1001,7 @@ static void _filter_duplicate_devs(struct cmd_context *cmd)
 		if (MAJOR(info->dev->dev) == dt->md_major) {
 			log_debug_devs("Ignoring md component duplicate %s", dev_name(devl->dev));
 			dm_list_del(&devl->list);
+			dm_free(devl);
 		}
 	}
 }
@@ -1307,7 +1308,7 @@ next:
 int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const char *vgid)
 {
 	struct dm_list devs;
-	struct device_list *devl;
+	struct device_list *devl, *devl2;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info, *info2;
 
@@ -1338,6 +1339,7 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 		dm_list_add(&devs, &devl->list);
 	}
 
+	/* Deleting the last info will delete vginfo. */
 	dm_list_iterate_items_safe(info, info2, &vginfo->infos)
 		lvmcache_del(info);
 
@@ -1350,6 +1352,11 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 
 	label_scan_devs(cmd, cmd->filter, &devs);
 
+	dm_list_iterate_items_safe(devl, devl2, &devs) {
+		dm_list_del(&devl->list);
+		dm_free(devl);
+	}
+
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
 		log_warn("VG info not found after rescan of %s", vgname);
 		return 0;
@@ -1749,6 +1756,7 @@ void lvmcache_del(struct lvmcache_info *info)
 
 	info->label->labeller->ops->destroy_label(info->label->labeller,
 						  info->label);
+	label_destroy(info->label);
 	dm_free(info);
 }
 
diff --git a/lib/label/label.c b/lib/label/label.c
index cd54b69..b073647 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -666,7 +666,7 @@ int label_scan(struct cmd_context *cmd)
 {
 	struct dm_list all_devs;
 	struct dev_iter *iter;
-	struct device_list *devl;
+	struct device_list *devl, *devl2;
 	struct device *dev;
 
 	log_debug_devs("Finding devices to scan");
@@ -718,6 +718,11 @@ int label_scan(struct cmd_context *cmd)
 
 	_scan_list(cmd, cmd->full_filter, &all_devs, NULL);
 
+	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
+		dm_list_del(&devl->list);
+		dm_free(devl);
+	}
+
 	return 1;
 }
 
@@ -867,6 +872,8 @@ int label_read(struct device *dev)
 
 	_scan_list(NULL, NULL, &one_dev, &failed);
 
+	dm_free(devl);
+
 	if (failed)
 		return 0;
 	return 1;


