From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 07 Nov 2011 13:49:23 +0100
Subject: [PATCH 1/2] dev names: Add dm_device_get_name to acquire device name for given major:minor pair
Message-ID: <4EB7D3D3.1030507@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The code to acquire device's kernel name using sysfs is already upstream,
this is just a tiny refactor that exports this functionality as libdevmapper fn.
In addition, it adds a possibility to read the device-mapper name from sysfs
using given major:minor pair (which is a quick operation).

The new fn "int dm_device_get_name(uint32_t major, uint32_t minor, int prefer_kernel_name, char *buf, size_t buf_size)"
has a "pefer_kernel_name" switch with which it's possible to prefer kernel "dm-X"
names over device-mapper names if this is a device-mapper device (for non-dm
devices, only kernel name is possible).

Note:
Since the /sys/block/major:minor/dm/name item was added later (kernel 2.6.29 iirc),
there's a fallback to return kernel "dm-X" name if we're not able to get the
dm name via sysfs (with some log_debug in place).

Peter
---
 libdm/libdevmapper.h |    9 ++++
 libdm/libdm-common.c |  122 ++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 108 insertions(+), 23 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c865f6f..d71d61e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -267,6 +267,15 @@ const char *dm_sysfs_dir(void);
 int dm_is_dm_major(uint32_t major);
 
 /*
+ * Get device name for given major and minor number. If prefer_kernel_name
+ * is set, kernel name is preferred over dm name for dm devices. If sysfs
+ * is not used (or configured incorrectly), returns 0.
+ */
+int dm_device_get_name(uint32_t major, uint32_t minor,
+		       int prefer_kernel_name,
+		       char *buf, size_t buf_size);
+
+/*
  * Determine whether a device has any holders (devices
  * using this device). If sysfs is not used (or configured
  * incorrectly), returns 0.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 23539d7..5b9ba0b 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1056,6 +1056,103 @@ const char *dm_sysfs_dir(void)
 	return _sysfs_dir;
 }
 
+static int _sysfs_get_dm_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
+{
+	char sysfs_path[PATH_MAX];
+	char temp_buf[PATH_MAX];
+	FILE *fp;
+
+	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32 ":%" PRIu32
+			"/dm/name", _sysfs_dir, major, minor) < 0) {
+		log_error("_sysfs_get_dm_name: dm_snprintf failed");
+		return 0;
+	}
+
+	if (!(fp = fopen(sysfs_path, "r"))) {
+		if (errno != ENOENT)
+			log_sys_error("fopen", sysfs_path);
+		else
+			log_sys_debug("fopen", sysfs_path);
+		return 0;
+	}
+
+	if (!fgets(temp_buf, sizeof(temp_buf), fp)) {
+		log_sys_debug("fgets", sysfs_path);
+		return 0;
+	}
+	temp_buf[strlen(temp_buf) - 1] = '\0';
+
+	if (fclose(fp))
+		log_sys_error("fclose", sysfs_path);
+
+	if (buf_size < strlen(temp_buf) + 1) {
+		log_error("_sysfs_get_dm_name: output buffer too small");
+		return 0;
+	}
+
+	strcpy(buf, temp_buf);
+	return 1;
+}
+
+static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
+{
+	char sysfs_path[PATH_MAX];
+	char temp_buf[PATH_MAX];
+	ssize_t size;
+	char *name;
+
+	if (dm_snprintf(sysfs_path, PATH_MAX, "%sdev/block/%" PRIu32 ":%" PRIu32,
+			_sysfs_dir, major, minor) < 0) {
+		log_error("_sysfs_get_kerne_name: dm_snprintf failed");
+		return 0;
+	}
+
+	if ((size = readlink(sysfs_path, temp_buf, PATH_MAX)) < 0) {
+		if (errno != ENOENT)
+			log_sys_error("readlink", sysfs_path);
+		else
+			log_sys_debug("readlink", sysfs_path);
+		return 0;
+	}
+	temp_buf[size] = '\0';
+
+	if (!(name = strrchr(temp_buf, '/'))) {
+		log_error("Could not locate device kernel name in sysfs path %s", temp_buf);
+		return 0;
+	}
+	name += 1;
+
+	if (buf_size < strlen(name) + 1) {
+		log_error("_sysfs_get_kernel_name: output buffer too small");
+		return 0;
+	}
+
+	strcpy(buf, name);
+	return 1;
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
+	if (dm_is_dm_major(major) && !prefer_kernel_name &&
+	    _sysfs_get_dm_name(major, minor, buf, buf_size))
+		return 1;
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
@@ -1126,32 +1223,11 @@ static int _mounted_fs_on_device(const char *kernel_dev_name)
 
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


