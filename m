From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 12 May 2009 19:09:22 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20090512190922.28498.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-12 19:09:21

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Fix first_seg() call for empty segment list.
	
	The seg variable is temporary variable for list iterator,
	code cannot expect that after iteration it remains NULL
	(it contains non-NULL pointer here id list is empty).
	
	Patch fixes first_seg function so it now correctly returns NULL
	for empty segment list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1099&r2=1.1100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.213&r2=1.214

--- LVM2/WHATS_NEW	2009/05/11 10:28:45	1.1099
+++ LVM2/WHATS_NEW	2009/05/12 19:09:21	1.1100
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix first_seg() call for empty segment list.
   Add make install_lvm2 as complement to device-mapper install.
   Reject missing PVs from allocation in toollib.
   Fix PV datalignment for values starting prior to MDA area. (2.02.45)
--- LVM2/lib/metadata/metadata.c	2009/04/28 17:46:47	1.213
+++ LVM2/lib/metadata/metadata.c	2009/05/12 19:09:21	1.214
@@ -1108,12 +1108,12 @@
 
 struct lv_segment *first_seg(const struct logical_volume *lv)
 {
-	struct lv_segment *seg = NULL;
+	struct lv_segment *seg;
 
 	dm_list_iterate_items(seg, &lv->segments)
-		break;
+		return seg;
 
-	return seg;
+	return NULL;
 }
 
 /* Find segment at a given physical extent in a PV */


