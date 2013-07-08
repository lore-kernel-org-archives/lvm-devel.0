From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  8 Jul 2013 14:06:31 +0000 (UTC)
Subject: master - dumpconfig: add --mergedconfig option
Message-ID: <20130708140631.BF2226073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ed7d0cf1de4ebea6be8cb67759da40cb61c3913
Commit:        5ed7d0cf1de4ebea6be8cb67759da40cb61c3913
Parent:        f1e289001286f978630f5e6423acca1af322ebd7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 8 15:34:27 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 8 16:05:56 2013 +0200

dumpconfig: add --mergedconfig option

Normally, the lvm dumpconfig processes only the configuration tree
that is at the top of the cascade. Considering the cascade is:

  CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_MERGED_FILES/CONFIG_FILE

...then:

  (dumpconfig of lvm.conf only)
  raw/~ $ lvm dumpconfig allocation
  allocation {
	  maximise_cling=1
	  mirror_logs_require_separate_pvs=0
	  thin_pool_metadata_require_separate_pvs=0
	  thin_pool_chunk_size=64
  }

  (dumpconfig of selected profile configuration only)
  raw/~ $ lvm dumpconfig --profile test allocation
  allocation {
	  thin_pool_chunk_size=8
	  thin_pool_discards="passdown"
	  thin_pool_zero=1
  }

  (dumpconfig of given --config configuration only)
  raw/~ $ lvm dumpconfig --config 'allocation{thin_pool_chunk_size=16}' allocation
  allocation {
	  thin_pool_chunk_size=16
  }

The --mergedconfig option causes the configuration cascade to be
merged before processing it with dumpconfig:

  (dumpconfig of merged selected profile and lvm.conf)
  raw/~ $ lvm dumpconfig --profile test allocation --mergedconfig
  allocation {
	  maximise_cling=1
	  thin_pool_zero=1
	  thin_pool_discards="passdown"
	  mirror_logs_require_separate_pvs=0
	  thin_pool_metadata_require_separate_pvs=0
	  thin_pool_chunk_size=8
  }

  (dumpconfig merged given --config and selected profile and lvm.conf)
  raw/~ $ lvm dumpconfig --profile test --config 'allocation{thin_pool_chunk_size=16}' allocation --mergedconfig
  allocation {
	  maximise_cling=1
	  thin_pool_zero=1
	  thin_pool_discards="passdown"
	  mirror_logs_require_separate_pvs=0
	  thin_pool_metadata_require_separate_pvs=0
	  thin_pool_chunk_size=16
  }

Hence with the --mergedconfig, we are able to see the
configuration that is actually used when processing any
LVM command while using any combination of --config/--profile
options together with lvm.conf file.
---
 WHATS_NEW          |    1 +
 tools/args.h       |    1 +
 tools/commands.h   |    3 +-
 tools/dumpconfig.c |   87 ++++++++++++++++++++++++++++++++++++++-------------
 4 files changed, 69 insertions(+), 23 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 567441a..68b3b78 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add --mergedconfig to lvm dumpconfig for merged --config/--profile/lvm.conf.
   Relase memory and unblock signals in lock_vol error path.
   Define LVM2_* command errors in lvm2cmd.h and use in dmeventd plugins.
   Move errors.h to tools dir.
diff --git a/tools/args.h b/tools/args.h
index 73312ca..ee95ad8 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -93,6 +93,7 @@ arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", size_kb_arg, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0)
 arg(profile_ARG, '\0', "profile", string_arg, 0)
 arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
+arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index f84aa35..3f43260 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -38,12 +38,13 @@ xx(dumpconfig,
    "\t[--withversions] \n"
    "\t[--ignoreadvanced] \n"
    "\t[--ignoreunsupported] \n"
+   "\t[--mergedconfig] \n"
    "\t[--atversion version]] \n"
    "\t[--validate]\n"
    "\t[ConfigurationNode...]\n",
    file_ARG, configtype_ARG, withcomments_ARG, atversion_ARG,
    withversions_ARG, ignoreadvanced_ARG, ignoreunsupported_ARG,
-   validate_ARG)
+   mergedconfig_ARG, validate_ARG)
 
 xx(formats,
    "List available metadata formats",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 3839def..08f996a 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -15,7 +15,7 @@
 
 #include "tools.h"
 
-static int _get_vsn(struct cmd_context *cmd, uint16_t *version)
+static int _get_vsn(struct cmd_context *cmd, uint16_t *version_int)
 {
 	const char *atversion = arg_str_value(cmd, atversion_ARG, LVM_VERSION);
 	unsigned int major, minor, patchlevel;
@@ -25,31 +25,42 @@ static int _get_vsn(struct cmd_context *cmd, uint16_t *version)
 		return 0;
 	}
 
-	*version = vsn(major, minor, patchlevel);
+	*version_int = vsn(major, minor, patchlevel);
 	return 1;
 }
 
