From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Jan 2012 12:34:48 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20120111123448.10821.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-01-11 12:34:45

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c 

Log message:
	Add dm_device_get_name to get map name or block device name for given devno.
	
	This is accomplished by reading associated sysfs information. For a dm device,
	this is /sys/dev/block/major:minor/dm/name (supported in kernel version >= 2.6.29,
	for older kernels, the behaviour is the same as for non-dm devices).
	
	For a non-dm device, this is a readlink on /sys/dev/block/major:minor, e.g.
	/sys/dev/block/253:0 --> ../../devices/virtual/block/dm-0.
	The last component of the path is a proper kernel name (block device name).
	
	One can request to read only kernel names by setting the 'prefer_kernel_name'
	argument if needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.529&r2=1.530
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/WHATS_NEW_DM	2012/01/10 02:03:31	1.529
+++ LVM2/WHATS_NEW_DM	2012/01/11 12:34:44	1.530
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add dm_device_get_name to get map name or block device name for given devno.
   Remove empty devices when clearing left-over inactive tables in deptree.
   Add dm_uuid_prefix/dm_set_uuid_prefix to override hard-coded LVM- prefix.
   Improve dmsetup man page about readahead parameter.
--- LVM2/libdm/libdevmapper.h	2012/01/10 02:03:32	1.174
+++ LVM2/libdm/libdevmapper.h	2012/01/11 12:34:45	1.175
@@ -300,6 +300,21 @@
 int dm_is_dm_major(uint32_t major);
 
 /*
+ * Get associated device name for given major and minor number by reading
+ * the sysfs content. If this is a dm device, get associated dm name, the one
+ * that appears in /dev/mapper. DM names could be resolved this way only if
+ * kernel used >= 2.6.29, kernel name is found otherwise (e.g. dm-0).
+ * If prefer_kernel_name is set, the kernel name is always preferred over
+ * device-mapper name for dm devices no matter what the kernel version is.
+ * For non-dm devices, we always get associated kernel name, e.g sda, md0 etc.
+ * Returns 0 on error or if sysfs is not used (or configured incorrectly),
+ * otherwise returns 1 and the supplied buffer holds the device name.
+ */
+int dm_device_get_name(uint32_t major, uint32_t minor,
+		       int prefer_kernel_name,
+		       char *buf, size_t buf_size);
+
+/*
  * Determine whether a device has any holders (devices
  * using this device). If sysfs is not used (or configured
  * incorrectly), returns 0.
--- LVM2/libdm/libdm-common.c	2012/01/10 02:03:32	1.131
+++ LVM2/libdm/libdm-common.c	2012/01/11 12:34:45	1.132
@@ -1165,6 +1165,133 @@
 	return _default_uuid_prefix;
 }
 
+static int _sysfs_get_dm_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
+{
+	char *sysfs_path, *temp_buf;
+	FILE *fp;
+
+	if (!(sysfs_path = dm_malloc(PATH_MAX)) ||
+	    !(temp_buf = dm_malloc(PATH_MAX))) {
+		log_error("_sysfs_get_dm_name: failed to allocate temporary buffers");
+		if (sysfs_path)
+			dm_free(sysfs_path);
+		return 0;
+	}
+
+	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32 ":%" PRIu32
+			"/dm/name", _sysfs_dir, major, minor) < 0) {
+		log_error("_sysfs_get_dm_name: dm_snprintf failed");
+		goto error;
+	}
+
+	if (!(fp = fopen(sysfs_path, "r"))) {
+		if (errno != ENOENT)
+			log_sys_error("fopen", sysfs_path);
+		else
+			log_sys_debug("fopen", sysfs_path);
+		goto error;
+	}
+
+	if (!fgets(temp_buf, PATH_MAX, fp)) {
+		log_sys_error("fgets", sysfs_path);
+		goto error;
+	}
+	temp_buf[strlen(temp_buf) - 1] = '\0';
+
+	if (fclose(fp))
+		log_sys_error("fclose", sysfs_path);
+
+	if (buf_size < strlen(temp_buf) + 1) {
+		log_error("_sysfs_get_dm_name: supplied buffer too small");
+		goto error;
+	}
+
+	strncpy(buf, temp_buf, buf_size);
+	dm_free(sysfs_path);
+	dm_free(temp_buf);
+	return 1;
+
+error:
+	dm_free(sysfs_path);
+	dm_free(temp_buf);
+	return 0;
+}
+
+static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
+{
+	char *sysfs_path, *temp_buf, *name;
+	ssize_t size;
+
+	if (!(sysfs_path = dm_malloc(PATH_MAX)) ||
+	    !(temp_buf = dm_malloc(PATH_MAX))) {
+		log_error("_sysfs_get_kernel_name: failed to allocate temporary buffers");
+		if (sysfs_path)
+			dm_free(sysfs_path);
+		return 0;
+	}
+
+	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32 ":%" PRIu32,
+			_sysfs_dir, major, minor) < 0) {
+		log_error("_sysfs_get_kernel_name: dm_snprintf failed");
+		goto error;
+	}
+
+	if ((size = readlink(sysfs_path, temp_buf, PATH_MAX)) < 0) {
+		if (errno != ENOENT)
+			log_sys_error("readlink", sysfs_path);
+		else
+			log_sys_debug("readlink", sysfs_path);
+		goto error;
+	}
+	temp_buf[size] = '\0';
+
+	if (!(name = strrchr(temp_buf, '/'))) {
+		log_error("Could not locate device kernel name in sysfs path %s", temp_buf);
+		goto error;
+	}
+	name += 1;
+
+	if (buf_size < strlen(name) + 1) {
+		log_error("_sysfs_get_kernel_name: output buffer too small");
+		goto error;
+	}
+
+	strncpy(buf, name, buf_size);
+	dm_free(sysfs_path);
+	dm_free(temp_buf);
+	return 1;
+
+error:
+	dm_free(sysfs_path);
+	dm_free(temp_buf);
+	return 0;
+}
+
+int dm_device_get_name(uint32_t major, uint32_t minor, int prefer_kernel_name,
+		       char *buf, size_t buf_size)
+{
+	if (!*_sysfs_dir)
+		return 0;
+
+	/*
+	 * device-mapper devices and prefer_kernel_name = 0
+	 * get dm name by reading /sys/dev/block/major:minor/dm/name,
+	 * fallback to _sysfs_get_kernel_name if not successful
+	 */
+	if (dm_is_dm_major(major) && !prefer_kernel_name) {
+		if (_sysfs_get_dm_name(major, minor, buf, buf_size))
+			return 1;
+		else
+			stack;
+	}
+
+	/*
+	 * non-device-mapper devices or prefer_kernel_name = 1
+	 * get kernel name using readlink /sys/dev/block/major:minor -> .../dm-X
+	 */
+	return _sysfs_get_kernel_name(major, minor, buf, buf_size);
+}
+
 int dm_device_has_holders(uint32_t major, uint32_t minor)
 {
 	char sysfs_path[PATH_MAX];
@@ -1235,32 +1362,11 @@
 
 int dm_device_has_mounted_fs(uint32_t major, uint32_t minor)
 {
-	char sysfs_path[PATH_MAX];
-	char temp_path[PATH_MAX];
-	char *kernel_dev_name;
-	ssize_t size;
-
-	if (!*_sysfs_dir)
-		return 0;
+	char kernel_dev_name[PATH_MAX];
 
 	/* Get kernel device name first */
-	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32 ":%" PRIu32,
-			_sysfs_dir, major, minor) < 0) {
-		log_error("sysfs_path dm_snprintf failed");
-		return 0;
-	}
-
-	if ((size = readlink(sysfs_path, temp_path, PATH_MAX)) < 0) {
-		log_sys_error("readlink", sysfs_path);
+	if (!dm_device_get_name(major, minor, 1, kernel_dev_name, PATH_MAX))
 		return 0;
-	}
-	temp_path[size] = '\0';
-
-	if (!(kernel_dev_name = strrchr(temp_path, '/'))) {
-		log_error("Could not locate device kernel name in sysfs path %s", temp_path);
-		return 0;
-	}
-	kernel_dev_name += 1;
 
 	/* Check /sys/fs/<fs_name>/<kernel_dev_name> presence */
 	return _mounted_fs_on_device(kernel_dev_name);


