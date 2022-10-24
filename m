From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Oct 2022 21:20:43 +0000 (GMT)
Subject: main - cmd: save device_id_sysfs_dir
Message-ID: <20221024212043.6A3CD385840C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=830ece75e80b1779de5e81e3424a8ee756f66f88
Commit:        830ece75e80b1779de5e81e3424a8ee756f66f88
Parent:        94dde5769984c5ede211d122cc7392a26f8dbef4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 24 16:15:53 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 24 16:20:28 2022 -0500

cmd: save device_id_sysfs_dir

read and save device_id_sysfs_dir to avoid spamming
debug output from find_config_tree_str.
---
 lib/commands/toolcontext.c | 1 +
 lib/commands/toolcontext.h | 1 +
 lib/device/device_id.c     | 4 +---
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 2666d7b42..b630554a9 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -643,6 +643,7 @@ static int _process_config(struct cmd_context *cmd)
 	if (!dm_set_uuid_prefix(UUID_PREFIX))
 		return_0;
 #endif
+	cmd->device_id_sysfs_dir = find_config_tree_str(cmd, devices_device_id_sysfs_dir_CFG, NULL);
 
 	dev_ext_info_src = find_config_tree_str(cmd, devices_external_device_info_source_CFG, NULL);
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index eb2d1922b..32bfda57a 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -247,6 +247,7 @@ struct cmd_context {
 	 * Paths.
 	 */
 	const char *lib_dir;			/* cache value global/library_dir */
+	const char *device_id_sysfs_dir;
 	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 252654861..34469e262 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -193,9 +193,7 @@ static int _read_sys_block(struct cmd_context *cmd, struct device *dev,
 	dev_t prim = 0;
 	int ret;
 
-	if (!(sysfs_dir = find_config_tree_str(cmd, devices_device_id_sysfs_dir_CFG, NULL)))
-		sysfs_dir = dm_sysfs_dir();
-
+	sysfs_dir = cmd->device_id_sysfs_dir ?: dm_sysfs_dir();
  retry:
 	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/%s",
 			sysfs_dir, (int)MAJOR(devt), (int)MINOR(devt), suffix) < 0) {

