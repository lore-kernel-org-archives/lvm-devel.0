From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Feb 2016 12:39:07 +0000 (UTC)
Subject: master - filters: partitioned: fix partition table filter with external_device_info_source="udev" and blkid<2.20
Message-ID: <20160202123907.B213960DEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec43f55445966b5075fa8083921d182a0a138326
Commit:        ec43f55445966b5075fa8083921d182a0a138326
Parent:        762b0d697ff7456d0a450121e41eff00cd5a7f08
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 2 13:28:11 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 2 13:28:11 2016 +0100

filters: partitioned: fix partition table filter with external_device_info_source="udev" and blkid<2.20

Non-dm devices have ID_PART_TABLE_TYPE variable exported in
udev db from blkid scan for *both* whole devices and partitions.
We used ID_PART_ENTRY_DISK in addition to decide whether this
is the whole device or partition and then we filtered out only
whole devices where the partition table really is.

However, ID_PART_ENTRY_DISK was added in blkid 2.20 so we need
to use a different set of variables to decide on whole devices
and partitions on systems where older blkid is still used.

Now, we use ID_PART_TABLE_TYPE to detect that there's something
related to partitioning with this device and we use DEVTYPE variable
instead to decide between whole device (DEVTYPE="disk") and partition
(DEVTYPE="partition").

For dm devices it's simpler, we have ID_PART_TABLE_TYPE variable\
set in udev db for whole devices. It's not set for partitions,
hence we don't need more variable in addition to make the decision
on whole device vs. partition (dm devices do not have regular
partitions, hence DEVTYPE can't be used anyway, it's always set
to "disk" for whole disks and partitions).
---
 WHATS_NEW                           |    1 +
 lib/device/dev-ext-udev-constants.h |    4 +++-
 lib/device/dev-type.c               |   34 +++++++++++++++++++++++++++-------
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 96c7cd6..c2f22e9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.142 - 
 ====================================
+  Fix part. table filter with external_device_info_source="udev" and blkid<2.20.
 
 Version 2.02.141 - 25th January 2016
 ====================================
diff --git a/lib/device/dev-ext-udev-constants.h b/lib/device/dev-ext-udev-constants.h
index 2e2fb08..5b9a096 100644
--- a/lib/device/dev-ext-udev-constants.h
+++ b/lib/device/dev-ext-udev-constants.h
@@ -32,7 +32,9 @@
 #define DEV_EXT_UDEV_BLKID_TYPE_RAID_SUFFIX     "_raid_member"
 #define DEV_EXT_UDEV_BLKID_TYPE_SW_RAID         "linux_raid_member"
 #define DEV_EXT_UDEV_BLKID_PART_TABLE_TYPE      "ID_PART_TABLE_TYPE"
-#define DEV_EXT_UDEV_BLKID_PART_ENTRY_DISK      "ID_PART_ENTRY_DISK"
+
+#define DEV_EXT_UDEV_DEVTYPE			"DEVTYPE"
+#define DEV_EXT_UDEV_DEVTYPE_DISK		"disk"
 
 /*
  * DEV_EXT_UDEV_MPATH_DEVICE_PATH is set by multipath in udev db
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index b033462..a6223dc 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -333,23 +333,43 @@ static int _has_partition_table(struct device *dev)
 }
 
 #ifdef UDEV_SYNC_SUPPORT
-static int _udev_dev_is_partitioned(struct device *dev)
+static int _udev_dev_is_partitioned(struct dev_types *dt, struct device *dev)
 {
 	struct dev_ext *ext;
+	struct udev_device *device;
+	const char *value;
 
 	if (!(ext = dev_ext_get(dev)))
 		return_0;
 
-	if (!udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_PART_TABLE_TYPE))
+	device = (struct udev_device *) ext->handle;
+	if (!(value = udev_device_get_property_value(device, DEV_EXT_UDEV_BLKID_PART_TABLE_TYPE)))
 		return 0;
 
-	if (udev_device_get_property_value((struct udev_device *)ext->handle, DEV_EXT_UDEV_BLKID_PART_ENTRY_DISK))
-		return 0;
+	/*
+	 * Device-mapper devices have DEV_EXT_UDEV_BLKID_PART_TABLE_TYPE
+	 * variable set if there's partition table found on whole device.
+	 * Partitions do not have this variable set - it's enough to use
+	 * only this variable to decide whether this device has partition
+	 * table on it.
+	 */
+	if (MAJOR(dev->dev) == dt->device_mapper_major)
+		return 1;
 
-	return 1;
+	/*
+	 * Other devices have DEV_EXT_UDEV_BLKID_PART_TABLE_TYPE set for
+	 * *both* whole device and partitions. We need to look at the
+	 * DEV_EXT_UDEV_DEVTYPE in addition to decide - whole device
+	 * with partition table on it has this variable set to
+	 * DEV_EXT_UDEV_DEVTYPE_DISK.
+	 */
+	if (!(value = udev_device_get_property_value(device, DEV_EXT_UDEV_DEVTYPE)))
+		return_0;
+
+	return !strcmp(value, DEV_EXT_UDEV_DEVTYPE_DISK);
 }
 #else
-static int _udev_dev_is_partitioned(struct device *dev)
+static int _udev_dev_is_partitioned(struct dev_types *dt, struct device *dev)
 {
 	return 0;
 }
@@ -386,7 +406,7 @@ int dev_is_partitioned(struct dev_types *dt, struct device *dev)
 		return _native_dev_is_partitioned(dt, dev);
 
 	if (dev->ext.src == DEV_EXT_UDEV)
-		return _udev_dev_is_partitioned(dev);
+		return _udev_dev_is_partitioned(dt, dev);
 
 	log_error(INTERNAL_ERROR "Missing hook for partition table recognition "
 		  "using external device info source %s", dev_ext_name(dev));


