From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Feb 2017 19:20:53 +0000 (UTC)
Subject: master - lvconvert: include swap behavior in generic pool syntax
Message-ID: <20170217192054.02EFB60E3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f88ce5fb9954721b41fa1fc19c53abc18006c395
Commit:        f88ce5fb9954721b41fa1fc19c53abc18006c395
Parent:        56deed9d54c9070cc586f040264a8e1985b19bdc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 17 11:45:13 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 17 13:20:15 2017 -0600

lvconvert: include swap behavior in generic pool syntax

For this syntax:
lvconvert --thinpool LV1 --poolmetadata LV2
lvconvert --cachepool LV1 --poolmetadata LV2

Restore the metadata swapping behavior in addition to
the pool creation behavior.  When LV1 is already a pool,
the metadata LV will be swapped with LV2.
When LV1 is not a pool, it will be converted to a
pool using the specified LV for metadata.

This syntax is no longer advertised because of the
ambiguous behavior.  The primary syntaxes for pool
creation and metadata swapping will be the advertised
methods.
---
 man/lvconvert.8.end    |   21 +++++++
 man/lvmthin.7.in       |   16 ------
 tools/args.h           |    9 ++-
 tools/command-lines.in |   66 ++++++++++++++++++-----
 tools/command.c        |    5 ++
 tools/command.h        |    3 +-
 tools/lvconvert.c      |  136 ++++++++++++++++++++++++++----------------------
 tools/lvmcmdline.c     |    7 ++-
 tools/tools.h          |    2 +-
 9 files changed, 166 insertions(+), 99 deletions(-)

diff --git a/man/lvconvert.8.end b/man/lvconvert.8.end
index fa8cc1d..5a3d475 100644
--- a/man/lvconvert.8.end
+++ b/man/lvconvert.8.end
@@ -1,3 +1,24 @@
+.SH NOTES
+
+This previous command syntax would perform two different operations:
+.br
+\fBlvconvert --thinpool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
+.br
+If LV1 was not a thin pool, the command would convert LV1 to
+a thin pool, optionally using a specified LV for metadata.
+But, if LV1 was already a thin pool, the command would swap
+the current metadata LV with LV2 (for repair purposes.)
+
+In the same way, this previous command syntax would perform two different
+operations:
+.br
+\fBlvconvert --cachepool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
+.br
+If LV1 was not a cache pool, the command would convert LV1 to
+a cache pool, optionally using a specified LV for metadata.
+But, if LV1 was already a cache pool, the command would swap
+the current metadata LV with LV2 (for repair purposes.)
+
 .SH EXAMPLES
 
 Convert a linear LV to a two-way mirror LV.
diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 714233e..f6f8548 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -278,22 +278,6 @@ or vgchange to activate thin snapshots with the "k" attribute.
 
 \&
 
-.SS Alternate syntax for specifying type thin\-pool
-
-\&
-
-The fully specified syntax for creating a thin pool LV shown above is:
-
-.B lvconvert \-\-type thin-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
-
-An alternate syntax may be used for the same operation:
-
-.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
-
-The thin-pool type is inferred by lvm; the \-\-thinpool option is not an
-alias for \-\-type thin\-pool.
-
-
 .SS Automatic pool metadata LV
 
 \&
