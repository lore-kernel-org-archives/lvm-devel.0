From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Dec 2011 18:32:37 -0000
Subject: LVM2/daemons/clvmd clvmd-command.c lvm-functions.c
Message-ID: <20111208183237.15966.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-08 18:32:34

Modified files:
	daemons/clvmd  : clvmd-command.c lvm-functions.c 

Log message:
	Test for LCK_CLUSTER_VG directly in args[0].
	Drop unused LCK_LOCAL from debug msg.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/daemons/clvmd/clvmd-command.c	2011/09/26 07:51:24	1.61
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/12/08 18:32:33	1.62
@@ -120,7 +120,7 @@
 
 	case CLVMD_CMD_LOCK_LV:
 		/* This is the biggie */
-		lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
+		lock_cmd = args[0];
 		lock_flags = args[1];
 		lockname = &args[2];
 		if (lock_flags & LCK_TEST_MODE)
--- LVM2/daemons/clvmd/lvm-functions.c	2011/11/30 17:00:58	1.126
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/12/08 18:32:34	1.127
@@ -109,10 +109,9 @@
 		break;
 	}
 
-	sprintf(buf, "0x%x %s (%s|%s%s%s%s%s%s)", cmdl, command, type, scope,
+	sprintf(buf, "0x%x %s (%s|%s%s%s%s%s)", cmdl, command, type, scope,
 		cmdl & LCK_NONBLOCK   ? "|NONBLOCK" : "",
 		cmdl & LCK_HOLD       ? "|HOLD" : "",
-		cmdl & LCK_LOCAL      ? "|LOCAL" : "",
 		cmdl & LCK_CLUSTER_VG ? "|CLUSTER_VG" : "",
 		cmdl & LCK_CACHE      ? "|CACHE" : "");
 
@@ -332,7 +331,7 @@
 */
 
 /* Activate LV exclusive or non-exclusive */
-static int do_activate_lv(char *resource, unsigned char lock_flags, int mode)
+static int do_activate_lv(char *resource, unsigned char command, unsigned char lock_flags, int mode)
 {
 	int oldmode;
 	int status;
@@ -342,7 +341,7 @@
 
 	/* Is it already open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == mode && (lock_flags & LCK_CLUSTER_VG)) {
+	if (oldmode == mode && (command & LCK_CLUSTER_VG)) {
 		DEBUGLOG("do_activate_lv, lock already held at %d\n", oldmode);
 		return 0;	/* Nothing to do */
 	}
@@ -365,7 +364,7 @@
 	 * Use lock conversion only if requested, to prevent implicit conversion
 	 * of exclusive lock to shared one during activation.
 	 */
-	if (lock_flags & LCK_CLUSTER_VG) {
+	if (command & LCK_CLUSTER_VG) {
 		status = hold_lock(resource, mode, LCKF_NOQUEUE | (lock_flags & LCK_CONVERT ? LCKF_CONVERT:0));
 		if (status) {
 			/* Return an LVM-sensible error for this.
@@ -405,13 +404,13 @@
 }
 
 /* Resume the LV if it was active */
-static int do_resume_lv(char *resource, unsigned char lock_flags)
+static int do_resume_lv(char *resource, unsigned char command, unsigned char lock_flags)
 {
 	int oldmode, origin_only, exclusive, revert;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == -1 && (lock_flags & LCK_CLUSTER_VG)) {
+	if (oldmode == -1 && (command & LCK_CLUSTER_VG)) {
 		DEBUGLOG("do_resume_lv, lock not already held\n");
 		return 0;	/* We don't need to do anything */
 	}
@@ -426,7 +425,7 @@
 }
 
 /* Suspend the device if active */
-static int do_suspend_lv(char *resource, unsigned char lock_flags)
+static int do_suspend_lv(char *resource, unsigned char command, unsigned char lock_flags)
 {
 	int oldmode;
 	struct lvinfo lvi;
@@ -434,7 +433,7 @@
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == -1 && (lock_flags & LCK_CLUSTER_VG)) {
+	if (oldmode == -1 && (command & LCK_CLUSTER_VG)) {
 		DEBUGLOG("do_suspend_lv, lock not already held\n");
 		return 0; /* Not active, so it's OK */
 	}
@@ -449,14 +448,14 @@
 	return 0;
 }
 
-static int do_deactivate_lv(char *resource, unsigned char lock_flags)
+static int do_deactivate_lv(char *resource, unsigned char command, unsigned char lock_flags)
 {
 	int oldmode;
 	int status;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == -1 && (lock_flags & LCK_CLUSTER_VG)) {
+	if (oldmode == -1 && (command & LCK_CLUSTER_VG)) {
 		DEBUGLOG("do_deactivate_lock, lock not already held\n");
 		return 0;	/* We don't need to do anything */
 	}
@@ -464,7 +463,7 @@
 	if (!lv_deactivate(cmd, resource))
 		return EIO;
 
-	if (lock_flags & LCK_CLUSTER_VG) {
+	if (command & LCK_CLUSTER_VG) {
 		status = hold_unlock(resource);
 		if (status)
 			return errno;
@@ -529,24 +528,24 @@
 
 	switch (command & LCK_MASK) {
 	case LCK_LV_EXCLUSIVE:
-		status = do_activate_lv(resource, lock_flags, LCK_EXCL);
+		status = do_activate_lv(resource, command, lock_flags, LCK_EXCL);
 		break;
 
 	case LCK_LV_SUSPEND:
-		status = do_suspend_lv(resource, lock_flags);
+		status = do_suspend_lv(resource, command, lock_flags);
 		break;
 
 	case LCK_UNLOCK:
 	case LCK_LV_RESUME:	/* if active */
-		status = do_resume_lv(resource, lock_flags);
+		status = do_resume_lv(resource, command, lock_flags);
 		break;
 
 	case LCK_LV_ACTIVATE:
-		status = do_activate_lv(resource, lock_flags, LCK_READ);
+		status = do_activate_lv(resource, command, lock_flags, LCK_READ);
 		break;
 
 	case LCK_LV_DEACTIVATE:
-		status = do_deactivate_lv(resource, lock_flags);
+		status = do_deactivate_lv(resource, command, lock_flags);
 		break;
 
 	default:
@@ -577,7 +576,7 @@
 	   LCKF_CONVERT is used always, local node is going to modify metadata
 	 */
 	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_SUSPEND &&
-	    (lock_flags & LCK_CLUSTER_VG)) {
+	    (command & LCK_CLUSTER_VG)) {
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
@@ -596,7 +595,7 @@
 
 	/* Opposite of above, done on resume after a metadata update */
 	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_RESUME &&
-	    (lock_flags & LCK_CLUSTER_VG)) {
+	    (command & LCK_CLUSTER_VG)) {
 		int oldmode;
 
 		DEBUGLOG


