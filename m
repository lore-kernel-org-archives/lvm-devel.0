From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Jan 2010 16:07:58 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20100105160758.25280.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-05 16:07:57

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 
	lib/locking    : cluster_locking.c 

Log message:
	Proper mask lock mode for vg lock.
	
	Lock mode is int masked by LCK_TYPE_MASK, always.
	
	Patch also remove uneccessary masking lock flag on sender side,
	if masking is needed, it is don on client side already.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1359&r2=1.1360
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW	2010/01/05 16:06:42	1.1359
+++ LVM2/WHATS_NEW	2010/01/05 16:07:56	1.1360
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Use proper mask for VG lock mode in clvmd.
   Add possibility to drop precommitted metadata in lvmcache.
   Move processing of VG locks to separate function in clvmd.
   Properly decode flags even for VG locks.
--- LVM2/daemons/clvmd/clvmd-command.c	2010/01/05 16:05:12	1.30
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/01/05 16:07:57	1.31
@@ -193,6 +193,7 @@
 	(struct clvm_header *) client->bits.localsock.cmd;
     unsigned char lock_cmd;
     unsigned char lock_flags;
+    int lock_mode;
     char *args = header->node + strlen(header->node) + 1;
     int lkid;
     int status = 0;
@@ -212,11 +213,12 @@
     }
 
     lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
+    lock_mode = ((int)lock_cmd & LCK_TYPE_MASK);
     lock_flags = args[1];
     lockname = &args[2];
     DEBUGLOG("doing PRE command LOCK_VG '%s' at %x (client=%p)\n", lockname, lock_cmd, client);
 
-    if (lock_cmd == LCK_UNLOCK) {
+    if (lock_mode == LCK_UNLOCK) {
 
 	lkid = (int)(long)dm_hash_lookup(lock_hash, lockname);
 	if (lkid == 0)
@@ -230,11 +232,9 @@
     }
     else {
 	/* Read locks need to be PR; other modes get passed through */
-	if ((lock_cmd & LCK_TYPE_MASK) == LCK_READ) {
-	    lock_cmd &= ~LCK_TYPE_MASK;
-	    lock_cmd |= LCK_PREAD;
-	}
-	status = sync_lock(lockname, (int)lock_cmd, (lock_cmd & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
+	if (lock_mode == LCK_READ)
+	    lock_mode = LCK_PREAD;
+	status = sync_lock(lockname, lock_mode, (lock_cmd & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
 	if (status)
 	    status = errno;
 	else
--- LVM2/lib/locking/cluster_locking.c	2010/01/05 16:03:37	1.39
+++ LVM2/lib/locking/cluster_locking.c	2010/01/05 16:07:57	1.40
@@ -409,7 +409,6 @@
 
 		lock_scope = "VG";
 		clvmd_cmd = CLVMD_CMD_LOCK_VG;
-		flags &= LCK_TYPE_MASK;
 		break;
 
 	case LCK_LV:


