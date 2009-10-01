From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 1 Oct 2009 14:15:34 -0000
Subject: LVM2/lib/locking locking.h
Message-ID: <20091001141534.9497.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-10-01 14:15:34

Modified files:
	lib/locking    : locking.h 

Log message:
	Add LCK_CONVERT flag I missed on the last checkin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/lib/locking/locking.h	2009/09/02 21:34:11	1.51
+++ LVM2/lib/locking/locking.h	2009/10/01 14:15:34	1.52
@@ -90,6 +90,7 @@
 #define LCK_PARTIAL_MODE        0x00000001U	/* Partial activation? */
 #define LCK_MIRROR_NOSYNC_MODE	0x00000002U	/* Mirrors don't require sync */
 #define LCK_DMEVENTD_MONITOR_MODE	0x00000004U	/* Register with dmeventd */
+#define LCK_CONVERT		0x00000008U	/* Convert existing lock */
 
 /*
  * Special cases of VG locks.


