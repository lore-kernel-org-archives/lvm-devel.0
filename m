From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Dec 2011 18:09:48 -0000
Subject: LVM2/lib/locking locking.h
Message-ID: <20111208180948.4884.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-08 18:09:48

Modified files:
	lib/locking    : locking.h 

Log message:
	Update comments.  CLUSTER_VG belongs firmly to args[0].

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/lib/locking/locking.h	2011/12/03 11:36:10	1.72
+++ LVM2/lib/locking/locking.h	2011/12/08 18:09:48	1.73
@@ -89,13 +89,14 @@
 #define LCK_LV		0x00000008U
 
 /*
- * Lock bits
+ * Lock bits.
+ * Bottom 8 bits except LCK_LOCAL form args[0] in cluster comms.
  */
 #define LCK_NONBLOCK	0x00000010U	/* Don't block waiting for lock? */
 #define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
+#define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
+
 #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
-// FIXME: not used in lock bits
-//#define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
 #define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
 #define LCK_ORIGIN_ONLY	0x00000200U	/* Operation should bypass any snapshots */
 #define LCK_REVERT	0x00000400U	/* Revert any incomplete change */
@@ -106,14 +107,14 @@
 #define LCK_PARTIAL_MODE        	0x01	/* Partial activation? */
 #define LCK_MIRROR_NOSYNC_MODE		0x02	/* Mirrors don't require sync */
 #define LCK_DMEVENTD_MONITOR_MODE	0x04	/* Register with dmeventd */
+
+/* Not yet used. */
 #define LCK_CONVERT			0x08	/* Convert existing lock */
+
 #define LCK_TEST_MODE			0x10    /* Test mode: No activation */
 #define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */
 #define LCK_DMEVENTD_MONITOR_IGNORE     0x40	/* Whether to ignore dmeventd */
-
-// FIXME: conflict here (CLUSTER_VG is used here)
 #define LCK_REVERT_MODE			0x80	/* Remove inactive tables */
-#define LCK_CLUSTER_VG			0x80	/* VG is clustered */
 
 /*
  * Special cases of VG locks.


