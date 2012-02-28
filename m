From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 10:08:21 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120228100821.14862.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 10:08:20

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Explicitely check list size of segments
	
	instead of checking for NULL from last_seg and first_seg.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.366&r2=1.367

--- LVM2/lib/metadata/lv_manip.c	2012/02/23 22:24:47	1.366
+++ LVM2/lib/metadata/lv_manip.c	2012/02/28 10:08:20	1.367
@@ -2093,7 +2093,8 @@
 		}
 	}
 
-	if ((seg = last_seg(lv)) && (seg->segtype == segtype)) {
+	if (!dm_list_empty(&lv->segments) &&
+	    (seg = last_seg(lv)) && (seg->segtype == segtype)) {
 		seg->area_len += extents;
 		seg->len += extents;
 	} else {
@@ -2411,7 +2412,7 @@
 	char img_name[len];
 	struct lv_segment *mapseg;
 
-	if (lv->le_count || first_seg(lv)) {
+	if (lv->le_count || !dm_list_empty(&lv->segments)) {
 		log_error(INTERNAL_ERROR
 			  "Non-empty LV passed to _lv_insert_empty_sublv");
 		return 0;


