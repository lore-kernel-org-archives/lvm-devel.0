From: David Teigland <teigland@sourceware.org>
Date: Tue,  9 Nov 2021 17:45:04 +0000 (GMT)
Subject: main - pvs_online: include devname in pvid files
Message-ID: <20211109174504.B12A93858020@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73b4602f219767850a2834c6b15bdb5e6d636870
Commit:        73b4602f219767850a2834c6b15bdb5e6d636870
Parent:        024ce50f06feff2dae53dce83398911bef071a6e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 8 16:02:48 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 9 11:26:26 2021 -0600

pvs_online: include devname in pvid files

Include the device name in the /run/lvm/pvs_online/pvid files.
Commands using the pvid file can use the devname to more quickly
find the correct device, vs finding the device using the
major:minor number.  If the devname in the pvid file is missing
or incorrect, fall back to using the devno.
---
 lib/device/dev-cache.c |  50 ++++++++++++++++++
 lib/device/dev-cache.h |   1 +
 lib/device/online.c    | 138 +++++++++++++++++++++++++++++++++++++------------
 lib/device/online.h    |   3 +-
 lib/label/label.c      |  18 ++-----
 tools/pvscan.c         |  41 +++++++--------
 6 files changed, 182 insertions(+), 69 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 525dae31e..b5f355484 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -2241,3 +2241,53 @@ int setup_devno_in_dev_cache(struct cmd_context *cmd, dev_t devno)
 	return setup_devname_in_dev_cache(cmd, devname);
 }
 
+struct device *setup_dev_in_dev_cache(struct cmd_context *cmd, dev_t devno, const char *devname)
+{
+	struct device *dev;
+	struct stat buf;
+	int major = (int)MAJOR(devno);
+	int minor = (int)MINOR(devno);
+
+	if (devname) {
+		if (stat(devname, &buf) < 0) {
+			log_error("Cannot access device %s for %d:%d.", devname, major, minor);
+			if (!(devname = _get_devname_from_devno(cmd, devno))) {
+				log_error("No device name found from %d:%d.", major, minor);
+				return_NULL;
+			}
+			if (stat(devname, &buf) < 0) {
+				log_error("Cannot access device %s from %d:%d.", devname, major, minor);
+				return_NULL;
+			}
+		}
+	} else {
+		if (!(devname = _get_devname_from_devno(cmd, devno))) {
+			log_error("No device name found from %d:%d.", major, minor);
+			return_NULL;
+		}
+		if (stat(devname, &buf) < 0) {
+			log_error("Cannot access device %s from %d:%d.", devname, major, minor);
+			return_NULL;
+		}
+	}
+
+	if (!S_ISBLK(buf.st_mode)) {
+		log_error("Invaild device type %s.", devname);
+		return_NULL;
+	}
+
+	if (devno && (buf.st_rdev != devno)) {
+		log_warn("Found %s devno %d:%d expected %d:%d.", devname,
+			  (int)MAJOR(buf.st_rdev), (int)MINOR(buf.st_rdev), major, minor);
+	}
+
+	if (!_insert_dev(devname, buf.st_rdev))
+		return_NULL;
+
+	if (!(dev = (struct device *) dm_hash_lookup(_cache.names, devname))) {
+		log_error("Device lookup failed for %d:%d %s", major, minor, devname);
+		return_NULL;
+	}
+
+	return dev;
+}
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 175c0a3e3..449bfeb75 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -82,5 +82,6 @@ int setup_device(struct cmd_context *cmd, const char *devname);
 int setup_devices_for_online_autoactivation(struct cmd_context *cmd);
 int setup_devname_in_dev_cache(struct cmd_context *cmd, const char *devname);
 int setup_devno_in_dev_cache(struct cmd_context *cmd, dev_t devno);
+struct device *setup_dev_in_dev_cache(struct cmd_context *cmd, dev_t devno, const char *devname);
 
 #endif
diff --git a/lib/device/online.c b/lib/device/online.c
index 58696871e..c67f45001 100644
--- a/lib/device/online.c
+++ b/lib/device/online.c
@@ -21,35 +21,50 @@
 
 #include <dirent.h>
 
