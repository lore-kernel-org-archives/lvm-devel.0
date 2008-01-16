From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 19:38:39 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20080116193839.24454.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 19:38:39

Modified files:
	lib/metadata   : mirror.c 

Log message:
	cope with stacked LVs as well as PVs when deciding which bits of mirrors to remove

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/lib/metadata/mirror.c	2008/01/16 19:18:51	1.57
+++ LVM2/lib/metadata/mirror.c	2008/01/16 19:38:39	1.58
@@ -347,9 +347,12 @@
 
 	list_iterate_items(seg, &mimage_lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) != AREA_PV)
-				/* FIXME Recurse for AREA_LV */
-				continue;
+			if (seg_type(seg, s) != AREA_PV) {
+				/* FIXME Recurse for AREA_LV? */
+				/* Structure of seg_lv is unknown.
+				 * Not removing this LV for safety. */
+				return 0;
+			}
 
 			pv = seg_pv(seg, s);
 


