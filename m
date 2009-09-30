From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 29 Sep 2009 20:28:18 -0400
Subject: [RFC][PATCH 4/5] dmeventd filtering failed devices
Message-ID: <4AC2A622.4020708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch filters out failed devices from the device list to prevent
those failed devices from being accessed by lvm commands, lvconvert
and vgreduce.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |  112 +++++++++++++++++++++-
 libdm/.exported_symbols                           |    1 
 libdm/libdevmapper.h                              |    1 
 libdm/libdm-deptree.c                             |   39 +++++++
 4 files changed, 151 insertions(+), 2 deletions(-)

Index: LVM2.02.54-20090928/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
===================================================================
--- LVM2.02.54-20090928.orig/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ LVM2.02.54-20090928/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -14,6 +14,7 @@
 
 #include "lvm2cmd.h"
 #include "errors.h"
+#include "kdev_t.h"
 
 #include <libdevmapper.h>
 #include <libdevmapper-event.h>
@@ -42,10 +43,12 @@ struct device {
 	char *dname;			/* device name (ex: /dev/sda) */
 	unsigned int major;
 	unsigned int minor;
+	int failed;
 };
 
 struct device_info {
 	struct dm_list dev_all;		/* all devices in the vg */
+  	struct dm_list dev_failed;	/* failed devices */
 	char filter_str[CMD_SIZE];
 };
 
