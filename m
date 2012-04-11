From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Apr 2012 12:36:39 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c
Message-ID: <20120411123639.8537.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-11 12:36:38

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c 

Log message:
	Lvresize rounds upward
	
	When given lvresize new size - round upward for stripes - unless we use % and
	we are at the border of free extents.
	
	This patch is not a complete fix and few more cases will need special care.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2379&r2=1.2380
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153

--- LVM2/WHATS_NEW	2012/04/11 12:33:34	1.2379
+++ LVM2/WHATS_NEW	2012/04/11 12:36:37	1.2380
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  For lvresize round upward when specifying number of extents.
   For lvcreate with %FREE support rounding downward strip alignment.
   Change message severity to log_very_verbose for missing dev info in udev db.
   Fix problems when specifying PVs during RAID down-converts.
--- LVM2/tools/lvresize.c	2012/04/11 12:30:48	1.152
+++ LVM2/tools/lvresize.c	2012/04/11 12:36:38	1.153
@@ -676,7 +676,11 @@
 
 		size_rest = seg_size % (lp->stripes * stripesize_extents);
 		/* Round toward the original size. */
-		if (size_rest && lp->extents < lv->le_count) {
+		if (size_rest &&
+		    ((lp->extents < lv->le_count) ||
+		     !lp->percent ||
+		     (vg->free_count >= (lp->extents - lv->le_count - size_rest +
+					 (lp->stripes * stripesize_extents))))) {
 			log_print("Rounding size (%d extents) up to stripe "
 				  "boundary size for segment (%d extents)",
 				  lp->extents, lp->extents - size_rest +
@@ -689,7 +693,6 @@
 				  lp->extents, lp->extents - size_rest);
 			lp->extents = lp->extents - size_rest;
 		}
-
 	}
 
 	if (lp->extents < lv->le_count) {


