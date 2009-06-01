From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 1 Jun 2009 14:23:39 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20090601142339.13771.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-01 14:23:38

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Fix log allocation segfault (fix previous commits).
	
	If there is no free area for log, code should break the loop.
	(Otherwise it uses uninitializes areas later.)
	
	Easily reproducible using lvconvert --repair
	- kill device with log
	- run lvconvert --repair vg/lv (with no PV usable for log)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179

--- LVM2/lib/metadata/lv_manip.c	2009/05/30 00:09:27	1.178
+++ LVM2/lib/metadata/lv_manip.c	2009/06/01 14:23:38	1.179
@@ -1124,6 +1124,13 @@
 		if ((contiguous || cling) && (preferred_count < ix_offset))
 			break;
 
+		log_needs_allocating = (ah->log_count && !ah->log_area.len) ?
+				       1 : 0;
+
+		if (ix + ix_offset < ah->area_count +
+		   (log_needs_allocating ? ah->log_count : 0))
+			break;
+
 		/* sort the areas so we allocate from the biggest */
 		if (ix > 1)
 			qsort(areas + ix_offset, ix, sizeof(*areas),
@@ -1136,9 +1143,6 @@
 		 * FIXME decide which PV to use at top of function instead
 		 */
 
-		log_needs_allocating = (ah->log_count && !ah->log_area.len) ?
-				       1 : 0;
-
 		too_small_for_log_count = 0;
 
 		if (!log_needs_allocating) {


