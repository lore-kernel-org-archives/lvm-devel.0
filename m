From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 6 Aug 2010 15:38:35 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c tools/l ...
Message-ID: <20100806153835.29635.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-08-06 15:38:33

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 
	tools          : lvconvert.c 

Log message:
	Fix for bug 619221 - log device splitting regression
	
	An incorrect fix on July 13, 2010 for an annoyance has caused a regression.
	The offending check-in was part of the 2.02.71 release of LVM.  That
	check-in caused any PVs specified on the command line to be ignored when
	performing a mirror split.
	
	This patch reverses the aforementioned check-in (solving the regressions)
	and posits a new solution to the list reversal problem.  The original
	problem was that we would always take the lowest mimage LVs from a mirror
	when performing a split, but what we really want is to take the highest
	mimage LVs.  This patch accomplishes that by working through the list in
	reverse order - choosing the higher numbered mimages first.  (This also
	reduces the amount of processing necessary.)
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
	Reviewed-by: Takahiro Yasui <takahiro.yasui@hds.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1696&r2=1.1697
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145

--- LVM2/WHATS_NEW	2010/08/04 18:18:18	1.1696
+++ LVM2/WHATS_NEW	2010/08/06 15:38:32	1.1697
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Split-mirror operations were ignoring user-specified PVs.
   Fix data corruption bug in cluster mirrors.
   Require logical volume(s) to be explicitly named for lvconvert --merge.
   Avoid changing aligned pe_start as a side-effect of very verbose logging.
--- LVM2/lib/metadata/mirror.c	2010/08/02 21:07:41	1.130
+++ LVM2/lib/metadata/mirror.c	2010/08/06 15:38:32	1.131
@@ -524,34 +524,22 @@
 					  uint32_t count,
 					  struct dm_list *removable_pvs)
 {
-	int i, images;
+	int i;
 	struct logical_volume *sub_lv;
 	struct lv_segment *mirrored_seg = first_seg(lv);
 
 	if (!removable_pvs)
 		return 1;
 
-	/*
-	 * When we shift an image to the end, we must start from
-	 * the begining of the list again.  We must visit the
-	 * images up to the last one we just moved.
-	 */
-	for (images = mirrored_seg->area_count; images && count; images--) {
-		for (i = 0; i < images; i++) {
-			sub_lv = seg_lv(mirrored_seg, i);
-
-			if (!is_temporary_mirror_layer(sub_lv) &&
-			    is_mirror_image_removable(sub_lv, removable_pvs)) {
-				if (!shift_mirror_images(mirrored_seg, i))
-					return_0;
-				count--;
-				break;
-			}
-		}
+	for (i = mirrored_seg->area_count - 1; (i >= 0) && count; i--) {
+		sub_lv = seg_lv(mirrored_seg, i);
 
-		/* Did we shift any images? */
-		if (i == images)
-			return 0;
+		if (!is_temporary_mirror_layer(sub_lv) &&
+		    is_mirror_image_removable(sub_lv, removable_pvs)) {
+			if (!shift_mirror_images(mirrored_seg, i))
+				return_0;
+			count--;
+		}
 	}
 
 	return !count;
--- LVM2/tools/lvconvert.c	2010/08/03 20:22:31	1.144
+++ LVM2/tools/lvconvert.c	2010/08/06 15:38:32	1.145
@@ -1015,7 +1015,7 @@
 						  lv->le_count,
 						  lp->region_size);
 
-	if (!operable_pvs && !lp->keep_mimages)
+	if (!operable_pvs)
 		operable_pvs = lp->pvh;
 
 	seg = first_seg(lv);


