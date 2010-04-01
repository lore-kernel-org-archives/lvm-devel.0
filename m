From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2010 13:08:07 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100401130807.9222.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-01 13:08:07

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Avoid endless loop if lv->segments list is corrupted

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.328&r2=1.329

--- LVM2/lib/metadata/metadata.c	2010/04/01 11:45:36	1.328
+++ LVM2/lib/metadata/metadata.c	2010/04/01 13:08:06	1.329
@@ -2191,6 +2191,12 @@
 		if (lv_is_visible(lvl->lv))
 			lv_visible_count++;
 
+		if (!check_lv_segments(lvl->lv, 0)) {
+			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
+				  lvl->lv->name);
+			r = 0;
+		}
+
 		if (lvl->lv->status & VISIBLE_LV)
 			continue;
 
@@ -2224,6 +2230,10 @@
 		r = 0;
 	}
 
+	/* Avoid endless loop if lv->segments list is corrupt */
+	if (!r)
+		return r;
+
 	loop_counter1 = loop_counter2 = 0;
 	/* FIXME Use temp hash table instead? */
 	dm_list_iterate_items(lvl, &vg->lvs) {
@@ -2253,12 +2263,6 @@
 			}
 		}
 
-		if (!check_lv_segments(lvl->lv, 0)) {
-			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
-				  lvl->lv->name);
-			r = 0;
-		}
-
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
@@ -2928,6 +2932,9 @@
 			vg_release(vg);
 			return NULL;
 		}
+	}
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		/*
 		 * Checks that cross-reference other LVs.
 		 */