diff --git a/tools/args.h b/tools/args.h
index f64b126..06595a6 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -589,9 +589,12 @@ arg(stripes_long_ARG, '\0', "stripes", number_VAL, 0, 0,
     "existing allocated space, only newly allocated space can be striped.\n")
 
 arg(swapmetadata_ARG, '\0', "swapmetadata", 0, 0, 0,
-    "Remove the metadata LV in a pool and replace it with another specified LV.\n"
-    "The removed LV is preserved and given the name of the LV that replaced it.\n"
-    "Used for repair only.\n")
+    "Extracts the metadata LV from a pool and replaces it with another specified LV.\n"
+    "The extracted LV is preserved and given the name of the LV that replaced it.\n"
+    "Use for repair only. When the metadata LV is swapped out of the pool, it can\n"
+    "be activated directly and used with thin provisioning tools:\n"
+    "\\fBcache_dump\\fP(8), \\fBcache_repair\\fP(8), \\fBcache_restore\\fP(8),\n"
+    "\\fBthin_dump\\fP(8), \\fBthin_repair\\fP(8), \\fBthin_restore\\fP(8).\n")
 
 arg(syncaction_ARG, '\0', "syncaction", syncaction_VAL, 0, 0,
     "Initiate different types of RAID synchronization.\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 377e536..aed38e7 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -454,17 +454,36 @@ DESC: Convert LV to type thin-pool.
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual
 
-# alternate form of lvconvert --type thin-pool
-# deprecated because of non-standard syntax (missing positional arg)
-# Commands in this form are converted to standard form so that
-# the validation of LV types and rules specified above will apply.
-lvconvert --thinpool LV_linear_striped_raid_cache
+# This command syntax has two different meanings depending on
+# whether the LV pos arg is already a thin pool or not.
+#
+# 1. When the LV arg is not a pool, this command converts
+# the LV into a pool, optionally using a specified meta LV.
+# This is an alternate form of the primary command:
+# lvconvert --type thin-pool LV
+#
+# 2. When the LV is is already a pool and a meta LV is specified,
+# the meta LV is swapped.  Swapping a meta LV is a very specialized
+# operation that users should never use.
+# This is an alternate form of the primary command:
+# lvconvert --swapmetadata --poolmetadata LV LV
+#
+# The command def cannot include --poolmetadata as a required
+# option, otherwise 1 would not pass, so the validation of
+# this option cannot be done by the command defs, but has to
+# be done ad hoc in the lvconvert implementation.
+#
+# This command syntax is deprecated, and the primary forms
+# of creating a pool or swapping metadata should be used.
+
+lvconvert --thinpool LV_linear_striped_raid_cache_thinpool
 OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
 --discards Discards, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
-ID: lvconvert_to_thinpool_noarg
+ID: lvconvert_to_thinpool_or_swap_metadata
 DESC: Convert LV to type thin-pool (variant, use --type thin-pool).
-FLAGS: SECONDARY_SYNTAX
+DESC: Swap metadata LV in a thin pool (variant, use --swapmetadata).
+FLAGS: PREVIOUS_SYNTAX
 
 ---
 
@@ -475,17 +494,36 @@ OP: PV ...
 ID: lvconvert_to_cachepool
 DESC: Convert LV to type cache-pool.
 
-# alternate form of lvconvert --type cache-pool
-# deprecated because of non-standard syntax (missing positional arg)
-# Commands in this form are converted to standard form so that
-# the validation of LV types and rules specified above will apply.
-lvconvert --cachepool LV_linear_striped_raid
+# This command syntax has two different meanings depending on
+# whether the LV pos arg is already a cache pool or not.
+#
+# 1. When the LV arg is not a pool, this command converts
+# the LV into a pool, optionally using a specified meta LV.
+# This is an alternate form of the primary command:
+# lvconvert --type cache-pool LV
+#
+# 2. When the LV is is already a pool and a meta LV is specified,
+# the meta LV is swapped.  Swapping a meta LV is a very specialized
+# operation that users should never use.
+# This is an alternate form of the primary command:
+# lvconvert --swapmetadata --poolmetadata LV LV
+#
+# The command def cannot include --poolmetadata as a required
+# option, otherwise 1 would not pass, so the validation of
+# this option cannot be done by the command defs, but has to
+# be done ad hoc in the lvconvert implementation.
+#
+# This command syntax is deprecated, and the primary forms
+# of creating a pool or swapping metadata should be used.
+
+lvconvert --cachepool LV_linear_striped_raid_cachepool
 OO: --type cache-pool, OO_LVCONVERT_POOL, OO_LVCONVERT,
 --cachemode CacheMode, --cachepolicy String, --cachesettings String
 OP: PV ...
-ID: lvconvert_to_cachepool_noarg
+ID: lvconvert_to_cachepool_or_swap_metadata
 DESC: Convert LV to type cache-pool (variant, use --type cache-pool).
-FLAGS: SECONDARY_SYNTAX
+DESC: Swap metadata LV in a cache pool (variant, use --swapmetadata).
+FLAGS: PREVIOUS_SYNTAX
 
 ---
 
diff --git a/tools/command.c b/tools/command.c
index 6cd4d68..2897c65 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1128,6 +1128,8 @@ static void add_flags(struct command *cmd, char *line)
 {
 	if (strstr(line, "SECONDARY_SYNTAX"))
 		cmd->cmd_flags |= CMD_FLAG_SECONDARY_SYNTAX;
+	if (strstr(line, "PREVIOUS_SYNTAX"))
+		cmd->cmd_flags |= CMD_FLAG_PREVIOUS_SYNTAX;
 }
 
 #define MAX_RULE_OPTS 64
@@ -2659,6 +2661,9 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 			prev_cmd = NULL;
 		}
 
