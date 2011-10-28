From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:29:33 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111028202933.6912.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:29:32

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin support for lvrename
	
	Rename pool's metadata lv _tmeta together with pool and _tdata.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.309&r2=1.310

--- LVM2/lib/metadata/lv_manip.c	2011/10/28 20:28:01	1.309
+++ LVM2/lib/metadata/lv_manip.c	2011/10/28 20:29:32	1.310
@@ -2745,6 +2745,8 @@
 	dm_list_iterate_items(seg, &lv->segments) {
 		if (seg->log_lv && !fn(cmd, seg->log_lv, data))
 			return_0;
+		if (seg->pool_metadata_lv && !fn(cmd, seg->pool_metadata_lv, data))
+			return_0;
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;


