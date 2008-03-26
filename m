From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Mar 2008 16:48:13 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c lib/met ...
Message-ID: <20080326164813.23513.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-26 16:48:10

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 
	lib/metadata   : metadata-exported.h metadata.c pv_manip.c 

Log message:
	Add pvseg_is_allocated() for identifying a PV segment allocated to a LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.808&r2=1.809
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2008/03/26 16:20:54	1.808
+++ LVM2/WHATS_NEW	2008/03/26 16:48:09	1.809
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add pvseg_is_allocated() for identifying a PV segment allocated to a LV.
   Add list_move() for moving elements from one list to another.
   Add 'is_reserved_lvname()' for identifying hidden LVs.
   Correct command name in lvmdiskscan man page.
--- LVM2/lib/display/display.c	2008/02/06 15:47:27	1.86
+++ LVM2/lib/display/display.c	2008/03/26 16:48:10	1.87
@@ -270,7 +270,7 @@
 		log_print("Physical extent %u to %u:",
 			  pvseg->pe, pvseg->pe + pvseg->len - 1);
 
-		if (pvseg->lvseg) {
+		if (pvseg_is_allocated(pvseg)) {
 			log_print("  Logical volume\t%s%s/%s",
 				  pvseg->lvseg->lv->vg->cmd->dev_dir,
 				  pvseg->lvseg->lv->vg->name,
--- LVM2/lib/metadata/metadata-exported.h	2008/03/13 22:51:24	1.45
+++ LVM2/lib/metadata/metadata-exported.h	2008/03/26 16:48:10	1.46
@@ -151,6 +151,8 @@
 	uint32_t lv_area;	/* Index to area in LV segment */
 };
 
+#define pvseg_is_allocated(pvseg) ((pvseg)->lvseg)
+
 struct physical_volume {
 	struct id id;
 	struct device *dev;
--- LVM2/lib/metadata/metadata.c	2008/03/17 16:51:31	1.160
+++ LVM2/lib/metadata/metadata.c	2008/03/26 16:48:10	1.161
@@ -612,7 +612,7 @@
 
 		/* foreach free PV Segment */
 		list_iterate_items(pvseg, &pv->segments) {
-			if (pvseg->lvseg)
+			if (pvseg_is_allocated(pvseg))
 				continue;
 
 			if (!_recalc_extents(&pvseg->pe, pv_dev_name(pv),
--- LVM2/lib/metadata/pv_manip.c	2008/01/30 14:00:00	1.20
+++ LVM2/lib/metadata/pv_manip.c	2008/03/26 16:48:10	1.21
@@ -233,7 +233,7 @@
 	list_iterate_items(pvl, pvh) {
 		list_iterate_items(per, pvl->pe_ranges) {
 			list_iterate_items(pvseg, &pvl->pv->segments) {
-				if (!pvseg->lvseg) /* free space */
+				if (!pvseg_is_allocated(pvseg))
 					extents += _overlap_pe(pvseg, per);
 			}
 		}


