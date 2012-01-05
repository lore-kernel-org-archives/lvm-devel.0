From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Jan 2012 15:38:21 -0000
Subject: LVM2 ./WHATS_NEW man/lvextend.8.in man/lvreduc ...
Message-ID: <20120105153821.20278.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-05 15:38:19

Modified files:
	.              : WHATS_NEW 
	man            : lvextend.8.in lvreduce.8.in lvresize.8.in 
	tools          : lvcreate.c lvresize.c toollib.c tools.h 

Log message:
	Support rounding of percentage upward
	
	We want to keep this logic -
	when LV is extend - extend the LV by at least given amount,
	when LV is reduced - reduce the LV by at most given amount.
	
	So for this the rounding needs to be used.
	Current logic which seems to satisfy give rule is to round up all
	extent values for LV resize upward except for values with '-' sign
	that are round downward.
	
	This patch also fixes the problem when  lvextend --use-polices tried
	to extend LV the by i.e. 20% - but the resulting 20% were smaller
	the extent size thus before this patch no extension happened.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2216&r2=1.2217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.251&r2=1.252
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.236&r2=1.237
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/WHATS_NEW	2011/12/22 16:37:01	1.2216
+++ LVM2/WHATS_NEW	2012/01/05 15:38:18	1.2217
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Supports rounding of percentage (%LV, %VG...) for LV resize upward.
   Use dmeventd_lvm2_command in dmeventd plugins snapshot, raid, mirror.
   Add helper dmeventd_lvm2_command() into libdevmapper-event-lvm2 library.
   Updated documentation for dmeventd.
--- LVM2/man/lvextend.8.in	2010/06/21 15:56:59	1.8
+++ LVM2/man/lvextend.8.in	2012/01/05 15:38:18	1.9
@@ -43,6 +43,7 @@
 as a percentage of the remaining free space in the Volume Group
 with the suffix %FREE, or (for a snapshot) as a percentage of the total
 space in the Origin Logical Volume with the suffix %ORIGIN.
+The resulting value is rounded upward.
 .TP
 .I \-L, \-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Extend or set the logical volume size in units of megabytes.
--- LVM2/man/lvreduce.8.in	2011/09/07 08:50:35	1.9
+++ LVM2/man/lvreduce.8.in	2012/01/05 15:38:18	1.10
@@ -66,6 +66,8 @@
 remaining free space in the Volume Group with the suffix \fI%FREE\fP, or (for
 a snapshot) as a percentage of the total space in the Origin Logical
 Volume with the suffix \fI%ORIGIN\fP.
+The resulting value for the substraction is rounded downward, for the absolute
+size it is rounded upward.
 .TP
 .IR \fB\-L ", " \fB\-\-size " [" \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Reduce or set the logical volume size in units of megabytes.
--- LVM2/man/lvresize.8.in	2011/09/07 08:50:35	1.10
+++ LVM2/man/lvresize.8.in	2012/01/05 15:38:18	1.11
@@ -54,15 +54,18 @@
 suffix \fI%PVS\fP, as a percentage of the remaining free space in the
 Volume Group with the suffix \fI%FREE\fP, or (for a snapshot) as a percentage
 of the total space in the Origin Logical Volume with the suffix \fI%ORIGIN\fP.
+The resulting value is rounded downward for the substraction otherwise
+it is rounded upward.
 .TP
 .IR \fB\-L ", " \fB\-\-size " [" + | - ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Change or set the logical volume size in units of megabytes.
 A size suffix of \fIM\fP for megabytes,
 \fIG\fP for gigabytes, \fIT\fP for terabytes, \fIP\fP for petabytes
 or \fIE\fP for exabytes is optional.
-With the \fI+\fP or \fI-\fP sign the value is added to or subtracted from
-the actual size of the logical volume and without it, the value is taken as an
-absolute one.
+With the \fI+\fP or \fI-\fP sign the value is added or subtracted
+from the actual size of the logical volume and rounded
+to the full extent size and without it,
+the value is taken as an absolute one.
 .TP
 .BR \-i ", " \-\-stripes " " \fIStripes
 Gives the number of stripes to use when extending a Logical Volume.
