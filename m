From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:58 +0000 (UTC)
Subject: master - config: add support for CFG_DISALLOW_INTERACTIVE flag to mark settings as not suitable for override in interactive mode
Message-ID: <20160809173958.6DDF46072F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8985c71bc7c6e8316adf97f2397ac32ab67191b
Commit:        e8985c71bc7c6e8316adf97f2397ac32ab67191b
Parent:        54bf15555be1808eb292cfc3edeece236a1c9744
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 8 10:43:18 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:49:11 2016 +0200

config: add support for CFG_DISALLOW_INTERACTIVE flag to mark settings as not suitable for override in interactive mode

Some settings are not suitable for override in interactive/shell
mode because such settings may confuse the code and it may end
up with unexpected behaviour. This is because of the fact that
once we're in the interactive/shell mode, we have already applied
some settings for the shell itself and we can't override them
further because we're already using those settings to drive the
interactive/shell mode. Such settings would get ignored silently
or, in worse case, they would mess up the existing configuration.
---
 lib/commands/toolcontext.c   |    3 +++
 lib/config/config.c          |   31 +++++++++++++++++++++++++++++++
 lib/config/config.h          |   33 +++++++++++++++++++--------------
 lib/config/config_settings.h |    1 +
 tools/lvmcmdline.c           |    3 +++
 5 files changed, 57 insertions(+), 14 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a7f76ba..eaabf98 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -950,6 +950,9 @@ static void _destroy_config(struct cmd_context *cmd)
 		 * they will get loaded again automatically.
 		 */
 		dm_list_iterate_items_safe(profile, tmp_profile, &cmd->profile_params->profiles) {
+			if (cmd->is_interactive && (profile == cmd->profile_params->shell_profile))
+				continue;
+
 			config_destroy(profile->cft);
 			profile->cft = NULL;
 			dm_list_move(&cmd->profile_params->profiles_to_load, &profile->list);
diff --git a/lib/config/config.c b/lib/config/config.c
index a569444..46ef8e7 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -385,6 +385,13 @@ int override_config_tree_from_string(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (cmd->is_interactive &&
+	    !config_force_check(cmd, CONFIG_STRING, cft_new)) {
+		log_error("Ignoring invalid configuration string.");
+		dm_config_destroy(cft_new);
+		return_0;
+	}
+
 	if (!(cs = dm_pool_zalloc(cft_new->mem, sizeof(struct config_source)))) {
 		log_error("Failed to allocate config source.");
 		dm_config_destroy(cft_new);
@@ -984,6 +991,20 @@ static int _config_def_check_node_is_profilable(struct cft_check_handle *handle,
 	return 1;
 }
 
+static int _config_def_check_node_is_allowed(struct cft_check_handle *handle,
+					     const char *rp, struct dm_config_node *cn,
+					     const cfg_def_item_t *def)
+{
+	if (handle->disallowed_flags & def->flags) {
+		log_warn_suppress(handle->suppress_messages,
+				  "Configuration %s \"%s\" is not allowed here.",
+				  cn->v ? "option" : "section", rp);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _config_def_check_node(struct cft_check_handle *handle,
 				  const char *vp, char *pvp, char *rp, char *prp,
 				  size_t buf_size, struct dm_config_node *cn)
@@ -1034,6 +1055,9 @@ static int _config_def_check_node(struct cft_check_handle *handle,
 	    !_config_def_check_node_is_profilable(handle, rp, cn, def))
 		return_0;
 
+	if (!_config_def_check_node_is_allowed(handle, rp, cn, def))
+		return_0;
+
 	handle->status[def->id] |= CFG_VALID;
 	return 1;
 }
@@ -2130,6 +2154,13 @@ int config_force_check(struct cmd_context *cmd, config_source_t source, struct d
 	/* provide warning messages only if config/checks=1 */
 	handle->suppress_messages = !find_config_tree_bool(cmd, config_checks_CFG, NULL);
 
+	/*
+	 * Some settings can't be changed if we're running commands interactively
+	 * within lvm shell so check for them in case we're in this interactive mode.
+	 */
+	if (cmd->is_interactive)
+		handle->disallowed_flags |= CFG_DISALLOW_INTERACTIVE;
+
 	r = config_def_check(handle);
 
 	dm_pool_free(cmd->libmem, handle);
diff --git a/lib/config/config.h b/lib/config/config.h
index 659b8b0..aa95202 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -48,6 +48,7 @@ struct profile_params {
 	struct profile *global_metadata_profile; /* profile (as given by --metadataprofile cmd arg) that overrides any other VG/LV-based profile */
 	struct dm_list profiles_to_load;         /* list of profiles which are only added, but still need to be loaded for any use */
 	struct dm_list profiles;                 /* list of profiles which are loaded already and which are ready for use */
+	struct profile *shell_profile;           /* master profile used in interactive/shell mode */
 };
 
 #define CFG_PATH_MAX_LEN 128
@@ -98,31 +99,34 @@ typedef union {
 
 
 /* whether the configuration item name is variable */
-#define CFG_NAME_VARIABLE	0x001
+#define CFG_NAME_VARIABLE        0x0001
 /* whether empty value is allowed */
-#define CFG_ALLOW_EMPTY		0x002
+#define CFG_ALLOW_EMPTY          0x0002
 /* whether the configuration item is for advanced use only */
-#define CFG_ADVANCED		0x004
+#define CFG_ADVANCED             0x0004
 /* whether the configuration item is not officially supported */
-#define CFG_UNSUPPORTED		0x008
+#define CFG_UNSUPPORTED          0x0008
 /* whether the configuration item is customizable by a profile */
-#define CFG_PROFILABLE		0x010
-/* whether the configuration item is customizable by a profile */
-/* and whether it can be attached to VG/LV metadata at the same time
+#define CFG_PROFILABLE           0x0010
+/* whether the configuration item is customizable by a profile
+ * and whether it can be attached to VG/LV metadata at the same time
  * The CFG_PROFILABLE_METADATA flag incorporates CFG_PROFILABLE flag!!! */
-#define CFG_PROFILABLE_METADATA 0x030
+#define CFG_PROFILABLE_METADATA  0x0030
 /* whether the default value is undefned */
-#define CFG_DEFAULT_UNDEFINED	0x040
+#define CFG_DEFAULT_UNDEFINED    0x0040
 /* whether the default value is commented out on output */
-#define CFG_DEFAULT_COMMENTED	0x080
+#define CFG_DEFAULT_COMMENTED    0x0080
 /* whether the default value is calculated during run time */
-#define CFG_DEFAULT_RUN_TIME	0x100
+#define CFG_DEFAULT_RUN_TIME     0x0100
 /* whether the configuration setting is disabled (and hence defaults always used) */
-#define CFG_DISABLED		0x200
+#define CFG_DISABLED             0x0200
 /* whether to print integers in octal form (prefixed by "0") */
-#define CFG_FORMAT_INT_OCTAL	0x400
+#define CFG_FORMAT_INT_OCTAL     0x0400
 /* whether to disable checks for the whole config section subtree */
-#define CFG_SECTION_NO_CHECK	0x800
+#define CFG_SECTION_NO_CHECK     0x0800
+/* whether to disallow a possibility to override configuration
+ * setting for commands run interactively (e.g. in lvm shell) */
+#define CFG_DISALLOW_INTERACTIVE 0x1000
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
@@ -212,6 +216,7 @@ struct cft_check_handle {
 	unsigned check_diff:1;		/* check if the value used differs from default one */
 	unsigned ignoreadvanced:1;	/* do not include advnced configs */
 	unsigned ignoreunsupported:1;	/* do not include unsupported configs */
+	uint16_t disallowed_flags;	/* set of disallowed flags */
 	uint8_t status[CFG_COUNT];	/* flags for each configuration item - the result of the check */
 };
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 9c46667..7d2cdd5 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -52,6 +52,7 @@
  *                                 CFG_DISABLED - configuration is disabled (defaults always used)
  *                                 CFG_FORMAT_INT_OCTAL - print integer number in octal form (also prefixed by "0")
  *                                 CFG_SECTION_NO_CHECK - do not check content of the section at all - use with care!!!
+ *                                 CFG_DISALLOW_INTERACTIVE - disallow configuration node for use in interactive environment (e.g. cmds run in lvm shell)
  *
  * type:		       Allowed type for the value of simple configuation setting, one of:
  *                                 CFG_TYPE_BOOL
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index cb41534..af38799 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1430,6 +1430,9 @@ static int _prepare_profiles(struct cmd_context *cmd)
 
 		log_debug(_setting_global_profile_msg, _command_profile_source_name, profile->name);
 		cmd->profile_params->global_command_profile = profile;
+
+		if (!cmd->arg_values)
+			cmd->profile_params->shell_profile = profile;
 	}
 
 


