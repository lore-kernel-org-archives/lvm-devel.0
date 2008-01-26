From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2008 00:30:33 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/merge.c
Message-ID: <20080126003033.6983.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-26 00:30:33

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : merge.c 

Log message:
	Fix two check_lv_segments error messages to show whole segment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.778&r2=1.779
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW	2008/01/26 00:25:04	1.778
+++ LVM2/WHATS_NEW	2008/01/26 00:30:28	1.779
@@ -1,5 +1,6 @@
 Version 2.02.32 -
 ===================================
+  Fix two check_lv_segments error messages to show whole segment.
   Refactor mirror log attachment code.
   Fix internal metadata corruption in lvchange --resync. (2.02.30)
   Fix new parameter validation in vgsplit and test mode. (2.02.30)
--- LVM2/lib/metadata/merge.c	2008/01/16 19:00:59	1.31
+++ LVM2/lib/metadata/merge.c	2008/01/26 00:30:28	1.32
@@ -210,17 +210,18 @@
 		if (seg->log_lv == lv)
 			seg_found++;
 		if (!seg_found) {
-			log_error("LV %s is used by LV %s:%" PRIu32 ", "
-				  "but missing ptr from %s to %s",
+			log_error("LV %s is used by LV %s:%" PRIu32 "-%" PRIu32
+				  ", but missing ptr from %s to %s",
 				  lv->name, seg->lv->name, seg->le,
+				  seg->le + seg->len - 1,
 				  seg->lv->name, lv->name);
 			r = 0;
 		} else if (seg_found != sl->count) {
 			log_error("Reference count mismatch: LV %s has %d "
-				  "links to LV %s:%" PRIu32
+				  "links to LV %s:%" PRIu32 "-%" PRIu32
 				  ", which has %d links",
-				  lv->name, sl->count,
-				  seg->lv->name, seg->le, seg_found);
+				  lv->name, sl->count, seg->lv->name, seg->le,
+				  seg->le + seg->len - 1, seg_found);
 			r = 0;
 		}
 	}


