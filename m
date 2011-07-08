From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 15:35:51 -0000
Subject: LVM2/lib/activate activate.c
Message-ID: <20110708153551.23550.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 15:35:50

Modified files:
	lib/activate   : activate.c 

Log message:
	Need to snapshot lookup by uuid instead of name in case it's renamed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.208&r2=1.209

--- LVM2/lib/activate/activate.c	2011/07/08 12:48:41	1.208
+++ LVM2/lib/activate/activate.c	2011/07/08 15:35:50	1.209
@@ -1214,9 +1214,9 @@
 		 */
 		if (!laopts->origin_only && lv_is_origin(lv)) {
         		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list) {
-				if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, snap_seg->cow->name))) {
-					log_error(INTERNAL_ERROR "LV %s missing from preload metadata",
-						  snap_seg->cow->name);
+				if (!(lvl_pre = find_lv_in_vg_by_lvid(lv_pre->vg, &snap_seg->cow->lvid))) {
+					log_error(INTERNAL_ERROR "LV %s (%s) missing from preload metadata",
+						  snap_seg->cow->name, snap_seg->cow->lvid.id[1].uuid);
 					goto out;
 				}
 				if (!lv_is_cow(lvl_pre->lv) &&


