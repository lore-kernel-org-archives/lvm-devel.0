From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 30 Jul 2009 19:07:18 -0400
Subject: [PATCH 4/5] Retrieve MD sysfs attributes for MD partitions
In-Reply-To: <1248995239-19128-1-git-send-email-snitzer@redhat.com>
References: <1248995239-19128-1-git-send-email-snitzer@redhat.com>
Message-ID: <1248995239-19128-5-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Rename private _primary_dev() to a public get_primary_dev() and reuse it
to allow retrieval of the MD sysfs attributes (raid level, etc) for MD
partitions.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/device/dev-md.c |   13 +++++++++----
 lib/device/device.c |   12 +++++++++---
 lib/device/device.h |    3 +++
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 5525b4f..be33775 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -131,16 +131,21 @@ static int _md_sysfs_attribute_snprintf(char *path, size_t size,
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
+		if (get_primary_dev(sysfs_dir, dev, &_dev))
+			goto check_md_major;
 		return ret;
+	}
 
 	ret = dm_snprintf(path, size, "%s/dev/block/%d:%d/md/%s", sysfs_dir,
-			  (int)MAJOR(dev->dev), (int)MINOR(dev->dev), attribute);
+			  (int)MAJOR(_dev), (int)MINOR(_dev), attribute);
 	if (ret < 0) {
 		log_error("dm_snprintf md %s failed", attribute);
 		return ret;
@@ -149,7 +154,7 @@ static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 	if (stat(path, &info) < 0) {
 		/* old sysfs structure */
 		ret = dm_snprintf(path, size, "%s/block/md%d/md/%s",
-				  sysfs_dir, (int)MINOR(dev->dev), attribute);
+				  sysfs_dir, (int)MINOR(_dev), attribute);
 		if (ret < 0) {
 			log_error("dm_snprintf old md %s failed", attribute);
 			return ret;
diff --git a/lib/device/device.c b/lib/device/device.c
index 93cd4bb..24d5075 100644
--- a/lib/device/device.c
+++ b/lib/device/device.c
@@ -286,8 +286,8 @@ int _get_partition_type(struct dev_mgr *dm, struct device *d)
 
 #ifdef linux
 
-static int _primary_dev(const char *sysfs_dir,
-			struct device *dev, dev_t *result)
+int get_primary_dev(const char *sysfs_dir,
+		    struct device *dev, dev_t *result)
 {
 	char path[PATH_MAX+1];
 	char temp_path[PATH_MAX+1];
@@ -387,7 +387,7 @@ static unsigned long _dev_topology_attribute(const char *attribute,
 	 *   or the device could be a partition
 	 */
 	if (stat(path, &info) < 0) {
-		if (!_primary_dev(sysfs_dir, dev, &primary))
+		if (!get_primary_dev(sysfs_dir, dev, &primary))
 			return 0;
 
 		/* get attribute from partition's primary device */
@@ -450,6 +450,12 @@ unsigned long dev_optimal_io_size(const char *sysfs_dir,
 
 #else
 
+int get_primary_dev(const char *sysfs_dir,
+		    struct device *dev, dev_t *result)
+{
+	return 0;
+}
+
 unsigned long dev_alignment_offset(const char *sysfs_dir,
 				   struct device *dev)
 {
diff --git a/lib/device/device.h b/lib/device/device.h
index 454fd0b..4ccf9a9 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -100,6 +100,9 @@ unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev);
 
 int is_partitioned_dev(struct device *dev);
 
+int get_primary_dev(const char *sysfs_dir,
+		    struct device *dev, dev_t *result);
+
 unsigned long dev_alignment_offset(const char *sysfs_dir,
 				   struct device *dev);
 
-- 
1.6.2.5


