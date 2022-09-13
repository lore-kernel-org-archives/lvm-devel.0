From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Sep 2022 20:18:06 +0000 (GMT)
Subject: main - lvresize: add new options and defaults for fs handling
Message-ID: <20220913201806.A30A5385840A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=264827cb98458f7100456eeebf7fdde8dcbc0ad4
Commit:        264827cb98458f7100456eeebf7fdde8dcbc0ad4
Parent:        18722dfdf4d3e6f172d0b2af8bbdc4a154ea1dc0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 14 15:20:21 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 13 15:15:05 2022 -0500

lvresize: add new options and defaults for fs handling

The new option "--fs String" for lvresize/lvreduce/lvextend
controls the handling of file systems before/after resizing
the LV.  --resizefs is the same as --fs resize.

The new option "--fsmode String" can be used to control
mounting and unmounting of the fs during resizing.

Possible --fs values:

checksize
  Only applies to reducing size; does nothing for extend.
  Check the fs size and reduce the LV if the fs is not using
  the affected space, i.e. the fs does not need to be shrunk.
  Fail the command without reducing the fs or LV if the fs is
  using the affected space.

resize
  Resize the fs using the fs-specific resize command.
  This may include mounting, unmounting, or running fsck.
  See --fsmode to control mounting behavior, and --nofsck to
  disable fsck.

resize_fsadm
  Use the old method of calling fsadm to handle the fs
  (deprecated.) Warning: this option does not prevent lvreduce
  from destroying file systems that are unmounted (or mounted
  if prompts are skipped.)

ignore
  Resize the LV without checking for or handling a file system.
  Warning: using ignore when reducing the LV size may destroy the
  file system.

Possible --fsmode values:

manage
  Mount or unmount the fs as needed to resize the fs,
  and attempt to restore the original mount state at the end.

nochange
  Do not mount or unmount the fs. If mounting or unmounting
  is required to resize the fs, then do not resize the fs or
  the LV and fail the command.

offline
  Unmount the fs if it is mounted, and resize the fs while it
  is unmounted. If mounting is required to resize the fs,
  then do not resize the fs or the LV and fail the command.

Notes on lvreduce:

When no --fs or --resizefs option is specified:
. lvextend default behavior is fs ignore.
. lvreduce default behavior is fs checksize
  (includes activating the LV.)

With the exception of --fs resize_fsadm|ignore, lvreduce requires
the recent libblkid fields FSLASTBLOCK and FSBLOCKSIZE.
FSLASTBLOCK*FSBLOCKSIZE is the last byte used by the fs on the LV,
which determines if reducing the fs is necessary.
---
 configure.ac                        |   12 +
 include/configure.h.in              |    3 +-
 lib/Makefile.in                     |    1 +
 lib/activate/dev_manager.c          |   75 +++
 lib/activate/dev_manager.h          |    2 +
 lib/device/dev-type.c               |   91 +++
 lib/device/dev-type.h               |    2 +
 lib/device/filesystem.c             |  400 ++++++++++++
 lib/device/filesystem.h             |   50 ++
 lib/metadata/lv_manip.c             |  763 ++++++++++++++++++++--
 lib/metadata/metadata-exported.h    |    7 +-
 lib/metadata/metadata.c             |    4 +-
 lib/metadata/metadata.h             |    2 +
 scripts/Makefile.in                 |    6 +-
 scripts/fsadm.sh                    |    2 +-
 scripts/lvresize_fs_helper.sh       |  466 ++++++++++++++
 spec/packages.inc                   |    1 +
 test/shell/fsadm-crypt-fsresize.sh  |  612 ++++++++++++++++++
 test/shell/fsadm-crypt.sh           |  130 ++--
 test/shell/fsadm.sh                 |   37 +-
 test/shell/hints.sh                 |    4 +-
 test/shell/lvresize-fs-crypt.sh     |  131 ++++
 test/shell/lvresize-fs.sh           | 1186 +++++++++++++++++++++++++++++++++++
 test/shell/lvresize-full.sh         |    7 +-
 test/shell/lvresize-mirror.sh       |    2 +-
 test/shell/lvresize-rounding.sh     |   10 +-
 test/shell/relative-sign-options.sh |   16 +-
 tools/args.h                        |   35 +-
 tools/command-lines.in              |   12 +-
 tools/lvresize.c                    |  115 +++-
 30 files changed, 3987 insertions(+), 197 deletions(-)

diff --git a/configure.ac b/configure.ac
index 39bbc4fef..e0593aba0 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1605,6 +1605,11 @@ AC_ARG_WITH(usrsbindir,
 			   [usrsbin executables in DIR [PREFIX/sbin]]),
 	    usrsbindir=$withval, usrsbindir='${prefix}/sbin')
 
+AC_ARG_WITH(libexecdir,
+	    AS_HELP_STRING([--with-libexecdir=DIR],
+			   [libexec executables in DIR [PREFIX/libexec]]),
+	    libexecdir=$withval, libexecdir='${prefix}/libexec')
+
 ################################################################################
 AC_ARG_WITH(udev_prefix,
 	    AS_HELP_STRING([--with-udev-prefix=UPREFIX],
@@ -1709,6 +1714,11 @@ AC_DEFINE_UNQUOTED(FSADM_PATH, ["$FSADM_PATH"], [Path to fsadm binary.])
 LVMIMPORTVDO_PATH="$SBINDIR/lvm_import_vdo"
 AC_DEFINE_UNQUOTED(LVMIMPORTVDO_PATH, ["$LVMIMPORTVDO_PATH"], [Path to lvm_import_vdo script.])
 
+LIBEXECDIR="$(eval echo $(eval echo $libexecdir))"
+
+LVRESIZE_FS_HELPER_PATH="$LIBEXECDIR/lvresize_fs_helper"
+AC_DEFINE_UNQUOTED(LVRESIZE_FS_HELPER_PATH, ["$LVRESIZE_FS_HELPER_PATH"], [Path to lvresize_fs_helper script.])
+
 ################################################################################
 dnl -- dmeventd pidfile and executable path
 if test "$BUILD_DMEVENTD" = yes; then
@@ -1878,6 +1888,7 @@ AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
 AC_SUBST(FSADM)
 AC_SUBST(FSADM_PATH)
+AC_SUBST(LVRESIZE_FS_HELPER_PATH)
 AC_SUBST(BLKDEACTIVATE)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
@@ -1976,6 +1987,7 @@ AC_SUBST(systemdutildir)
 AC_SUBST(tmpfilesdir)
 AC_SUBST(usrlibdir)
 AC_SUBST(usrsbindir)
+AC_SUBST(libexecdir)
 
 ################################################################################
 dnl -- First and last lines should not contain files to generate in order to
diff --git a/include/configure.h.in b/include/configure.h.in
index 230658f7b..584c2b4f1 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -127,8 +127,9 @@
 /* Define to 1 to include the LVM editline shell. */
 #undef EDITLINE_SUPPORT
 
-/* Path to fsadm binary. */
+/* Paths to binaries. */
 #undef FSADM_PATH
+#undef LVRESIZE_FS_HELPER_PATH
 
 /* Define to use GNU versioning in the shared library. */
 #undef GNU_SYMVER
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 3ab5cb2f1..3380b28fb 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -40,6 +40,7 @@ SOURCES =\
 	device/dev-luks.c \
 	device/dev-dasd.c \
 	device/dev-lvm1-pool.c \
+	device/filesystem.c \
 	device/online.c \
 	device/parse_vpd.c \
 	display/display.c \
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2bfd275fd..5fec52a2a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -4028,3 +4028,78 @@ out:
 
 	return r;
 }
+
+/*
+ * crypt offset is usually the LUKS header size but can be larger.
+ * The LUKS header is usually 2MB for LUKS1 and 16MB for LUKS2.
+ * The offset needs to be subtracted from the LV size to get the
+ * size used to resize the crypt device.
+ */
+int get_crypt_table_offset(dev_t crypt_devt, uint32_t *offset_bytes)
+{
+	struct dm_task *dmt = dm_task_create(DM_DEVICE_TABLE);
+	uint64_t start, length;
+	char *target_type = NULL;
+	void *next = NULL;
+	char *params = NULL;
+	char offset_str[32] = { 0 };
+	int copy_offset = 0;
+	int spaces = 0;
+	int i, i_off = 0;
+
+	if (!dmt)
+		return_0;
+
+	if (!dm_task_set_major_minor(dmt, (int)MAJOR(crypt_devt), (int)MINOR(crypt_devt), 0)) {
+		dm_task_destroy(dmt);
+		return_0;
+	}
+
+	/* Non-blocking status read */
+	if (!dm_task_no_flush(dmt))
+		log_warn("WARNING: Can't set no_flush for dm status.");
+
+	if (!dm_task_run(dmt)) {
+		dm_task_destroy(dmt);
+		return_0;
+	}
+
+	next = dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
+
+	if (!target_type || !params || strcmp(target_type, "crypt")) {
+		dm_task_destroy(dmt);
+		return_0;
+	}
+
+	/*
+	 * get offset from params string:
+	 * <cipher> <key> <iv_offset> <device> <offset> [<#opt_params> <opt_params>]
+	 * <offset> is reported in 512 byte sectors.
+	 */
+	for (i = 0; i < strlen(params); i++) {
+		if (params[i] == ' ') {
+			spaces++;
+			if (spaces == 4)
+				copy_offset = 1;
+			if (spaces == 5)
+				break;
+			continue;
+		}
+		if (!copy_offset)
+			continue;
+
+		offset_str[i_off++] = params[i];
+
+		if (i_off == sizeof(offset_str)) {
+			offset_str[0] = '\0';
+			break;
+		}
+	}
+	dm_task_destroy(dmt);
+
+	if (!offset_str[0])
+		return_0;
+
+	*offset_bytes = ((uint32_t)strtoul(offset_str, NULL, 0) * 512);
+	return 1;
+}
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 9980e1647..b494e3eaf 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -29,6 +29,8 @@ struct lv_seg_status;
 
 int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts *laopts, const char *layer);
 
+int get_crypt_table_offset(dev_t crypt_devt, uint32_t *offset_bytes);
+
 /*
  * Constructor and destructor.
  */
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index b1cf5b431..fb6e9a444 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -26,6 +26,11 @@
 
 #ifdef BLKID_WIPING_SUPPORT
 #include <blkid.h>
+/*
+ * FIXME: recent addition to blkid.h copied here.
+ * Remove this and require a recent libblkid version from configure.
+ */
+#define BLKID_SUBLKS_FSINFO     (1 << 11) /* read and define fs properties from superblock */
 #endif
 
 #ifdef UDEV_SYNC_SUPPORT
@@ -880,12 +885,98 @@ out:
 	blkid_free_probe(probe);
 	return ret;
 }
+
+int fs_get_blkid(const char *pathname, struct fs_info *fsi)
+{
+	blkid_probe probe = NULL;
+	const char *str;
+	size_t len;
+	uint64_t fslastblock = 0;
+	unsigned int fsblocksize = 0;
+	int no_block_size = 0, no_fslastblock = 0, no_fsblocksize = 0;
+	int rc;
+
+	if (!(probe = blkid_new_probe_from_filename(pathname))) {
+		log_error("Failed libblkid probe setup for %s", pathname);
+		return 0;
+	}
+
+	blkid_probe_enable_superblocks(probe, 1);
+	blkid_probe_set_superblocks_flags(probe,
+			BLKID_SUBLKS_LABEL | BLKID_SUBLKS_LABELRAW |
+			BLKID_SUBLKS_UUID | BLKID_SUBLKS_UUIDRAW |
+			BLKID_SUBLKS_TYPE | BLKID_SUBLKS_SECTYPE |
+			BLKID_SUBLKS_USAGE | BLKID_SUBLKS_VERSION |
+			BLKID_SUBLKS_MAGIC | BLKID_SUBLKS_FSINFO);
+	rc = blkid_do_safeprobe(probe);
+	if (rc < 0) {
+		log_error("Failed libblkid probe for %s", pathname);
+		blkid_free_probe(probe);
+		return 0;
+	} else if (rc == 1) {
+		/* no file system on the device */
+		log_print("No file system found on %s.", pathname);
+		fsi->nofs = 1;
+		blkid_free_probe(probe);
+		return 1;
+	}
+
+	if (!blkid_probe_lookup_value(probe, "TYPE", &str, &len) && len)
+		strncpy(fsi->fstype, str, sizeof(fsi->fstype)-1);
+	else {
+		/* any difference from blkid_do_safeprobe rc=1? */
+		log_print("No file system type on %s.", pathname);
+		fsi->nofs = 1;
+		blkid_free_probe(probe);
+		return 1;
+	}
+
+	if (!blkid_probe_lookup_value(probe, "BLOCK_SIZE", &str, &len) && len)
+		fsi->fs_block_size_bytes = atoi(str);
+	else
+		no_block_size = 1;
+
+	if (!blkid_probe_lookup_value(probe, "FSLASTBLOCK", &str, &len) && len)
+		fslastblock = strtoull(str, NULL, 0);
+	else
+		no_fslastblock = 1;
+
+	if (!blkid_probe_lookup_value(probe, "FSBLOCKSIZE", &str, &len) && len)
+		fsblocksize = (unsigned int)atoi(str);
+	else
+		no_fsblocksize = 1;
+
+	blkid_free_probe(probe);
+
+	/* We don't expect to get this info for luks */
+	if (strcmp(fsi->fstype, "crypto_LUKS") && (no_block_size || no_fslastblock || no_fsblocksize)) {
+		log_print("Missing libblkid %s%s%sfor %s",
+			  no_block_size ? "BLOCK_SIZE " : "",
+			  no_fslastblock ? "FSLASTBLOCK " : "",
+			  no_fsblocksize ? "FSBLOCKSIZE " : "",
+			  pathname);
+	}
+
+	if (fslastblock && fsblocksize)
+		fsi->fs_last_byte = fslastblock * fsblocksize;
+
+	log_debug("libblkid TYPE %s BLOCK_SIZE %d FSLASTBLOCK %llu FSBLOCKSIZE %u fs_last_byte %llu",
+		  fsi->fstype, fsi->fs_block_size_bytes, (unsigned long long)fslastblock, fsblocksize,
+		  (unsigned long long)fsi->fs_last_byte);
+	return 1;
+}
+
 #else
 int fs_block_size_and_type(const char *pathname, uint32_t *fs_block_size_bytes, char *fstype, int *nofs)
 {
 	log_debug("Disabled blkid BLOCK_SIZE for fs.");
 	return 0;
 }
+int fs_get_blkid(const char *pathname, struct fs_info *fsi)
+{
+	log_debug("Disabled blkid for fs info.");
+	return 0;
+}
 #endif
 
 #ifdef BLKID_WIPING_SUPPORT
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 4f793b0e0..efbf995c2 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -18,6 +18,7 @@
 #include "lib/device/device.h"
 #include "lib/display/display.h"
 #include "lib/label/label.h"
+#include "lib/device/filesystem.h"
 
 #define NUMBER_OF_MAJORS 4096
 
@@ -103,6 +104,7 @@ int dev_is_lv(struct device *dev);
 
 #define FSTYPE_MAX 16
 int fs_block_size_and_type(const char *pathname, uint32_t *fs_block_size_bytes, char *fstype, int *nofs);
+int fs_get_blkid(const char *pathname, struct fs_info *fsi);
 
 int dev_is_used_by_active_lv(struct cmd_context *cmd, struct device *dev, int *used_by_lv_count,
 			     char **used_by_dm_name, char **used_by_vg_uuid, char **used_by_lv_uuid);
diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
new file mode 100644
index 000000000..c53a377ea
--- /dev/null
+++ b/lib/device/filesystem.c
@@ -0,0 +1,400 @@
+/*
+ * Copyright (C) 2022 Red Hat, Inc. All rights reserved.
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
+#include "lib/device/dev-type.h"
+#include "lib/misc/lvm-exec.h"
+#include "lib/activate/dev_manager.h"
+
+#include <dirent.h>
+#include <mntent.h>
+#include <sys/ioctl.h>
+
+/*
+ * Set the path of the dm-crypt device, i.e. /dev/dm-N, that is using the LV.
+ */
+static int _get_crypt_path(dev_t lv_devt, char *lv_path, char *crypt_path)
+{
+	char holders_path[PATH_MAX];
+	char *holder_name;
+	DIR *dr;
+	struct stat st;
+	struct dirent *de;
+	int ret = 0;
+
+	if (dm_snprintf(holders_path, sizeof(holders_path), "%sdev/block/%d:%d/holders",
+			dm_sysfs_dir(), (int)MAJOR(lv_devt), (int)MINOR(lv_devt)) < 0)
+		return_0;
+
+	/* If the crypt dev is not active, there will be no LV holder. */
+	if (stat(holders_path, &st)) {
+		log_error("Missing %s for %s", crypt_path, lv_path);
+		return 0;
+	}
+
+	if (!(dr = opendir(holders_path))) {
+		log_error("Cannot open %s", holders_path);
+		return 0;
+	}
+
+	while ((de = readdir(dr))) {
+		if (!strcmp(de->d_name, ".") || !strcmp(de->d_name, ".."))
+			continue;
+
+		holder_name = de->d_name;
+
+		if (strncmp(holder_name, "dm", 2)) {
+			log_error("Unrecognized holder %s of %s", holder_name, lv_path);
+			ret = 0;
+			break;
+		}
+
+		/* We could read the holder's dm uuid to verify it's a crypt dev. */
+
+		if (dm_snprintf(crypt_path, PATH_MAX, "/dev/%s", holder_name) < 0) {
+			ret = 0;
+			stack;
+			break;
+		}
+		ret = 1;
+		break;
+	}
+	closedir(dr);
+	if (ret)
+		log_debug("Found holder %s of %s.", crypt_path, lv_path);
+	else
+		log_debug("No holder in %s", holders_path);
+	return ret;
+}
+
+int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
+		struct fs_info *fsi, int include_mount)
+{
+	char lv_path[PATH_MAX];
+	char crypt_path[PATH_MAX];
+	struct stat st_lv;
+	struct stat st_crypt;
+	struct stat st_top;
+	struct stat stme;
+	struct fs_info info;
+	FILE *fme = NULL;
+	struct mntent *me;
+	int ret;
+
+	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", lv->vg->cmd->dev_dir,
+			lv->vg->name, lv->name) < 0) {
+		log_error("Couldn't create LV path for %s.", display_lvname(lv));
+		return 0;
+	}
+
+	if (stat(lv_path, &st_lv) < 0) {
+		log_error("Failed to get LV path %s", lv_path);
+		return 0;
+	}
+
+	memset(&info, 0, sizeof(info));
+
+	if (!fs_get_blkid(lv_path, &info)) {
+		log_error("No file system info from blkid for %s", display_lvname(lv));
+		return 0;
+	}
+
+	if (fsi->nofs)
+		return 1;
+
+	/*
+	 * If there's a LUKS dm-crypt layer over the LV, then
+	 * return fs info from that layer, setting needs_crypt
+	 * to indicate a crypt layer between the fs and LV.
+	 */
+	if (!strcmp(info.fstype, "crypto_LUKS")) {
+		if (!_get_crypt_path(st_lv.st_rdev, lv_path, crypt_path)) {
+			log_error("Cannot find active LUKS dm-crypt device using %s.",
+				  display_lvname(lv));
+			return 0;
+		}
+
+		if (stat(crypt_path, &st_crypt) < 0) {
+			log_error("Failed to get crypt path %s", crypt_path);
+			return 0;
+		}
+
+		memset(&info, 0, sizeof(info));
+
+		log_print("File system found on crypt device %s on LV %s.",
+			  crypt_path, display_lvname(lv));
+
+		if (!fs_get_blkid(crypt_path, &info)) {
+			log_error("No file system info from blkid for dm-crypt device %s on LV %s.",
+				  crypt_path, display_lvname(lv));
+			return 0;
+		}
+		*fsi = info;
+		fsi->needs_crypt = 1;
+		fsi->crypt_devt = st_crypt.st_rdev;
+		memcpy(fsi->fs_dev_path, crypt_path, PATH_MAX);
+		st_top = st_crypt;
+
+		if (!get_crypt_table_offset(st_crypt.st_rdev, &fsi->crypt_offset_bytes)) {
+			log_error("Failed to get crypt data offset.");
+			return 0;
+		}
+	} else {
+		*fsi = info;
+		memcpy(fsi->fs_dev_path, lv_path, PATH_MAX);
+		st_top = st_lv;
+	}
+
+	if (!include_mount)
+		return 1;
+
+	if (!(fme = setmntent("/etc/mtab", "r")))
+		return_0;
+
+	ret = 1;
+
+	while ((me = getmntent(fme))) {
+		if (strcmp(me->mnt_type, fsi->fstype))
+			continue;
+		if (me->mnt_dir[0] != '/')
+			continue;
+		if (me->mnt_fsname[0] != '/')
+			continue;
+		if (stat(me->mnt_dir, &stme) < 0)
+			continue;
+		if (stme.st_dev != st_top.st_rdev)
+			continue;
+
+		log_debug("fs_get_info %s is mounted \"%s\"", fsi->fs_dev_path, me->mnt_dir);
+		fsi->mounted = 1;
+		strncpy(fsi->mount_dir, me->mnt_dir, PATH_MAX-1);
+	}
+	endmntent(fme);
+
+	fsi->unmounted = !fsi->mounted;
+	return ret;
+}
+
+#define FS_CMD_MAX_ARGS 16
+
+int crypt_resize_script(struct cmd_context *cmd, struct logical_volume *lv, struct fs_info *fsi,
+			uint64_t newsize_bytes_fs)
+{
+	char crypt_path[PATH_MAX];
+	char newsize_str[16] = { 0 };
+	const char *argv[FS_CMD_MAX_ARGS + 4];
+	int args = 0;
+	int status;
+
+	if (dm_snprintf(newsize_str, sizeof(newsize_str), "%llu", (unsigned long long)newsize_bytes_fs) < 0)
+		return_0;
+
+	if (dm_snprintf(crypt_path, sizeof(crypt_path), "/dev/dm-%d", (int)MINOR(fsi->crypt_devt)) < 0)
+		return_0;
+
+	argv[0] = LVRESIZE_FS_HELPER_PATH; /* from configure, usually in /usr/libexec */
+	argv[++args] = "--cryptresize";
+	argv[++args] = "--cryptpath";
+	argv[++args] = crypt_path;
+	argv[++args] = "--newsizebytes";
+	argv[++args] = newsize_str;
+	argv[++args] = NULL;
+
+	if (!exec_cmd(cmd, argv, &status, 1)) {
+		log_error("Failed to resize crypt dev with lvresize_fs_helper.");
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * The helper script does the following steps for reduce:
+ * devpath = $cryptpath ? $cryptpath : $lvpath
+ * if needs_unmount
+ * 	umount $mountdir 
+ * if needs_fsck
+ * 	e2fsck -f -p $devpath
+ * if needs_mount
+ * 	mount $devpath $tmpdir
+ * if $fstype == "ext"
+ * 	resize2fs $devpath $newsize_kb
+ * if needs_crypt
+ * 	cryptsetup resize --size $newsize_sectors $cryptpath
+ *
+ * Note: when a crypt layer is included, newsize_bytes_fs is smaller
+ * than newsize_bytes_lv because of the crypt header.
+ */
+
+int fs_reduce_script(struct cmd_context *cmd, struct logical_volume *lv, struct fs_info *fsi,
+		     uint64_t newsize_bytes_fs, char *fsmode)
+{
+	char lv_path[PATH_MAX];
+	char crypt_path[PATH_MAX];
+	char newsize_str[16] = { 0 };
+	const char *argv[FS_CMD_MAX_ARGS + 4];
+	char *devpath;
+	int args = 0;
+	int status;
+
+	if (dm_snprintf(newsize_str, sizeof(newsize_str), "%llu", (unsigned long long)newsize_bytes_fs) < 0)
+		return_0;
+
+	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0)
+		return_0;
+
+	argv[0] = LVRESIZE_FS_HELPER_PATH; /* from configure, usually in /usr/libexec */
+	argv[++args] = "--fsreduce";
+	argv[++args] = "--fstype";
+	argv[++args] = fsi->fstype;
+	argv[++args] = "--lvpath";
+	argv[++args] = lv_path;
+
+	if (newsize_bytes_fs) {
+		argv[++args] = "--newsizebytes";
+		argv[++args] = newsize_str;
+	}
+	if (fsi->mounted) {
+		argv[++args] = "--mountdir";
+		argv[++args] = fsi->mount_dir;
+	}
+
+	if (fsi->needs_unmount)
+		argv[++args] = "--unmount";
+	if (fsi->needs_mount)
+		argv[++args] = "--mount";
+	if (fsi->needs_fsck)
+		argv[++args] = "--fsck";
+
+	if (fsi->needs_crypt) {
+		if (dm_snprintf(crypt_path, sizeof(crypt_path), "/dev/dm-%d", (int)MINOR(fsi->crypt_devt)) < 0)
+			return_0;
+		argv[++args] = "--cryptresize";
+		argv[++args] = "--cryptpath";
+		argv[++args] = crypt_path;
+	}
+
+	/*
+	 * fsmode manage means the fs should be remounted after
+	 * resizing if it was unmounted.
+	 */
+	if (fsi->needs_unmount && !strcmp(fsmode, "manage"))
+		argv[++args] = "--remount";
+
+	argv[++args] = NULL;
+
+	devpath = fsi->needs_crypt ? crypt_path : (char *)display_lvname(lv);
+
+	log_print("Reducing file system %s to %s (%llu bytes) on %s...",
+		  fsi->fstype, display_size(cmd, newsize_bytes_fs/512),
+		  (unsigned long long)newsize_bytes_fs, devpath);
+
+	if (!exec_cmd(cmd, argv, &status, 1)) {
+		log_error("Failed to reduce file system with lvresize_fs_helper.");
+		return 0;
+	}
+
+	log_print("Reduced file system %s on %s.", fsi->fstype, devpath);
+
+	return 1;
+}
+
+/*
+ * The helper script does the following steps for extend:
+ * devpath = $cryptpath ? $cryptpath : $lvpath
+ * if needs_unmount
+ * 	umount $mountdir 
+ * if needs_fsck
+ * 	e2fsck -f -p $devpath
+ * if needs_crypt
+ * 	cryptsetup resize $cryptpath
+ * if needs_mount
+ * 	mount $devpath $tmpdir
+ * if $fstype == "ext"
+ * 	resize2fs $devpath
+ * if $fstype == "xfs"
+ * 	xfs_growfs $devpath
+ *
+ * Note: when a crypt layer is included, newsize_bytes_fs is smaller
+ * than newsize_bytes_lv because of the crypt header.
+ */
+
+int fs_extend_script(struct cmd_context *cmd, struct logical_volume *lv, struct fs_info *fsi,
+		     uint64_t newsize_bytes_fs, char *fsmode)
+{
+	char lv_path[PATH_MAX];
+	char crypt_path[PATH_MAX];
+	const char *argv[FS_CMD_MAX_ARGS + 4];
+	char *devpath;
+	int args = 0;
+	int status;
+
+	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0)
+		return_0;
+
+	argv[0] = LVRESIZE_FS_HELPER_PATH; /* from configure, usually in /usr/libexec */
+	argv[++args] = "--fsextend";
+	argv[++args] = "--fstype";
+	argv[++args] = fsi->fstype;
+	argv[++args] = "--lvpath";
+	argv[++args] = lv_path;
+
+	if (fsi->mounted) {
+		argv[++args] = "--mountdir";
+		argv[++args] = fsi->mount_dir;
+	}
+
+	if (fsi->needs_unmount)
+		argv[++args] = "--unmount";
+	if (fsi->needs_mount)
+		argv[++args] = "--mount";
+	if (fsi->needs_fsck)
+		argv[++args] = "--fsck";
+
+	if (fsi->needs_crypt) {
+		if (dm_snprintf(crypt_path, sizeof(crypt_path), "/dev/dm-%d", (int)MINOR(fsi->crypt_devt)) < 0)
+			return_0;
+		argv[++args] = "--cryptresize";
+		argv[++args] = "--cryptpath";
+		argv[++args] = crypt_path;
+	}
+
+	/*
+	 * fsmode manage means the fs should be remounted after
+	 * resizing if it was unmounted.
+	 */
+	if (fsi->needs_unmount && !strcmp(fsmode, "manage"))
+		argv[++args] = "--remount";
+
+	argv[++args] = NULL;
+
+	devpath = fsi->needs_crypt ? crypt_path : (char *)display_lvname(lv);
+
+	log_print("Extending file system %s to %s (%llu bytes) on %s...",
+		  fsi->fstype, display_size(cmd, newsize_bytes_fs/512),
+		  (unsigned long long)newsize_bytes_fs, devpath);
+
+	if (!exec_cmd(cmd, argv, &status, 1)) {
+		log_error("Failed to extend file system with lvresize_fs_helper.");
+		return 0;
+	}
+
+	log_print("Extended file system %s on %s.", fsi->fstype, devpath);
+
+	return 1;
+}
+
diff --git a/lib/device/filesystem.h b/lib/device/filesystem.h
new file mode 100644
index 000000000..7a34d2ae0
--- /dev/null
+++ b/lib/device/filesystem.h
@@ -0,0 +1,50 @@
+/*
+ * Copyright (C) 2022 Red Hat, Inc. All rights reserved.
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
+#ifndef _FILESYSTEM_H
+#define _FILESYSTEM_H
+
+#define FSTYPE_MAX 16
+
+struct fs_info {
+	char fstype[FSTYPE_MAX];
+	char mount_dir[PATH_MAX];
+	char fs_dev_path[PATH_MAX]; /* usually lv dev, can be crypt dev */
+	unsigned int fs_block_size_bytes; /* 512 or 4k */
+	uint64_t fs_last_byte; /* last byte on the device used by the fs */
+	uint32_t crypt_offset_bytes; /* offset in bytes of crypt data on LV */
+	dev_t crypt_devt; /* dm-crypt device between the LV and FS */
+
+	unsigned nofs:1;
+	unsigned unmounted:1;
+	unsigned mounted:1;
+	/* for resizing */
+	unsigned needs_reduce:1;
+	unsigned needs_extend:1;
+	unsigned needs_fsck:1;
+	unsigned needs_unmount:1;
+	unsigned needs_mount:1;
+	unsigned needs_crypt:1;
+};
+
+int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
+                struct fs_info *fsi, int include_mount);
+
+int fs_extend_script(struct cmd_context *cmd, struct logical_volume *lv, struct fs_info *fsi,
+		uint64_t newsize_bytes, char *fsmode);
+int fs_reduce_script(struct cmd_context *cmd, struct logical_volume *lv, struct fs_info *fsi,
+		uint64_t newsize_bytes, char *fsmode);
+int crypt_resize_script(struct cmd_context *cmd, struct logical_volume *lv, struct fs_info *fsi,
+		uint64_t newsize_bytes_fs);
+#endif
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e819db8d5..71aee7fb7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -31,6 +31,7 @@
 #include "lib/locking/lvmlockd.h"
 #include "lib/label/label.h"
 #include "lib/misc/lvm-signal.h"
+#include "lib/device/filesystem.h"
 
 #ifdef HAVE_BLKZEROOUT
 #include <sys/ioctl.h>
