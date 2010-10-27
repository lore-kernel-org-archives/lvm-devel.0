From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Oct 2010 09:15:49 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101027091549.21598.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-27 09:15:48

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1780&r2=1.1781

--- LVM2/WHATS_NEW	2010/10/26 09:13:13	1.1780
+++ LVM2/WHATS_NEW	2010/10/27 09:15:48	1.1781
@@ -1,5 +1,7 @@
 Version 2.02.76
 ===================================
+  Fix a deadlock caused by double close in clvmd.
+  Add dmeventd -R to restart dmeventd without losing monitoring state. (2.02.75)
   Fix NULL pointer dereference for too large MDA error path in _vg_read_raw_area().
   Use static for internal _align_chunk() and _new_chunk() from pool-fast.c.
   Fix vgchange to process -a, --refresh, --monitor and --poll like lvchange.


