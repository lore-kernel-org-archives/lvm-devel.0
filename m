From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:27 +0000 (GMT)
Subject: main - filesystem: use PATH_MAX for linux paths
Message-ID: <20230213133127.083473881D1D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf0dc9a13cf365859e7dad3bb1ad02040925ae11
Commit:        cf0dc9a13cf365859e7dad3bb1ad02040925ae11
Parent:        615347da20f7ede98c3cc8b1fd0aaaae15603c6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 19:23:12 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 12 23:56:29 2023 +0100

filesystem: use PATH_MAX for linux paths

---
 lib/device/filesystem.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index c9cc7c553..9b086d8c1 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -232,10 +232,10 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 	FILE *fp;
 	char proc_line[PATH_MAX];
 	char proc_fstype[FSTYPE_MAX];
-	char proc_devpath[1024];
-	char proc_mntpath[1024];
-	char lv_mapper_path[1024];
-	char mntent_mount_dir[1024];
+	char proc_devpath[PATH_MAX];
+	char proc_mntpath[PATH_MAX];
+	char lv_mapper_path[PATH_MAX];
+	char mntent_mount_dir[PATH_MAX];
 	char *dm_name;
 	struct stat st_lv;
 	struct stat stme;
@@ -275,14 +275,14 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 			continue;
 		if (stme.st_dev != st_lv.st_rdev)
 			continue;
-		strncpy(mntent_mount_dir, me->mnt_dir, PATH_MAX-1);
+		dm_strncpy(mntent_mount_dir, me->mnt_dir, sizeof(mntent_mount_dir));
 	}
 	endmntent(fme);
 
 	if (!(dm_name = dm_build_dm_name(cmd->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
-	if ((dm_snprintf(lv_mapper_path, 1024, "%s/%s", dm_dir(), dm_name) < 0))
+	if ((dm_snprintf(lv_mapper_path, sizeof(lv_mapper_path), "%s/%s", dm_dir(), dm_name) < 0))
 		return_0;
 
 	if (!(fp = fopen("/proc/mounts", "r")))

