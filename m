From: David Teigland <teigland@sourceware.org>
Date: Fri,  1 Apr 2022 18:38:37 +0000 (GMT)
Subject: main - devices file: warn about missing multipath entry
Message-ID: <20220401183837.286DB3858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e22be20c66b85ee161d170571c65b0f383010e4
Commit:        6e22be20c66b85ee161d170571c65b0f383010e4
Parent:        09371131469f7398c597a5fb30dc565859253cc2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 29 17:18:45 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 1 13:38:21 2022 -0500

devices file: warn about missing multipath entry

Warn if a scsi device is listed in the devices file that
is used by a multipath device that is not listed.  This
will happen if a scsi device is listed in the devices
file and then an mpath device is set up to use it.

The way to correct this would be to remove the devices
file entry for the component device and add a new entry
for the multipath device.
---
 lib/device/dev-mpath.c     | 10 +++++++---
 lib/device/dev-type.h      |  2 +-
 lib/device/device_id.c     | 11 +++++++++++
 lib/device/device_id.h     |  1 +
 lib/filters/filter-mpath.c | 19 ++++++++++++++++++-
 5 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index cbbad9dc9..808d5201f 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -272,7 +272,9 @@ static int _dev_is_mpath_component_udev(struct device *dev)
 }
 #endif
 
-static int _dev_is_mpath_component_sysfs(struct cmd_context *cmd, struct device *dev)
+/* mpath_devno is major:minor of the dm multipath device currently using the component dev. */
+
+static int _dev_is_mpath_component_sysfs(struct cmd_context *cmd, struct device *dev, dev_t *mpath_devno)
 {
 	struct dev_types *dt = cmd->dev_types;
 	const char *part_name;
@@ -426,6 +428,8 @@ static int _dev_is_mpath_component_sysfs(struct cmd_context *cmd, struct device
 	if (closedir(dr))
 		stack;
 
+	if (is_mpath_component)
+		*mpath_devno = MKDEV(dm_dev_major, dm_dev_minor);
 	return is_mpath_component;
 }
 
@@ -464,9 +468,9 @@ static int _dev_in_wwid_file(struct cmd_context *cmd, struct device *dev)
 	return 0;
 }
 
-int dev_is_mpath_component(struct cmd_context *cmd, struct device *dev)
+int dev_is_mpath_component(struct cmd_context *cmd, struct device *dev, dev_t *holder_devno)
 {
-	if (_dev_is_mpath_component_sysfs(cmd, dev) == 1)
+	if (_dev_is_mpath_component_sysfs(cmd, dev, holder_devno) == 1)
 		goto found;
 
 	if (_dev_in_wwid_file(cmd, dev))
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 36fb8f258..17c997641 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -58,7 +58,7 @@ int major_is_scsi_device(struct dev_types *dt, int major);
 
 /* Signature/superblock recognition with position returned where found. */
 int dev_is_md_component(struct cmd_context *cmd, struct device *dev, uint64_t *sb, int full);
-int dev_is_mpath_component(struct cmd_context *cmd, struct device *dev);
+int dev_is_mpath_component(struct cmd_context *cmd, struct device *dev, dev_t *mpath_devno);
 int dev_is_swap(struct cmd_context *cmd, struct device *dev, uint64_t *signature, int full);
 int dev_is_luks(struct cmd_context *cmd, struct device *dev, uint64_t *signature, int full);
 int dasd_is_cdl_formatted(struct device *dev);
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 7ce955b11..fa71874d0 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -887,6 +887,17 @@ static int _device_ids_use_lvmlv(struct cmd_context *cmd)
 	return 0;
 }
 
+struct dev_use *get_du_for_devno(struct cmd_context *cmd, dev_t devno)
+{
+	struct dev_use *du;
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->dev && du->dev->dev == devno)
+			return du;
+	}
+	return NULL;
+}
+
 struct dev_use *get_du_for_dev(struct cmd_context *cmd, struct device *dev)
 {
 	struct dev_use *du;
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index 5d352cd81..03c3ecaec 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -39,6 +39,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, uint16_t idtype);
 void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg, struct id *old_vg_id);
 
+struct dev_use *get_du_for_devno(struct cmd_context *cmd, dev_t devno);
 struct dev_use *get_du_for_dev(struct cmd_context *cmd, struct device *dev);
 struct dev_use *get_du_for_pvid(struct cmd_context *cmd, const char *pvid);
 struct dev_use *get_du_for_devname(struct cmd_context *cmd, const char *devname);
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 7644a5b0a..fc7cc51fa 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -15,6 +15,7 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
+#include "lib/device/device_id.h"
 
 #ifdef __linux__
 
@@ -22,11 +23,27 @@
 
 static int _ignore_mpath_component(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
 {
+	dev_t mpath_devno = 0;
+
 	dev->filtered_flags &= ~DEV_FILTERED_MPATH_COMPONENT;
 
-	if (dev_is_mpath_component(cmd, dev)) {
+	if (dev_is_mpath_component(cmd, dev, &mpath_devno)) {
 		log_debug_devs("%s: Skipping mpath component device", dev_name(dev));
 		dev->filtered_flags |= DEV_FILTERED_MPATH_COMPONENT;
+
+		/*
+		 * Warn about misconfig where an mpath component is
+		 * in the devices file, but its mpath device is not.
+		 */
+		if ((dev->flags & DEV_MATCHED_USE_ID) && mpath_devno) {
+			if (!get_du_for_devno(cmd, mpath_devno)) {
+				struct device *mpath_dev = dev_cache_get_by_devt(cmd, mpath_devno);
+				log_warn("WARNING: devices file is missing %s (%d:%d) using multipath component %s.",
+					 mpath_dev ? dev_name(mpath_dev) : "unknown",
+					 (int)MAJOR(mpath_devno), (int)MINOR(mpath_devno), dev_name(dev));
+			}
+		}
+
 		return 0;
 	}
 

