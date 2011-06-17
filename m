From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 17 Jun 2011 14:39:37 +0200
Subject: [PATCH] lvm2: add configuration option to enable udev fallback code only when needed
Message-ID: <4DFB4B09.9080902@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We've used udev fallback code till now to check whether udev
created/removed the entries in /dev correctly and if not,
a repair was done (giving a warning messagea about that).

This patch adds a possibility to enable this additional check
and subsequent fallback only when required (debugging purposes
mostly) and trust udev completely.

So let's disable the fallback code by default and add a new
configuration option "activation/udev_fallback".

(The original code for creating the nodes will still be used
in case the device directory that is set in lvm.conf differs
from the one that udev uses and also when activation/udev_rules
is set to 0 - otherwise we would end up with no nodes/symlinks
at all)

Peter
---
 doc/example.conf.in        |    7 +++++++
 lib/activate/dev_manager.c |   15 +++++++++++++++
 lib/commands/toolcontext.c |   15 +++++++++++++++
 lib/commands/toolcontext.h |    1 +
 lib/config/defaults.h      |    1 +
 tools/lvmcmdline.c         |    7 +++++--
 6 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 3682b5e..b758463 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -428,6 +428,13 @@ activation {
     # while any logical volumes are active.
     udev_rules = 1
 
+    # Set to 1 to enable udev fallback. This will enable additional checks and
+    # possible repairs done on entries in the device directory after udev has
+    # completed processing the events. This is normally not needed if udev
+    # works correctly but it may be used in some problematic situations or
+    # for debugging purposes.
+    udev_fallback = 0
+
     # How to fill in missing stripes if activating an incomplete volume.
     # Using "error" will make inaccessible parts of the device return
     # I/O errors on access.  You can instead use a device path, in which 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3ca6c5b..65781ff 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -874,6 +874,13 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *l
 	uint16_t udev_flags = 0;
 
 	/*
+	 * Instruct also libdevmapper to disable udev
+	 * fallback in accordance to LVM2 settings.
+	 */
+	if (!dm->cmd->current_settings.udev_fallback)
+		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
+
+	/*
 	 * Is this top-level and visible device?
 	 * If not, create just the /dev/mapper content.
 	 */
@@ -1574,6 +1581,10 @@ static int _create_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 	const char *name;
 	int r = 1;
 
+	/* Nothing to do if udev fallback is disabled. */
+	if (!dm->cmd->current_settings.udev_fallback)
+		return 1;
+
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(lvlayer = dm_tree_node_get_context(child)))
 			continue;
@@ -1616,6 +1627,10 @@ static int _remove_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 	char *vgname, *lvname, *layer;
 	int r = 1;
 
+	/* Nothing to do if udev fallback is disabled. */
+	if (!dm->cmd->current_settings.udev_fallback)
+		return 1;
+
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!dm_split_lvm_name(dm->mem, dm_tree_node_get_name(child), &vgname, &lvname, &layer)) {
 			r = 0;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 918362c..73a7209 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -285,6 +285,21 @@ static int _process_config(struct cmd_context *cmd)
 								"activation/udev_sync",
 								DEFAULT_UDEV_SYNC);
 
+	#ifdef UDEV_SYNC_SUPPORT
+	/*
+	 * We need udev rules to be applied, otherwise we would end up with no
+	 * nodes and symlinks! However, we can disable the synchronization itself
+	 * in runtime and still have only udev to create the nodes and symlinks
+	 * without any fallback.
+	 */
+	cmd->default_settings.udev_fallback = cmd->default_settings.udev_rules ?
+					find_config_tree_int(cmd, "activation/udev_fallback",
+							     DEFAULT_UDEV_FALLBACK) : 1;
+	#else
+	/* We must use old node/symlink creation code if not compiled with udev support at all! */
+	cmd->default_settings.udev_fallback = 1;
+	#endif
+
 	cmd->stripe_filler = find_config_tree_str(cmd,
 						  "activation/missing_stripe_filler",
 						  DEFAULT_STRIPE_FILLER);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 1c3368e..fb28a03 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -36,6 +36,7 @@ struct config_info {
 	int read_ahead;		/* DM_READ_AHEAD_NONE or _AUTO */
 	int udev_rules;
 	int udev_sync;
+	int udev_fallback;
 	int cache_vgmetadata;
 	const char *msg_prefix;
 	const char *fmt_name;
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 452de3d..d9c0a1f 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -78,6 +78,7 @@
 #define DEFAULT_READ_AHEAD "auto"
 #define DEFAULT_UDEV_RULES 1
 #define DEFAULT_UDEV_SYNC 0
+#define DEFAULT_UDEV_FALLBACK 0
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
 #define DEFAULT_MAX_PV 0
 #define DEFAULT_MAX_LV 0
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3e13a27..d6b12cb 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -952,7 +952,7 @@ static void _apply_settings(struct cmd_context *cmd)
 	cmd->handles_missing_pvs = 0;
 }
 
-static int _set_udev_checking(struct cmd_context *cmd)
+static int _set_udev_fallback(struct cmd_context *cmd)
 {
 #ifdef UDEV_SYNC_SUPPORT
 	const char *udev_dev_dir;
@@ -984,6 +984,9 @@ static int _set_udev_checking(struct cmd_context *cmd)
 			   cmd->dev_dir, udev_dev_dir);
 		dm_udev_set_checking(0);
 		init_udev_checking(0);
+
+		/* Device directories differ - we must use the fallback code! */
+		cmd->current_settings.udev_fallback = 1;
 	}
 
 #endif
@@ -1088,7 +1091,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	log_debug("O_DIRECT will be used");
 #endif
 
-	if (!_set_udev_checking(cmd))
+	if (!_set_udev_fallback(cmd))
 		goto_out;
 
 	if ((ret = _process_common_commands(cmd))) {


