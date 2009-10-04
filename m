From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:44 -0400
Subject: [PATCH 07/10] Move pvcreate_validate_params into toollib to allow calling from mutiple tools.
In-Reply-To: <1254697907-16448-7-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-2-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-3-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-4-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-5-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-6-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For implicit pvcreate support, we need to call this from vgcreate and vgextend,
so move it into toollib.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/pvcreate.c |  108 -----------------------------------------------------
 tools/toollib.c  |  109 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h  |    3 +
 3 files changed, 112 insertions(+), 108 deletions(-)

diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index ead1f46..5471c8d 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -78,114 +78,6 @@ static int pvcreate_validate_restore_params(struct cmd_context *cmd,
 	return 1;
 }
 
-/*
- * Intial sanity checking of non-recovery related command-line arguments.
- *
- * Output arguments:
- * pp: structure allocated by caller, fields written / validated here
- */
-static int pvcreate_validate_params(struct cmd_context *cmd,
-				    int argc, char **argv,
-				    struct pvcreate_params *pp)
-{
-	if (!argc) {
-		log_error("Please enter a physical volume path");
-		return 0;
-	}
-
-	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
-		log_error("Option y can only be given with option f");
-		return 0;
-	}
-
-	pp->yes = arg_count(cmd, yes_ARG);
-	pp->force = arg_count(cmd, force_ARG);
-
-	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
-		log_error("labelsector must be less than %lu",
-			  LABEL_SCAN_SECTORS);
-		return 0;
-	} else {
-		pp->labelsector = arg_int64_value(cmd, labelsector_ARG,
-						  DEFAULT_LABELSECTOR);
-	}
-
-	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_count(cmd, metadatacopies_ARG) ||
-	     arg_count(cmd, metadatasize_ARG)   ||
-	     arg_count(cmd, dataalignment_ARG)  ||
-	     arg_count(cmd, dataalignmentoffset_ARG))) {
-		log_error("Metadata and data alignment parameters only "
-			  "apply to text format.");
-		return 0;
-	}
-
-	if (arg_count(cmd, metadatacopies_ARG) &&
-	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
-		log_error("Metadatacopies may only be 0, 1 or 2");
-		return 0;
-	}
-
-	if (arg_count(cmd, zero_ARG))
-		pp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
-
-	if (arg_sign_value(cmd, dataalignment_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical volume data alignment may not be negative");
-		return 0;
-	}
-	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
-
-	if (pp->data_alignment > ULONG_MAX) {
-		log_error("Physical volume data alignment is too big.");
-		return 0;
-	}
-
-	if (pp->data_alignment && pp->pe_start) {
-		if (pp->pe_start % pp->data_alignment)
-			log_warn("WARNING: Ignoring data alignment %" PRIu64
-				 " incompatible with --restorefile value (%"
-				 PRIu64").", pp->data_alignment, pp->pe_start);
-		pp->data_alignment = 0;
-	}
-
-	if (arg_sign_value(cmd, dataalignmentoffset_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical volume data alignment offset may not be negative");
-		return 0;
-	}
-	pp->data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
-
-	if (pp->data_alignment_offset > ULONG_MAX) {
-		log_error("Physical volume data alignment offset is too big.");
-		return 0;
-	}
-
-	if (pp->data_alignment_offset && pp->pe_start) {
-		log_warn("WARNING: Ignoring data alignment offset %" PRIu64
-			 " incompatible with --restorefile value (%"
-			 PRIu64").", pp->data_alignment_offset, pp->pe_start);
-		pp->data_alignment_offset = 0;
-	}
-
-	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
-		log_error("Metadata size may not be negative");
-		return 0;
-	}
-
-	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
-	if (!pp->pvmetadatasize)
-		pp->pvmetadatasize = find_config_tree_int(cmd,
-						 "metadata/pvmetadatasize",
-						 DEFAULT_PVMETADATASIZE);
-
-	pp->pvmetadatacopies = arg_int_value(cmd, metadatacopies_ARG, -1);
-	if (pp->pvmetadatacopies < 0)
-		pp->pvmetadatacopies = find_config_tree_int(cmd,
-						   "metadata/pvmetadatacopies",
-						   DEFAULT_PVMETADATACOPIES);
-
-	return 1;
-}
-
 int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i;
