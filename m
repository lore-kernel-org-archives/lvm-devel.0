From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Apr 2012 12:33:37 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20120411123337.7848.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-11 12:33:35

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Support rounding downward for lvcreate and %
	
	If specifying size with % and we are reaching number
	of free extents - round downward with stripes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2378&r2=1.2379
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.263&r2=1.264

--- LVM2/WHATS_NEW	2012/04/11 09:12:02	1.2378
+++ LVM2/WHATS_NEW	2012/04/11 12:33:34	1.2379
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  For lvcreate with %FREE support rounding downward strip alignment.
   Change message severity to log_very_verbose for missing dev info in udev db.
   Fix problems when specifying PVs during RAID down-converts.
   Fix ability to handle failures in mirrored log (regression intro 2.02.89).
--- LVM2/tools/lvcreate.c	2012/03/06 09:22:03	1.263
+++ LVM2/tools/lvcreate.c	2012/04/11 12:33:35	1.264
@@ -236,6 +236,8 @@
 	uint32_t pv_extent_count;
 	struct logical_volume *origin = NULL;
 	int changed = 0;
+	uint32_t size_rest;
+	uint32_t stripesize_extents;
 
 	if (lcp->size &&
 	    !(lp->extents = extents_from_size(vg->cmd, lcp->size,
@@ -294,6 +296,18 @@
 			break;
 	}
 
+	if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
+		stripesize_extents = 1;
+
+	if ((lcp->percent != PERCENT_NONE) && lp->stripes &&
+	    (size_rest = lp->extents % (lp->stripes * stripesize_extents)) &&
+	    (vg->free_count < lp->extents - size_rest + (lp->stripes * stripesize_extents))) {
+		log_print("Rounding size (%d extents) down to stripe boundary "
+			  "size (%d extents)", lp->extents,
+			  lp->extents - size_rest);
+		lp->extents = lp->extents - size_rest;
+	}
+
 	if (lp->create_thin_pool) {
 		if (!arg_count(vg->cmd, poolmetadatasize_ARG)) {
 			/* Defaults to nr_pool_blocks * 64b */


