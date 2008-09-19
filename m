From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 03:45:34 -0000
Subject: LVM2/tools vgreduce.c
Message-ID: <20080919034534.32711.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 03:45:34

Modified files:
	tools          : vgreduce.c 

Log message:
	remove unused var

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/tools/vgreduce.c	2008/09/18 19:56:50	1.81
+++ LVM2/tools/vgreduce.c	2008/09/19 03:45:34	1.82
@@ -139,7 +139,6 @@
 	struct logical_volume *lv;
 	struct physical_volume *pv;
 	struct lv_segment *seg, *mirrored_seg;
-	struct lv_segment_area area;
 	unsigned s;
 	uint32_t mimages, remove_log;
 	int list_unsafe, only_mirror_images_found;


