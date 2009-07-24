From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jul 2009 18:26:42 -0000
Subject: LVM2/lib/locking locking.h
Message-ID: <20090724182642.10077.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-24 18:26:42

Modified files:
	lib/locking    : locking.h 

Log message:
	remove no-longer-needed NONBLOCK

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/lib/locking/locking.h	2009/07/24 18:15:07	1.49
+++ LVM2/lib/locking/locking.h	2009/07/24 18:26:42	1.50
@@ -118,7 +118,7 @@
 	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
 
 #define lock_lv_vol(cmd, lv, flags)	\
-	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv) | LCK_NONBLOCK)
+	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
 
 #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
 #define unlock_and_release_vg(cmd, vg, vol) \


