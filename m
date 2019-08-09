From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Aug 2019 06:58:33 -0400
Subject: master - libdm: implement search for device names for older kernels
Message-ID: <201908091058.x79AwX9k031556@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46f1d17c743145d3ffa045557a6a792eb99f478a
Commit:        46f1d17c743145d3ffa045557a6a792eb99f478a
Parent:        2f5ea9e61acf56aa244715570710ba1e229a77cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 6 01:21:39 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 12:57:07 2019 +0200

libdm: implement search for device names for older kernels

Kernels <2.6.27 don't have /sys/dev dir - add code for looking
out device name via longre seach in /sys/block

This makes commands like 'dmsetup dep -o blkdevname' working.
---
 device_mapper/libdm-common.c |  118 +++++++++++++++++++++++++++++++++++++++++-
 libdm/libdm-common.c         |  119 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 235 insertions(+), 2 deletions(-)

diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index 45dcb4c..1cb29f1 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -1874,6 +1874,120 @@ bad:
 	return r;
 }
 
+static int _sysfs_get_dev_major_minor(const char *path, uint32_t major, uint32_t minor)
+{
+	FILE *fp;
+	uint32_t ma, mi;
+	int r;
+
+	if (!(fp = fopen(path, "r")))
+		return 0;
+
+	r = (fscanf(fp, "%" PRIu32 ":%" PRIu32 , &ma, &mi) == 2) &&
+		(ma == major) && (mi == minor);
+	// log_debug("Checking %s  %u:%u  -> %d", path, ma, mi, r);
+
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return r;
+}
+
+static int _sysfs_find_kernel_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
+{
+	const char *name, *name_dev;
+	char path[PATH_MAX];
+	struct dirent *dirent, *dirent_dev;
+	DIR *d, *d_dev;
+	struct stat st;
+	int r = 0, sz;
+
+	if (!*_sysfs_dir ||
+	    dm_snprintf(path, sizeof(path), "%s/block/", _sysfs_dir) < 0) {
+		log_error("Failed to build sysfs_path.");
+		return 0;
+	}
+
+	if (!(d = opendir(path))) {
+		log_sys_error("opendir", path);
+		return 0;
+	}
+
+	while (!r && (dirent = readdir(d))) {
+		name = dirent->d_name;
+
+		if (!strcmp(name, ".") || !strcmp(name, ".."))
+			continue;
+
+		if ((sz = dm_snprintf(path, sizeof(path), "%sblock/%s/dev",
+				      _sysfs_dir, name)) == -1) {
+			log_warn("Couldn't create path for %s.", name);
+			continue;
+		}
+
+		if (_sysfs_get_dev_major_minor(path, major, minor)) {
+			r = dm_strncpy(buf, name, buf_size);
+			break; /* found */
+		}
+
+		path[sz - 4] = 0; /* strip /dev from end of path string */
+		if (stat(path, &st))
+			continue;
+
+		if (S_ISDIR(st.st_mode)) {
+
+			/* let's assume there is no tree-complex device in past systems */
+			if (!(d_dev = opendir(path))) {
+				log_sys_debug("opendir", path);
+				continue;
+			}
+
+			while ((dirent_dev = readdir(d_dev))) {
+				name_dev = dirent_dev->d_name;
+
+				/* skip known ignorable paths */
+				if (!strcmp(name_dev, ".") || !strcmp(name_dev, "..") ||
+				    !strcmp(name_dev, "bdi") ||
+				    !strcmp(name_dev, "dev") ||
+				    !strcmp(name_dev, "device") ||
+				    !strcmp(name_dev, "holders") ||
+				    !strcmp(name_dev, "integrity") ||
+				    !strcmp(name_dev, "loop") ||
+				    !strcmp(name_dev, "queueu") ||
+				    !strcmp(name_dev, "md") ||
+				    !strcmp(name_dev, "mq") ||
+				    !strcmp(name_dev, "power") ||
+				    !strcmp(name_dev, "removable") ||
+				    !strcmp(name_dev, "slave") ||
+				    !strcmp(name_dev, "slaves") ||
+				    !strcmp(name_dev, "subsystem") ||
+				    !strcmp(name_dev, "trace") ||
+				    !strcmp(name_dev, "uevent"))
+					continue;
+
+				if (dm_snprintf(path, sizeof(path), "%sblock/%s/%s/dev",
+						_sysfs_dir, name, name_dev) == -1) {
+					log_warn("Couldn't create path for %s/%s.", name, name_dev);
+					continue;
+				}
+
+				if (_sysfs_get_dev_major_minor(path, major, minor)) {
+					r = dm_strncpy(buf, name_dev, buf_size);
+					break; /* found */
+				}
+			}
+
+			if (closedir(d_dev))
+				log_sys_debug("closedir", name);
+		}
+	}
+
+	if (closedir(d))
+		log_sys_debug("closedir", path);
+
+	return r;
+}
+
 static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
 {
 	char *name, *sysfs_path, *temp_buf = NULL;
@@ -1896,8 +2010,10 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 	if ((size = readlink(sysfs_path, temp_buf, PATH_MAX - 1)) < 0) {
 		if (errno != ENOENT)
 			log_sys_error("readlink", sysfs_path);
-		else
+		else {
 			log_sys_debug("readlink", sysfs_path);
+			return _sysfs_find_kernel_name(major, minor, buf, buf_size);
+		}
 		goto bad;
 	}
 	temp_buf[size] = '\0';
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 7d19f75..d17c284 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1872,6 +1872,121 @@ bad:
 	return r;
 }
 
