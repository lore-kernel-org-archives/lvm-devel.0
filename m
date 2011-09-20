From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Sep 2011 14:57:39 +0200
Subject: [PATCH 5/7][retry remove] Replace "info.open_count" test with "dm_device_has_holders" in lvremove code path
Message-ID: <4E788DC3.6090306@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 lib/activate/activate.c    |    2 +-
 lib/commands/toolcontext.c |    8 +++++---
 lib/metadata/lv_manip.c    |    2 +-
 libdm/libdm-deptree.c      |    2 +-
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ae769dd..3d854d1 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1437,7 +1437,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	}
 
 	if (lv_is_visible(lv)) {
-		if (info.open_count) {
+		if (dm_device_has_holders(info.major, info.minor)) {
 			log_error("LV %s/%s in use: not deactivating",
 				  lv->vg->name, lv->name);
 			goto out;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 859da2b..3dccc18 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -243,9 +243,6 @@ static int _process_config(struct cmd_context *cmd)
 		log_error("Device directory given in config file too long");
 		return 0;
 	}
-#ifdef DEVMAPPER_SUPPORT
-	dm_set_dev_dir(cmd->dev_dir);
-#endif
 
 	/* proc dir */
 	if (dm_snprintf(cmd->proc_dir, sizeof(cmd->proc_dir), "%s",
@@ -265,6 +262,11 @@ static int _process_config(struct cmd_context *cmd)
 	_get_sysfs_dir(cmd);
 	set_sysfs_dir_path(cmd->sysfs_dir);
 
+#ifdef DEVMAPPER_SUPPORT
+	dm_set_dev_dir(cmd->dev_dir);
+	dm_set_sysfs_dir(cmd->sysfs_dir);
+#endif
+
 	/* activation? */
 	cmd->default_settings.activation = find_config_tree_int(cmd,
 							   "global/activation",
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 61e84c1..3132d0e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3099,7 +3099,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	/* FIXME Ensure not referred to by another existing LVs */
 
 	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
-		if (info.open_count) {
+		if (info.exists && dm_device_has_holders(info.major, info.minor)) {
 			log_error("Can't remove open logical volume \"%s\"",
 				  lv->name);
 			return 0;
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 0db8de2..864723d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1185,7 +1185,7 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 			continue;
 
 		/* Also checking open_count in parent nodes of presuspend_node */
-		if (info.open_count ||
+		if (dm_device_has_holders(info.major, info.minor) ||
 		    (child->presuspend_node &&
 		     !_node_has_closed_parents(child->presuspend_node,
 					       uuid_prefix, uuid_prefix_len))) {


