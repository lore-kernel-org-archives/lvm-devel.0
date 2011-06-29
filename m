From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 17:05:54 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20110629170554.23557.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 17:05:53

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Reinstate correct permissions when creating mirrors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2030&r2=1.2031
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.264&r2=1.265

--- LVM2/WHATS_NEW	2011/06/29 14:56:33	1.2030
+++ LVM2/WHATS_NEW	2011/06/29 17:05:53	1.2031
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Reinstate correct permissions when creating mirrors. [2.02.85]
   Append 'm' attribute to pv_attr for missing PVs.
   Annotate CLVMD_CMD_SYNC_NAMES in decode_cmd.
   Remove enforcement of udev verification when using non-standard /dev location.
--- LVM2/lib/metadata/lv_manip.c	2011/06/23 14:00:58	1.264
+++ LVM2/lib/metadata/lv_manip.c	2011/06/29 17:05:53	1.265
@@ -2157,7 +2157,8 @@
 
 	for (i = 0; i < devices; i++) {
 		sub_lv = lv_create_empty(img_name, NULL,
-					 MIRROR_IMAGE, lv->alloc, lv->vg);
+					 LVM_READ | LVM_WRITE | MIRROR_IMAGE,
+					 lv->alloc, lv->vg);
 		if (!sub_lv)
 			return_0;
 		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, status))


