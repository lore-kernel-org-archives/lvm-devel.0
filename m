From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Nov 2006 15:28:50 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20061114152850.26487.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-14 15:28:50

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Fix --autobackup argument which could never disable backups.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.496&r2=1.497
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2006/11/14 15:03:07	1.496
+++ LVM2/WHATS_NEW	2006/11/14 15:28:50	1.497
@@ -1,5 +1,6 @@
 Version 2.02.15 -
 ====================================
+  Fix --autobackup argument which could never disable backups.
   Fix a label_verify error path.
 
 Version 2.02.14 - 10th November 2006
--- LVM2/tools/lvmcmdline.c	2006/11/10 18:24:11	1.37
+++ LVM2/tools/lvmcmdline.c	2006/11/14 15:28:50	1.38
@@ -712,10 +712,8 @@
 				  cmd->default_settings.activation);
 	}
 
-	if (arg_count(cmd, autobackup_ARG)) {
-		cmd->current_settings.archive = 1;
-		cmd->current_settings.backup = 1;
-	}
+	cmd->current_settings.archive = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.archive);
+	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
 
 	if (arg_count(cmd, partial_ARG)) {
 		init_partial(1);


