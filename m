From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 Aug 2011 17:06:25 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20110811170625.8889.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-08-11 17:06:24

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Remove dev name prefix from dmsetup line output if major and minor is used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.487&r2=1.488
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167

--- LVM2/WHATS_NEW_DM	2011/08/09 17:56:47	1.487
+++ LVM2/WHATS_NEW_DM	2011/08/11 17:06:24	1.488
@@ -1,5 +1,6 @@
 Version 1.02.66 - 
 ===============================
+  Remove dev name prefix from dmsetup line output if major and minor is used.
   Remove support for the original version 1 dm ioctls.
   Add missing check for allocation failure _create_dir_recursive().
   Add support for systemd file descriptor handover in dmeventd.
--- LVM2/tools/dmsetup.c	2011/08/04 12:40:24	1.166
+++ LVM2/tools/dmsetup.c	2011/08/11 17:06:24	1.167
@@ -3478,7 +3478,8 @@
 	#endif
 
       doit:
-	multiple_devices = (argc != 2 && cmd->repeatable_cmd);
+	multiple_devices = (cmd->repeatable_cmd && argc != 2 &&
+			   (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
 	do {
 		if (!cmd->fn(cmd, argc--, argv++, NULL, multiple_devices)) {
 			fprintf(stderr, "Command failed\n");


