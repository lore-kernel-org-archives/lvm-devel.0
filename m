From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 18:55:54 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20091209185554.18558.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 18:55:53

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Allow implicit lock conversion for pre/post callbacks.
	
	This is unnoticed regression from commit 31672ff60e405795cad70d6d7888ac011f5373ce
	
	The pre/post callback need to convert lock always, local node
	is going to modify metadata in this case, it it fails conversion,
	the call is ignored.
	
	Also it fixes bug when the lock is not yet held, we cannot set LKF_CONVERT
	in this case, it will fail because this lock do not exist.
	
	Note that the automatic conversion is still disabled in activate
	call, so the original fix (reactivation of exlusive LV) should
	be still in place.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1345&r2=1.1346
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/WHATS_NEW	2009/12/09 18:45:12	1.1345
+++ LVM2/WHATS_NEW	2009/12/09 18:55:53	1.1346
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Allow implicit lock conversion in pre/post callbacks on local node.
   Allow implicit convert to the same cluster lock mode.
   Replace magic masks in cluster locking code by defined masks.
   Remove log volume from metadata if initial deactivation fails.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 18:45:13	1.74
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 18:55:53	1.75
@@ -274,7 +274,7 @@
 			return -1;
 
 		lvi->lock_mode = mode;
-		status = sync_lock(resource, mode, flags, &lvi->lock_id);
+		status = sync_lock(resource, mode, flags & ~LKF_CONVERT, &lvi->lock_id);
 		saved_errno = errno;
 		if (status) {
 			free(lvi);
@@ -348,7 +348,11 @@
 		mode = LKM_EXMODE;
 	}
 
-	/* Try to get the lock if it's a clustered volume group */
+	/*
+	 * Try to get the lock if it's a clustered volume group.
+	 * Use lock conversion only if requested, to prevent implicit conversion
+	 * of exclusive lock to shared one during activation.
+	 */
 	if (lock_flags & LCK_CLUSTER_VG) {
 		status = hold_lock(resource, mode, LKF_NOQUEUE | (lock_flags & LCK_CONVERT?LKF_CONVERT:0));
 		if (status) {
@@ -546,12 +550,13 @@
 	/* Nearly all the stuff happens cluster-wide. Apart from SUSPEND. Here we get the
 	   lock out on this node (because we are the node modifying the metadata)
 	   before suspending cluster-wide.
+	   LKF_CONVERT is used always, local node is going to modify metadata
 	 */
 	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_SUSPEND) {
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
-		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE| (lock_flags & LCK_CONVERT?LKF_CONVERT:0)))
+		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE | LKF_CONVERT))
 			return errno;
 	}
 	return 0;
@@ -583,7 +588,7 @@
 				return EIO;
 
 			if (lvi.exists) {
-				if (hold_lock(resource, LKM_CRMODE, lock_flags & LCK_CONVERT?LKF_CONVERT:0))
+				if (hold_lock(resource, LKM_CRMODE, LKF_CONVERT))
 					return errno;
 			} else {
 				if (hold_unlock(resource))


