From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:07 -0500
Subject: master - activation: automaticaly discover pvmove holders
Message-ID: <201711241511.vAOFB7Ti000386@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a6981a6976368f633942a13cf007b141b2ece0a
Commit:        2a6981a6976368f633942a13cf007b141b2ece0a
Parent:        ddbe763eb81c5f9608ca9ff192bd33d9d37acd77
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 24 13:55:42 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:09:59 2017 +0100

activation: automaticaly discover pvmove holders

When pvmove is finished and does 'suspend/resume' on PVMOVE LV,
on resume path committed metadata are already showing 'standalone'
pvmove LV prepared just for removal.

However code should be able to 'resume' preloaded LV there were
participating in pvmove operation.

Previously this was all done in the 'tools' part of lvm2 code.
So the lvconvert upon pvmove finish had to explicitely call 'resume' on every such LV.
Now 'smarted' activation code is able to deduce and combine all information from
the active dm table and committed metadata so single  call resolves
it all in one go.

Internally holders are detected by reading sysfs directory to capture
all needed UUID which are then looked in lvm2 metadata and all such
LVs are automatically collected into dmtree.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |  108 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 109 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f29a498..c27db7c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Activation code for pvmove automatically discovers holding LVs for resume.
   Make a pvmove LV locking holder.
   Do not change critical section counter on resume path without real resume.
   Enhance activation code to automatically suspend pvmove participants.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1ca3baa..76fc546 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -26,6 +26,7 @@
 #include "activate.h"
 #include "lvm-exec.h"
 #include "str_list.h"
+#include "dm-ioctl.h" /* for DM_UUID_LEN */
 
 #include <limits.h>
 #include <dirent.h>
@@ -1717,6 +1718,104 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, const struct logical_vol
 	return udev_flags;
 }
 
+static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
+			    const struct logical_volume *lv, int origin_only);
+/*
+ * Add exiting devices which holds given LV device open.
+ * This is used in case when metadata already do not contain information
+ * i.e. PVMOVE is being finished and final table is going to be resumed.
+ */
+static int _add_holders_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
+				 const struct logical_volume *lv, struct dm_info *info)
+{
+	const char *default_uuid_prefix = dm_uuid_prefix();
+	const size_t default_uuid_prefix_len = strlen(default_uuid_prefix);
+	const char *sysfs_dir = dm_sysfs_dir();
+	char sysfs_path[PATH_MAX];
+	char uuid_path[PATH_MAX];
+	char uuid_buf[DM_UUID_LEN + 1];
+	char *uuid;
+	struct dirent *dirent;
+	DIR *d;
+	FILE *fp;
+	struct logical_volume *lv_det;
+	int r = 0;
+
+	/* Sysfs path of holders */
+	if (dm_snprintf(sysfs_path, sizeof(sysfs_path), "%sdev/block/" FMTu32
+			":" FMTu32 "/holders", sysfs_dir, info->major, info->minor) < 0) {
+		log_error("sysfs_path dm_snprintf failed.");
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
+		/* Determine path where sysfs holds UUID for holding dm device */
+		if (dm_snprintf(uuid_path, sizeof(uuid_path), "%s/%s/dm/uuid",
+				sysfs_path, dirent->d_name) < 0) {
+			log_error("uuid_path dm_snprintf failed.");
+			goto out;
+		}
+
+		if (!(fp = fopen(uuid_path, "r"))) {
+			log_sys_error("fopen", uuid_path);
+			goto out;
+		}
+
+		if (!fgets(uuid_buf, sizeof(uuid_buf), fp)) {
+			log_sys_error("fgets", uuid_path);
+			fclose(fp);
+			goto out;
+		}
+
+		if (fclose(fp))
+			log_sys_debug("fclose", uuid_path);
+
+		uuid = uuid_buf;
+		log_debug_activation("Checking holder of LV %s with uuid %s.",
+				     display_lvname(lv), uuid);
+
+		/* Skip common uuid LVM prefix */
+		if (!strncmp(default_uuid_prefix, uuid, default_uuid_prefix_len))
+			uuid += default_uuid_prefix_len;
+
+		/* Check holder comes from processed VG and is not yet in dmtree */
+		if (!strncmp(uuid, (char*)&lv->vg->id, sizeof(lv->vg->id)) &&
+		    !dm_tree_find_node_by_uuid(dtree, uuid)) {
+			uuid[2 * sizeof(struct id)] = 0; /* Cut any suffix */
+			/* If UUID is not yet in dtree, look for matching LV */
+			if (!(lv_det = find_lv_in_vg_by_lvid(lv->vg, (union lvid*)uuid))) {
+				log_error("Cannot find holding uuid %s in VG %s.",
+					  uuid, lv->vg->name);
+				goto out;
+			}
+
+			if (lv_is_cow(lv_det))
+				lv_det = origin_from_cow(lv_det);
+			log_debug_activation("Found holder %s of %s.",
+					     display_lvname(lv_det),
+					     display_lvname(lv));
+			if (!_add_lv_to_dtree(dm, dtree, lv_det, 0))
+				goto_out;
+		}
+	}
+
+	r = 1;
+out:
+	if (closedir(d))
+		log_sys_error("closedir", "holders");
+
+	return r;
+}
+
 static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			     const struct logical_volume *lv, const char *layer)
 {
@@ -1771,6 +1870,15 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			return_0;
 	}
 
+	/*
+	 * Find holders of existing active LV where name starts with 'pvmove',
+	 * but it's not anymore PVMOVE LV and also it's not PVMOVE _mimage
+	 */
+	if (info.exists && !lv_is_pvmove(lv) &&
+	    !strchr(lv->name, '_') && !strncmp(lv->name, "pvmove", 6))
+		if (!_add_holders_to_dtree(dm, dtree, lv, &info))
+			return_0;
+
 	return 1;
 }
 


