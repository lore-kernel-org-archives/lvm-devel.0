From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 4 Dec 2009 14:03:18 -0000
Subject: LVM2/tools pvmove.c
Message-ID: <20091204140318.17556.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-12-04 14:03:18

Modified files:
	tools          : pvmove.c 

Log message:
	Give better message for pvmove when all data on source PV is skipped.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/tools/pvmove.c	2009/12/03 19:22:24	1.69
+++ LVM2/tools/pvmove.c	2009/12/04 14:03:18	1.70
@@ -180,6 +180,7 @@
 	struct lv_list *lvl;
 	uint32_t log_count = 0;
 	int lv_found = 0;
+	int lv_skipped = 0;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -209,22 +210,27 @@
 			lv_found = 1;
 		}
 		if (lv_is_origin(lv) || lv_is_cow(lv)) {
+			lv_skipped = 1;
 			log_print("Skipping snapshot-related LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & MIRRORED) {
+			lv_skipped = 1;
 			log_print("Skipping mirror LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & MIRROR_LOG) {
+			lv_skipped = 1;
 			log_print("Skipping mirror log LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & MIRROR_IMAGE) {
+			lv_skipped = 1;
 			log_print("Skipping mirror image LV %s", lv->name);
 			continue;
 		}
 		if (lv->status & LOCKED) {
+			lv_skipped = 1;
 			log_print("Skipping locked LV %s", lv->name);
 			continue;
 		}
@@ -240,6 +246,10 @@
 
 	/* Is temporary mirror empty? */
 	if (!lv_mirr->le_count) {
+		if (lv_skipped)
+			log_error("All data on source PV skipped. "
+				  "It contains locked, hidden or "
+				  "non-top level LVs only.");
 		log_error("No data to move for %s", vg->name);
 		return NULL;
 	}


