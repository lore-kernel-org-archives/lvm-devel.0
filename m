From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2011 13:38:36 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c tools/pvchan ...
Message-ID: <20110124133836.4980.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-24 13:38:33

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c pvchange.c toollib.c toollib.h 
	                 vgchange.c 

Log message:
	Add change_tag to toollib.
	Allow multiple pvchange command line options to be specified together.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1886&r2=1.1887
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.218&r2=1.219
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/WHATS_NEW	2011/01/19 23:11:39	1.1886
+++ LVM2/WHATS_NEW	2011/01/24 13:38:31	1.1887
@@ -1,5 +1,7 @@
 Version 2.02.82 -
 ===================================
+  Add change_tag to toollib.
+  Allow multiple pvchange command line options to be specified together.
   Add -f (don't fork) option to clvmd and fix clvmd -d<num> description.
   Fix possible clvmd DLM lockspace increasing reference count.
   Do not fail polling if pvmove finished in another process.
--- LVM2/tools/lvchange.c	2010/11/11 17:29:06	1.127
+++ LVM2/tools/lvchange.c	2011/01/24 13:38:32	1.128
@@ -491,24 +491,10 @@
 	return 1;
 }
 
-static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
-			int arg)
+static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int arg)
 {
-	const char *tag;
-	struct arg_value_group_list *current_group;
-
-	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
-		if (!grouped_arg_is_set(current_group->arg_values, arg))
-			continue;
-
-		if (!(tag = grouped_arg_str_value(current_group->arg_values, arg, NULL))) {
-			log_error("Failed to get tag");
-			return 0;
-		}
-
-		if (!lv_change_tag(lv, tag, arg == addtag_ARG))
-			return_0;
-	}
+	if (!change_tag(cmd, NULL, lv, NULL, arg))
+		return_0;
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
--- LVM2/tools/pvchange.c	2010/12/23 14:23:30	1.87
+++ LVM2/tools/pvchange.c	2011/01/24 13:38:32	1.88
@@ -15,8 +15,6 @@
 
 #include "tools.h"
 
-/* FIXME Locking.  PVs in VG. */
-
 static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv,
 			    void *handle __attribute__((unused)))
@@ -27,21 +25,14 @@
 	uint64_t orig_pe_start;
 
 	const char *pv_name = pv_dev_name(pv);
-	const char *tag = NULL;
 	const char *orig_vg_name;
 	char uuid[64] __attribute__((aligned(8)));
 
 	int allocatable = 0;
-	int tagarg = 0;
-	int r = 0;
+	int tagargs = 0;
 	int mda_ignore = 0;
 
-	struct arg_value_group_list *current_group;
-
-	if (arg_count(cmd, addtag_ARG))
-		tagarg = addtag_ARG;
-	else if (arg_count(cmd, deltag_ARG))
-		tagarg = deltag_ARG;
+	tagargs = arg_count(cmd, addtag_ARG) + arg_count(cmd, deltag_ARG);
 
 	if (arg_count(cmd, allocatable_ARG))
 		allocatable = !strcmp(arg_str_value(cmd, allocatable_ARG, "n"),
@@ -52,20 +43,20 @@
 
 	/* If in a VG, must change using volume group. */
 	if (!is_orphan(pv)) {
-		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
+		if (tagargs && !(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group containing %s does not "
 				  "support tags", pv_name);
-			goto out;
+			return 0;
 		}
 		if (arg_count(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
 			log_error("Volume group containing %s has active "
 				  "logical volumes", pv_name);
-			goto out;
+			return 0;
 		}
 		if (!archive(vg))
-			goto out;
+			return 0;
 	} else {
-		if (tagarg) {
+		if (tagargs) {
 			log_error("Can't change tag on Physical Volume %s not "
 				  "in volume group", pv_name);
 			return 0;
@@ -77,22 +68,20 @@
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
 			log_error("Allocatability not supported by orphan "
 				  "%s format PV %s", pv->fmt->name, pv_name);
-			goto out;
+			return 0;
 		}
 
 		/* change allocatability for a PV */
 		if (allocatable && (pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "allocatable", pv_name);
-			r = 1;
-			goto out;
+			return 1;
 		}
 
 		if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "unallocatable", pv_name);
-			r = 1;
-			goto out;
+			return 1;
 		}
 
 		if (allocatable) {
@@ -104,50 +93,40 @@
 				    "allocatable", pv_name);
 			pv->status &= ~ALLOCATABLE_PV;
 		}
-	} else if (tagarg) {
-		/* tag or deltag */
+	}
 
