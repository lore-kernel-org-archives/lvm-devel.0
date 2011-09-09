From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Sep 2011 01:15:20 -0000
Subject: LVM2 lib/metadata/lv.c lib/metadata/metadata.h ...
Message-ID: <20110909011520.6664.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-09 01:15:18

Modified files:
	lib/metadata   : lv.c metadata.h thin_manip.c 
	man            : lvs.8.in 

Log message:
	Append z to lv_attr if new blocks will be zeroed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.255&r2=1.256
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/lib/metadata/lv.c	2011/09/09 00:54:49	1.26
+++ LVM2/lib/metadata/lv.c	2011/09/09 01:15:18	1.27
@@ -308,9 +308,10 @@
 {
 	percent_t snap_percent;
 	struct lvinfo info;
+	struct lv_segment *seg;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 8))) {
+	if (!(repstr = dm_pool_zalloc(mem, 9))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -405,6 +406,13 @@
 	else
 		repstr[6] = '-';
 
+	if ((lv_is_thin_volume(lv) && (seg = first_seg(lv)) && seg->pool_lv && (seg = first_seg(seg->pool_lv))) ||
+	    (lv_is_thin_pool(lv) && (seg = first_seg(lv))) &&
+	    seg->zero_new_blocks)
+		repstr[7] = 'z';
+	else
+		repstr[7] = '-';
+
 out:
 	return repstr;
 }
--- LVM2/lib/metadata/metadata.h	2011/09/08 16:41:19	1.255
+++ LVM2/lib/metadata/metadata.h	2011/09/09 01:15:18	1.256
@@ -372,7 +372,7 @@
 struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le);
 
 /* Find pool LV segment given a thin pool data or metadata segment. */
-struct lv_segment *find_pool_seg(struct lv_segment *seg);
+struct lv_segment *find_pool_seg(const struct lv_segment *seg);
 
 /*
  * Remove a dev_dir if present.
--- LVM2/lib/metadata/thin_manip.c	2011/09/08 16:41:19	1.3
+++ LVM2/lib/metadata/thin_manip.c	2011/09/09 01:15:18	1.4
@@ -61,7 +61,7 @@
 	return remove_seg_from_segs_using_this_lv(seg->pool_lv, seg);
 }
 
-struct lv_segment *find_pool_seg(struct lv_segment *seg)
+struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 {
         struct lv_segment *pool_seg;
 
--- LVM2/man/lvs.8.in	2011/09/09 00:54:49	1.15
+++ LVM2/man/lvs.8.in	2011/09/09 01:15:18	1.16
@@ -94,6 +94,8 @@
 equivalents using the md raid kernel driver all appear as (r).
 Snapshots using the original device-mapper driver appear as (s); whereas
 snapshots of thin volumes using the new thin provisioning driver appear as (t).
+.IP 8 3
+Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
 .RE
 .TP
 .I \-\-segments


