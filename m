From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 17 Jun 2011 14:50:56 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/activ ...
Message-ID: <20110617145056.10755.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-06-17 14:50:54

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/activate   : dev_manager.c 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : defaults.h 
	tools          : lvmcmdline.c 

Log message:
	Disable udev fallback by default and add activation/udev_fallback to lvm.conf.
	
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

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2022&r2=1.2023
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.219&r2=1.220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143

--- LVM2/WHATS_NEW	2011/06/17 14:39:10	1.2022
+++ LVM2/WHATS_NEW	2011/06/17 14:50:53	1.2023
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Disable udev fallback by default and add activation/udev_fallback to lvm.conf.
   Call vg_mark_partial_lvs() before VG structure is returned from the cache.
   Remove unused internal flag ACTIVATE_EXCL from the code.
   Remove useless test of ACTIVATE_EXCL in lv_add_mirrors() clustered code path.
--- LVM2/doc/example.conf.in	2011/04/28 17:33:35	1.25
+++ LVM2/doc/example.conf.in	2011/06/17 14:50:53	1.26
@@ -428,6 +428,13 @@
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
--- LVM2/lib/activate/dev_manager.c	2011/06/17 14:22:48	1.219
+++ LVM2/lib/activate/dev_manager.c	2011/06/17 14:50:53	1.220
@@ -874,6 +874,13 @@
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
@@ -1584,6 +1591,10 @@
 	const char *name;
 	int r = 1;
 
+	/* Nothing to do if udev fallback is disabled. */
+	if (!dm->cmd->current_settings.udev_fallback)
+		return 1;
+
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(lvlayer = dm_tree_node_get_context(child)))
 			continue;
@@ -1626,6 +1637,10 @@
 	char *vgname, *lvname, *layer;
 	int r = 1;
 
+	/* Nothing to do if udev fallback is disabled. */
+	if (!dm->cmd->current_settings.udev_fallback)
+		return 1;
+
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!dm_split_lvm_name(dm->mem, dm_tree_node_get_name(child), &vgname, &lvname, &layer)) {
 			r = 0;
--- LVM2/lib/commands/toolcontext.c	2011/05/07 13:50:12	1.119
+++ LVM2/lib/commands/toolcontext.c	2011/06/17 14:50:54	1.120
@@ -285,6 +285,21 @@
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
--- LVM2/lib/commands/toolcontext.h	2011/05/07 13:50:12	1.43
+++ LVM2/lib/commands/toolcontext.h	2011/06/17 14:50:54	1.44
@@ -36,6 +36,7 @@
 	int read_ahead;		/* DM_READ_AHEAD_NONE or _AUTO */
 	int udev_rules;
 	int udev_sync;
+	int udev_fallback;
 	int cache_vgmetadata;
 	const char *msg_prefix;
 	const char *fmt_name;
--- LVM2/lib/config/defaults.h	2011/04/28 17:33:35	1.75
+++ LVM2/lib/config/defaults.h	2011/06/17 14:50:54	1.76
@@ -78,6 +78,7 @@
 #define DEFAULT_READ_AHEAD "auto"
 #define DEFAULT_UDEV_RULES 1
 #define DEFAULT_UDEV_SYNC 0
+#define DEFAULT_UDEV_FALLBACK 0
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
 #define DEFAULT_MAX_PV 0
 #define DEFAULT_MAX_LV 0
--- LVM2/tools/lvmcmdline.c	2011/05/07 13:50:11	1.142
+++ LVM2/tools/lvmcmdline.c	2011/06/17 14:50:54	1.143
@@ -952,7 +952,7 @@
 	cmd->handles_missing_pvs = 0;
 }
 
-static int _set_udev_checking(struct cmd_context *cmd)
+static int _set_udev_fallback(struct cmd_context *cmd)
 {
 #ifdef UDEV_SYNC_SUPPORT
 	const char *udev_dev_dir;
@@ -984,6 +984,9 @@
 			   cmd->dev_dir, udev_dev_dir);
 		dm_udev_set_checking(0);
 		init_udev_checking(0);
+
+		/* Device directories differ - we must use the fallback code! */
+		cmd->current_settings.udev_fallback = 1;
 	}
 
 #endif
@@ -1088,7 +1091,7 @@
 	log_debug("O_DIRECT will be used");
 #endif
 
-	if (!_set_udev_checking(cmd))
+	if (!_set_udev_fallback(cmd))
 		goto_out;
 
 	if ((ret = _process_common_commands(cmd))) {