-static char *_vgname_in_pvid_file_buf(char *buf)
+/*
+ * file contains:
+ * <major>:<minor>\n
+ * vg:<vgname>\n
+ * dev:<devname>\n\0
+ *
+ * It's possible that vg and dev may not exist.
+ */
+
+static int _copy_pvid_file_field(const char *field, char *buf, int bufsize, char *out, int outsize)
 {
-	char *p, *n;
+	char *p;
+	int i = 0;
+	
+	if (!(p = strstr(buf, field)))
+		return 0;
 
-	/*
-	 * file contains:
-	 * <major>:<minor>\n
-	 * vg:<vgname>\n\0
-	 */
+	p += strlen(field);
 
-	if (!(p = strchr(buf, '\n')))
-		return NULL;
+	while (1) {
+		if (*p == '\n')
+			break;
+		if (*p == '\0')
+			break;
 
-	p++; /* skip \n */
+		if (p >= (buf + bufsize))
+			return 0;
+		if (i >= outsize-1)
+			return 0;
 
-	if (*p && !strncmp(p, "vg:", 3)) {
-		if ((n = strchr(p, '\n')))
-			*n = '\0';
-		return p + 3;
+		out[i] = *p;
+
+		i++;
+		p++;
 	}
-	return NULL;
+
+	return i ? 1 : 0;
 }
 
 #define MAX_PVID_FILE_SIZE 512
 
-int online_pvid_file_read(char *path, int *major, int *minor, char *vgname)
+int online_pvid_file_read(char *path, int *major, int *minor, char *vgname, char *devname)
 {
 	char buf[MAX_PVID_FILE_SIZE] = { 0 };
-	char *name;
 	int fd, rv;
 
 	fd = open(path, O_RDONLY);
@@ -72,12 +87,47 @@ int online_pvid_file_read(char *path, int *major, int *minor, char *vgname)
 		return 0;
 	}
 
-	/* vgname points to an offset in buf */
-	if ((name = _vgname_in_pvid_file_buf(buf)))
-		strncpy(vgname, name, NAME_LEN);
-	else
-		log_debug("No vgname in %s", path);
+	if (vgname) {
+		if (!strstr(buf, "vg:")) {
+			log_debug("No vgname in %s", path);
+			vgname[0] = '\0';
+			goto copy_dev;
+		}
+
+		if (!_copy_pvid_file_field("vg:", buf, MAX_PVID_FILE_SIZE, vgname, NAME_LEN)) {
+			log_warn("Ignoring invalid vg field in %s", path);
+			vgname[0] = '\0';
+			goto copy_dev;
+		}
+
+		if (!validate_name(vgname)) {
+			log_warn("Ignoring invalid vgname in %s (%s)", path, vgname);
+			vgname[0] = '\0';
+			goto copy_dev;
+		}
+	}
+
+ copy_dev:
+	if (devname) {
+		if (!strstr(buf, "dev:")) {
+			log_debug("No devname in %s", path);
+			devname[0] = '\0';
+			goto out;
+		}
+
+		if (!_copy_pvid_file_field("dev:", buf, MAX_PVID_FILE_SIZE, devname, NAME_LEN)) {
+			log_warn("Ignoring invalid devname field in %s", path);
+			devname[0] = '\0';
+			goto out;
+		}
 
+		if (strncmp(devname, "/dev/", 5)) {
+			log_warn("Ignoring invalid devname in %s (%s)", path, devname);
+			devname[0] = '\0';
+			goto out;
+		}
+	}
+ out:
 	return 1;
 }
 
@@ -95,6 +145,7 @@ int get_pvs_online(struct dm_list *pvs_online, const char *vgname)
 {
 	char path[PATH_MAX];
 	char file_vgname[NAME_LEN];
+	char file_devname[NAME_LEN];
 	DIR *dir;
 	struct dirent *de;
 	struct pv_online *po;
@@ -116,8 +167,9 @@ int get_pvs_online(struct dm_list *pvs_online, const char *vgname)
 		file_major = 0;
 		file_minor = 0;
 		memset(file_vgname, 0, sizeof(file_vgname));
+		memset(file_devname, 0, sizeof(file_devname));
 
-		if (!online_pvid_file_read(path, &file_major, &file_minor, file_vgname))
+		if (!online_pvid_file_read(path, &file_major, &file_minor, file_vgname, file_devname))
 			continue;
 
 		if (vgname && strcmp(file_vgname, vgname))
@@ -130,15 +182,18 @@ int get_pvs_online(struct dm_list *pvs_online, const char *vgname)
 		if (file_major || file_minor)
 			po->devno = MKDEV(file_major, file_minor);
 		if (file_vgname[0])
-			strncpy(po->vgname, file_vgname, NAME_LEN-1);
+			strncpy(po->vgname, file_vgname, NAME_LEN);
+		if (file_devname[0])
+			strncpy(po->devname, file_devname, NAME_LEN);
 
+		log_debug("Found PV online %s for VG %s %s", path, vgname, file_devname);
 		dm_list_add(pvs_online, &po->list);
 	}
 
 	if (closedir(dir))
 		log_sys_debug("closedir", PVS_ONLINE_DIR);
 