@@ -85,6 +88,9 @@ static void _build_filter_str(struct dev
 	int len = 0, size, ct = 0;
 
 	dm_list_iterate_items(dev, &devi->dev_all) {
+		if (dev->failed)
+			continue;
+
 		size = dm_snprintf(devi->filter_str+len, CMD_SIZE-len,
 				   "%s\"a|%s$|\"",
 				   ct++ ? "," : "filter=[", dev->dname);
@@ -106,10 +112,107 @@ err:
 	return;
 }
 
+/*
+ * Register major:minor number of failed device. This function assumes to be
+ * called at most 9 times (8 mirror legs + 1 mirror log) and memory should
+ * be allocated beforehand. (360 byte = 40 byte * 9 for now)
+ */
+static void _register_failed_device(struct device_info *devi, char *dev_str)
+{
+	unsigned int major, minor;
+	struct device *dev;
+
+	if (!devi)
+		return;
+
+	if (sscanf(dev_str, "%u:%u", &major, &minor) != 2) {
+		syslog(LOG_ERR, "Unrecognized device number (%s)\n",
+		       dev_str);
+		return;
+	}
+
+	if (!(dev = dm_malloc(sizeof(*dev))))
+		return;
+
+	dev->major = major;
+	dev->minor = minor;
+
+	dm_list_add(&devi->dev_failed, &dev->list);
+}
+
+static void _release_failed_list(struct device_info *devi)
+{
+	struct device *dev, *devt;
+
+	if (!devi)
+		return;
+
+	dm_list_iterate_items_safe(dev, devt, &devi->dev_failed) {
+		dm_list_del(&dev->list);
+		dm_free(dev);
+	}
+}
+
+static void _mark_device_disabled(struct device_info *devi,
+				  unsigned int major, unsigned int minor)
+{
+	struct device *dev;
+
+	dm_list_iterate_items(dev, &devi->dev_all) {
+		if (dev->major == major && dev->minor == minor)
+			dev->failed = 1;
+	}
+}
+
+static void _walk_tree_and_disable_devices(struct dm_tree_node *node,
+					   struct device_info *devi)
+{
+	struct dm_tree_node *child;
+	void *handle = NULL;
+	const struct dm_info *info;
+
+	while ((child = dm_tree_next_child(&handle, node, 0))) {
+		if (dm_tree_node_num_children(child, 0))
+			_walk_tree_and_disable_devices(child, devi);
+		else {
+			info = dm_tree_node_get_info(child);
+			_mark_device_disabled(devi, info->major, info->minor);
+		}
+	}
+}
+
+static void _disable_devices(struct device_info *devi, struct dm_tree *dtree,
+			     unsigned int major, unsigned int minor)
+{
+	struct dm_tree_node *node;
+
+	if (!(node = dm_tree_find_node(dtree, major, minor))) {
+		syslog(LOG_ERR, "device (%u:%u) doesn't exist.\n",
+		       major, minor);
+		return;
+	}
+
+	_walk_tree_and_disable_devices(node, devi);
+}
+
 static void _create_filter(struct device_info *devi)
 {
+	struct dm_tree *dtree;
+	struct device *dev;
+
 	if (!devi)
 		return;
+
+	if (!(dtree = dm_build_deptree())) {
+		syslog(LOG_ERR, "Failed to get device information\n");
+		return;
+	}
+
+	dm_list_iterate_items(dev, &devi->dev_failed)
+		_disable_devices(devi, dtree, dev->major, dev->minor);
+
+	dm_tree_free(dtree);
+
 	_build_filter_str(devi);
 }
 
@@ -119,7 +222,7 @@ static void _destroy_filter(struct devic
 		devi->filter_str[0] = '\0';
 }
 
-static int _get_mirror_event(char *params)
+static int _get_mirror_event(char *params, struct device_info *devi)
 {
 	int i, r = ME_INSYNC;
 	char **args = NULL;
@@ -160,6 +263,7 @@ static int _get_mirror_event(char *param
 	for (i = 0; i < num_devs; i++)
 		if (dev_status_str[i] == 'D') {
 			syslog(LOG_ERR, "Mirror device, %s, has failed.\n", args[i]);
+			_register_failed_device(devi, args[i]);
 			r = ME_FAILURE;
 		}
 
@@ -167,6 +271,7 @@ static int _get_mirror_event(char *param
 	if (log_argc > 1 && log_status_str[0] == 'D') {
 		syslog(LOG_ERR, "Log device, %s, has failed.\n",
 		       args[2 + num_devs + log_argc]);
+		_register_failed_device(devi, args[2 + num_devs + log_argc]);
 		r = ME_FAILURE;
 	}
 
@@ -278,7 +383,7 @@ void process_event(struct dm_task *dmt,
 			continue;
 		}
 
-		switch(_get_mirror_event(params)) {
+		switch(_get_mirror_event(params, devi)) {
 		case ME_INSYNC:
 			/* FIXME: all we really know is that this
 			   _part_ of the device is in sync
@@ -304,6 +409,8 @@ void process_event(struct dm_task *dmt,
 			/* FIXME Provide value then! */
 			syslog(LOG_INFO, "Unknown event received.\n");
 		}
+
+		_release_failed_list(devi);
 	} while (next);
 
 	pthread_mutex_unlock(&_event_mutex);
@@ -355,6 +462,7 @@ static struct device_info *alloc_device_
 		return NULL;
 
 	dm_list_init(&devi->dev_all);
+	dm_list_init(&devi->dev_failed);
 
 	return devi;
 }
Index: LVM2.02.54-20090928/libdm/.exported_symbols
===================================================================
--- LVM2.02.54-20090928.orig/libdm/.exported_symbols
+++ LVM2.02.54-20090928/libdm/.exported_symbols
@@ -81,6 +81,7 @@ dm_tree_skip_lockfs
 dm_tree_use_no_flush_suspend
 dm_tree_set_cookie
 dm_tree_get_cookie
+dm_build_deptree
 dm_is_dm_major
 dm_mknodes
 dm_malloc_aux
Index: LVM2.02.54-20090928/libdm/libdevmapper.h
===================================================================
--- LVM2.02.54-20090928.orig/libdm/libdevmapper.h
+++ LVM2.02.54-20090928/libdm/libdevmapper.h
@@ -435,6 +435,7 @@ void dm_tree_node_set_read_ahead(struct 
 
 void dm_tree_set_cookie(struct dm_tree_node *node, uint32_t cookie);
 uint32_t dm_tree_get_cookie(struct dm_tree_node *node);
+struct dm_tree *dm_build_deptree(void);
 
 /*****************************************************************************
  * Library functions
Index: LVM2.02.54-20090928/libdm/libdm-deptree.c
===================================================================
--- LVM2.02.54-20090928.orig/libdm/libdm-deptree.c
+++ LVM2.02.54-20090928/libdm/libdm-deptree.c
@@ -1948,3 +1948,42 @@ uint32_t dm_tree_get_cookie(struct dm_tr
 {
 	return node->dtree->cookie;
 }
+
+struct dm_tree *dm_build_deptree(void)
+{
+	struct dm_tree *dtree;
+	struct dm_names *names;
+	struct dm_task *dmt = NULL;
+	unsigned next = 0;
+
+	if (!(dtree = dm_tree_create()))
+		return NULL;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_LIST)))
+		goto err;
+
+	if (!dm_task_run(dmt))
+		goto err;
+
+	if (!(names = dm_task_get_names(dmt)))
+		goto err;
+
+	if (!names->dev)
+		goto err;
+
+	do {
+		names = (void *)names + next;
+		if (!dm_tree_add_dev(dtree,
+				     (unsigned)MAJOR(names->dev),
+				     (unsigned)MINOR(names->dev)))
+			goto err;
+		next = names->next;
+	} while (next);
+
+	return dtree;
+err:
+	if (dmt)
+		dm_task_destroy(dmt);
+	dm_tree_free(dtree);
+	return NULL;
+}

-- 
Takahiro Yasui
Hitachi Computer Products (America), Inc.


