From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 12:43:07 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/thin ...
Message-ID: <20111110124307.7893.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 12:43:06

Modified files:
	lib/metadata   : lv_manip.c thin_manip.c 
	tools          : lvcreate.c toollib.c 

Log message:
	Small comment and indent updates

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.329&r2=1.330
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.249&r2=1.250
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.233&r2=1.234

--- LVM2/lib/metadata/lv_manip.c	2011/11/10 12:42:36	1.329
+++ LVM2/lib/metadata/lv_manip.c	2011/11/10 12:43:05	1.330
@@ -4263,7 +4263,6 @@
 	init_dmeventd_monitor(lp->activation_monitoring);
 
 	if (seg_is_thin(lp)) {
-
 		/* For thin snapshot suspend active thin origin first */
 		if (org && lv_is_active(org)) {
 			if (!suspend_lv(cmd, org)) {
--- LVM2/lib/metadata/thin_manip.c	2011/11/07 11:04:45	1.25
+++ LVM2/lib/metadata/thin_manip.c	2011/11/10 12:43:05	1.26
@@ -346,7 +346,7 @@
 	}
 
 	if (activate) {
-		/* If the pool was not yet activated, do it */
+		/* If the pool is not active, do activate deactivate */
 		if (!lv_is_active(lv)) {
 			if (!activate_lv_excl(lv->vg->cmd, lv))
 				return_0;
--- LVM2/tools/lvcreate.c	2011/11/10 12:40:29	1.249
+++ LVM2/tools/lvcreate.c	2011/11/10 12:43:05	1.250
@@ -200,7 +200,8 @@
 	struct lv_list *lvl;
 
 	if (!(lvl = find_lv_in_vg(vg, lp->origin))) {
-		log_error("Snapshot origin LV %s not found in Volume group %s.", lp->origin, vg->name);
+		log_error("Snapshot origin LV %s not found in Volume group %s.",
+			  lp->origin, vg->name);
 		return 0;
 	}
 
@@ -222,7 +223,7 @@
 
 /*
  * Update extents parameters based on other parameters which affect the size
- * calcuation.
+ * calculation.
  * NOTE: We must do this here because of the percent_t typedef and because we
  * need the vg.
  */
--- LVM2/tools/toollib.c	2011/11/03 14:59:20	1.233
+++ LVM2/tools/toollib.c	2011/11/10 12:43:05	1.234
@@ -329,6 +329,7 @@
 		dm_list_iterate_items(sll, &arg_lvnames) {
 			const char *vg_name = sll->str;
 			const char *lv_name = strchr(vg_name, '/');
+log_error("VGNAME strdup %p %s   %s", lv_name, vg_name,  vgname);
 
 			if ((!lv_name && !strcmp(vg_name, vgname))) {
 				/* Process all LVs in this VG */