-	log_debug("PVs online found %d for %s", dm_list_size(pvs_online), vgname ?: "all");
+	log_debug("Found PVs online %d for %s", dm_list_size(pvs_online), vgname ?: "all");
 
 	return 1;
 }
@@ -195,6 +250,9 @@ int online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const c
 	char path[PATH_MAX];
 	char buf[MAX_PVID_FILE_SIZE] = { 0 };
 	char file_vgname[NAME_LEN];
+	char file_devname[NAME_LEN];
+	char devname[NAME_LEN];
+	int devnamelen;
 	int file_major = 0, file_minor = 0;
 	int major, minor;
 	int fd;
@@ -202,6 +260,7 @@ int online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const c
 	int len;
 	int len1 = 0;
 	int len2 = 0;
+	int len3 = 0;
 
 	major = (int)MAJOR(dev->dev);
 	minor = (int)MINOR(dev->dev);
@@ -218,13 +277,22 @@ int online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const c
 
 	if (vgname) {
 		if ((len2 = dm_snprintf(buf + len1, sizeof(buf) - len1, "vg:%s\n", vgname)) < 0) {
-			log_print_pvscan(cmd, "Incomplete online file for %s %d:%d vg %s.", dev_name(dev), major, minor, vgname);
+			log_print("Incomplete online file for %s %d:%d vg %s.", dev_name(dev), major, minor, vgname);
 			/* can still continue without vgname */
 			len2 = 0;
 		}
 	}
 
-	len = len1 + len2;
+	devnamelen = dm_snprintf(devname, sizeof(devname), "%s", dev_name(dev));
+	if ((devnamelen > 5) && (devnamelen < NAME_LEN-1)) {
+		if ((len3 = dm_snprintf(buf + len1 + len2, sizeof(buf) - len1 - len2, "dev:%s\n", devname)) < 0) {
+			log_print("Incomplete devname in online file for %s.", dev_name(dev));
+			/* can continue without devname */
+			len3 = 0;
+		}
+	}
+
+	len = len1 + len2 + len3;
 
 	log_debug("Create pv online: %s %d:%d %s", path, major, minor, dev_name(dev));
 
@@ -269,8 +337,9 @@ check_duplicate:
 	 */
 
 	memset(file_vgname, 0, sizeof(file_vgname));
+	memset(file_devname, 0, sizeof(file_devname));
 
