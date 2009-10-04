From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:42 -0400
Subject: [PATCH 05/10] Refactor pvcreate - split pvcreate_validate_params into recovery/non-recovery.
In-Reply-To: <1254697907-16448-5-git-send-email-dwysocha@redhat.com>
References: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-2-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-3-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-4-git-send-email-dwysocha@redhat.com>
	<1254697907-16448-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1254697907-16448-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Split pvcreate_validate_params into recovery and non-recovery parameters.
This is necessary so we can call the non-recovery validate function from
vgextend / vgcreate.  Note in the pvcreate tool case, we must call the
recovery validation function first (see treatment of pe_start and --zero),
and that we add a call to fill_default_pvcreate_params before the validation
functions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    2 +-
 tools/pvcreate.c        |   62 ++++++++++++++++++++++++++++-------------------
 2 files changed, 38 insertions(+), 26 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 341128d..1bee7d0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1275,7 +1275,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 void fill_default_pvcreate_params(struct pvcreate_params *pp)
 {
 	memset(pp, 0, sizeof(*pp));
-	pp->zero = 0;
+	pp->zero = 1;
 	pp->size = 0;
 	pp->data_alignment = UINT64_C(0);
 	pp->data_alignment_offset = UINT64_C(0);
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 9949631..ead1f46 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,29 +17,20 @@
 #include "metadata-exported.h"
 
 /*
- * Intial sanity checking of command-line arguments and fill in 'pp' fields.
- *
- * Input arguments:
- * cmd, argc, argv
+ * Intial sanity checking of recovery-related command-line arguments.
+ * These args are: --restorefile, --uuid, and --physicalvolumesize
  *
  * Output arguments:
  * pp: structure allocated by caller, fields written / validated here
  */
-static int pvcreate_validate_params(struct cmd_context *cmd,
-				    int argc, char **argv,
-				    struct pvcreate_params *pp)
+static int pvcreate_validate_restore_params(struct cmd_context *cmd,
+					    int argc, char **argv,
+					    struct pvcreate_params *pp)
 {
 	const char *uuid = NULL;
 	void *existing_pv;
 	struct volume_group *vg;
 
-	memset(pp, 0, sizeof(*pp));
-
-	if (!argc) {
-		log_error("Please enter a physical volume path");
-		return 0;
-	}
-
 	if (arg_count(cmd, restorefile_ARG) && !arg_count(cmd, uuidstr_ARG)) {
 		log_error("--uuid is required with --restorefile");
 		return 0;
@@ -76,6 +67,32 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 		vg_release(vg);
 	}
 
+	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical volume size may not be negative");
+		return 0;
+	}
+	pp->size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
+
+	if (arg_count(cmd, restorefile_ARG) || arg_count(cmd, uuidstr_ARG))
+		pp->zero = 0;
+	return 1;
+}
+
+/*
+ * Intial sanity checking of non-recovery related command-line arguments.
+ *
+ * Output arguments:
+ * pp: structure allocated by caller, fields written / validated here
+ */
+static int pvcreate_validate_params(struct cmd_context *cmd,
+				    int argc, char **argv,
+				    struct pvcreate_params *pp)
+{
+	if (!argc) {
+		log_error("Please enter a physical volume path");
+		return 0;
+	}
+
 	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
 		log_error("Option y can only be given with option f");
 		return 0;
@@ -111,16 +128,6 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 
 	if (arg_count(cmd, zero_ARG))
 		pp->zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
-	else if (arg_count(cmd, restorefile_ARG) || arg_count(cmd, uuidstr_ARG))
-		pp->zero = 0;
-	else
-		pp->zero = 1;
-
-	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical volume size may not be negative");
-		return 0;
-	}
-	pp->size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
 
 	if (arg_sign_value(cmd, dataalignment_ARG, 0) == SIGN_MINUS) {
 		log_error("Physical volume data alignment may not be negative");
@@ -185,6 +192,11 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	int ret = ECMD_PROCESSED;
 	struct pvcreate_params pp;
 
+	fill_default_pvcreate_params(&pp);
+
+	if (!pvcreate_validate_restore_params(cmd, argc, argv, &pp)) {
+		return EINVALID_CMD_LINE;
+	}
 	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
-- 
1.6.0.6


