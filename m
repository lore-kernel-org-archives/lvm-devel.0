From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Nov 2007 02:55:23 -0000
Subject: LVM2/lib/locking locking.h
Message-ID: <20071115025523.30602.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-15 02:55:22

Modified files:
	lib/locking    : locking.h 

Log message:
	define LCK_NONE for cases when vg_lock_and_read already holds lock
	(temporary - library will use internal ref counting instead)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/lib/locking/locking.h	2007/08/23 15:02:26	1.35
+++ LVM2/lib/locking/locking.h	2007/11/15 02:55:22	1.36
@@ -86,6 +86,8 @@
 /*
  * Common combinations
  */
+#define LCK_NONE		0
+
 #define LCK_VG_READ		(LCK_VG | LCK_READ | LCK_HOLD)
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)


