From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:32:57 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c lib/command ...
Message-ID: <20081211033257.30314.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:32:57

Modified files:
	daemons/clvmd  : lvm-functions.c 
	lib/commands   : toolcontext.c 
	lib/format_text: archiver.c archiver.h 
	tools          : lvmcmdline.c 

Log message:
	Remove archive_enable() calls after create_toolcontext() calls.
	
	_init_backup() calls archive_init(), which originally set 'enabled' to
	a hardcoded '1' value.  This seems incorrect based on my read of other
	areas of the code so here we add a 'enabled' paramter to archive_init().
	We pass in cmd->default_settings.archive, which is obtained from the
	config tree.  Later in create_toolcontext, cmd->current_settings is
	set to cmd->default_settings.  The archive_enable() call we remove
	here was using cmd->current_settings to set the 'archive' enable
	value.  The final value of cmd->archive_params->enabled should thus
	be equivalent to the original code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:30:19	1.50
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:32:56	1.51
@@ -733,7 +733,6 @@
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
 	set_activation(cmd->current_settings.activation);
-	archive_enable(cmd, cmd->current_settings.archive);
 	backup_enable(cmd, cmd->current_settings.backup);
 	cmd->cmd_line = (char *)"clvmd";
 
--- LVM2/lib/commands/toolcontext.c	2008/12/11 03:31:47	1.66
+++ LVM2/lib/commands/toolcontext.c	2008/12/11 03:32:57	1.67
@@ -926,7 +926,7 @@
 	if (!cmd->sys_dir) {
 		log_warn("WARNING: Metadata changes will NOT be backed up");
 		backup_init(cmd, "");
-		archive_init(cmd, "", 0, 0);
+		archive_init(cmd, "", 0, 0, 0);
 		return 1;
 	}
 
@@ -952,7 +952,8 @@
 	dir = find_config_tree_str(cmd, "backup/archive_dir",
 			      default_dir);
 
-	if (!archive_init(cmd, dir, days, min)) {
+	if (!archive_init(cmd, dir, days, min,
+			  cmd->default_settings.archive)) {
 		log_debug("backup_init failed.");
 		return 0;
 	}
--- LVM2/lib/format_text/archiver.c	2008/11/03 22:14:28	1.15
+++ LVM2/lib/format_text/archiver.c	2008/12/11 03:32:57	1.16
@@ -36,7 +36,8 @@
 };
 
 int archive_init(struct cmd_context *cmd, const char *dir,
-		 unsigned int keep_days, unsigned int keep_min)
+		 unsigned int keep_days, unsigned int keep_min,
+		 int enabled)
 {
 	if (!(cmd->archive_params = dm_pool_zalloc(cmd->libmem,
 						sizeof(*cmd->archive_params)))) {
@@ -56,7 +57,7 @@
 
 	cmd->archive_params->keep_days = keep_days;
 	cmd->archive_params->keep_number = keep_min;
-	cmd->archive_params->enabled = 1;
+	archive_enable(cmd, enabled);
 
 	return 1;
 }
--- LVM2/lib/format_text/archiver.h	2007/08/20 20:55:26	1.4
+++ LVM2/lib/format_text/archiver.h	2008/12/11 03:32:57	1.5
@@ -32,7 +32,8 @@
  */
 
 int archive_init(struct cmd_context *cmd, const char *dir,
-		 unsigned int keep_days, unsigned int keep_min);
+		 unsigned int keep_days, unsigned int keep_min,
+		 int enabled);
 void archive_exit(struct cmd_context *cmd);
 
 void archive_enable(struct cmd_context *cmd, int flag);
--- LVM2/tools/lvmcmdline.c	2008/12/11 03:31:47	1.81
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:32:57	1.82
@@ -1097,7 +1097,6 @@
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 	init_cmd_name(cmd->default_settings.cmd_name);
 
-	archive_enable(cmd, cmd->current_settings.archive);
 	backup_enable(cmd, cmd->current_settings.backup);
 
 	set_activation(cmd->current_settings.activation);


