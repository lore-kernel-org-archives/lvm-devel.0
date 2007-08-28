From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Aug 2007 16:14:50 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20070828161450.7559.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-28 16:14:49

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata.c 
	man            : vgremove.8 
	tools          : commands.h 

Log message:
	Modify lvremove to prompt for removal if LV active on other cluster nodes.
	Add '-f' to vgremove to force removal of VG even if LVs exist.
	Update vgremove man page for '-f'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.697&r2=1.698
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgremove.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/WHATS_NEW	2007/08/24 21:05:15	1.697
+++ LVM2/WHATS_NEW	2007/08/28 16:14:48	1.698
@@ -1,6 +1,8 @@
 Version 2.02.29 -
 ==================================
-
+  Modify lvremove to prompt for removal if LV active on other cluster nodes.
+  Add '-f' to vgremove to force removal of VG even if LVs exist.
+  
 Version 2.02.28 - 24th August 2007
 ==================================
   Fix clvmd logging so you can get lvm-level debugging out of it.
--- LVM2/lib/metadata/lv_manip.c	2007/08/22 14:38:17	1.127
+++ LVM2/lib/metadata/lv_manip.c	2007/08/28 16:14:48	1.128
@@ -1839,37 +1839,49 @@
 
 	/* FIXME Ensure not referred to by another existing LVs */
 
-	if (lv_info(cmd, lv, &info, 1)) {
-		if (info.open_count) {
-			log_error("Can't remove open logical volume \"%s\"",
-				  lv->name);
-			return 0;
-		}
-
-		if (info.exists && (force == PROMPT)) {
-			if (yes_no_prompt("Do you really want to remove active "
-					  "logical volume \"%s\"? [y/n]: ",
-					  lv->name) == 'n') {
-				log_print("Logical volume \"%s\" not removed",
-					  lv->name);
-				return 0;
-			}
-		}
+	/*
+	 * If we can't get information about the LV from the kernel, or
+	 * someone has the LV device open, fail.
+	 */
+	if (!lv_info(cmd, lv, &info, 1)) {
+		log_error("Unable to obtain status for logical volume \"%s\"",
+			  lv->name);
+		return 0;
 	}
-
-	if (!archive(vg))
+	if (info.open_count) {
+		log_error("Can't remove open logical volume \"%s\"",
+			  lv->name);
 		return 0;
+	}
 
-	/* If the VG is clustered then make sure no-one else is using the LV
-	   we are about to remove */
-	if (vg_status(vg) & CLUSTERED) {
-		if (!activate_lv_excl(cmd, lv)) {
-			log_error("Can't get exclusive access to volume \"%s\"",
+	/*
+	 * Check for confirmation prompts in the following cases:
+	 * 1) Clustered VG, and some remote nodes have the LV active
+	 * 2) Non-clustered VG, but LV active locally
+	 */
+	if ((vg_status(vg) & CLUSTERED) && !activate_lv_excl(cmd, lv) &&
+	    (force == PROMPT)) {
+		if (yes_no_prompt("Logical volume \"%s\" is active on other "
+				  "cluster nodes.  Really remove? [y/n]: ",
+				  lv->name) == 'n') {
+			log_print("Logical volume \"%s\" not removed",
 				  lv->name);
 			return 0;
 		}
+	} else if (info.exists && (force == PROMPT)) {
+		 if (yes_no_prompt("Do you really want to remove active "
+				   "logical volume \"%s\"? [y/n]: ",
+				   lv->name) == 'n') {
+			 log_print("Logical volume \"%s\" not removed",
+				  lv->name);
+			 return 0;
+		 }
 	}
 
+
+	if (!archive(vg))
+		return 0;
+
 	/* FIXME Snapshot commit out of sequence if it fails after here? */
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate logical volume \"%s\"",
--- LVM2/lib/metadata/metadata.c	2007/08/22 14:38:17	1.134
+++ LVM2/lib/metadata/metadata.c	2007/08/28 16:14:48	1.135
@@ -249,6 +249,20 @@
 	return 1;
 }
 
+static int remove_lvs_in_vg(struct cmd_context *cmd,
+			    struct volume_group *vg,
+			    force_t force)
+{
+	struct lv_list *lvl;
+
+	list_iterate_items(lvl, &vg->lvs)
+		if (!lv_remove_single(cmd, lvl->lv, force))
+			return 0;
+
+	return 1;
+}
+
+/* FIXME: remove redundant vg_name */
 int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 		     struct volume_group *vg, int consistent,
 		     force_t force __attribute((unused)))
@@ -269,6 +283,19 @@
 		return 0;
 
 	if (vg->lv_count) {
+		if ((force == PROMPT) &&
+		    (yes_no_prompt("Do you really want to remove volume "
+				   "group \"%s\" containing %d "
+				   "logical volumes? [y/n]: ",
+				   vg_name, vg->lv_count) == 'n')) {
+			log_print("Volume group \"%s\" not removed", vg_name);
+			return 0;
+		}
+		if (!remove_lvs_in_vg(cmd, vg, force))
+			return 0;
+	}
+	
+	if (vg->lv_count) {
 		log_error("Volume group \"%s\" still contains %d "
 			  "logical volume(s)", vg_name, vg->lv_count);
 		return 0;
--- LVM2/man/vgremove.8	2004/11/18 19:45:52	1.4
+++ LVM2/man/vgremove.8	2007/08/28 16:14:49	1.5
@@ -3,17 +3,24 @@
 vgremove \- remove a volume group
 .SH SYNOPSIS
 .B vgremove
-[\-d/\-\-debug] [\-h/\-?/\-\-help] [\-t/\-\-test] [\-v/\-\-verbose]
+[\-d/\-\-debug] [\-f/\-\-force] [\-h/\-?/\-\-help]
+[\-t/\-\-test] [\-v/\-\-verbose]
 VolumeGroupName [VolumeGroupName...]
 .SH DESCRIPTION
 vgremove allows you to remove one or more volume groups.
-The volume group(s) must not have any logical volumes allocated:
-Remove them first with \fBlvremove\fP. If one or more physical
-volumes in the volume group are lost, consider 
-\fBvgreduce --removemissing\fP to make the volume group
+If one or more physical volumes in the volume group are lost,
+consider \fBvgreduce --removemissing\fP to make the volume group
 metadata consistent again.
+.sp
+If there are logical volumes that exist in the volume group,
+a prompt will be given to confirm removal.  You can override
+the prompt with \fB-f\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
+.TP
+.BR \-f ", " \-\-force
+Force the removal of any logical volumes on the volume group
+without confirmation.
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvremove (8), 
--- LVM2/tools/commands.h	2007/08/21 19:46:36	1.101
+++ LVM2/tools/commands.h	2007/08/28 16:14:49	1.102
@@ -807,13 +807,14 @@
    "Remove volume group(s)",
    "vgremove\n"
    "\t[-d|--debug]\n"
+   "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
-   test_ARG)
+   force_ARG, test_ARG)
 
 xx(vgrename,
    "Rename a volume group",


