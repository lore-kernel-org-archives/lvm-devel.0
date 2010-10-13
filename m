From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Oct 2010 10:34:33 -0000
Subject: LVM2 man/vgextend.8.in tools/args.h tools/comm ...
Message-ID: <20101013103433.4615.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-13 10:34:32

Modified files:
	man            : vgextend.8.in 
	tools          : args.h commands.h vgextend.c 

Log message:
	Implement vgextend --restoremissing (BZ 537913), which makes it possible to
	re-add a physical volume that has gone missing previously, due to a transient
	device failure, without re-initialising it.
	
	Signed-off-by: Petr Rockai <prockai@redhat.com>
	Reviewed-by: Alasdair Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/man/vgextend.8.in	2010/07/07 19:14:57	1.8
+++ LVM2/man/vgextend.8.in	2010/10/13 10:34:31	1.9
@@ -4,6 +4,7 @@
 .SH SYNOPSIS
 .B vgextend
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help] 
+[\-\-restoremissing]
 [\-f|\-\-force]
 [\-t|\-\-test]
 [\-v|\-\-verbose]
@@ -12,7 +13,10 @@
 .SH DESCRIPTION
 vgextend allows you to add one or more initialized physical volumes ( see
 .B pvcreate(8)
-) to an existing volume group to extend it in size.
+) to an existing volume group to extend it in size. Moreover, it allows you to
+re-add a physical volume that has gone missing previously, due to a transient
+device failure, without re-initialising it. Use vgextend \-\-restoremissing to
+that effect.
 .sp
 If \fIPhysicalDevicePath\fP was not previously configured for LVM with
 \fBpvcreate (8)\fP, the device will be initialized with the same
--- LVM2/tools/args.h	2010/08/12 04:09:00	1.79
+++ LVM2/tools/args.h	2010/10/13 10:34:32	1.80
@@ -38,6 +38,7 @@
 arg(units_ARG, '\0', "units", string_arg, 0)
 arg(nosuffix_ARG, '\0', "nosuffix", NULL, 0)
 arg(removemissing_ARG, '\0', "removemissing", NULL, 0)
+arg(restoremissing_ARG, '\0', "restoremissing", NULL, 0)
 arg(abort_ARG, '\0', "abort", NULL, 0)
 arg(addtag_ARG, '\0', "addtag", tag_arg, 0)
 arg(deltag_ARG, '\0', "deltag", tag_arg, 0)
--- LVM2/tools/commands.h	2010/08/12 04:09:00	1.154
+++ LVM2/tools/commands.h	2010/10/13 10:34:32	1.155
@@ -848,6 +848,7 @@
    0,
    "vgextend\n"
    "\t[-A|--autobackup y|n]\n"
+   "\t[--restoremissing]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
@@ -860,7 +861,8 @@
    autobackup_ARG, test_ARG,
    force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
    metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
-   metadataignore_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
+   metadataignore_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
+   restoremissing_ARG)
 
 xx(vgimport,
    "Register exported volume group with system",
--- LVM2/tools/vgextend.c	2010/07/07 21:30:07	1.59
+++ LVM2/tools/vgextend.c	2010/10/13 10:34:32	1.60
@@ -15,12 +15,36 @@
 
 #include "tools.h"
 
+static int _restore_pv(struct volume_group *vg, char *pv_name)
+{
+	struct pv_list *pvl = NULL;
+	pvl = find_pv_in_vg(vg, pv_name);
+	if (!pvl) {
+		log_warn("WARNING: PV %s not found in VG %s", pv_name, vg->name);
+		return 0;
+	}
+
+	if (!(pvl->pv->status & MISSING_PV)) {
+		log_warn("WARNING: PV %s was not missing in VG %s", pv_name, vg->name);
+		return 0;
+	}
+
+	if (!pvl->pv->dev) {
+		log_warn("WARNING: The PV %s is still missing.", pv_name);
+		return 0;
+	}
+
+	pvl->pv->status &= ~MISSING_PV;
+	return 1;
+}
+
 int vgextend(struct cmd_context *cmd, int argc, char **argv)
 {
 	char *vg_name;
 	struct volume_group *vg = NULL;
 	int r = ECMD_FAILED;
 	struct pvcreate_params pp;
+	int fixed = 0, i = 0;
 
 	if (!argc) {
 		log_error("Please enter volume group name and "
@@ -42,6 +66,9 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, restoremissing_ARG))
+		cmd->handles_missing_pvs = 1;
+
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
@@ -50,42 +77,53 @@
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		unlock_and_release_vg(cmd, vg, vg_name);
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg))
 		goto_bad;
 
-	if (arg_count(cmd, metadataignore_ARG) &&
-	    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
-	    (pp.force == PROMPT) &&
-	    yes_no_prompt("Override preferred number of copies "
+	if (arg_count(cmd, restoremissing_ARG)) {
+		for (i = 0; i < argc; ++i) {
+			if (_restore_pv(vg, argv[i]))
+				++ fixed;
+		}
+		if (!fixed) {
+			log_error("No PV has been restored.");
+			goto_bad;
+		}
+	} else { /* no --restore, normal vgextend */
+		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+			log_error("Can't get lock for orphan PVs");
+			unlock_and_release_vg(cmd, vg, vg_name);
+			return ECMD_FAILED;
+		}
+
+		if (arg_count(cmd, metadataignore_ARG) &&
+		    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
+		    (pp.force == PROMPT) &&
+		    yes_no_prompt("Override preferred number of copies "
 			  "of VG %s metadata? [y/n]: ",
-			  vg_name) == 'n') {
-		log_error("Volume group %s not changed", vg_name);
-		goto_bad;
-	}
-
-	/* extend vg */
-	if (!vg_extend(vg, argc, argv, &pp))
-		goto_bad;
-
-	if (arg_count(cmd, metadataignore_ARG) &&
-	    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
-	    (vg_mda_copies(vg) != vg_mda_used_count(vg))) {
-		log_warn("WARNING: Changing preferred number of copies of VG %s "
+				  vg_name) == 'n') {
+			log_error("Volume group %s not changed", vg_name);
+			goto_bad;
+		}
+
+		/* extend vg */
+		if (!vg_extend(vg, argc, argv, &pp))
+			goto_bad;
+
+		if (arg_count(cmd, metadataignore_ARG) &&
+		    (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
+		    (vg_mda_copies(vg) != vg_mda_used_count(vg))) {
+			log_warn("WARNING: Changing preferred number of copies of VG %s "
 			 "metadata from %"PRIu32" to %"PRIu32, vg_name,
-			 vg_mda_copies(vg), vg_mda_used_count(vg));
-		vg_set_mda_copies(vg, vg_mda_used_count(vg));
+				 vg_mda_copies(vg), vg_mda_used_count(vg));
+			vg_set_mda_copies(vg, vg_mda_used_count(vg));
+		}
+
+		/* ret > 0 */
+		log_verbose("Volume group \"%s\" will be extended by %d new "
+			    "physical volumes", vg_name, argc);
 	}
 
-	/* ret > 0 */
-	log_verbose("Volume group \"%s\" will be extended by %d new "
-		    "physical volumes", vg_name, argc);
-
 	/* store vg on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
 		goto_bad;


