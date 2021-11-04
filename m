From: David Teigland <teigland@sourceware.org>
Date: Thu,  4 Nov 2021 16:37:14 +0000 (GMT)
Subject: main - move code from pvscan.c to online.c
Message-ID: <20211104163714.27FD1385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f40fd88374fe1e911233e5a4fc79223d97decde0
Commit:        f40fd88374fe1e911233e5a4fc79223d97decde0
Parent:        d558b3ad7e6086480075b3bf750eba0ee66c78ec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 3 16:02:38 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 4 11:09:29 2021 -0500

move code from pvscan.c to online.c

related to managing files in /run/lvm/pvs_online
and /run/lvm/vgs_online
---
 lib/Makefile.in            |   1 +
 lib/commands/toolcontext.h |   1 +
 lib/device/online.c        | 306 ++++++++++++++++++++++++++++++++++++++
 lib/device/online.h        |  46 ++++++
 lib/label/hints.c          |   3 +-
 tools/lvmcmdline.c         |   4 +-
 tools/pvscan.c             | 360 ++++-----------------------------------------
 tools/toollib.c            |   1 +
 tools/tools.h              |   2 -
 9 files changed, 384 insertions(+), 340 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 8b3eac60a..e97f57a4d 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -40,6 +40,7 @@ SOURCES =\
 	device/dev-luks.c \
 	device/dev-dasd.c \
 	device/dev-lvm1-pool.c \
