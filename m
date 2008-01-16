From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 19:13:52 -0000
Subject: LVM2/lib/metadata metadata-exported.h mirror.c
Message-ID: <20080116191352.14101.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 19:13:51

Modified files:
	lib/metadata   : metadata-exported.h mirror.c 

Log message:
	export find_temporary_mirror()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/lib/metadata/metadata-exported.h	2008/01/16 19:00:59	1.35
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/16 19:13:51	1.36
@@ -472,6 +472,7 @@
 		      struct list *pvs, uint32_t status_mask);
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
+struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
                                     uint32_t region_size);
--- LVM2/lib/metadata/mirror.c	2008/01/16 19:11:39	1.55
+++ LVM2/lib/metadata/mirror.c	2008/01/16 19:13:51	1.56
@@ -54,7 +54,7 @@
  * Return a temporary LV for resyncing added mirror image.
  * Add other mirror legs to lvs list.
  */
-static struct logical_volume *_find_tmp_mirror(struct logical_volume *lv)
+struct logical_volume *find_temporary_mirror(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
@@ -562,7 +562,7 @@
 	struct logical_volume *tmp_lv;
 	struct lv_segment *mirror_seg;
 
-	while ((tmp_lv = _find_tmp_mirror(lv))) {
+	while ((tmp_lv = find_temporary_mirror(lv))) {
 		mirror_seg = find_mirror_seg(first_seg(tmp_lv));
 		if (!mirror_seg) {
 			log_error("Failed to find mirrored LV for %s",


