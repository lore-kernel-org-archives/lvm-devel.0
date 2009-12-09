From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 19:00:17 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20091209190017.22077.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 19:00:16

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Never ever use distributed lock for LV in non-clustered VG.
	
	The LV locks make sense only for clustered LVs.
	
	Properly check cluster flag and never issue cluster lock here.
	
	There are several places in code, where it is already checked, this
	patch add this check to all needed calls.
	
	In previous code the lock behaviour was inconsistent,
	for example, the pre/post callback can take lock even for local volume,
	but deactivate call do not released this lock and it remains held forever.
	
	The local LV lock request now just let run the underlying activation code
	on local node, the same process like in local locking.
	
	(Again, this is important for new mirror repair calls, here for local
	mirrors but with cluster locking enabled.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1346&r2=1.1347
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2009/12/09 18:55:53	1.1346
+++ LVM2/WHATS_NEW	2009/12/09 19:00:16	1.1347
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Never use distributed lock for LV in non-clustered VG.
   Allow implicit lock conversion in pre/post callbacks on local node.
   Allow implicit convert to the same cluster lock mode.
   Replace magic masks in cluster locking code by defined masks.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 18:55:53	1.75
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 19:00:16	1.76
@@ -331,7 +331,8 @@
 
 	/* Is it already open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == mode) {
+	if (oldmode == mode && (lock_flags & LCK_CLUSTER_VG)) {
+		DEBUGLOG("do_activate_lv, lock already held at %d\n", oldmode);
 		return 0;	/* Nothing to do */
 	}
 
@@ -384,13 +385,13 @@
 }
 
 /* Resume the LV if it was active */
-static int do_resume_lv(char *resource)
+static int do_resume_lv(char *resource, unsigned char lock_flags)
 {
 	int oldmode;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == -1) {
+	if (oldmode == -1 && (lock_flags & LCK_CLUSTER_VG)) {
 		DEBUGLOG("do_resume_lv, lock not already held\n");
 		return 0;	/* We don't need to do anything */
 	}
@@ -402,15 +403,15 @@
 }
 
 /* Suspend the device if active */
-static int do_suspend_lv(char *resource)
+static int do_suspend_lv(char *resource, unsigned char lock_flags)
 {
 	int oldmode;
 	struct lvinfo lvi;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == -1) {
-		DEBUGLOG("do_suspend_lv, lock held at %d\n", oldmode);
+	if (oldmode == -1 && (lock_flags & LCK_CLUSTER_VG)) {
+		DEBUGLOG("do_suspend_lv, lock not already held\n");
 		return 0; /* Not active, so it's OK */
 	}
 
@@ -502,14 +503,14 @@
 		break;
 
 	case LCK_LV_SUSPEND:
-		status = do_suspend_lv(resource);
+		status = do_suspend_lv(resource, lock_flags);
 		if (!status)
 			suspended++;
 		break;
 
 	case LCK_UNLOCK:
 	case LCK_LV_RESUME:	/* if active */
-		status = do_resume_lv(resource);
+		status = do_resume_lv(resource, lock_flags);
 		if (!status)
 			suspended--;
 		break;
@@ -552,7 +553,8 @@
 	   before suspending cluster-wide.
 	   LKF_CONVERT is used always, local node is going to modify metadata
 	 */
-	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_SUSPEND) {
+	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_SUSPEND &&
+	    (lock_flags & LCK_CLUSTER_VG)) {
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
@@ -569,7 +571,8 @@
 	int status;
 
 	/* Opposite of above, done on resume after a metadata update */
-	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_RESUME) {
+	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_RESUME &&
+	    (lock_flags & LCK_CLUSTER_VG)) {
 		int oldmode;
 
 		DEBUGLOG


