From: agk@sourceware.org <agk@sourceware.org>
Date: 8 May 2008 18:35:59 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20080508183559.4540.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-08 18:35:58

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	Avoid unnecessary unlock attempts with LCK_CACHE pseudo-locks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.869&r2=1.870
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2008/05/08 18:28:27	1.869
+++ LVM2/WHATS_NEW	2008/05/08 18:35:58	1.870
@@ -5,6 +5,7 @@
 
 Version 2.02.37 - 
 =================================
+  Avoid unnecessary unlock attempts with LCK_CACHE pseudo-locks.
   When asked to drop cached committed VG metadata, invalidate cached PV labels.
   Drop metadata cache before writing precommitted metadata instead of after.
   Don't touch /dev in vgrename if activation is disabled.
--- LVM2/lib/locking/locking.c	2008/04/15 14:46:19	1.47
+++ LVM2/lib/locking/locking.c	2008/05/08 18:35:58	1.48
@@ -370,8 +370,12 @@
 	if (!_lock_vol(cmd, resource, flags))
 		return 0;
 
-	/* Perform immediate unlock unless LCK_HOLD set */
-	if (!(flags & LCK_HOLD) && ((flags & LCK_TYPE_MASK) != LCK_UNLOCK)) {
+	/*
+	 * If a real lock was acquired (i.e. not LCK_CACHE),
+	 * perform an immediate unlock unless LCK_HOLD was requested.
+	 */
+	if (!(flags & LCK_CACHE) && !(flags & LCK_HOLD) &&
+	    ((flags & LCK_TYPE_MASK) != LCK_UNLOCK)) {
 		if (!_lock_vol(cmd, resource,
 			       (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK))
 			return 0;


