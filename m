From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:28:54 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20081211032854.19454.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:28:54

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Replace _apply_settings() after create_toolcontext() with equivalent inline.
	
	Subsequent patches will refactor / remove each of these lines, as many of
	them are redundant when called immediately after create_toolcontext().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/tools/lvmcmdline.c	2008/12/07 04:27:57	1.76
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:28:54	1.77
@@ -1091,7 +1091,23 @@
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	_apply_settings(cmd);
+	init_debug(cmd->current_settings.debug);
+	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
+	init_test(cmd->current_settings.test);
+	init_full_scan_done(0);
+	init_mirror_in_sync(0);
+
+	init_msg_prefix(cmd->default_settings.msg_prefix);
+	init_cmd_name(cmd->default_settings.cmd_name);
+
+	archive_enable(cmd, cmd->current_settings.archive);
+	backup_enable(cmd, cmd->current_settings.backup);
+
+	set_activation(cmd->current_settings.activation);
+
+	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
+				 cmd->current_settings.fmt);
+	cmd->handles_missing_pvs = 0;
 
 	return cmd;
 }


