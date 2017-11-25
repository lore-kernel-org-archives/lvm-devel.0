From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 25 Nov 2017 18:38:24 -0500
Subject: master - activation: enhance holders detection
Message-ID: <201711252338.vAPNcO2A005288@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c6fd0933fa4ee9b79ae5edbb90afe6a3d893b18
Commit:        8c6fd0933fa4ee9b79ae5edbb90afe6a3d893b18
Parent:        ce83162d7c7eae008935989a26dbf23dfb08d0f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 24 20:59:38 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 26 00:31:26 2017 +0100

activation: enhance holders detection

Use code which detectes handlers in a way, which is more
backward-compatible friendly.

Replace read of 'sysfs' uuid entry with dm ioctl call.

Use /sys/block/dm-X/holders path instead of
new path  /sys/dev/block/major:minor/holders.

TODO:
There are few more occurencies of this logic around the code
so some abstract interface should be considered.
---
 lib/activate/dev_manager.c |  128 ++++++++++++++++++++++++--------------------
 1 files changed, 69 insertions(+), 59 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 76fc546..429f4f6 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1720,81 +1720,52 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, const struct logical_vol
 
 static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			    const struct logical_volume *lv, int origin_only);
-/*
- * Add exiting devices which holds given LV device open.
- * This is used in case when metadata already do not contain information
- * i.e. PVMOVE is being finished and final table is going to be resumed.
- */
-static int _add_holders_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-				 const struct logical_volume *lv, struct dm_info *info)
+
+static int _check_holder(struct dev_manager *dm, struct dm_tree *dtree,
+			 const struct logical_volume *lv, uint32_t major,
+			 const char *d_name)
 {
 	const char *default_uuid_prefix = dm_uuid_prefix();
 	const size_t default_uuid_prefix_len = strlen(default_uuid_prefix);
-	const char *sysfs_dir = dm_sysfs_dir();
-	char sysfs_path[PATH_MAX];
-	char uuid_path[PATH_MAX];
-	char uuid_buf[DM_UUID_LEN + 1];
-	char *uuid;
-	struct dirent *dirent;
-	DIR *d;
-	FILE *fp;
+	const char *name;
+	const char *uuid;
+	struct dm_info info;
+	struct dm_task *dmt;
 	struct logical_volume *lv_det;
-	int r = 0;
+	union lvid id;
+	int dev, r = 0;
 
-	/* Sysfs path of holders */
-	if (dm_snprintf(sysfs_path, sizeof(sysfs_path), "%sdev/block/" FMTu32
-			":" FMTu32 "/holders", sysfs_dir, info->major, info->minor) < 0) {
-		log_error("sysfs_path dm_snprintf failed.");
-		return 0;
-	}
-
-	if (!(d = opendir(sysfs_path))) {
-		if (errno != ENOENT)
-			log_sys_error("opendir", sysfs_path);
+	errno = 0;
+	dev = strtoll(d_name + 3, NULL, 10);
+	if (errno) {
+		log_error("Failed to parse dm device minor number from %s.", d_name);
 		return 0;
 	}
 
-	while ((dirent = readdir(d))) {
-		if (!strcmp(dirent->d_name, ".") || !strcmp(dirent->d_name, ".."))
-			continue;
-
-		/* Determine path where sysfs holds UUID for holding dm device */
-		if (dm_snprintf(uuid_path, sizeof(uuid_path), "%s/%s/dm/uuid",
-				sysfs_path, dirent->d_name) < 0) {
-			log_error("uuid_path dm_snprintf failed.");
-			goto out;
-		}
-
-		if (!(fp = fopen(uuid_path, "r"))) {
-			log_sys_error("fopen", uuid_path);
-			goto out;
-		}
-
-		if (!fgets(uuid_buf, sizeof(uuid_buf), fp)) {
-			log_sys_error("fgets", uuid_path);
-			fclose(fp);
-			goto out;
-		}
+	if (!(dmt = _setup_task_run(DM_DEVICE_INFO, &info, NULL, NULL, NULL,
+				    major, dev, 0, 0, 0)))
+		return_0;
 
-		if (fclose(fp))
-			log_sys_debug("fclose", uuid_path);
+	if (info.exists) {
+		uuid = dm_task_get_uuid(dmt);
+		name = dm_task_get_name(dmt);
 
-		uuid = uuid_buf;
-		log_debug_activation("Checking holder of LV %s with uuid %s.",
-				     display_lvname(lv), uuid);
+		log_debug_activation("Checking holder of %s  %s (" FMTu32 ":" FMTu32 ") %s.",
+				     display_lvname(lv), uuid, info.major, info.minor,
+				     name);
 
-		/* Skip common uuid LVM prefix */
+		/* Skip common uuid prefix */
 		if (!strncmp(default_uuid_prefix, uuid, default_uuid_prefix_len))
 			uuid += default_uuid_prefix_len;
 
-		/* Check holder comes from processed VG and is not yet in dmtree */
 		if (!strncmp(uuid, (char*)&lv->vg->id, sizeof(lv->vg->id)) &&
 		    !dm_tree_find_node_by_uuid(dtree, uuid)) {
-			uuid[2 * sizeof(struct id)] = 0; /* Cut any suffix */
+			dm_strncpy((char*)&id, uuid, 2 * sizeof(struct id) + 1);
+
 			/* If UUID is not yet in dtree, look for matching LV */
-			if (!(lv_det = find_lv_in_vg_by_lvid(lv->vg, (union lvid*)uuid))) {
-				log_error("Cannot find holding uuid %s in VG %s.",
-					  uuid, lv->vg->name);
+			if (!(lv_det = find_lv_in_vg_by_lvid(lv->vg, &id))) {
+				log_error("Cannot find holder with device name %s in VG %s.",
+					  name, lv->vg->name);
 				goto out;
 			}
 
@@ -1808,10 +1779,49 @@ static int _add_holders_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		}
 	}
 
+        r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
+/*
+ * Add exiting devices which holds given LV device open.
+ * This is used in case when metadata already do not contain information
+ * i.e. PVMOVE is being finished and final table is going to be resumed.
+ */
+static int _add_holders_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
+				 const struct logical_volume *lv, struct dm_info *info)
+{
+	const char *sysfs_dir = dm_sysfs_dir();
+	char sysfs_path[PATH_MAX];
+	struct dirent *dirent;
+	DIR *d;
+	int r = 0;
+
+	/* Sysfs path of holders */
+	if (dm_snprintf(sysfs_path, sizeof(sysfs_path), "%sblock/dm-" FMTu32
+			"/holders", sysfs_dir, info->minor) < 0) {
+		log_error("sysfs_path dm_snprintf failed.");
+		return 0;
+	}
+
+	if (!(d = opendir(sysfs_path))) {
+		log_sys_error("opendir", sysfs_path);
+		return 0;
+	}
+
+	while ((dirent = readdir(d)))
+		/* Expects minor is added to 'dm-' prefix */
+		if (!strncmp(dirent->d_name, "dm-", 3) &&
+		    !_check_holder(dm, dtree, lv, info->major, dirent->d_name))
+			goto_out;
+
 	r = 1;
 out:
 	if (closedir(d))
-		log_sys_error("closedir", "holders");
+		log_sys_debug("closedir", "holders");
 
 	return r;
 }


