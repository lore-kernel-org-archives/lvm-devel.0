From: David Teigland <teigland@sourceware.org>
Date: Tue, 27 Sep 2022 20:46:36 +0000 (GMT)
Subject: main - lvresize: let env var set lvresize_fs_helper_path
Message-ID: <20220927204636.A8E1C3858404@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b39ad99325342f2cdc7a9944f11b6d6ae120febe
Commit:        b39ad99325342f2cdc7a9944f11b6d6ae120febe
Parent:        7f1ef25b46cc96a2f8dce5beac57362370274261
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 27 15:39:09 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 27 15:42:18 2022 -0500

lvresize: let env var set lvresize_fs_helper_path

---
 lib/device/filesystem.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index c53a377ea..bdc230175 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -24,6 +24,19 @@
 #include <mntent.h>
 #include <sys/ioctl.h>
 
+static const char *_lvresize_fs_helper_path;
+
+static const char *_get_lvresize_fs_helper_path(void)
+{
+	if (!_lvresize_fs_helper_path)
+		_lvresize_fs_helper_path = getenv("LVRESIZE_FS_HELPER_PATH");
+
+	if (!_lvresize_fs_helper_path)
+		_lvresize_fs_helper_path = LVRESIZE_FS_HELPER_PATH; /* from configure, usually in /usr/libexec */
+
+	return _lvresize_fs_helper_path;
+}
+
 /*
  * Set the path of the dm-crypt device, i.e. /dev/dm-N, that is using the LV.
  */
@@ -206,7 +219,7 @@ int crypt_resize_script(struct cmd_context *cmd, struct logical_volume *lv, stru
 	if (dm_snprintf(crypt_path, sizeof(crypt_path), "/dev/dm-%d", (int)MINOR(fsi->crypt_devt)) < 0)
 		return_0;
 
-	argv[0] = LVRESIZE_FS_HELPER_PATH; /* from configure, usually in /usr/libexec */
+	argv[0] = _get_lvresize_fs_helper_path();
 	argv[++args] = "--cryptresize";
 	argv[++args] = "--cryptpath";
 	argv[++args] = crypt_path;
@@ -257,7 +270,7 @@ int fs_reduce_script(struct cmd_context *cmd, struct logical_volume *lv, struct
 	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0)
 		return_0;
 
-	argv[0] = LVRESIZE_FS_HELPER_PATH; /* from configure, usually in /usr/libexec */
+	argv[0] = _get_lvresize_fs_helper_path();
 	argv[++args] = "--fsreduce";
 	argv[++args] = "--fstype";
 	argv[++args] = fsi->fstype;
@@ -346,7 +359,7 @@ int fs_extend_script(struct cmd_context *cmd, struct logical_volume *lv, struct
 	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0)
 		return_0;
 
-	argv[0] = LVRESIZE_FS_HELPER_PATH; /* from configure, usually in /usr/libexec */
+	argv[0] = _get_lvresize_fs_helper_path();
 	argv[++args] = "--fsextend";
 	argv[++args] = "--fstype";
 	argv[++args] = fsi->fstype;