+	device/online.c \
 	display/display.c \
 	error/errseg.c \
 	unknown/unknown.c \
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 0ae45ccc0..b3de65702 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -202,6 +202,7 @@ struct cmd_context {
 	unsigned ignore_device_name_mismatch:1; /* skip updating devices file names */
 	unsigned backup_disabled:1;		/* skip repeated debug message */
 	unsigned event_activation:1;		/* whether event_activation is set */
+	unsigned udevoutput:1;
 
 	/*
 	 * Devices and filtering.
diff --git a/lib/device/online.c b/lib/device/online.c
new file mode 100644
index 000000000..28e97d9fe
--- /dev/null
+++ b/lib/device/online.c
@@ -0,0 +1,306 @@
+/*
+ * Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "base/memory/zalloc.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/device/device.h"
+#include "lib/device/device_id.h"
+#include "lib/device/online.h"
+
+#include <dirent.h>
+
+static char *_vgname_in_pvid_file_buf(char *buf)
+{
+	char *p, *n;
+
+	/*
+	 * file contains:
+	 * <major>:<minor>\n
+	 * vg:<vgname>\n\0
+	 */
+
+	if (!(p = strchr(buf, '\n')))
+		return NULL;
+
+	p++; /* skip \n */
+
+	if (*p && !strncmp(p, "vg:", 3)) {
+		if ((n = strchr(p, '\n')))
+			*n = '\0';
+		return p + 3;
+	}
+	return NULL;
+}
+
+#define MAX_PVID_FILE_SIZE 512
+
+int online_pvid_file_read(char *path, int *major, int *minor, char *vgname)
+{
+	char buf[MAX_PVID_FILE_SIZE] = { 0 };
+	char *name;
+	int fd, rv;
+
+	fd = open(path, O_RDONLY);
+	if (fd < 0) {
+		log_warn("Failed to open %s", path);
+		return 0;
+	}
+
+	rv = read(fd, buf, sizeof(buf) - 1);
+	if (close(fd))
+		log_sys_debug("close", path);
+	if (!rv || rv < 0) {
+		log_warn("No info in %s", path);
+		return 0;
+	}
+	buf[rv] = 0; /* \0 terminated buffer */
+
+	if (sscanf(buf, "%d:%d", major, minor) != 2) {
+		log_warn("No device numbers in %s", path);
+		return 0;
+	}
+
+	/* vgname points to an offset in buf */
+	if ((name = _vgname_in_pvid_file_buf(buf)))
+		strncpy(vgname, name, NAME_LEN);
+	else
+		log_debug("No vgname in %s", path);
+
+	return 1;
+}
+
+/*
+ * When a PV goes offline, remove the vg online file for that VG
+ * (even if other PVs for the VG are still online).  This means
+ * that the vg will be activated again when it becomes complete.
+ */
+
+void online_vg_file_remove(const char *vgname)
+{
+	char path[PATH_MAX];
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", VGS_ONLINE_DIR, vgname) < 0) {
+		log_error("Path %s/%s is too long.", VGS_ONLINE_DIR, vgname);
+		return;
+	}
+
+	log_debug("Unlink vg online: %s", path);
+
+	if (unlink(path) && (errno != ENOENT))
+		log_sys_debug("unlink", path);
+}
+
+int online_vg_file_create(struct cmd_context *cmd, const char *vgname)
+{
+	char path[PATH_MAX];
+	int fd;
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", VGS_ONLINE_DIR, vgname) < 0) {
+		log_error_pvscan(cmd, "Path %s/%s is too long.", VGS_ONLINE_DIR, vgname);
+		return 0;
+	}
+
+	log_debug("Create vg online: %s", path);
+
+	fd = open(path, O_CREAT | O_EXCL | O_TRUNC | O_RDWR, S_IRUSR | S_IWUSR);
+	if (fd < 0) {
+		log_debug("Failed to create %s: %d", path, errno);
+		return 0;
+	}
+
+	/* We don't care about syncing, these files are not even persistent. */
+
+	if (close(fd))
+		log_sys_debug("close", path);
+
+	return 1;
+}
+
+int online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const char *vgname)
+{
+	char path[PATH_MAX];
+	char buf[MAX_PVID_FILE_SIZE] = { 0 };
+	char file_vgname[NAME_LEN];
+	int file_major = 0, file_minor = 0;
+	int major, minor;
+	int fd;
+	int rv;
+	int len;
+	int len1 = 0;
+	int len2 = 0;
+
+	major = (int)MAJOR(dev->dev);
+	minor = (int)MINOR(dev->dev);
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, dev->pvid) < 0) {
+		log_error_pvscan(cmd, "Path %s/%s is too long.", PVS_ONLINE_DIR, dev->pvid);
+		return 0;
+	}
+
+	if ((len1 = dm_snprintf(buf, sizeof(buf), "%d:%d\n", major, minor)) < 0) {
+		log_error_pvscan(cmd, "Cannot create online file path for %s %d:%d.", dev_name(dev), major, minor);
+		return 0;
+	}
+
+	if (vgname) {
+		if ((len2 = dm_snprintf(buf + len1, sizeof(buf) - len1, "vg:%s\n", vgname)) < 0) {
+			log_print_pvscan(cmd, "Incomplete online file for %s %d:%d vg %s.", dev_name(dev), major, minor, vgname);
+			/* can still continue without vgname */
+			len2 = 0;
+		}
+	}
+
+	len = len1 + len2;
+
+	log_debug("Create pv online: %s %d:%d %s", path, major, minor, dev_name(dev));
+
+	fd = open(path, O_CREAT | O_EXCL | O_RDWR, S_IRUSR | S_IWUSR);
+	if (fd < 0) {
+		if (errno == EEXIST)
+			goto check_duplicate;
+		log_error_pvscan(cmd, "Failed to create online file for %s path %s error %d", dev_name(dev), path, errno);
+		return 0;
+	}
+
+	while (len > 0) {
+		rv = write(fd, buf, len);
+		if (rv < 0) {
+			/* file exists so it still works in part */
+			log_warn("Cannot write online file for %s to %s error %d",
+				  dev_name(dev), path, errno);
+			if (close(fd))
+				log_sys_debug("close", path);
+			return 1;
+		}
+		len -= rv;
+	}
+
+	/* We don't care about syncing, these files are not even persistent. */
+
+	if (close(fd))
+		log_sys_debug("close", path);
+
+	return 1;
+
+check_duplicate:
+
+	/*
+	 * If a PVID online file already exists for this PVID, check if the
+	 * file contains a different device number, and if so we may have a
+	 * duplicate PV.
+	 *
+	 * FIXME: disable autoactivation of the VG somehow?
+	 * The VG may or may not already be activated when a dupicate appears.
+	 * Perhaps write a new field in the pv online or vg online file?
+	 */
+
+	memset(file_vgname, 0, sizeof(file_vgname));
+
+	online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
+
+	if ((file_major == major) && (file_minor == minor)) {
+		log_debug("Existing online file for %d:%d", major, minor);
+		return 1;
+	}
+
+	/* Don't know how vgname might not match, but it's not good so fail. */
+
+	if ((file_major != major) || (file_minor != minor))
+		log_error_pvscan(cmd, "PV %s is duplicate for PVID %s on %d:%d and %d:%d.",
+			         dev_name(dev), dev->pvid, major, minor, file_major, file_minor);
+
+	if (file_vgname[0] && vgname && strcmp(file_vgname, vgname))
+		log_error_pvscan(cmd, "PV %s has unexpected VG %s vs %s.",
+			         dev_name(dev), vgname, file_vgname);
+
+	return 0;
+}
+
+int online_pvid_file_exists(const char *pvid)
+{
+	char path[PATH_MAX] = { 0 };
+	struct stat buf;
+	int rv;
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, pvid) < 0) {
+		log_debug(INTERNAL_ERROR "Path %s/%s is too long.", PVS_ONLINE_DIR, pvid);
+		return 0;
+	}
+
+	log_debug("Check pv online: %s", path);
+
+	rv = stat(path, &buf);
+	if (!rv) {
+		log_debug("Check pv online %s: yes", pvid);
+		return 1;
+	}
+	log_debug("Check pv online %s: no", pvid);
+	return 0;
+}
+
+void online_dir_setup(struct cmd_context *cmd)
+{
+	struct stat st;
+	int rv;
+
+	if (!stat(DEFAULT_RUN_DIR, &st))
+		goto do_pvs;
+
+	log_debug("Creating run_dir.");
+	dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
+	rv = mkdir(DEFAULT_RUN_DIR, 0755);
+	dm_prepare_selinux_context(NULL, 0);
+
+	if ((rv < 0) && stat(DEFAULT_RUN_DIR, &st))
+		log_error_pvscan(cmd, "Failed to create %s %d", DEFAULT_RUN_DIR, errno);
+
+do_pvs:
+	if (!stat(PVS_ONLINE_DIR, &st))
+		goto do_vgs;
+
+	log_debug("Creating pvs_online_dir.");
+	dm_prepare_selinux_context(PVS_ONLINE_DIR, S_IFDIR);
+	rv = mkdir(PVS_ONLINE_DIR, 0755);
+	dm_prepare_selinux_context(NULL, 0);
+
+	if ((rv < 0) && stat(PVS_ONLINE_DIR, &st))
+		log_error_pvscan(cmd, "Failed to create %s %d", PVS_ONLINE_DIR, errno);
+
+do_vgs:
+	if (!stat(VGS_ONLINE_DIR, &st))
+		goto do_lookup;
+
+	log_debug("Creating vgs_online_dir.");
+	dm_prepare_selinux_context(VGS_ONLINE_DIR, S_IFDIR);
+	rv = mkdir(VGS_ONLINE_DIR, 0755);
+	dm_prepare_selinux_context(NULL, 0);
+
+	if ((rv < 0) && stat(VGS_ONLINE_DIR, &st))
+		log_error_pvscan(cmd, "Failed to create %s %d", VGS_ONLINE_DIR, errno);
+
+do_lookup:
+	if (!stat(PVS_LOOKUP_DIR, &st))
+		return;
+
+	log_debug("Creating pvs_lookup_dir.");
+	dm_prepare_selinux_context(PVS_LOOKUP_DIR, S_IFDIR);
+	rv = mkdir(PVS_LOOKUP_DIR, 0755);
+	dm_prepare_selinux_context(NULL, 0);
+
+	if ((rv < 0) && stat(PVS_LOOKUP_DIR, &st))
+		log_error_pvscan(cmd, "Failed to create %s %d", PVS_LOOKUP_DIR, errno);
+
+
+}
diff --git a/lib/device/online.h b/lib/device/online.h
new file mode 100644
index 000000000..0a5076f7d
--- /dev/null
+++ b/lib/device/online.h
@@ -0,0 +1,46 @@
+/*
+ * Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#ifndef _ONLINE_H
+#define _ONLINE_H
+
+/*
+ * Avoid a duplicate pvscan[%d] prefix when logging to the journal.
+ * FIXME: this should probably replace if (udevoutput) with
+ * if (log_journal & LOG_JOURNAL_OUTPUT)
+ */
+#define log_print_pvscan(cmd, fmt, args...) \
+do \
+	if (cmd->udevoutput) \
+		log_print(fmt, ##args); \
+	else \
+		log_print("pvscan[%d] " fmt, getpid(), ##args); \
+while (0)
+
+#define log_error_pvscan(cmd, fmt, args...) \
+do \
+	if (cmd->udevoutput) \
+		log_error(fmt, ##args); \
+	else \
+		log_error("pvscan[%d] " fmt, getpid(), ##args); \
+while (0)
+
+int online_pvid_file_read(char *path, int *major, int *minor, char *vgname);
+int online_vg_file_create(struct cmd_context *cmd, const char *vgname);
+void online_vg_file_remove(const char *vgname);
+int online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const char *vgname);
+int online_pvid_file_exists(const char *pvid);
+void online_dir_setup(struct cmd_context *cmd);
+
+#endif
diff --git a/lib/label/hints.c b/lib/label/hints.c
index c84bd1f1c..85e5ab1cb 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -146,6 +146,7 @@
 #include "lib/label/hints.h"
 #include "lib/device/dev-type.h"
 #include "lib/device/device_id.h"
+#include "lib/device/online.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -156,8 +157,6 @@
 #include <sys/file.h>
 #include <sys/sysmacros.h>
 
-int online_pvid_file_read(char *path, int *major, int *minor, char *vgname);
-
 static const char *_hints_file = DEFAULT_RUN_DIR "/hints";
 static const char *_nohints_file = DEFAULT_RUN_DIR "/nohints";
 static const char *_newhints_file = DEFAULT_RUN_DIR "/newhints";
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9cbeab91d..0f2c832ae 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2393,8 +2393,10 @@ static void _reset_current_settings_to_default(struct cmd_context *cmd)
 
 static void _get_current_output_settings_from_args(struct cmd_context *cmd)
 {
-	if (arg_is_set(cmd, udevoutput_ARG))
+	if (arg_is_set(cmd, udevoutput_ARG)) {
 		cmd->current_settings.suppress = 1;
+		cmd->udevoutput = 1;
+	}
 
 	if (arg_is_set(cmd, debug_ARG))
 		cmd->current_settings.debug = _LOG_FATAL + (arg_count(cmd, debug_ARG) - 1);
diff --git a/tools/pvscan.c b/tools/pvscan.c
index d9607fdb6..c1f7fbe6d 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -18,11 +18,10 @@
 #include "lib/cache/lvmcache.h"
 #include "lib/metadata/metadata.h"
 #include "lib/label/hints.h"
+#include "lib/device/online.h"
 
 #include <dirent.h>
 
-int online_pvid_file_read(char *path, int *major, int *minor, char *vgname);
-
 struct pvscan_params {
 	int new_pvs_found;
 	int pvs_found;
@@ -44,10 +43,6 @@ struct pvscan_aa_params {
  */
 static struct volume_group *saved_vg;
 
-static const char *_pvs_online_dir = DEFAULT_RUN_DIR "/pvs_online";
-static const char *_vgs_online_dir = DEFAULT_RUN_DIR "/vgs_online";
-static const char *_pvs_lookup_dir = DEFAULT_RUN_DIR "/pvs_lookup";
-
 static int _pvscan_display_pv(struct cmd_context *cmd,
 				  struct physical_volume *pv,
 				  struct pvscan_params *params)
@@ -181,93 +176,12 @@ out:
 	return ret;
 }
 
-/*
- * Avoid a duplicate pvscan[%d] prefix when logging to the journal.
- * FIXME: this should probably replace if (udevoutput) with
- * if (log_journal & LOG_JOURNAL_OUTPUT)
- */
-#define log_print_pvscan(cmd, fmt, args...) \
-do \
-	if (arg_is_set(cmd, udevoutput_ARG)) \
-		log_print(fmt, ##args); \
-	else \
-		log_print("pvscan[%d] " fmt, getpid(), ##args); \
-while (0)
-
-#define log_error_pvscan(cmd, fmt, args...) \
-do \
-	if (arg_is_set(cmd, udevoutput_ARG)) \
-		log_error(fmt, ##args); \
-	else \
-		log_error("pvscan[%d] " fmt, getpid(), ##args); \
-while (0)
-
-static char *_vgname_in_pvid_file_buf(char *buf)
-{
-	char *p, *n;
-
-	/*
-	 * file contains:
-	 * <major>:<minor>\n
-	 * vg:<vgname>\n\0
-	 */
-
-	if (!(p = strchr(buf, '\n')))
-		return NULL;
-
-	p++; /* skip \n */
-
-	if (*p && !strncmp(p, "vg:", 3)) {
-		if ((n = strchr(p, '\n')))
-			*n = '\0';
-		return p + 3;
-	}
-	return NULL;
-}
-
-#define MAX_PVID_FILE_SIZE 512
-
-int online_pvid_file_read(char *path, int *major, int *minor, char *vgname)
-{
-	char buf[MAX_PVID_FILE_SIZE] = { 0 };
-	char *name;
-	int fd, rv;
-
-	fd = open(path, O_RDONLY);
-	if (fd < 0) {
-		log_warn("Failed to open %s", path);
-		return 0;
-	}
-
-	rv = read(fd, buf, sizeof(buf) - 1);
-	if (close(fd))
-		log_sys_debug("close", path);
-	if (!rv || rv < 0) {
-		log_warn("No info in %s", path);
-		return 0;
-	}
-	buf[rv] = 0; /* \0 terminated buffer */
-
-	if (sscanf(buf, "%d:%d", major, minor) != 2) {
-		log_warn("No device numbers in %s", path);
-		return 0;
-	}
-
-	/* vgname points to an offset in buf */
-	if ((name = _vgname_in_pvid_file_buf(buf)))
-		strncpy(vgname, name, NAME_LEN);
-	else
-		log_debug("No vgname in %s", path);
-
-	return 1;
-}
-
 static void _lookup_file_remove(char *vgname)
 {
 	char path[PATH_MAX];
 
-	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_lookup_dir, vgname) < 0) {
-		log_error("Path %s/%s is too long.", _pvs_lookup_dir, vgname);
+	if (dm_snprintf(path, sizeof(path), "%s/%s", PVS_LOOKUP_DIR, vgname) < 0) {
+		log_error("Path %s/%s is too long.", PVS_LOOKUP_DIR, vgname);
 		return;
 	}
 
@@ -277,27 +191,6 @@ static void _lookup_file_remove(char *vgname)
 		log_sys_debug("unlink", path);
 }
 
-/*
- * When a PV goes offline, remove the vg online file for that VG
- * (even if other PVs for the VG are still online).  This means
- * that the vg will be activated again when it becomes complete.
- */
-
-void online_vg_file_remove(const char *vgname)
-{
-	char path[PATH_MAX];
-
-	if (dm_snprintf(path, sizeof(path), "%s/%s", _vgs_online_dir, vgname) < 0) {
-		log_error("Path %s/%s is too long.", _vgs_online_dir, vgname);
-		return;
-	}
-
-	log_debug("Unlink vg online: %s", path);
-
-	if (unlink(path) && (errno != ENOENT))
-		log_sys_debug("unlink", path);
-}
-
 /*
  * When a device goes offline we only know its major:minor, not its PVID.
  * Since the dev isn't around, we can't read it to get its PVID, so we have to
@@ -316,7 +209,7 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 
 	log_debug("Remove pv online devno %d:%d", major, minor);
 
-	if (!(dir = opendir(_pvs_online_dir)))
+	if (!(dir = opendir(PVS_ONLINE_DIR)))
 		return;
 
 	while ((de = readdir(dir))) {
@@ -324,7 +217,7 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 			continue;
 
 		memset(path, 0, sizeof(path));
-		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, de->d_name);
+		snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, de->d_name);
 
 		file_major = 0;
 		file_minor = 0;
@@ -344,7 +237,7 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 		}
 	}
 	if (closedir(dir))
-		log_sys_debug("closedir", _pvs_online_dir);
+		log_sys_debug("closedir", PVS_ONLINE_DIR);
 }
 
 static void _online_files_remove(const char *dirpath)
@@ -369,128 +262,6 @@ static void _online_files_remove(const char *dirpath)
 		log_sys_debug("closedir", dirpath);
 }
 
-static int _online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const char *vgname)
-{
-	char path[PATH_MAX];
-	char buf[MAX_PVID_FILE_SIZE] = { 0 };
-	char file_vgname[NAME_LEN];
-	int file_major = 0, file_minor = 0;
-	int major, minor;
-	int fd;
-	int rv;
-	int len;
-	int len1 = 0;
-	int len2 = 0;
-
-	major = (int)MAJOR(dev->dev);
-	minor = (int)MINOR(dev->dev);
-
-	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, dev->pvid) < 0) {
-		log_error_pvscan(cmd, "Path %s/%s is too long.", _pvs_online_dir, dev->pvid);
-		return 0;
-	}
-
-	if ((len1 = dm_snprintf(buf, sizeof(buf), "%d:%d\n", major, minor)) < 0) {
-		log_error_pvscan(cmd, "Cannot create online file path for %s %d:%d.", dev_name(dev), major, minor);
-		return 0;
-	}
-
-	if (vgname) {
-		if ((len2 = dm_snprintf(buf + len1, sizeof(buf) - len1, "vg:%s\n", vgname)) < 0) {
-			log_print_pvscan(cmd, "Incomplete online file for %s %d:%d vg %s.", dev_name(dev), major, minor, vgname);
-			/* can still continue without vgname */
-			len2 = 0;
-		}
-	}
-
-	len = len1 + len2;
-
-	log_debug("Create pv online: %s %d:%d %s", path, major, minor, dev_name(dev));
-
-	fd = open(path, O_CREAT | O_EXCL | O_RDWR, S_IRUSR | S_IWUSR);
-	if (fd < 0) {
-		if (errno == EEXIST)
-			goto check_duplicate;
-		log_error_pvscan(cmd, "Failed to create online file for %s path %s error %d", dev_name(dev), path, errno);
-		return 0;
-	}
-
-	while (len > 0) {
-		rv = write(fd, buf, len);
-		if (rv < 0) {
-			/* file exists so it still works in part */
-			log_warn("Cannot write online file for %s to %s error %d",
-				  dev_name(dev), path, errno);
-			if (close(fd))
-				log_sys_debug("close", path);
-			return 1;
-		}
-		len -= rv;
-	}
-
-	/* We don't care about syncing, these files are not even persistent. */
-
-	if (close(fd))
-		log_sys_debug("close", path);
-
-	return 1;
-
-check_duplicate:
-
-	/*
-	 * If a PVID online file already exists for this PVID, check if the
-	 * file contains a different device number, and if so we may have a
-	 * duplicate PV.
-	 *
-	 * FIXME: disable autoactivation of the VG somehow?
-	 * The VG may or may not already be activated when a dupicate appears.
-	 * Perhaps write a new field in the pv online or vg online file?
-	 */
-
-	memset(file_vgname, 0, sizeof(file_vgname));
-
-	online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
-
-	if ((file_major == major) && (file_minor == minor)) {
-		log_debug("Existing online file for %d:%d", major, minor);
-		return 1;
-	}
-
-	/* Don't know how vgname might not match, but it's not good so fail. */
-
-	if ((file_major != major) || (file_minor != minor))
-		log_error_pvscan(cmd, "PV %s is duplicate for PVID %s on %d:%d and %d:%d.",
-			         dev_name(dev), dev->pvid, major, minor, file_major, file_minor);
-
-	if (file_vgname[0] && vgname && strcmp(file_vgname, vgname))
-		log_error_pvscan(cmd, "PV %s has unexpected VG %s vs %s.",
-			         dev_name(dev), vgname, file_vgname);
-
-	return 0;
-}
-
-static int _online_pvid_file_exists(const char *pvid)
-{
-	char path[PATH_MAX] = { 0 };
-	struct stat buf;
-	int rv;
-
-	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, pvid) < 0) {
-		log_debug(INTERNAL_ERROR "Path %s/%s is too long.", _pvs_online_dir, pvid);
-		return 0;
-	}
-
-	log_debug("Check pv online: %s", path);
-
-	rv = stat(path, &buf);
-	if (!rv) {
-		log_debug("Check pv online %s: yes", pvid);
-		return 1;
-	}
-	log_debug("Check pv online %s: no", pvid);
-	return 0;
-}
-
 static int _write_lookup_file(struct cmd_context *cmd, struct volume_group *vg)
 {
 	char path[PATH_MAX];
@@ -498,8 +269,8 @@ static int _write_lookup_file(struct cmd_context *cmd, struct volume_group *vg)
 	struct pv_list *pvl;
 	int fd;
 
-	if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_lookup_dir, vg->name) < 0) {
-		log_error_pvscan(cmd, "Path %s/%s is too long.", _pvs_lookup_dir, vg->name);
+	if (dm_snprintf(path, sizeof(path), "%s/%s", PVS_LOOKUP_DIR, vg->name) < 0) {
+		log_error_pvscan(cmd, "Path %s/%s is too long.", PVS_LOOKUP_DIR, vg->name);
 		return 0;
 	}
 
@@ -555,7 +326,7 @@ static void _lookup_file_count_pvid_files(FILE *fp, const char *vgname, int *pvs
 			continue;
 		}
 
-		if (_online_pvid_file_exists((const char *)pvid))
+		if (online_pvid_file_exists((const char *)pvid))
 			(*pvs_online)++;
 		else
 			(*pvs_offline)++;
@@ -616,8 +387,8 @@ static int _count_pvid_files_from_lookup_file(struct cmd_context *cmd, struct de
 	*pvs_online = 0;
 	*pvs_offline = 0;
 
-	if (!(dir = opendir(_pvs_lookup_dir))) {
-		log_sys_debug("opendir", _pvs_lookup_dir);
+	if (!(dir = opendir(PVS_LOOKUP_DIR))) {
+		log_sys_debug("opendir", PVS_LOOKUP_DIR);
 		return 0;
 	}
 
@@ -629,8 +400,8 @@ static int _count_pvid_files_from_lookup_file(struct cmd_context *cmd, struct de
 		if (de->d_name[0] == '.')
 			continue;
 
-		if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_lookup_dir, de->d_name) < 0) {
-			log_warn("WARNING: Path %s/%s is too long.", _pvs_lookup_dir, de->d_name);
+		if (dm_snprintf(path, sizeof(path), "%s/%s", PVS_LOOKUP_DIR, de->d_name) < 0) {
+			log_warn("WARNING: Path %s/%s is too long.", PVS_LOOKUP_DIR, de->d_name);
 			continue;
 		}
 
@@ -655,68 +426,13 @@ static int _count_pvid_files_from_lookup_file(struct cmd_context *cmd, struct de
 			log_sys_debug("fclose", path);
 	}
 	if (closedir(dir))
-		log_sys_debug("closedir", _pvs_lookup_dir);
+		log_sys_debug("closedir", PVS_LOOKUP_DIR);
 
 	*vgname_out = vgname;
 
 	return (vgname) ? 1 : 0;
 }
 
-static void _online_dir_setup(struct cmd_context *cmd)
-{
-	struct stat st;
-	int rv;
-
-	if (!stat(DEFAULT_RUN_DIR, &st))
-		goto do_pvs;
-
-	log_debug("Creating run_dir.");
-	dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
-	rv = mkdir(DEFAULT_RUN_DIR, 0755);
-	dm_prepare_selinux_context(NULL, 0);
-
-	if ((rv < 0) && stat(DEFAULT_RUN_DIR, &st))
-		log_error_pvscan(cmd, "Failed to create %s %d", DEFAULT_RUN_DIR, errno);
-
-do_pvs:
-	if (!stat(_pvs_online_dir, &st))
-		goto do_vgs;
-
-	log_debug("Creating pvs_online_dir.");
-	dm_prepare_selinux_context(_pvs_online_dir, S_IFDIR);
-	rv = mkdir(_pvs_online_dir, 0755);
-	dm_prepare_selinux_context(NULL, 0);
-
-	if ((rv < 0) && stat(_pvs_online_dir, &st))
-		log_error_pvscan(cmd, "Failed to create %s %d", _pvs_online_dir, errno);
-
-do_vgs:
-	if (!stat(_vgs_online_dir, &st))
-		goto do_lookup;
-
-	log_debug("Creating vgs_online_dir.");
-	dm_prepare_selinux_context(_vgs_online_dir, S_IFDIR);
-	rv = mkdir(_vgs_online_dir, 0755);
-	dm_prepare_selinux_context(NULL, 0);
-
-	if ((rv < 0) && stat(_vgs_online_dir, &st))
-		log_error_pvscan(cmd, "Failed to create %s %d", _vgs_online_dir, errno);
-
-do_lookup:
-	if (!stat(_pvs_lookup_dir, &st))
-		return;
-
-	log_debug("Creating pvs_lookup_dir.");
-	dm_prepare_selinux_context(_pvs_lookup_dir, S_IFDIR);
-	rv = mkdir(_pvs_lookup_dir, 0755);
-	dm_prepare_selinux_context(NULL, 0);
-
-	if ((rv < 0) && stat(_pvs_lookup_dir, &st))
-		log_error_pvscan(cmd, "Failed to create %s %d", _pvs_lookup_dir, errno);
-
-
-}
-
 static void _count_pvid_files(struct volume_group *vg, int *pvs_online, int *pvs_offline)
 {
 	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
@@ -727,7 +443,7 @@ static void _count_pvid_files(struct volume_group *vg, int *pvs_online, int *pvs
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
-		if (_online_pvid_file_exists(pvid))
+		if (online_pvid_file_exists(pvid))
 			(*pvs_online)++;
 		else
 			(*pvs_offline)++;
@@ -758,32 +474,6 @@ static int _pvscan_aa_single(struct cmd_context *cmd, const char *vg_name,
 	return ECMD_PROCESSED;
 }
 
-static int _online_vg_file_create(struct cmd_context *cmd, const char *vgname)
-{
-	char path[PATH_MAX];
-	int fd;
-
-	if (dm_snprintf(path, sizeof(path), "%s/%s", _vgs_online_dir, vgname) < 0) {
-		log_error_pvscan(cmd, "Path %s/%s is too long.", _vgs_online_dir, vgname);
-		return 0;
-	}
-
-	log_debug("Create vg online: %s", path);
-
-	fd = open(path, O_CREAT | O_EXCL | O_TRUNC | O_RDWR, S_IRUSR | S_IWUSR);
-	if (fd < 0) {
-		log_debug("Failed to create %s: %d", path, errno);
-		return 0;
-	}
-
-	/* We don't care about syncing, these files are not even persistent. */
-
-	if (close(fd))
-		log_sys_debug("close", path);
-
-	return 1;
-}
-
 /*
  * This is a very unconventional way of doing things because
  * we want to figure out which devices to read the VG from
@@ -843,7 +533,7 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 		memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
 
 		memset(path, 0, sizeof(path));
-		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, pvid);
+		snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, pvid);
 
 		file_major = 0;
 		file_minor = 0;
@@ -1072,7 +762,7 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 	 * to run the activation.  The first to create the file will do it.
 	 */
 	dm_list_iterate_items_safe(sl, sl2, vgnames) {
-		if (!_online_vg_file_create(cmd, sl->str)) {
+		if (!online_vg_file_create(cmd, sl->str)) {
 			log_print_pvscan(cmd, "VG %s skip autoactivation.", sl->str);
 			str_list_del(vgnames, sl->str);
 			continue;
@@ -1242,7 +932,7 @@ static void _set_pv_devices_online(struct cmd_context *cmd, struct volume_group
 			continue;
 		}
 
-		if (!_online_pvid_file_exists(pvid)) {
+		if (!online_pvid_file_exists(pvid)) {
 			log_debug("set_pv_devices_online vg %s pv %s no online file",
 				  vg->name, pvid);
 			pvl->pv->status |= MISSING_PV;
@@ -1250,7 +940,7 @@ static void _set_pv_devices_online(struct cmd_context *cmd, struct volume_group
 		}
 
 		memset(path, 0, sizeof(path));
-		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, pvid);
+		snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, pvid);
 
 		major = 0;
 		minor = 0;
@@ -1422,7 +1112,7 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 		 * Create file named for pvid to record this PV is online.
 		 * The command creates/checks online files only when --cache is used.
 		 */
-		if (do_cache && !_online_pvid_file_create(cmd, dev, vg ? vg->name : NULL)) {
+		if (do_cache && !online_pvid_file_create(cmd, dev, vg ? vg->name : NULL)) {
 			log_error_pvscan(cmd, "PV %s failed to create online file.", dev_name(dev));
 			release_vg(vg);
 			ret = 0;
@@ -1507,7 +1197,7 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 			} else if (!do_check_complete) {
 				log_print("VG %s", vgname);
 			} else if (vg_complete) {
-				if (do_vgonline && !_online_vg_file_create(cmd, vgname)) {
+				if (do_vgonline && !online_vg_file_create(cmd, vgname)) {
 					log_print("VG %s finished", vgname);
 				} else {
 					/*
@@ -1613,9 +1303,9 @@ static int _pvscan_cache_all(struct cmd_context *cmd, int argc, char **argv,
 
 	dm_list_init(&pvscan_devs);
 
-	_online_files_remove(_pvs_online_dir);
-	_online_files_remove(_vgs_online_dir);
-	_online_files_remove(_pvs_lookup_dir);
+	_online_files_remove(PVS_ONLINE_DIR);
+	_online_files_remove(VGS_ONLINE_DIR);
+	_online_files_remove(PVS_LOOKUP_DIR);
 
 	unlink_searched_devnames(cmd);
 
@@ -1958,7 +1648,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	do_all = !argc && !devno_args;
 
-	_online_dir_setup(cmd);
+	online_dir_setup(cmd);
 
 	if (do_all) {
 		if (!_pvscan_cache_all(cmd, argc, argv, &complete_vgnames))
diff --git a/tools/toollib.c b/tools/toollib.c
index d6f48aad2..33b704134 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -17,6 +17,7 @@
 #include "lib/format_text/format-text.h"
 #include "lib/label/hints.h"
 #include "lib/device/device_id.h"
+#include "lib/device/online.h"
 
 #include <sys/stat.h>
 #include <signal.h>
diff --git a/tools/tools.h b/tools/tools.h
index 182ff3af9..cd89e1692 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -295,6 +295,4 @@ int lvconvert_cachevol_attach_single(struct cmd_context *cmd,
                                      struct logical_volume *lv,
                                      struct processing_handle *handle);
 
-void online_vg_file_remove(const char *vgname);
-
 #endif


