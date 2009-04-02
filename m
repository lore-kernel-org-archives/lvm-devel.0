From: taka@sourceware.org <taka@sourceware.org>
Date: 2 Apr 2009 20:46:12 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20090402204612.19496.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	taka at sourceware.org	2009-04-02 20:46:11

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Fix error message when archive initialization fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1074&r2=1.1075
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/WHATS_NEW	2009/04/01 07:51:05	1.1074
+++ LVM2/WHATS_NEW	2009/04/02 20:46:11	1.1075
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix error message when archive initialization fails.
   Make sure clvmd-corosync releases the lockspace when it exits.
   Fix segfault for vgcfgrestore on VG with missing PVs.
   Block SIGTERM & SIGINT in clvmd subthreads.
--- LVM2/lib/commands/toolcontext.c	2009/02/22 21:14:38	1.73
+++ LVM2/lib/commands/toolcontext.c	2009/04/02 20:46:11	1.74
@@ -955,7 +955,7 @@
 
 	if (!archive_init(cmd, dir, days, min,
 			  cmd->default_settings.archive)) {
-		log_debug("backup_init failed.");
+		log_debug("archive_init failed.");
 		return 0;
 	}
 


