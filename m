From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 12 Feb 2015 16:45:42 +0000 (UTC)
Subject: master - pvchange: Use process_each_pv.
Message-ID: <20150212164542.B3B4360552@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4e703ab60dc912d3d8c7ff198c98962338341b2
Commit:        e4e703ab60dc912d3d8c7ff198c98962338341b2
Parent:        acb6c062078fbfd5ccd5aa92fbfd8db081b39b19
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Feb 12 16:37:47 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 12 16:37:47 2015 +0000

pvchange: Use process_each_pv.

Invalid devices no longer included in the counters printed at the end.
May now need to use --ignoreskippedcluster if relying upon exit status.
If more than one change is requested per-PV, attempt to perform them
all.  Note that different arguments still handle exit status
differently.
---
 WHATS_NEW        |    3 +
 tools/commands.h |    6 +-
 tools/pvchange.c |  194 +++++++++++++++++++----------------------------------
 3 files changed, 77 insertions(+), 126 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7691649..2c50c78 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.117 - 
 ====================================
+  Add --ignoreskippedcluster to pvchange.
+  Allow pvchange to modify several properties at once.
+  Update pvchange to use process_each_pv.
   Fix pvs -a used with lvmetad to filter out devices unsuitable for PVs.
   Fix selection to recognize units for ba_start, vg_free and seg_start fields.
   Add support for -S/--select to vgexport and vgimport.
diff --git a/tools/commands.h b/tools/commands.h
index 5221f79..febd851 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -640,11 +640,12 @@ xx(pvchange,
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[--ignoreskippedcluster]\n"
+   "\t[--metadataignore y|n]\n"
    "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
    "\t[-x|--allocatable y|n]\n"
-   "\t[--metadataignore y|n]\n"
    "\t[-v|--verbose]\n"
    "\t[--addtag Tag]\n"
    "\t[--deltag Tag]\n"
@@ -652,7 +653,8 @@ xx(pvchange,
    "\t[PhysicalVolumePath...]\n",
 
    all_ARG, allocatable_ARG, allocation_ARG, autobackup_ARG, deltag_ARG,
-   addtag_ARG, force_ARG, metadataignore_ARG, select_ARG, test_ARG, uuid_ARG)
+   addtag_ARG, force_ARG, ignoreskippedcluster_ARG, metadataignore_ARG,
+   select_ARG, test_ARG, uuid_ARG)
 
 xx(pvresize,
    "Resize physical volume(s)",
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 1788620..9a673f7 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -15,37 +15,43 @@
 
 #include "tools.h"
 
+struct pvchange_params {
+	unsigned done;
+	unsigned total;
+};
+
 static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
-			    struct physical_volume *pv,
-			    void *handle __attribute__((unused)))
+			    struct physical_volume *pv, struct processing_handle *handle)
 {
+	struct pvchange_params *params = (struct pvchange_params *) handle->custom_handle;
 	const char *pv_name = pv_dev_name(pv);
 	char uuid[64] __attribute__((aligned(8)));
+	unsigned done = 0;
 
 	int allocatable = arg_int_value(cmd, allocatable_ARG, 0);
 	int mda_ignore = arg_int_value(cmd, metadataignore_ARG, 0);
 	int tagargs = arg_count(cmd, addtag_ARG) + arg_count(cmd, deltag_ARG);
 
+	params->total++;
+
 	/* If in a VG, must change using volume group. */
 	if (!is_orphan(pv)) {
 		if (tagargs && !(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group containing %s does not "
 				  "support tags", pv_name);
-			return 0;
+			goto bad;
 		}
 		if (arg_count(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
 			log_error("Volume group containing %s has active "
 				  "logical volumes", pv_name);
-			return 0;
+			goto bad;
 		}
 		if (!archive(vg))
-			return 0;
-	} else {
-		if (tagargs) {
-			log_error("Can't change tag on Physical Volume %s not "
-				  "in volume group", pv_name);
-			return 0;
-		}
+			goto_bad;
+	} else if (tagargs) {
+		log_error("Can't change tag on Physical Volume %s not "
+			  "in volume group", pv_name);
+		goto bad;
 	}
 
 	if (arg_count(cmd, allocatable_ARG)) {
@@ -53,41 +59,38 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
 			log_error("Allocatability not supported by orphan "
 				  "%s format PV %s", pv->fmt->name, pv_name);
-			return 0;
+			goto bad;
 		}
 
 		/* change allocatability for a PV */
 		if (allocatable && (pv_status(pv) & ALLOCATABLE_PV)) {
 			log_warn("Physical volume \"%s\" is already "
 				 "allocatable.", pv_name);
-			return 1;
-		}
-
-		if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
+		} else if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
 			log_warn("Physical volume \"%s\" is already "
 				 "unallocatable.", pv_name);
-			return 1;
-		}
-
-		if (allocatable) {
+		} else if (allocatable) {
 			log_verbose("Setting physical volume \"%s\" "
 				    "allocatable", pv_name);
 			pv->status |= ALLOCATABLE_PV;
+			done = 1;
 		} else {
 			log_verbose("Setting physical volume \"%s\" NOT "
 				    "allocatable", pv_name);
 			pv->status &= ~ALLOCATABLE_PV;
+			done = 1;
 		}
 	}
 
 	if (tagargs) {
 		/* tag or deltag */
 		if (arg_count(cmd, addtag_ARG) && !change_tag(cmd, NULL, NULL, pv, addtag_ARG))
-			return_0;
+			goto_bad;
 
 		if (arg_count(cmd, deltag_ARG) && !change_tag(cmd, NULL, NULL, pv, deltag_ARG))
-			return_0;
- 
+			goto_bad;
+	
+		done = 1;
 	}
 
 	if (arg_count(cmd, metadataignore_ARG)) {
@@ -95,12 +98,12 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		    (arg_count(cmd, force_ARG) == PROMPT) &&
 		    yes_no_prompt("Override preferred number of copies "
 				  "of VG %s metadata? [y/n]: ",
-				  pv_vg_name(pv)) == 'n') {
-			log_error("Physical volume %s not changed", pv_name);
-			return 0;
-		}
+				  pv_vg_name(pv)) == 'n')
+			goto_bad;
 		if (!pv_change_metadataignore(pv, mda_ignore))
