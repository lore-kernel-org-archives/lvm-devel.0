From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 14:23:44 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c
Message-ID: <20120213142344.32583.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 14:23:42

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 

Log message:
	Never try to test character past given buffer
	
	In case units[0] would be already '\0', do not check units[1].

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2291&r2=1.2292
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/WHATS_NEW	2012/02/13 13:02:47	1.2291
+++ LVM2/WHATS_NEW	2012/02/13 14:23:40	1.2292
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Properly test buffer for unit check in units_to_bytes().
   Add configure --with-systemdsystemunitdir.
   Add check for allocation failure in _build_matcher().
   Add check for rimage name allocation failure in _raid_add_images().
--- LVM2/lib/display/display.c	2012/01/26 14:02:43	1.128
+++ LVM2/lib/display/display.c	2012/02/13 14:23:41	1.129
@@ -60,7 +60,7 @@
 		v = 1;
 
 	/* Only one units char permitted. */
-	if (*(units + 1))
+	if (units[0] && units[1])
 		return 0;
 
 	if (v == 1)


