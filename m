From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Mar 2008 18:15:05 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter.c
Message-ID: <20080305181505.29665.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-03-05 18:15:05

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter.c 

Log message:
	add vd to filters

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.798&r2=1.799
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW	2008/02/22 13:28:29	1.798
+++ LVM2/WHATS_NEW	2008/03/05 18:15:02	1.799
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add VirtIO disks (vd) to filters.
   Fix resetting of MIRROR_IMAGE and VISIBLE_LV after removal of LV. (2.02.30)
   Fix remove_layer_from_lv to empty the LV before removing it. (2.02.30)
   Add missing no-longer-used segs_using_this_lv test to check_lv_segments.
--- LVM2/lib/filters/filter.c	2008/01/30 13:19:45	1.44
+++ LVM2/lib/filters/filter.c	2008/03/05 18:15:04	1.45
@@ -77,6 +77,7 @@
 	{"xvd", 16},		/* Xen virtual block device */
 	{"vdisk", 8},		/* SUN's LDOM virtual block device */
 	{"ps3disk", 16},	/* PlayStation 3 internal disk */
+	{"vd", 8},		/* VirtIO disk */
 	{NULL, 0}
 };
 


