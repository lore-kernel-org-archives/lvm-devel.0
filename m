From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:36:16 -0000
Subject: LVM2 lib/commands/toolcontext.c tools/lvmcmdline.c
Message-ID: <20081211033616.31954.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:36:16

Modified files:
	lib/commands   : toolcontext.c 
	tools          : lvmcmdline.c 

Log message:
	Move initialization of cmd->fmt into init_formats().
	
	init_formats() sets up the command formats, and currently sets cmd->fmt_backup
	but does not set cmd->fmt to a default value.  This seems incorrect so we
	set it to cmd->default_settings.fmt before returning.
	
	The call we remove here may set cmd->fmt based on a command line setting.
	But it is safe to remove this, because the only caller of init_lvm() that
	cares about the cmdline override is the cmdline tools (clvmd does not care),
	called from lvm2_main().  After lvm2_main() calls init_lvm(), it later calls
	lvm_run_command().  In lvm_run_command(), we have a call to _apply_settings(),
	which has the identical assignment of cmd->fmt that this patch removes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/lib/commands/toolcontext.c	2008/12/11 03:33:35	1.68
+++ LVM2/lib/commands/toolcontext.c	2008/12/11 03:36:16	1.69
@@ -784,6 +784,7 @@
 		if (!strcasecmp(fmt->name, format) ||
 		    (fmt->alias && !strcasecmp(fmt->alias, format))) {
 			cmd->default_settings.fmt = fmt;
+			cmd->fmt = cmd->default_settings.fmt;
 			return 1;
 		}
 	}
--- LVM2/tools/lvmcmdline.c	2008/12/11 03:34:43	1.85
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:36:16	1.86
@@ -1094,9 +1094,6 @@
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
 
-	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
-				 cmd->current_settings.fmt);
-
 	return cmd;
 }
 