+		if (cmd->cmd_flags & CMD_FLAG_PREVIOUS_SYNTAX)
+			continue;
+
 		if ((cmd->cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !include_secondary)
 			continue;
 
diff --git a/tools/command.h b/tools/command.h
index fcf0ccb..95bd797 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -166,7 +166,8 @@ struct cmd_rule {
  */
 #define CMD_FLAG_ONE_REQUIRED_OPT   1  /* lvchange/vgchage require one item from required_opt_args */
 #define CMD_FLAG_SECONDARY_SYNTAX   2  /* allows syntax variants to be suppressed in certain output */
-#define CMD_FLAG_PARSE_ERROR        4  /* error parsing command-lines.in def */
+#define CMD_FLAG_PREVIOUS_SYNTAX    4  /* allows syntax variants to not be advertised in output */
+#define CMD_FLAG_PARSE_ERROR        8  /* error parsing command-lines.in def */
 
 /* a register of the lvm commands */
 struct command {
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a2ad115..b9e0665 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3790,51 +3790,6 @@ int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv)
 			       NULL, NULL, &_lvconvert_to_pool_single);
 }
 
-/*
- * Reformats non-standard command form into standard command form.
- *
- * In the command variants with no position LV arg, the LV arg is taken from
- * the --thinpool/--cachepool arg, and the position args are modified to match
- * the standard command form.
- */
-
-int lvconvert_to_pool_noarg_cmd(struct cmd_context *cmd, int argc, char **argv)
-{
-	struct command *new_command;
-	char *pool_data_name;
-	int i, p;
-
-	switch (cmd->command->command_enum) {
-	case lvconvert_to_thinpool_noarg_CMD:
-		pool_data_name = (char *)arg_str_value(cmd, thinpool_ARG, NULL);
-		new_command = get_command(lvconvert_to_thinpool_CMD);
-		break;
-	case lvconvert_to_cachepool_noarg_CMD:
-		pool_data_name = (char *)arg_str_value(cmd, cachepool_ARG, NULL);
-		new_command = get_command(lvconvert_to_cachepool_CMD);
-		break;
-	default:
-		log_error(INTERNAL_ERROR "Unknown pool conversion.");
-		return 0;
-	};
-
-	log_debug("Changing command %d:%s to standard form %d:%s",
-		  cmd->command->command_index, cmd->command->command_id,
-		  new_command->command_index, new_command->command_id);
-
-	/* Make the LV the first position arg. */
-
-	p = cmd->position_argc;
-	for (i = 0; i < cmd->position_argc; i++)
-		cmd->position_argv[p] = cmd->position_argv[p-1];
-
-	cmd->position_argv[0] = pool_data_name;
-	cmd->position_argc++;
-	cmd->command = new_command;
-
-	return lvconvert_to_pool_cmd(cmd, argc, argv);
-}
-
 static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 					 struct logical_volume *lv,
 					 struct processing_handle *handle)
@@ -4077,39 +4032,96 @@ int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **a
 			       NULL, NULL, &_lvconvert_swap_pool_metadata_single);
 }
 
-#if 0
-int lvconvert_swap_pool_metadata_noarg_cmd(struct cmd_context *cmd, int argc, char **argv)
+static int _lvconvert_to_pool_or_swap_metadata_single(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct processing_handle *handle)
 {
-	struct command *new_command;
-	char *pool_name;
+	struct dm_list *use_pvh = NULL;
+	int to_thinpool = 0;
+	int to_cachepool = 0;
 
 	switch (cmd->command->command_enum) {
-	case lvconvert_swap_thinpool_metadata_CMD:
-		pool_name = (char *)arg_str_value(cmd, thinpool_ARG, NULL);
+	case lvconvert_to_thinpool_or_swap_metadata_CMD:
+		to_thinpool = 1;
 		break;
-	case lvconvert_swap_cachepool_metadata_CMD:
-		pool_name = (char *)arg_str_value(cmd, cachepool_ARG, NULL);
+	case lvconvert_to_cachepool_or_swap_metadata_CMD:
+		to_cachepool = 1;
 		break;
 	default:
-		log_error(INTERNAL_ERROR "Unknown pool conversion.");
+		log_error(INTERNAL_ERROR "Invalid lvconvert pool command");
 		return 0;
 	};
 
-	new_command = get_command(lvconvert_swap_pool_metadata_CMD);
+	if (cmd->position_argc > 1) {
+		/* First pos arg is required LV, remaining are optional PVs. */
+		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))
+			return_ECMD_FAILED;
+	} else
+		use_pvh = &lv->vg->pvs;
+
+	/*
+	 * We can finally determine if this command is supposed to create
+	 * a pool or swap the metadata in an existing pool.
+	 *
+	 * This allows the ambiguous command:
+	 * 'lvconvert --thinpool LV1 --poolmetadata LV2' to mean either:
+	 * 1. convert LV2 to a pool using the specified meta LV2
+	 * 2. swap the meta lv in LV1 with LV2
+	 *
+	 * In case 2, the poolmetadata option is required, but in case 1
+	 * it is optional.  So, the command def is not able to validate
+	 * the required/optional option, and we have to check here
+	 * for missing poolmetadata in case 2.
+	 */
+	if (lv_is_pool(lv)) {
+		if (!arg_is_set(cmd, poolmetadata_ARG)) {
+			log_error("The --poolmetadata option is required to swap metadata.");
+			return ECMD_FAILED;
+		}
+		return _lvconvert_swap_pool_metadata_single(cmd, lv, handle);
+	}
+
+	if (!_lvconvert_to_pool(cmd, lv, to_thinpool, to_cachepool, use_pvh))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+/*
+ * In the command variants with no position LV arg, the LV arg is taken from
+ * the --thinpool/--cachepool arg, and the position args are modified to match
+ * the standard command form.
+ */
+
+int lvconvert_to_pool_or_swap_metadata_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	char *pool_data_name;
+	int i, p;
 
