From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 09:52:38 -0000
Subject: LVM2/lib/locking locking.h
Message-ID: <20120227095238.2699.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 09:52:37

Modified files:
	lib/locking    : locking.h 

Log message:
	Ignore result of unlock explicitely

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/lib/locking/locking.h	2012/01/21 05:29:52	1.74
+++ LVM2/lib/locking/locking.h	2012/02/27 09:52:37	1.75
@@ -163,7 +163,7 @@
 	do { \
 		if (is_real_vg(vol)) \
 			sync_dev_names(cmd); \
-		lock_vol(cmd, vol, LCK_VG_UNLOCK); \
+		(void) lock_vol(cmd, vol, LCK_VG_UNLOCK); \
 	} while (0)
 #define unlock_and_release_vg(cmd, vg, vol) \
 	do { \


