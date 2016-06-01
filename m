From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  1 Jun 2016 15:42:18 +0000 (UTC)
Subject: master - devices: handle partscan loop devices
Message-ID: <20160601154218.538E860613@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d37a26b680f6c7ca9ec0bb1ce0cca189d19b525f
Commit:        d37a26b680f6c7ca9ec0bb1ce0cca189d19b525f
Parent:        3d333e5a296eba8ba2858ca007699fe70ec8083e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 1 16:39:47 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 1 17:37:47 2016 +0200

devices: handle partscan loop devices

Treat loop device created with 'losetup -P' as regular
partitioned device - so if it has partition table,
prevent its usage in commands like 'pvcreate'.

Before 'pvcreate /dev/loop0' could have erased and formated as PV,
after this patch, device is filtered out and cannot be used.
---
 WHATS_NEW             |    1 +
 lib/device/dev-type.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 lib/device/dev-type.h |    1 +
 3 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1bad12a..74b5bdb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Automatically filter out partitioned loop devices with partscan (losetup -P).
   Fix lvm devtypes internal error if -S used with field name from pvs/vgs/lvs.
   When reporting Data%,Snap%,Meta%,Cpy%Sync use single ioctl per LV.
   Add lvseg_percent_with_info_and_seg_status() for percent retrieval.
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index f9f1418..0246c09 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -125,6 +125,9 @@ struct dev_types *create_dev_types(const char *proc_dir,
 		if (!strncmp("emcpower", line + i, 8) && isspace(*(line + i + 8)))
 			dt->emcpower_major = line_maj;
 
+		if (!strncmp("loop", line + i, 4) && isspace(*(line + i + 4)))
+			dt->loop_major = line_maj;
+
 		if (!strncmp("power2", line + i, 6) && isspace(*(line + i + 6)))
 			dt->power2_major = line_maj;
 
@@ -246,6 +249,9 @@ const char *dev_subsystem_name(struct dev_types *dt, struct device *dev)
 	if (MAJOR(dev->dev) == dt->blkext_major)
 		return "BLKEXT";
 
+	if (MAJOR(dev->dev) == dt->loop_major)
+		return "LOOP";
+
 	return "";
 }
 
@@ -265,6 +271,38 @@ int major_is_scsi_device(struct dev_types *dt, int major)
 	return (dt->dev_type_array[major].flags & PARTITION_SCSI_DEVICE) ? 1 : 0;
 }
 
+
+static int _loop_is_with_partscan(struct device *dev)
+{
+	FILE *fp;
+	int partscan = 0;
+	char path[PATH_MAX];
+	char buffer[64];
+
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/loop/partscan",
+			dm_sysfs_dir(),
+			(int) MAJOR(dev->dev),
+			(int) MINOR(dev->dev)) < 0) {
+		log_warn("Sysfs path for partscan is too long.");
+		return 0;
+	}
+
+	if (!(fp = fopen(path, "r")))
+		return 0; /* not there -> no partscan */
+
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_warn("Failed to read %s.", path);
+	} else if (sscanf(buffer, "%d", &partscan) != 1) {
+		log_warn("Failed to parse %s '%s'.", path, buffer);
+		partscan = 0;
+	}
+
+	if (fclose(fp))
+		log_sys_debug("fclose", path);
+
+	return partscan;
+}
+
 /* See linux/genhd.h and fs/partitions/msdos */
 #define PART_MAGIC 0xAA55
 #define PART_MAGIC_OFFSET UINT64_C(0x1FE)
@@ -294,6 +332,11 @@ static int _is_partitionable(struct dev_types *dt, struct device *dev)
 	if (MAJOR(dev->dev) == dt->md_major)
 		return 1;
 
+	/* All loop devices are partitionable via blkext (as of 3.2) */
+	if ((MAJOR(dev->dev) == dt->loop_major) &&
+	    _loop_is_with_partscan(dev))
+		return 1;
+
 	if ((parts <= 1) || (MINOR(dev->dev) % parts))
 		return 0;
 
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 6438b44..267b79f 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -43,6 +43,7 @@ struct dev_types {
 	int emcpower_major;
 	int power2_major;
 	int dasd_major;
+	int loop_major;
 	struct dev_type_def dev_type_array[NUMBER_OF_MAJORS];
 };
 


