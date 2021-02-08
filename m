From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 23:50:24 +0000 (GMT)
Subject: main - dev-type: sysfs attrs without sectors
Message-ID: <20210208235024.3AE67385480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=427121efc76f1a11df5d06c11ea4f095305b6333
Commit:        427121efc76f1a11df5d06c11ea4f095305b6333
Parent:        ef2e0d3d680829ad4f4253787cd7a0db0c4597d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 9 00:43:13 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 9 00:49:14 2021 +0100

dev-type: sysfs attrs without sectors

Split function for reading attrs in sectors.
---
 lib/device/dev-type.c | 56 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 36 insertions(+), 20 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 11add4b6b..b7bca361f 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -936,17 +936,16 @@ static int _snprintf_attr(char *buf, size_t buf_size, const char *sysfs_dir,
 	return 1;
 }
 
-static unsigned long _dev_topology_attribute(struct dev_types *dt,
-					     const char *attribute,
-					     struct device *dev,
-					     unsigned long default_value)
+static int _dev_sysfs_block_attribute(struct dev_types *dt,
+				      const char *attribute,
+				      struct device *dev,
+				      unsigned long *value)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
 	char path[PATH_MAX], buffer[64];
 	FILE *fp;
 	dev_t primary = 0;
-	unsigned long result = default_value;
-	unsigned long value = 0UL;
+	int ret = 0;
 
 	if (!attribute || !*attribute)
 		goto_out;
@@ -955,7 +954,7 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 		goto_out;
 
 	if (!_snprintf_attr(path, sizeof(path), sysfs_dir, attribute, dev->dev))
-                goto_out;
+		goto_out;
 
 	/*
 	 * check if the desired sysfs attribute exists
@@ -986,27 +985,42 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 		goto out_close;
 	}
 
-	if (sscanf(buffer, "%lu", &value) != 1) {
+	if (sscanf(buffer, "%lu", value) != 1) {
 		log_warn("WARNING: sysfs file %s not in expected format: %s", path, buffer);
 		goto out_close;
 	}
 
-	log_very_verbose("Device %s: %s is %lu%s.",
-			 dev_name(dev), attribute, value, default_value ? "" : " bytes");
-
-	result = value >> SECTOR_SHIFT;
-
-	if (!result && value) {
-		log_warn("WARNING: Device %s: %s is %lu and is unexpectedly less than sector.",
-			 dev_name(dev), attribute, value);
-		result = 1;
-	}
+	ret = 1;
 
 out_close:
 	if (fclose(fp))
 		log_sys_debug("fclose", path);
 
 out:
+	return ret;
+}
+
+static unsigned long _dev_topology_attribute(struct dev_types *dt,
+					     const char *attribute,
+					     struct device *dev,
+					     unsigned long default_value)
+{
+	unsigned long result = default_value;
+	unsigned long value = 0UL;
+
+	if (_dev_sysfs_block_attribute(dt, attribute, dev, &value)) {
+		log_very_verbose("Device %s: %s is %lu%s.",
+				 dev_name(dev), attribute, value, default_value ? "" : " bytes");
+
+		result = value >> SECTOR_SHIFT;
+
+		if (!result && value) {
+			log_warn("WARNING: Device %s: %s is %lu and is unexpectedly less than sector.",
+				 dev_name(dev), attribute, value);
+			result = 1;
+		}
+	}
+
 	return result;
 }
 
@@ -1037,13 +1051,15 @@ unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev)
 
 int dev_is_rotational(struct dev_types *dt, struct device *dev)
 {
-	return (int) _dev_topology_attribute(dt, "queue/rotational", dev, 1UL);
+	unsigned long value;
+	return _dev_sysfs_block_attribute(dt, "queue/rotational", dev, &value) ? (int) value : 1;
 }
 
 /* dev is pmem if /sys/dev/block/<major>:<minor>/queue/dax is 1 */
 int dev_is_pmem(struct dev_types *dt, struct device *dev)
 {
-	return (int) _dev_topology_attribute(dt, "queue/dax", dev, 0UL);
+	unsigned long value;
+	return _dev_sysfs_block_attribute(dt, "queue/dax", dev, &value) ? (int) value : 0;
 }
 
 #else


