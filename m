From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Jun 2023 17:13:00 +0000 (GMT)
Subject: main - lvresize: fix multiple mounts
Message-ID: <20230616171300.CCFD73858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c3eca833ff7878d6d32198ed76380c91fdc15fc
Commit:        7c3eca833ff7878d6d32198ed76380c91fdc15fc
Parent:        228a8e8c1fd8e82a2e31a6060614dc3dd2f8bc51
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 16 12:06:40 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 16 12:11:51 2023 -0500

lvresize: fix multiple mounts

which was mistaken as a mounted LV that had been renamed.
---
 lib/device/filesystem.c | 47 ++++++++++++++++++++++++-----------------------
 1 file changed, 24 insertions(+), 23 deletions(-)

diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index 2572bca69..39e563117 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -243,8 +243,6 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 	FILE *fme = NULL;
 	struct mntent *me;
 	int renamed = 0;
-	int found_dir = 0;
-	int found_dev = 0;
 	int dev_match, dir_match;
 
 	if (stat(lv_path, &st_lv) < 0) {
@@ -281,6 +279,9 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 	}
 	endmntent(fme);
 
+	if (mtab_mntpath[0])
+		log_debug("%s mtab mntpath %s", display_lvname(lv), mtab_mntpath);
+
 	/*
 	 * In mtab dir path, replace each ascii space character with the
 	 * four characters \040 which is how /proc/mounts represents spaces.
@@ -319,15 +320,31 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 		if (strcmp(fstype, proc_fstype))
 			continue;
 
+		/*
+		 * When an LV is mounted on two dirs, it appears in /proc/mounts twice as
+		 * /dev/mapper/vg-lvol0 on /foo type xfs ...
+		 * /dev/mapper/vg-lvol0 on /bar type xfs ...
+		 * All entries match dm_devpath, one entry matches mntpath,
+		 * and other entries don't match mntpath.
+		 *
+		 * When an LV is mounted on one dir, and is renamed from lvol0 to lvol1,
+		 * it appears in /proc/mounts once as
+		 * /dev/mapper/vg-lvol0 on /foo type xfs ...
+		 */
+
 		dir_match = !strcmp(mtab_mntpath, proc_mntpath);
 		dev_match = !strcmp(dm_devpath, proc_devpath);
 
-		if (dir_match)
-			found_dir++;
-		if (dev_match)
-			found_dev++;
+		if (!dir_match && !dev_match)
+			continue;
+
+		if (dev_match && !dir_match) {
+			log_debug("LV %s mounted at %s also mounted at %s.",
+				  dm_devpath, mtab_mntpath, proc_mntpath);
+			continue;
+		}
 
-		if (dir_match != dev_match) {
+		if (!dev_match && dir_match) {
 			log_error("LV %s mounted@%s may have been renamed (from %s).",
 				  dm_devpath, proc_mntpath, proc_devpath);
 			renamed = 1;
@@ -337,26 +354,10 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 	if (fclose(fp))
 		stack;
 
-	/*
-	 * Don't try resizing if:
-	 * - different device names apppear for the mount point
-	 *   (LVs probably renamed while mounted), or
-	 * - the mount point for the LV appears multiple times, or
-	 * - the LV device is listed for multiple mounts. 
-	 */
 	if (renamed) {
 		log_error("File system resizing not supported: fs utilities do not support renamed devices.");
 		return 1;
 	}
-	/* These two are likely detected as renamed, but include checks in case. */
-	if (found_dir > 1) {
-		log_error("File system resizing not supported: %s appears more than once in /proc/mounts.", mtab_mntpath);
-		return 1;
-	}
-	if (found_dev > 1) {
-		log_error("File system resizing not supported: %s appears more than once in /proc/mounts.", dm_devpath);
-		return 1;
-	}
 	return 0;
 }
 

