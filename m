From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:33:58 -0000
Subject: LVM2/tools args.h commands.h pvchange.c
Message-ID: <20100628203358.15746.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:33:58

Modified files:
	tools          : args.h commands.h pvchange.c 

Log message:
	Add --metadataignore to pvchange, allowing for ignoring of metadata areas.
	
	This patch just modifies pvchange to call the underlying ignore
	functions for mdas.  Ensure special cases do not reflect changes
	in metadata (PVs with 0 mdas, setting ignored when already ignored,
	clearing ignored when not ignored).
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/tools/args.h	2010/05/06 11:15:55	1.74
+++ LVM2/tools/args.h	2010/06/28 20:33:58	1.75
@@ -25,6 +25,7 @@
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
+arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
 arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
 arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
--- LVM2/tools/commands.h	2010/05/06 11:15:55	1.146
+++ LVM2/tools/commands.h	2010/06/28 20:33:58	1.147
@@ -455,6 +455,7 @@
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
    "\t[-x|--allocatable y|n]\n"
+   "\t[--metadataignore y|n]\n"
    "\t[-v|--verbose]\n"
    "\t[--addtag Tag]\n"
    "\t[--deltag Tag]\n"
@@ -462,7 +463,7 @@
    "\t[PhysicalVolumePath...]\n",
 
    all_ARG, allocatable_ARG, allocation_ARG, autobackup_ARG, deltag_ARG,
-   addtag_ARG, test_ARG, uuid_ARG)
+   addtag_ARG, metadataignore_ARG, test_ARG, uuid_ARG)
 
 xx(pvresize,
    "Resize physical volume(s)",
--- LVM2/tools/pvchange.c	2010/05/19 15:34:10	1.76
+++ LVM2/tools/pvchange.c	2010/06/28 20:33:58	1.77
@@ -34,6 +34,7 @@
 	int allocatable = 0;
 	int tagarg = 0;
 	int r = 0;
+	int mda_ignore = 0;
 
 	if (arg_count(cmd, addtag_ARG))
 		tagarg = addtag_ARG;
@@ -43,6 +44,9 @@
 	if (arg_count(cmd, allocatable_ARG))
 		allocatable = !strcmp(arg_str_value(cmd, allocatable_ARG, "n"),
 				      "y");
+	if (arg_count(cmd, metadataignore_ARG))
+		mda_ignore = !strcmp(arg_str_value(cmd, metadataignore_ARG, "n"),
+				      "y");
 	else if (tagarg && !(tag = arg_str_value(cmd, tagarg, NULL))) {
 		log_error("Failed to get tag");
 		return 0;
@@ -117,6 +121,32 @@
 				goto out;
 			}
 		}
+	} else if (arg_count(cmd, metadataignore_ARG)) {
+		if (mda_ignore && (pv_mda_used_count(pv) == 0)) {
+			log_error("Physical volume \"%s\" metadata already "
+				  "ignored", pv_name);
+			goto out;
+		}
+		if (!mda_ignore && (pv_mda_used_count(pv) == pv_mda_count(pv))) {
+			log_error("Physical volume \"%s\" metadata already "
+				  "not ignored", pv_name);
+			goto out;
+		}
+		if (!pv_mda_count(pv)) {
+			log_error("Physical volume \"%s\" has no metadata "
+				  "areas ", pv_name);
+			goto out;
+		}
+		if (mda_ignore) {
+			log_verbose("Setting physical volume \"%s\" "
+				    "metadata ignored", pv_name);
+		} else {
+			log_verbose("Setting physical volume \"%s\" "
+				    "metadata not ignored", pv_name);
+		}
+		if (!pv_mda_set_ignored(pv, mda_ignore)) {
+			goto out;
+		}
 	} else {
 		/* --uuid: Change PV ID randomly */
 		if (!id_create(&pv->id)) {
@@ -187,7 +217,8 @@
 	struct str_list *sll;
 
 	if (arg_count(cmd, allocatable_ARG) + arg_count(cmd, addtag_ARG) +
-	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) != 1) {
+	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
+	    arg_count(cmd, metadataignore_ARG) != 1) {
 		log_error("Please give exactly one option of -x, -uuid, "
 			  "--addtag or --deltag");
 		return EINVALID_CMD_LINE;


