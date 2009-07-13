From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 13 Jul 2009 16:11:21 -0400
Subject: [PATCH 5/6] Retrieve MD sysfs attributes for MD partitions
In-Reply-To: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
Message-ID: <1247515882-13736-6-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Rename private _primary_dev() to a public primary_dev() and reuse it to
allow retrieval of the MD sysfs attributes (raid level, etc) for MD
partitions.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/device/dev-md.c |   13 +++++++++----
 lib/device/device.c |   12 +++++++++---
 lib/device/device.h |    3 +++
 3 files changed, 21 insertions(+), 7 deletions(-)

Index: LVM2/lib/device/dev-md.c
===================================================================
--- LVM2.orig/lib/device/dev-md.c
+++ LVM2/lib/device/dev-md.c
@@ -131,16 +131,21 @@ static int _md_sysfs_attribute_snprintf(
 					const char *attribute)
 {
 	struct stat info;
+	dev_t _dev = dev->dev;
 	int ret = -1;
 
-	if (MAJOR(dev->dev) != md_major())
+	if (!sysfs_dir || !*sysfs_dir)
 		return ret;
 
-	if (!sysfs_dir || !*sysfs_dir)
+check_md_major:
+	if (MAJOR(_dev) != md_major()) {
+		if (primary_dev(sysfs_dir, dev, &_dev))
+			goto check_md_major;
 		return ret;
+	}
 
 	ret = dm_snprintf(path, size, "%s/dev/block/%d:%d/md/%s",
-	      sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev), attribute);
+	      sysfs_dir, MAJOR(_dev), MINOR(_dev), attribute);
 	if (ret < 0) {
 		log_error("dm_snprintf md %s failed", attribute);
 		return ret;
@@ -149,7 +154,7 @@ static int _md_sysfs_attribute_snprintf(
 	if (stat(path, &info) < 0) {
 		/* old sysfs structure */
 		ret = dm_snprintf(path, size, "%s/block/md%d/md/%s",
-				  sysfs_dir, MINOR(dev->dev), attribute);
+				  sysfs_dir, MINOR(_dev), attribute);
 		if (ret < 0) {
 			log_error("dm_snprintf old md %s failed", attribute);
 			return ret;
Index: LVM2/lib/device/device.c
===================================================================
--- LVM2.orig/lib/device/device.c
+++ LVM2/lib/device/device.c
@@ -286,8 +286,8 @@ int _get_partition_type(struct dev_mgr *
 
 #ifdef linux
 
-static int _primary_dev(const char *sysfs_dir,
-			struct device *dev, dev_t *result)
+int primary_dev(const char *sysfs_dir,
+		struct device *dev, dev_t *result)
 {
 	char path[PATH_MAX+1], temp_path[PATH_MAX+1], buffer[64];
 	struct stat info;
@@ -378,7 +378,7 @@ static unsigned long _dev_topology_attri
 	 *   or the device could be a partition
 	 */
 	if (stat(path, &info) < 0) {
-		if (!_primary_dev(sysfs_dir, dev, &primary))
+		if (!primary_dev(sysfs_dir, dev, &primary))
 			return 0;
 
 		/* get attribute from partition's primary device */
@@ -441,6 +441,12 @@ unsigned long dev_optimal_io_size(const 
 
 #else
 
+int primary_dev(const char *sysfs_dir,
+		struct device *dev, dev_t *result)
+{
+	return 0;
+}
+
 unsigned long dev_alignment_offset(const char *sysfs_dir,
 				   struct device *dev)
 {
Index: LVM2/lib/device/device.h
===================================================================
--- LVM2.orig/lib/device/device.h
+++ LVM2/lib/device/device.h
@@ -100,6 +100,9 @@ unsigned long dev_md_stripe_width(const 
 
 int is_partitioned_dev(struct device *dev);
 
+int primary_dev(const char *sysfs_dir,
+		struct device *dev, dev_t *result);
+
 unsigned long dev_alignment_offset(const char *sysfs_dir,
 				   struct device *dev);
 


