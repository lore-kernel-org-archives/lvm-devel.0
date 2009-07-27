From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 21:01:37 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20090727210137.1893.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 21:01:36

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Refactor _override_settings to take the new config string as input.
	
	We will re-use this function from liblvm.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103

--- LVM2/tools/lvmcmdline.c	2009/07/16 00:37:00	1.102
+++ LVM2/tools/lvmcmdline.c	2009/07/27 21:01:36	1.103
@@ -887,9 +887,9 @@
 	return ret;
 }
 
-static int _override_settings(struct cmd_context *cmd)
+static int _override_settings(struct cmd_context *cmd, const char *config_settings)
 {
-	if (!(cmd->cft_override = create_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, "")))) {
+	if (!(cmd->cft_override = create_config_tree_from_string(cmd, config_settings))) {
 		log_error("Failed to set overridden configuration entries.");
 		return EINVALID_CMD_LINE;
 	}
@@ -986,7 +986,8 @@
 	set_cmd_name(cmd->command->name);
 
 	if (arg_count(cmd, config_ARG))
-		if ((ret = _override_settings(cmd)))
+		if ((ret = _override_settings(cmd,
+				arg_str_value(cmd, config_ARG, ""))))
 			goto_out;
 
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {


