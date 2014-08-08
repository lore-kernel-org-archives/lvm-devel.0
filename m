From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  8 Aug 2014 09:01:06 +0000 (UTC)
Subject: master - filter-mpath: fix primary device lookup failure for partition when processing mpath filter
Message-ID: <20140808090106.E999C6146F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9738a02d3d56a3a30bd8b59838eae8f805ba3bcc
Commit:        9738a02d3d56a3a30bd8b59838eae8f805ba3bcc
Parent:        c52c9a1e316b6a92a2475dfe3ad2aac92edc80c0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 8 10:49:19 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 8 10:49:19 2014 +0200

filter-mpath: fix primary device lookup failure for partition when processing mpath filter

If using persistent filter and we're refreshing filters (just like we
do for pvcreate now after commit 54685c20fc9dfb155a2e5bc9d8cf5f0aad944305),
we can't rely on getting the primary device of the partition from the cache
as such device could be already filtered by persistent filter and we get
a device cache lookup failure for such device.

For example:

$ lvm dumpconfig --type diff
devices {
	obtain_device_list_from_udev=0
}

$lsblk /dev/sda
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0  128M  0 disk
`-sda1   8:1    0  127M  0 part

$cat /etc/lvm/cache/.cache | grep sda
		"/dev/sda1",

$pvcreate /dev/sda1
  dev_is_mpath: failed to get device for 8:1
  Physical volume "/dev/sda1" successfully created

The problematic part of the code called dev_cache_get_by_devt
to get the device for the device number supplied. Then the code
used dev_name(dev) to get the name which is then used in check
whether there's any mpath on top of this dev...

This patch uses sysfs to get the base name for the partition
instead, hence avoiding the device cache which is a correct
approach here.
---
 WHATS_NEW                  |    1 +
 lib/filters/filter-mpath.c |   53 +++++++++++++++++++++++++++++---------------
 2 files changed, 36 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 96ce8cb..28f7e36 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Fix primary device lookup failure for partition when processing mpath filter.
   If LV inactive and non-clustered, do not issue "Cannot deactivate" on -aln.
   Remove spurious "Skipping mirror LV" message on pvmove of clustered mirror.
 
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 10106f0..52c9341 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -40,6 +40,34 @@ static const char *get_sysfs_name(struct device *dev)
 	return name;
 }
 
+static const char *get_sysfs_name_by_devt(const char *sysfs_dir, dev_t devno,
+					  char *buf, size_t buf_size)
+{
+	const char *name;
+	char path[PATH_MAX];
+	int size;
+
+	if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d", sysfs_dir,
+			(int) MAJOR(devno), (int) MINOR(devno)) < 0) {
+		log_error("Sysfs path string is too long.");
+		return NULL;
+	}
+
+	if ((size = readlink(path, buf, buf_size - 1)) < 0) {
+		log_sys_error("readlink", path);
+		return NULL;
+	}
+	buf[size] = '\0';
+
+	if (!(name = strrchr(buf, '/'))) {
+		log_error("Cannot find device name in sysfs path.");
+		return NULL;
+	}
+	name++;
+
+	return name;
+}
+
 static int get_sysfs_string(const char *path, char *buffer, int max_size)
 {
 	FILE *fp;
@@ -116,7 +144,7 @@ static int get_parent_mpath(const char *dir, char *name, int max_size)
 static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 {
 	struct dev_types *dt = (struct dev_types *) f->private;
-	const char *name;
+	const char *part_name, *name;
 	char path[PATH_MAX+1];
 	char parent_name[PATH_MAX+1];
 	struct stat info;
@@ -136,31 +164,20 @@ static int dev_is_mpath(struct dev_filter *f, struct device *dev)
 			return 0;
 		case 1:
 			/* The dev is already a primary dev. Just continue with the dev. */
+			if (!(name = get_sysfs_name(dev)))
+				return_0;
 			break;
 		case 2:
 			/* The dev is partition. */
-			name = dev_name(dev); /* name of original dev for log_debug msg */
-
-			/* Get primary dev from cache. */
-			if (!(dev = dev_cache_get_by_devt(primary_dev, NULL))) {
-				log_error("dev_is_mpath: failed to get device for %d:%d",
-					  major, minor);
-				return 0;
-			}
-
-			major = (int) MAJOR(primary_dev);
-			minor = (int) MINOR(primary_dev);
-
+			part_name = dev_name(dev); /* name of original dev for log_debug msg */
+			if (!(name = get_sysfs_name_by_devt(sysfs_dir, primary_dev, parent_name, PATH_MAX)))
+				return_0;
 			log_debug_devs("%s: Device is a partition, using primary "
 				       "device %s for mpath component detection",
-					name, dev_name(dev));
-
+					part_name, name);
 			break;
 	}
 
-	if (!(name = get_sysfs_name(dev)))
-		return_0;
-
 	if (dm_snprintf(path, PATH_MAX, "%s/block/%s/holders", sysfs_dir, name) < 0) {
 		log_error("Sysfs path to check mpath is too long.");
 		return 0;