-			return_0;
+			goto_bad;
+
+		done = 1;
 	} 
 
 	if (arg_count(cmd, uuid_ARG)) {
@@ -109,16 +112,23 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		if (!id_create(&pv->id)) {
 			log_error("Failed to generate new random UUID for %s.",
 				  pv_name);
-			return 0;
+			goto bad;
 		}
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid)))
-			return 0;
+			goto_bad;
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
 		if (!is_orphan(pv) && (!pv_write(cmd, pv, 1))) {
 			log_error("pv_write with new uuid failed "
 				  "for %s.", pv_name);
-			return 0;
+			goto bad;
 		}
+
+		done = 1;
+	}
+
+	if (!done) {
+		log_print_unless_silent("Physical volume %s not changed", pv_name);
+		return ECMD_PROCESSED;
 	}
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
@@ -126,102 +136,64 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
-			return 0;
+			goto bad;
 		}
 		backup(vg);
 	} else if (!(pv_write(cmd, pv, 0))) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
-		return 0;
+		goto bad;
 	}
 
 	log_print_unless_silent("Physical volume \"%s\" changed", pv_name);
 
-	return 1;
+	params->done++;
+	return ECMD_PROCESSED;
+
+bad:
+	log_error("Physical volume %s not changed", pv_name);
+
+	return ECMD_FAILED;
 }
 
 int pvchange(struct cmd_context *cmd, int argc, char **argv)
 {
-	int opt = 0;
-	int done = 0;
-	int total = 0;
-	int selected;
-
+	struct pvchange_params params = { 0 };
 	struct processing_handle *handle = NULL;
-	struct volume_group *vg;
-	const char *vg_name;
-	char *pv_name;
 
-	struct pv_list *pvl;
-	struct dm_list *vgnames;
-	struct dm_str_list *sll;
-
-	int r = ECMD_PROCESSED;
+	int ret = ECMD_PROCESSED;
 
 	if (!(arg_count(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
 	    arg_is_set(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
 	    arg_count(cmd, metadataignore_ARG))) {
 		log_error("Please give one or more of -x, -uuid, "
 			  "--addtag, --deltag or --metadataignore");
-		r = EINVALID_CMD_LINE;
+		ret = EINVALID_CMD_LINE;
 		goto out;
 	}
 
-	/* FIXME: use process_each_pv for pvchange. */
-
 	if (!(handle = init_processing_handle(cmd)) ||
 	    (handle->internal_report_for_select && !init_selection_handle(cmd, handle, PVS))) {
 		log_error("Failed to initialize processing handle.");
-		r = ECMD_FAILED;
+		ret = ECMD_FAILED;
 		goto out;
 	}
 
+	handle->custom_handle = &params;
+
 	if (!(arg_count(cmd, all_ARG)) && !argc && !handle->internal_report_for_select) {
-		log_error("Please give a physical volume path "
-			  "or use -S for selection.");
-		r = EINVALID_CMD_LINE;
+		log_error("Please give a physical volume path or use -S for selection.");
+		ret = EINVALID_CMD_LINE;
 		goto out;
 	}
 
 	if (arg_count(cmd, all_ARG) && argc) {
 		log_error("Option --all and PhysicalVolumePath are exclusive.");
-		r = EINVALID_CMD_LINE;
+		ret = EINVALID_CMD_LINE;
 		goto out;
 	}
 
-	if (argc) {
-		log_verbose("Using physical volume(s) on command line");
-		for (; opt < argc; opt++) {
-			total++;
-			pv_name = argv[opt];
-			dm_unescape_colons_and_at_signs(pv_name, NULL, NULL);
-			vg_name = find_vgname_from_pvname(cmd, pv_name);
-			if (!vg_name) {
-				log_error("Failed to read physical volume %s",
-					  pv_name);
-				continue;
-			}
-			vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-			if (vg_read_error(vg)) {
-				release_vg(vg);
-				stack;
-				continue;
-			}
-			pvl = find_pv_in_vg(vg, pv_name);
-			if (!pvl || !pvl->pv) {
-				unlock_and_release_vg(cmd, vg, vg_name);
-				log_error("Unable to find %s in %s",
-					  pv_name, vg_name);
-				continue;
-			}
-
-			done += _pvchange_single(cmd, vg,
-						 pvl->pv, NULL);
-			unlock_and_release_vg(cmd, vg, vg_name);
-		}
-	} else {
-		log_verbose("Scanning for physical volume names");
-		/* FIXME: share code with toollib */
+	if (!argc) {
 		/*
 		 * Take the global lock here so the lvmcache remains
 		 * consistent across orphan/non-orphan vg locks.  If we don't
@@ -230,47 +202,21 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		 */
 		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
 			log_error("Unable to obtain global lock.");
-			r = ECMD_FAILED;
+			ret = ECMD_FAILED;
 			goto out;
 		}
+	}
 
-		/* populate lvmcache */
-		if (!lvmetad_vg_list_to_lvmcache(cmd))
-			stack;
-
-		if ((vgnames = get_vgnames(cmd, 1)) &&
-		    !dm_list_empty(vgnames)) {
-			dm_list_iterate_items(sll, vgnames) {
-				vg = vg_read_for_update(cmd, sll->str, NULL, 0);
-				if (vg_read_error(vg)) {
-					release_vg(vg);
-					stack;
-					continue;
-				}
-				dm_list_iterate_items(pvl, &vg->pvs) {
-					if (select_match_pv(cmd, handle, vg, pvl->pv,
-							    &selected) && selected) {
-						total++;
-						done += _pvchange_single(cmd, vg,
-									 pvl->pv,
-									 NULL);
-					}
-				}
-				unlock_and_release_vg(cmd, vg, sll->str);
-			}
-		}
+	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, handle, _pvchange_single);
+
+	if (!argc)
 		unlock_vg(cmd, VG_GLOBAL);
-	}
 
-	log_print_unless_silent("%d physical volume%s changed / %d physical volume%s "
-				"not changed",
-				done, done == 1 ? "" : "s",
-				total - done, (total - done) == 1 ? "" : "s");
+	log_print_unless_silent("%d physical volume%s changed / %d physical volume%s not changed",
+				params.done, params.done == 1 ? "" : "s",
+				params.total - params.done, (params.total - params.done) == 1 ? "" : "s");
 
 out:
 	destroy_processing_handle(cmd, handle, 1);
-	if (r == ECMD_PROCESSED)
-		return (total == done) ? ECMD_PROCESSED : ECMD_FAILED;
-	else
-		return r;
+	return ret;
 }


