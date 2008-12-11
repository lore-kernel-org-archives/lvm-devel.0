From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:29:37 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c tools/lvmcm ...
Message-ID: <20081211032937.19674.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:29:37

Modified files:
	daemons/clvmd  : lvm-functions.c 
	tools          : lvmcmdline.c 

Log message:
	Remove init_debug() calls immediately after create_toolcontext() call.
	
	We can safely remove because create_toolcontext() calls _init_logging(),
	which makes these calls:
	/* Debug level for log file output */
	cmd->default_settings.debug =
	find_config_tree_int(cmd, "log/level", DEFAULT_LOGLEVEL);
	init_debug(cmd->default_settings.debug);
	
	Then at the bottom of create_toolcontext() we do this:
	cmd->current_settings = cmd->default_settings;
	
	So the call we are removing from init_lvm() functions (clvmd and lvmcmdline):
	init_debug(cmd->current_settings.debug);
	
	Just sets the value of debug based on 'cmd->current_settings.debug'.
	Since cmd->current_settings is equivalent to cmd->default_settings, and
	init_debug() was called with cmd->default_settings, the call we remove is
	redundant.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/daemons/clvmd/lvm-functions.c	2008/11/04 16:41:47	1.48
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/12/11 03:29:37	1.49
@@ -732,7 +732,6 @@
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
-	init_debug(cmd->current_settings.debug);
 	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	set_activation(cmd->current_settings.activation);
 	archive_enable(cmd, cmd->current_settings.archive);
--- LVM2/tools/lvmcmdline.c	2008/12/11 03:28:54	1.77
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:29:37	1.78
@@ -1091,7 +1091,6 @@
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	init_debug(cmd->current_settings.debug);
 	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
 	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);


