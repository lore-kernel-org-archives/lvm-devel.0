From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 8 Jan 2010 14:03:55 -0000
Subject: LVM2 ./WHATS_NEW tools/vgremove.c
Message-ID: <20100108140355.25433.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-01-08 14:03:55

Modified files:
	.              : WHATS_NEW 
	tools          : vgremove.c 

Log message:
	Allow vgremove of a VG with PVs missing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1373&r2=1.1374
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2010/01/07 20:55:01	1.1373
+++ LVM2/WHATS_NEW	2010/01/08 14:03:54	1.1374
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Allow vgremove of a VG with PVs missing.
   Keep log type consistent when changing mirror image count.
   Always set environment variables for an LVM2 device in 11-dm-lvm.rules.
   Add activation/udev_rules config option in lvm.conf.
--- LVM2/tools/vgremove.c	2009/12/03 19:18:34	1.58
+++ LVM2/tools/vgremove.c	2010/01/08 14:03:55	1.59
@@ -19,7 +19,7 @@
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
-	unsigned lv_count;
+	unsigned lv_count, missing;
 	force_t force;
 
 	if (!vg_check_status(vg, EXPORTED_VG)) {
@@ -31,13 +31,17 @@
 
 	force = arg_count(cmd, force_ARG);
 	if (lv_count) {
-		if ((force == PROMPT) &&
-		    (yes_no_prompt("Do you really want to remove volume "
-				   "group \"%s\" containing %u "
-				   "logical volumes? [y/n]: ",
-				   vg_name, lv_count) == 'n')) {
-			log_error("Volume group \"%s\" not removed", vg_name);
-			return ECMD_FAILED;
+		if (force == PROMPT) {
+			if ((missing = vg_missing_pv_count(vg)))
+				log_warn("WARNING: %d physical volumes are currently missing "
+					 "from the system.", missing);
+			if (yes_no_prompt("Do you really want to remove volume "
+					  "group \"%s\" containing %u "
+					  "logical volumes? [y/n]: ",
+					  vg_name, lv_count) == 'n') {
+				log_error("Volume group \"%s\" not removed", vg_name);
+				return ECMD_FAILED;
+			}
 		}
 		if (!remove_lvs_in_vg(cmd, vg, force)) {
 			stack;
@@ -67,6 +71,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	cmd->handles_missing_pvs = 1;
 	ret = process_each_vg(cmd, argc, argv,
 			      READ_FOR_UPDATE,
 			      NULL, &vgremove_single);


