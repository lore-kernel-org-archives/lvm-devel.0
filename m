From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Apr 2008 10:29:01 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20080403102901.2986.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-03 10:29:00

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	fix vd->virtblk

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.818&r2=1.819
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/WHATS_NEW	2008/04/02 21:23:38	1.818
+++ LVM2/WHATS_NEW	2008/04/03 10:29:00	1.819
@@ -22,7 +22,7 @@
   Use return_0 in a couple more places.
   Correct a function name typo in _line_append error message.
   Include limits.h in clvmd so it compiles with newer headers.
-  Add VirtIO disks (vd) to filters.
+  Add VirtIO disks (virtblk) to filters.
   Fix resetting of MIRROR_IMAGE and VISIBLE_LV after removal of LV. (2.02.30)
   Fix remove_layer_from_lv to empty the LV before removing it. (2.02.30)
   Add missing no-longer-used segs_using_this_lv test to check_lv_segments.
--- LVM2/lib/filters/filter.c	2008/03/05 18:15:04	1.45
+++ LVM2/lib/filters/filter.c	2008/04/03 10:29:00	1.46
@@ -77,7 +77,7 @@
 	{"xvd", 16},		/* Xen virtual block device */
 	{"vdisk", 8},		/* SUN's LDOM virtual block device */
 	{"ps3disk", 16},	/* PlayStation 3 internal disk */
-	{"vd", 8},		/* VirtIO disk */
+	{"virtblk", 8},		/* VirtIO disk */
 	{NULL, 0}
 };
 


