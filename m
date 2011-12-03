From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Dec 2011 11:36:11 -0000
Subject: LVM2/lib/locking locking.h
Message-ID: <20111203113611.28192.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-12-03 11:36:10

Modified files:
	lib/locking    : locking.h 

Log message:
	Fix FIXME and comment :-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/lib/locking/locking.h	2011/12/03 11:34:35	1.71
+++ LVM2/lib/locking/locking.h	2011/12/03 11:36:10	1.72
@@ -94,7 +94,7 @@
 #define LCK_NONBLOCK	0x00000010U	/* Don't block waiting for lock? */
 #define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
 #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
-// FIXME: not used in lock bit byte
+// FIXME: not used in lock bits
 //#define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
 #define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
 #define LCK_ORIGIN_ONLY	0x00000200U	/* Operation should bypass any snapshots */
@@ -111,7 +111,7 @@
 #define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */
 #define LCK_DMEVENTD_MONITOR_IGNORE     0x40	/* Whether to ignore dmeventd */
 
-// FIXME: conlict here (CLUSTER_VG is used in lock bits byte)
+// FIXME: conflict here (CLUSTER_VG is used here)
 #define LCK_REVERT_MODE			0x80	/* Remove inactive tables */
 #define LCK_CLUSTER_VG			0x80	/* VG is clustered */
 


