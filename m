From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 07:11:55 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20080919071155.26557.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 07:11:55

Modified files:
	tools          : lvmcmdline.c 

Log message:
	rename var

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/tools/lvmcmdline.c	2008/09/19 06:42:00	1.70
+++ LVM2/tools/lvmcmdline.c	2008/09/19 07:11:54	1.71
@@ -710,10 +710,10 @@
 	cmd->current_settings.archive = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.archive);
 	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
 	cmd->current_settings.cache_vgmetadata = cmd->command->flags & CACHE_VGMETADATA ? 1 : 0;
-	cmd->partial_activate = 0;
+	cmd->partial_activation = 0;
 
 	if (arg_count(cmd, partial_ARG)) {
-		cmd->partial_activate = 1;
+		cmd->partial_activation = 1;
 		log_print("Partial mode. Incomplete volume groups will "
 			  "be activated read-only.");
 	}