+static int _sysfs_get_dev_major_minor(const char *path, uint32_t major, uint32_t minor)
+{
+	FILE *fp;
+	uint32_t ma, mi;
+	int r;
+
+	if (!(fp = fopen(path, "r")))
+		return 0;
+
+	r = (fscanf(fp, "%" PRIu32 ":%" PRIu32 , &ma, &mi) == 2) &&
+		(ma == major) && (mi == minor);
+	// log_debug("Checking %s  %u:%u  -> %d", path, ma, mi, r);
+
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return r;
+}
+
+
+static int _sysfs_find_kernel_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
+{
+	const char *name, *name_dev;
+	char path[PATH_MAX];
+	struct dirent *dirent, *dirent_dev;
+	DIR *d, *d_dev;
+	struct stat st;
+	int r = 0, sz;
+
+	if (!*_sysfs_dir ||
+	    dm_snprintf(path, sizeof(path), "%s/block/", _sysfs_dir) < 0) {
+		log_error("Failed to build sysfs_path.");
+		return 0;
+	}
+
+	if (!(d = opendir(path))) {
+		log_sys_error("opendir", path);
+		return 0;
+	}
+
+	while (!r && (dirent = readdir(d))) {
+		name = dirent->d_name;
+
+		if (!strcmp(name, ".") || !strcmp(name, ".."))
+			continue;
+
+		if ((sz = dm_snprintf(path, sizeof(path), "%sblock/%s/dev",
+				      _sysfs_dir, name)) == -1) {
+			log_warn("Couldn't create path for %s.", name);
+			continue;
+		}
+
+		if (_sysfs_get_dev_major_minor(path, major, minor)) {
+			r = dm_strncpy(buf, name, buf_size);
+			break; /* found */
+		}
+
+		path[sz - 4] = 0; /* strip /dev from end of path string */
+		if (stat(path, &st))
+			continue;
+
+		if (S_ISDIR(st.st_mode)) {
+
+			/* let's assume there is no tree-complex device in past systems */
+			if (!(d_dev = opendir(path))) {
+				log_sys_debug("opendir", path);
+				continue;
+			}
+
+			while ((dirent_dev = readdir(d_dev))) {
+				name_dev = dirent_dev->d_name;
+
+				/* skip known ignorable paths */
+				if (!strcmp(name_dev, ".") || !strcmp(name_dev, "..") ||
+				    !strcmp(name_dev, "bdi") ||
+				    !strcmp(name_dev, "dev") ||
+				    !strcmp(name_dev, "device") ||
+				    !strcmp(name_dev, "holders") ||
+				    !strcmp(name_dev, "integrity") ||
+				    !strcmp(name_dev, "loop") ||
+				    !strcmp(name_dev, "queueu") ||
+				    !strcmp(name_dev, "md") ||
+				    !strcmp(name_dev, "mq") ||
+				    !strcmp(name_dev, "power") ||
+				    !strcmp(name_dev, "removable") ||
+				    !strcmp(name_dev, "slave") ||
+				    !strcmp(name_dev, "slaves") ||
+				    !strcmp(name_dev, "subsystem") ||
+				    !strcmp(name_dev, "trace") ||
+				    !strcmp(name_dev, "uevent"))
+					continue;
+
+				if (dm_snprintf(path, sizeof(path), "%sblock/%s/%s/dev",
+						_sysfs_dir, name, name_dev) == -1) {
+					log_warn("Couldn't create path for %s/%s.", name, name_dev);
+					continue;
+				}
+
+				if (_sysfs_get_dev_major_minor(path, major, minor)) {
+					r = dm_strncpy(buf, name_dev, buf_size);
+					break; /* found */
+				}
+			}
+
+			if (closedir(d_dev))
+				log_sys_debug("closedir", name);
+		}
+	}
+
+	if (closedir(d))
+		log_sys_debug("closedir", path);
+
+	return r;
+}
+
 static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, size_t buf_size)
 {
 	char *name, *sysfs_path, *temp_buf = NULL;
@@ -1894,8 +2009,10 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 	if ((size = readlink(sysfs_path, temp_buf, PATH_MAX - 1)) < 0) {
 		if (errno != ENOENT)
 			log_sys_error("readlink", sysfs_path);
-		else
+		else {
 			log_sys_debug("readlink", sysfs_path);
+			return _sysfs_find_kernel_name(major, minor, buf, buf_size);
+		}
 		goto bad;
 	}
 	temp_buf[size] = '\0';


