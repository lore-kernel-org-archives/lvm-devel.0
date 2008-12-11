From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:34:12 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c tools/lvmcm ...
Message-ID: <20081211033412.30976.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:34:12

Modified files:
	daemons/clvmd  : lvm-functions.c 
	tools          : lvmcmdline.c 

Log message:
	Remove redundant set_activation() call after create_toolcontext() calls.
	
	Very similar argument to removal of init_debug() and other calls.
	
	create_toolcontext() calls _process_config() which sets
	cmd->default_settings.activation, then calls
	set_activation(cmd->default_settings.activation).  Later, create_toolcontext()
	sets cmd->current_settings = cmd->default_settings.  So these calls
	set_activation(cmd->current_settings.activation) are redundant.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:33:35	1.52
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:34:12	1.53
@@ -732,7 +732,6 @@
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
-	set_activation(cmd->current_settings.activation);
 	cmd->cmd_line = (char *)"clvmd";
 
 	/* Check lvm.conf is setup for cluster-LVM */
--- LVM2/tools/lvmcmdline.c	2008/12/11 03:33:35	1.83
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:34:12	1.84
@@ -1097,8 +1097,6 @@
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 	init_cmd_name(cmd->default_settings.cmd_name);
 
-	set_activation(cmd->current_settings.activation);
-
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
 				 cmd->current_settings.fmt);
 


