From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Sep 2011 21:15:24 +0200
Subject: [PATCH 8/7][retry remove] Also add check for filesystem use on a DM/LVM device - "dm_device_has_fs"
Message-ID: <4E78E64C.8080006@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is an addition to patch #5 and it adds "dm_device_has_fs" fn to libdm.
This one gets the kernel device name first by using readlink for
/sys/dev/major:minor and stripping off the last part of the path which is
kernel device name actually (we could also use a shortcut here - just assume
that the kernel name is dm-<minor> but that seems to be less robust for future
changes). Then we iterate over /sys/fs/ and see if any of the filesystems use
our DM device (so checking the /sys/fs/<fs_name>/<kernel_dev_name> presence).

This way, we can tell the user whether a device is opened by another device or
if it is a filesystem that is still used (iow it's mounted) on a device when
trying to remove it and unable to do so.

So we can catch two of three possible reasons for the device removal failure
which could end up with "device or resource busy" error. The third one which
we do not handle is "device opened by an application". For this one, we use
the remove retry logic.

(Hmm, maybe we could store the sysfs path + kernel_device name somewhere in LVM
structs so we don't need to repeat those dm_snprintf calls to construct it
anytime we need to do these checks.)

Peter
---
 lib/activate/activate.c |   24 ++++++++++++---
 lib/activate/activate.h |    3 ++
 lib/metadata/lv_manip.c |    7 +---
 libdm/libdevmapper.h    |    3 +-
 libdm/libdm-common.c    |   75 +++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 101 insertions(+), 11 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3d854d1..5dc7d5f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -526,6 +526,22 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
 	return r;
 }
 
+int lv_check_not_in_use(struct cmd_context *cmd __attribute__((unused)),
+			struct logical_volume *lv, uint32_t major, uint32_t minor)
+{
+	if (dm_device_has_holders(major, minor)) {
+		log_error("Logical volume \"%s\" is used by another device.", lv->name);
+		return 0;
+	}
+
+	if (dm_device_has_fs(major, minor)) {
+		log_error("Logical volume \"%s\" contains a filesystem in use.", lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Returns 1 if percent set, else 0 on failure.
  */
@@ -1437,11 +1453,9 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	}
 
 	if (lv_is_visible(lv)) {
-		if (dm_device_has_holders(info.major, info.minor)) {
-			log_error("LV %s/%s in use: not deactivating",
-				  lv->vg->name, lv->name);
-			goto out;
-		}
+		if (!lv_check_not_in_use(cmd, lv, info.major, info.minor))
+			goto_out;
+
 		if (lv_is_origin(lv) && _lv_has_open_snapshots(lv))
 			goto_out;
 	}
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 7030633..728cbe9 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -80,6 +80,9 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
+int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
+			uint32_t major, uint32_t minor);
+
 /*
  * Returns 1 if activate_lv has been set: 1 = activate; 0 = don't.
  */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3132d0e..cea8ef3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3099,11 +3099,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* FIXME Ensure not referred to by another existing LVs */
 
 	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
-		if (info.exists && dm_device_has_holders(info.major, info.minor)) {
-			log_error("Can't remove open logical volume \"%s\"",
-				  lv->name);
-			return 0;
-		}
+		if (info.exists && !lv_check_not_in_use(cmd, lv, info.major, info.minor))
+			return_0;
 
 		if (lv_is_active(lv) && (force == PROMPT) &&
 		    lv_is_visible(lv) &&
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index f6614a5..f93dcc7 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -267,10 +267,11 @@ const char *dm_sysfs_dir(void);
 int dm_is_dm_major(uint32_t major);
 
 /*
- * Determine whether a device has holders.
+ * Determine whether a device has holders or if there's a filesystem present.
  * (this requires sysfs directory to be configured via dm_set_sysfs_dir)
  */
 int dm_device_has_holders(uint32_t major, uint32_t minor);
+int dm_device_has_fs(uint32_t major, uint32_t minor);
 
 /*
  * Release library resources
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 7ea78af..37b6902 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1087,6 +1087,81 @@ int dm_device_has_holders(uint32_t major, uint32_t minor)
 	return !_is_empty_dir(sysfs_path);
 }
 
+static int _fs_present_on_device(const char *kernel_dev_name)
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
+int dm_device_has_fs(uint32_t major, uint32_t minor)
+{
+	char sysfs_path[PATH_MAX];
+	char temp_path[PATH_MAX];
+	size_t size;
+	char *kernel_dev_name;
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
+	return _fs_present_on_device(kernel_dev_name);
+}
+
 int dm_mknodes(const char *name)
 {
 	struct dm_task *dmt;


