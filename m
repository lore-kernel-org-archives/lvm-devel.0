From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2011 12:08:43 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20110606120843.13575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-06 12:08:42

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	missing space in mesg

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.259&r2=1.260

--- LVM2/lib/metadata/lv_manip.c	2011/06/01 19:21:04	1.259
+++ LVM2/lib/metadata/lv_manip.c	2011/06/06 12:08:42	1.260
@@ -418,7 +418,7 @@
 	if (seg_is_striped(seg)) {
 		if (reduction % seg->area_count) {
 			log_error("Segment extent reduction %" PRIu32
-				  "not divisible by #stripes %" PRIu32,
+				  " not divisible by #stripes %" PRIu32,
 				  reduction, seg->area_count);
 			return 0;
 		}


