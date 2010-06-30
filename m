From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2010 16:43:11 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20100630164311.28685.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-30 16:43:10

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Update partial mode warning message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1643&r2=1.1644
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW	2010/06/30 14:50:32	1.1643
+++ LVM2/WHATS_NEW	2010/06/30 16:43:09	1.1644
@@ -1,5 +1,6 @@
 Version 2.02.70 - 
 ================================
+  Update partial mode warning message.
 
 Version 2.02.69 - 30th June 2010
 ================================
--- LVM2/tools/lvmcmdline.c	2010/06/28 20:40:01	1.124
+++ LVM2/tools/lvmcmdline.c	2010/06/30 16:43:10	1.125
@@ -817,8 +817,7 @@
 
 	if (arg_count(cmd, partial_ARG)) {
 		cmd->partial_activation = 1;
-		log_print("Partial mode. Incomplete volume groups will "
-			  "be activated read-only.");
+		log_print("Partial mode. Incomplete logical volumes will be processed.");
 	}
 
 	if (arg_count(cmd, ignorelockingfailure_ARG) || arg_count(cmd, sysinit_ARG))