@@ -4946,13 +4947,6 @@ static int _lv_reduce_confirmation(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lv_is_vdo(lv) && !info.exists) {
-		log_error("Logical volume %s must be activated "
-			  "before reducing device size.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	if (!info.exists)
 		return 1;
 
@@ -5565,10 +5559,8 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 			if (!(seg_size = lp->extents - existing_logical_extents))
 				return 1;  /* No change in metadata size */
 		}
-	} else {  /* If reducing, find stripes, stripesize & size of last segment */
-		if (lp->stripes || lp->stripe_size || lp->mirrors)
-			log_print_unless_silent("Ignoring stripes, stripesize and mirrors "
-						"arguments when reducing.");
+	} else { 
+		/* If reducing, find stripes, stripesize & size of last segment */
 
 		if (lp->sign == SIGN_MINUS)  {
 			if (lp->extents >= existing_extents) {
@@ -5933,7 +5925,7 @@ static void _setup_params_for_extend_metadata(struct logical_volume *lv,
 	lp->percent = PERCENT_NONE;
 	lp->segtype = mseg->segtype;
 	lp->mirrors = seg_is_mirrored(mseg) ? lv_mirror_count(lv) : 0;
-	lp->resizefs = 0;
+	lp->fsopt[0] = '\0';
 	lp->stripes = lp->mirrors ? mseg->area_count / lp->mirrors : 0;
 	lp->stripe_size = mseg->stripe_size;
 }
@@ -5974,6 +5966,581 @@ static int _lv_resize_check_used(struct logical_volume *lv)
 	return 1;
 }
 
+/*
+ * --fs checksize: check fs size and allow the lv to reduce if the fs is not
+ * 		using the affected space, i.e. the fs does not need to be
+ *		resized.  fail the command without reducing the fs or lv if
+ *		the fs is using the affected space.
+ *
+ * --fs resize --fsmode manage: resize the fs, mounting/unmounting the fs
+ *  		as needed, but avoiding mounting/unmounted when possible.
+ *
+ * --fs resize --fsmode nochange: resize the fs without changing the current
+ *		mount/unmount state. fail the command without reducing the
+ *		fs or lv if the fs resize would require mounting or unmounting.
+ *
+ * --fs resize --fsmode offline: resize the fs only while it's unmounted
+ *		unmounting the fs if needed.  fail the commandn without
+ *		reducing the fs or lv if the fs resize would require having
+ *		the fs mounted.
+ *
+ * --fs resize_fsadm: old method using fsadm script to do everything
+ */
+static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
+			    struct lvresize_params *lp, uint64_t newsize_bytes_lv,
+			    uint64_t newsize_bytes_fs, struct fs_info *fsi)
+{
+	const char *fs_reduce_cmd = "";
+	const char *cmp_desc = "";
+	int equal = 0, smaller = 0, larger = 0;
+	int is_ext_fstype = 0;
+	int confirm_mount_change = 0;
+
+	/*
+	 * Allow reducing the LV for other fs types if the fs is not using
+	 * space that's being reduced.
+	 */
+	if (!strcmp(fsi->fstype, "ext2") ||
+	    !strcmp(fsi->fstype, "ext3") ||
+	    !strcmp(fsi->fstype, "ext4") ||
+	    !strcmp(fsi->fstype, "xfs")) {
+		log_debug("Found fs %s last_byte %llu newsize_bytes_fs %llu",
+			  fsi->fstype,
+			  (unsigned long long)fsi->fs_last_byte,
+			  (unsigned long long)newsize_bytes_fs);
+		if (!strncmp(fsi->fstype, "ext", 3)) {
+			is_ext_fstype = 1;
+			fs_reduce_cmd = " resize2fs";
+		}
+	}
+
+	if (!fsi->mounted)
+		log_print("File system %s%s found on %s.",
+			  fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
+			  display_lvname(lv));
+	else
+		log_print("File system %s%s found on %s mounted at %s.",
+			  fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
+			  display_lvname(lv), fsi->mount_dir);
+
+	if (!fsi->fs_last_byte) {
+		log_error("File system size unknown: update libblkid for FSLASTBLOCK, or see --fs resize_fsadm.");
+		return 0;
+	}
+
+	if ((equal = (fsi->fs_last_byte == newsize_bytes_fs)))
+		cmp_desc = "equal to";
+	else if ((smaller = (fsi->fs_last_byte < newsize_bytes_fs)))
+		cmp_desc = "smaller than";
+	else if ((larger = (fsi->fs_last_byte > newsize_bytes_fs)))
+		cmp_desc = "larger than";
+
+	log_print("File system size (%s) is %s the requested size (%s).",
+		  display_size(cmd, fsi->fs_last_byte/512), cmp_desc,
+		  display_size(cmd, newsize_bytes_fs/512));
+
+	/*
+	 * FS reduce is not needed, it's not using the affected space.
+	 */
+	if (smaller || equal) {
+		log_print("File system reduce is not needed, skipping.");
+		fsi->needs_reduce = 0;
+		return 1;
+	}
+
+	/*
+	 * FS reduce is required, but checksize does not allow it.
+	 */
+	if (!strcmp(lp->fsopt, "checksize")) {
+		if (is_ext_fstype)
+			log_error("File system reduce is required (see resize2fs or --resizefs.)");
+		else
+			log_error("File system reduce is required and not supported (%s).", fsi->fstype);
+		return 0;
+	}
+
+	/*
+	 * FS reduce required, ext* supports it, xfs does not.
+	 */
+	if (is_ext_fstype) {
+		log_print("File system reduce is required using resize2fs.");
+	} else {
+		log_error("File system reduce is required and not supported (%s).", fsi->fstype);
+		return 0;
+	}
+
+	/*
+	 * Set fstype-specific requirements for running fs resize command.
+	 * ext2,3,4 require the fs to be unmounted to shrink with resize2fs,
+	 * and they require e2fsck to be run first, unless resize2fs -f is used.
+	 */
+	if (is_ext_fstype) {
+		/* it's traditional to run fsck before shrink */
+		if (!lp->nofsck)
+			fsi->needs_fsck = 1;
+
+		/* ext2,3,4 require fs to be unmounted to shrink */
+		if (fsi->mounted)
+			fsi->needs_unmount = 1;
+
+		fsi->needs_reduce = 1;
+	} else {
+		/*
+		 * Shouldn't reach here since no other fs types get this far.
+		 * A future fs supporting shrink may require the fs to be
+		 * mounted or unmounted to run the fs shrink command.
+		 * set fsi->needs_unmount or fs->needs_mount according to
+		 * the fs-specific shrink command's requirement.
+		 */
+		log_error("File system %s: fs reduce not implemented.", fsi->fstype);
+		return 0;
+	}
+
+	/*
+	 * FS reduce may require mounting or unmounting, check the fsopt value
+	 * from the user, and the current mount state to decide if fs resize
+	 * can be done.
+	 */
+	if (!strcmp(lp->fsopt, "resize") && !strcmp(lp->fsmode, "nochange")) {
+		/* can't mount|unmount to run fs resize */
+		if (fsi->needs_mount) {
+			log_error("File system needs to be mounted to reduce fs (see --fsmode).");
+			return 0;
+		}
+		if (fsi->needs_unmount) {
+			log_error("File system needs to be unmounted to reduce fs (see --fsmode).");
+			return 0;
+		}
+	} else if (!strcmp(lp->fsopt, "resize") && !strcmp(lp->fsmode, "offline")) {
+		/* we can unmount if needed to run fs resize */
+		if (fsi->needs_mount) {
+			log_error("File system needs to be mounted to reduce fs (see --fsmode).");
+			return 0;
+		}
+	} else if (!strcmp(lp->fsopt, "resize") && !strcmp(lp->fsmode, "manage")) {
+		/* we can mount|unmount as needed to run fs resize */
+		/* confirm mount change unless --fsmode manage is set explicitly */
+
+		if (fsi->needs_mount || fsi->needs_unmount)
+			confirm_mount_change = 1;
+
+		if (lp->user_set_fsmode)
+			confirm_mount_change = 0;
+	} else {
+		log_error("Unknown file system resize options: --fs %s --fsmode %s", lp->fsopt, lp->fsmode);
+		return 0;
+	}
+
+	/*
+	 * If future file systems can be reduced while mounted, then suppress
+	 * needs_fsck here if the fs is already mounted.
+	 */
+
+	if (fsi->needs_unmount)
+		log_print("File system unmount is needed for reduce.");
+	if (fsi->needs_fsck)
+		log_print("File system fsck will be run before reduce.");
+	if (fsi->needs_mount)
+		log_print("File system mount is needed for reduce.");
+	if (fsi->needs_crypt)
+		log_print("cryptsetup resize is needed for reduce.");
+
+	/*
+	 * Use a confirmation prompt because mount|unmount is needed, and
+	 * no specific --fsmode was set (i.e. the user did not give specific
+	 * direction about how to handle mounting|unmounting with --fsmode.)
+	 */
+	if (!lp->yes && confirm_mount_change) {
+		if (yes_no_prompt("Continue with %s file system reduce steps:%s%s%s%s%s? [y/n]:",
+				  fsi->fstype,
+				  fsi->needs_unmount ? " unmount," : "",
+				  fsi->needs_fsck ? " fsck," : "",
+				  fsi->needs_mount ? " mount," : "",
+				  fsi->needs_crypt ? " cryptsetup," : "",
+				  fsi->needs_reduce ? fs_reduce_cmd : "") == 'n') {
+			log_error("File system not reduced.");
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+static int _fs_extend_allow(struct cmd_context *cmd, struct logical_volume *lv,
+			    struct lvresize_params *lp, struct fs_info *fsi)
+{
+	const char *fs_extend_cmd = "";
+	int is_ext_fstype = 0;
+	int confirm_mount_change = 0;
+
+	if (!strcmp(fsi->fstype, "ext2") ||
+	    !strcmp(fsi->fstype, "ext3") ||
+	    !strcmp(fsi->fstype, "ext4") ||
+	    !strcmp(fsi->fstype, "xfs")) {
+		log_debug("Found fs %s last_byte %llu",
+			  fsi->fstype, (unsigned long long)fsi->fs_last_byte);
+		if (!strncmp(fsi->fstype, "ext", 3))
+			is_ext_fstype = 1;
+	} else {
+		log_error("File system extend is not supported (%s).", fsi->fstype);
+		return 0;
+	}
+
+	if (!fsi->mounted)
+		log_print("File system %s%s found on %s.",
+			  fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
+			  display_lvname(lv));
+	else
+		log_print("File system %s%s found on %s mounted at %s.",
+			  fsi->fstype, fsi->needs_crypt ? "+crypto_LUKS" : "",
+			  display_lvname(lv), fsi->mount_dir);
+
+	/*
+	 * FS extend may require mounting or unmounting, check the fsopt value
+	 * from the user, and the current mount state to decide if fs extend
+	 * can be done.
+	 */
+
+	if (is_ext_fstype) {
+		fs_extend_cmd = " resize2fs";
+
+		/*
+		 * ext* can be extended while it's mounted or unmounted.  If
+		 * the fs is unmounted, it's traditional to run fsck before
+		 * running the fs extend.
+		 *
+		 * --fs resize --fsmode nochange: don't change mount condition.
+		 * if mounted: fs_extend
+		 * if unmounted: fsck, fs_extend
+		 *
+		 * --fs resize --fsmode offline: extend offline, so unmount first if mounted.
+		 * if mounted: unmount, fsck, fs_extend
+		 * if unmounted: fsck, fs_extend
+		 *
+		 * --fs resize --fsmode manage: do any mount or unmount that's necessary,
+		 * avoiding unnecessary mounting/unmounting.
+		 * if mounted: fs_extend
+		 * if unmounted: fsck, fs_extend
+		 */
+		if (!strcmp(lp->fsopt, "resize") && !strcmp(lp->fsmode, "nochange")) {
+			if (fsi->mounted)
+				fsi->needs_extend = 1;
+			else if (fsi->unmounted) {
+				fsi->needs_fsck = 1;
+				fsi->needs_extend = 1;
+			}
+		} else if (!strcmp(lp->fsopt, "resize") && !strcmp(lp->fsmode, "offline")) {
+			if (fsi->mounted) {
+				fsi->needs_unmount = 1;
+				fsi->needs_fsck = 1;
+				fsi->needs_extend = 1;
+			} else if (fsi->unmounted) {
+				fsi->needs_fsck = 1;
+				fsi->needs_extend = 1;
+			}
+		} else if (!strcmp(lp->fsopt, "resize") && !strcmp(lp->fsmode, "manage")) {
+			if (fsi->mounted)
+				fsi->needs_extend = 1;
+			else if (fsi->unmounted) {
+				fsi->needs_fsck = 1;
+				fsi->needs_extend = 1;
+			}
+		}
+
+		if (lp->nofsck)
+			fsi->needs_fsck = 0;
+
+	} else if (!strcmp(fsi->fstype, "xfs")) {
+		fs_extend_cmd = " xfs_growfs";
+
+		/*
+		 * xfs must be mounted to extend.
+		 *
+		 * --fs resize --fsmode nochange: don't change mount condition.
+		 * if mounted: fs_extend
+		 * if unmounted: fail
+		 *
+		 * --fs resize --fsmode offline: extend offline, so unmount first if mounted.
+		 * if mounted: fail
+		 * if unmounted: fail
+		 *
+		 * --fs resize --fsmode manage: do any mount or unmount that's necessary,
+		 * avoiding unnecessary mounting/unmounting.
+		 * if mounted: fs_extend
+		 * if unmounted: mount, fs_extend
+		 */
+		if (!strcmp(lp->fsopt, "resize") && !strcmp(lp->fsmode, "nochange")) {
+			if (fsi->mounted)
+				fsi->needs_extend = 1;
+			else if (fsi->unmounted) {
+				log_error("File system must be mounted to extend (see --fsmode).");
+				return 0;
+			}
+		} else if (!strcmp(lp->fsopt, "resize") && !strcmp(lp->fsmode, "offline")) {
+			log_error("File system must be mounted to extend (see --fsmode).");
+			return 0;
+		} else if (!strcmp(lp->fsopt, "resize") && !strcmp(lp->fsmode, "manage")) {
+			if (fsi->mounted)
+				fsi->needs_extend = 1;
+			else if (fsi->unmounted) {
+				fsi->needs_mount = 1;
+				fsi->needs_extend = 1;
+			}
+		}
+
+	} else {
+		/* shouldn't reach here */
+		log_error("File system type %s not handled.", fsi->fstype);
+		return 0;
+	}
+
+	/*
+	 * Skip needs_fsck if the fs is mounted and we can extend the fs while
+	 * it's mounted.
+	 */
+	if (fsi->mounted && !fsi->needs_unmount && fsi->needs_fsck) {
+		log_print("File system fsck skipped for extending mounted fs.");
+		fsi->needs_fsck = 0;
+	}
+
+	if (fsi->needs_unmount)
+		log_print("File system unmount is needed for extend.");
+	if (fsi->needs_fsck)
+		log_print("File system fsck will be run before extend.");
+	if (fsi->needs_mount)
+		log_print("File system mount is needed for extend.");
+	if (fsi->needs_crypt)
+		log_print("cryptsetup resize is needed for extend.");
+
+	/*
+	 * Use a confirmation prompt when mount|unmount is needed if
+	 * the user did not give specific direction about how to handle
+	 * mounting|unmounting with --fsmode.
+	 */
+	if (!strcmp(lp->fsopt, "resize") && !lp->user_set_fsmode &&
+	    (fsi->needs_mount || fsi->needs_unmount))
+		confirm_mount_change = 1;
+
+	if (!lp->yes && confirm_mount_change) {
+		if (yes_no_prompt("Continue with %s file system extend steps:%s%s%s%s%s? [y/n]:",
+				  fsi->fstype,
+				  fsi->needs_unmount ? " unmount," : "",
+				  fsi->needs_fsck ? " fsck," : "",
+				  fsi->needs_mount ? " mount," : "",
+				  fsi->needs_crypt ? " cryptsetup," : "",
+				  fsi->needs_extend ? fs_extend_cmd : "") == 'n') {
+			log_error("File system not extended.");
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+static int _fs_reduce(struct cmd_context *cmd, struct logical_volume *lv,
+		      struct lvresize_params *lp)
+{
+	struct fs_info fsinfo;
+	struct fs_info fsinfo2;
+	uint64_t newsize_bytes_lv;
+	uint64_t newsize_bytes_fs;
+	int ret = 0;
+
+	memset(&fsinfo, 0, sizeof(fsinfo));
+	memset(&fsinfo2, 0, sizeof(fsinfo));
+
+	if (!fs_get_info(cmd, lv, &fsinfo, 1))
+		goto_out;
+
+	if (fsinfo.nofs) {
+		ret = 1;
+		goto_out;
+	}
+
+	/* extent_size units is SECTOR_SIZE (512) */
+	newsize_bytes_lv = lp->extents * lv->vg->extent_size * SECTOR_SIZE;
+	newsize_bytes_fs = newsize_bytes_lv;
+
+	/*
+	 * If needs_crypt, then newsize_bytes passed to fs_reduce_script() and
+	 * crypt_resize_script() needs to be decreased by the offset of crypt
+	 * data on the LV (usually the size of the LUKS header which is usually
+	 * 2MB for LUKS1 and 16MB for LUKS2.)
+	 */
+	if (fsinfo.needs_crypt) {
+		newsize_bytes_fs -= fsinfo.crypt_offset_bytes;
+		log_print("File system size %llub is adjusted for crypt data offset %ub.",
+			  (unsigned long long)newsize_bytes_fs, fsinfo.crypt_offset_bytes);
+	}
+
+	/*
+	 * Based on the --fs command option, the fs type, the last block used,
+	 * and the mount state, determine if LV reduce is allowed.  If not
+	 * returns 0 and lvreduce should fail.  If allowed, returns 1 and sets
+	 * fsinfo.needs_* for any steps that are required to reduce the LV.
+	 */
+	if (!_fs_reduce_allow(cmd, lv, lp, newsize_bytes_lv, newsize_bytes_fs, &fsinfo))
+		goto_out;
+
+	/*
+	 * Uncommon special case in which the FS does not need to be shrunk,
+	 * but the crypt dev over the LV should be shrunk to correspond with
+	 * the LV size, so that the FS does not see an incorrect device size.
+	 */
+	if (!fsinfo.needs_reduce && fsinfo.needs_crypt && !test_mode()) {
+		ret = crypt_resize_script(cmd, lv, &fsinfo, newsize_bytes_fs);
+		goto out;
+	}
+
+	/*
+	 * fs reduce is not needed to reduce the LV.
+	 */
+	if (!fsinfo.needs_reduce) {
+		ret = 1;
+		goto_out;
+	}
+
+	if (test_mode()) {
+		if (fsinfo.needs_unmount)
+			log_print("Skip unmount in test mode.");
+		if (fsinfo.needs_fsck)
+			log_print("Skip fsck in test mode.");
+		if (fsinfo.needs_mount)
+			log_print("Skip mount in test mode.");
+		if (fsinfo.needs_crypt)
+			log_print("Skip cryptsetup in test mode.");
+		log_print("Skip fs reduce in test mode.");
+		ret = 1;
+		goto out;
+	}
+
+	/*
+	 * mounting, unmounting, fsck, and shrink command can all take a long
+	 * time to run, and this lvm command should not block other lvm
+	 * commands from running during that time, so release the vg lock
+	 * around the long-running steps, and reacquire after.
+	 */
+	unlock_vg(cmd, lv->vg, lv->vg->name);
+
+	if (!fs_reduce_script(cmd, lv, &fsinfo, newsize_bytes_fs, lp->fsmode))
+		goto_out;
+
+	if (!lock_vol(cmd, lv->vg->name, LCK_VG_WRITE, NULL)) {
+		log_error("Failed to lock VG, cannot reduce LV.");
+		ret = 0;
+		goto out;
+	}
+
+	/*
+	 * Check that the vg wasn't changed while it was unlocked.
+	 * (can_use_one_scan: check just one mda in the vg for changes)
+	 */
+	cmd->can_use_one_scan = 1;
+	if (scan_text_mismatch(cmd, lv->vg->name, NULL)) {
+		log_print("VG was changed during fs operations, restarting.");
+		lp->vg_changed_error = 1;
+		ret = 0;
+		goto out;
+	}
+
+	/*
+	 * Re-check the fs last block which should now be less than the
+	 * requested (reduced) LV size.
+	 */
+	if (!fs_get_info(cmd, lv, &fsinfo2, 0))
+		goto_out;
+
+	if (fsinfo.fs_last_byte && (fsinfo2.fs_last_byte > newsize_bytes_fs)) {
+		log_error("File system last byte %llu is greater than new size %llu bytes.",
+			  (unsigned long long)fsinfo2.fs_last_byte,
+			  (unsigned long long)newsize_bytes_fs);
+		goto_out;
+	}
+
+	ret = 1;
+ out:
+	return ret;
+}
+
+static int _fs_extend(struct cmd_context *cmd, struct logical_volume *lv,
+		      struct lvresize_params *lp)
+{
+	struct fs_info fsinfo;
+	uint64_t newsize_bytes_lv;
+	uint64_t newsize_bytes_fs;
+	int ret = 0;
+
+	memset(&fsinfo, 0, sizeof(fsinfo));
+
+	if (!fs_get_info(cmd, lv, &fsinfo, 1))
+		goto_out;
+
+	if (fsinfo.nofs) {
+		ret = 1;
+		goto_out;
+	}
+
+	/*
+	 * Note: here in the case of extend, newsize_bytes_lv/newsize_bytes_fs 
+	 * are only calculated and used for log messages.  The extend commands
+	 * do not use these values, they just extend to the new LV size that
+	 * is visible to them.
+	 */
+
+	/* extent_size units is SECTOR_SIZE (512) */
+	newsize_bytes_lv = lp->extents * lv->vg->extent_size * SECTOR_SIZE;
+	newsize_bytes_fs = newsize_bytes_lv;
+	if (fsinfo.needs_crypt) {
+		newsize_bytes_fs -= fsinfo.crypt_offset_bytes;
+		log_print("File system size %llub is adjusted for crypt data offset %ub.",
+			  (unsigned long long)newsize_bytes_fs, fsinfo.crypt_offset_bytes);
+	}
+
+	/*
+	 * Decide if fs should be extended based on the --fs option,
+	 * the fs type and the mount state.
+	 */
+	if (!_fs_extend_allow(cmd, lv, lp, &fsinfo))
+		goto_out;
+
+	/*
+	 * fs extend is not needed
+	 */
+	if (!fsinfo.needs_extend) {
+		ret = 1;
+		goto_out;
+	}
+
+	if (test_mode()) {
+		if (fsinfo.needs_unmount)
+			log_print("Skip unmount in test mode.");
+		if (fsinfo.needs_fsck)
+			log_print("Skip fsck in test mode.");
+		if (fsinfo.needs_mount)
+			log_print("Skip mount in test mode.");
+		if (fsinfo.needs_crypt)
+			log_print("Skip cryptsetup in test mode.");
+		log_print("Skip fs extend in test mode.");
+		ret = 1;
+		goto out;
+	}
+
+	/*
+	 * mounting, unmounting and extend command can all take a long
+	 * time to run, and this lvm command should not block other lvm
+	 * commands from running during that time, so release the vg
+	 * lock around the long-running steps.
+	 */
+	unlock_vg(cmd, lv->vg, lv->vg->name);
+
+	if (!fs_extend_script(cmd, lv, &fsinfo, newsize_bytes_fs, lp->fsmode))
+		goto_out;
+
+	ret = 1;
+ out:
+	return ret;
+}
+
 int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	      struct lvresize_params *lp)
 {
@@ -5989,7 +6556,9 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	int meta_size_matches = 0;
 	int is_extend = (lp->resize == LV_EXTEND);
 	int is_reduce = (lp->resize == LV_REDUCE);
+	int is_active = 0;
 	int activated = 0;
+	int activated_checksize = 0;
 	int status;
 	int ret = 0;
 
@@ -6018,26 +6587,6 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	/*
-	 * resizefs applies to the LV command arg, not to the top LV or lower
-	 * resizable LV.
-	 */
-	if (lp->resizefs) {
-		if (!lv_is_active(lv)) {
-			log_error("Logical volume %s must be activated before resizing filesystem.",
-       				  display_lvname(lv));
-			return 0;
-		}
-		/* types of LVs that can hold a file system */
-		if (!(lv_is_linear(lv) || lv_is_striped(lv) || lv_is_raid(lv) ||
-		      lv_is_mirror(lv) || lv_is_thin_volume(lv) || lv_is_vdo(lv) ||
-		      lv_is_cache(lv) || lv_is_writecache(lv))) {
-			log_print_unless_silent("Ignoring --resizefs for LV type %s.",
-						seg ? seg->segtype->name : "unknown");
-			lp->resizefs = 0;
-		}
-	}
-
 	/*
 	 * Figure out which LVs are going to be extended, and set params
 	 * to the requested extents/size for each.  Some LVs are extended
@@ -6197,10 +6746,6 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 
 		if (!_lv_resize_check_type(lv_main, lp))
 			return_0;
-
-		if (is_reduce && !main_size_matches && !lp->resizefs &&
-		    !_lv_reduce_confirmation(lv, lp))
-			return_0;
 	}
 
 	/*
@@ -6265,20 +6810,93 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	 * So active temporarily pool LV (with on disk metadata) then use
 	 * suspend and resume and deactivate pool LV, instead of searching for
 	 * an active thin volume.
+	 *
+	 * FIXME: why are thin pools activated where other LV types return
+	 * error if inactive?
 	 */
 	if (lv_is_thin_pool(lv_top) && !lv_is_active(lv_top)) {
-		if (!activation()) {
-			log_error("Cannot resize %s without using device-mapper kernel driver.",
-       				  display_lvname(lv_top));
-			return_0;
+	       	if (!activation()) {
+			log_error("Cannot activate to resize %s without using device-mapper kernel driver.",
+				  display_lvname(lv_top));
+			return 0;
 		}
 		if (!activate_lv(cmd, lv_top)) {
 			log_error("Failed to activate %s.", display_lvname(lv_top));
-			return_0;
+			return 0;
 		}
+		if (!sync_local_dev_names(cmd))
+			stack;
 		activated = 1;
 	}
 
+	/*
+	 * Disable fsopt checksize for lvextend.
+	 */
+	if (is_extend && !strcmp(lp->fsopt, "checksize"))
+		lp->fsopt[0] = '\0';
+
+	/*
+	 * Disable fsopt if LV type cannot hold a file system.
+	 */
+	if (lp->fsopt[0] &&
+	    !(lv_is_linear(lv) || lv_is_striped(lv) || lv_is_raid(lv) ||
+	      lv_is_mirror(lv) || lv_is_thin_volume(lv) || lv_is_vdo(lv) ||
+	      lv_is_cache(lv) || lv_is_writecache(lv))) {
+		log_print_unless_silent("Ignoring fs resizing options for LV type %s.",
+					seg ? seg->segtype->name : "unknown");
+		lp->fsopt[0] = '\0';
+	}
+
+	/*
+	 * Using an option to resize the fs has always/traditionally required
+	 * the LV to already be active, so keep that behavior.  Reducing an
+	 * inactive LV will activate the LV to look for a fs that would be
+	 * damaged.
+	 */
+	is_active = lv_is_active(lv_top);
+
+	if (is_reduce && !is_active && !strcmp(lp->fsopt, "checksize")) {
+		if (!activate_lv(cmd, lv_top)) {
+			log_error("Failed to activate %s to check for fs.", display_lvname(lv_top));
+			goto out;
+		}
+		if (!sync_local_dev_names(cmd))
+			stack;
+		activated_checksize = 1;
+
+	} else if (lp->fsopt[0] && !is_active) {
+		log_error("Logical volume %s must be active for file system %s.",
+			  display_lvname(lv_top), lp->fsopt);
+		goto out;
+	}
+
+	/*
+	 * Return an error without resizing the LV if the user requested
+	 * a file system resize when no file system exists on the LV.
+	 * (fs checksize does not require a fs to exist.)
+	 */
+	if (lp->fsopt[0] && strcmp(lp->fsopt, "checksize") && lp->user_set_fs) {
+		char lv_path[PATH_MAX];
+		char fstype[FSTYPE_MAX];
+		int nofs = 0;
+
+		if (dm_snprintf(lv_path, sizeof(lv_path), "%s%s/%s", cmd->dev_dir,
+				lv_top->vg->name, lv_top->name) < 0) {
+			log_error("Couldn't create LV path for %s.", display_lvname(lv_top));
+			goto out;
+		}
+		if (!fs_block_size_and_type(lv_path, NULL, fstype, &nofs) || nofs) {
+			log_error("File system not found for --resizefs or --fs options.");
+			goto out;
+		}
+	}
+
+	/*
+	 * Warn and confirm if checksize has been disabled for reduce.
+	 */
+	if (is_reduce && !lp->fsopt[0] && !_lv_reduce_confirmation(lv_top, lp))
+		goto_out;
+
 	/*
 	 * If the LV is locked due to being active, this lock call is a no-op.
 	 * Otherwise, this acquires a transient lock on the lv (not PERSISTENT)
@@ -6286,25 +6904,30 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lockd_lv_resize(cmd, lv_top, "ex", 0, lp))
 		goto_out;
 
-	/*
-	 * Check the file system, and shrink the fs before reducing lv.
-	 * TODO: libblkid fs type, fs last_block, mount state,
-	 *       unlock vg, mount|unmount if needed, fork fs shrink,
-	 *       lock vg, rescan devs, recheck fs type last_block.
-	 *       (at end mount|unmount if needed to restore initial state.)
-	 */
-	if (lp->resizefs && !lp->nofsck &&
+	/* Part of old approach to fs handling using fsadm.  */
+	if (!strcmp(lp->fsopt, "resize_fsadm") && !lp->nofsck &&
 	    !_fsadm_cmd(FSADM_CMD_CHECK, lv_top, 0, lp->yes, lp->force, &status)) {
 		if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
 			log_error("Filesystem check failed.");
 			goto out;
 		}
-		/* some filesystems support online resize */
 	}
-	if (lp->resizefs && is_reduce &&
-	    !_fsadm_cmd(FSADM_CMD_RESIZE, lv_top, lp->extents, lp->yes, lp->force, NULL)) {
-		log_error("Filesystem resize failed.");
-		goto out;
+
+	if (is_reduce && lp->fsopt[0]) {
+		if (!strcmp(lp->fsopt, "resize_fsadm")) {
+			/* Old approach to fs handling using fsadm. */
+			if (!_fsadm_cmd(FSADM_CMD_RESIZE, lv_top, lp->extents, lp->yes, lp->force, NULL)) {
+				log_error("Filesystem resize failed.");
+				goto out;
+			}
+		} else {
+			/* New approach to fs handling using fs info. */
+			if (!_fs_reduce(cmd, lv_top, lp))
+				goto_out;
+		}
+
+		if (activated_checksize && !deactivate_lv(cmd, lv_top))
+			log_warn("Problem deactivating %s.", display_lvname(lv_top));
 	}
 
 	/*
@@ -6319,9 +6942,9 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	 * Remove any striped raid reshape space for LV resizing (not common).
 	 */
 	if (lv_meta && first_seg(lv_meta)->reshape_len && !lv_raid_free_reshape_space(lv_meta))
-		return_0;
+		goto_out;
 	if (lv_main && first_seg(lv_main)->reshape_len && !lv_raid_free_reshape_space(lv_main))
-		return_0;
+		goto_out;
 
 	/*
 	 * The core of the actual lv resizing.
@@ -6376,22 +6999,28 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 			stack;
 	}
 
-	/*
-	 * Extend the file system.
-	 * TODO: libblkid fs type, mount state,
-	 *       unlock vg, mount|unmount if needed, fork fs grow,
-	 *       mount|unmount if needed to restore initial state.
-	 */
-	if (lp->resizefs && is_extend &&
-	    !_fsadm_cmd(FSADM_CMD_RESIZE, lv_top, lp->extents, lp->yes, lp->force, NULL)) {
-		log_warn("Filesystem resize failed.");
-		goto out;
+	if (is_extend && lp->fsopt[0]) {
+		if (!strcmp(lp->fsopt, "resize_fsadm")) {
+			/* Old approach to fs handling using fsadm. */
+			if (!_fsadm_cmd(FSADM_CMD_RESIZE, lv_top, lp->extents, lp->yes, lp->force, NULL)) {
+				log_error("File system extend error.");
+				lp->extend_fs_error = 1;
+				goto out;
+			}
+		} else {
+			/* New approach to fs handling using fs info. */
+			if (!_fs_extend(cmd, lv_top, lp)) {
+				log_error("File system extend error.");
+				lp->extend_fs_error = 1;
+				goto out;
+			}
+		}
 	}
 
 	ret = 1;
 
  out:
-	if (activated) {
+	if (activated || activated_checksize) {
 		if (!sync_local_dev_names(cmd))
 			stack;
 		if (!deactivate_lv(cmd, lv_top))
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 048b7553f..04f32cace 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -674,8 +674,11 @@ struct lvresize_params {
 	int force;
 	int nosync;
 	int nofsck;
-	int resizefs;
 	int use_policies;
+	int user_set_fs;
+	int user_set_fsmode;
+	char fsopt[16]; /* set by --resizefs|--fs, empty for --fs ignore */
+	char fsmode[16]; /* set by --fsmode */
 
 	const struct segment_type *segtype;
 	unsigned mirrors;
@@ -695,6 +698,8 @@ struct lvresize_params {
 	int approx_alloc;
 	int extents_are_pes;	/* Is 'extents' counting PEs or LEs? */
 	int size_changed;	/* Was there actually a size change */
+	int extend_fs_error;    /* FS extend error after LV extend success */
+	int vg_changed_error;   /* VG metadata was modified during fs resize */
 
 	const char *lockopt;
 	char *lockd_lv_refresh_path; /* set during resize to use for refresh at the end */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 95f25eef8..30b2c1779 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4533,7 +4533,7 @@ void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
  * reread metadata.
  */
 
-static bool _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
+bool scan_text_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
 {
 	DM_LIST_INIT(mda_list);
 	struct mda_list *mdal, *safe;
@@ -4706,7 +4706,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * probably unnecessary; all commands could likely just check a single mda.
 	 */
 
-	if (lvmcache_scan_mismatch(cmd, vgname, vgid) || _scan_text_mismatch(cmd, vgname, vgid)) {
+	if (lvmcache_scan_mismatch(cmd, vgname, vgid) || scan_text_mismatch(cmd, vgname, vgid)) {
 		log_debug_metadata("Rescanning devices for %s %s", vgname, writing ? "rw" : "");
 		if (writing)
 			lvmcache_label_rescan_vg_rw(cmd, vgname, vgid);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 7f3cf9d29..95fd359c7 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -541,5 +541,7 @@ void set_pv_devices(struct format_instance *fid, struct volume_group *vg);
 int get_visible_lvs_using_pv(struct cmd_context *cmd, struct volume_group *vg, struct device *dev,
                             struct dm_list *lvs_list);
 
+bool scan_text_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
+
 
 #endif
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index ebcea92f9..9fcff37b0 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -56,7 +56,11 @@ install_device-mapper: $(DM_SCRIPTS:.sh=_install)
 
 install_ocf: $(OCF_SCRIPTS:.ocf=_install)
 
-install: install_lvm2 install_ocf install_device-mapper
+install_libexec:
+	$(Q) $(INSTALL_SCRIPT) lvresize_fs_helper.sh $(libexecdir)/lvresize_fs_helper
+
+install: install_lvm2 install_ocf install_device-mapper install_libexec
+
 
 # FIXME Customise for other distributions
 install_initscripts:
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 9ae422f55..d22c7d0a6 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -164,7 +164,7 @@ cleanup() {
 		export _FSADM_YES _FSADM_EXTOFF
 		unset FSADM_RUNNING
 		test -n "${LVM_BINARY-}" && PATH=$_SAVEPATH
-		dry exec "$LVM" lvresize $VERB $FORCE -r -L"${NEWSIZE_ORIG}b" "$VOLUME_ORIG"
+		dry exec "$LVM" lvresize $VERB $FORCE $YES --fs resize_fsadm -L"${NEWSIZE_ORIG}b" "$VOLUME_ORIG"
 	fi
 
 	# error exit status for break
diff --git a/scripts/lvresize_fs_helper.sh b/scripts/lvresize_fs_helper.sh
new file mode 100755
index 000000000..031b8453b
--- /dev/null
+++ b/scripts/lvresize_fs_helper.sh
@@ -0,0 +1,466 @@
+#!/bin/bash
+#
+# Copyright (C) 2022 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+errorexit() {
+	echo "$1" >&2
+	exit 1
+}
+
+logmsg() {
+	echo "$1"
+	logger "${SCRIPTNAME}: $1"
+}
+
+# Set to 1 while the fs is temporarily mounted on $TMPDIR
+TMP_MOUNT_DONE=0
+# Set to 1 if the fs resize command fails
+RESIZEFS_FAILED=0
+
+fsextend() {
+	if [ "$DO_UNMOUNT" -eq 1 ]; then
+		logmsg "unmount ${MOUNTDIR}"
+		umount "$MOUNTDIR"
+		if [ $? -eq 0 ]; then
+			logmsg "unmount done"
+		else
+			logmsg "unmount failed"
+			exit 1
+		fi
+	fi
+
+	if [ "$DO_FSCK" -eq 1 ]; then
+		logmsg "e2fsck ${DEVPATH}"
+		e2fsck -f -p "$DEVPATH"
+		if [ $? -eq 0 ]; then
+			logmsg "e2fsck done"
+		else
+			logmsg "e2fsck failed"
+			exit 1
+		fi
+	fi
+	
+	if [ "$DO_CRYPTRESIZE" -eq 1 ]; then
+		logmsg "cryptsetup resize ${DEVPATH}"
+		cryptsetup resize "$DEVPATH"
+		if [ $? -eq 0 ]; then
+			logmsg "cryptsetup done"
+		else
+			logmsg "cryptsetup failed"
+			exit 1
+		fi
+	fi
+
+	if [ "$DO_MOUNT" -eq 1 ]; then
+		logmsg "mount ${DEVPATH} ${TMPDIR}"
+		mount -t "$FSTYPE" "$DEVPATH" "$TMPDIR"
+		if [ $? -eq 0 ]; then
+			logmsg "mount done"
+			TMP_MOUNT_DONE=1
+		else
+			logmsg "mount failed"
+			exit 1
+		fi
+	fi
+
+	if [[ "$FSTYPE" == "ext"* ]]; then
+		logmsg "resize2fs ${DEVPATH}"
+		resize2fs "$DEVPATH"
+		if [ $? -eq 0 ]; then
+			logmsg "resize2fs done"
+		else
+			logmsg "resize2fs failed"
+			RESIZEFS_FAILED=1
+		fi
+	elif [[ "$FSTYPE" == "xfs" ]]; then
+		logmsg "xfs_growfs ${DEVPATH}"
+		xfs_growfs "$DEVPATH"
+		if [ $? -eq 0 ]; then
+			logmsg "xfs_growfs done"
+		else
+			logmsg "xfs_growfs failed"
+			RESIZEFS_FAILED=1
+		fi
+	fi
+
+	# If the fs was temporarily mounted, now unmount it.
+	if [ $TMP_MOUNT_DONE -eq 1 ]; then
+		logmsg "cleanup unmount ${TMPDIR}"
+		umount "$TMPDIR"
+		if [ $? -eq 0 ]; then
+			logmsg "cleanup unmount done"
+			TMP_MOUNT_DONE=0
+			rmdir "$TMPDIR"
+		else
+			logmsg "cleanup unmount failed"
+			exit 1
+		fi
+	fi
+
+	# If the fs was temporarily unmounted, now remount it.
+	# Not considered a command failure if this fails.
+	if [[ $DO_UNMOUNT -eq 1 && $REMOUNT -eq 1 ]]; then
+		logmsg "remount ${DEVPATH} ${MOUNTDIR}"
+		mount -t "$FSTYPE" "$DEVPATH" "$MOUNTDIR"
+		if [ $? -eq 0 ]; then
+			logmsg "remount done"
+		else
+			logmsg "remount failed"
+		fi
+	fi
+
+	if [ $RESIZEFS_FAILED -eq 1 ]; then
+		logmsg "File system extend failed."
+		exit 1
+	fi
+
+	exit 0
+}
+
+fsreduce() {
+	if [ "$DO_UNMOUNT" -eq 1 ]; then
+		logmsg "unmount ${MOUNTDIR}"
+		umount "$MOUNTDIR"
+		if [ $? -eq 0 ]; then
+			logmsg "unmount done"
+		else
+			logmsg "unmount failed"
+			exit 1
+		fi
+	fi
+
+	if [ "$DO_FSCK" -eq 1 ]; then
+		logmsg "e2fsck ${DEVPATH}"
+		e2fsck -f -p "$DEVPATH"
+		if [ $? -eq 0 ]; then
+			logmsg "e2fsck done"
+		else
+			logmsg "e2fsck failed"
+			exit 1
+		fi
+	fi
+	
+	if [ "$DO_MOUNT" -eq 1 ]; then
+		logmsg "mount ${DEVPATH} ${TMPDIR}"
+		mount -t "$FSTYPE" "$DEVPATH" "$TMPDIR"
+		if [ $? -eq 0 ]; then
+			logmsg "mount done"
+			TMP_MOUNT_DONE=1
+		else
+			logmsg "mount failed"
+			exit 1
+		fi
+	fi
+
+	if [[ "$FSTYPE" == "ext"* ]]; then
+		NEWSIZEKB=$(($NEWSIZEBYTES/1024))
+		logmsg "resize2fs ${DEVPATH} ${NEWSIZEKB}k"
+		resize2fs "$DEVPATH" "$NEWSIZEKB"k
+		if [ $? -eq 0 ]; then
+			logmsg "resize2fs done"
+		else
+			logmsg "resize2fs failed"
+			# will exit after cleanup unmount
+			RESIZEFS_FAILED=1
+		fi
+	fi
+
+	# If the fs was temporarily mounted, now unmount it.
+	if [ $TMP_MOUNT_DONE -eq 1 ]; then
+		logmsg "cleanup unmount ${TMPDIR}"
+		umount "$TMPDIR"
+		if [ $? -eq 0 ]; then
+			logmsg "cleanup unmount done"
+			TMP_MOUNT_DONE=0
+			rmdir "$TMPDIR"
+		else
+			logmsg "cleanup unmount failed"
+			exit 1
+		fi
+	fi
+
+	if [ $RESIZEFS_FAILED -eq 1 ]; then
+		logmsg "File system reduce failed."
+		exit 1
+	fi
+
+	if [ "$DO_CRYPTRESIZE" -eq 1 ]; then
+		NEWSIZESECTORS=$(($NEWSIZEBYTES/512))
+		logmsg "cryptsetup resize ${NEWSIZESECTORS} sectors ${DEVPATH}"
+		cryptsetup resize --size "$NEWSIZESECTORS" "$DEVPATH"
+		if [ $? -eq 0 ]; then
+			logmsg "cryptsetup done"
+		else
+			logmsg "cryptsetup failed"
+			exit 1
+		fi
+	fi
+
+	# If the fs was temporarily unmounted, now remount it.
+	# Not considered a command failure if this fails.
+	if [[ $DO_UNMOUNT -eq 1 && $REMOUNT -eq 1 ]]; then
+		logmsg "remount ${DEVPATH} ${MOUNTDIR}"
+		mount -t "$FSTYPE" "$DEVPATH" "$MOUNTDIR"
+		if [ $? -eq 0 ]; then
+			logmsg "remount done"
+		else
+			logmsg "remount failed"
+		fi
+	fi
+
+	exit 0
+}
+
+cryptresize() {
+	NEWSIZESECTORS=$(($NEWSIZEBYTES/512))
+	logmsg "cryptsetup resize ${NEWSIZESECTORS} sectors ${DEVPATH}"
+	cryptresize resize --size "$NEWSIZESECTORS" "$DEVPATH"
+	if [ $? -eq 0 ]; then
+		logmsg "cryptsetup done"
+	else
+		logmsg "cryptsetup failed"
+		exit 1
+	fi
+
+	exit 0
+}
+
+usage() {
+	echo "${SCRIPTNAME}: helper script called by lvresize to resize file systems."
+	echo ""
+	echo "${SCRIPTNAME} --fsextend --fstype name --lvpath path"
+	echo "    [ --mountdir path ]"
+	echo "    [ --mount ]"
+	echo "    [ --unmount ]"
+	echo "    [ --remount ]"
+	echo "    [ --fsck ]"
+	echo "    [ --cryptresize ]"
+	echo "    [ --cryptpath path ]"
+	echo ""
+	echo "${SCRIPTNAME} --fsreduce --fstype name --lvpath path"
+	echo "    [ --newsizebytes num ]"
+	echo "    [ --mountdir path ]"
+	echo "    [ --mount ]"
+	echo "    [ --unmount ]"
+	echo "    [ --remount ]"
+	echo "    [ --fsck ]"
+	echo "    [ --cryptresize ]"
+	echo "    [ --cryptpath path ]"
+	echo ""
+	echo "${SCRIPTNAME} --cryptresize --cryptpath path --newsizebytes num"
+	echo ""
+	echo "Options:"
+	echo "    --fsextend"
+	echo "        Extend the file system."
+	echo "    --fsreduce"
+	echo "        Reduce the file system."
+	echo "    --fstype name"
+	echo "        The type of file system (ext*, xfs)."
+	echo "    --lvpath path"
+	echo "        The path to the LV being resized."
+	echo "    --mountdir path"
+	echo "        The file system is currently mounted here."
+	echo "    --mount"
+	echo "        Mount the file system on a temporary directory before resizing."
+	echo "    --unmount"
+	echo "        Unmount the file system before resizing."
+	echo "    --remount"
+	echo "        Remount the file system after resizing if unmounted."
+	echo "    --fsck"
+	echo "        Run fsck on the file system before resizing (only with ext*)."
+	echo "    --newsizebytes num"
+	echo "        The new size of the file system."
+	echo "    --cryptresize"
+	echo "        Resize the crypt device between the LV and file system."
+	echo "    --cryptpath path"
+	echo "        The path to the crypt device."
+	echo ""
+}
+
+#
+# BEGIN SCRIPT
+#
+PATH="/sbin:/usr/sbin:/bin:/usr/sbin:$PATH"
+SCRIPTNAME=$(basename "$0")
+
+# These are the only commands that this script will run.
+# Each is enabled (1) by the corresponding command options:
+# --fsextend, --fsreduce, --cryptresize, --mount, --unmount, --fsck
+DO_FSEXTEND=0
+DO_FSREDUCE=0
+DO_CRYPTRESIZE=0
+DO_MOUNT=0
+DO_UNMOUNT=0
+DO_FSCK=0
+
+# --remount: attempt to remount the fs if it was originally
+# mounted and the script unmounted it.
+REMOUNT=0
+
+if [ "$UID" != 0 ] && [ "$EUID" != 0 ]; then
+	errorexit "${SCRIPTNAME} must be run as root."
+fi
+
+GETOPT="getopt"
+
+OPTIONS=$("$GETOPT" -o h -l help,fsextend,fsreduce,cryptresize,mount,unmount,remount,fsck,fstype:,lvpath:,newsizebytes:,mountdir:,cryptpath: -n "${SCRIPTNAME}" -- "$@")
+eval set -- "$OPTIONS"
+
+while true
+do
+	case $1 in
+	--fsextend)
+		DO_FSEXTEND=1
+		shift
+		;;
+	--fsreduce)
+		DO_FSREDUCE=1
+		shift
+		;;
+	--cryptresize)
+		DO_CRYPTRESIZE=1
+		shift
+		;;
+	--mount)
+		DO_MOUNT=1
+		shift
+		;;
+	--unmount)
+		DO_UNMOUNT=1
+		shift
+		;;
+	--fsck)
+		DO_FSCK=1
+		shift
+		;;
+	--remount)
+		REMOUNT=1
+		shift
+		;;
+	--fstype)
+		FSTYPE=$2;
+		shift; shift
+		;;
+	--lvpath)
+		LVPATH=$2;
+		shift; shift
+		;;
+	--newsizebytes)
+		NEWSIZEBYTES=$2;
+		shift; shift
+		;;
+	--mountdir)
+		MOUNTDIR=$2;
+		shift; shift
+		;;
+	--cryptpath)
+		CRYPTPATH=$2;
+		shift; shift
+		;;
+	-h|--help)
+		usage
+		shift
+		exit 0
+		;;
+	--)
+		shift
+		break
+		;;
+	*)
+		errorexit "Unknown option \"$1\."
+		exit 1
+		;;
+    esac
+done
+
+#
+# Input arg checking
+#
+
+# There are three top level commands: --fsextend, --fsreduce, --cryptresize.
+if [[ "$DO_FSEXTEND" -eq 0 && "$DO_FSREDUCE" -eq 0 && "$DO_CRYPTRESIZE" -eq 0 ]]; then
+	errorexit "Missing --fsextend|--fsreduce|--cryptresize."
+fi
+
+if [[ "$DO_FSEXTEND" -eq 1 || "$DO_FSREDUCE" -eq 1 ]]; then
+	case "$FSTYPE" in
+	  ext[234]) ;;
+	  "xfs")    ;;
+	  *) errorexit "Cannot resize --fstype \"$FSTYPE\"."
+	esac
+
+	if [ -z "$LVPATH" ]; then
+		errorexit "Missing required --lvpath."
+	fi
+fi
+
+if [[ "$DO_CRYPTRESIZE" -eq 1 && -z "$CRYPTPATH" ]]; then
+	errorexit "Missing required --cryptpath for --cryptresize."
+fi
+
+if [ "$DO_CRYPTRESIZE" -eq 1 ]; then
+	DEVPATH=$CRYPTPATH
+else
+	DEVPATH=$LVPATH
+fi
+
+if [ -z "$DEVPATH" ]; then
+	errorexit "Missing path to device."
+fi
+
+if [ ! -e "$DEVPATH" ]; then
+	errorexit "Device does not exist \"$DEVPATH\"."
+fi
+
+if [[ "$DO_UNMOUNT" -eq 1 && -z "$MOUNTDIR" ]]; then
+	errorexit "Missing required --mountdir for --unmount."
+fi
+
+if [[ "$DO_FSREDUCE" -eq 1 && "$FSTYPE" == "xfs" ]]; then
+	errorexit "Cannot reduce xfs."
+fi
+
+if [[ "$DO_FSCK" -eq 1 && "$FSTYPE" == "xfs" ]]; then
+	errorexit "Cannot use --fsck with xfs."
+fi
+
+if [ "$DO_MOUNT" -eq 1 ]; then
+	TMPDIR=$(mktemp --suffix _lvresize_$$ -d -p /tmp)
+	if [ ! -e "$TMPDIR" ]; then
+		errorexit "Failed to create temp dir."
+	fi
+	# In case the script terminates without doing cleanup
+	function finish {
+		if [ "$TMP_MOUNT_DONE" -eq 1 ]; then
+			logmsg "exit unmount ${TMPDIR}"
+			umount "$TMPDIR"
+			rmdir "$TMPDIR"
+		fi
+	}
+	trap finish EXIT
+fi
+
+#
+# Main program function:
+# - the two main functions are fsextend and fsreduce.
+# - one special case function is cryptresize.
+#
+
+if [ "$DO_FSEXTEND" -eq 1 ]; then
+	fsextend
+elif [ "$DO_FSREDUCE" -eq 1 ]; then
+	fsreduce
+elif [ "$DO_CRYPTRESIZE" -eq 1 ]; then
+	cryptresize
+fi
+
diff --git a/spec/packages.inc b/spec/packages.inc
index f8271533a..cc1655ece 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -34,6 +34,7 @@ fi
 %doc COPYING COPYING.LIB INSTALL README VERSION WHATS_NEW
 %doc doc/lvm_fault_handling.txt
 %{_sbindir}/fsadm
