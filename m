From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Feb 2011 20:04:40 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c lib/locking ...
Message-ID: <20110202200440.15310.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-02 20:04:39

Modified files:
	daemons/clvmd  : lvm-functions.c 
	lib/locking    : no_locking.c 

Log message:
	Better fix for no-locking udev sync and clvmd
	
	This is better way how to fix clustered synchronization with udev.
	As the code for message passing needs fixed - put currently
	fs_unlock() after every active/deactive command in clvmd to
	ensure nodes are properly created in time.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/daemons/clvmd/lvm-functions.c	2011/01/12 20:42:50	1.106
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/02/02 20:04:39	1.107
@@ -507,6 +507,7 @@
 	switch (command & LCK_MASK) {
 	case LCK_LV_EXCLUSIVE:
 		status = do_activate_lv(resource, lock_flags, LCK_EXCL);
+		fs_unlock();
 		break;
 
 	case LCK_LV_SUSPEND:
@@ -520,10 +521,12 @@
 
 	case LCK_LV_ACTIVATE:
 		status = do_activate_lv(resource, lock_flags, LCK_READ);
+		fs_unlock();
 		break;
 
 	case LCK_LV_DEACTIVATE:
 		status = do_deactivate_lv(resource, lock_flags);
+		fs_unlock();
 		break;
 
 	default:
--- LVM2/lib/locking/no_locking.c	2011/01/12 20:42:51	1.25
+++ LVM2/lib/locking/no_locking.c	2011/02/02 20:04:39	1.26
@@ -38,7 +38,9 @@
 {
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
-		if (!strcmp(resource, VG_SYNC_NAMES))
+		if (!strcmp(resource, VG_SYNC_NAMES) ||
+		    (((flags & LCK_TYPE_MASK) == LCK_UNLOCK) &&
+		     is_real_vg(resource)))
 			fs_unlock();
 		break;
 	case LCK_LV:


