From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Dec 2006 22:48:47 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c
Message-ID: <20061201224847.22529.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-12-01 22:48:47

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 

Log message:
	Fix VG clustered read locks to use PR not CR.
	
	VG metadata reads were not being locked out during metadata updates.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.512&r2=1.513
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/WHATS_NEW	2006/11/30 23:11:39	1.512
+++ LVM2/WHATS_NEW	2006/12/01 22:48:47	1.513
@@ -1,5 +1,6 @@
 Version 2.02.16 -
 ====================================
+  Fix VG clustered read locks to use PR not CR.
   Adjust some alignments for ia64/sparc.
   Fix mirror segment removal to use temporary error segment.
   Always compile debug logging into clvmd.
--- LVM2/daemons/clvmd/clvmd-command.c	2006/10/09 14:11:57	1.11
+++ LVM2/daemons/clvmd/clvmd-command.c	2006/12/01 22:48:47	1.12
@@ -191,7 +191,11 @@
 	    dm_hash_remove(lock_hash, lockname);
     }
     else {
-
+	/* Read locks need to be PR; other modes get passed through */
+	if ((lock_cmd & LCK_TYPE_MASK) == LCK_READ) {
+	    lock_cmd &= ~LCK_TYPE_MASK;
+	    lock_cmd |= LKM_PRMODE;
+	}
 	status = sync_lock(lockname, (int)lock_cmd, (lock_flags & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
 	if (status)
 	    status = errno;


