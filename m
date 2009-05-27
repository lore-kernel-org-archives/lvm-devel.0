From: agk@sourceware.org <agk@sourceware.org>
Date: 27 May 2009 13:05:55 -0000
Subject: LVM2 ./WHATS_NEW lib/zero/zero.c
Message-ID: <20090527130555.20595.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-27 13:05:54

Modified files:
	.              : WHATS_NEW 
	lib/zero       : zero.c 

Log message:
	Attempt to load dm-zero module if zero target needed but not present. (mbroz)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1124&r2=1.1125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2009/05/22 15:23:11	1.1124
+++ LVM2/WHATS_NEW	2009/05/27 13:05:53	1.1125
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Attempt to load dm-zero module if zero target needed but not present.
 
 Version 2.02.47 - 22nd May 2009
 ===============================
--- LVM2/lib/zero/zero.c	2009/02/28 20:04:25	1.20
+++ LVM2/lib/zero/zero.c	2009/05/27 13:05:54	1.21
@@ -58,7 +58,7 @@
 	static int _zero_present = 0;
 
 	if (!_zero_checked)
-		_zero_present = target_present(cmd, "zero", 0);
+		_zero_present = target_present(cmd, "zero", 1);
 
 	_zero_checked = 1;
 


