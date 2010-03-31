From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 31 Mar 2010 17:23:57 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20100331172357.1067.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-31 17:23:57

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	Always use blocking lock for VGs and orphan locks.
	
	Because we have now strong rule for lock ordering:
	- VG locks must be taken in alphabetical order
	- ORPHAN locks must be the last
	vgs_locked() is now not needed.
	
	This fixes problem with orphan locking, e.g.
	vgremove VG1    |    vgremove VG2
	lock(VG1)       |    lock(VG2)
	lock(ORPHAN)    |    lock(ORPHAN) -> fail, non-blocking
	
	https://bugzilla.redhat.com/show_bug.cgi?id=578413
	
	(More similar places in code.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1497&r2=1.1498
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2010/03/31 17:23:18	1.1497
+++ LVM2/WHATS_NEW	2010/03/31 17:23:56	1.1498
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Always use blocking lock for VGs and orphan locks.
   Allocate all segments memory from vg private mempool.
   Return newly allocated PV segment after segment split.
   Optimise PV segments search for the most last segment search case.
--- LVM2/lib/locking/locking.c	2010/03/05 14:48:34	1.75
+++ LVM2/lib/locking/locking.c	2010/03/31 17:23:57	1.76
@@ -420,11 +420,9 @@
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
 		/*
-		 * Automatically set LCK_NONBLOCK if one or more VGs locked.
-		 * This will enforce correctness and prevent deadlocks rather
-		 * than relying on the caller to set the flag properly.
+		 * VG locks alphabetical, ORPHAN lock last
 		 */
-		if (!_blocking_supported || vgs_locked())
+		if (!_blocking_supported)
 			flags |= LCK_NONBLOCK;
 
 		if (vol[0] != '#' &&


