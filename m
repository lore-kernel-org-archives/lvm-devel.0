From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Jun 2011 10:56:52 -0000
Subject: LVM2/tools lvresize.c
Message-ID: <20110615105652.23542.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-15 10:56:52

Modified files:
	tools          : lvresize.c 

Log message:
	Fix lvreduce stripe rounding up from previous commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/tools/lvresize.c	2011/06/09 19:38:56	1.132
+++ LVM2/tools/lvresize.c	2011/06/15 10:56:52	1.133
@@ -609,8 +609,10 @@
 		if (size_rest && lp->resize == LV_REDUCE) {
 			log_print("Rounding size (%d extents) up to stripe "
 				  "boundary size for segment (%d extents)",
-				  lp->extents, lp->extents + size_rest);
-			lp->extents = lp->extents + size_rest;
+				  lp->extents, lp->extents - size_rest +
+				  (lp->stripes * stripesize_extents));
+			lp->extents = lp->extents - size_rest +
+				      (lp->stripes * stripesize_extents);
 		} else if (size_rest) {
 			log_print("Rounding size (%d extents) down to stripe "
 				  "boundary size for segment (%d extents)",


