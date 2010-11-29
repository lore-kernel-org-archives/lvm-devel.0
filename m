From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 10:58:33 -0000
Subject: LVM2 lib/commands/toolcontext.c ./WHATS_NEW
Message-ID: <20101129105833.5420.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 10:58:33

Modified files:
	lib/commands   : toolcontext.c 
	.              : WHATS_NEW 

Log message:
	Fix check for empty system_dir
	
	Fixing check for zero length system_dir string.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1810&r2=1.1811

--- LVM2/lib/commands/toolcontext.c	2010/11/24 09:34:35	1.109
+++ LVM2/lib/commands/toolcontext.c	2010/11/29 10:58:32	1.110
@@ -1036,7 +1036,7 @@
 	char default_dir[PATH_MAX];
 	const char *dir;
 
-	if (!cmd->system_dir) {
+	if (!cmd->system_dir[0]) {
 		log_warn("WARNING: Metadata changes will NOT be backed up");
 		backup_init(cmd, "", 0);
 		archive_init(cmd, "", 0, 0, 0);
--- LVM2/WHATS_NEW	2010/11/25 17:16:41	1.1810
+++ LVM2/WHATS_NEW	2010/11/29 10:58:33	1.1811
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix test for empty system_dir string in _init_backup().
   Certain lvconvert invocations are now required to be done in two steps.
   Fix missing context desctruction in err path of lvm1 fallback in lvm2_main().
   Fix memory leak in error path of parse_loop_device_name() from dmsetup.