+%{_libexecdir}/lvresize_fs_helper
 %{_sbindir}/lvchange
 %{_sbindir}/lvconvert
 %{_sbindir}/lvcreate
diff --git a/test/shell/fsadm-crypt-fsresize.sh b/test/shell/fsadm-crypt-fsresize.sh
new file mode 100644
index 000000000..009350800
--- /dev/null
+++ b/test/shell/fsadm-crypt-fsresize.sh
@@ -0,0 +1,612 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Exercise fsadm filesystem resize on crypt devices'
+
+SKIP_WITH_LVMPOLLD=1
+
+# FIXME: cannot use brd (ramdisk)  - lsblk is NOT listing it
+# so lsblk usage should be replaced
+export LVM_TEST_PREFER_BRD=0
+
+. lib/inittest
+
+aux prepare_vg 1 300
+
+# set to "skip" to avoid testing given fs and test warning result
+# i.e. check_reiserfs=skip
+check_ext2=
+check_ext3=
+check_xfs=
+check_reiserfs=
+check_cryptsetup=
+DROP_SYMLINK=
+
+CRYPT_NAME="$PREFIX-tcrypt"
+CRYPT_DEV="$DM_DEV_DIR/mapper/$CRYPT_NAME"
+
+CRYPT_NAME2="$PREFIX-tcrypt2"
+CRYPT_DEV2="$DM_DEV_DIR/mapper/$CRYPT_NAME2"
+
+CRYPT_NAME_PLAIN="$PREFIX-tcryptp"
+CRYPT_DEV_PLAIN="$DM_DEV_DIR/mapper/$CRYPT_NAME_PLAIN"
+
+FORMAT_PARAMS="-i1"
+PWD1="93R4P4pIqAH8"
+PWD2="mymJeD8ivEhE"
+PWD3="ocMakf3fAcQO"
+SKIP_DETACHED=
+
+if which cryptsetup ; then
+	# use older format luks1 - otherwise the test would need to pass password everywhere...
+	case $(cryptsetup --version) in
+	"cryptsetup 2"*)  FORMAT_PARAMS="$FORMAT_PARAMS --type luks1" ;;
+	esac
+else
+	check_cryptsetup=${check_cryptsetup:-cryptsetup}
+fi
+
+which mkfs.ext2 || check_ext2=${check_ext2:-mkfs.ext2}
+which mkfs.ext3 || check_ext3=${check_ext3:-mkfs.ext3}
+which fsck.ext3 || check_ext3=${check_ext3:-fsck.ext3}
+which mkfs.xfs || check_xfs=${check_xfs:-mkfs.xfs}
+which xfs_check || {
+	which xfs_repair || check_xfs=${check_xfs:-xfs_repair}
+}
+grep xfs /proc/filesystems || check_xfs=${check_xfs:-no_xfs}
+
+which mkfs.reiserfs || check_reiserfs=${check_reiserfs:-mkfs.reiserfs}
+which reiserfsck || check_reiserfs=${check_reiserfs:-reiserfsck}
+modprobe reiserfs || true
+grep reiserfs /proc/filesystems || check_reiserfs=${check_reiserfs:-no_reiserfs}
+
+vg_lv=$vg/$lv1
+vg_lv2=$vg/${lv1}bar
+vg_lv3=$vg/${lv1}plain
+dev_vg_lv="$DM_DEV_DIR/$vg_lv"
+dev_vg_lv2="$DM_DEV_DIR/$vg_lv2"
+dev_vg_lv3="$DM_DEV_DIR/$vg_lv3"
+mount_dir="mnt"
+
+test ! -d "$mount_dir" && mkdir "$mount_dir"
+
+crypt_close() {
+	aux udev_wait
+	cryptsetup remove "$1"
+	if [ "$?" -eq 0 -a -n "$DROP_SYMLINK" ]; then
+		rm -f "$DM_DEV_DIR/mapper/$1"
+	fi
+}
+
+cleanup_mounted_and_teardown()
+{
+	umount "$mount_dir" || true
+	crypt_close $CRYPT_NAME > /dev/null 2>&1 || true
+	crypt_close $CRYPT_NAME2 > /dev/null 2>&1 || true
+	crypt_close $CRYPT_NAME_PLAIN > /dev/null 2>&1 || true
+	aux teardown
+}
+
+fscheck_ext3()
+{
+	fsck.ext3 -p -F -f "$1"
+}
+
+fscheck_xfs()
+{
+	if which xfs_repair ; then
+		xfs_repair -n "$1"
+	else
+		xfs_check "$1"
+	fi
+}
+
+fscheck_reiserfs()
+{
+	reiserfsck --check -p -f "$1" </dev/null
+}
+
+check_missing()
+{
+	local t
+	eval "t=\$check_$1"
+	test -z "$t" && return 0
+	test "$t" = skip && return 1
+	echo "WARNING: fsadm test skipped $1 tests, $t tool is missing."
+	# trick to get test listed with warning
+	# should false;
+	return 1
+}
+
+get_crypt_kname() {
+	lsblk -r -n -o KNAME,NAME | grep "$1" | cut -d ' ' -f 1
+}
+
+
+# $1 device
+# $2 pass
+crypt_format() {
+	echo "$2" | cryptsetup luksFormat $FORMAT_PARAMS "$1"
+}
+
+
+# $1 device
+# $2 pass
+# $3 name
+crypt_open() {
+	local kname=
+	echo "$2" | cryptsetup luksOpen "$1" "$3"
+	test -L "$DM_DEV_DIR/mapper/$3" || {
+		kname=$(get_crypt_kname $3)
+		ln -s "/dev/$kname" "$DM_DEV_DIR/mapper/$3"
+		DROP_SYMLINK=1
+	}
+}
+
+# $1 data device
+# $2 pass
+# $3 name
+# $4 header
+crypt_open_detached() {
+	local kname=
+	echo "$2" | cryptsetup luksOpen --header "$4" "$1" "$3" || return $?
+	test -L "$DM_DEV_DIR/mapper/$3" || {
+		kname=$(get_crypt_kname $3)
+		ln -s "/dev/$kname" "$DM_DEV_DIR/mapper/$3"
+		DROP_SYMLINK=1
+	}
+}
+
+# $1 device
+# $2 pass
+# $3 name
+crypt_open_plain() {
+	local kname=
+	echo "$2" | cryptsetup create "$3" "$1"
+	test -L "$DM_DEV_DIR/mapper/$3" || {
+		kname=$(get_crypt_kname $3)
+		ln -s "/dev/$kname" "$DM_DEV_DIR/mapper/$3"
+		DROP_SYMLINK=1
+	}
+}
+
+# $1 device
+# $2 type
+create_crypt_device()
+{
+	crypt_format "$dev_vg_lv" $PWD1
+	crypt_open "$dev_vg_lv" $PWD1 "$CRYPT_NAME"
+
+	crypt_format "$dev_vg_lv2" $PWD2
+
+	if crypt_open_detached "$dev_vg_lv3" "$PWD2" "$PREFIX-test" "$dev_vg_lv2"; then
+		crypt_close "$PREFIX-test"
+	else
+		SKIP_DETACHED=1
+	fi
+}
+
+which lsblk > /dev/null || skip
+check_missing cryptsetup || skip
+
+vgchange -s 128k
+lvcreate -n $lv1 -L25M $vg
+lvcreate -n ${lv1}bar -L35M $vg
+lvcreate -n ${lv1}plain -L35M $vg
+create_crypt_device
+trap 'cleanup_mounted_and_teardown' EXIT
+
+
+# $1 LVM backend (vg/lv name)
+# $2 LVM backend device (/dev/vg/lv)
+# $3 active dm-crypt device (/dev/mapper/some_name )
+test_ext2_resize() {
+	mkfs.ext2 -b4096 -j "$3"
+
+	fsadm --lvresize resize $1 30M
+	# Fails - not enough space for 4M fs
+	not fsadm -y --lvresize resize "$2" 4M
+	lvresize -L+10M --fs resize $1
+	lvreduce -L10M --fs resize $1
+
+	fscheck_ext3 "$3"
+	mount "$3" "$mount_dir"
+	not fsadm -y --lvresize resize $1 4M
+	echo n | not lvresize -L4M --fs resize -n $1
+	lvresize -L+20M --fs resize -n $1
+	umount "$mount_dir"
+	fscheck_ext3 "$3"
+}
+
+test_ext2_small_shrink() {
+	mkfs.ext2 "$3"
+
+	lvresize -L-1 --fs resize $1
+	lvresize -L-1 --fs resize $1
+
+	fscheck_ext3 "$3"
+}
+
+test_ext3_resize() {
+	mkfs.ext3 -b4096 -j "$3"
+
+	fsadm --lvresize resize $1 30M
+	# Fails - not enough space for 4M fs
+	not fsadm -y --lvresize resize "$2" 4M
+	lvresize -L+10M --fs resize $1
+	lvreduce -L10M --fs resize $1
+
+	fscheck_ext3 "$3"
+	mount "$3" "$mount_dir"
+	lvresize -L+10M --fs resize $1
+
+	not fsadm -y --lvresize resize $1 4M
+	echo n | not lvresize -L4M --fs resize -n $1
+	lvresize -L+20M --fs resize -n $1
+	lvresize -L-10M --fs resize  -y $1
+	umount "$mount_dir"
+}
+
+test_ext3_small_shrink() {
+	mkfs.ext3 "$3"
+
+	lvresize -L-1 --fs resize $1
+	lvresize -L-1 --fs resize  $1
+
+	fscheck_ext3 "$3"
+}
+
+test_xfs_resize() {
+	mkfs.xfs -l internal,size=1536b -f "$3"
+
+	fsadm --lvresize resize $1 30M
+	# Fails - not enough space for 4M fs
+	lvresize -L+10M -y --fs resize $1
+	not lvreduce -L10M --fs resize $1
+
+	fscheck_xfs "$3"
+	mount "$3" "$mount_dir"
+	lvresize -L+10M -y --fs resize -n $1
+	umount "$mount_dir"
+	fscheck_xfs "$3"
+}
+
+test_xfs_small_shrink() {
+	mkfs.xfs -l internal,size=1536b -f "$3"
+
+	not lvresize -L-1 --fs resize $1
+	fscheck_xfs "$3"
+}
+
+test_reiserfs_resize() {
+	mkfs.reiserfs -s 513 -f "$3"
+
+	fsadm --lvresize resize $1 30M
+	lvresize -L+10M --fs resize $1
+	fsadm --lvresize -y resize $1 10M
+
+	fscheck_reiserfs "$3"
+	mount "$3" "$mount_dir"
+
+	fsadm -y --lvresize resize $1 30M
+	umount "$mount_dir"
+	fscheck_reiserfs "$3"
+}
+
+test_reiserfs_small_shrink() {
+	mkfs.reiserfs -s 513 -f "$3"
+
+	lvresize -y -L-1 --fs resize $1
+	lvresize -y -L-1 --fs resize  $1
+
+	fscheck_reiserfs "$3"
+}
+
+# $1 LVM backend (vg/lv name)
+# $2 LVM backend device (/dev/vg/lv)
+# $3 active dm-crypt device (/dev/mapper/some_name )
+# $4 active dm-crypt name ( some_name )
+test_ext2_inactive() {
+	crypt_open "$2" $PWD2 "$4"
+	mkfs.ext2 -b4096 -j "$3"
+	crypt_close "$4"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+
+	crypt_open "$2" $PWD2 "$4"
+	fscheck_ext3 "$3"
+	crypt_close "$4"
+}
+
+test_ext3_inactive() {
+	crypt_open "$2" $PWD2 "$4"
+	mkfs.ext3 -b4096 -j "$3"
+	crypt_close "$4"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+
+	crypt_open "$2" $PWD2 "$4"
+	fscheck_ext3 "$3"
+	crypt_close "$4"
+}
+
+test_xfs_inactive() {
+	crypt_open "$2" $PWD2 "$4"
+	mkfs.xfs -l internal,size=1536b -f "$3"
+	crypt_close "$4"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+
+	crypt_open "$2" $PWD2 "$4"
+	fscheck_xfs "$3"
+	crypt_close "$4"
+}
+
+test_reiserfs_inactive() {
+	crypt_open "$2" $PWD2 "$4"
+	mkfs.reiserfs -s 513 -f "$3"
+	crypt_close "$4"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+
+	crypt_open "$2" $PWD2 "$4"
+	fscheck_reiserfs "$3"
+	crypt_close "$4"
+}
+
+# $1 LVM backend (vg/lv name)
+# $2 LVM backend device (/dev/vg/lv)
+# $3 active dm-crypt device (/dev/mapper/some_name )
+# $4 active dm-crypt name ( some_name )
+test_ext2_plain() {
+	mkfs.ext2 -b4096 -j "$3"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+	fscheck_ext3 "$3"
+
+	fsadm --cryptresize resize $3 30M
+	fsadm --cryptresize resize $3 35M
+	fscheck_ext3 "$3"
+
+	mount "$3" "$mount_dir"
+	not fsadm -y --cryptresize resize $3 4M
+	umount "$mount_dir"
+	fscheck_ext3 "$3"
+
+	crypt_close "$4"
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+	crypt_open_plain "$2" $PWD3 "$4"
+	fscheck_ext3 "$3"
+}
+
+test_ext3_plain() {
+	mkfs.ext3 -b4096 -j "$3"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+	fscheck_ext3 "$3"
+
+	fsadm --cryptresize resize $3 30M
+	fsadm --cryptresize resize $3 35M
+	fscheck_ext3 "$3"
+
+	mount "$3" "$mount_dir"
+	not fsadm -y --cryptresize resize $3 4M
+	umount "$mount_dir"
+	fscheck_ext3 "$3"
+
+	crypt_close "$4"
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+	crypt_open_plain "$2" $PWD3 "$4"
+	fscheck_ext3 "$3"
+}
+
+test_xfs_plain() {
+	mkfs.xfs -l internal,size=1536b -f "$3"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+	fscheck_xfs "$3"
+
+	lvresize -f -L+10M $1
+	fsadm --cryptresize resize $3 40M
+	# no shrink support in xfs
+	not fsadm --cryptresize resize $3 35M
+	fscheck_xfs "$3"
+
+	crypt_close "$4"
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+	crypt_open_plain "$2" $PWD3 "$4"
+	fscheck_xfs "$3"
+
+	lvresize -f -L35M $1
+}
+
+test_reiserfs_plain() {
+	mkfs.reiserfs -s 513 -f "$3"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L-10M --fs resize $1
+	fscheck_reiserfs "$3"
+
+	fsadm -y --cryptresize resize $3 30M
+	fsadm -y --cryptresize resize $3 35M
+	fscheck_reiserfs "$3"
+
+	crypt_close "$4"
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+	crypt_open_plain "$2" $PWD3 "$4"
+	fscheck_reiserfs "$3"
+}
+
+# $1 LVM header backend (vg/lv name)
+# $2 LVM hedaer backend device (/dev/vg/lv)
+# $3 active dm-crypt device (/dev/mapper/some_name )
+# $4 active dm-crypt name ( some_name )a
+test_ext2_detached() {
+	mkfs.ext2 -b4096 -j "$3"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+	fscheck_ext3 "$3"
+}
+
+test_ext3_detached() {
+	mkfs.ext3 -b4096 -j "$3"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+	fscheck_ext3 "$3"
+}
+
+test_xfs_detached() {
+	mkfs.xfs -l internal,size=1536b -f "$3"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+
+	fscheck_xfs "$3"
+}
+
+test_reiserfs_detached() {
+	mkfs.reiserfs -s 513 -f "$3"
+
+	not fsadm --lvresize resize $1 30M
+	not lvresize -L+10M --fs resize $1
+	not lvreduce -L10M --fs resize $1
+
+	fscheck_reiserfs "$3"
+}
+
+if check_missing ext2; then
+	test_ext2_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize --fs ignore -y -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
+	test_ext2_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+
+	crypt_open_plain "$dev_vg_lv3" $PWD3 "$CRYPT_NAME_PLAIN"
+	test_ext2_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
+	crypt_close "$CRYPT_NAME_PLAIN"
+
+	lvresize --fs ignore -y -L100M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+	test_ext2_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize --fs ignore -y -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
+	if [ -z "$SKIP_DETACHED" ]; then
+		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
+		test_ext2_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+		crypt_close "$CRYPT_NAME2"
+	fi
+fi
+
+if check_missing ext3; then
+	test_ext3_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize --fs ignore -y -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
+	test_ext3_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+
+	crypt_open_plain "$dev_vg_lv3" $PWD3 "$CRYPT_NAME_PLAIN"
+	test_ext3_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
+	crypt_close "$CRYPT_NAME_PLAIN"
+
+	lvresize --fs ignore -y -L100M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+	test_ext3_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize --fs ignore -y -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
+	if [ -z "$SKIP_DETACHED" ]; then
+		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
+		test_ext3_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+		crypt_close "$CRYPT_NAME2"
+	fi
+fi
+
+if check_missing xfs; then
+	test_xfs_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize --fs ignore -y -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
+	test_xfs_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+
+	crypt_open_plain "$dev_vg_lv3" $PWD3 "$CRYPT_NAME_PLAIN"
+	test_xfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
+	crypt_close "$CRYPT_NAME_PLAIN"
+
+	lvresize --fs ignore -y -L100M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+	test_xfs_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize --fs ignore -y -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
+	if [ -z "$SKIP_DETACHED" ]; then
+		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
+		test_xfs_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+		crypt_close "$CRYPT_NAME2"
+	fi
+fi
+
+if check_missing reiserfs; then
+	test_reiserfs_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize --fs ignore -y -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
+	test_reiserfs_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+
+	crypt_open_plain "$dev_vg_lv3" $PWD3 "$CRYPT_NAME_PLAIN"
+	test_reiserfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
+	crypt_close "$CRYPT_NAME_PLAIN"
+
+	lvresize --fs ignore -y -L100M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+	test_reiserfs_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
+	lvresize --fs ignore -y -L25M $vg_lv
+	cryptsetup resize $CRYPT_NAME
+
+	if [ -z "$SKIP_DETACHED" ]; then
+		crypt_open_detached "$dev_vg_lv3" $PWD2 "$CRYPT_NAME2" "$dev_vg_lv2"
+		test_reiserfs_detached "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
+		crypt_close "$CRYPT_NAME2"
+	fi
+fi
+
+crypt_close "$CRYPT_NAME"
+
+vgremove -ff $vg
diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 3b0c46aca..4d6efbc63 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -215,14 +215,14 @@ test_ext2_resize() {
 	fsadm --lvresize resize $1 30M
 	# Fails - not enough space for 4M fs
 	not fsadm -y --lvresize resize "$2" 4M
-	lvresize -L+10M -r $1
-	lvreduce -L10M -r $1
+	lvresize -L+10M --fs resize_fsadm $1
+	lvreduce -L10M --fs resize_fsadm $1
 
 	fscheck_ext3 "$3"
 	mount "$3" "$mount_dir"
 	not fsadm -y --lvresize resize $1 4M
-	echo n | not lvresize -L4M -r -n $1
-	lvresize -L+20M -r -n $1
+	echo n | not lvresize -L4M --fs resize_fsadm -n $1
+	lvresize -L+20M --fs resize_fsadm -n $1
 	umount "$mount_dir"
 	fscheck_ext3 "$3"
 }
