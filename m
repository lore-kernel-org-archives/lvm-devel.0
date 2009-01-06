From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Jan 2009 17:24:22 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20090106172422.552.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-01-06 17:24:21

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Fix "Calculate mirror log size" commit, the le_count should be always set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163

--- LVM2/lib/metadata/lv_manip.c	2008/12/19 15:26:02	1.162
+++ LVM2/lib/metadata/lv_manip.c	2009/01/06 17:24:21	1.163
@@ -844,7 +844,7 @@
 
 	/* FIXME only_single_area_segments used as workaround to skip log LV - needs new param? */
 	if (!only_single_area_segments && seg_is_mirrored(seg) && seg->log_lv) {
-		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, seg->log_lv->le_count?:1,
+		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, seg->log_lv->le_count,
 				       NULL, 0, 0, 0, only_single_area_segments,
 				       fn, data)))
 			stack;


