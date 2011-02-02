From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Feb 2011 13:34:01 -0000
Subject: LVM2 daemons/clvmd/clvmd-command.c lib/locking ...
Message-ID: <20110202133401.23822.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-02 13:34:01

Modified files:
	daemons/clvmd  : clvmd-command.c 
	lib/locking    : file_locking.c locking.c 

Log message:
	Revert wrong fix for nolock locking missing fs_unlock
	
	Patch was wrond and introduced recursive lock_vol
	Reverting it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/daemons/clvmd/clvmd-command.c	2011/01/31 19:52:41	1.50
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/02/02 13:34:00	1.51
@@ -217,6 +217,7 @@
 	if (lkid == 0)
 	    return EINVAL;
 
+	lvm_do_fs_unlock(); /* Wait for devices */
 	status = sync_unlock(lockname, lkid);
 	if (status)
 	    status = errno;
--- LVM2/lib/locking/file_locking.c	2011/01/31 19:52:41	1.55
+++ LVM2/lib/locking/file_locking.c	2011/02/02 13:34:00	1.56
@@ -215,6 +215,7 @@
 		state = 'W';
 		break;
 	case LCK_UNLOCK:
+		fs_unlock(); /* Wait until devices are available */
 		return _release_lock(file, 1);
 	default:
 		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
--- LVM2/lib/locking/locking.c	2011/01/31 19:52:41	1.90
+++ LVM2/lib/locking/locking.c	2011/02/02 13:34:00	1.91
@@ -442,10 +442,6 @@
 		/* If LVM1 driver knows about the VG, it can't be accessed. */
 		if (!check_lvm1_vg_inactive(cmd, vol))
 			return_0;
-
-		/* Before unlocking VG wait until devices are available. */
-		if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
-			sync_local_dev_names(cmd);
 		break;
 	case LCK_LV:
 		/* All LV locks are non-blocking. */


