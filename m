From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2009 17:21:17 -0000
Subject: LVM2/tools reporter.c
Message-ID: <20090110172117.14541.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-10 17:21:17

Modified files:
	tools          : reporter.c 

Log message:
	...and a few more uninitialised dummy fields.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/tools/reporter.c	2008/12/04 15:54:27	1.42
+++ LVM2/tools/reporter.c	2009/01/10 17:21:17	1.43
@@ -88,9 +88,12 @@
 
         _free_lv_segment.segtype = get_segtype_from_string(cmd, "free");
 	_free_lv_segment.len = pvseg->len;
+	dm_list_init(&_free_lv_segment.tags);
+	dm_list_init(&_free_lv_segment.origin_list);
 	dm_list_init(&_free_logical_volume.tags);
 	dm_list_init(&_free_logical_volume.segments);
 	dm_list_init(&_free_logical_volume.segs_using_this_lv);
+	dm_list_init(&_free_logical_volume.snapshot_segs);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
 			   seg ? : &_free_lv_segment, pvseg))


