From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Jan 2011 15:00:30 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20110113150030.15326.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-13 15:00:29

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Do not log backtrace for correctly processed command

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/tools/lvmcmdline.c	2010/12/20 13:59:52	1.136
+++ LVM2/tools/lvmcmdline.c	2011/01/13 15:00:29	1.137
@@ -1095,8 +1095,11 @@
 	if (!_set_udev_checking(cmd))
 		goto_out;
 
-	if ((ret = _process_common_commands(cmd)))
-		goto_out;
+	if ((ret = _process_common_commands(cmd))) {
+		if (ret != ECMD_PROCESSED)
+			stack;
+		goto out;
+	}
 
 	if (cmd->metadata_read_only &&
 	    !(cmd->command->flags & PERMITTED_READ_ONLY)) {


