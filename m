From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:08 +0000 (UTC)
Subject: master - toollib: persistent major minor
Message-ID: <20141024144108.2A56460CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7484a139a3b24d05459d8593309b518b4104172
Commit:        c7484a139a3b24d05459d8593309b518b4104172
Parent:        d13239b0547e09def4b58b0f49bd0252f459d431
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 23 14:26:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

toollib: persistent major minor

Deduce -M from presence of --minor, --major option if
not specified on command line.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |   37 +++++++++++--------------------
 tools/toollib.c  |   64 ++++++++++++++++++++++++++++++++---------------------
 3 files changed, 53 insertions(+), 49 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 320bca3..c3d56de 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Better support for persistent major and minor options with lvcreate.
   Refactor lvcreate towards more complete validation of all supported options.
   Support lvcreate --type linear.
   Improve _should_wipe_lv() to warn with message.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index a789fb2..2744b09 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -623,20 +623,9 @@ static int _read_activation_params(struct cmd_context *cmd,
 		lp->wipe_signatures = 0;
 	}
 
-	/* Persistent minor (and major) */
-	if (arg_is_set(cmd, persistent_ARG)) {
-		if (lp->create_pool && !seg_is_thin_volume(lp)) {
-			log_error("--persistent is not permitted when creating a thin pool device.");
-			return 0;
-		}
-
-		if (!get_and_validate_major_minor(cmd, vg->fid->fmt,
-						  &lp->major, &lp->minor))
-			return_0;
-	} else if (arg_is_set(cmd, major_ARG) || arg_is_set(cmd, minor_ARG)) {
-		log_error("--major and --minor require -My.");
-		return 0;
-	}
+	/* Persistent minor (and major), default 'n' */
+	if (!get_and_validate_major_minor(cmd, vg->fid->fmt, &lp->major, &lp->minor))
+		return_0;
 
 	if (arg_is_set(cmd, setactivationskip_ARG)) {
 		lp->activation_skip |= ACTIVATION_SKIP_SET;
@@ -1316,10 +1305,14 @@ static int _check_pool_parameters(struct cmd_context *cmd,
 				return 0;
 			}
 		}
-		/* When creating just pool the pool_name needs to be in lv_name */
-		if (seg_is_pool(lp))
+		if (seg_is_pool(lp)) {
+			if (lp->major != -1 || lp->minor != -1) {
+				log_error("Persistent major and minor numbers are unsupported with pools.");
+				return 0;
+			}
+			/* When creating just pool the pool_name needs to be in lv_name */
 			lp->lv_name = lp->pool_name;
-
+		}
 		return 1;
 	}
 	/* Not creating new pool, but existing pool is needed */
@@ -1416,6 +1409,9 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
+	if (!_read_activation_params(cmd, vg, &lp))
+		goto_out;
+
 	/* Resolve segment types with opened VG */
 	if (lp.snapshot && lp.origin_name && !_determine_snapshot_type(vg, &lp, &lcp))
 		goto_out;
@@ -1433,13 +1429,6 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!_check_pool_parameters(cmd, vg, &lp, &lcp))
 		goto_out;
 
-	/*
-	 * Check activation parameters to support inactive thin snapshot creation
-	 * FIXME: anything else needs to be moved past _determine_snapshot_type()?
-	 */
-	if (!_read_activation_params(cmd, vg, &lp))
-		goto_out;
-
 	if (!_update_extents_params(vg, &lp, &lcp))
 		goto_out;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index a33e6c2..dd09811 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1181,55 +1181,69 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 	return ret_max;
 }
 
+/*
+ * Parse persistent major minor parameters.
+ *
+ * --persistent is unspecified => state is deduced
+ * from presence of options --minor or --major.
+ *
+ * -Mn => --minor or --major not allowed.
+ *
+ * -My => --minor is required (and also --major on <=2.4)
+ */
 int get_and_validate_major_minor(const struct cmd_context *cmd,
 				 const struct format_type *fmt,
 				 int32_t *major, int32_t *minor)
 {
-	if (!arg_int_value(cmd, persistent_ARG, 0)) {
+	if (arg_count(cmd, minor_ARG) > 1) {
+		log_error("Option --minor may not be repeated.");
+		return 0;
+	}
+
+	if (arg_count(cmd, major_ARG) > 1) {
+		log_error("Option -j|--major may not be repeated.");
+		return 0;
+	}
+
+	/* Check with default 'y' */
+	if (!arg_int_value(cmd, persistent_ARG, 1)) { /* -Mn */
 		if (arg_is_set(cmd, minor_ARG) || arg_is_set(cmd, major_ARG)) {
-			log_error("--major and --minor incompatible with -Mn");
+			log_error("Options --major and --minor are incompatible with -Mn.");
 			return 0;
 		}
 		*major = *minor = -1;
 		return 1;
 	}
 
-	if (arg_count(cmd, minor_ARG) > 1) {
-		log_error("Option --minor may not be repeated.");
-		return 0;
-	}
+	/* -1 cannot be entered as an argument for --major, --minor */
+	*major = arg_int_value(cmd, major_ARG, -1);
+	*minor = arg_int_value(cmd, minor_ARG, -1);
 
-	if (arg_count(cmd, major_ARG) > 1) {
-		log_error("Option -j/--major may not be repeated.");
-		return 0;
+	if (arg_is_set(cmd, persistent_ARG)) { /* -My */
+		if (*minor == -1) {
+			log_error("Please specify minor number with --minor when using -My.");
+			return 0;
+		}
 	}
 
 	if (!strncmp(cmd->kernel_vsn, "2.4.", 4)) {
 		/* Major is required for 2.4 */
-		if (!arg_is_set(cmd, major_ARG)) {
-			log_error("Please specify major number with "
-				  "--major when using -My");
+		if (arg_is_set(cmd, persistent_ARG) && *major < 0) {
+			log_error("Please specify major number with --major when using -My.");
 			return 0;
 		}
-		*major = arg_int_value(cmd, major_ARG, -1);
 	} else {
-		if (arg_is_set(cmd, major_ARG)) {
-			log_warn("WARNING: Ignoring supplied major number - "
+		if (*major != -1) {
+			log_warn("WARNING: Ignoring supplied major number %d - "
 				 "kernel assigns major numbers dynamically. "
 				 "Using major number %d instead.",
-				 cmd->dev_types->device_mapper_major);
+				 *major, cmd->dev_types->device_mapper_major);
 		}
-		*major = cmd->dev_types->device_mapper_major;
+		/* Stay with dynamic major:minor if minor is not specified. */
+		*major = (*minor == -1) ? -1 : cmd->dev_types->device_mapper_major;
 	}
 
-	if (!arg_is_set(cmd, minor_ARG)) {
-		log_error("Please specify minor number with --minor when using -My.");
-		return 0;
-	}
-
-	*minor = arg_int_value(cmd, minor_ARG, -1);
-
-	if (!validate_major_minor(cmd, fmt, *major, *minor))
+	if ((*minor != -1) && !validate_major_minor(cmd, fmt, *major, *minor))
 		return_0;
 
 	return 1;


