From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Sep 2010 11:44:58 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20100930114458.23234.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-09-30 11:44:55

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Fix memory leak of config_tree
	
	Adding missing destroy_config_tree() for cft_override if it has been allocated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1740&r2=1.1741
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/WHATS_NEW	2010/09/30 11:40:14	1.1740
+++ LVM2/WHATS_NEW	2010/09/30 11:44:54	1.1741
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix memory leak of config_tree in reinitialization code path.
   Swap pool destruction order in dmeventd_lvm2_exit() to fix leak report.
   Read whole /proc/self/maps file before working with maps entries.
   Speed up unquoting of quoted double quotes and backslashes.
--- LVM2/tools/lvmcmdline.c	2010/07/09 15:34:48	1.127
+++ LVM2/tools/lvmcmdline.c	2010/09/30 11:44:54	1.128
@@ -1048,6 +1048,10 @@
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
+			if (cmd->cft_override) {
+				destroy_config_tree(cmd->cft_override);
+				cmd->cft_override = NULL;
+			}
 			log_error("Updated config file invalid. Aborting.");
 			return ECMD_FAILED;
 		}