-		dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
-			if (!grouped_arg_is_set(current_group->arg_values, tagarg))
-				continue;
+	if (tagargs) {
+		/* tag or deltag */
+		if (arg_count(cmd, addtag_ARG) && !change_tag(cmd, NULL, NULL, pv, addtag_ARG))
+			return_0;
 
-			if (!(tag = grouped_arg_str_value(current_group->arg_values, tagarg, NULL))) {
-				log_error("Failed to get tag");
-				goto out;
-			}
+		if (arg_count(cmd, deltag_ARG) && !change_tag(cmd, NULL, NULL, pv, deltag_ARG))
+			return_0;
+ 
+	}
 
-			if ((tagarg == addtag_ARG)) {
-				if (!str_list_add(cmd->mem, &pv->tags, tag)) {
-					log_error("Failed to add tag %s to physical "
-						  "volume %s", tag, pv_name);
-					goto out;
-				}
-			} else if (!str_list_del(&pv->tags, tag)) {
-				log_error("Failed to remove tag %s from "
-				  	"physical volume" "%s", tag, pv_name);
-				goto out;
-			}
-		}
-	} else if (arg_count(cmd, metadataignore_ARG)) {
+	if (arg_count(cmd, metadataignore_ARG)) {
 		if ((vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
 		    (arg_count(cmd, force_ARG) == PROMPT) &&
 		    yes_no_prompt("Override preferred number of copies "
 				  "of VG %s metadata? [y/n]: ",
 				  pv_vg_name(pv)) == 'n') {
 			log_error("Physical volume %s not changed", pv_name);
-			goto out;
+			return 0;
 		}
 		if (!pv_change_metadataignore(pv, mda_ignore))
-			goto out;
-	} else {
+			return_0;
+	} 
+
+	if (arg_count(cmd, uuid_ARG)) {
 		/* --uuid: Change PV ID randomly */
 		if (!id_create(&pv->id)) {
 			log_error("Failed to generate new random UUID for %s.",
 				  pv_name);
-			goto out;
+			return 0;
 		}
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid)))
-			goto_out;
+			return 0;
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
 		if (!is_orphan(pv)) {
 			orig_vg_name = pv_vg_name(pv);
@@ -163,7 +142,7 @@
 			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
 				log_error("pv_write with new uuid failed "
 					  "for %s.", pv_name);
-				goto out;
+				return 0;
 			}
 			pv->vg_name = orig_vg_name;
 			pv->pe_alloc_count = orig_pe_alloc_count;
@@ -179,20 +158,18 @@
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
-			goto out;
+			return 0;
 		}
 		backup(vg);
 	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
-		goto out;
+		return 0;
 	}
 
 	log_print("Physical volume \"%s\" changed", pv_name);
-	r = 1;
-out:
-	return r;
 
+	return 1;
 }
 
 int pvchange(struct cmd_context *cmd, int argc, char **argv)
@@ -209,11 +186,11 @@
 	struct dm_list *vgnames;
 	struct str_list *sll;
 
