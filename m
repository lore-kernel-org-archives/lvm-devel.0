From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 Jan 2010 17:40:18 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20100113174018.15855.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-13 17:40:18

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	Fix clvmd automatic target module loading crash.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1383&r2=1.1384
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/WHATS_NEW	2010/01/12 20:53:20	1.1383
+++ LVM2/WHATS_NEW	2010/01/13 17:40:17	1.1384
@@ -1,5 +1,6 @@
 Version 2.02.58 - 
 ===================================
+  Fix clvmd automatic target module loading crash.
   Fix allocation code not to stop at the first area of a PV that fits.
 
 Version 2.02.57 - 12th January 2010
--- LVM2/lib/locking/locking.c	2010/01/05 21:08:34	1.71
+++ LVM2/lib/locking/locking.c	2010/01/13 17:40:17	1.72
@@ -186,7 +186,8 @@
 	_vg_lock_count = 0;
 	_vg_write_lock_held = 0;
 
-	_locking.reset_locking();
+	if (_locking.reset_locking)
+		_locking.reset_locking();
 
 	if (was_locked)
 		_unblock_signals();


