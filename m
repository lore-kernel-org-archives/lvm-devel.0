From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2010 20:53:21 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20100112205321.3408.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-12 20:53:20

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix allocation code not to stop at the first area of a PV that fits.
	
	This spurious 'break' has been here since this code was first committed
	in June 2005 and stopped the algorithm behaving as described in the
	comment above it and rendered the variable 'already_found_one' useless.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1382&r2=1.1383
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.196&r2=1.197

--- LVM2/WHATS_NEW	2010/01/12 14:47:00	1.1382
+++ LVM2/WHATS_NEW	2010/01/12 20:53:20	1.1383
@@ -1,5 +1,6 @@
 Version 2.02.58 - 
 ===================================
+  Fix allocation code not to stop at the first area of a PV that fits.
 
 Version 2.02.57 - 12th January 2010
 ===================================
--- LVM2/lib/metadata/lv_manip.c	2010/01/12 14:00:51	1.196
+++ LVM2/lib/metadata/lv_manip.c	2010/01/12 20:53:20	1.197
@@ -1114,8 +1114,6 @@
 				}
 
 				areas[ix + ix_offset - 1] = pva;
-
-				goto next_pv;
 			}
 		next_pv:
 			if (ix >= areas_size)


