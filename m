From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:48 +0000 (UTC)
Subject: master - toollib: remove unsed pvcreate params function
Message-ID: <20160225151548.3F63A60EE3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30c69b3f8ac6c2a4c8b1a47b1482ac4b6a7b8d2e
Commit:        30c69b3f8ac6c2a4c8b1a47b1482ac4b6a7b8d2e
Parent:        0cd7d2332c4f6b5f6b71e6fe38a7678074c34bcc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 26 12:04:37 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

toollib: remove unsed pvcreate params function

which has been replaced by an equivalent pvcreate_each params
function.
---
 tools/toollib.c |  115 -------------------------------------------------------
 tools/toollib.h |    2 -
 2 files changed, 0 insertions(+), 117 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 88cbb51..ec0335d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1141,121 +1141,6 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
 	}
 }
 
-/*
- * Intial sanity checking of non-recovery related command-line arguments.
- *
- * Output arguments:
- * pp: structure allocated by caller, fields written / validated here
- */
-int pvcreate_params_validate(struct cmd_context *cmd, int argc,
-			     struct pvcreate_params *pp)
-{
-	if (!argc) {
-		log_error("Please enter a physical volume path.");
-		return 0;
-	}
-
-	pp->yes = arg_count(cmd, yes_ARG);
-	pp->force = (force_t) arg_count(cmd, force_ARG);
-
-	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
-		log_error("labelsector must be less than %lu.",
-			  LABEL_SCAN_SECTORS);
-		return 0;
-	} else {
-		pp->labelsector = arg_int64_value(cmd, labelsector_ARG,
-						  DEFAULT_LABELSECTOR);
-	}
-
-	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_count(cmd, pvmetadatacopies_ARG) ||
-	     arg_count(cmd, metadatasize_ARG)   ||
-	     arg_count(cmd, dataalignment_ARG)  ||
-	     arg_count(cmd, dataalignmentoffset_ARG))) {
-		log_error("Metadata and data alignment parameters only "
-			  "apply to text format.");
-		return 0;
-	}
-
-	if (!(cmd->fmt->features & FMT_BAS) &&
-	    arg_count(cmd, bootloaderareasize_ARG)) {
-		log_error("Bootloader area parameters only "
-			  "apply to text format.");
-		return 0;
-	}
-
-	if (arg_count(cmd, metadataignore_ARG))
-		pp->metadataignore = arg_int_value(cmd, metadataignore_ARG,
-						   DEFAULT_PVMETADATAIGNORE);
-	else
-		pp->metadataignore = find_config_tree_bool(cmd, metadata_pvmetadataignore_CFG, NULL);
-
-	if (arg_count(cmd, pvmetadatacopies_ARG) &&
-	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&
-	    pp->metadataignore) {
-		log_error("metadataignore only applies to metadatacopies > 0");
-		return 0;
-	}
-
-	pp->zero = arg_int_value(cmd, zero_ARG, 1);
-
-	if (arg_sign_value(cmd, dataalignment_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Physical volume data alignment may not be negative.");
-		return 0;
-	}
-	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
-
-	if (pp->data_alignment > UINT32_MAX) {
-		log_error("Physical volume data alignment is too big.");
-		return 0;
-	}
-
-	if (arg_sign_value(cmd, dataalignmentoffset_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Physical volume data alignment offset may not be negative");
-		return 0;
-	}
-	pp->data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
-
-	if (pp->data_alignment_offset > UINT32_MAX) {
-		log_error("Physical volume data alignment offset is too big.");
-		return 0;
-	}
-
-	if ((pp->data_alignment + pp->data_alignment_offset) &&
-	    (pp->rp.pe_start != PV_PE_START_CALC)) {
-		if ((pp->data_alignment ? pp->rp.pe_start % pp->data_alignment : pp->rp.pe_start) != pp->data_alignment_offset) {
-			log_warn("WARNING: Ignoring data alignment %s"
-				 " incompatible with restored pe_start value %s)",
-				 display_size(cmd, pp->data_alignment + pp->data_alignment_offset),
-				 display_size(cmd, pp->rp.pe_start));
-			pp->data_alignment = 0;
-			pp->data_alignment_offset = 0;
-		}
-	}
-
-	if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Metadata size may not be negative.");
-		return 0;
-	}
-
-	if (arg_sign_value(cmd, bootloaderareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Bootloader area size may not be negative.");
-		return 0;
-	}
-
-	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
-	if (!pp->pvmetadatasize)
-		pp->pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
-
-	pp->pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
-	if (pp->pvmetadatacopies < 0)
-		pp->pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
-
-	pp->rp.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, pp->rp.ba_size);
-
-	return 1;
-}
-
 int get_activation_monitoring_mode(struct cmd_context *cmd,
 				   int *monitoring_mode)
 {
diff --git a/tools/toollib.h b/tools/toollib.h
index 0ef9e92..c092c74 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -177,8 +177,6 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv);
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
 void lv_spawn_background_polling(struct cmd_context *cmd,
 				 struct logical_volume *lv);
-int pvcreate_params_validate(struct cmd_context *cmd, int argc,
-			     struct pvcreate_params *pp);
 
 int get_activation_monitoring_mode(struct cmd_context *cmd,
 				   int *monitoring_mode);


