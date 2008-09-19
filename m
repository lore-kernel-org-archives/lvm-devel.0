From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 04:30:03 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20080919043003.11645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 04:30:02

Modified files:
	lib/metadata   : mirror.c 

Log message:
	remove unsed var

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/lib/metadata/mirror.c	2008/09/19 00:20:39	1.76
+++ LVM2/lib/metadata/mirror.c	2008/09/19 04:30:02	1.77
@@ -491,7 +491,6 @@
 	struct logical_volume *detached_log_lv = NULL;
 	struct logical_volume *lv1 = NULL;
 	struct lv_segment *mirrored_seg = first_seg(lv);
-	struct lv_segment_area area;
 	uint32_t old_area_count = mirrored_seg->area_count;
 	uint32_t new_area_count = mirrored_seg->area_count;
 	struct lv_list *lvl;