-	log_debug("Changing command %d:%s to standard form %d:%s",
-		  cmd->command->command_index, cmd->command->command_id,
-		  new_command->command_index, new_command->command_id);
+	switch (cmd->command->command_enum) {
+	case lvconvert_to_thinpool_or_swap_metadata_CMD:
+		pool_data_name = (char *)arg_str_value(cmd, thinpool_ARG, NULL);
+		break;
+	case lvconvert_to_cachepool_or_swap_metadata_CMD:
+		pool_data_name = (char *)arg_str_value(cmd, cachepool_ARG, NULL);
+		break;
+	default:
+		log_error(INTERNAL_ERROR "Unknown pool conversion.");
+		return 0;
+	};
 
 	/* Make the LV the first position arg. */
 
-	cmd->position_argv[0] = pool_name;
+	p = cmd->position_argc;
+	for (i = 0; i < cmd->position_argc; i++)
+		cmd->position_argv[p] = cmd->position_argv[p-1];
+
+	cmd->position_argv[0] = pool_data_name;
 	cmd->position_argc++;
-	cmd->command = new_command;
 
-	return lvconvert_swap_pool_metadata_cmd(cmd, argc, argv);
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_to_pool_or_swap_metadata_single);
 }
-#endif
 
 static int _lvconvert_merge_thin_single(struct cmd_context *cmd,
 					 struct logical_volume *lv,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 7e50d05..26f7476 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -135,12 +135,12 @@ struct command_function command_functions[CMD_COUNT] = {
 
 	/* lvconvert utilities for creating/maintaining thin and cache objects. */
 	{ lvconvert_to_thinpool_CMD,			lvconvert_to_pool_cmd },
-	{ lvconvert_to_thinpool_noarg_CMD,		lvconvert_to_pool_noarg_cmd },
 	{ lvconvert_to_cachepool_CMD,			lvconvert_to_pool_cmd },
-	{ lvconvert_to_cachepool_noarg_CMD,		lvconvert_to_pool_noarg_cmd },
 	{ lvconvert_to_thin_with_external_CMD,		lvconvert_to_thin_with_external_cmd },
 	{ lvconvert_to_cache_vol_CMD,			lvconvert_to_cache_vol_cmd },
 	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_cmd },
+	{ lvconvert_to_thinpool_or_swap_metadata_CMD,   lvconvert_to_pool_or_swap_metadata_cmd },
+	{ lvconvert_to_cachepool_or_swap_metadata_CMD,  lvconvert_to_pool_or_swap_metadata_cmd },
 	{ lvconvert_merge_thin_CMD,			lvconvert_merge_thin_cmd },
 	{ lvconvert_split_and_keep_cachepool_CMD,	lvconvert_split_cachepool_cmd },
 	{ lvconvert_split_and_remove_cachepool_CMD,	lvconvert_split_cachepool_cmd },
@@ -1727,6 +1727,9 @@ static int _usage(const char *name, int longhelp)
 		if (strcmp(_cmdline.commands[i].name, name))
 			continue;
 
+		if (_cmdline.commands[i].cmd_flags & CMD_FLAG_PREVIOUS_SYNTAX)
+			continue;
+
 		if ((_cmdline.commands[i].cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !longhelp)
 			continue;
 
diff --git a/tools/tools.h b/tools/tools.h
index b3858a0..62db506 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -274,10 +274,10 @@ int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char
 int lvconvert_start_poll_cmd(struct cmd_context *cmd, int argc, char **argv);
 
 int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv);
-int lvconvert_to_pool_noarg_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_cache_vol_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_thin_with_external_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_to_pool_or_swap_metadata_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv);
 


