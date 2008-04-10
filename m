From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Apr 2008 01:30:22 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20080410013022.10906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-10 01:30:22

Modified files:
	tools          : vgsplit.c 

Log message:
	Add _move_one_lv() helper function for vgsplit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/tools/vgsplit.c	2008/04/09 20:56:06	1.58
+++ LVM2/tools/vgsplit.c	2008/04/10 01:30:22	1.59
@@ -93,6 +93,25 @@
 	return 0;
 }
 
+static int _move_one_lv(struct volume_group *vg_from,
+			struct volume_group *vg_to,
+			struct list *lvh)
+{
+	struct logical_volume *lv;
+
+	lv = list_item(lvh, struct lv_list)->lv;
+	list_del(lvh);
+	list_add(&vg_to->lvs, lvh);
+	
+	if (lv->status & SNAPSHOT) {
+		vg_from->snapshot_count--;
+		vg_to->snapshot_count++;
+	} else {
+		vg_from->lv_count--;
+		vg_to->lv_count++;
+	}
+	return 1;
+}	
 
 static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 {
@@ -152,11 +171,8 @@
 			continue;
 
 		/* Move this LV */
-		list_del(lvh);
-		list_add(&vg_to->lvs, lvh);
-
-		vg_from->lv_count--;
-		vg_to->lv_count++;
+		if (!_move_one_lv(vg_from, vg_to, lvh))
+			return 0;
 	}
 
 	/* FIXME Ensure no LVs contain segs pointing at LVs in the other VG */
@@ -201,11 +217,8 @@
 			 */
 			if (_lv_is_in_vg(vg_to, seg->cow) &&
 			    _lv_is_in_vg(vg_to, seg->origin)) {
-				list_del(lvh);
-				list_add(&vg_to->lvs, lvh);
-				
-				vg_from->snapshot_count--;
-				vg_to->snapshot_count++;
+				if (!_move_one_lv(vg_from, vg_to, lvh))
+					return 0;
 			}
 		}
 
@@ -246,11 +259,8 @@
 		}
 
 		if (seg_in == seg->area_count && log_in) {
-			list_del(lvh);
-			list_add(&vg_to->lvs, lvh);
-
-			vg_from->lv_count--;
-			vg_to->lv_count++;
+			if (!_move_one_lv(vg_from, vg_to, lvh))
+				return 0;
 		}
 	}
 


