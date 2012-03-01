From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 10:09:37 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120301100937.11725.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 10:09:37

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Add stack trace for lv_reduce
	
	Use common code call with stack trace.
	
	TODO: maybe the release_lv_segment_area()
	should be actually able to return error code to upper level.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.368&r2=1.369

--- LVM2/lib/metadata/lv_manip.c	2012/02/29 22:08:58	1.368
+++ LVM2/lib/metadata/lv_manip.c	2012/03/01 10:09:36	1.369
@@ -312,13 +312,10 @@
 		return;
 	}
 
-	if (seg_lv(seg, s)->status & MIRROR_IMAGE) {
-		lv_reduce(seg_lv(seg, s), area_reduction);
-		return;
-	}
-
-	if (seg_lv(seg, s)->status & THIN_POOL_DATA) {
-		lv_reduce(seg_lv(seg, s), area_reduction);
+	if ((seg_lv(seg, s)->status & MIRROR_IMAGE) ||
+	    (seg_lv(seg, s)->status & THIN_POOL_DATA)) {
+		if (!lv_reduce(seg_lv(seg, s), area_reduction))
+			stack; /* FIXME: any upper level reporting */
 		return;
 	}
 