--- LVM2/tools/lvcreate.c	2011/12/21 12:54:19	1.251
+++ LVM2/tools/lvcreate.c	2012/01/05 15:38:19	1.252
@@ -257,17 +257,17 @@
 
 	switch(lcp->percent) {
 		case PERCENT_VG:
-			lp->extents = percent_of_extents(lp->extents, vg->extent_count);
+			lp->extents = percent_of_extents(lp->extents, vg->extent_count, 0);
 			break;
 		case PERCENT_FREE:
-			lp->extents = percent_of_extents(lp->extents, vg->free_count);
+			lp->extents = percent_of_extents(lp->extents, vg->free_count, 0);
 			break;
 		case PERCENT_PVS:
 			if (!lcp->pv_count)
-				lp->extents = percent_of_extents(lp->extents, vg->extent_count);
+				lp->extents = percent_of_extents(lp->extents, vg->extent_count, 0);
 			else {
 				pv_extent_count = pv_list_extents_free(lp->pvh);
-				lp->extents = percent_of_extents(lp->extents, pv_extent_count);
+				lp->extents = percent_of_extents(lp->extents, pv_extent_count, 0);
 			}
 			break;
 		case PERCENT_LV:
@@ -285,7 +285,7 @@
 				log_error(INTERNAL_ERROR "Couldn't find origin volume.");
 				return 0;
 			}
-			lp->extents = percent_of_extents(lp->extents, origin->le_count);
+			lp->extents = percent_of_extents(lp->extents, origin->le_count, 0);
 			break;
 		case PERCENT_NONE:
 			break;
--- LVM2/tools/lvresize.c	2011/12/21 13:10:53	1.145
+++ LVM2/tools/lvresize.c	2012/01/05 15:38:19	1.146
@@ -464,27 +464,33 @@
 
 	switch(lp->percent) {
 		case PERCENT_VG:
-			lp->extents = percent_of_extents(lp->extents, vg->extent_count);
+			lp->extents = percent_of_extents(lp->extents, vg->extent_count,
+							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_FREE:
-			lp->extents = percent_of_extents(lp->extents, vg->free_count);
+			lp->extents = percent_of_extents(lp->extents, vg->free_count,
+							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_LV:
-			lp->extents = percent_of_extents(lp->extents, lv->le_count);
+			lp->extents = percent_of_extents(lp->extents, lv->le_count,
+							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_PVS:
 			if (lp->argc) {
 				pv_extent_count = pv_list_extents_free(pvh);
-				lp->extents = percent_of_extents(lp->extents, pv_extent_count);
+				lp->extents = percent_of_extents(lp->extents, pv_extent_count,
+								 (lp->sign != SIGN_MINUS));
 			} else
-				lp->extents = percent_of_extents(lp->extents, vg->extent_count);
+				lp->extents = percent_of_extents(lp->extents, vg->extent_count,
+								 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_ORIGIN:
 			if (!lv_is_cow(lv)) {
 				log_error("Specified LV does not have an origin LV.");
 				return EINVALID_CMD_LINE;
 			}
-			lp->extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count);
+			lp->extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count,
+							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_NONE:
 			break;
--- LVM2/tools/toollib.c	2011/11/18 19:19:22	1.236
+++ LVM2/tools/toollib.c	2012/01/05 15:38:19	1.237
@@ -1630,8 +1630,9 @@
 	return 1;
 }
 
-/* Return percents of extents and avoid overflow */
-uint32_t percent_of_extents(uint32_t percents, uint32_t count)
+/* Return percents of extents and avoid overflow, with optional roundup */
+uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
 {
-	return (uint32_t)((uint64_t)percents * (uint64_t)count / 100);
+	return (uint32_t)(((uint64_t)percents * (uint64_t)count +
+			   ((roundup) ? 99 : 0)) / 100);
 }
--- LVM2/tools/tools.h	2011/09/15 15:26:40	1.77
+++ LVM2/tools/tools.h	2012/01/05 15:38:19	1.78
@@ -181,5 +181,5 @@
 int mirror_remove_missing(struct cmd_context *cmd,
 			  struct logical_volume *lv, int force);
 
-uint32_t percent_of_extents(uint32_t percents, uint32_t count);
+uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup);
 #endif


