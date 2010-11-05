From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 5 Nov 2010 18:18:13 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/m ...
Message-ID: <20101105181813.2851.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-11-05 18:18:12

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/metadata   : lv_manip.c 

Log message:
	Clarify error messages when activation fails due to activation filter use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1788&r2=1.1789
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.234&r2=1.235

--- LVM2/WHATS_NEW	2010/11/05 16:18:38	1.1788
+++ LVM2/WHATS_NEW	2010/11/05 18:18:11	1.1789
@@ -1,5 +1,6 @@
 Version 2.02.76 - 
 ===================================
+  Clarify error messages when activation fails due to activation filter use.
   Add initial script VolumeGroup.ocf for pacemaker support.
   Fix regex optimiser not to ignore RHS of OR nodes in _find_leftmost_common.
   Fix handling of online filesystem resize (using new fsadm return code).
--- LVM2/lib/activate/activate.c	2010/11/01 14:17:35	1.178
+++ LVM2/lib/activate/activate.c	2010/11/05 18:18:12	1.179
@@ -285,12 +285,12 @@
 		/* Don't activate */
 		return 0;
 	}
-
-	for (cv = cn->v; cv; cv = cv->next) {
+	else
 		log_verbose("activation/volume_list configuration setting "
 			    "defined, checking the list to match %s/%s",
 			    lv->vg->name, lv->name);
 
+	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type != CFG_STRING) {
 			log_error("Ignoring invalid string in config file "
 				  "activation/volume_list");
@@ -303,6 +303,7 @@
 			continue;
 		}
 
+
 		/* Tag? */
 		if (*str == '@') {
 			str++;
@@ -1239,8 +1240,8 @@
 		goto out;
 
 	if (!_passes_activation_filter(cmd, lv)) {
-		log_verbose("Not activating %s/%s due to config file settings",
-			    lv->vg->name, lv->name);
+		log_verbose("Not activating %s/%s since it does not pass "
+			    "activation filter.", lv->vg->name, lv->name);
 		*activate_lv = 0;
 	} else
 		*activate_lv = 1;
@@ -1266,8 +1267,8 @@
 		goto out;
 
 	if (filter && !_passes_activation_filter(cmd, lv)) {
-		log_verbose("Not activating %s/%s due to config file settings",
-			    lv->vg->name, lv->name);
+		log_error("Not activating %s/%s since it does not pass "
+			  "activation filter.", lv->vg->name, lv->name);
 		goto out;
 	}
 
--- LVM2/lib/metadata/lv_manip.c	2010/10/14 20:03:12	1.234
+++ LVM2/lib/metadata/lv_manip.c	2010/11/05 18:18:12	1.235
@@ -3240,12 +3240,9 @@
 			goto revert_new_lv;
 		}
 	} else if (!activate_lv(cmd, lv)) {
-		if (lp->zero) {
-			log_error("Aborting. Failed to activate new LV to wipe "
-				  "the start of it.");
-			goto deactivate_and_revert_new_lv;
-		}
 		log_error("Failed to activate new LV.");
+		if (lp->zero)
+			goto deactivate_and_revert_new_lv;
 		return 0;
 	}
 


