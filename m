From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Apr 2012 12:30:50 -0000
Subject: LVM2/tools lvresize.c
Message-ID: <20120411123050.6401.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-11 12:30:49

Modified files:
	tools          : lvresize.c 

Log message:
	Move check for min strip size
	
	and remove few asigns that are not needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152

--- LVM2/tools/lvresize.c	2012/03/05 15:05:25	1.151
+++ LVM2/tools/lvresize.c	2012/04/11 12:30:48	1.152
@@ -367,12 +367,12 @@
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
-	uint32_t stripesize_extents = 0;
-	uint32_t seg_stripes = 0, seg_stripesize = 0, seg_size = 0;
+	uint32_t stripesize_extents;
+	uint32_t seg_stripes = 0, seg_stripesize = 0, seg_size;
 	uint32_t seg_mirrors = 0;
-	uint32_t extents_used = 0;
+	uint32_t extents_used;
 	uint32_t size_rest;
-	uint32_t pv_extent_count = 0;
+	uint32_t pv_extent_count;
 	alloc_policy_t alloc;
 	struct logical_volume *lock_lv;
 	struct lv_list *lvl;
@@ -665,6 +665,12 @@
 	}
 
 	if (lp->stripes > 1) {
+		if (lp->stripe_size < STRIPE_SIZE_MIN) {
+			log_error("Invalid stripe size %s",
+				  display_size(cmd, (uint64_t) lp->stripe_size));
+			return EINVALID_CMD_LINE;
+		}
+
 		if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
 			stripesize_extents = 1;
 
@@ -684,11 +690,6 @@
 			lp->extents = lp->extents - size_rest;
 		}
 
-		if (lp->stripe_size < STRIPE_SIZE_MIN) {
-			log_error("Invalid stripe size %s",
-				  display_size(cmd, (uint64_t) lp->stripe_size));
-			return EINVALID_CMD_LINE;
-		}
 	}
 
 	if (lp->extents < lv->le_count) {


