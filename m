From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Oct 2010 16:44:48 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101029164448.18989.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-29 16:44:47

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1781&r2=1.1782

--- LVM2/WHATS_NEW	2010/10/27 09:15:48	1.1781
+++ LVM2/WHATS_NEW	2010/10/29 16:44:47	1.1782
@@ -1,5 +1,6 @@
 Version 2.02.76
 ===================================
+  Automatically unmount invalidated snapshots in dmeventd.
   Fix a deadlock caused by double close in clvmd.
   Add dmeventd -R to restart dmeventd without losing monitoring state. (2.02.75)
   Fix NULL pointer dereference for too large MDA error path in _vg_read_raw_area().


