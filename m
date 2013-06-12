From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Jun 2013 11:16:58 +0000 (UTC)
Subject: master - dev-type: dev_get_primary_dev fn: use dev_types and provide better return codes
Message-ID: <20130612111658.083BF60F27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65d0089c6477e6bc30ef64ce9fd79e8c855c4529
Commit:        65d0089c6477e6bc30ef64ce9fd79e8c855c4529
Parent:        c6f48b7c1a0271255405346c50d6bee8cc8b9241
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 12 12:14:11 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 12 12:14:11 2013 +0200

dev-type: dev_get_primary_dev fn: use dev_types and provide better return codes

The dev_get_primary_dev fn now returns:

  0 if the dev is already a primary dev
  1 if the dev is a partition, primary dev is returned in "result" (output arg)
  -1 on error

This way, we can better differentiate between the error state
and the state in which the dev supplied is not a partition
in the caller (this was same return value before).

Also, if we already have information about the device type,
we can check its major number against the list of known device
types (cmd->dev_types) directly, so we don't need to go through
the sysfs - we only check the major:minor pair which is a bit
more straightforward and faster. If the dev_types does not have
any info about this device type, the code just fallbacks to
the original sysfs interface to get the partition info.
---
 lib/device/dev-md.c   |    2 +-
 lib/device/dev-type.c |   63 ++++++++++++++++++++++++++++++++++++------------
 2 files changed, 48 insertions(+), 17 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index a8bbe81..84d9ce3 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -141,7 +141,7 @@ static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 
 	if (MAJOR(dev) == dt->blkext_major) {
 		/* lookup parent MD device from blkext partition */
-		if (!dev_get_primary_dev(dt, blkdev, &dev))
+		if (dev_get_primary_dev(dt, blkdev, &dev) < 1)
 			return ret;
 	}
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 150daf4..92120e8 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -203,7 +203,7 @@ int dev_subsystem_part_major(struct dev_types *dt, struct device *dev)
 		return 1;
 
 	if ((MAJOR(dev->dev) == dt->blkext_major) &&
-	    (dev_get_primary_dev(dt, dev, &primary_dev)) &&
+	    (dev_get_primary_dev(dt, dev, &primary_dev) > 0) &&
 	    (MAJOR(primary_dev) == dt->md_major))
 		return 1;
 
@@ -318,28 +318,60 @@ int dev_is_partitioned(struct dev_types *dt, struct device *dev)
 	return _has_partition_table(dev);
 }
 
+/*
+ * Get primary dev for the dev supplied.
+ * Returns:
+ *   0 if the dev is already a primary dev
+ *   1 if the dev is a partition, primary dev in result
+ *   -1 on error
+ */
 int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
+	int major = (int) MAJOR(dev->dev);
+	int minor = (int) MINOR(dev->dev);
 	char path[PATH_MAX+1];
 	char temp_path[PATH_MAX+1];
 	char buffer[64];
 	struct stat info;
-	FILE *fp;
-	uint32_t pri_maj, pri_min;
-	int size, ret = 0;
+	FILE *fp = NULL;
+	int parts, residue, size, ret = -1;
+
+	/*
+	 * Try to get the primary dev out of the
+	 * list of known device types first.
+	 */
+	if ((parts = dt->dev_type_array[major].max_partitions) > 1) {
+		if ((residue = minor % parts)) {
+			*result = MKDEV((dev_t)major, (minor - residue));
+			ret = 1;
+		} else {
+			*result = dev->dev;
+			ret = 0; /* dev is not a partition! */
+		}
+		goto out;
+	}
+
+	/*
+	 * If we can't get the primary dev out of the list of known device
+	 * types, try to look at sysfs directly then. This is more complex
+	 * way and it also requires certain sysfs layout to be present
+	 * which might not be there in old kernels!
+	 */
 
 	/* check if dev is a partition */
 	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/partition",
-			sysfs_dir, (int)MAJOR(dev->dev), (int)MINOR(dev->dev)) < 0) {
+			sysfs_dir, major, minor) < 0) {
 		log_error("dm_snprintf partition failed");
-		return ret;
+		goto out;
 	}
 
 	if (stat(path, &info) == -1) {
 		if (errno != ENOENT)
 			log_sys_error("stat", path);
-		return ret;
+		*result = dev->dev;
+		ret = 0; goto out; /* dev is not a partition! */
+
 	}
 
 	/*
@@ -351,7 +383,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	 */
 	if ((size = readlink(dirname(path), temp_path, PATH_MAX)) < 0) {
 		log_sys_error("readlink", path);
-		return ret;
+		goto out;
 	}
 
 	temp_path[size] = '\0';
@@ -359,7 +391,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/dev",
 			sysfs_dir, basename(dirname(temp_path))) < 0) {
 		log_error("dm_snprintf dev failed");
-		return ret;
+		goto out;
 	}
 
 	/* finally, parse 'dev' attribute and create corresponding dev_t */
@@ -368,13 +400,13 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 			log_error("sysfs file %s does not exist", path);
 		else
 			log_sys_error("stat", path);
-		return ret;
+		goto out;
 	}
 
 	fp = fopen(path, "r");
 	if (!fp) {
 		log_sys_error("fopen", path);
-		return ret;
+		goto out;
 	}
 
 	if (!fgets(buffer, sizeof(buffer), fp)) {
@@ -382,16 +414,15 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 		goto out;
 	}
 
-	if (sscanf(buffer, "%d:%d", &pri_maj, &pri_min) != 2) {
+	if (sscanf(buffer, "%d:%d", &major, &minor) != 2) {
 		log_error("sysfs file %s not in expected MAJ:MIN format: %s",
 			  path, buffer);
 		goto out;
 	}
-	*result = MKDEV((dev_t)pri_maj, pri_min);
+	*result = MKDEV((dev_t)major, minor);
 	ret = 1;
-
 out:
-	if (fclose(fp))
+	if (fp && fclose(fp))
 		log_sys_error("fclose", path);
 
 	return ret;
@@ -615,7 +646,7 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 			log_sys_error("stat", path);
 			return 0;
 		}
-		if (!dev_get_primary_dev(dt, dev, &primary))
+		if (dev_get_primary_dev(dt, dev, &primary) < 0)
 			return 0;
 
 		/* get attribute from partition's primary device */


