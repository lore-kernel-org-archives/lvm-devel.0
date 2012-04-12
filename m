From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Apr 2012 15:11:21 -0000
Subject: LVM2/tools lvresize.c
Message-ID: <20120412151121.2204.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-04-12 15:11:21

Modified files:
	tools          : lvresize.c 

Log message:
	Remove 'up' from rounding message that sometimes rounds down.
	Detect reduction of 0 after rounding for stripes and avoid warning of potential data loss.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155

--- LVM2/tools/lvresize.c	2012/04/11 12:40:04	1.154
+++ LVM2/tools/lvresize.c	2012/04/12 15:11:21	1.155
@@ -454,6 +454,12 @@
 
 	alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, lv->alloc);
 
+	/*
+	 * First adjust to an exact multiple of extent size.
+	 * When extending by a relative amount we round that amount up.
+	 * When reducing by a relative amount we remove at most that amount.
+	 * When changing to an absolute size, we round that size up.
+	 */
 	if (lp->size) {
 		if (lp->size % vg->extent_size) {
 			if (lp->sign == SIGN_MINUS)
@@ -462,7 +468,7 @@
 				lp->size += vg->extent_size -
 				    (lp->size % vg->extent_size);
 
-			log_print("Rounding up size to full physical extent %s",
+			log_print("Rounding size to boundary between physical extents: %s",
 				  display_size(cmd, lp->size));
 		}
 
@@ -714,6 +720,15 @@
 			return EINVALID_CMD_LINE;
 		}
 		lp->resize = LV_EXTEND;
+	} else if (lp->extents == lv->le_count) {
+		if (use_policy)
+			return ECMD_PROCESSED; /* Nothing to do. */
+		if (!lp->resizefs) {
+			log_error("New size (%d extents) matches existing size "
+				  "(%d extents)", lp->extents, lv->le_count);
+			return EINVALID_CMD_LINE;
+		}
+		lp->resize = LV_EXTEND;
 	}
 
 	if (lv_is_origin(lv)) {


