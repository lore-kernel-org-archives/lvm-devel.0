From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Apr 2009 14:59:48 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20090402145948.23571.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-02 14:59:48

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Do not use pointer from released memory pool (cmd->cmd_line).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/tools/lvmcmdline.c	2009/02/22 22:11:59	1.94
+++ LVM2/tools/lvmcmdline.c	2009/04/02 14:59:48	1.95
@@ -1026,16 +1026,16 @@
 	cmd->current_settings = cmd->default_settings;
 	_apply_settings(cmd);
 
-	/*
-	 * free off any memory the command used.
-	 */
-	dm_pool_empty(cmd->mem);
-
 	if (ret == EINVALID_CMD_LINE && !_cmdline.interactive)
 		_short_usage(cmd->command->name);
 
 	log_debug("Completed: %s", cmd->cmd_line);
 
+	/*
+	 * free off any memory the command used.
+	 */
+	dm_pool_empty(cmd->mem);
+
 	return ret;
 }
 