-	online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
+	online_pvid_file_read(path, &file_major, &file_minor, file_vgname, file_devname);
 
 	if ((file_major == major) && (file_minor == minor)) {
 		log_debug("Existing online file for %d:%d", major, minor);
@@ -280,8 +349,8 @@ check_duplicate:
 	/* Don't know how vgname might not match, but it's not good so fail. */
 
 	if ((file_major != major) || (file_minor != minor))
-		log_error_pvscan(cmd, "PV %s is duplicate for PVID %s on %d:%d and %d:%d.",
-			         dev_name(dev), dev->pvid, major, minor, file_major, file_minor);
+		log_error_pvscan(cmd, "PV %s %d:%d is duplicate for PVID %s on %d:%d %s.",
+			         dev_name(dev), major, minor, dev->pvid, file_major, file_minor, file_devname);
 
 	if (file_vgname[0] && vgname && strcmp(file_vgname, vgname))
 		log_error_pvscan(cmd, "PV %s has unexpected VG %s vs %s.",
@@ -319,6 +388,7 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 	char line[64];
 	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	char file_vgname[NAME_LEN];
+	char file_devname[NAME_LEN];
 	struct pv_online *po;
 	int file_major = 0, file_minor = 0;
 	FILE *fp;
@@ -340,8 +410,9 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 		file_major = 0;
 		file_minor = 0;
 		memset(file_vgname, 0, sizeof(file_vgname));
+		memset(file_devname, 0, sizeof(file_devname));
 
-		if (!online_pvid_file_read(path, &file_major, &file_minor, file_vgname))
+		if (!online_pvid_file_read(path, &file_major, &file_minor, file_vgname, file_devname))
 			goto_bad;
 
 		if (vgname && strcmp(file_vgname, vgname))
@@ -355,11 +426,14 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 			po->devno = MKDEV(file_major, file_minor);
 		if (file_vgname[0])
 			strncpy(po->vgname, file_vgname, NAME_LEN-1);
+		if (file_devname[0])
+			strncpy(po->devname, file_devname, NAME_LEN-1);
 
+		log_debug("Found PV online lookup %s for VG %s on %s", path, vgname, file_devname);
 		dm_list_add(pvs_online, &po->list);
 	}
 
-	log_debug("PVs online lookup found %d for %s", dm_list_size(pvs_online), vgname);
+	log_debug("Found PVs online lookup %d for %s", dm_list_size(pvs_online), vgname);
 
 	fclose(fp);
 	return 1;
diff --git a/lib/device/online.h b/lib/device/online.h
index 25a176854..850b03db8 100644
--- a/lib/device/online.h
+++ b/lib/device/online.h
@@ -21,6 +21,7 @@ struct pv_online {
 	dev_t devno;
 	char pvid[ID_LEN + 1];
 	char vgname[NAME_LEN];
+	char devname[NAME_LEN];
 };
 
 /*
@@ -44,7 +45,7 @@ do \
 		log_error("pvscan[%d] " fmt, getpid(), ##args); \
 while (0)
 
-int online_pvid_file_read(char *path, int *major, int *minor, char *vgname);
+int online_pvid_file_read(char *path, int *major, int *minor, char *vgname, char *devname);
 int online_vg_file_create(struct cmd_context *cmd, const char *vgname);
 void online_vg_file_remove(const char *vgname);
 int online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const char *vgname);
diff --git a/lib/label/label.c b/lib/label/label.c
index 9875b5f02..324cfd034 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1073,26 +1073,18 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 	}
 
 	/*
-	 * For each po devno add a struct dev to dev-cache.  This is a faster
+	 * For each po add a struct dev to dev-cache.  This is a faster
 	 * alternative to the usual dev_cache_scan() which looks at all
 	 * devices.  If this optimization fails, then fall back to the usual
 	 * dev_cache_scan().
 	 */
 	dm_list_iterate_items(po, &pvs_online) {
-		if (!setup_devno_in_dev_cache(cmd, po->devno)) {
-			log_debug("No device set up for quick mapping of %d:%d PVID %s",
-				  (int)MAJOR(po->devno), (int)MINOR(po->devno), po->pvid);
+		if (!(po->dev = setup_dev_in_dev_cache(cmd, po->devno, po->devname[0] ? po->devname : NULL))) {
+			log_debug("No device found for quick mapping of online PV %d:%d %s PVID %s",
+				  (int)MAJOR(po->devno), (int)MINOR(po->devno), po->devname, po->pvid);
 			try_dev_scan = 1;
-			break;
-		}
-
-		if (!(po->dev = dev_cache_get_by_devt(cmd, po->devno, NULL, NULL))) {
-			log_debug("No device found for quick mapping of %d:%d PVID %s",
-				  (int)MAJOR(po->devno), (int)MINOR(po->devno), po->pvid);
-			try_dev_scan = 1;
-			break;
+			continue;
 		}
-
 		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
 			goto_bad;
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6fd86e486..df1722c45 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -223,7 +223,7 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 		file_minor = 0;
 		memset(file_vgname, 0, sizeof(file_vgname));
 
-		online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
+		online_pvid_file_read(path, &file_major, &file_minor, file_vgname, NULL);
 
 		if ((file_major == major) && (file_minor == minor)) {
 			log_debug("Unlink pv online %s", path);
@@ -509,6 +509,7 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 {
 	char path[PATH_MAX];
 	char file_vgname[NAME_LEN];
+	char file_devname[NAME_LEN];
 	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	char uuidstr[64] __attribute__((aligned(8)));
 	struct pv_list *pvl;
@@ -538,8 +539,9 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 		file_major = 0;
 		file_minor = 0;
 		memset(file_vgname, 0, sizeof(file_vgname));
+		memset(file_devname, 0, sizeof(file_devname));
 
-		online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
+		online_pvid_file_read(path, &file_major, &file_minor, file_vgname, file_devname);
 
 		if (file_vgname[0] && strcmp(vgname, file_vgname)) {
 			log_error_pvscan(cmd, "Wrong VG found for %d:%d PVID %s: %s vs %s",
@@ -549,13 +551,8 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 
 		devno = MKDEV(file_major, file_minor);
 
-		if (!setup_devno_in_dev_cache(cmd, devno)) {
-			log_error_pvscan(cmd, "No device set up for %d:%d PVID %s", file_major, file_minor, pvid);
-			goto bad;
-		}
-
-		if (!(dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL))) {
-			log_error_pvscan(cmd, "No device found for %d:%d PVID %s", file_major, file_minor, pvid);
+		if (!(dev = setup_dev_in_dev_cache(cmd, devno, file_devname[0] ? file_devname : NULL))) {
+			log_error_pvscan(cmd, "No device set up for online PV %d:%d %s PVID %s", file_major, file_minor, file_devname, pvid);
 			goto bad;
 		}
 
@@ -888,16 +885,12 @@ static int _get_args_devs(struct cmd_context *cmd, struct dm_list *pvscan_args,
 	/* in common usage, no dev will be found for a devno */
 
 	dm_list_iterate_items(arg, pvscan_args) {
-		if (arg->devname) {
-			if (!setup_devname_in_dev_cache(cmd, arg->devname))
-				log_error_pvscan(cmd, "No device set up for name arg %s", arg->devname);
-			arg->dev = dev_cache_get(cmd, arg->devname, NULL);
-		} else if (arg->devno) {
-			if (!setup_devno_in_dev_cache(cmd, arg->devno))
-				log_error_pvscan(cmd, "No device set up for devno arg %d", (int)arg->devno);
-			arg->dev = dev_cache_get_by_devt(cmd, arg->devno, NULL, NULL);
-		} else
+		if (!arg->devname && !arg->devno)
 			return_0;
+		if (!(arg->dev = setup_dev_in_dev_cache(cmd, arg->devno, arg->devname))) {
+			log_error_pvscan(cmd, "No device set up for arg %s %d:%d",
+					 arg->devname ?: "", (int)MAJOR(arg->devno), (int)MINOR(arg->devno));
+		}
 	}
 
 	dm_list_iterate_items(arg, pvscan_args) {
@@ -917,6 +910,7 @@ static void _set_pv_devices_online(struct cmd_context *cmd, struct volume_group
 {
 	char path[PATH_MAX];
 	char file_vgname[NAME_LEN];
+	char file_devname[NAME_LEN];
 	char pvid[ID_LEN+1] = { 0 };
 	struct pv_list *pvl;
 	struct device *dev;
@@ -944,9 +938,10 @@ static void _set_pv_devices_online(struct cmd_context *cmd, struct volume_group
 
 		major = 0;
 		minor = 0;
-		file_vgname[0] = '\0';
+		memset(file_vgname, 0, sizeof(file_vgname));
+		memset(file_devname, 0, sizeof(file_devname));
 
-		online_pvid_file_read(path, &major, &minor, file_vgname);
+		online_pvid_file_read(path, &major, &minor, file_vgname, file_devname);
 
 		if (file_vgname[0] && strcmp(vg->name, file_vgname)) {
 			log_warn("WARNING: VG %s PV %s wrong vgname in online file %s",
@@ -957,9 +952,9 @@ static void _set_pv_devices_online(struct cmd_context *cmd, struct volume_group
 
 		devno = MKDEV(major, minor);
 
-		if (!(dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL))) {
-			log_print_pvscan(cmd, "VG %s PV %s no device found for %d:%d",
-					 vg->name, pvid, major, minor);
+		if (!(dev = setup_dev_in_dev_cache(cmd, devno, file_devname[0] ? file_devname : NULL))) {
+			log_print_pvscan(cmd, "VG %s PV %s no device found for online PV %d:%d %s",
+					 vg->name, pvid, major, minor, file_devname);
 			pvl->pv->status |= MISSING_PV;
 			continue;
 		}


