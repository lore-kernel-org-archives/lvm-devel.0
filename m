From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:30:20 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c tools/lvmcm ...
Message-ID: <20081211033020.20382.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:30:20

Modified files:
	daemons/clvmd  : lvm-functions.c 
	tools          : lvmcmdline.c 

Log message:
	Remove init_verbose() calls immediately after create_toolcontext() calls.
	
	The rationale for removing init_verbose() call is very similar to removing
	init_debug() call.  create_toolcontext() calls _init_logging() which
	makes these calls:
	/* Verbose level for tty output */
	cmd->default_settings.verbose =
	find_config_tree_int(cmd, "log/verbose", DEFAULT_VERBOSE);
	init_verbose(cmd->default_settings.verbose + VERBOSE_BASE_LEVEL);
	
	And being that create_toolcontext() copies default_settings into
	current_settings at the bottom, the init_verbose() call we are removing:
	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
	
	is redundant.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:29:37	1.49
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:30:19	1.50
@@ -732,7 +732,6 @@
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
-	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	set_activation(cmd->current_settings.activation);
 	archive_enable(cmd, cmd->current_settings.archive);
 	backup_enable(cmd, cmd->current_settings.backup);
--- LVM2/tools/lvmcmdline.c	2008/12/11 03:29:37	1.78
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:30:20	1.79
@@ -1091,7 +1091,6 @@
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);


