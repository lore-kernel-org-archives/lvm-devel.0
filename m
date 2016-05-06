From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:54 +0000 (UTC)
Subject: master - lvmcache: use active LVs and device sizes to choose between duplicates
Message-ID: <20160506140054.9344B60722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49d9582bed338dc555b616bcc9de20fafd00ce2d
Commit:        49d9582bed338dc555b616bcc9de20fafd00ce2d
Parent:        d4e434d1e6082ff4d448f4fbc03962c6f0926da4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 29 13:29:39 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

lvmcache: use active LVs and device sizes to choose between duplicates

If duplicate devices exist for a PV, and one device's
size matches the PV size, but the other doesn't, then
prefer the matching device.

If one device is used by an active LV, prefer that device.
---
 lib/cache/lvmcache.c |   90 ++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 76 insertions(+), 14 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f04f7ea..fe2ad07 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -816,15 +816,19 @@ static void _choose_preferred_devs(struct cmd_context *cmd,
 				   struct dm_list *add_cache_devs)
 {
 	char uuid[64] __attribute__((aligned(8)));
+	const char *reason = "none";
 	struct dm_list altdevs;
 	struct dev_types *dt = cmd->dev_types;
 	struct device_list *devl, *devl_safe, *alt, *del;
 	struct lvmcache_info *info;
 	struct device *dev1, *dev2;
 	uint32_t dev1_major, dev1_minor, dev2_major, dev2_minor;
+	uint64_t info_size, dev1_size, dev2_size;
 	int in_subsys1, in_subsys2;
 	int is_dm1, is_dm2;
 	int has_fs1, has_fs2;
+	int has_lv1, has_lv2;
+	int same_size1, same_size2;
 	int change;
 
 	/*
@@ -880,6 +884,14 @@ next:
 		dev2_major = MAJOR(dev2->dev);
 		dev2_minor = MINOR(dev2->dev);
 
+		if (!dev_get_size(dev1, &dev1_size))
+			dev1_size = 0;
+		if (!dev_get_size(dev2, &dev2_size))
+			dev2_size = 0;
+
+		has_lv1 = (dev1->flags & DEV_USED_FOR_LV) ? 1 : 0;
+		has_lv2 = (dev2->flags & DEV_USED_FOR_LV) ? 1 : 0;
+
 		in_subsys1 = dev_subsystem_part_major(dt, dev1);
 		in_subsys2 = dev_subsystem_part_major(dt, dev2);
 
@@ -889,44 +901,94 @@ next:
 		has_fs1 = dm_device_has_mounted_fs(dev1_major, dev1_minor);
 		has_fs2 = dm_device_has_mounted_fs(dev2_major, dev2_minor);
 
-		log_debug_cache("PV %s compare duplicates %s and %s",
-				devl->dev->pvid, dev_name(dev1), dev_name(dev2));
-
-		log_debug_cache("dup dev1 %s subsys %d dm %d fs %d",
-				dev_name(dev1), in_subsys1, is_dm1, has_fs1);
-		log_debug_cache("dup dev2 %s subsys %d dm %d fs %d",
-				dev_name(dev2), in_subsys2, is_dm2, has_fs2);
+		info_size = info->device_size >> SECTOR_SHIFT;
+		same_size1 = (dev1_size == info_size);
+		same_size2 = (dev2_size == info_size);
+
+		log_debug_cache("PV %s compare duplicates: %s %u:%u. %s %u:%u.",
+				devl->dev->pvid,
+				dev_name(dev1), dev1_major, dev1_minor,
+				dev_name(dev2), dev2_major, dev2_minor);
+
+		log_debug_cache("PV %s: wants size %llu. %s is %llu. %s is %llu.",
+				devl->dev->pvid,
+				(unsigned long long)info_size,
+				dev_name(dev1), (unsigned long long)dev1_size,
+				dev_name(dev2), (unsigned long long)dev2_size);
+
+		log_debug_cache("PV %s: %s %s subsystem. %s %s subsystem.",
+				devl->dev->pvid,
+				dev_name(dev1), in_subsys1 ? "is in" : "is not in",
+				dev_name(dev2), in_subsys2 ? "is in" : "is not in");
+
+		log_debug_cache("PV %s: %s %s dm. %s %s dm.",
+				devl->dev->pvid,
+				dev_name(dev1), is_dm1 ? "is" : "is not",
+				dev_name(dev2), is_dm2 ? "is" : "is not");
+
+		log_debug_cache("PV %s: %s %s mounted fs. %s %s mounted fs.",
+				devl->dev->pvid,
+				dev_name(dev1), has_fs1 ? "has" : "has no",
+				dev_name(dev2), has_fs2 ? "has" : "has no");
+
+		log_debug_cache("PV %s: %s %s LV. %s %s LV.",
+				devl->dev->pvid,
+				dev_name(dev1), has_lv1 ? "is used for" : "is not used for",
+				dev_name(dev2), has_lv2 ? "is used for" : "is not used for");
 
 		change = 0;
 
-		if (has_fs1 && !has_fs2) {
+		if (has_lv1 && !has_lv2) {
 			/* keep 1 */
+			reason = "device is used by LV";
+		} else if (has_lv2 && !has_lv1) {
+			/* change to 2 */
+			change = 1;
+			reason = "device is used by LV";
+		} else if (same_size1 && !same_size2) {
+			/* keep 1 */
+			reason = "device size is correct";
+		} else if (same_size2 && !same_size1) {
+			/* change to 2 */
+			change = 1;
+			reason = "device size is correct";
+		} else if (has_fs1 && !has_fs2) {
+			/* keep 1 */
+			reason = "device has fs mounted";
 		} else if (has_fs2 && !has_fs1) {
 			/* change to 2 */
 			change = 1;
+			reason = "device has fs mounted";
 		} else if (is_dm1 && !is_dm2) {
 			/* keep 1 */
+			reason = "device is in dm subsystem";
 		} else if (is_dm2 && !is_dm1) {
 			/* change to 2 */
 			change = 1;
+			reason = "device is in dm subsystem";
 		} else if (in_subsys1 && !in_subsys2) {
 			/* keep 1 */
+			reason = "device is in subsystem";
 		} else if (in_subsys2 && !in_subsys1) {
 			/* change to 2 */
 			change = 1;
+			reason = "device is in subsystem";
+		} else {
+			reason = "device was seen first";
 		}
 
 		if (change) {
 			dev1 = dev2;
 			alt = devl;
 		}
-	}
 
-	id_write_format((const struct id *)info->dev->pvid, uuid, sizeof(uuid));
+		id_write_format((const struct id *)dev1->pvid, uuid, sizeof(uuid));
+		log_warn("WARNING: PV %s prefers device %s because %s.", uuid, dev_name(dev1), reason);
+	}
 
 	if (dev1 != info->dev) {
-		log_warn("PV %s is using preferred device %s, changed from %s",
-			 uuid, dev_name(dev1), dev_name(info->dev));
+		log_debug_cache("PV %s: switching to device %s instead of device %s.",
+				 dev1->pvid, dev_name(dev1), dev_name(info->dev));
 		/*
 		 * Move the preferred device from altdevs to add_cache_devs.
 		 * Create a del_cache_devs entry for the current lvmcache
@@ -939,9 +1001,9 @@ next:
 			del->dev = info->dev;
 			dm_list_add(del_cache_devs, &del->list);
 		}
+
 	} else {
-		log_warn("PV %s is using preferred device %s",
-			 uuid, dev_name(info->dev));
+		log_debug_cache("PV %s: keeping current device %s.", dev1->pvid, dev_name(info->dev));
 	}
 
 	/*


