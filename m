From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:31:10 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20081211033110.22879.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:31:10

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Remove handles_missing_pvs assignment after call to create_toolcontext().
	
	This variable is set at the top of create_toolcontext() to 0.
	Nothing later in create_toolcontext() changes the value.
	In init_lvm(), nothing between create_toolcontext() call and this assignment
	changes the value.  Thus, the assignment is redundant.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/tools/lvmcmdline.c	2008/12/11 03:30:20	1.79
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:31:10	1.80
@@ -1105,7 +1105,6 @@
 
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
 				 cmd->current_settings.fmt);
-	cmd->handles_missing_pvs = 0;
 
 	return cmd;
 }


