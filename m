From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Jul 2021 16:11:36 +0000 (GMT)
Subject: main - fix multipath component detection for multiple holders
Message-ID: <20210713161136.09F6D396E05B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8b52f2763cd029422147fa97928661bd67ebd03
Commit:        f8b52f2763cd029422147fa97928661bd67ebd03
Parent:        deaf43d6f0341d8d15e8ff5ffd25d7e0a7d2092a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 9 15:05:11 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 13 11:11:23 2021 -0500

fix multipath component detection for multiple holders

sysfs-based multipath component detection quit if a
device had multiple holders, and in this case would
fail to detect a device was an mpath component.
---
 lib/device/dev-mpath.c | 169 ++++++++++++++++++++++++-------------------------
 1 file changed, 83 insertions(+), 86 deletions(-)

diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index 1fb281d41..d3eaf42a3 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -240,38 +240,6 @@ static int _get_sysfs_dm_mpath(struct dev_types *dt, const char *sysfs_dir, cons
 	return 0;
 }
 
-static int _get_holder_name(const char *dir, char *name, int max_size)
-{
-	struct dirent *d;
-	DIR *dr;
-	int r = 0;
-
-	if (!(dr = opendir(dir))) {
-		log_sys_error("opendir", dir);
-		return 0;
-	}
-
-	*name = '\0';
-	while ((d = readdir(dr))) {
-		if (!strcmp(d->d_name, ".") || !strcmp(d->d_name, ".."))
-			continue;
-
-		/* There should be only one holder if it is multipath */
-		if (*name) {
-			r = 0;
-			break;
-		}
-
-		strncpy(name, d->d_name, max_size);
-		r = 1;
-	}
-
-	if (closedir(dr))
-		log_sys_debug("closedir", dir);
-
-	return r;
-}
-
 #ifdef UDEV_SYNC_SUPPORT
 static int _dev_is_mpath_component_udev(struct device *dev)
 {
@@ -310,15 +278,18 @@ static int _dev_is_mpath_component_sysfs(struct cmd_context *cmd, struct device
 	const char *name;               /* e.g. "sda" for "/dev/sda" */
 	char link_path[PATH_MAX];       /* some obscure, unpredictable sysfs path */
 	char holders_path[PATH_MAX];    /* e.g. "/sys/block/sda/holders/" */
-	char dm_dev_path[PATH_MAX];    /* e.g. "/dev/dm-1" */
-	char holder_name[256];		/* e.g. "dm-1" */
+	char dm_dev_path[PATH_MAX];     /* e.g. "/dev/dm-1" */
+	char *holder_name;		/* e.g. "dm-1" */
 	const char *sysfs_dir = dm_sysfs_dir();
+	DIR *dr;
+	struct dirent *de;
 	int dev_major = MAJOR(dev->dev);
 	int dev_minor = MINOR(dev->dev);
 	int dm_dev_major;
 	int dm_dev_minor;
 	struct stat info;
 	dev_t primary_dev;
+	int is_mpath_component = 0;
 
 	/* multipathing is only known to exist for SCSI or NVME devices */
 	if (!major_is_scsi_device(dt, dev_major) && !dev_is_nvme(dt, dev))
@@ -365,70 +336,96 @@ static int _dev_is_mpath_component_sysfs(struct cmd_context *cmd, struct device
 	}
 
 	/*
-	 * If holders dir contains an entry such as "dm-1", then this sets
-	 * holder_name to "dm-1".
-	 *
-	 * If holders dir is empty, return 0 (this is generally where
-	 * devs that are not mpath components return.)
+	 * If any holder is a dm mpath device, then return 1;
 	 */
-	if (!_get_holder_name(holders_path, holder_name, sizeof(holder_name)))
-		return 0;
 
-	if (dm_snprintf(dm_dev_path, sizeof(dm_dev_path), "%s/%s", cmd->dev_dir, holder_name) < 0) {
-		log_warn("dm device path to check mpath is too long.");
+	if (!(dr = opendir(holders_path))) {
+		log_debug("Device %s has no holders dir", dev_name(dev));
 		return 0;
 	}
 
-	/*
-	 * stat "/dev/dm-1" which is the holder of the dev we're checking
-	 * dm_dev_major:dm_dev_minor come from stat("/dev/dm-1")
-	 */
-	if (stat(dm_dev_path, &info)) {
-		log_debug_devs("dev_is_mpath_component %s holder %s stat result %d",
-			       dev_name(dev), dm_dev_path, errno);
-		return 0;
-	}
-	dm_dev_major = (int)MAJOR(info.st_rdev);
-	dm_dev_minor = (int)MINOR(info.st_rdev);
+	while ((de = readdir(dr))) {
+		if (!strcmp(de->d_name, ".") || !strcmp(de->d_name, ".."))
+			continue;
+
+		/*
+		 * holder_name is e.g. "dm-1"
+		 * dm_dev_path is then e.g. "/dev/dm-1"
+		 */
+		holder_name = de->d_name;
+
+		if (dm_snprintf(dm_dev_path, sizeof(dm_dev_path), "%s/%s", cmd->dev_dir, holder_name) < 0) {
+			log_warn("dm device path to check mpath is too long.");
+			continue;
+		}
+
+		/*
+		 * stat "/dev/dm-1" which is the holder of the dev we're checking
+		 * dm_dev_major:dm_dev_minor come from stat("/dev/dm-1")
+		 */
+		if (stat(dm_dev_path, &info)) {
+			log_debug_devs("dev_is_mpath_component %s holder %s stat result %d",
+					dev_name(dev), dm_dev_path, errno);
+			continue;
+		}
+		dm_dev_major = (int)MAJOR(info.st_rdev);
+		dm_dev_minor = (int)MINOR(info.st_rdev);
 	
-	if (dm_dev_major != dt->device_mapper_major) {
-		log_debug_devs("dev_is_mpath_component %s holder %s %d:%d does not have dm major",
-			       dev_name(dev), dm_dev_path, dm_dev_major, dm_dev_minor);
-		return 0;
-	}
+		if (dm_dev_major != dt->device_mapper_major) {
+			log_debug_devs("dev_is_mpath_component %s holder %s %d:%d does not have dm major",
+					dev_name(dev), dm_dev_path, dm_dev_major, dm_dev_minor);
+			continue;
+		}
 
-	/*
-	 * Save the result of checking that "/dev/dm-1" is an mpath device
-	 * to avoid repeating it for each path component.
-	 * The minor number of "/dev/dm-1" is added to the hash table with
-	 * const value 2 meaning that dm minor 1 (for /dev/dm-1) is a multipath dev
-	 * and const value 1 meaning that dm minor 1 is not a multipath dev.
-	 */
-	if (_minor_hash_tab) {
-		long look = (long) dm_hash_lookup_binary(_minor_hash_tab, &dm_dev_minor, sizeof(dm_dev_minor));
-		if (look > 0) {
-			log_debug_devs("dev_is_mpath_component %s holder %s %u:%u already checked as %sbeing mpath.",
-					dev_name(dev), holder_name, dm_dev_major, dm_dev_minor, (look > 1) ? "" : "not ");
-			return (look > 1) ? 1 : 0;
+		/*
+		 * A previous call may have checked if dm_dev_minor is mpath and saved
+		 * the result in the hash table.  If there's a saved result just use that.
+		 *
+		 * The minor number of "/dev/dm-1" is added to the hash table with
+		 * const value 2 meaning that dm minor 1 (for /dev/dm-1) is a multipath dev
+		 * and const value 1 meaning that dm minor 1 is not a multipath dev.
+		 */
+
+		if (_minor_hash_tab) {
+			long look = (long) dm_hash_lookup_binary(_minor_hash_tab, &dm_dev_minor, sizeof(dm_dev_minor));
+			if (look > 0) {
+				log_debug_devs("dev_is_mpath_component %s holder %s %u:%u already checked as %sbeing mpath.",
+						dev_name(dev), holder_name, dm_dev_major, dm_dev_minor, (look > 1) ? "" : "not ");
+
+				is_mpath_component = (look == 2);
+				goto out;
+			}
+
+			/* no saved result for dm_dev_minor, so check the uuid for it */
 		}
-	}
 
-	/*
-	 * Returns 1 if /sys/block/<holder_name>/dm/uuid indicates that
-	 * <holder_name> is a dm device with dm uuid prefix mpath-.
-	 * When true, <holder_name> will be something like "dm-1".
-	 */
-	if (_get_sysfs_dm_mpath(dt, sysfs_dir, holder_name)) {
-		log_debug_devs("dev_is_mpath_component %s holder %s %u:%u ignore mpath component",
-			       dev_name(dev), holder_name, dm_dev_major, dm_dev_minor);
+		/*
+	 	 * Returns 1 if /sys/block/<holder_name>/dm/uuid indicates that
+		 * <holder_name> is a dm device with dm uuid prefix mpath-.
+		 * When true, <holder_name> will be something like "dm-1".
+		 */
+		if (_get_sysfs_dm_mpath(dt, sysfs_dir, holder_name)) {
+			log_debug_devs("dev_is_mpath_component %s holder %s %u:%u ignore mpath component",
+					dev_name(dev), holder_name, dm_dev_major, dm_dev_minor);
+
+			/* For future checks, save that the dm minor refers to mpath ("2" == is mpath) */
+			if (_minor_hash_tab)
+				(void) dm_hash_insert_binary(_minor_hash_tab, &dm_dev_minor, sizeof(dm_dev_minor), (void*)2);
+
+			is_mpath_component = 1;
+			goto out;
+		}
+
+		/* For future checks, save that the dm minor does not refer to mpath ("1" == is not mpath) */
 		if (_minor_hash_tab)
-			(void) dm_hash_insert_binary(_minor_hash_tab, &dm_dev_minor, sizeof(dm_dev_minor), (void*)2);
-		return 1;
+			(void) dm_hash_insert_binary(_minor_hash_tab, &dm_dev_minor, sizeof(dm_dev_minor), (void*)1);
 	}
 
-	if (_minor_hash_tab)
-		(void) dm_hash_insert_binary(_minor_hash_tab, &dm_dev_minor, sizeof(dm_dev_minor), (void*)1);
-	return 0;
+ out:
+	if (closedir(dr))
+		stack;
+
+	return is_mpath_component;
 }
 
 static int _dev_in_wwid_file(struct cmd_context *cmd, struct device *dev)