-	if (arg_count(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
+	if (!(arg_count(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
 	    arg_is_set(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
-	    arg_count(cmd, metadataignore_ARG) != 1) {
-		log_error("Please give exactly one option of -x, -uuid, "
-			  "--addtag or --deltag");
+	    arg_count(cmd, metadataignore_ARG))) {
+		log_error("Please give one or more of -x, -uuid, "
+			  "--addtag, --deltag or --metadataignore");
 		return EINVALID_CMD_LINE;
 	}
 
--- LVM2/tools/toollib.c	2010/12/20 14:05:31	1.218
+++ LVM2/tools/toollib.c	2011/01/24 13:38:32	1.219
@@ -472,7 +472,7 @@
 	for (;;) {
 		/* FIXME: consistent handling of command break */
 		if (sigint_caught()) {
-                        ret = ECMD_FAILED;
+			ret = ECMD_FAILED;
 			break;
 		}
 		if (!cmd_vg_read(cmd, &cmd_vgs))
@@ -1525,7 +1525,7 @@
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stripe_size)
 {
 	/* stripes_long_ARG takes precedence (for lvconvert) */
-        *stripes = arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ? stripes_long_ARG : stripes_ARG, 1);
+	*stripes = arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ? stripes_long_ARG : stripes_ARG, 1);
 
 	*stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
 	if (*stripe_size) {
@@ -1544,3 +1544,47 @@
 	return _validate_stripe_params(cmd, stripes, stripe_size);
 }
 
+/* FIXME move to lib */
+static int _pv_change_tag(struct physical_volume *pv, const char *tag, int addtag)
+{
+	if (addtag) {
+		if (!str_list_add(pv->fmt->cmd->mem, &pv->tags, tag)) {
+			log_error("Failed to add tag %s to physical volume %s",
+				  tag, pv_dev_name(pv));
+			return 0;
+		}
+	} else if (!str_list_del(&pv->tags, tag)) {
+		log_error("Failed to remove tag %s from physical volume" "%s",
+			  tag,  pv_dev_name(pv));
+		return 0;
+	}
+
+	return 1;
+}
+
+/* Set exactly one of VG, LV or PV */
+int change_tag(struct cmd_context *cmd, struct volume_group *vg,
+	       struct logical_volume *lv, struct physical_volume *pv, int arg)
+{
+	const char *tag;
+	struct arg_value_group_list *current_group;
+
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(current_group->arg_values, arg))
+			continue;
+
+		if (!(tag = grouped_arg_str_value(current_group->arg_values, arg, NULL))) {
+			log_error("Failed to get tag");
+			return 0;
+		}
+
+		if (vg && !vg_change_tag(vg, tag, arg == addtag_ARG))
+			return_0;
+		else if (lv && !lv_change_tag(lv, tag, arg == addtag_ARG))
+			return_0;
+		else if (pv && !_pv_change_tag(pv, tag, arg == addtag_ARG))
+			return_0;
+	}
+
+	return 1;
+}
--- LVM2/tools/toollib.h	2010/07/09 15:21:10	1.75
+++ LVM2/tools/toollib.h	2011/01/24 13:38:32	1.76
@@ -115,4 +115,7 @@
 int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 		      uint32_t *stripe_size);
 
+int change_tag(struct cmd_context *cmd, struct volume_group *vg,
+	       struct logical_volume *lv, struct physical_volume *pv, int arg);
+
 #endif
--- LVM2/tools/vgchange.c	2010/11/11 17:29:06	1.117
+++ LVM2/tools/vgchange.c	2011/01/24 13:38:32	1.118
@@ -360,37 +360,14 @@
 	return 1;
 }
 
-static int _vgchange_tag(struct cmd_context *cmd, struct volume_group *vg,
-			 int arg)
-{
-	const char *tag;
-	struct arg_value_group_list *current_group;
-
-	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
-		if (!grouped_arg_is_set(current_group->arg_values, arg))
-			continue;
-
-		if (!(tag = grouped_arg_str_value(current_group->arg_values, arg, NULL))) {
-			log_error("Failed to get tag");
-			return 0;
-		}
-
-		if (!vg_change_tag(vg, tag, arg == addtag_ARG))
-			return_0;
-
-	}
-
-	return 1;
-}
-
 static int _vgchange_addtag(struct cmd_context *cmd, struct volume_group *vg)
 {
-	return _vgchange_tag(cmd, vg, addtag_ARG);
+	return change_tag(cmd, vg, NULL, NULL, addtag_ARG);
 }
 
 static int _vgchange_deltag(struct cmd_context *cmd, struct volume_group *vg)
 {
-	return _vgchange_tag(cmd, vg, deltag_ARG);
+	return change_tag(cmd, vg, NULL, NULL, deltag_ARG);
 }
 
 static int _vgchange_uuid(struct cmd_context *cmd __attribute__((unused)),


