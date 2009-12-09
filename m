From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 18:42:03 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20091209184203.6137.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 18:42:03

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c lvm-functions.c 

Log message:
	Get rid of magic masks in cluster locking code - clvmd part.
	
	- do_command and lock_vg expect flags (no change here)
	
	Bug fixes:
	- lock_vg should check for NONBLOCK on lock_cmd, flags have this bit masked-out
	
	- do_pre/post_command expect do not mask flag at all, this causes that
	the code inside is never run! (see following patches, these functions
	expect plain command without flags)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1343&r2=1.1344
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/WHATS_NEW	2009/12/09 18:09:52	1.1343
+++ LVM2/WHATS_NEW	2009/12/09 18:42:02	1.1344
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Replace magic masks in cluster locking code by defined masks.
   Remove log volume from metadata if initial deactivation fails.
   Give better error message for pvmove when all data is skipped.
   Fix memory lock imbalance in lv_suspend if already suspended.
--- LVM2/daemons/clvmd/clvmd-command.c	2009/05/19 10:39:00	1.28
+++ LVM2/daemons/clvmd/clvmd-command.c	2009/12/09 18:42:03	1.29
@@ -132,7 +132,7 @@
 
 	case CLVMD_CMD_LOCK_LV:
 		/* This is the biggie */
-		lock_cmd = args[0] & 0x3F;
+		lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
 		lock_flags = args[1];
 		lockname = &args[2];
 		status = do_lock_lv(lock_cmd, lock_flags, lockname);
@@ -214,7 +214,7 @@
 	client->bits.localsock.private = (void *)lock_hash;
     }
 
-    lock_cmd = args[0] & 0x3F;
+    lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
     lock_flags = args[1];
     lockname = &args[2];
     DEBUGLOG("doing PRE command LOCK_VG '%s' at %x (client=%p)\n", lockname, lock_cmd, client);
@@ -237,7 +237,7 @@
 	    lock_cmd &= ~LCK_TYPE_MASK;
 	    lock_cmd |= LCK_PREAD;
 	}
-	status = sync_lock(lockname, (int)lock_cmd, (lock_flags & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
+	status = sync_lock(lockname, (int)lock_cmd, (lock_cmd & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
 	if (status)
 	    status = errno;
 	else
--- LVM2/daemons/clvmd/lvm-functions.c	2009/11/23 10:44:51	1.72
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 18:42:03	1.73
@@ -542,7 +542,7 @@
 	   lock out on this node (because we are the node modifying the metadata)
 	   before suspending cluster-wide.
 	 */
-	if (command == LCK_LV_SUSPEND) {
+	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_SUSPEND) {
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
@@ -559,7 +559,7 @@
 	int status;
 
 	/* Opposite of above, done on resume after a metadata update */
-	if (command == LCK_LV_RESUME) {
+	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_RESUME) {
 		int oldmode;
 
 		DEBUGLOG


