From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jul 2007 18:50:03 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/merge.c
Message-ID: <20070710185003.14487.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-07-10 18:50:03

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : merge.c 

Log message:
	Cope with find_seg_by_le() failure in check_lv_segments().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.650&r2=1.651
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2007/07/10 17:51:26	1.650
+++ LVM2/WHATS_NEW	2007/07/10 18:50:02	1.651
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Cope with find_seg_by_le() failure in check_lv_segments().
   Call dev_iter_destroy() if _process_all_devs() is interrupted by sigint.
   Add vg_mda_count and pv_mda_count columns to reports.
   Fix dumpconfig to use log_print instead of stdout directly.
--- LVM2/lib/metadata/merge.c	2005/10/28 12:48:50	1.27
+++ LVM2/lib/metadata/merge.c	2007/07/10 18:50:03	1.28
@@ -146,9 +146,9 @@
 
 				if (complete_vg && seg_lv(seg, s) &&
 				    (seg_lv(seg, s)->status & MIRROR_IMAGE) &&
-				    (find_seg_by_le(seg_lv(seg, s),
-						    seg_le(seg, s))->mirror_seg
-							!= seg)) {
+				    (!(seg2 = find_seg_by_le(seg_lv(seg, s),
+							    seg_le(seg, s))) ||
+				     seg2->mirror_seg != seg)) {
 					log_error("LV %s: segment %u mirror "
 						  "image %u missing mirror ptr",
 						  lv->name, seg_count, s);


