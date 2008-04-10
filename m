From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Apr 2008 21:34:54 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20080410213454.14213.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-10 21:34:53

Modified files:
	tools          : vgsplit.c 

Log message:
	Update vgsplit to only restrict split with active LVs involved in split.
	
	Existing code will reject a vgsplit if any LVs in the source VG are active.
	This patch updates vgsplit to only check LVs involved in the split.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/tools/vgsplit.c	2008/04/10 20:02:04	1.64
+++ LVM2/tools/vgsplit.c	2008/04/10 21:34:53	1.65
@@ -93,7 +93,7 @@
 	return 0;
 }
 
-static void _move_one_lv(struct volume_group *vg_from,
+static int _move_one_lv(struct volume_group *vg_from,
 			 struct volume_group *vg_to,
 			 struct list *lvh)
 {
@@ -101,6 +101,11 @@
 
 	list_move(&vg_to->lvs, lvh);
 	
+	if (lv_is_active(lv)) {
+		log_error("Logical volume \"%s\" must be inactive", lv->name);
+		return 0;
+	}
+
 	if (lv->status & SNAPSHOT) {
 		vg_from->snapshot_count--;
 		vg_to->snapshot_count++;
@@ -108,6 +113,7 @@
 		vg_from->lv_count--;
 		vg_to->lv_count++;
 	}
+	return 1;
 }	
 
 static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
@@ -168,7 +174,8 @@
 			continue;
 
 		/* Move this LV */
-		_move_one_lv(vg_from, vg_to, lvh);
+		if (!_move_one_lv(vg_from, vg_to, lvh))
+			return 0;
 	}
 
 	/* FIXME Ensure no LVs contain segs pointing at LVs in the other VG */
@@ -212,8 +219,10 @@
 			 * in vg_to.
 			 */
 			if (_lv_is_in_vg(vg_to, seg->cow) &&
-			    _lv_is_in_vg(vg_to, seg->origin))
-				_move_one_lv(vg_from, vg_to, lvh);
+			    _lv_is_in_vg(vg_to, seg->origin)) {
+				if (!_move_one_lv(vg_from, vg_to, lvh))
+					return 0;
+			}
 		}
 
 	}
@@ -252,8 +261,10 @@
 			return 0;
 		}
 
-		if (seg_in == seg->area_count && log_in)
-			_move_one_lv(vg_from, vg_to, lvh);
+		if (seg_in == seg->area_count && log_in) {
+			if (!_move_one_lv(vg_from, vg_to, lvh))
+				return 0;
+		}
 	}
 
 	return 1;
@@ -277,7 +288,6 @@
 	char *vg_name_from, *vg_name_to;
 	struct volume_group *vg_to, *vg_from;
 	int opt;
-	int active;
 	int existing_vg;
 	int consistent;
 	const char *lv_name;
@@ -316,14 +326,6 @@
 				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		 return ECMD_FAILED;
 
-	if ((active = lvs_in_vg_activated(vg_from))) {
-		/* FIXME Remove this restriction */
-		log_error("Logical volumes in \"%s\" must be inactive",
-			  vg_name_from);
-		unlock_vg(cmd, vg_name_from);
-		return ECMD_FAILED;
-	}
-
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {
 		log_error("Can't get lock for %s", vg_name_to);