-static struct cft_check_handle *_get_cft_check_handle(struct cmd_context *cmd)
+static struct cft_check_handle *_get_cft_check_handle(struct cmd_context *cmd, struct dm_config_tree *cft)
 {
-	struct cft_check_handle *handle = cmd->cft_check_handle;
+	struct cft_check_handle *handle;
+	struct dm_pool *mem;
+
+	if (cft == cmd->cft) {
+		mem = cmd->libmem;
+		handle = cmd->cft_check_handle;
+	} else {
+		mem = cft->mem;
+		handle = NULL;
+	}
 
 	if (!handle) {
-		if (!(handle = dm_pool_zalloc(cmd->libmem, sizeof(*cmd->cft_check_handle)))) {
+		if (!(handle = dm_pool_zalloc(mem, sizeof(struct cft_check_handle)))) {
 			log_error("Configuration check handle allocation failed.");
 			return NULL;
 		}
-		handle->cft = cmd->cft;
-		cmd->cft_check_handle = handle;
+		handle->cft = cft;
+		if (cft == cmd->cft)
+			cmd->cft_check_handle = handle;
 	}
 
 	return handle;
 }
 
-static int _do_def_check(struct cmd_context *cmd, struct cft_check_handle **cft_check_handle)
+static int _do_def_check(struct cmd_context *cmd, struct dm_config_tree *cft,
+			 struct cft_check_handle **cft_check_handle)
 {
 	struct cft_check_handle *handle;
 
-	if (!(handle = _get_cft_check_handle(cmd)))
+	if (!(handle = _get_cft_check_handle(cmd, cft)))
 		return 0;
 
 	handle->force_check = 1;
@@ -62,6 +73,21 @@ static int _do_def_check(struct cmd_context *cmd, struct cft_check_handle **cft_
 	return 1;
 }
 
+static int _merge_config_cascade(struct cmd_context *cmd, struct dm_config_tree *cft_cascaded,
+				 struct dm_config_tree **cft_merged)
+{
+	if (!cft_cascaded)
+		return 1;
+
+	if (!*cft_merged && !(*cft_merged = config_open(CONFIG_MERGED_FILES, NULL, 0)))
+		return_0;
+
+	if (!_merge_config_cascade(cmd, cft_cascaded->cascade, cft_merged))
+		return_0;
+
+	return merge_config_tree(cmd, *cft_merged, cft_cascaded, CONFIG_MERGE_TYPE_RAW);
+}
+
 int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
@@ -103,8 +129,21 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	if (!_get_vsn(cmd, &tree_spec.version))
 		return EINVALID_CMD_LINE;
 
+	/*
+	 * Set the 'cft' to work with based on whether we need the plain
+	 * config tree or merged config tree cascade if --mergedconfig is used.
+	 */
+	if (arg_count(cmd, mergedconfig_ARG) && cmd->cft->cascade) {
+		if (!_merge_config_cascade(cmd, cmd->cft, &cft)) {
+			log_error("Failed to merge configuration.");
+			r = ECMD_FAILED;
+			goto out;
+		}
+	} else
+		cft = cmd->cft;
+
 	if (arg_count(cmd, validate_ARG)) {
-		if (!(cft_check_handle = _get_cft_check_handle(cmd)))
+		if (!(cft_check_handle = _get_cft_check_handle(cmd, cft)))
 			return ECMD_FAILED;
 
 		cft_check_handle->force_check = 1;
@@ -113,22 +152,27 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 
 		if (config_def_check(cmd, cft_check_handle)) {
 			log_print("LVM configuration valid.");
-			return ECMD_PROCESSED;
+			goto out;
 		} else {
 			log_error("LVM configuration invalid.");
-			return ECMD_FAILED;
+			r = ECMD_FAILED;
+			goto out;
 		}
 	}
 
 	if (!strcmp(type, "current")) {
 		tree_spec.type = CFG_DEF_TREE_CURRENT;
-		if (!_do_def_check(cmd, &cft_check_handle))
-			return ECMD_FAILED;
+		if (!_do_def_check(cmd, cft, &cft_check_handle)) {
+			r = ECMD_FAILED;
+			goto_out;
+		}
 	}
 	else if (!strcmp(type, "missing")) {
 		tree_spec.type = CFG_DEF_TREE_MISSING;
-		if (!_do_def_check(cmd, &cft_check_handle))
-			return ECMD_FAILED;
+		if (!_do_def_check(cmd, cft, &cft_check_handle)) {
+			r = ECMD_FAILED;
+			goto_out;
+		}
 	}
 	else if (!strcmp(type, "default")) {
 		tree_spec.type = CFG_DEF_TREE_DEFAULT;
@@ -141,15 +185,14 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	else {
 		log_error("Incorrect type of configuration specified. "
 			  "Expected one of: current, default, missing, new.");
-		return EINVALID_CMD_LINE;
+		r = EINVALID_CMD_LINE;
+		goto out;
 	}
 
 	if (cft_check_handle)
 		tree_spec.check_status = cft_check_handle->status;
 
-	if (tree_spec.type == CFG_DEF_TREE_CURRENT)
-		cft = cmd->cft;
-	else
+	if (tree_spec.type != CFG_DEF_TREE_CURRENT)
 		cft = config_def_create_tree(&tree_spec);
 
 	if (!config_write(cft, arg_count(cmd, withcomments_ARG),
@@ -158,8 +201,8 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		stack;
 		r = ECMD_FAILED;
 	}
-
-	if (cft != cmd->cft)
+out:
+	if (cft && (cft != cmd->cft))
 		dm_pool_destroy(cft->mem);
 
 	/*


