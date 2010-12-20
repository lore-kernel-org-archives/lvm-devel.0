From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:59:52 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20101220135952.18682.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:59:52

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Remove dead store in lvm_run_command
	
	Variable 'ret' is not read before its next assignment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/tools/lvmcmdline.c	2010/12/20 13:16:30	1.135
+++ LVM2/tools/lvmcmdline.c	2010/12/20 13:59:52	1.136
@@ -1064,8 +1064,8 @@
 	set_cmd_name(cmd->command->name);
 
 	if (arg_count(cmd, config_ARG))
-		if ((ret = override_config_tree_from_string(cmd,
-			     arg_str_value(cmd, config_ARG, "")))) {
+		if (override_config_tree_from_string(cmd,
+		    arg_str_value(cmd, config_ARG, ""))) {
 			ret = EINVALID_CMD_LINE;
 			goto_out;
 		}


