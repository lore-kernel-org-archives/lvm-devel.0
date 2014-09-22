From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:37 +0000 (UTC)
Subject: dev-dct-process-latest - devices: Detect rotational devices.
Message-ID: <20140922153837.6262D602D6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9c16b750694c4ec03d05bc9e4a12cecc4d9450f
Commit:        b9c16b750694c4ec03d05bc9e4a12cecc4d9450f
Parent:        979be63f2537373b49e47aa3e8ce3f9bf2a4279f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 16 00:44:25 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 16 00:44:25 2014 +0100

devices: Detect rotational devices.

Add dev_is_rotational() for future use by allocation code.
---
 WHATS_NEW             |    1 +
 lib/device/dev-type.c |   57 ++++++++++++++++++++++++++++++-------------------
 lib/device/dev-type.h |    2 +
 3 files changed, 38 insertions(+), 22 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 70d8a9a..5b8a32f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Add function to detect rotational devices.
   Review internal checks for mirror/raid/pvmove volumes.
   Track mirror segment type with separate MIRROR flag.
   Fix cmirror endian conversions.
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index ecceb2d..6fcfa08 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -655,23 +655,25 @@ static int _snprintf_attr(char *buf, size_t buf_size, const char *sysfs_dir,
 
 static unsigned long _dev_topology_attribute(struct dev_types *dt,
 					     const char *attribute,
-					     struct device *dev)
+					     struct device *dev,
+					     unsigned long default_value)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
 	char path[PATH_MAX], buffer[64];
 	FILE *fp;
 	struct stat info;
 	dev_t uninitialized_var(primary);
-	unsigned long result = 0UL;
+	unsigned long result = default_value;
+	unsigned long value = 0UL;
 
 	if (!attribute || !*attribute)
-		return_0;
+		goto_out;
 
 	if (!sysfs_dir || !*sysfs_dir)
-		return_0;
+		goto_out;
 
 	if (!_snprintf_attr(path, sizeof(path), sysfs_dir, attribute, dev->dev))
-                return_0;
+                goto_out;
 
 	/*
 	 * check if the desired sysfs attribute exists
@@ -681,72 +683,79 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 	if (stat(path, &info) == -1) {
 		if (errno != ENOENT) {
 			log_sys_debug("stat", path);
-			return 0;
+			goto out;
 		}
 		if (!dev_get_primary_dev(dt, dev, &primary))
-			return 0;
+			goto out;
 
 		/* get attribute from partition's primary device */
 		if (!_snprintf_attr(path, sizeof(path), sysfs_dir, attribute, primary))
-			return_0;
+			goto_out;
 
 		if (stat(path, &info) == -1) {
 			if (errno != ENOENT)
 				log_sys_debug("stat", path);
-			return 0;
+			goto out;
 		}
 	}
 
 	if (!(fp = fopen(path, "r"))) {
 		log_sys_debug("fopen", path);
-		return 0;
+		goto out;
 	}
 
 	if (!fgets(buffer, sizeof(buffer), fp)) {
 		log_sys_debug("fgets", path);
-		goto out;
+		goto out_close;
 	}
 
-	if (sscanf(buffer, "%lu", &result) != 1) {
+	if (sscanf(buffer, "%lu", &value) != 1) {
 		log_warn("sysfs file %s not in expected format: %s", path, buffer);
-		goto out;
+		goto out_close;
 	}
 
-	log_very_verbose("Device %s %s is %lu bytes.",
-			 dev_name(dev), attribute, result);
+	log_very_verbose("Device %s: %s is %lu%s.",
+			 dev_name(dev), attribute, result, default_value ? "" : " bytes");
 
-out:
+	result = value >> SECTOR_SHIFT;
+
+out_close:
 	if (fclose(fp))
 		log_sys_debug("fclose", path);
 
-	return result >> SECTOR_SHIFT;
+out:
+	return result;
 }
 
 unsigned long dev_alignment_offset(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute(dt, "alignment_offset", dev);
+	return _dev_topology_attribute(dt, "alignment_offset", dev, 0UL);
 }
 
 unsigned long dev_minimum_io_size(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute(dt, "queue/minimum_io_size", dev);
+	return _dev_topology_attribute(dt, "queue/minimum_io_size", dev, 0UL);
 }
 
 unsigned long dev_optimal_io_size(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute(dt, "queue/optimal_io_size", dev);
+	return _dev_topology_attribute(dt, "queue/optimal_io_size", dev, 0UL);
 }
 
 unsigned long dev_discard_max_bytes(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute(dt, "queue/discard_max_bytes", dev);
+	return _dev_topology_attribute(dt, "queue/discard_max_bytes", dev, 0UL);
 }
 
 unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev)
 {
-	return _dev_topology_attribute(dt, "queue/discard_granularity", dev);
+	return _dev_topology_attribute(dt, "queue/discard_granularity", dev, 0UL);
 }
 
+int dev_is_rotational(struct dev_types *dt, struct device *dev)
+{
+	return (int) _dev_topology_attribute(dt, "queue/rotational", dev, 1UL);
+}
 #else
 
 int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
@@ -779,4 +788,8 @@ unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev)
 	return 0UL;
 }
 
+int dev_is_rotational(struct dev_types *dt, struct device *dev)
+{
+	return 1;
+}
 #endif
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index b1520ee..8dcd4c8 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -82,4 +82,6 @@ unsigned long dev_optimal_io_size(struct dev_types *dt, struct device *dev);
 unsigned long dev_discard_max_bytes(struct dev_types *dt, struct device *dev);
 unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev);
 
+int dev_is_rotational(struct dev_types *dt, struct device *dev);
+
 #endif


