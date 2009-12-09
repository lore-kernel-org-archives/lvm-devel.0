From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 18:45:14 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20091209184514.9550.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 18:45:13

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Allow implicit "convert" to the same lock mode.
	
	(Code already not fail if unlocking not locked resource.)
	
	This is needed in pre/post lock_lv call, where we can
	request the same lock on local node becuase of suspend call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1344&r2=1.1345
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/WHATS_NEW	2009/12/09 18:42:02	1.1344
+++ LVM2/WHATS_NEW	2009/12/09 18:45:12	1.1345
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Allow implicit convert to the same cluster lock mode.
   Replace magic masks in cluster locking code by defined masks.
   Remove log volume from metadata if initial deactivation fails.
   Give better error message for pvmove when all data is skipped.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 18:42:03	1.73
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/12/09 18:45:13	1.74
@@ -245,6 +245,11 @@
 
 	lvi = lookup_info(resource);
 
+	if (lvi && lvi->lock_mode == mode) {
+		DEBUGLOG("hold_lock, lock mode %d already held\n", mode);
+		return 0;
+	}
+
 	/* Only allow explicit conversions */
 	if (lvi && !(flags & LKF_CONVERT)) {
 		errno = EBUSY;


