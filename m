From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Dec 2011 11:34:36 -0000
Subject: LVM2/lib/locking locking.h
Message-ID: <20111203113436.32562.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-12-03 11:34:36

Modified files:
	lib/locking    : locking.h 

Log message:
	Switch locking bits to match RHEL5 version.
	
	FIXME:
	There is a problem with overloaded bit 0x80 in locking flag,
	the bit flags array must be extended or changed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/lib/locking/locking.h	2011/11/30 17:00:58	1.70
+++ LVM2/lib/locking/locking.h	2011/12/03 11:34:35	1.71
@@ -94,7 +94,8 @@
 #define LCK_NONBLOCK	0x00000010U	/* Don't block waiting for lock? */
 #define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
 #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
-#define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
+// FIXME: not used in lock bit byte
+//#define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
 #define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
 #define LCK_ORIGIN_ONLY	0x00000200U	/* Operation should bypass any snapshots */
 #define LCK_REVERT	0x00000400U	/* Revert any incomplete change */
@@ -106,10 +107,13 @@
 #define LCK_MIRROR_NOSYNC_MODE		0x02	/* Mirrors don't require sync */
 #define LCK_DMEVENTD_MONITOR_MODE	0x04	/* Register with dmeventd */
 #define LCK_CONVERT			0x08	/* Convert existing lock */
-#define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */
 #define LCK_TEST_MODE			0x10    /* Test mode: No activation */
-#define LCK_REVERT_MODE			0x40	/* Remove inactive tables */
-#define LCK_DMEVENTD_MONITOR_IGNORE     0x80	/* Whether to ignore dmeventd */
+#define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */
+#define LCK_DMEVENTD_MONITOR_IGNORE     0x40	/* Whether to ignore dmeventd */
+
+// FIXME: conlict here (CLUSTER_VG is used in lock bits byte)
+#define LCK_REVERT_MODE			0x80	/* Remove inactive tables */
+#define LCK_CLUSTER_VG			0x80	/* VG is clustered */
 
 /*
  * Special cases of VG locks.


