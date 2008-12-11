From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:33:36 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c lib/command ...
Message-ID: <20081211033336.30637.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:33:35

Modified files:
	daemons/clvmd  : lvm-functions.c 
	lib/commands   : toolcontext.c 
	lib/format_text: archiver.c archiver.h 
	tools          : lvmcmdline.c 

Log message:
	Remove backup_enable() calls after create_toolcontext() calls.
	
	Identical argument to previous patch which removed archive_enable() calls.
	We add a new parameter to backup_init() which sets the enable value based
	on the cmd->default_settings.backup value.  This value was used to set
	cmd->current_settings.backup, used in the removed backup_enable() call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:32:56	1.51
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:33:35	1.52
@@ -733,7 +733,6 @@
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
 	set_activation(cmd->current_settings.activation);
-	backup_enable(cmd, cmd->current_settings.backup);
 	cmd->cmd_line = (char *)"clvmd";
 
 	/* Check lvm.conf is setup for cluster-LVM */
--- LVM2/lib/commands/toolcontext.c	2008/12/11 03:32:57	1.67
+++ LVM2/lib/commands/toolcontext.c	2008/12/11 03:33:35	1.68
@@ -925,7 +925,7 @@
 
 	if (!cmd->sys_dir) {
 		log_warn("WARNING: Metadata changes will NOT be backed up");
-		backup_init(cmd, "");
+		backup_init(cmd, "", 0);
 		archive_init(cmd, "", 0, 0, 0);
 		return 1;
 	}
@@ -973,7 +973,7 @@
 
 	dir = find_config_tree_str(cmd, "backup/backup_dir", default_dir);
 
-	if (!backup_init(cmd, dir)) {
+	if (!backup_init(cmd, dir, cmd->default_settings.backup)) {
 		log_debug("backup_init failed.");
 		return 0;
 	}
--- LVM2/lib/format_text/archiver.c	2008/12/11 03:32:57	1.16
+++ LVM2/lib/format_text/archiver.c	2008/12/11 03:33:35	1.17
@@ -150,7 +150,8 @@
 	return r;
 }
 
-int backup_init(struct cmd_context *cmd, const char *dir)
+int backup_init(struct cmd_context *cmd, const char *dir,
+		int enabled)
 {
 	if (!(cmd->backup_params = dm_pool_zalloc(cmd->libmem,
 					       sizeof(*cmd->archive_params)))) {
@@ -166,6 +167,7 @@
 		log_error("Couldn't copy backup directory name.");
 		return 0;
 	}
+	backup_enable(cmd, enabled);
 
 	return 1;
 }
--- LVM2/lib/format_text/archiver.h	2008/12/11 03:32:57	1.5
+++ LVM2/lib/format_text/archiver.h	2008/12/11 03:33:35	1.6
@@ -41,7 +41,7 @@
 int archive_display(struct cmd_context *cmd, const char *vg_name);
 int archive_display_file(struct cmd_context *cmd, const char *file);
 
-int backup_init(struct cmd_context *cmd, const char *dir);
+int backup_init(struct cmd_context *cmd, const char *dir, int enabled);
 void backup_exit(struct cmd_context *cmd);
 
 void backup_enable(struct cmd_context *cmd, int flag);
--- LVM2/tools/lvmcmdline.c	2008/12/11 03:32:57	1.82
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:33:35	1.83
@@ -1097,8 +1097,6 @@
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 	init_cmd_name(cmd->default_settings.cmd_name);
 
-	backup_enable(cmd, cmd->current_settings.backup);
-
 	set_activation(cmd->current_settings.activation);
 
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,


