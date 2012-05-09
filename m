From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 May 2012 12:12:22 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20120509121222.26252.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-05-09 12:12:22

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix regression in for_each_sub_lv
	
	pool_lv is not a sub lv in terms for this function.
	It has caused problem with renaming thin_volume, where it has tried to
	rename pool LV as well.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2397&r2=1.2398
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.374&r2=1.375

--- LVM2/WHATS_NEW	2012/05/05 02:08:46	1.2397
+++ LVM2/WHATS_NEW	2012/05/09 12:12:21	1.2398
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix lvrename for thin volumes (regression in for_each_sub_lv() 2.02.89).
   Fix up-convert when mirror activation is controled by volume_list and tags.
   Disallow snapshots of mirror segment type.
   Fix bug in cmirror that caused incorrect status info to print on some nodes.
--- LVM2/lib/metadata/lv_manip.c	2012/05/05 02:08:47	1.374
+++ LVM2/lib/metadata/lv_manip.c	2012/05/09 12:12:21	1.375
@@ -2814,13 +2814,6 @@
 				return_0;
 		}
 
-		if (seg->pool_lv) {
-			if (!fn(cmd, seg->pool_lv, data))
-				return_0;
-			if (!for_each_sub_lv(cmd, seg->pool_lv, fn, data))
-				return_0;
-		}
-
 		if (seg->metadata_lv) {
 			if (!fn(cmd, seg->metadata_lv, data))
 				return_0;


