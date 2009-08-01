From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 1 Aug 2009 17:11:02 -0000
Subject: LVM2/lib/device dev-md.c device.c device.h
Message-ID: <20090801171102.3016.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-08-01 17:11:02

Modified files:
	lib/device     : dev-md.c device.c device.h 

Log message:
	Retrieve MD sysfs attributes for MD partitions
	
	Rename private _primary_dev() to a public get_primary_dev() and reuse it
	to allow retrieval of the MD sysfs attributes (raid level, etc) for MD
	partitions.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/lib/device/dev-md.c	2009/07/20 18:44:13	1.16
+++ LVM2/lib/device/dev-md.c	2009/08/01 17:11:02	1.17
@@ -127,20 +127,25 @@
 
 static int _md_sysfs_attribute_snprintf(char *path, size_t size,
 					const char *sysfs_dir,
-					struct device *dev,
+					struct device *blkdev,
 					const char *attribute)
 {
 	struct stat info;
+	dev_t dev = blkdev->dev;
 	int ret = -1;
 
-	if (MAJOR(dev->dev) != md_major())
+	if (!sysfs_dir || !*sysfs_dir)
 		return ret;
 
-	if (!sysfs_dir || !*sysfs_dir)
+check_md_major:
+	if (MAJOR(dev) != md_major()) {
+		if (get_primary_dev(sysfs_dir, blkdev, &dev))
+			goto check_md_major;
 		return ret;
+	}
 
 	ret = dm_snprintf(path, size, "%s/dev/block/%d:%d/md/%s", sysfs_dir,
-			  (int)MAJOR(dev->dev), (int)MINOR(dev->dev), attribute);
+			  (int)MAJOR(dev), (int)MINOR(dev), attribute);
 	if (ret < 0) {
 		log_error("dm_snprintf md %s failed", attribute);
 		return ret;
@@ -149,7 +154,7 @@
 	if (stat(path, &info) < 0) {
 		/* old sysfs structure */
 		ret = dm_snprintf(path, size, "%s/block/md%d/md/%s",
-				  sysfs_dir, (int)MINOR(dev->dev), attribute);
+				  sysfs_dir, (int)MINOR(dev), attribute);
 		if (ret < 0) {
 			log_error("dm_snprintf old md %s failed", attribute);
 			return ret;
--- LVM2/lib/device/device.c	2009/08/01 17:09:48	1.30
+++ LVM2/lib/device/device.c	2009/08/01 17:11:02	1.31
@@ -286,8 +286,8 @@
 
 #ifdef linux
 
-static int _primary_dev(const char *sysfs_dir,
-			struct device *dev, dev_t *result)
+int get_primary_dev(const char *sysfs_dir,
+		    struct device *dev, dev_t *result)
 {
 	char path[PATH_MAX+1];
 	char temp_path[PATH_MAX+1];
@@ -387,7 +387,7 @@
 	 *   or the device could be a partition
 	 */
 	if (stat(path, &info) < 0) {
-		if (!_primary_dev(sysfs_dir, dev, &primary))
+		if (!get_primary_dev(sysfs_dir, dev, &primary))
 			return 0;
 
 		/* get attribute from partition's primary device */
@@ -450,6 +450,12 @@
 
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
--- LVM2/lib/device/device.h	2009/08/01 17:08:44	1.42
+++ LVM2/lib/device/device.h	2009/08/01 17:11:02	1.43
@@ -100,6 +100,9 @@
 
 int is_partitioned_dev(struct device *dev);
 
+int get_primary_dev(const char *sysfs_dir,
+		    struct device *dev, dev_t *result);
+
 unsigned long dev_alignment_offset(const char *sysfs_dir,
 				   struct device *dev);
 


