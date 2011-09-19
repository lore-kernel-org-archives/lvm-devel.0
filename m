From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 18:38:44 -0000
Subject: LVM2 lib/misc/lvm-exec.c ./WHATS_NEW
Message-ID: <20110919183844.17228.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 18:38:43

Modified files:
	lib/misc       : lvm-exec.c 
	.              : WHATS_NEW 

Log message:
	Revert patch
	
	Caller of exec must report log_error when rstatus is passed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2122&r2=1.2123

--- LVM2/lib/misc/lvm-exec.c	2011/09/19 14:54:23	1.15
+++ LVM2/lib/misc/lvm-exec.c	2011/09/19 18:38:43	1.16
@@ -96,7 +96,7 @@
 	if (WEXITSTATUS(status)) {
 		if (rstatus) {
 			*rstatus = WEXITSTATUS(status);
-			log_error("%s failed: %u", argv[0], *rstatus);
+			log_verbose("%s failed: %u", argv[0], *rstatus);
 		} else
 			log_error("%s failed: %u", argv[0], WEXITSTATUS(status));
 		return 0;
--- LVM2/WHATS_NEW	2011/09/19 14:54:23	1.2122
+++ LVM2/WHATS_NEW	2011/09/19 18:38:43	1.2123
@@ -1,6 +1,5 @@
 Version 2.02.89 - 
 ==================================
-  Use log_error instead of log_verbose when executed command fails.
   Add support for non /dev device paths into fsadm script.
   Support different PATH setting for fsadm script testing.
   Surround all executed commands with quotes in fsadm script.