diff --git a/tools/toollib.c b/tools/toollib.c
index c9cb201..9211576 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1271,3 +1271,112 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
 		lvconvert_poll(cmd, lv, 1);
 	}
 }
+
+/*
+ * Intial sanity checking of non-recovery related command-line arguments.
+ *
+ * Output arguments:
+ * pp: structure allocated by caller, fields written / validated here
+ */
+int pvcreate_validate_params(struct cmd_context *cmd,
+			     int argc, char **argv,
+			     struct pvcreate_params *pp)
+{
+	if (!argc) {
+		log_error("Please enter a physical volume path");
+		return 0;
+	}
+
+	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
+		log_error("Option y can only be given with option f");
+		return 0;
+	}
+
+	pp->yes = arg_count(cmd, yes_ARG);
+	pp->force = arg_count(cmd, force_ARG);
+
+	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
+		log_error("labelsector must be less than %lu",
+			  LABEL_SCAN_SECTORS);
+		return 0;
+	} else {
+		pp->labelsector = arg_int64_value(cmd, labelsector_ARG,
+						  DEFAULT_LABELSECTOR);
+	}
+
+	if (!(cmd->fmt->features & FMT_MDAS) &&
+	    (arg_count(cmd, metadatacopies_ARG) ||
+	     arg_count(cmd, metadatasize_ARG)   ||
+	     arg_count(cmd, dataalignment_ARG)  ||
+	     arg_count(cmd, dataalignmentoffset_ARG))) {
+		log_error("Metadata and data alignment parameters only "
+			  "apply to text format.");
+		return 0;
+	}
+
+	if (arg_count(cmd, metadatacopies_ARG) &&
+	    arg_int_value(cmd, metadatacopies_ARG, -1) > 2) {
+		log_error("Metadatacopies may only be 0, 1 or 2");
+		return 0;
+	}
+
+	if (arg_count(cmd, zero_ARG))
+		pp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
+
+	if (arg_sign_value(cmd, dataalignment_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical volume data alignment may not be negative");
+		return 0;
+	}
+	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
+
+	if (pp->data_alignment > ULONG_MAX) {
+		log_error("Physical volume data alignment is too big.");
+		return 0;
+	}
+
+	if (pp->data_alignment && pp->pe_start) {
+		if (pp->pe_start % pp->data_alignment)
+			log_warn("WARNING: Ignoring data alignment %" PRIu64
+				 " incompatible with --restorefile value (%"
+				 PRIu64").", pp->data_alignment, pp->pe_start);
+		pp->data_alignment = 0;
+	}
+
+	if (arg_sign_value(cmd, dataalignmentoffset_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical volume data alignment offset may not be negative");
+		return 0;
+	}
+	pp->data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
+
+	if (pp->data_alignment_offset > ULONG_MAX) {
+		log_error("Physical volume data alignment offset is too big.");
+		return 0;
+	}
+
+	if (pp->data_alignment_offset && pp->pe_start) {
+		log_warn("WARNING: Ignoring data alignment offset %" PRIu64
+			 " incompatible with --restorefile value (%"
+			 PRIu64").", pp->data_alignment_offset, pp->pe_start);
+		pp->data_alignment_offset = 0;
+	}
+
+	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
+		log_error("Metadata size may not be negative");
+		return 0;
+	}
+
+	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
+	if (!pp->pvmetadatasize)
+		pp->pvmetadatasize = find_config_tree_int(cmd,
+						 "metadata/pvmetadatasize",
+						 DEFAULT_PVMETADATASIZE);
+
+	pp->pvmetadatacopies = arg_int_value(cmd, metadatacopies_ARG, -1);
+	if (pp->pvmetadatacopies < 0)
+		pp->pvmetadatacopies = find_config_tree_int(cmd,
+						   "metadata/pvmetadatacopies",
+						   DEFAULT_PVMETADATACOPIES);
+
+	return 1;
+}
+
diff --git a/tools/toollib.h b/tools/toollib.h
index 59cbeb6..526c711 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -107,5 +107,8 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv);
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
 void lv_spawn_background_polling(struct cmd_context *cmd,
 				 struct logical_volume *lv);
+int pvcreate_validate_params(struct cmd_context *cmd,
+			     int argc, char **argv,
+			     struct pvcreate_params *pp);
 
 #endif
-- 
1.6.0.6


