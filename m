From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jan 2007 23:01:19 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c tools/vgs ...
Message-ID: <20070129230119.32034.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-29 23:01:18

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit to handle mirrors.
	Reorder fields in reporting field definitions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.564&r2=1.565
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2007/01/27 02:09:05	1.564
+++ LVM2/WHATS_NEW	2007/01/29 23:01:17	1.565
@@ -1,5 +1,7 @@
 Version 2.02.21 -
 ===================================
+  Fix vgsplit to handle mirrors.
+  Reorder fields in reporting field definitions.
   Fix vgs to treat args as VGs even when PV fields are displayed.
   Fix md signature check to handle both endiannesses.
 
--- LVM2/lib/report/report.c	2007/01/24 16:51:24	1.54
+++ LVM2/lib/report/report.c	2007/01/29 23:01:18	1.55
@@ -868,11 +868,11 @@
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
-#define FIELD(type, strct, sorttype, head, field, width, func, id, desc) {type, id, (off_t)((void *)&_dummy._ ## strct.field - (void *)&_dummy._ ## strct), head, width, sorttype, &_ ## func ## _disp, desc},
+#define FIELD(type, strct, sorttype, head, field, width, func, id, desc) {type, sorttype, (off_t)((void *)&_dummy._ ## strct.field - (void *)&_dummy._ ## strct), width, id, head, &_ ## func ## _disp, desc},
 
 static struct dm_report_field_type _fields[] = {
 #include "columns.h"
-{0, "", 0, "", 0, 0, NULL, NULL},
+{0, 0, 0, 0, "", "", NULL, NULL},
 };
 
 #undef STR
--- LVM2/tools/vgsplit.c	2007/01/09 21:12:41	1.21
+++ LVM2/tools/vgsplit.c	2007/01/29 23:01:18	1.22
@@ -72,6 +72,9 @@
 		if ((lv->status & SNAPSHOT))
 			continue;
 
+		if ((lv->status & MIRRORED))
+			continue;
+
 		/* Ensure all the PVs used by this LV remain in the same */
 		/* VG as each other */
 		vg_with = NULL;
@@ -161,6 +164,48 @@
 	return 1;
 }
 
+static int _move_mirrors(struct volume_group *vg_from,
+			 struct volume_group *vg_to)
+{
+	struct list *lvh, *lvht;
+	struct logical_volume *lv;
+	struct lv_segment *seg;
+	int i, seg_in, log_in;
+
+	list_iterate_safe(lvh, lvht, &vg_from->lvs) {
+		lv = list_item(lvh, struct lv_list)->lv;
+
+		if (!(lv->status & MIRRORED))
+			continue;
+
+		seg = first_seg(lv); 
+
+		seg_in = 0;
+		for (i = 0; i < seg->area_count; i++)
+			if (_lv_is_in_vg(vg_to, seg_lv(seg, i)))
+			    seg_in++;
+
+		log_in = (!seg->log_lv || _lv_is_in_vg(vg_to, seg->log_lv));
+		
+		if ((seg_in && seg_in < seg->area_count) || 
+		    (seg_in && seg->log_lv && !log_in) || 
+		    (!seg_in && seg->log_lv && log_in)) {
+			log_error("Mirror %s split", lv->name);
+			return 0;
+		}
+
+		if (seg_in == seg->area_count && log_in) {
+			list_del(lvh);
+			list_add(&vg_to->lvs, lvh);
+
+			vg_from->lv_count--;
+			vg_to->lv_count++;
+		}
+	}
+
+	return 1;
+}
+
 int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 {
 	char *vg_name_from, *vg_name_to;
@@ -275,6 +320,10 @@
 	if (!(_move_snapshots(vg_from, vg_to)))
 		goto error;
 
+	/* Move required mirrors across */
+	if (!(_move_mirrors(vg_from, vg_to)))
+		goto error;
+
 	/* FIXME Split mdas properly somehow too! */
 	/* Currently we cheat by sharing the format instance and relying on 
 	 * vg_write to ignore mdas outside the VG!  Done this way, with text 


