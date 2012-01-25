From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jan 2012 17:14:57 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20120125171457.1556.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-25 17:14:56

Modified files:
	lib/display    : display.c 

Log message:
	& -> &&

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/lib/display/display.c	2012/01/24 00:55:03	1.126
+++ LVM2/lib/display/display.c	2012/01/25 17:14:56	1.127
@@ -487,7 +487,7 @@
 		  lv->name,
 		  lv->vg->name,
 		  ((lv->status & (LVM_READ | LVM_WRITE)) >> 8) |
-		  ((inkernel & info.read_only) ? 4 : 0), inkernel ? 1 : 0,
+		  ((inkernel && info.read_only) ? 4 : 0), inkernel ? 1 : 0,
 		  /* FIXME lv->lv_number,  */
 		  inkernel ? info.open_count : 0, lv->size, lv->le_count,
 		  /* FIXME Add num allocated to struct! lv->lv_allocated_le, */


