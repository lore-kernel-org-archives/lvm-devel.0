From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Jul 2009 19:49:49 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20090713194949.15452.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-13 19:49:49

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/commands   : toolcontext.h 
	tools          : lvmcmdline.c 

Log message:
	Make cmd->cmd_line const.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1177&r2=1.1178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/WHATS_NEW	2009/07/13 11:25:35	1.1177
+++ LVM2/WHATS_NEW	2009/07/13 19:49:48	1.1178
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Make cmd->cmd_line const.
   Fix dev name mismatch in vgcreate man page example.
   Refactor vg_remove_single for use in liblvm.
   Make all tools consistent with lock ordering - obtain VG_ORPHAN lock second.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/06/15 12:15:23	1.63
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/07/13 19:49:48	1.64
@@ -795,7 +795,7 @@
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
-	cmd->cmd_line = (char *)"clvmd";
+	cmd->cmd_line = "clvmd";
 
 	/* Check lvm.conf is setup for cluster-LVM */
 	check_config();
--- LVM2/lib/commands/toolcontext.h	2009/02/22 21:14:38	1.31
+++ LVM2/lib/commands/toolcontext.h	2009/07/13 19:49:49	1.32
@@ -63,7 +63,7 @@
 	const char *kernel_vsn;
 
 	unsigned rand_seed;
-	char *cmd_line;
+	const char *cmd_line;
 	struct command *command;
 	char **argv;
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
--- LVM2/tools/lvmcmdline.c	2009/07/07 01:51:00	1.98
+++ LVM2/tools/lvmcmdline.c	2009/07/13 19:49:49	1.99
@@ -918,7 +918,7 @@
 	cmd->handles_missing_pvs = 0;
 }
 
-static char *_copy_command_line(struct cmd_context *cmd, int argc, char **argv)
+static const char *_copy_command_line(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i, space;
 


