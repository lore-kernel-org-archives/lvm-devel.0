From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2010 20:03:55 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20100630200355.992.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-30 20:03:53

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : toollib.c vgchange.c vgcreate.c vgsplit.c 

Log message:
	improve vgmetadatacopies unmanaged message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.377&r2=1.378
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.206&r2=1.207
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/lib/metadata/metadata-exported.h	2010/06/30 19:28:35	1.163
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/30 20:03:52	1.164
@@ -456,7 +456,7 @@
 	const char *restorefile; /* 0 if no --restorefile option */
 	force_t force;
 	unsigned yes;
-	unsigned mda_ignore;
+	unsigned metadataignore;
 };
 
 struct physical_volume *pvcreate_single(struct cmd_context *cmd,
@@ -889,7 +889,7 @@
 uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_used_count(const struct volume_group *vg);
 uint32_t vg_mda_copies(const struct volume_group *vg);
-int vg_set_mda_copies(struct volume_group *vg, uint32_t copies);
+int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
@@ -905,7 +905,7 @@
 	size_t max_lv;
 	alloc_policy_t alloc;
 	int clustered; /* FIXME: put this into a 'status' variable instead? */
-	uint32_t metadata_copies;
+	uint32_t vgmetadatacopies;
 };
 
 int vgcreate_params_validate(struct cmd_context *cmd,
--- LVM2/lib/metadata/metadata.c	2010/06/30 19:55:43	1.377
+++ LVM2/lib/metadata/metadata.c	2010/06/30 20:03:52	1.378
@@ -1583,7 +1583,7 @@
 	pp->restorefile = 0;
 	pp->force = PROMPT;
 	pp->yes = 0;
-	pp->mda_ignore = DEFAULT_PVMETADATAIGNORE;
+	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
 }
 
 /*
@@ -1673,7 +1673,7 @@
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
 
-	if (pp->mda_ignore) {
+	if (pp->metadataignore) {
 		dm_list_iterate_items(mda, &mdas) {
 			mda_set_ignored(mda, 1);
 		}
@@ -4247,17 +4247,17 @@
 	return 0;
 }
 
-int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore)
+int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignored)
 {
 	const char *pv_name = pv_dev_name(pv);
 
-	if (mda_ignore && !pv_mda_used_count(pv)) {
+	if (mda_ignored && !pv_mda_used_count(pv)) {
 		log_error("Metadata areas on physical volume \"%s\" already "
 			  "ignored.", pv_name);
 		return 0;
 	}
 
-	if (!mda_ignore && (pv_mda_used_count(pv) == pv_mda_count(pv))) {
+	if (!mda_ignored && (pv_mda_used_count(pv) == pv_mda_count(pv))) {
 		log_error("Metadata areas on physical volume \"%s\" already "
 			  "marked as in-use.", pv_name);
 		return 0;
@@ -4270,9 +4270,9 @@
 	}
 
 	log_verbose("Marking metadata areas on physical volume \"%s\" "
-		    "as %s.", pv_name, mda_ignore ? "ignored" : "in-use");
+		    "as %s.", pv_name, mda_ignored ? "ignored" : "in-use");
 
-	if (!pv_mda_set_ignored(pv, mda_ignore))
+	if (!pv_mda_set_ignored(pv, mda_ignored))
 		return_0;
 
 	/*
--- LVM2/tools/toollib.c	2010/06/30 12:49:29	1.206
+++ LVM2/tools/toollib.c	2010/06/30 20:03:53	1.207
@@ -1187,7 +1187,7 @@
 		vp_def->max_lv = vg->max_lv;
 		vp_def->alloc = vg->alloc;
 		vp_def->clustered = vg_is_clustered(vg);
-		vp_def->metadata_copies = vg->mda_copies;
+		vp_def->vgmetadatacopies = vg->mda_copies;
 	} else {
 		vp_def->vg_name = NULL;
 		vp_def->extent_size = DEFAULT_EXTENT_SIZE * 2;
@@ -1195,7 +1195,7 @@
 		vp_def->max_lv = DEFAULT_MAX_LV;
 		vp_def->alloc = DEFAULT_ALLOC_POLICY;
 		vp_def->clustered = DEFAULT_CLUSTERED;
-		vp_def->metadata_copies = DEFAULT_VGMETADATACOPIES;
+		vp_def->vgmetadatacopies = DEFAULT_VGMETADATACOPIES;
 	}
 }
 
@@ -1244,13 +1244,13 @@
 	}
 
 	if (arg_count(cmd, metadatacopies_ARG)) {
-		vp_new->metadata_copies = arg_int_value(cmd, metadatacopies_ARG,
+		vp_new->vgmetadatacopies = arg_int_value(cmd, metadatacopies_ARG,
 							DEFAULT_VGMETADATACOPIES);
 	} else if (arg_count(cmd, vgmetadatacopies_ARG)) {
-		vp_new->metadata_copies = arg_int_value(cmd, vgmetadatacopies_ARG,
+		vp_new->vgmetadatacopies = arg_int_value(cmd, vgmetadatacopies_ARG,
 							DEFAULT_VGMETADATACOPIES);
 	} else {
-		vp_new->metadata_copies = find_config_tree_int(cmd,
+		vp_new->vgmetadatacopies = find_config_tree_int(cmd,
 						   "metadata/vgmetadatacopies",
 						   DEFAULT_VGMETADATACOPIES);
 	}
@@ -1378,19 +1378,19 @@
 	}
 
 	if (arg_count(cmd, metadataignore_ARG)) {
-		pp->mda_ignore = !strcmp(arg_str_value(cmd,
+		pp->metadataignore = !strcmp(arg_str_value(cmd,
 						metadataignore_ARG,
 						DEFAULT_PVMETADATAIGNORE_STR),
 					 "y");
 	} else {
-		pp->mda_ignore = !strcmp(find_config_tree_str(cmd,
+		pp->metadataignore = !strcmp(find_config_tree_str(cmd,
 					"metadata/pvmetadataignore",
 					DEFAULT_PVMETADATAIGNORE_STR),
 					"y");
 	}
 	if (arg_count(cmd, pvmetadatacopies_ARG) &&
 	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&
-	    pp->mda_ignore) {
+	    pp->metadataignore) {
 		log_error("metadataignore only applies to metadatacopies > 0");
 		return 0;
 	}
--- LVM2/tools/vgchange.c	2010/06/28 21:35:00	1.107
+++ LVM2/tools/vgchange.c	2010/06/30 20:03:53	1.108
@@ -528,17 +528,15 @@
 static int _vgchange_metadata_copies(struct cmd_context *cmd,
 				     struct volume_group *vg)
 {
-	uint32_t mda_copies = DEFAULT_VGMETADATACOPIES;
+	uint32_t mda_copies = arg_uint_value(cmd, vgmetadatacopies_ARG, DEFAULT_VGMETADATACOPIES);
 
-	if (arg_count(cmd, vgmetadatacopies_ARG))
-		mda_copies = arg_uint_value(cmd, vgmetadatacopies_ARG,
-			DEFAULT_VGMETADATACOPIES);
-	else if (arg_count(cmd, metadatacopies_ARG))
-		mda_copies = arg_uint_value(cmd, metadatacopies_ARG,
-			DEFAULT_VGMETADATACOPIES);
 	if (mda_copies == vg_mda_copies(vg)) {
-		log_error("Metadata copies of VG %s is already %u",
-			  vg->name, mda_copies);
+		if (vg_mda_copies(vg) == VGMETADATACOPIES_UNMANAGED)
+			log_error("Number of metadata copies for VG %s is already unmanaged.",
+				  vg->name);
+		else
+			log_error("Number of metadata copies for VG %s is already %" PRIu32,
+				  vg->name, mda_copies);
 		return ECMD_PROCESSED;
 	}
 
--- LVM2/tools/vgcreate.c	2010/06/28 20:38:23	1.79
+++ LVM2/tools/vgcreate.c	2010/06/30 20:03:53	1.80
@@ -64,7 +64,7 @@
 	    !vg_set_max_pv(vg, vp_new.max_pv) ||
 	    !vg_set_alloc_policy(vg, vp_new.alloc) ||
 	    !vg_set_clustered(vg, vp_new.clustered) ||
-	    !vg_set_mda_copies(vg, vp_new.metadata_copies))
+	    !vg_set_mda_copies(vg, vp_new.vgmetadatacopies))
 		goto bad_orphan;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
--- LVM2/tools/vgsplit.c	2010/06/28 20:39:24	1.100
+++ LVM2/tools/vgsplit.c	2010/06/30 20:03:53	1.101
@@ -384,7 +384,7 @@
 		    !vg_set_max_pv(vg_to, vp_new.max_pv) ||
 		    !vg_set_alloc_policy(vg_to, vp_new.alloc) ||
 		    !vg_set_clustered(vg_to, vp_new.clustered) ||
-		    !vg_set_mda_copies(vg_to, vp_new.metadata_copies))
+		    !vg_set_mda_copies(vg_to, vp_new.vgmetadatacopies))
 			goto_bad;
 	}
 


