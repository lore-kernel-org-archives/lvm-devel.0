From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Feb 2011 19:21:48 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c lib/locking ...
Message-ID: <20110204192148.22647.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-04 19:21:47

Modified files:
	daemons/clvmd  : lvm-functions.c 
	lib/locking    : no_locking.c 

Log message:
	Remove extra sync calls.
	
	Remove temporaly added fs_unlock() calls to fix clmvd usablity.
	Now when the message passing is properly working - they are no longer needed.
	Simplify no_locking  check for VG unlock - as message is always send
	for all targets - clustered & non-clustered.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/daemons/clvmd/lvm-functions.c	2011/02/03 16:03:13	1.109
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/02/04 19:21:47	1.110
@@ -507,7 +507,6 @@
 	switch (command & LCK_MASK) {
 	case LCK_LV_EXCLUSIVE:
 		status = do_activate_lv(resource, lock_flags, LCK_EXCL);
-		fs_unlock();
 		break;
 
 	case LCK_LV_SUSPEND:
@@ -517,17 +516,14 @@
 	case LCK_UNLOCK:
 	case LCK_LV_RESUME:	/* if active */
 		status = do_resume_lv(resource, lock_flags);
-		fs_unlock();
 		break;
 
 	case LCK_LV_ACTIVATE:
 		status = do_activate_lv(resource, lock_flags, LCK_READ);
-		fs_unlock();
 		break;
 
 	case LCK_LV_DEACTIVATE:
 		status = do_deactivate_lv(resource, lock_flags);
-		fs_unlock();
 		break;
 
 	default:
--- LVM2/lib/locking/no_locking.c	2011/02/02 20:04:39	1.26
+++ LVM2/lib/locking/no_locking.c	2011/02/04 19:21:47	1.27
@@ -38,9 +38,7 @@
 {
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
-		if (!strcmp(resource, VG_SYNC_NAMES) ||
-		    (((flags & LCK_TYPE_MASK) == LCK_UNLOCK) &&
-		     is_real_vg(resource)))
+		if (!strcmp(resource, VG_SYNC_NAMES))
 			fs_unlock();
 		break;
 	case LCK_LV:


