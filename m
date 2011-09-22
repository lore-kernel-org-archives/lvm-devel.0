From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Sep 2011 17:23:37 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110922172337.28612.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-22 17:23:36

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c libdm-file.c 

Log message:
	Add dm_device_has_holders fn to to check use of the device by another device.
	Add dm_device_has_mounted_fs fn to check mounted filesystem on a device.
	
	This requires sysfs directory to be correctly set via dm_set_sysfs_dir
	(/sys by default). If sysfs dir is not used or it's set incorrectly,
	dm_device_has_{holders,mounted_fs} will return 0!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.502&r2=1.503
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-file.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW_DM	2011/09/22 17:17:07	1.502
+++ LVM2/WHATS_NEW_DM	2011/09/22 17:23:35	1.503
@@ -1,5 +1,7 @@
 Version 1.02.68 -
 ==================================
+  Add dm_device_has_mounted_fs fn to check mounted filesystem on a device.
+  Add dm_device_has_holders fn to to check use of the device by another device.
   Add dm_sysfs_dir to libdevmapper to retrieve sysfs location thas is set.
   Add dm_set_sysfs_dir to libdevmapper to set sysfs location.
   Add --retry option for dmsetup remove to retry removal if not successful.
--- LVM2/libdm/libdevmapper.h	2011/09/22 17:17:07	1.151
+++ LVM2/libdm/libdevmapper.h	2011/09/22 17:23:36	1.152
@@ -267,6 +267,19 @@
 int dm_is_dm_major(uint32_t major);
 
 /*
+ * Determine whether a device has any holders (devices
+ * using this device). If sysfs is not used (or configured
+ * incorrectly), returns 0.
+ */
+int dm_device_has_holders(uint32_t major, uint32_t minor);
+
+/*
+ * Determine whether a device contains mounted filesystem.
+ * If sysfs is not used (or configured incorrectly), returns 0.
+ */
+int dm_device_has_mounted_fs(uint32_t major, uint32_t minor);
+
+/*
  * Release library resources
  */
 void dm_lib_release(void);
@@ -1069,6 +1082,8 @@
  */
 int dm_create_dir(const char *dir);
 
+int dm_is_empty_dir(const char *dir);
+
 /*
  * Close a stream, with nicer error checking than fclose's.
  * Derived from gnulib's close-stream.c.
--- LVM2/libdm/libdm-common.c	2011/09/22 17:17:07	1.125
+++ LVM2/libdm/libdm-common.c	2011/09/22 17:23:36	1.126
@@ -1056,6 +1056,106 @@
 	return _sysfs_dir;
 }
 
+int dm_device_has_holders(uint32_t major, uint32_t minor)
+{
+	char sysfs_path[PATH_MAX];
+	struct stat st;
+
+	if (!*_sysfs_dir)
+		return 0;
+
+	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32
+			":%" PRIu32 "/holders", _sysfs_dir, major, minor) < 0) {
+		log_error("sysfs_path dm_snprintf failed");
+		return 0;
+	}
+
+	if (stat(sysfs_path, &st)) {
+		log_sys_error("stat", sysfs_path);
+		return 0;
+	}
+
+	return !dm_is_empty_dir(sysfs_path);
+}
+
+static int _mounted_fs_on_device(const char *kernel_dev_name)
+{
+	char sysfs_path[PATH_MAX];
+	struct dirent *dirent;
+	DIR *d;
+	struct stat st;
+	int r = 0;
+
+	if (dm_snprintf(sysfs_path, PATH_MAX, "%sfs", _sysfs_dir) < 0) {
+		log_error("sysfs_path dm_snprintf failed");
+		return 0;
+	}
+
+	if (!(d = opendir(sysfs_path))) {
+		if (errno != ENOENT)
+			log_sys_error("opendir", sysfs_path);
+		return 0;
+	}
+
+	while ((dirent = readdir(d))) {
+		if (!strcmp(dirent->d_name, ".") || !strcmp(dirent->d_name, ".."))
+			continue;
+
+		if (dm_snprintf(sysfs_path, PATH_MAX, "%sfs/%s/%s",
+				_sysfs_dir, dirent->d_name, kernel_dev_name) < 0) {
+			log_error("sysfs_path dm_snprintf failed");
+			break;
+		}
+
+		if (!stat(sysfs_path, &st)) {
+			/* found! */
+			r = 1;
+			break;
+		}
+		else if (errno != ENOENT) {
+			log_sys_error("stat", sysfs_path);
+			break;
+		}
+	}
+
+	if (closedir(d))
+		log_error("_fs_present_on_device: %s: closedir failed", kernel_dev_name);
+
+	return r;
+}
+
+int dm_device_has_mounted_fs(uint32_t major, uint32_t minor)
+{
+	char sysfs_path[PATH_MAX];
+	char temp_path[PATH_MAX];
+	char *kernel_dev_name;
+	ssize_t size;
+
+	if (!*_sysfs_dir)
+		return 0;
+
+	/* Get kernel device name first */
+	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32 ":%" PRIu32,
+			_sysfs_dir, major, minor) < 0) {
+		log_error("sysfs_path dm_snprintf failed");
+		return 0;
+	}
+
+	if ((size = readlink(sysfs_path, temp_path, PATH_MAX)) < 0) {
+		log_sys_error("readlink", sysfs_path);
+		return 0;
+	}
+
+	if (!(kernel_dev_name = strrchr(temp_path, '/'))) {
+		log_error("Could not locate device kernel name in sysfs path %s", temp_path);
+		return 0;
+	}
+	kernel_dev_name += 1;
+
+	/* Check /sys/fs/<fs_name>/<kernel_dev_name> presence */
+	return _mounted_fs_on_device(kernel_dev_name);
+}
+
 int dm_mknodes(const char *name)
 {
 	struct dm_task *dmt;
--- LVM2/libdm/libdm-file.c	2011/08/04 17:56:12	1.16
+++ LVM2/libdm/libdm-file.c	2011/09/22 17:23:36	1.17
@@ -76,6 +76,26 @@
 	return 0;
 }
 
+int dm_is_empty_dir(const char *dir)
+{
+	struct dirent *dirent;
+	DIR *d;
+
+	if (!(d = opendir(dir))) {
+		log_sys_error("opendir", dir);
+		return 0;
+	}
+
+	while ((dirent = readdir(d)))
+		if (strcmp(dirent->d_name, ".") && strcmp(dirent->d_name, ".."))
+			break;
+
+	if (closedir(d))
+		log_sys_error("closedir", dir);
+
+	return dirent ? 0 : 1;
+}
+
 int dm_fclose(FILE *stream)
 {
 	int prev_fail = ferror(stream);


