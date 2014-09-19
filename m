From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Sep 2014 13:57:38 +0000 (UTC)
Subject: master - tools: common handling of --persistent option
Message-ID: <20140919135738.A705C60CD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f09f85d027d8833727483efd6077f52d2e5b6ba2
Commit:        f09f85d027d8833727483efd6077f52d2e5b6ba2
Parent:        73f4fa6bc100e21562397627ea95a5e89443c1ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 14:57:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:54:20 2014 +0200

tools: common handling of --persistent option

Move common code for reading and processing
of --persistent arguments for lvcreate and lvchange
into lvmcmdline.

Reuse validate_major_minor() routine for validation.

Don't blindly activate LVs after change in cluster
and instead only local reactivation is supported.
(we have now many limited targets now).

Dropping 'sigint_caught()' handling, since
prompt() is resolving this case itself.
---
 WHATS_NEW          |    1 +
 tools/lvchange.c   |  103 +++++++++++++++++++++++-----------------------------
 tools/lvcreate.c   |   59 ++++++------------------------
 tools/lvmcmdline.c |   61 +++++++++++++++++++++----------
 tools/tools.h      |    5 ++-
 5 files changed, 103 insertions(+), 126 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 24e28c7..a2c4577 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Unify handling of --persistent option for lvcreate and lvchange.
   Validate major and minor numbers stored in metadata.
   Use -fPIE when linking -pie executables.
   Enable cache segment type by default.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e0e3b03..8ccbe19 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -552,86 +552,73 @@ static int lvchange_readahead(struct cmd_context *cmd,
 static int lvchange_persistent(struct cmd_context *cmd,
 			       struct logical_volume *lv)
 {
-	struct lvinfo info;
-	int active = 0;
-	int32_t major, minor;
+	enum activation_change activate = CHANGE_AN;
+
+	if (!read_and_validate_major_minor(cmd, lv->vg->fid->fmt,
+					   &lv->major, &lv->minor))
+		return_0;
 
-	if (!arg_uint_value(cmd, persistent_ARG, 0)) {
+	if (lv->minor == -1) {
 		if (!(lv->status & FIXED_MINOR)) {
-			log_error("Minor number is already not persistent "
-				  "for \"%s\"", lv->name);
+			log_error("Minor number is already not persistent for %s.",
+				  display_lvname(lv));
 			return 0;
 		}
 		lv->status &= ~FIXED_MINOR;
-		lv->minor = -1;
-		lv->major = -1;
-		log_verbose("Disabling persistent device number for \"%s\"",
-			    lv->name);
+		log_verbose("Disabling persistent device number for %s.",
+			    display_lvname(lv));
 	} else {
-		if (!arg_count(cmd, minor_ARG) && lv->minor < 0) {
-			log_error("Minor number must be specified with -My");
-			return 0;
-		}
-		if (arg_count(cmd, major_ARG) > 1) {
-			log_error("Option -j/--major may not be repeated.");
-			return 0;
-		}
-		if (arg_count(cmd, minor_ARG) > 1) {
-			log_error("Option --minor may not be repeated.");
-			return 0;
-		}
-		if (!arg_count(cmd, major_ARG) && lv->major < 0) {
-			log_error("Major number must be specified with -My");
-			return 0;
-		}
-		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists)
-			active = 1;
-
-		major = arg_int_value(cmd, major_ARG, lv->major);
-		minor = arg_int_value(cmd, minor_ARG, lv->minor);
-		if (!major_minor_valid(cmd, lv->vg->fid->fmt, major, minor))
-			return 0;
+		if (lv_is_active(lv)) {
+			if (!arg_count(cmd, force_ARG) &&
+			    !arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Logical volume %s will be "
+					  "deactivated temporarily. "
+					  "Continue? [y/n]: ", lv->name) == 'n') {
+				log_error("%s device number not changed.",
+					  display_lvname(lv));
+				return 0;
+			}
 
-		if (active && !arg_count(cmd, force_ARG) &&
-		    !arg_count(cmd, yes_ARG) &&
-		    yes_no_prompt("Logical volume %s will be "
-				  "deactivated temporarily. "
-				  "Continue? [y/n]: ", lv->name) == 'n') {
-			log_error("%s device number not changed.",
-				  lv->name);
-			return 0;
+			activate = CHANGE_AEY;
+			if (vg_is_clustered(lv->vg) &&
+			    locking_is_clustered() &&
+			    locking_supports_remote_queries() &&
+			    !lv_is_active_exclusive_locally(lv)) {
+				/* Reliable reactivate only locally */
+				log_print_unless_silent("Remotely active LV %s needs "
+							"individual reactivation.",
+							display_lvname(lv));
+				activate = CHANGE_ALY;
+			}
 		}
 
-		if (sigint_caught())
-			return_0;
-
-		log_verbose("Ensuring %s is inactive.", lv->name);
+		/* Ensuring LV is not active */
 		if (!deactivate_lv(cmd, lv)) {
-			log_error("%s: deactivation failed", lv->name);
+			log_error("Cannot deactivate %s.", display_lvname(lv));
 			return 0;
 		}
 		lv->status |= FIXED_MINOR;
-		lv->minor = minor;
-		lv->major = major;
-		log_verbose("Setting persistent device number to (%d, %d) "
-			    "for \"%s\"", lv->major, lv->minor, lv->name);
-
+		log_verbose("Setting persistent device number to (%d, %d) for %s.",
+			    lv->major, lv->minor, display_lvname(lv));
 	}
 
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
+	log_very_verbose("Updating logical volume %s on disk(s).",
+			 display_lvname(lv));
+
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
-	if (active) {
-		log_verbose("Re-activating logical volume \"%s\"", lv->name);
-		if (!activate_lv(cmd, lv)) {
-			log_error("%s: reactivation failed", lv->name);
+	if (activate != CHANGE_AN) {
+		log_verbose("Re-activating logical volume %s", display_lvname(lv));
+		if (!lv_active_change(cmd, lv, activate)) {
+			log_error("%s: reactivation failed", display_lvname(lv));
+			backup(lv->vg);
 			return 0;
 		}
 	}
 
+	backup(lv->vg);
+
 	return 1;
 }
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7870d4f..499d686 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -760,55 +760,18 @@ static int _read_activation_params(struct lvcreate_params *lp,
 		lp->wipe_signatures = 0;
 	}
 
-	if (arg_count(cmd, major_ARG) > 1) {
-		log_error("Option -j/--major may not be repeated.");
-		return 0;
-	}
-
-	if (arg_count(cmd, minor_ARG) > 1) {
-		log_error("Option --minor may not be repeated.");
-		return 0;
-	}
-
-	lp->minor = arg_int_value(cmd, minor_ARG, -1);
-	lp->major = arg_int_value(cmd, major_ARG, -1);
-
-	/* Persistent minor */
-	if (arg_count(cmd, persistent_ARG)) {
+	/* Persistent minor (and major) */
+	if (arg_is_set(cmd, persistent_ARG)) {
 		if (lp->create_pool && !lp->thin) {
 			log_error("--persistent is not permitted when creating a thin pool device.");
 			return 0;
 		}
-		if (!strcmp(arg_str_value(cmd, persistent_ARG, "n"), "y")) {
-			if (lp->minor == -1) {
-				log_error("Please specify minor number with "
-					  "--minor when using -My");
-				return 0;
-			}
-			if (!strncmp(cmd->kernel_vsn, "2.4.", 4)) {
-				if (lp->major == -1) {
-					log_error("Please specify major number with "
-						  "--major when using -My");
-					return 0;
-				}
-			} else {
-				if (lp->major >= 0)
-					log_warn("Ignoring supplied major number - kernel assigns "
-						 "major numbers dynamically. Using major number %d instead.",
-						  cmd->dev_types->device_mapper_major);
-				lp->major = cmd->dev_types->device_mapper_major;
-			}
-			if (!major_minor_valid(cmd, vg->fid->fmt, lp->major, lp->minor))
-				return 0;
-		} else {
-			if ((lp->minor != -1) || (lp->major != -1)) {
-				log_error("--major and --minor incompatible "
-					  "with -Mn");
-				return 0;
-			}
-		}
-	} else if (arg_count(cmd, minor_ARG) || arg_count(cmd, major_ARG)) {
-		log_error("--major and --minor require -My");
+
+		if (!read_and_validate_major_minor(cmd, vg->fid->fmt,
+						   &lp->major, &lp->minor))
+                        return_0;
+	} else if (arg_is_set(cmd, major_ARG) || arg_is_set(cmd, minor_ARG)) {
+		log_error("--major and --minor require -My.");
 		return 0;
 	}
 
@@ -844,7 +807,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	const char *segtype_str;
 	const char *tag;
 
-	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
 	dm_list_init(&lp->tags);
 	lp->target_attr = ~0;
@@ -1248,7 +1210,10 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int r = ECMD_FAILED;
-	struct lvcreate_params lp;
+	struct lvcreate_params lp = {
+                .major = -1,
+                .minor = -1,
+	};
 	struct lvcreate_cmdline_params lcp;
 	struct volume_group *vg;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d90ef91..9a5cc3a 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -576,32 +576,55 @@ int metadatacopies_arg(struct cmd_context *cmd, struct arg_values *av)
 	return int_arg(cmd, av);
 }
 
-int major_minor_valid(const struct cmd_context *cmd, const struct format_type *fmt,
-		      int32_t major, int32_t minor)
+int read_and_validate_major_minor(const struct cmd_context *cmd,
+				  const struct format_type *fmt,
+				  int32_t *major, int32_t *minor)
 {
-	if (!strncmp(cmd->kernel_vsn, "2.4.", 4) ||
-	    (fmt->features & FMT_RESTRICTED_LVIDS)) {
-		if (major < 0 || major > 255) {
-			log_error("Major number outside range 0-255");
+	if (strcmp(arg_str_value(cmd, persistent_ARG, "n"), "y")) {
+		if (arg_is_set(cmd, minor_ARG) || arg_is_set(cmd, major_ARG)) {
+			log_error("--major and --minor incompatible with -Mn");
 			return 0;
 		}
-		if (minor < 0 || minor > 255) {
-			log_error("Minor number outside range 0-255");
-			return 0;
-		}
-	} else {
-		/* 12 bits for major number */
-		if (major < 0 || major > 4095) {
-			log_error("Major number outside range 0-4095");
-			return 0;
-		}
-		/* 20 bits for minor number */
-		if (minor < 0 || minor > 1048575) {
-			log_error("Minor number outside range 0-1048575");
+		*major = *minor = -1;
+		return 1;
+	}
+
+	if (arg_count(cmd, minor_ARG) > 1) {
+		log_error("Option --minor may not be repeated.");
+		return 0;
+	}
+
+	if (arg_count(cmd, major_ARG) > 1) {
+		log_error("Option -j/--major may not be repeated.");
+		return 0;
+	}
+
+	if (!strncmp(cmd->kernel_vsn, "2.4.", 4)) {
+		/* Major is required for 2.4 */
+		if (!arg_is_set(cmd, major_ARG)) {
+			log_error("Please specify major number with "
+				  "--major when using -My");
 			return 0;
 		}
+		*major = arg_int_value(cmd, major_ARG, -1);
+	} else if (arg_is_set(cmd, major_ARG)) {
+		log_warn("WARNING: Ignoring supplied major number - "
+			 "kernel assigns major numbers dynamically. "
+			 "Using major number %d instead.",
+			 cmd->dev_types->device_mapper_major);
+		*major = cmd->dev_types->device_mapper_major;
 	}
 
+	if (!arg_is_set(cmd, minor_ARG)) {
+		log_error("Please specify minor number with --minor when using -My.");
+		return 0;
+	}
+
+	*minor = arg_int_value(cmd, minor_ARG, -1);
+
+	if (!validate_major_minor(cmd, fmt, *major, *minor))
+		return_0;
+
 	return 1;
 }
 
diff --git a/tools/tools.h b/tools/tools.h
index 51c6a4e..cbea1fa 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -138,8 +138,9 @@ int segtype_arg(struct cmd_context *cmd, struct arg_values *av);
 int alloc_arg(struct cmd_context *cmd, struct arg_values *av);
 int readahead_arg(struct cmd_context *cmd, struct arg_values *av);
 int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
-int major_minor_valid(const struct cmd_context * cmd, const struct format_type *fmt,
-		      int32_t major, int32_t minor);
+int read_and_validate_major_minor(const struct cmd_context *cmd,
+				  const struct format_type *fmt,
+				  int32_t *major, int32_t *minor);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);


