From: David Teigland <teigland@sourceware.org>
Date: Thu, 26 Jan 2023 20:30:45 +0000 (GMT)
Subject: main - lvresize: fail early if mounted LV was renamed
Message-ID: <20230126203045.32B613858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5374a44c57127cdd832a675545c1d2bbf0b3751a
Commit:        5374a44c57127cdd832a675545c1d2bbf0b3751a
Parent:        8adfcddc35be16ac1d1a00a169ec89a7f12d69af
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 26 14:00:00 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 26 14:02:20 2023 -0600

lvresize: fail early if mounted LV was renamed

If a mounted LV is renamed, then fs resizing utilities will fail,
so detect this condition and fail the command before any changes
are made.
---
 lib/device/filesystem.c   | 110 ++++++++++++++++++++++++++++++++++++++++++++++
 lib/device/filesystem.h   |   2 +
 lib/metadata/lv_manip.c   |   3 ++
 test/shell/lvresize-fs.sh |  11 +++++
 4 files changed, 126 insertions(+)

diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index b4c43a626..db507bdda 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -214,6 +214,116 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 	return ret;
 }
 
+int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *lv, char *lv_path, char *fstype)
+{
+	FILE *fp;
+	char proc_line[PATH_MAX];
+	char proc_fstype[FSTYPE_MAX];
+	char proc_devpath[1024];
+	char proc_mntpath[1024];
+	char lv_mapper_path[1024];
+	char mntent_mount_dir[1024];
+	char *dm_name;
+	struct stat st_lv;
+	struct stat stme;
+	FILE *fme = NULL;
+	struct mntent *me;
+	int renamed = 0;
+	int found_dir = 0;
+	int found_dev = 0;
+	int dev_match, dir_match;
+
+	if (stat(lv_path, &st_lv) < 0) {
+		log_error("Failed to get LV path %s", lv_path);
+		return 0;
+	}
+
+	/*
+	 * If LVs have been renamed while their file systems were mounted, then
+	 * inconsistencies appear in the device path and mount point info
+	 * provided by getmntent and /proc/mounts.  If there's any
+	 * inconsistency or duplication of info for the LV name or the mount
+	 * point, then give up and don't try fs resize which is likely to fail
+	 * due to kernel problems where mounts reference old device names
+	 * causing fs resizing tools to fail.
+	 */
+
+	if (!(fme = setmntent("/etc/mtab", "r")))
+		return_0;
+
+	while ((me = getmntent(fme))) {
+		if (strcmp(me->mnt_type, fstype))
+			continue;
+		if (me->mnt_dir[0] != '/')
+			continue;
+		if (me->mnt_fsname[0] != '/')
+			continue;
+		if (stat(me->mnt_dir, &stme) < 0)
+			continue;
+		if (stme.st_dev != st_lv.st_rdev)
+			continue;
+		strncpy(mntent_mount_dir, me->mnt_dir, PATH_MAX-1);
+	}
+	endmntent(fme);
+
+	if (!(dm_name = dm_build_dm_name(cmd->mem, lv->vg->name, lv->name, NULL)))
+		return_0;
+
+	if ((dm_snprintf(lv_mapper_path, 1024, "%s/%s", dm_dir(), dm_name) < 0))
+		return_0;
+
+	if (!(fp = fopen("/proc/mounts", "r")))
+		return_0;
+
+	while (fgets(proc_line, sizeof(proc_line), fp)) {
+		if (proc_line[0] != '/')
+			continue;
+		if (sscanf(proc_line, "%s %s %s", proc_devpath, proc_mntpath, proc_fstype) != 3)
+			continue;
+		if (strcmp(fstype, proc_fstype))
+			continue;
+
+		dir_match = !strcmp(mntent_mount_dir, proc_mntpath);
+		dev_match = !strcmp(lv_mapper_path, proc_devpath);
+
+		if (dir_match)
+			found_dir++;
+		if (dev_match)
+			found_dev++;
+
+		if (dir_match != dev_match) {
+			log_error("LV %s mounted@%s may have been renamed (from %s).",
+				  lv_mapper_path, proc_mntpath, proc_devpath);
+			renamed = 1;
+		}
+	}
+
+	if (fclose(fp))
+		stack;
+
+	/*
+	 * Don't try resizing if:
+	 * - different device names apppear for the mount point
+	 *   (LVs probably renamed while mounted), or
+	 * - the mount point for the LV appears multiple times, or
+	 * - the LV device is listed for multiple mounts. 
+	 */
+	if (renamed) {
+		log_error("File system resizing not supported: fs utilities do not support renamed devices.");
+		return 1;
+	}
+	/* These two are likely detected as renamed, but include checks in case. */
+	if (found_dir > 1) {
+		log_error("File system resizing not supported: %s appears more than once in /proc/mounts.", mntent_mount_dir);
+		return 1;
+	}
+	if (found_dev > 1) {
+		log_error("File system resizing not supported: %s appears more than once in /proc/mounts.", lv_mapper_path);
+		return 1;
+	}
+	return 0;
+}
+
 #define FS_CMD_MAX_ARGS 16
 
 int crypt_resize_script(struct cmd_context *cmd, struct logical_volume *lv, struct fs_info *fsi,
diff --git a/lib/device/filesystem.h b/lib/device/filesystem.h
index fd1af0416..77eac34d0 100644
--- a/lib/device/filesystem.h
+++ b/lib/device/filesystem.h
@@ -48,4 +48,6 @@ int fs_reduce_script(struct cmd_context *cmd, struct logical_volume *lv, struct
 		uint64_t newsize_bytes, char *fsmode);
 int crypt_resize_script(struct cmd_context *cmd, struct logical_volume *lv, struct fs_info *fsi,
 		uint64_t newsize_bytes_fs);
+
+int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *lv, char *lv_path, char *fstype);
 #endif
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cfb118f11..fa6393a48 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6939,6 +6939,9 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 			log_error("File system not found for --resizefs or --fs options.");
 			goto out;
 		}
+		/* FS utils will fail if LVs were renamed while mounted. */
+		if (fs_mount_state_is_misnamed(cmd, lv_top, lv_path, fstype))
+			goto_out;
 	}
 
 	/*
diff --git a/test/shell/lvresize-fs.sh b/test/shell/lvresize-fs.sh
index 0be6911a0..f437652d6 100644
--- a/test/shell/lvresize-fs.sh
+++ b/test/shell/lvresize-fs.sh
@@ -262,6 +262,17 @@ umount "$mount_dir"
 lvchange -an $vg/$lv
 lvremove $vg/$lv
 
+# lvextend|lvreduce, ext4, active, mounted, --fs resize, renamed LV
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
+lvrename $vg/$lv $vg/$lv2
+not lvextend --fs resize -L+32M $vg/$lv2
+not lvreduce --fs resize -L-32M $vg/$lv2
+umount "$mount_dir"
+lvchange -an $vg/$lv2
+lvremove $vg/$lv2
+
 
 #
 # lvextend, xfs

