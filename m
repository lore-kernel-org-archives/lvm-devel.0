From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 21:01:59 -0000
Subject: LVM2 lib/config/config.c lib/config/config.h t ...
Message-ID: <20090727210159.2082.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 21:01:59

Modified files:
	lib/config     : config.c config.h 
	tools          : lvmcmdline.c 

Log message:
	Rename _override_settings into override_config_tree_from_string and move.
	
	Move _override_settings from tools/lvmcmdline.c into lib/config/config.c
	and export so we can re-use in liblvm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/lib/config/config.c	2009/07/09 11:29:00	1.74
+++ LVM2/lib/config/config.c	2009/07/27 21:01:56	1.75
@@ -186,6 +186,17 @@
 	return cft;
 }
 
+int override_config_tree_from_string(struct cmd_context *cmd,
+				     const char *config_settings)
+{
+	if (!(cmd->cft_override = create_config_tree_from_string(cmd,config_settings))) {
+		log_error("Failed to set overridden configuration entries.");
+		return 1;
+	}
+
+	return 0;
+}
+
 int read_config_fd(struct config_tree *cft, struct device *dev,
 		   off_t offset, size_t size, off_t offset2, size_t size2,
 		   checksum_fn_t checksum_fn, uint32_t checksum)
--- LVM2/lib/config/config.h	2009/07/09 11:29:00	1.27
+++ LVM2/lib/config/config.h	2009/07/27 21:01:58	1.28
@@ -56,6 +56,8 @@
 struct config_tree *create_config_tree(const char *filename, int keep_open);
 struct config_tree *create_config_tree_from_string(struct cmd_context *cmd,
 						   const char *config_settings);
+int override_config_tree_from_string(struct cmd_context *cmd,
+				     const char *config_settings);
 void destroy_config_tree(struct config_tree *cft);
 
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const void *buf, uint32_t size);
--- LVM2/tools/lvmcmdline.c	2009/07/27 21:01:36	1.103
+++ LVM2/tools/lvmcmdline.c	2009/07/27 21:01:58	1.104
@@ -887,16 +887,6 @@
 	return ret;
 }
 
-static int _override_settings(struct cmd_context *cmd, const char *config_settings)
-{
-	if (!(cmd->cft_override = create_config_tree_from_string(cmd, config_settings))) {
-		log_error("Failed to set overridden configuration entries.");
-		return EINVALID_CMD_LINE;
-	}
-
-	return 0;
-}
-
 static void _apply_settings(struct cmd_context *cmd)
 {
 	init_debug(cmd->current_settings.debug);
@@ -986,9 +976,11 @@
 	set_cmd_name(cmd->command->name);
 
 	if (arg_count(cmd, config_ARG))
-		if ((ret = _override_settings(cmd,
-				arg_str_value(cmd, config_ARG, ""))))
+		if ((ret = override_config_tree_from_string(cmd,
+			     arg_str_value(cmd, config_ARG, "")))) {
+			ret = EINVALID_CMD_LINE;
 			goto_out;
+		}
 
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */


