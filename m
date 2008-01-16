From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 19:18:51 -0000
Subject: LVM2/lib activate/activate.c metadata/mirror.c ...
Message-ID: <20080116191851.16805.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 19:18:51

Modified files:
	lib/activate   : activate.c 
	lib/metadata   : mirror.c 
	lib/mirror     : mirrored.c 

Log message:
	allow a mirror to contain only one mimage

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/lib/activate/activate.c	2008/01/09 15:32:19	1.129
+++ LVM2/lib/activate/activate.c	2008/01/16 19:18:50	1.130
@@ -508,6 +508,13 @@
 	struct dev_manager *dm;
 	struct lvinfo info;
 
+	/* If mirrored LV is temporarily shrinked to 1 area (= linear),
+	 * it should be considered in-sync. */
+	if (list_size(&lv->segments) == 1 && first_seg(lv)->area_count == 1) {
+		*percent = 100.0;
+		return 1;
+	}
+
 	if (!activation())
 		return 0;
 
--- LVM2/lib/metadata/mirror.c	2008/01/16 19:13:51	1.56
+++ LVM2/lib/metadata/mirror.c	2008/01/16 19:18:51	1.57
@@ -956,7 +956,7 @@
 	list_iterate_items(seg, &lv_mirr->segments) {
 		denominator += seg->area_len;
 
-		if (seg_is_mirrored(seg))
+		if (seg_is_mirrored(seg) && seg->area_count > 1)
 			numerator += seg->extents_copied;
 		else
 			numerator += seg->area_len;
--- LVM2/lib/mirror/mirrored.c	2008/01/16 15:24:25	1.47
+++ LVM2/lib/mirror/mirrored.c	2008/01/16 19:18:51	1.48
@@ -283,6 +283,11 @@
 
 	mirr_state = *target_state;
 
+	/* Mirror segment could have only 1 area temporarily,
+	 * if the segment is under conversion. */
+ 	if (seg->area_count == 1)
+		mirror_status = MIRR_DISABLED;
+
 	/*
 	 * For pvmove, only have one mirror segment RUNNING at once.
 	 * Segments before this are COMPLETED and use 2nd area.


