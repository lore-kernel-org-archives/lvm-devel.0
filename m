From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Oct 2010 14:51:20 -0000
Subject: LVM2/daemons/clvmd clvmd-command.c
Message-ID: <20101020145120.28796.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-20 14:51:18

Modified files:
	daemons/clvmd  : clvmd-command.c 

Log message:
	Revert some debug statements that slipped in with last checkin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/daemons/clvmd/clvmd-command.c	2010/10/20 14:46:45	1.40
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/10/20 14:51:18	1.41
@@ -210,12 +210,9 @@
 
     if (lock_mode == LCK_UNLOCK) {
 
-        DEBUGLOG("PRE: UNLOCK\n");
 	lkid = (int)(long)dm_hash_lookup(lock_hash, lockname);
-	if (lkid == 0) {
-            DEBUGLOG("lock not found in table\n");
+	if (lkid == 0)
 	    return EINVAL;
-	}
 
 	status = sync_unlock(lockname, lkid);
 	if (status)
@@ -224,7 +221,6 @@
 	    dm_hash_remove(lock_hash, lockname);
     }
     else {
-        DEBUGLOG("PRE: LOCK\n");
 	/* Read locks need to be PR; other modes get passed through */
 	if (lock_mode == LCK_READ)
 	    lock_mode = LCK_PREAD;


