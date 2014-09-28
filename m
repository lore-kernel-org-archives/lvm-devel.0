From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 28 Sep 2014 11:56:42 +0000 (UTC)
Subject: master - cleanup: rename func
Message-ID: <20140928115642.9270C60041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89e1190ef01943b59207c2093e643a6b06dc9be6
Commit:        89e1190ef01943b59207c2093e643a6b06dc9be6
Parent:        911d6efa51fac96846e109dbff8839cd3fb6cb25
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 27 18:53:08 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 28 13:49:01 2014 +0200

cleanup: rename func

Update name of function read_and_validate_major_minor
and put it into the right header file toollib.h.

(In release update for f09f85d027d8833)
---
 tools/lvchange.c   |    4 +-
 tools/lvcreate.c   |    4 +-
 tools/lvmcmdline.c |   54 --------------------------------------------------
 tools/toollib.c    |   56 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 tools/toollib.h    |    4 +++
 tools/tools.h      |    3 --
 6 files changed, 63 insertions(+), 62 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 7976bf3..fb3df50 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -542,8 +542,8 @@ static int lvchange_persistent(struct cmd_context *cmd,
 {
 	enum activation_change activate = CHANGE_AN;
 
-	if (!read_and_validate_major_minor(cmd, lv->vg->fid->fmt,
-					   &lv->major, &lv->minor))
+	if (!get_and_validate_major_minor(cmd, lv->vg->fid->fmt,
+					  &lv->major, &lv->minor))
 		return_0;
 
 	if (lv->minor == -1) {
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7c811ba..17fcd46 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -767,8 +767,8 @@ static int _read_activation_params(struct lvcreate_params *lp,
 			return 0;
 		}
 
-		if (!read_and_validate_major_minor(cmd, vg->fid->fmt,
-						   &lp->major, &lp->minor))
+		if (!get_and_validate_major_minor(cmd, vg->fid->fmt,
+						  &lp->major, &lp->minor))
                         return_0;
 	} else if (arg_is_set(cmd, major_ARG) || arg_is_set(cmd, minor_ARG)) {
 		log_error("--major and --minor require -My.");
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 5f258a2..e56a57a 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -576,60 +576,6 @@ int metadatacopies_arg(struct cmd_context *cmd, struct arg_values *av)
 	return int_arg(cmd, av);
 }
 
-int read_and_validate_major_minor(const struct cmd_context *cmd,
-				  const struct format_type *fmt,
-				  int32_t *major, int32_t *minor)
-{
-	if (strcmp(arg_str_value(cmd, persistent_ARG, "n"), "y")) {
-		if (arg_is_set(cmd, minor_ARG) || arg_is_set(cmd, major_ARG)) {
-			log_error("--major and --minor incompatible with -Mn");
-			return 0;
-		}
-		*major = *minor = -1;
-		return 1;
-	}
-
-	if (arg_count(cmd, minor_ARG) > 1) {
-		log_error("Option --minor may not be repeated.");
-		return 0;
-	}
-
-	if (arg_count(cmd, major_ARG) > 1) {
-		log_error("Option -j/--major may not be repeated.");
-		return 0;
-	}
-
-	if (!strncmp(cmd->kernel_vsn, "2.4.", 4)) {
-		/* Major is required for 2.4 */
-		if (!arg_is_set(cmd, major_ARG)) {
-			log_error("Please specify major number with "
-				  "--major when using -My");
-			return 0;
-		}
-		*major = arg_int_value(cmd, major_ARG, -1);
-	} else {
-		if (arg_is_set(cmd, major_ARG)) {
-			log_warn("WARNING: Ignoring supplied major number - "
-				 "kernel assigns major numbers dynamically. "
-				 "Using major number %d instead.",
-				 cmd->dev_types->device_mapper_major);
-		}
-		*major = cmd->dev_types->device_mapper_major;
-	}
-
-	if (!arg_is_set(cmd, minor_ARG)) {
-		log_error("Please specify minor number with --minor when using -My.");
-		return 0;
-	}
-
-	*minor = arg_int_value(cmd, minor_ARG, -1);
-
-	if (!validate_major_minor(cmd, fmt, *major, *minor))
-		return_0;
-
-	return 1;
-}
-
 static void __alloc(int size)
 {
 	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 31bb037..eb7f058 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1895,3 +1895,57 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 
 	return ret_max;
 }
+
+int get_and_validate_major_minor(const struct cmd_context *cmd,
+				 const struct format_type *fmt,
+				 int32_t *major, int32_t *minor)
+{
+	if (strcmp(arg_str_value(cmd, persistent_ARG, "n"), "y")) {
+		if (arg_is_set(cmd, minor_ARG) || arg_is_set(cmd, major_ARG)) {
+			log_error("--major and --minor incompatible with -Mn");
+			return 0;
+		}
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
+			return 0;
+		}
+		*major = arg_int_value(cmd, major_ARG, -1);
+	} else {
+		if (arg_is_set(cmd, major_ARG)) {
+			log_warn("WARNING: Ignoring supplied major number - "
+				 "kernel assigns major numbers dynamically. "
+				 "Using major number %d instead.",
+				 cmd->dev_types->device_mapper_major);
+		}
+		*major = cmd->dev_types->device_mapper_major;
+	}
+
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
+	return 1;
+}
diff --git a/tools/toollib.h b/tools/toollib.h
index c605aed..b4fc24c 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -140,4 +140,8 @@ int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	       struct logical_volume *lv, struct physical_volume *pv, int arg);
 
+int get_and_validate_major_minor(const struct cmd_context *cmd,
+				 const struct format_type *fmt,
+				 int32_t *major, int32_t *minor);
+
 #endif
diff --git a/tools/tools.h b/tools/tools.h
index cbea1fa..44364d8 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -138,9 +138,6 @@ int segtype_arg(struct cmd_context *cmd, struct arg_values *av);
 int alloc_arg(struct cmd_context *cmd, struct arg_values *av);
 int readahead_arg(struct cmd_context *cmd, struct arg_values *av);
 int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
-int read_and_validate_major_minor(const struct cmd_context *cmd,
-				  const struct format_type *fmt,
-				  int32_t *major, int32_t *minor);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);


