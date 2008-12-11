From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:34:44 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20081211033444.31281.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:34:43

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Remove redundant init_msg_prefix() and init_cmd_name().
	
	This is very obvious - _init_logging() makes the identical init_msg_prefix()
	and init_cmd_name() calls with cmd->default_settings so these calls are
	clearly redundant after calling create_toolcontext().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/tools/lvmcmdline.c	2008/12/11 03:34:12	1.84
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:34:43	1.85
@@ -1094,9 +1094,6 @@
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
 
-	init_msg_prefix(cmd->default_settings.msg_prefix);
-	init_cmd_name(cmd->default_settings.cmd_name);
-
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
 				 cmd->current_settings.fmt);
 


