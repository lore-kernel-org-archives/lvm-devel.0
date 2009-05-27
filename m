From: agk@sourceware.org <agk@sourceware.org>
Date: 27 May 2009 18:19:22 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c tools ...
Message-ID: <20090527181922.26249.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-27 18:19:21

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 
	tools          : lvchange.c lvcreate.c toollib.c 

Log message:
	Suppress 'removed' messages displayed when internal LVs are removed.
	Fix lvchange -a and -p for sparse LVs.
	Fix lvcreate --virtualsize to activate the new device immediately.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1128&r2=1.1129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.191&r2=1.192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155

--- LVM2/WHATS_NEW	2009/05/27 16:30:29	1.1128
+++ LVM2/WHATS_NEW	2009/05/27 18:19:21	1.1129
@@ -1,8 +1,11 @@
 Version 2.02.48 - 
 ===============================
+  Suppress 'removed' messages displayed when internal LVs are removed.
+  Fix lvchange -a and -p for sparse LVs.
+  Fix lvcreate --virtualsize to activate the new device immediately.
   Make --snapshot optional with lvcreate --virtualsize.
   Generalise --virtualoriginsize to --virtualsize.
-  Skip virtual origins in process_each_lv_in_vg().
+  Skip virtual origins in process_each_lv_in_vg() without --all.
   Fix counting of virtual origin LVs in vg_validate.
   Attempt to load dm-zero module if zero target needed but not present.
 
--- LVM2/lib/metadata/lv_manip.c	2009/05/21 03:04:53	1.174
+++ LVM2/lib/metadata/lv_manip.c	2009/05/27 18:19:21	1.175
@@ -2037,6 +2037,7 @@
 		}
 
 		if (lv_is_active(lv) && (force == PROMPT) &&
+		    lv_is_visible(lv) &&
 		    yes_no_prompt("Do you really want to remove active "
 				  "%slogical volume %s? [y/n]: ",
 				  vg_is_clustered(vg) ? "clustered " : "",
@@ -2083,7 +2084,9 @@
 			log_error("Failed to resume %s.", origin->name);
 	}
 
-	log_print("Logical volume \"%s\" successfully removed", lv->name);
+	if (lv_is_visible(lv))
+		log_print("Logical volume \"%s\" successfully removed", lv->name);
+
 	return 1;
 }
 
--- LVM2/tools/lvchange.c	2009/05/20 09:55:34	1.101
+++ LVM2/tools/lvchange.c	2009/05/27 18:19:21	1.102
@@ -540,6 +540,7 @@
 {
 	int doit = 0, docmds = 0;
 	int archived = 0;
+	struct logical_volume *origin;
 
 	if (!(lv->vg->status & LVM_WRITE) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
@@ -584,7 +585,12 @@
 		return ECMD_FAILED;
 	}
 
-	if (!(lv_is_visible(lv))) {
+	/* If LV is sparse, activate origin instead */
+	if (arg_count(cmd, available_ARG) && lv_is_cow(lv) &&
+	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
+		lv = origin;
+
+	if (!(lv_is_visible(lv)) && !lv_is_virtual_origin(lv)) {
 		log_error("Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
--- LVM2/tools/lvcreate.c	2009/05/27 16:30:30	1.191
+++ LVM2/tools/lvcreate.c	2009/05/27 18:19:21	1.192
@@ -910,12 +910,16 @@
 			return 0;
 		}
 
+		/* A virtual origin must be activated explicitly. */
 		if (lp->voriginsize &&
-		    !(org = _create_virtual_origin(cmd, vg, lv->name,
-						   lp->permission,
-						   lp->voriginextents))) {
+		    (!(org = _create_virtual_origin(cmd, vg, lv->name,
+						    lp->permission,
+						    lp->voriginextents)) ||
+		     !activate_lv(cmd, org))) {
 			log_error("Couldn't create virtual origin for LV %s",
 				  lv->name);
+			if (org && !lv_remove(org))
+				stack;
 			goto deactivate_and_revert_new_lv;
 		}
 
--- LVM2/tools/toollib.c	2009/05/27 13:23:42	1.154
+++ LVM2/tools/toollib.c	2009/05/27 18:19:21	1.155
@@ -122,7 +122,7 @@
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
 
-		if (lv_is_virtual_origin(lvl->lv))
+		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
 
 		/* Should we process this LV? */


