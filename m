From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 Feb 2023 22:58:41 +0000 (GMT)
Subject: main - lvresize: fix check for mounted and renamed LV to handle spaces
Message-ID: <20230223225841.6AB993858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1857eb9fe08924c2e4e5adfc322ee4a2ae5a2e67
Commit:        1857eb9fe08924c2e4e5adfc322ee4a2ae5a2e67
Parent:        86ac529b99d04cb7feb9b52fae3cbeda6144660c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 23 16:32:37 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 23 16:55:36 2023 -0600

lvresize: fix check for mounted and renamed LV to handle spaces

Replace spaces with \040 in directory paths from getmntent (mtab).

The recent commit 5374a44c5712 compares mount point directory paths
from /etc/mtab and /proc/mounts, in order to detect when a mounted
LV has been renamed.  The directory path comparison does not work
correctly when the path contains spaces because getmntent uses
ascii space chars and proc replaces spaces with \040.
---
 lib/device/filesystem.c   | 41 ++++++++++++++++++++++++++++++++---------
 test/shell/lvresize-fs.sh | 14 ++++++++++++++
 2 files changed, 46 insertions(+), 9 deletions(-)

diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index 9b086d8c1..2163276ed 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -234,8 +234,9 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 	char proc_fstype[FSTYPE_MAX];
 	char proc_devpath[PATH_MAX];
 	char proc_mntpath[PATH_MAX];
-	char lv_mapper_path[PATH_MAX];
-	char mntent_mount_dir[PATH_MAX];
+	char mtab_mntpath[PATH_MAX];
+	char dm_devpath[PATH_MAX];
+	char tmp_path[PATH_MAX];
 	char *dm_name;
 	struct stat st_lv;
 	struct stat stme;
@@ -275,14 +276,36 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 			continue;
 		if (stme.st_dev != st_lv.st_rdev)
 			continue;
-		dm_strncpy(mntent_mount_dir, me->mnt_dir, sizeof(mntent_mount_dir));
+		dm_strncpy(mtab_mntpath, me->mnt_dir, sizeof(mtab_mntpath));
+		break;
 	}
 	endmntent(fme);
 
+	/*
+	 * In mtab dir path, replace each ascii space character with the
+	 * four characters \040 which is how /proc/mounts represents spaces.
+	 * The mnt dir from /etc/mtab and /proc/mounts are compared below.
+	 */
+	if (strchr(mtab_mntpath, ' ')) {
+		int i, j = 0;
+		memcpy(tmp_path, mtab_mntpath, sizeof(tmp_path));
+		memset(mtab_mntpath, 0, sizeof(mtab_mntpath));
+		for (i = 0; i < sizeof(tmp_path); i++) {
+			if (tmp_path[i] == ' ') {
+				mtab_mntpath[j++] = '\\';
+				mtab_mntpath[j++] = '0';
+				mtab_mntpath[j++] = '4';
+				mtab_mntpath[j++] = '0';
+				continue;
+			}
+			mtab_mntpath[j++] = tmp_path[i];
+		}
+	}
+
 	if (!(dm_name = dm_build_dm_name(cmd->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
-	if ((dm_snprintf(lv_mapper_path, sizeof(lv_mapper_path), "%s/%s", dm_dir(), dm_name) < 0))
+	if ((dm_snprintf(dm_devpath, sizeof(dm_devpath), "%s/%s", dm_dir(), dm_name) < 0))
 		return_0;
 
 	if (!(fp = fopen("/proc/mounts", "r")))
@@ -296,8 +319,8 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 		if (strcmp(fstype, proc_fstype))
 			continue;
 
-		dir_match = !strcmp(mntent_mount_dir, proc_mntpath);
-		dev_match = !strcmp(lv_mapper_path, proc_devpath);
+		dir_match = !strcmp(mtab_mntpath, proc_mntpath);
+		dev_match = !strcmp(dm_devpath, proc_devpath);
 
 		if (dir_match)
 			found_dir++;
@@ -306,7 +329,7 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 
 		if (dir_match != dev_match) {
 			log_error("LV %s mounted@%s may have been renamed (from %s).",
-				  lv_mapper_path, proc_mntpath, proc_devpath);
+				  dm_devpath, proc_mntpath, proc_devpath);
 			renamed = 1;
 		}
 	}
@@ -327,11 +350,11 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 	}
 	/* These two are likely detected as renamed, but include checks in case. */
 	if (found_dir > 1) {
-		log_error("File system resizing not supported: %s appears more than once in /proc/mounts.", mntent_mount_dir);
+		log_error("File system resizing not supported: %s appears more than once in /proc/mounts.", mtab_mntpath);
 		return 1;
 	}
 	if (found_dev > 1) {
-		log_error("File system resizing not supported: %s appears more than once in /proc/mounts.", lv_mapper_path);
+		log_error("File system resizing not supported: %s appears more than once in /proc/mounts.", dm_devpath);
 		return 1;
 	}
 	return 0;
diff --git a/test/shell/lvresize-fs.sh b/test/shell/lvresize-fs.sh
index f437652d6..de234aad5 100644
--- a/test/shell/lvresize-fs.sh
+++ b/test/shell/lvresize-fs.sh
@@ -30,6 +30,9 @@ which mkfs.xfs || skip
 mount_dir="mnt_lvresize_fs"
 mkdir -p "$mount_dir"
 
+mount_dir_space="other mnt dir"
+mkdir -p "$mount_dir_space"
+
 # Tests require a libblkid version that shows FSLASTBLOCK
 lvcreate -n $lv1 -L 300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
@@ -273,6 +276,17 @@ umount "$mount_dir"
 lvchange -an $vg/$lv2
 lvremove $vg/$lv2
 
+# lvextend|lvreduce, ext4, active, mounted, mount dir with space, --fs resize, renamed LV
+lvcreate -n $lv -L 256M $vg
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
+mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir_space"
+lvrename $vg/$lv $vg/$lv2
+not lvextend --fs resize -L+32M $vg/$lv2
+not lvreduce --fs resize -L-32M $vg/$lv2
+umount "$mount_dir_space"
+lvchange -an $vg/$lv2
+lvremove $vg/$lv2
+
 
 #
 # lvextend, xfs

