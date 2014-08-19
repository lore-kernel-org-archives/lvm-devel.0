From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:18:57 +0000 (UTC)
Subject: master - cleanup: use _ prefix for static functions
Message-ID: <20140819141857.BF4DE6030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5cd3b5c0cf562edc3ec2d860b4d51313525e4130
Commit:        5cd3b5c0cf562edc3ec2d860b4d51313525e4130
Parent:        3e4a21427bdba7d6cfc9083e8c3736707ab31cc0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 18 17:34:01 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:06 2014 +0200

cleanup: use _ prefix for static functions

---
 lib/filters/filter-mpath.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 902cc25..468dc6c 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -22,7 +22,7 @@
 
 #define MPATH_PREFIX "mpath-"
 
-static const char *get_sysfs_name(struct device *dev)
+static const char *_get_sysfs_name(struct device *dev)
 {
 	const char *name;
 
@@ -40,7 +40,7 @@ static const char *get_sysfs_name(struct device *dev)
 	return name;
 }
 
-static const char *get_sysfs_name_by_devt(const char *sysfs_dir, dev_t devno,
+static const char *_get_sysfs_name_by_devt(const char *sysfs_dir, dev_t devno,
 					  char *buf, size_t buf_size)
 {
 	const char *name;
@@ -68,7 +68,7 @@ static const char *get_sysfs_name_by_devt(const char *sysfs_dir, dev_t devno,
 	return name;
 }
 
-static int get_sysfs_string(const char *path, char *buffer, int max_size)
+static int _get_sysfs_string(const char *path, char *buffer, int max_size)
 {
 	FILE *fp;
 	int r = 0;
@@ -89,7 +89,7 @@ static int get_sysfs_string(const char *path, char *buffer, int max_size)
 	return r;
 }
 
-static int get_sysfs_get_major_minor(const char *sysfs_dir, const char *kname, int *major, int *minor)
+static int _get_sysfs_get_major_minor(const char *sysfs_dir, const char *kname, int *major, int *minor)
 {
 	char path[PATH_MAX], buffer[64];
 
@@ -98,7 +98,7 @@ static int get_sysfs_get_major_minor(const char *sysfs_dir, const char *kname, i
 		return 0;
 	}
 
-	if (!get_sysfs_string(path, buffer, sizeof(buffer)))
+	if (!_get_sysfs_string(path, buffer, sizeof(buffer)))
 		return_0;
 
 	if (sscanf(buffer, "%d:%d", major, minor) != 2) {
@@ -109,7 +109,7 @@ static int get_sysfs_get_major_minor(const char *sysfs_dir, const char *kname, i
 	return 1;
 }
 
-static int get_parent_mpath(const char *dir, char *name, int max_size)
+static int _get_parent_mpath(const char *dir, char *name, int max_size)
 {
 	struct dirent *d;
 	DIR *dr;
@@ -141,7 +141,7 @@ static int get_parent_mpath(const char *dir, char *name, int max_size)
 	return r;
 }
 
-static int dev_is_mpath(struct dev_filter *f, struct device *dev)
+static int _dev_is_mpath(struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
 	const char *part_name, *name;
@@ -160,14 +160,14 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 	switch (dev_get_primary_dev(dt, dev, &primary_dev)) {
 	case 2: /* The dev is partition. */
 		part_name = dev_name(dev); /* name of original dev for log_debug msg */
-		if (!(name = get_sysfs_name_by_devt(sysfs_dir, primary_dev, parent_name, sizeof(parent_name))))
+		if (!(name = _get_sysfs_name_by_devt(sysfs_dir, primary_dev, parent_name, sizeof(parent_name))))
 			return_0;
 		log_debug_devs("%s: Device is a partition, using primary "
 			       "device %s for mpath component detection",
 			       part_name, name);
 		break;
 	case 1: /* The dev is already a primary dev. Just continue with the dev. */
-		if (!(name = get_sysfs_name(dev)))
+		if (!(name = _get_sysfs_name(dev)))
 			return_0;
 		break;
 	default: /* 0, error. */
@@ -189,10 +189,10 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 		return 0;
 	}
 
-	if (!get_parent_mpath(path, parent_name, PATH_MAX))
+	if (!_get_parent_mpath(path, parent_name, sizeof(parent_name)))
 		return 0;
 
-	if (!get_sysfs_get_major_minor(sysfs_dir, parent_name, &major, &minor))
+	if (!_get_sysfs_get_major_minor(sysfs_dir, parent_name, &major, &minor))
 		return_0;
 
 	if (major != dt->device_mapper_major)
@@ -203,7 +203,7 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 
 static int _ignore_mpath(struct dev_filter *f, struct device *dev)
 {
-	if (dev_is_mpath(f, dev) == 1) {
+	if (_dev_is_mpath(f, dev) == 1) {
 		log_debug_devs("%s: Skipping mpath component device", dev_name(dev));
 		return 0;
 	}


