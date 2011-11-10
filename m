From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 12:42:16 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111110124216.7348.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 12:42:15

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin align volume size on chunk boundary size
	
	If the extent_size is smaller then the chunk_size we may try
	to find better aligment (wasting less space).
	
	i.e. using  4KB extent_size and  64KB chunk size will
	lead to creation of 64KB aligned thin volume.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.327&r2=1.328

--- LVM2/lib/metadata/lv_manip.c	2011/11/10 12:39:01	1.327
+++ LVM2/lib/metadata/lv_manip.c	2011/11/10 12:42:15	1.328
@@ -2051,6 +2051,7 @@
 	struct lv_segment *seg;
 	struct logical_volume *thin_pool_lv = NULL;
 	struct lv_list *lvl;
+	uint32_t size;
 
 	if (thin_pool_name) {
 		if (!(lvl = find_lv_in_vg(lv->vg, thin_pool_name))) {
@@ -2059,6 +2060,17 @@
 			return 0;
 		}
 		thin_pool_lv = lvl->lv;
+		size = first_seg(thin_pool_lv)->data_block_size;
+		if (lv->vg->extent_size < size) {
+			/* Align extents on chunk boundary size */
+			size = ((uint64_t)lv->vg->extent_size * extents + size - 1) /
+				size * size / lv->vg->extent_size;
+			if (size != extents) {
+				log_print("Rounding size (%d extents) up to chunk boundary "
+					  "size (%d extents).", extents, size);
+				extents = size;
+			}
+		}
 	}
 
 	if ((seg = last_seg(lv)) && (seg->segtype == segtype)) {


