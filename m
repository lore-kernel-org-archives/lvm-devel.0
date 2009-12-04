From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 4 Dec 2009 14:26:23 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20091204142623.23994.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-12-04 14:26:23

Modified files:
	.              : WHATS_NEW 

Log message:
	WHATS_NEW for previous commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1341&r2=1.1342

--- LVM2/WHATS_NEW	2009/12/03 19:23:40	1.1341
+++ LVM2/WHATS_NEW	2009/12/04 14:26:22	1.1342
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Give better error message for pvmove when all data is skipped.
   Fix memory lock imbalance in lv_suspend if already suspended.
   Fix pvmove test mode to not fail and do not poll.
   Fix error message if VG already exist in vgcreate.


