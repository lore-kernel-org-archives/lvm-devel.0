From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Apr 2010 00:56:27 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100408005627.21193.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-08 00:56:26

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	missing ?:

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.226&r2=1.227

--- LVM2/lib/metadata/lv_manip.c	2010/04/08 00:52:41	1.226
+++ LVM2/lib/metadata/lv_manip.c	2010/04/08 00:56:26	1.227
@@ -2096,7 +2096,7 @@
 		if (!_for_each_pv(cmd, use_pvmove_parent_lv ? seg->pvmove_source_seg->lv : lv,
 				  use_pvmove_parent_lv ? seg->pvmove_source_seg->le : current_le,
 				  use_pvmove_parent_lv ? spvs->len * calc_area_multiple(seg->pvmove_source_seg->segtype, seg->pvmove_source_seg->area_count) : spvs->len,
-				  seg->pvmove_source_seg,
+				  use_pvmove_parent_lv ? seg->pvmove_source_seg : NULL,
 				  &spvs->len,
 				  0, 0, -1, 0, _add_pvs, (void *) spvs))
 			return_NULL;


