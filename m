From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jul 2010 14:29:29 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20100708142929.12575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-07-08 14:29:28

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Revert previous commit as it would return also for incorrect syntax.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.393&r2=1.394
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141

--- LVM2/WHATS_NEW_DM	2010/07/08 13:35:55	1.393
+++ LVM2/WHATS_NEW_DM	2010/07/08 14:29:26	1.394
@@ -1,6 +1,5 @@
 Version 1.02.53 -
 ===============================
-  Fix return value to 0 for 'dmsetup -c -o help'.
   Use "nowatch" udev rule for inappropriate devices.
 
 Version 1.02.52 - 6th July 2010
--- LVM2/tools/dmsetup.c	2010/07/08 13:31:03	1.140
+++ LVM2/tools/dmsetup.c	2010/07/08 14:29:28	1.141
@@ -3341,7 +3341,6 @@
 
 	if (argc == 0) {
 		_usage(stderr);
-		r = 0;
 		goto out;
 	}
 