@@ -230,8 +230,8 @@ test_ext2_resize() {
 test_ext2_small_shrink() {
 	mkfs.ext2 "$3"
 
-	lvresize -L-1 -r $1
-	lvresize -L-1 -r $1
+	lvresize -L-1 --fs resize_fsadm $1
+	lvresize -L-1 --fs resize_fsadm $1
 
 	fscheck_ext3 "$3"
 }
@@ -242,25 +242,25 @@ test_ext3_resize() {
 	fsadm --lvresize resize $1 30M
 	# Fails - not enough space for 4M fs
 	not fsadm -y --lvresize resize "$2" 4M
-	lvresize -L+10M -r $1
-	lvreduce -L10M -r $1
+	lvresize -L+10M --fs resize_fsadm $1
+	lvreduce -L10M --fs resize_fsadm $1
 
 	fscheck_ext3 "$3"
 	mount "$3" "$mount_dir"
-	lvresize -L+10M -r $1
+	lvresize -L+10M --fs resize_fsadm $1
 
 	not fsadm -y --lvresize resize $1 4M
-	echo n | not lvresize -L4M -r -n $1
-	lvresize -L+20M -r -n $1
-	lvresize -L-10M -r -y $1
+	echo n | not lvresize -L4M --fs resize_fsadm -n $1
+	lvresize -L+20M --fs resize_fsadm -n $1
+	lvresize -L-10M --fs resize_fsadm  -y $1
 	umount "$mount_dir"
 }
 
 test_ext3_small_shrink() {
 	mkfs.ext3 "$3"
 
-	lvresize -L-1 -r $1
-	lvresize -L-1 -r $1
+	lvresize -L-1 --fs resize_fsadm $1
+	lvresize -L-1 --fs resize_fsadm  $1
 
 	fscheck_ext3 "$3"
 }
@@ -270,12 +270,12 @@ test_xfs_resize() {
 
 	fsadm --lvresize resize $1 330M
 	# Fails - not enough space for 4M fs
-	lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 
 	fscheck_xfs "$3"
 	mount "$3" "$mount_dir"
-	lvresize -L+10M -r -n $1
+	lvresize -L+10M --fs resize_fsadm -n $1
 	umount "$mount_dir"
 	fscheck_xfs "$3"
 }
@@ -283,7 +283,7 @@ test_xfs_resize() {
 test_xfs_small_shrink() {
 	mkfs.xfs -f "$3"
 
-	not lvresize -L-1 -r $1
+	not lvresize -L-1 --fs resize_fsadm $1
 	fscheck_xfs "$3"
 }
 
@@ -291,7 +291,7 @@ test_reiserfs_resize() {
 	mkfs.reiserfs -s 513 -f "$3"
 
 	fsadm --lvresize resize $1 30M
-	lvresize -L+10M -r $1
+	lvresize -L+10M --fs resize_fsadm $1
 	fsadm --lvresize -y resize $1 10M
 
 	fscheck_reiserfs "$3"
@@ -305,8 +305,8 @@ test_reiserfs_resize() {
 test_reiserfs_small_shrink() {
 	mkfs.reiserfs -s 513 -f "$3"
 
-	lvresize -y -L-1 -r $1
-	lvresize -y -L-1 -r $1
+	lvresize -y -L-1 --fs resize_fsadm $1
+	lvresize -y -L-1 --fs resize_fsadm  $1
 
 	fscheck_reiserfs "$3"
 }
@@ -321,8 +321,8 @@ test_ext2_inactive() {
 	crypt_close "$4"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 
 	crypt_open "$2" $PWD2 "$4"
 	fscheck_ext3 "$3"
@@ -335,8 +335,8 @@ test_ext3_inactive() {
 	crypt_close "$4"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 
 	crypt_open "$2" $PWD2 "$4"
 	fscheck_ext3 "$3"
@@ -349,8 +349,8 @@ test_xfs_inactive() {
 	crypt_close "$4"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 
 	crypt_open "$2" $PWD2 "$4"
 	fscheck_xfs "$3"
@@ -363,8 +363,8 @@ test_reiserfs_inactive() {
 	crypt_close "$4"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 
 	crypt_open "$2" $PWD2 "$4"
 	fscheck_reiserfs "$3"
@@ -379,8 +379,8 @@ test_ext2_plain() {
 	mkfs.ext2 -b4096 -j "$3"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 	fscheck_ext3 "$3"
 
 	fsadm --cryptresize resize $3 30M
@@ -394,8 +394,8 @@ test_ext2_plain() {
 
 	crypt_close "$4"
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_ext3 "$3"
 }
@@ -404,8 +404,8 @@ test_ext3_plain() {
 	mkfs.ext3 -b4096 -j "$3"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 	fscheck_ext3 "$3"
 
 	fsadm --cryptresize resize $3 30M
@@ -419,8 +419,8 @@ test_ext3_plain() {
 
 	crypt_close "$4"
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_ext3 "$3"
 }
@@ -429,8 +429,8 @@ test_xfs_plain() {
 	mkfs.xfs -f "$3"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 	fscheck_xfs "$3"
 
 	lvresize -f -L+10M $1
@@ -441,8 +441,8 @@ test_xfs_plain() {
 
 	crypt_close "$4"
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_xfs "$3"
 
@@ -453,8 +453,8 @@ test_reiserfs_plain() {
 	mkfs.reiserfs -s 513 -f "$3"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L-10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L-10M --fs resize_fsadm $1
 	fscheck_reiserfs "$3"
 
 	fsadm -y --cryptresize resize $3 30M
@@ -463,8 +463,8 @@ test_reiserfs_plain() {
 
 	crypt_close "$4"
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 	crypt_open_plain "$2" $PWD3 "$4"
 	fscheck_reiserfs "$3"
 }
@@ -477,8 +477,8 @@ test_ext2_detached() {
 	mkfs.ext2 -b4096 -j "$3"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 	fscheck_ext3 "$3"
 }
 
@@ -486,8 +486,8 @@ test_ext3_detached() {
 	mkfs.ext3 -b4096 -j "$3"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 	fscheck_ext3 "$3"
 }
 
@@ -495,8 +495,8 @@ test_xfs_detached() {
 	mkfs.xfs -f "$3"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 
 	fscheck_xfs "$3"
 }
@@ -505,15 +505,15 @@ test_reiserfs_detached() {
 	mkfs.reiserfs -s 513 -f "$3"
 
 	not fsadm --lvresize resize $1 30M
-	not lvresize -L+10M -r $1
-	not lvreduce -L10M -r $1
+	not lvresize -L+10M --fs resize_fsadm $1
+	not lvreduce -L10M --fs resize_fsadm $1
 
 	fscheck_reiserfs "$3"
 }
 
 if check_missing ext2; then
 	test_ext2_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize -f -L25M $vg_lv
+	lvresize --fs ignore -y -L25M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	test_ext2_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
@@ -522,10 +522,10 @@ if check_missing ext2; then
 	test_ext2_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	lvresize -f -L100M $vg_lv
+	lvresize --fs ignore -y -L100M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 	test_ext2_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize -f -L25M $vg_lv
+	lvresize --fs ignore -y -L25M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	if [ -z "$SKIP_DETACHED" ]; then
@@ -537,7 +537,7 @@ fi
 
 if check_missing ext3; then
 	test_ext3_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize -f -L25M $vg_lv
+	lvresize --fs ignore -y -L25M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	test_ext3_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
@@ -546,10 +546,10 @@ if check_missing ext3; then
 	test_ext3_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	lvresize -f -L100M $vg_lv
+	lvresize --fs ignore -y -L100M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 	test_ext3_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize -f -L25M $vg_lv
+	lvresize --fs ignore -y -L25M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	if [ -z "$SKIP_DETACHED" ]; then
@@ -563,7 +563,7 @@ if check_missing xfs; then
 	lvresize -f -L310M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 	test_xfs_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize -f -L325M $vg_lv
+	lvresize --fs ignore -y -L325M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	test_xfs_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
@@ -572,10 +572,10 @@ if check_missing xfs; then
 	test_xfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	lvresize -f -L310M $vg_lv
+	lvresize --fs ignore -y -L310M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 	test_xfs_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize -f -L25M $vg_lv
+	lvresize --fs ignore -y -L25M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	if [ -z "$SKIP_DETACHED" ]; then
@@ -587,7 +587,7 @@ fi
 
 if check_missing reiserfs; then
 	test_reiserfs_resize "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize -f -L25M $vg_lv
+	lvresize --fs ignore -y -L25M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	test_reiserfs_inactive "$vg_lv2" "$dev_vg_lv2" "$CRYPT_DEV2" "$CRYPT_NAME2"
@@ -596,10 +596,10 @@ if check_missing reiserfs; then
 	test_reiserfs_plain "$vg_lv3" "$dev_vg_lv3" "$CRYPT_DEV_PLAIN" "$CRYPT_NAME_PLAIN"
 	crypt_close "$CRYPT_NAME_PLAIN"
 
-	lvresize -f -L100M $vg_lv
+	lvresize --fs ignore -y -L100M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 	test_reiserfs_small_shrink "$vg_lv" "$dev_vg_lv" "$CRYPT_DEV"
-	lvresize -f -L25M $vg_lv
+	lvresize --fs ignore -y -L25M $vg_lv
 	cryptsetup resize $CRYPT_NAME
 
 	if [ -z "$SKIP_DETACHED" ]; then
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index fea86813d..7f155d707 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -113,18 +113,18 @@ if check_missing ext2; then
 	fsadm --lvresize resize $vg_lv 30M
 	# Fails - not enough space for 4M fs
 	not fsadm -y --lvresize resize "$dev_vg_lv" 4M
-	lvresize -L+10M -r $vg_lv
-	lvreduce -L10M -r $vg_lv
+	lvresize -L+10M --fs resize_fsadm $vg_lv
+	lvreduce -L10M --fs resize_fsadm $vg_lv
 
 	fscheck_ext3
 	mount "$dev_vg_lv" "$mount_dir"
 	not fsadm -y --lvresize resize $vg_lv 4M
-	echo n | not lvresize -L4M -r -n $vg_lv
-	lvresize -L+20M -r -n $vg_lv
+	echo n | not lvresize -L4M --fs resize_fsadm -n $vg_lv
+	lvresize -L+20M --fs resize_fsadm -n $vg_lv
 	umount "$mount_dir"
 	fscheck_ext3
 
-	lvresize -f -L20M $vg_lv
+	lvresize --fs ignore -y -L20M $vg_lv
 
 	if which debugfs ; then
 		mkfs.ext2 -b4096 -j "$dev_vg_lv"
@@ -145,7 +145,7 @@ if check_missing ext2; then
 
 		mount "$dev_vg_lv" "$mount_dir"
 		fsadm -v -y --lvresize resize $vg_lv 10M
-		lvresize -L+10M -y -r -n $vg_lv
+		lvresize -L+10M -y --fs resize_fsadm -n $vg_lv
 		umount "$mount_dir" 2>/dev/null || true
 		fscheck_ext3
 	fi
@@ -158,24 +158,24 @@ if check_missing ext3; then
 	fsadm --lvresize resize $vg_lv 30M
 	# Fails - not enough space for 4M fs
 	not fsadm -y --lvresize resize "$dev_vg_lv" 4M
-	lvresize -L+10M -r $vg_lv
-	lvreduce -L10M -r $vg_lv
+	lvresize -L+10M --fs resize_fsadm $vg_lv
+	lvreduce -L10M --fs resize_fsadm $vg_lv
 
 	fscheck_ext3
 	mount "$dev_vg_lv" "$mount_dir"
-	lvresize -L+10M -r $vg_lv
+	lvresize -L+10M --fs resize_fsadm $vg_lv
 	mount "$dev_vg_lv2" "$mount_space_dir"
 	fsadm --lvresize -e -y resize $vg_lv2 25M
 
 	not fsadm -y --lvresize resize $vg_lv 4M
 	echo n | not lvresize -L4M -r -n $vg_lv
-	lvresize -L+20M -r -n $vg_lv
-	lvresize -L-10M -r -y $vg_lv
+	lvresize -L+20M --fs resize_fsadm -n $vg_lv
+	lvresize -L-10M --fs resize_fsadm -y $vg_lv
 	umount "$mount_dir"
 	umount "$mount_space_dir"
 	fscheck_ext3
 
-	lvresize -f -L20M $vg_lv
+	lvresize --fs ignore -y -L20M $vg_lv
 fi
 
 if check_missing xfs; then
@@ -183,23 +183,24 @@ if check_missing xfs; then
 	mkfs.xfs -l internal -f "$dev_vg_lv"
 
 	fsadm --lvresize resize $vg_lv 320M
-	lvresize -L+10M -r $vg_lv
-	not lvreduce -L10M -r $vg_lv
+	# Fails - not enough space for 4M fs
+	lvresize -L+10M --fs resize_fsadm $vg_lv
+	not lvreduce -L10M --fs resize_fsadm $vg_lv
 
 	fscheck_xfs
 	mount "$dev_vg_lv" "$mount_dir"
-	lvresize -L+10M -r -n $vg_lv
+	lvresize -L+10M --fs resize_fsadm -n $vg_lv
 	umount "$mount_dir"
 	fscheck_xfs
 
-	lvresize -f -L20M $vg_lv
+	lvresize --fs ignore -y -L20M $vg_lv
 fi
 
 if check_missing reiserfs; then
 	mkfs.reiserfs -s 513 -f "$dev_vg_lv"
 
 	fsadm --lvresize resize $vg_lv 30M
-	lvresize -L+10M -r $vg_lv
+	lvresize -L+10M --fs resize_fsadm $vg_lv
 	fsadm --lvresize -y resize $vg_lv 10M
 
 	fscheck_reiserfs
@@ -209,7 +210,7 @@ if check_missing reiserfs; then
 	umount "$mount_dir"
 	fscheck_reiserfs
 
-	lvresize -f -L20M $vg_lv
+	lvresize --fs ignore -y -L20M $vg_lv
 fi
 
 vgremove -ff $vg
diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index 506c005dd..68e61153d 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -264,8 +264,8 @@ lvcreate -l1 -n $lv2 $vg1
 lvcreate -l1 -an -n $lv3 $vg1
 lvchange -an $vg1
 lvremove $vg1/$lv3
-lvresize -l+1 $vg1/$lv2
-lvresize -l-1 $vg1/$lv2
+lvresize --fs ignore -l+1 $vg1/$lv2
+lvresize --fs ignore -l-1 $vg1/$lv2
 lvdisplay
 pvdisplay
 vgdisplay
diff --git a/test/shell/lvresize-fs-crypt.sh b/test/shell/lvresize-fs-crypt.sh
new file mode 100644
index 000000000..19c4e7d8e
--- /dev/null
+++ b/test/shell/lvresize-fs-crypt.sh
@@ -0,0 +1,131 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2007-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_vg 3 256
+
+mount_dir="mnt_lvresize_cr"
+mkdir -p "$mount_dir"
+
+# dm-crypt device on lv
+cr="$PREFIX-$lv-cr"
+
+# lvextend ext4 on LUKS1
+lvcreate -n $lv -L 256M $vg
+echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
+echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
+mkfs.ext4 /dev/mapper/$cr
+mount /dev/mapper/$cr "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+lvextend -L+200M --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+umount "$mount_dir"
+cryptsetup close $cr
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce ext4 on LUKS1
+lvcreate -n $lv -L 456M $vg
+echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
+echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
+mkfs.ext4 /dev/mapper/$cr
+mount /dev/mapper/$cr "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+lvresize -L-100M --yes --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "356.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+umount "$mount_dir"
+cryptsetup close $cr
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend xfs on LUKS1
+lvcreate -n $lv -L 256M $vg
+echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
+echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
+mkfs.xfs /dev/mapper/$cr
+mount /dev/mapper/$cr "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+lvextend -L+200M --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+umount "$mount_dir"
+cryptsetup close $cr
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce xfs on LUKS1
+lvcreate -n $lv -L 456M $vg
+echo 93R4P4pIqAH8 | cryptsetup luksFormat -i1 --type luks1 "$DM_DEV_DIR/$vg/$lv"
+echo 93R4P4pIqAH8 | cryptsetup luksOpen "$DM_DEV_DIR/$vg/$lv" $cr
+mkfs.xfs /dev/mapper/$cr
+mount /dev/mapper/$cr "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# xfs cannot be reduced
+not lvresize -L-100M --yes --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+diff df1 df2
+umount "$mount_dir"
+cryptsetup close $cr
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend ext4 on plain crypt (no header)
+lvcreate -n $lv -L 256M $vg
+echo 93R4P4pIqAH8 | cryptsetup create $cr "$DM_DEV_DIR/$vg/$lv"
+mkfs.ext4 /dev/mapper/$cr
+mount /dev/mapper/$cr "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# fails when no fs is found for --fs resize
+not lvextend -L+200M --yes --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+df --output=size "$mount_dir" |tee df2
+diff df1 df2
+umount "$mount_dir"
+cryptsetup close $cr
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce ext4 on plain crypt (no header)
+lvcreate -n $lv -L 456M $vg
+echo 93R4P4pIqAH8 | cryptsetup create $cr "$DM_DEV_DIR/$vg/$lv"
+mkfs.ext4 /dev/mapper/$cr
+mount /dev/mapper/$cr "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# fails when no fs is found for --fs resize
+not lvresize -L-100M --yes --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+diff df1 df2
+umount "$mount_dir"
+cryptsetup close $cr
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# test with LUKS2?
+
+vgremove -ff $vg
diff --git a/test/shell/lvresize-fs.sh b/test/shell/lvresize-fs.sh
new file mode 100644
index 000000000..b65e980b7
--- /dev/null
+++ b/test/shell/lvresize-fs.sh
@@ -0,0 +1,1186 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2007-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_vg 3 256
+
+# Test combinations of the following:
+# lvreduce / lvextend
+# no fs / ext4 / xfs
+# each --fs opt / no --fs opt / --resizefs
+# active / inactive
+# mounted / unmounted
+# fs size less than, equal to or greater than reduced lv size
+
+mount_dir="mnt_lvresize_fs"
+mkdir -p "$mount_dir"
+
+
+#
+# lvextend, no fs
+#
+
+# lvextend, no fs, active, no --fs
+lvcreate -n $lv -L 256M $vg
+aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, no fs, inactive, no --fs
+lvcreate -n $lv -L 256M $vg
+aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
+lvchange -an $vg/$lv
+lvextend -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+lvremove $vg/$lv
+
+# lvextend, no fs, active, --fs resize fails with no fs found
+lvcreate -n $lv -L 256M $vg
+aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
+not lvextend -L+200M --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, no fs, inactive, --fs resize error requires active lv
+lvcreate -n $lv -L 256M $vg
+aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
+lvchange -an $vg/$lv
+not lvextend -L+200M --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+lvremove $vg/$lv
+
+#
+# lvextend, ext4
+#
+
+# lvextend, ext4, active, mounted, no --fs setting is same as --fs ignore
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+# with no --fs used, the fs size should be the same
+df --output=size "$mount_dir" |tee df2
+diff df1 df2
+resize2fs "$DM_DEV_DIR/$vg/$lv"
+df --output=size "$mount_dir" |tee df3
+not diff df2 df3
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, inactive, --fs ignore
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvchange -an $vg/$lv
+lvextend --fs ignore -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+lvremove $vg/$lv
+
+# lvextend, ext4, active, mounted, --fs ignore
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+lvextend --fs ignore -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, active, mounted, --fs resize
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --fs resize -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, active, mounted, --resizefs (same as --fs resize)
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --resizefs -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, active, mounted, --fs resize --fsmode manage (same as --fs resize)
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --fs resize --fsmode manage -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, active, mounted, --fs resize --fsmode offline
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --fs resize --fsmode offline -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+# fsmode offline leaves fs unmounted 
+df -a | tee dfa
+not grep "$mount_dir" dfa
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, active, mounted, --fs resize --fsmode nochange
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --fs resize --fsmode nochange -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, active, mounted, --fs resize_fsadm
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --fs resize_fsadm -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, active, unmounted, --fs resize --fsmode nochange
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvextend --fs resize --fsmode nochange -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, active, unmounted, --fs resize
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvextend --fs resize -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, ext4, active, unmounted, --fs resize_fsadm
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvextend --fs resize_fsadm -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+
+#
+# lvextend, xfs
+#
+
+# lvextend, xfs, active, mounted, no --fs setting is same as --fs ignore
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+# with no --fs used, the fs size should be the same
+df --output=size "$mount_dir" |tee df2
+diff df1 df2
+xfs_growfs "$DM_DEV_DIR/$vg/$lv"
+df --output=size "$mount_dir" |tee df3
+not diff df2 df3
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, inactive, --fs ignore
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+lvchange -an $vg/$lv
+lvextend --fs ignore -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+lvremove $vg/$lv
+
+# lvextend, xfs, active, mounted, --fs ignore
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+lvextend --fs ignore -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, active, mounted, --fs resize
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --fs resize -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, active, mounted, --resizefs (same as --fs resize)
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --resizefs -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, active, mounted, --fs resize --fsmode manage (same as --fs resize)
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --fs resize --fsmode manage -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, active, mounted, --fs resize --fsmode offline
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+# xfs_growfs requires the fs to be mounted, so extending the lv is
+# succeeds, then the xfs extend fails because it cannot be done unmounted
+not lvextend --fs resize --fsmode offline -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df -a | tee dfa
+grep "$mount_dir" dfa
+df --output=size "$mount_dir" |tee df2
+# fs not extended so fs size not changed
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, active, mounted, --fs resize --fsmode nochange
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --fs resize --fsmode nochange -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, active, mounted, --fs resize_fsadm
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+lvextend --fs resize_fsadm -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, active, unmounted, --fs resize --fsmode nochange
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+# xfs_growfs requires the fs to be mounted to grow, so --fsmode nochange
+# with an unmounted fs fails
+not lvextend --fs resize --fsmode nochange -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs not extended so fs size not changed
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, active, unmounted, --fs resize
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+# --yes needed because mount changes are required and plain "resize"
+# fsopt did not specify if the user wants to change mount state
+lvextend --yes --fs resize -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvextend, xfs, active, unmounted, --fs resize_fsadm
+lvcreate -n $lv -L 256M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df1
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvextend --fs resize_fsadm -L+200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+not diff df1 df2
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=200 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+
+#
+# lvreduce, no fs
+#
+
+# lvreduce, no fs, active, no --fs setting is same as --fs checksize
+lvcreate -n $lv -L 456M $vg
+aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
+lvreduce -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, no fs, inactive, no --fs setting is same as --fs checksize
+lvcreate -n $lv -L 456M $vg
+aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
+lvchange -an $vg/$lv
+lvreduce -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+lvremove $vg/$lv
+
+# lvreduce, no fs, active, --fs resize requires fs to be found
+lvcreate -n $lv -L 456M $vg
+aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
+not lvreduce -L-200M --fs resize $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, no fs, inactive, --fs ignore
+lvcreate -n $lv -L 456M $vg
+aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
+lvchange -an $vg/$lv
+lvreduce -L-200M --fs ignore $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+
+#
+# lvreduce, ext4, no --fs setting and the equivalent --fs checksize
+# i.e. fs is not resized
+#
+
+# lvreduce, ext4, active, mounted, no --fs setting is same as --fs checksize
+# fs smaller than the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+# todo: check that resize2fs was not run?
+lvreduce -L216M $vg/$lv
+check lv_field $vg/$lv lv_size "216.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, mounted, no --fs setting is same as --fs checksize
+# fs equal to the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# fs is 200M, reduced size is 200M, so no fs reduce is needed
+# todo: check that resize2fs was not run?
+lvreduce -L200M $vg/$lv
+check lv_field $vg/$lv lv_size "200.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, mounted, no --fs setting is same as --fs checksize
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce fails because fs needs to be reduced and checksize does not resize
+not lvreduce -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, mounted, no --fs setting is same as --fs checksize
+# fs larger than the reduced size, fs is using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=300 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce fails because fs needs to be reduced and checksize does not resize
+not lvreduce -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# repeat lvreduce tests with unmounted instead of mounted fs
+
+# lvreduce, ext4, active, unmounted, no --fs setting is same as --fs checksize
+# fs smaller than the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+lvreduce -L216M $vg/$lv
+check lv_field $vg/$lv lv_size "216.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, no --fs setting is same as --fs checksize
+# fs equal to the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# fs is 200M, reduced size is 200M, so no fs reduce is needed
+lvreduce -L200M $vg/$lv
+check lv_field $vg/$lv lv_size "200.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, no --fs setting is same as --fs checksize
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# lvreduce fails because fs needs to be reduced and checksize does not resize
+not lvreduce -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, no --fs setting is same as --fs checksize
+# fs larger than the reduced size, fs is using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=300 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# lvreduce fails because fs needs to be reduced and checksize does not resize
+not lvreduce -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# repeat a couple prev lvreduce that had no --fs setting,
+# now using --fs checksize to verify it's the same as using no --fs set
+
+# lvreduce, ext4, active, mounted, --fs checksize (same as no --fs set)
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce fails because fs needs to be reduced and checksize does not resize
+not lvreduce --fs checksize -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, --fs checksize (same as no --fs set)
+# fs smaller than the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+lvreduce --fs checksize -L216M $vg/$lv
+check lv_field $vg/$lv lv_size "216.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce with inactive and no --fs setting fails because
+# default behavior is fs checksize which activates the LV
+# and sees the fs
+
+# lvreduce, ext4, inactive, no --fs setting same as --fs checksize
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+lvchange -an $vg/$lv
+# lvreduce fails because default is --fs checksize which sees the fs
+not lvreduce -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+lvremove $vg/$lv
+
+#
+# lvreduce, ext4, --fs resize*
+#
+
+# lvreduce, ext4, active, mounted, --fs resize
+# fs smaller than the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+lvreduce -L216M $vg/$lv
+check lv_field $vg/$lv lv_size "216.00m"
+ls -l $mount_dir/zeros1
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, mounted, --fs resize
+# fs equal to the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# fs is 200M, reduced size is 200M, so no fs reduce is needed
+lvreduce -L200M $vg/$lv
+check lv_field $vg/$lv lv_size "200.00m"
+ls -l $mount_dir/zeros1
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, mounted, --fs resize
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce runs resize2fs to shrink the fs
+lvreduce --yes --fs resize -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+ls -l $mount_dir/zeros1
+df --output=size "$mount_dir" |tee df2
+# fs size is changed
+not diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, mounted, --fs resize
+# fs larger than the reduced size, fs is using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=300 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce runs resize2fs to shrink the fs but resize2fs fails
+# the fs is not remounted after resize2fs fails because the
+# resize failure might leave the fs in an unknown state
+not lvreduce --yes --fs resize -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+ls -l $mount_dir/zeros1
+ls -l $mount_dir/zeros2
+df --output=size "$mount_dir" |tee df2
+# fs size is unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# repeat with unmounted instead of mounted
+
+# lvreduce, ext4, active, unmounted, --fs resize
+# fs smaller than the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+lvreduce -L216M $vg/$lv
+check lv_field $vg/$lv lv_size "216.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+ls -l $mount_dir/zeros1
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, --fs resize
+# fs equal to the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# fs is 200M, reduced size is 200M, so no fs reduce is needed
+lvreduce -L200M $vg/$lv
+check lv_field $vg/$lv lv_size "200.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+ls -l $mount_dir/zeros1
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, --fs resize
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# lvreduce runs resize2fs to shrink the fs
+lvreduce --fs resize -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+ls -l $mount_dir/zeros1
+df --output=size "$mount_dir" |tee df2
+# fs size is changed
+not diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, --fs resize
+# fs larger than the reduced size, fs is using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+dd if=/dev/zero of="$mount_dir/zeros2" bs=1M count=300 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# lvreduce runs resize2fs to shrink the fs but resize2fs fails
+not lvreduce --yes --fs resize -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+ls -l $mount_dir/zeros1
+df --output=size "$mount_dir" |tee df2
+# fs size is unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# repeat resizes that shrink the fs, replacing --fs resize with
+# --fs resize --fsmode nochange|offline, --fs resize_fsadm.
+# while mounted and unmounted
+
+# lvreduce, ext4, active, mounted, --fs resize --fsmode nochange
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce needs to unmount to run resize2fs but fsmode nochange doesn't let it
+not lvreduce --fs resize --fsmode nochange -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size is unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, --fs resize --fsmode nochange
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# lvreduce runs resize2fs to shrink the fs
+lvreduce --fs resize --fsmode nochange -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size is changed
+not diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, mounted, --fs resize --fsmode offline
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce runs resize2fs to shrink the fs
+# fsmode offline leaves the fs unmounted
+lvreduce --fs resize --fsmode offline -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size is changed
+not diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, --fs resize --fsmode offline
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# lvreduce runs resize2fs to shrink the fs
+lvreduce --fs resize --fsmode offline -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size is changed
+not diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, mounted, --fs resize_fsadm
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce runs resize2fs to shrink the fs
+lvreduce --yes --fs resize_fsadm -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+ls -l $mount_dir/zeros1
+df --output=size "$mount_dir" |tee df2
+# fs size is changed
+not diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, ext4, active, unmounted, --fs resize_fsadm
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# lvreduce runs resize2fs to shrink the fs
+lvreduce --fs resize_fsadm -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "256.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size is changed
+not diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+#
+# lvreduce, xfs (xfs does not support shrinking)
+#
+
+# lvreduce, xfs, active, mounted, no --fs setting is same as --fs checksize
+# fs smaller than the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+lvreduce -L216M $vg/$lv
+check lv_field $vg/$lv lv_size "216.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, xfs, active, mounted, no --fs setting is same as --fs checksize
+# fs equal to the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# fs is 200M, reduced size is 200M, so no fs reduce is needed
+lvreduce -L200M $vg/$lv
+check lv_field $vg/$lv lv_size "200.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, xfs, active, mounted, no --fs setting is same as --fs checksize
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce fails because fs needs to be reduced
+not lvreduce -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, xfs, active, unmounted, no --fs setting is same as --fs checksize
+# fs smaller than the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+lvreduce -L216M $vg/$lv
+check lv_field $vg/$lv lv_size "216.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, xfs, active, mounted, --fs resize
+# fs smaller than the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+lvreduce -L216M $vg/$lv
+check lv_field $vg/$lv lv_size "216.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, xfs, active, mounted, --fs resize
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+# lvreduce fails because xfs cannot shrink
+not lvreduce --yes --fs resize -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, xfs, active, unmounted, --fs resize*
+# fs larger than the reduced size, fs not using reduced space
+lvcreate -n $lv -L 456M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+# lvreduce fails because xfs cannot shrink
+not lvreduce --yes --fs resize -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce --yes --fs resize --fsmode manage -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce --yes --fs resize --fsmode nochange -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce --yes --fs resize --fsmode offline -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce --yes --fs resize_fsadm -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+not lvreduce --yes --resizefs -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, xfs, inactive, no --fs setting is same as --fs checksize
+# fs equal to the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+lvchange -an $vg/$lv
+# no fs reduce is needed
+lvreduce -L200M $vg/$lv
+check lv_field $vg/$lv lv_size "200.00m"
+lvchange -ay $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, xfs, inactive, no fs setting is same as --fs checksize
+# fs smaller than the reduced size
+lvcreate -n $lv -L 200M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+lvextend -L+256M $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=128 conv=fdatasync
+df --output=size "$mount_dir" |tee df1
+umount "$mount_dir"
+lvchange -an $vg/$lv
+# fs is 200M, reduced size is 216M, so no fs reduce is needed
+lvreduce -L216M $vg/$lv
+check lv_field $vg/$lv lv_size "216.00m"
+lvchange -ay $vg/$lv
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+df --output=size "$mount_dir" |tee df2
+# fs size unchanged
+diff df1 df2
+umount "$mount_dir"
+lvchange -an $vg/$lv
+lvremove $vg/$lv
+
+# lvreduce, xfs, inactive, no --fs setting is same as --fs checksize
+# fs larger than the reduced size
+lvcreate -n $lv -L 456M $vg
+mkfs.xfs "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+dd if=/dev/zero of="$mount_dir/zeros1" bs=1M count=100 conv=fdatasync
+umount "$mount_dir"
+lvchange -an $vg/$lv
+# lvreduce fails because fs needs to be reduced
+not lvreduce -L-200M $vg/$lv
+check lv_field $vg/$lv lv_size "456.00m"
+lvremove $vg/$lv
+
+vgremove -ff $vg
diff --git a/test/shell/lvresize-full.sh b/test/shell/lvresize-full.sh
index 1ad9f32b1..fe39f45df 100644
--- a/test/shell/lvresize-full.sh
+++ b/test/shell/lvresize-full.sh
@@ -69,7 +69,10 @@ grep -v "20000 blocks" out
 
 # Also check it fails when the user 'resize' volume without
 # resizing fs and then retries with '-r'.
-lvreduce -f -l50%VG $vg/$lv1
-fail lvresize -r -f -l50%VG $vg/$lv1
+# The first lvreduce intentionally ignores the fs and intentionally
+# corrupts the fs so that the second lvresize will fail when it runs
+# fsck.
+lvreduce -f --fs ignore -l50%VG $vg/$lv1
+fail lvresize -r -f -l20%VG $vg/$lv1
 
 lvremove -ff $vg
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index 61e4491bd..ee23f7f24 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -29,7 +29,7 @@ for deactivate in true false; do
 	check mirror_images_contiguous $vg $lv1
 
 # reduce 2-way mirror
-	lvreduce -f -l-2 $vg/$lv1
+	lvreduce -f --fs ignore -l-2 $vg/$lv1
 	check mirror $vg $lv1 "$dev3"
 
 # extend 2-way mirror (cling if not contiguous)
diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index 0cdce558f..c2251eb06 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -52,7 +52,7 @@ lvcreate -an -Zn -l1 -n $lv1 -i3 $vg
 lvextend -l+100%FREE -i3 $vg/$lv1
 check vg_field $vg vg_free_count 2
 
-lvreduce -f -l50%LV $vg/$lv1
+lvreduce -f --fs ignore -l50%LV $vg/$lv1
 vgremove -f $vg
 
 vgcreate $SHARED -s 4M $vg "$dev1" "$dev2" "$dev3"
@@ -72,21 +72,21 @@ lvextend -l+100%FREE $vg/lv
 check vg_field $vg vg_free_count 0
 
 # Rounds up and should reduce just by 3 extents
-lvreduce -f -l-4 $vg/lv
+lvreduce -f --fs ignore -l-4 $vg/lv
 check vg_field $vg vg_free_count 3
 
 # Should round up to 15 extents
 lvextend -f -l+1 $vg/lv
 check vg_field $vg vg_free_count 0
 
-lvreduce -f -l-4 $vg/lv
+lvreduce -f --fs ignore -l-4 $vg/lv
 check vg_field $vg vg_free_count 3
 
 lvextend -l90%VG $vg/lv
 check vg_field $vg vg_free_count 0
 
-not lvreduce -f -l-10%LV $vg/lv
+not lvreduce -f --fs ignore -l-10%LV $vg/lv
 check vg_field $vg vg_free_count 0
 
-lvreduce -f -l-20%LV $vg/lv
+lvreduce -f --fs ignore -l-20%LV $vg/lv
 check vg_field $vg vg_free_count 3
diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
index ac6fe53b0..6be75259a 100644
--- a/test/shell/relative-sign-options.sh
+++ b/test/shell/relative-sign-options.sh
@@ -34,8 +34,8 @@ lvresize -y -l8 $vg/$lv1
 lvresize -y -L16 $vg/$lv1
 lvresize -y -l+1 $vg/$lv1
 lvresize -y -L+1 $vg/$lv1
-lvresize -y -l-1 $vg/$lv1
-lvresize -y -L-1 $vg/$lv1
+lvresize -y --fs ignore -l-1 $vg/$lv1
+lvresize -y --fs ignore -L-1 $vg/$lv1
 
 lvcreate -an -n $lv2 -l4 $vg
 lvextend -y -l8 $vg/$lv2
@@ -46,12 +46,12 @@ not lvextend -y -l-1 $vg/$lv2
 not lvextend -y -L-1 $vg/$lv2
 
 lvcreate -an -n $lv3 -l64 $vg
-lvreduce -y -l32 $vg/$lv3
-lvreduce -y -L8 $vg/$lv3
-lvreduce -y -l-1 $vg/$lv3
-lvreduce -y -L-1 $vg/$lv3
-not lvreduce -y -l+1 $vg/$lv3
-not lvreduce -y -L+1 $vg/$lv3
+lvreduce -y --fs ignore -l32 $vg/$lv3
+lvreduce -y --fs ignore -L8 $vg/$lv3
+lvreduce -y --fs ignore -l-1 $vg/$lv3
+lvreduce -y --fs ignore -L-1 $vg/$lv3
+not lvreduce -y --fs ignore -l+1 $vg/$lv3
+not lvreduce -y --fs ignore -L+1 $vg/$lv3
 
 # relative with percent extents
 
diff --git a/tools/args.h b/tools/args.h
index 85dd11aeb..a7a0dd3d9 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -301,6 +301,32 @@ arg(foreign_ARG, '\0', "foreign", 0, 0, 0,
     "Report/display foreign VGs that would otherwise be skipped.\n"
     "See \\fBlvmsystemid\\fP(7) for more information about foreign VGs.\n")
 
+arg(fs_ARG, '\0', "fs", string_VAL, 0, 0,
+    "Control file system resizing when resizing an LV.\n"
+    "\\fBchecksize\\fP: Check the fs size and reduce the LV if the fs is not\n"
+    "using the reduced space (fs reduce is not needed.) If the reduced space\n"
+    "is used by the fs, then do not resize the fs or LV, and return an error.\n"
+    "(checksize only applies when reducing, and does nothing for extend.)\n"
+    "\\fBresize\\fP: Resize the fs by calling the fs-specific resize command.\n"
+    "This may also include mounting, unmounting, or running fsck. See --fsmode to\n"
+    "control mounting behavior, and --nofsck to disable fsck.\n"
+    "\\fBresize_fsadm\\fP: Use the old method of calling fsadm to handle the fs\n"
+    "(deprecated.) Warning: this option does not prevent lvreduce from destroying\n"
+    "file systems that are unmounted (or mounted if prompts are skipped.)\n"
+    "\\fBignore\\fP: Resize the LV without checking for or handling a file system.\n"
+    "Warning: using ignore when reducing the LV size may destroy the file system.\n")
+
+arg(fsmode_ARG, '\0', "fsmode", string_VAL, 0, 0,
+    "Control file system mounting behavior for fs resize.\n"
+    "\\fBmanage\\fP: Mount or unmount the fs as needed to resize the fs,\n"
+    "and attempt to restore the original mount state at the end.\n"
+    "\\fBnochange\\fP: Do not mount or unmount the fs. If mounting or unmounting\n"
+    "is required to resize the fs, then do not resize the fs or the LV and fail\n"
+    "the command.\n"
+    "\\fBoffline\\fP: Unmount the fs if it is mounted, and resize the fs while it\n"
+    "is unmounted. If mounting is required to resize the fs, then do not resize\n"
+    "the fs or the LV and fail the command.\n")
+
 arg(handlemissingpvs_ARG, '\0', "handlemissingpvs", 0, 0, 0,
     "Allows a polling operation to continue when PVs are missing,\n"
     "e.g. for repairs due to faulty devices.\n")
@@ -1384,9 +1410,7 @@ arg(name_ARG, 'n', "name", string_VAL, 0, 0,
     "Move only PVs used by the named LV.\n")
 
 arg(nofsck_ARG, 'n', "nofsck", 0, 0, 0,
-    "Do not perform fsck before resizing filesystem when filesystem\n"
-    "requires it. You may need to use --force to proceed with\n"
-    "this option.\n")
+    "Do not perform fsck when resizing the file system with --resizefs.\n")
 
 arg(novolumegroup_ARG, 'n', "novolumegroup", 0, 0, 0,
     "Only show PVs not belonging to any VG.\n")
@@ -1452,7 +1476,10 @@ arg(readahead_ARG, 'r', "readahead", readahead_VAL, 0, 0,
     "\\fBnone\\fP is equivalent to zero.\n")
 
 arg(resizefs_ARG, 'r', "resizefs", 0, 0, 0,
-    "Resize underlying filesystem together with the LV using \\fBfsadm\\fP(8).\n")
+    "Resize the fs using the fs-specific resize command.\n"
+    "May include mounting, unmounting, or running fsck. See --fsmode to control\n"
+    "mounting behavior, and --nofsck to disable fsck. See --fs for more options\n"
+    "(--resizefs is equivalent to --fs resize.)\n")
 
 /* Not used */
 arg(reset_ARG, 'R', "reset", 0, 0, 0, NULL)
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 0cb9425c1..ec61d3b7d 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1380,7 +1380,7 @@ lvextend --size PSizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors Number,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
 --stripes Number, --stripesize SizeKB, --poolmetadatasize PSizeMB,
---type SegType
+--type SegType, --fs String, --fsmode String
 OP: PV ...
 ID: lvextend_size
 DESC: Extend an LV by a specified size.
@@ -1389,7 +1389,7 @@ lvextend LV PV ...
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors Number,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --resizefs, --stripes Number, --stripesize SizeKB,
---type SegType
+--type SegType, --fs String, --fsmode String
 ID: lvextend_pv
 DESC: Extend an LV by specified PV extents.
 
@@ -1406,7 +1406,7 @@ lvextend --usepolicies LV_snapshot_thinpool_vdopool
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors Number,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --resizefs,
---type SegType
+--type SegType, --fs String, --fsmode String
 OP: PV ...
 ID: lvextend_policy
 DESC: Extend an LV according to a predefined policy.
@@ -1455,7 +1455,7 @@ DESC: Remove the devices file entry for the given PVID.
 
 lvreduce --size NSizeMB LV
 OO: --autobackup Bool, --force, --nofsck, --noudevsync,
---reportformat ReportFmt, --resizefs
+--reportformat ReportFmt, --resizefs, --fs String, --fsmode String
 ID: lvreduce_size
 
 ---
@@ -1485,7 +1485,7 @@ lvresize --size SSizeMB LV
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
 --stripes Number, --stripesize SizeKB, --poolmetadatasize PSizeMB,
---type SegType
+--type SegType, --fs String, --fsmode String
 OP: PV ...
 ID: lvresize_size
 DESC: Resize an LV by a specified size.
@@ -1494,7 +1494,7 @@ lvresize LV PV ...
 OO: --alloc Alloc, --autobackup Bool, --force,
 --nofsck, --nosync, --noudevsync,
 --reportformat ReportFmt, --resizefs, --stripes Number, --stripesize SizeKB,
---type SegType
+--type SegType, --fs String, --fsmode String
 ID: lvresize_pv
 DESC: Resize an LV by specified PV extents.
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index a7148e52c..bba8ee26c 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -19,6 +19,7 @@ static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 {
 	const char *type_str = arg_str_value(cmd, type_ARG, NULL);
 	int only_linear = 0;
+	int set_fsopt = 0;
 	int set_extents_and_size = 0;
 
 	memset(lp, 0, sizeof(struct lvresize_params));
@@ -54,35 +55,31 @@ static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 		lp->percent = PERCENT_PVS;
 		lp->sign = SIGN_PLUS;
 		lp->poolmetadata_size = 0;
-		lp->resizefs = arg_is_set(cmd, resizefs_ARG);
-		lp->nofsck = arg_is_set(cmd, nofsck_ARG);
+		set_fsopt = 1;
 		break;
 
 	case lvextend_size_CMD:
 		lp->resize = LV_EXTEND;
-		lp->resizefs = arg_is_set(cmd, resizefs_ARG);
-		lp->nofsck = arg_is_set(cmd, nofsck_ARG);
 		if ((lp->poolmetadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, 0)))
 			lp->poolmetadata_sign = arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE);
 		set_extents_and_size = 1;
+		set_fsopt = 1;
 		break;
 
 	case lvreduce_size_CMD:
 		lp->resize = LV_REDUCE;
 		lp->poolmetadata_size = 0;
-		lp->resizefs = arg_is_set(cmd, resizefs_ARG);
-		lp->nofsck = arg_is_set(cmd, nofsck_ARG);
 		set_extents_and_size = 1;
+		set_fsopt = 1;
 		break;
 
 	case lvresize_size_CMD:
 		lp->resize = LV_ANY;
 		lp->poolmetadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, 0);
-		lp->resizefs = arg_is_set(cmd, resizefs_ARG);
-		lp->nofsck = arg_is_set(cmd, nofsck_ARG);
 		if ((lp->poolmetadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, 0)))
 			lp->poolmetadata_sign = arg_sign_value(cmd, poolmetadatasize_ARG, SIGN_NONE);
 		set_extents_and_size = 1;
+		set_fsopt = 1;
 		break;
 
 	default:
@@ -90,6 +87,67 @@ static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 		return 0;
 	};
 
+	if (set_fsopt) {
+		const char *str;
+
+		if (arg_is_set(cmd, resizefs_ARG) && arg_is_set(cmd, fs_ARG)) {
+			log_error("Options --fs and --resizefs cannot be used together.");
+			log_error("--resizefs is equivalent to --fs resize.");
+			return 0;
+		}
+
+		if ((str = arg_str_value(cmd, fs_ARG, NULL))) {
+			if (!strcmp(str, "checksize") ||
+			    !strcmp(str, "resize") ||
+			    !strcmp(str, "resize_fsadm")) {
+				strncpy(lp->fsopt, str, sizeof(lp->fsopt)-1);
+			} else if (!strcmp(str, "ignore")) {
+				lp->fsopt[0] = '\0';
+			} else {
+				log_error("Unknown --fs value.");
+				return 0;
+			}
+			lp->user_set_fs = 1;
+		} else if (arg_is_set(cmd, resizefs_ARG)) {
+			/* --resizefs alone equates to --fs resize */
+			strncpy(lp->fsopt, "resize", sizeof(lp->fsopt)-1);
+			lp->user_set_fs = 1;
+		} else {
+			/*
+			 * Use checksize when no fs option is specified.
+			 * checksize with extend does nothing: the LV
+			 * is extended and any fs is ignored.
+			 * checksize with reduce checks for an fs that
+			 * needs reducing: the LV is reduced only if the
+			 * fs does not need to be reduced (or no fs.)
+			 */
+			strncpy(lp->fsopt, "checksize", sizeof(lp->fsopt)-1);
+		}
+
+		if (lp->fsopt[0])
+			lp->nofsck = arg_is_set(cmd, nofsck_ARG);
+
+		if (!strcmp(lp->fsopt, "resize_fsadm") && arg_is_set(cmd, fsmode_ARG)) {
+			log_error("The --fsmode option does not apply to resize_fsadm.");
+			return 0;
+		}
+
+		if ((str = arg_str_value(cmd, fsmode_ARG, NULL))) {
+			if (!strcmp(str, "nochange") ||
+			    !strcmp(str, "offline") ||
+			    !strcmp(str, "manage")) {
+				strncpy(lp->fsmode, str, sizeof(lp->fsmode)-1);
+				lp->user_set_fsmode = 1;
+			} else {
+				log_error("Unknown --fsmode value.");
+				return 0;
+			}
+		} else {
+			/* Use manage when no fsmode option is specified. */
+			strncpy(lp->fsmode, "manage", sizeof(lp->fsmode)-1);
+		}
+	}
+
 	if (set_extents_and_size) {
 		if ((lp->extents = arg_uint_value(cmd, extents_ARG, 0))) {
 			lp->sign = arg_sign_value(cmd, extents_ARG, 0);
@@ -121,6 +179,17 @@ static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 			return_0;
 	}
 
+	if ((lp->resize == LV_REDUCE) &&
+	    (type_str ||
+	     arg_is_set(cmd, mirrors_ARG) ||
+	     arg_is_set(cmd, stripes_ARG) ||
+	     arg_is_set(cmd, stripesize_ARG))) {
+		/* should be obvious since reduce doesn't alloc space. */
+		log_print_unless_silent("Ignoring type, stripes, stripesize and mirrors "
+					"arguments when reducing.");
+		goto out;
+	}
+
 	if (arg_is_set(cmd, mirrors_ARG)) {
 		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) != SIGN_NONE) {
 			log_error("Mirrors argument may not be signed.");
@@ -146,7 +215,7 @@ static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 		log_error("Stripesize may not be negative.");
 		return 0;
 	}
-
+out:
 	return 1;
 }
 
@@ -237,6 +306,7 @@ static int _lvresize_single(struct cmd_context *cmd, struct logical_volume *lv,
 			    struct processing_handle *handle)
 {
 	struct lvresize_params *lp = (struct lvresize_params *) handle->custom_handle;
+	int ret;
 
 	if (cmd->position_argc > 1) {
 		/* First pos arg is required LV, remaining are optional PVs. */
@@ -245,11 +315,13 @@ static int _lvresize_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else
 		lp->pvh = &lv->vg->pvs;
 
-	if (!lv_resize(cmd, lv, lp))
-		return ECMD_FAILED;
+	ret = lv_resize(cmd, lv, lp);
 
-	log_print_unless_silent("Logical volume %s successfully resized.",
-				display_lvname(lv));
+	if (ret || lp->extend_fs_error)
+		log_print_unless_silent("Logical volume %s successfully resized.",
+					display_lvname(lv));
+	if (!ret)
+		return ECMD_FAILED;
 	return ECMD_PROCESSED;
 }
 
@@ -279,6 +351,7 @@ int lvresize_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
 	struct lvresize_params lp;
+	int retries = 0;
 	int ret;
 
 	if (!_lvresize_params(cmd, &lp))
@@ -289,9 +362,25 @@ int lvresize_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &lp;
 
+retry:
 	ret = process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
 			      handle, NULL, &_lvresize_single);
 
+	/*
+	 * The VG can be changed by another command while it is unlocked
+	 * during fs resize.  The fs steps likely succeeded, and this
+	 * retry will likely find that no more fs steps are needed, and
+	 * will resize the LV directly.
+	 */
+	if (lp.vg_changed_error && !retries) {
+		lp.vg_changed_error = 0;
+		retries = 1;
+		goto retry;
+	} else if (lp.vg_changed_error && retries) {
+		log_error("VG changed during file system resize, LV not resized.");
+		ret = ECMD_FAILED;
+	}
+
 	destroy_processing_handle(cmd, handle);
 
 	if (lp.lockd_lv_refresh_path && !lockd_lv_refresh(cmd, &lp))

