From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Jan 2010 21:08:35 -0000
Subject: LVM2 lib/activate/activate.c lib/locking/locki ...
Message-ID: <20100105210835.25514.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-05 21:08:35

Modified files:
	lib/activate   : activate.c 
	lib/locking    : locking.c 
	tools          : pvmove.c vgchange.c 

Log message:
	Add missing 'stack;' for all activate_lv and deactivate_lv callers.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/lib/activate/activate.c	2009/12/03 19:23:40	1.160
+++ LVM2/lib/activate/activate.c	2010/01/05 21:08:34	1.161
@@ -714,7 +714,8 @@
 	 * FIXME: check status to not deactivate already activate device
 	 */
 	if (activate_lv_excl(lv->vg->cmd, lv)) {
-		deactivate_lv(lv->vg->cmd, lv);
+		if (!deactivate_lv(lv->vg->cmd, lv))
+			stack;
 		return 0;
 	}
 
--- LVM2/lib/locking/locking.c	2010/01/05 21:07:31	1.70
+++ LVM2/lib/locking/locking.c	2010/01/05 21:08:34	1.71
@@ -498,7 +498,8 @@
 			log_error("Failed to activate %s", lvl->lv->name);
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
-				activate_lv(cmd, lvl->lv);
+				if (!activate_lv(cmd, lvl->lv))
+					stack;
 			}
 			return 0;
 		}
--- LVM2/tools/pvmove.c	2010/01/05 21:07:31	1.71
+++ LVM2/tools/pvmove.c	2010/01/05 21:08:34	1.72
@@ -271,10 +271,17 @@
 static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
 			unsigned exclusive)
 {
+	int r = 0;
+
 	if (exclusive)
-		return activate_lv_excl(cmd, lv_mirr);
+		r = activate_lv_excl(cmd, lv_mirr);
+	else
+		r = activate_lv(cmd, lv_mirr);
 
-	return activate_lv(cmd, lv_mirr);
+	if (!r)
+		stack;
+
+	return r;
 }
 
 static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
--- LVM2/tools/vgchange.c	2010/01/05 20:56:52	1.93
+++ LVM2/tools/vgchange.c	2010/01/05 21:08:34	1.94
@@ -114,19 +114,29 @@
 		expected_count++;
 
 		if (activate == CHANGE_AN) {
-			if (!deactivate_lv(cmd, lv))
+			if (!deactivate_lv(cmd, lv)) {
+				stack;
 				continue;
+			}
 		} else if (activate == CHANGE_ALN) {
-			if (!deactivate_lv_local(cmd, lv))
+			if (!deactivate_lv_local(cmd, lv)) {
+				stack;
 				continue;
+			}
 		} else if (lv_is_origin(lv) || (activate == CHANGE_AE)) {
-			if (!activate_lv_excl(cmd, lv))
+			if (!activate_lv_excl(cmd, lv)) {
+				stack;
 				continue;
+			}
 		} else if (activate == CHANGE_ALY) {
-			if (!activate_lv_local(cmd, lv))
+			if (!activate_lv_local(cmd, lv)) {
+				stack;
 				continue;
-		} else if (!activate_lv(cmd, lv))
+			}
+		} else if (!activate_lv(cmd, lv)) {
+			stack;
 			continue;
+		}
 
 		if (background_polling() &&
 		    activate != CHANGE_AN && activate != CHANGE_ALN &&


