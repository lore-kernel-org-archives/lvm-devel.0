From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 20 May 2014 14:28:51 +0000 (UTC)
Subject: master - config: differentiate command and metadata profiles and consolidate profile handling code
Message-ID: <20140520142851.E28EA61200@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e3e4d69944f072742fd13c5ac74d68e41a3db55
Commit:        9e3e4d69944f072742fd13c5ac74d68e41a3db55
Parent:        c5fbd2c59f1248b1315aae71dee032878d8476f8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 20 14:13:10 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 20 16:21:48 2014 +0200

config: differentiate command and metadata profiles and consolidate profile handling code

- When defining configuration source, the code now uses separate
  CONFIG_PROFILE_COMMAND and CONFIG_PROFILE_METADATA markers
  (before, it was just CONFIG_PROFILE that did not make the
  difference between the two). This helps when checking the
  configuration if it contains correct set of options which
  are all in either command-profilable or metadata-profilable
  group without mixing these groups together - so it's a firm
  distinction. The "command profile" can't contain
  "metadata profile" and vice versa! This is strictly checked
  and if the settings are mixed, such profile is rejected and
  it's not used. So in the end, the CONFIG_PROFILE_COMMAND
  set of options and CONFIG_PROFILE_METADATA are mutually exclusive
  sets.

- Marking configuration with one or the other marker will also
  determine the way these configuration sources are positioned
  in the configuration cascade which is now:

  CONFIG_STRING -> CONFIG_PROFILE_COMMAND -> CONFIG_PROFILE_METADATA -> CONFIG_FILE/CONFIG_MERGED_FILES

- Marking configuration with one or the other marker will also make
  it possible to issue a command context refresh (will be probably
  a part of a future patch) if needed for settings in global profile
  set. For settings in metadata profile set this is impossible since
  we can't refresh cmd context in the middle of reading VG/LV metadata
  and for each VG/LV separately because each VG/LV can have a different
  metadata profile assinged and it's not possible to change these
  settings at this level.

- When command profile is incorrect, it's rejected *and also* the
  command exits immediately - the profile *must* be correct for the
  command that was run with a profile to be executed. Before this
  patch, when the profile was found incorrect, there was just the
  warning message and the command continued without profile applied.
  But it's more correct to exit immediately in this case.

- When metadata profile is incorrect, we reject it during command
  runtime (as we know the profile name from metadata and not early
  from command line as it is in case of command profiles) and we
  *do continue* with the command as we're in the middle of operation.
  Also, the metadata profile is applied directly and on the fly on
  find_config_tree_* fn call and even if the metadata profile is
  found incorrect, we still need to return the non-profiled value
  as found in the other configuration provided or default value.
  To exit immediately even in this case, we'd need to refactor
  existing find_config_tree_* fns so they can return error. Currently,
  these fns return only config values (which end up with default
  values in the end if the config is not found).

- To check the profile validity before use to be sure it's correct,
  one can use :

    lvm dumpconfig --commandprofile/--metadataprofile ProfileName --validate

  (the --commandprofile/--metadataprofile for dumpconfig will come
   as part of the subsequent patch)

- This patch also adds a reference to --commandprofile and
  --metadataprofile in the cmd help string (which was missing before
  for the --profile for some commands). We do not mention --profile
  now as people should use --commandprofile or --metadataprofile
  directly. However, the --profile is still supported for backward
  compatibility and it's translated as:

    --profile == --metadataprofile for lvcreate, vgcreate, lvchange and vgchange
                 (as these commands are able to attach profile to metadata)

    --profile == --commandprofile for all the other commands
                (--metadataprofile is not allowed there as it makes no sense)

- This patch also contains some cleanups to make the code handling
  the profiles more readable...
---
 WHATS_NEW                     |    3 +
 lib/commands/toolcontext.c    |   20 ++-
 lib/config/config.c           |  322 ++++++++++++++++++++++++++++++-----------
 lib/config/config.h           |   15 +-
 lib/format_text/import_vsn1.c |    4 +-
 lib/metadata/lv_manip.c       |    2 +-
 lib/mm/memlock.c              |    2 +-
 tools/args.h                  |    2 +
 tools/commands.h              |  101 ++++++++++---
 tools/lvchange.c              |   22 ++-
 tools/lvmcmdline.c            |  141 ++++++++++++++++---
 tools/vgchange.c              |   14 ++-
 tools/vgcreate.c              |    2 +-
 13 files changed, 495 insertions(+), 155 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6cbd622..b57a1c3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.107 - 
 ==================================
+  Exit immediately with error if command profile is found invalid.
+  Separate --profile cmd line arg into --commandprofile and --metadataprofile.
+  Strictly separate command profiles and per-VG/LV profiles referenced in mda.
   Fix dumpconfig --type diff when run as second and later cmd in lvm shell.
   Fix wrong profile reuse from previous run if another cmd is run in lvm shell.
   Move cache description from lvm(8) to lvmcache(7) man page.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 904ae83..519d36a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -717,7 +717,8 @@ static void _destroy_config(struct cmd_context *cmd)
 
 	/* CONFIG_PROFILE */
 	if (cmd->profile_params) {
-		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE_COMMAND);
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE_METADATA);
 		/*
 		 * Destroy config trees for any loaded profiles and
 		 * move these profiles to profile_to_load list.
@@ -1605,7 +1606,7 @@ int refresh_filters(struct cmd_context *cmd)
 int refresh_toolcontext(struct cmd_context *cmd)
 {
 	struct dm_config_tree *cft_cmdline, *cft_tmp;
-	const char *profile_name;
+	const char *profile_command_name, *profile_metadata_name;
 	struct profile *profile;
 
 	log_verbose("Reloading config files");
@@ -1633,8 +1634,10 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	cft_cmdline = remove_config_tree_by_source(cmd, CONFIG_STRING);
 
 	/* save the global profile name used */
-	profile_name = cmd->profile_params->global_profile ?
-			cmd->profile_params->global_profile->name : NULL;
+	profile_command_name = cmd->profile_params->global_command_profile ?
+				cmd->profile_params->global_command_profile->name : NULL;
+	profile_metadata_name = cmd->profile_params->global_metadata_profile ?
+				cmd->profile_params->global_metadata_profile->name : NULL;
 
 	_destroy_config(cmd);
 
@@ -1653,8 +1656,13 @@ int refresh_toolcontext(struct cmd_context *cmd)
 		cmd->cft = dm_config_insert_cascaded_tree(cft_cmdline, cft_tmp);
 
 	/* Reload the global profile. */
-	if (profile_name) {
-		if (!(profile = add_profile(cmd, profile_name)) ||
+	if (profile_command_name) {
+		if (!(profile = add_profile(cmd, profile_command_name, CONFIG_PROFILE_COMMAND)) ||
+		    !override_config_tree_from_profile(cmd, profile))
+			return_0;
+	}
+	if (profile_metadata_name) {
+		if (!(profile = add_profile(cmd, profile_metadata_name, CONFIG_PROFILE_METADATA)) ||
 		    !override_config_tree_from_profile(cmd, profile))
 			return_0;
 	}
diff --git a/lib/config/config.c b/lib/config/config.c
index 4b5c18c..4fbee66 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -38,7 +38,8 @@ static const char *_config_source_names[] = {
 	[CONFIG_FILE] = "file",
 	[CONFIG_MERGED_FILES] = "merged files",
 	[CONFIG_STRING] = "string",
-	[CONFIG_PROFILE] = "profile",
+	[CONFIG_PROFILE_COMMAND] = "command profile",
+	[CONFIG_PROFILE_METADATA] = "metadata profile",
 	[CONFIG_FILE_SPECIAL] = "special purpose"
 };
 
@@ -83,6 +84,19 @@ config_source_t config_get_source_type(struct dm_config_tree *cft)
 	return cs ? cs->type : CONFIG_UNDEFINED;
 }
 
+static inline int _is_profile_based_config_source(config_source_t source)
+{
+	return (source == CONFIG_PROFILE_COMMAND) ||
+	       (source == CONFIG_PROFILE_METADATA);
+}
+
+static inline int _is_file_based_config_source(config_source_t source)
+{
+	return (source == CONFIG_FILE) ||
+	       (source == CONFIG_FILE_SPECIAL) ||
+	       _is_profile_based_config_source(source);
+}
+
 /*
  * public interface
  */
@@ -102,9 +116,7 @@ struct dm_config_tree *config_open(config_source_t source,
 		goto fail;
 	}
 
-	if ((source == CONFIG_FILE) ||
-	    (source == CONFIG_FILE_SPECIAL) ||
-	    (source == CONFIG_PROFILE)) {
+	if (_is_file_based_config_source(source)) {
 		if (!(cf = dm_pool_zalloc(cft->mem, sizeof(struct config_file)))) {
 			log_error("Failed to allocate config file.");
 			goto fail;
@@ -137,9 +149,7 @@ int config_file_check(struct dm_config_tree *cft, const char **filename, struct
 	struct config_file *cf;
 	struct stat _info;
 
-	if ((cs->type != CONFIG_FILE) &&
-	    (cs->type != CONFIG_PROFILE) &&
-	    (cs->type != CONFIG_FILE_SPECIAL)) {
+	if (!_is_file_based_config_source(cs->type)) {
 		log_error(INTERNAL_ERROR "config_file_check: expected file, special file or "
 					 "profile config source, found %s config source.",
 					 _config_source_names[cs->type]);
@@ -234,9 +244,7 @@ void config_destroy(struct dm_config_tree *cft)
 
 	cs = dm_config_get_custom(cft);
 
-	if ((cs->type == CONFIG_FILE) ||
-	    (cs->type == CONFIG_PROFILE) ||
-	    (cs->type == CONFIG_FILE_SPECIAL)) {
+	if (_is_file_based_config_source(cs->type)) {
 		cf = cs->source.file;
 		if (cf && cf->dev)
 			if (!dev_close(cf->dev))
@@ -261,7 +269,7 @@ struct dm_config_tree *config_file_open_and_read(const char *config_file,
 	/* Is there a config file? */
 	if (stat(config_file, &info) == -1) {
 		/* Profile file must be present! */
-		if (errno == ENOENT && (source != CONFIG_PROFILE))
+		if (errno == ENOENT && (!_is_profile_based_config_source(source)))
 			return cft;
 		log_sys_error("stat", config_file);
 		goto bad;
@@ -360,7 +368,7 @@ int override_config_tree_from_string(struct cmd_context *cmd,
 
 	/*
 	 * Follow this sequence:
-	 * CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES
+	 * CONFIG_STRING -> CONFIG_PROFILE_COMMAND -> CONFIG_PROFILE_METADATA -> CONFIG_FILE/CONFIG_MERGED_FILES
 	 */
 
 	if (cs->type == CONFIG_STRING) {
@@ -388,39 +396,89 @@ int override_config_tree_from_string(struct cmd_context *cmd,
 	return 1;
 }
 
-int override_config_tree_from_profile(struct cmd_context *cmd,
-				      struct profile *profile)
+static int _override_config_tree_from_command_profile(struct cmd_context *cmd,
+						      struct profile *profile)
 {
-	struct dm_config_tree *cft = cmd->cft, *cft_string = NULL;
+	struct dm_config_tree *cft = cmd->cft, *cft_previous = NULL;
 	struct config_source *cs = dm_config_get_custom(cft);
 
-	/*
-	 * Follow this sequence:
-	 * CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES
-	 */
+	if (cs->type == CONFIG_STRING) {
+		cft_previous = cft;
+		cft = cft->cascade;
+		cs = dm_config_get_custom(cft);
+	}
 
-	if (!profile->cft && !load_profile(cmd, profile))
-		return_0;
+	if (cs->type == CONFIG_PROFILE_COMMAND) {
+		log_error(INTERNAL_ERROR "_override_config_tree_from_command_profile: "
+				"config cascade already contains a command profile config.");
+		return 0;
+	}
+
+	if (cft_previous)
+		dm_config_insert_cascaded_tree(cft_previous, profile->cft);
+	else
+		cmd->cft = profile->cft;
+
+	dm_config_insert_cascaded_tree(profile->cft, cft);
+
+	return 1;
+}
+
+static int _override_config_tree_from_metadata_profile(struct cmd_context *cmd,
+						       struct profile *profile)
+{
+	struct dm_config_tree *cft = cmd->cft, *cft_previous = NULL;
+	struct config_source *cs = dm_config_get_custom(cft);
 
 	if (cs->type == CONFIG_STRING) {
-		cft_string = cft;
+		cft_previous = cft;
+		cft = cft->cascade;
+	}
+
+	if (cs->type == CONFIG_PROFILE_COMMAND) {
+		cft_previous = cft;
 		cft = cft->cascade;
 		cs = dm_config_get_custom(cft);
-		if (cs->type == CONFIG_PROFILE) {
-			log_error(INTERNAL_ERROR "override_config_tree_from_profile: "
-				  "config cascade already contains a profile config.");
-			return 0;
-		}
-		dm_config_insert_cascaded_tree(cft_string, profile->cft);
 	}
 
-	cmd->cft = dm_config_insert_cascaded_tree(profile->cft, cft);
+	cs = dm_config_get_custom(cft);
+
+	if (cs->type == CONFIG_PROFILE_METADATA) {
+		log_error(INTERNAL_ERROR "_override_config_tree_from_metadata_profile: "
+				"config cascade already contains a metadata profile config.");
+		return 0;
+	}
+
+	if (cft_previous)
+		dm_config_insert_cascaded_tree(cft_previous, profile->cft);
+	else
+		cmd->cft = profile->cft;
 
-	cmd->cft = cft_string ? : profile->cft;
+	dm_config_insert_cascaded_tree(profile->cft, cft);
 
 	return 1;
 }
 
+int override_config_tree_from_profile(struct cmd_context *cmd,
+				      struct profile *profile)
+{
+	/*
+	 * Follow this sequence:
+	 * CONFIG_STRING -> CONFIG_PROFILE_COMMAND -> CONFIG_PROFILE_METADATA -> CONFIG_FILE/CONFIG_MERGED_FILES
+	 */
+
+	if (!profile->cft && !load_profile(cmd, profile))
+		return_0;
+
+	if (profile->source == CONFIG_PROFILE_COMMAND)
+		return _override_config_tree_from_command_profile(cmd, profile);
+	else if (profile->source == CONFIG_PROFILE_METADATA)
+		return _override_config_tree_from_metadata_profile(cmd, profile);
+
+	log_error(INTERNAL_ERROR "override_config_tree_from_profile: incorrect profile source type");
+	return 0;
+}
+
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum)
@@ -432,9 +490,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 	char *buf = NULL;
 	struct config_source *cs = dm_config_get_custom(cft);
 
-	if ((cs->type != CONFIG_FILE) &&
-	    (cs->type != CONFIG_PROFILE) &&
-	    (cs->type != CONFIG_FILE_SPECIAL)) {
+	if (!_is_file_based_config_source(cs->type)) {
 		log_error(INTERNAL_ERROR "config_file_read_fd: expected file, special file "
 					 "or profile config source, found %s config source.",
 					 _config_source_names[cs->type]);
@@ -850,6 +906,48 @@ static int _config_def_check_node_value(struct cft_check_handle *handle,
 	return 1;
 }
 
+static int _config_def_check_node_is_profilable(struct cft_check_handle *handle,
+						const char *rp, struct dm_config_node *cn,
+						const cfg_def_item_t *def)
+{
+	uint16_t flags;
+
+	if (!(def->flags & CFG_PROFILABLE)) {
+		log_warn_suppress(handle->suppress_messages,
+				  "Configuration %s \"%s\" is not customizable by "
+				  "a profile.", cn->v ? "option" : "section", rp);
+		return 0;
+	}
+
+	flags = def->flags & ~CFG_PROFILABLE;
+
+	/*
+	* Make sure there is no metadata profilable config in the command profile!
+	*/
+	if ((handle->source == CONFIG_PROFILE_COMMAND) && (flags & CFG_PROFILABLE_METADATA)) {
+		log_warn_suppress(handle->suppress_messages,
+				  "Configuration %s \"%s\" is customizable by "
+				  "metadata profile only, not command profile.",
+				   cn->v ? "option" : "section", rp);
+		return 0;
+	}
+
+	/*
+	 * Make sure there is no command profilable config in the metadata profile!
+	 * (sections do not need to be flagged with CFG_PROFILABLE_METADATA, the
+	 *  CFG_PROFILABLE is enough as sections may contain both types inside)
+	 */
+	if ((handle->source == CONFIG_PROFILE_METADATA) && cn->v && !(flags & CFG_PROFILABLE_METADATA)) {
+		log_warn_suppress(handle->suppress_messages,
+				  "Configuration %s \"%s\" is customizable by "
+				  "command profile only, not metadata profile.",
+				   cn->v ? "option" : "section", rp);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _config_def_check_node(struct cft_check_handle *handle,
 				  const char *vp, char *pvp, char *rp, char *prp,
 				  size_t buf_size, struct dm_config_node *cn)
@@ -896,13 +994,9 @@ static int _config_def_check_node(struct cft_check_handle *handle,
 	 * in certain types of configuration trees as in some
 	 * the use of configuration is restricted, e.g. profiles...
 	 */
-	if (handle->source == CONFIG_PROFILE &&
-	    !(def->flags & CFG_PROFILABLE)) {
-		log_warn_suppress(handle->suppress_messages,
-			"Configuration %s \"%s\" is not customizable by "
-			"a profile.", cn->v ? "option" : "section", rp);
-		return 0;
-	}
+	if (_is_profile_based_config_source(handle->source) &&
+	    !_config_def_check_node_is_profilable(handle, rp, cn, def))
+		return_0;
 
 	handle->status[def->id] |= CFG_VALID;
 	return 1;
@@ -1028,6 +1122,23 @@ out:
 	return r;
 }
 
+static int _apply_local_profile(struct cmd_context *cmd, struct profile *profile)
+{
+	if (!profile)
+		return 0;
+
+	/*
+	 * Global metadata profile overrides the local one.
+	 * This simply means the "--metadataprofile" arg
+	 * overrides any profile attached to VG/LV.
+	 */
+	if ((profile->source == CONFIG_PROFILE_METADATA) &&
+	     cmd->profile_params->global_metadata_profile)
+		return 0;
+
+	return override_config_tree_from_profile(cmd, profile);
+}
+
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
@@ -1035,14 +1146,13 @@ const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int
 	int profile_applied = 0;
 	const struct dm_config_node *cn;
 
-	if (profile && !cmd->profile_params->global_profile)
-		profile_applied = override_config_tree_from_profile(cmd, profile);
-
+	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
+
 	cn = dm_config_tree_find_node(cmd->cft, path);
 
 	if (profile_applied)
-		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+		remove_config_tree_by_source(cmd, profile->source);
 
 	return cn;
 }
@@ -1054,9 +1164,7 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	int profile_applied = 0;
 	const char *str;
 
-	if (profile && !cmd->profile_params->global_profile)
-		profile_applied = override_config_tree_from_profile(cmd, profile);
-
+	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_STRING)
@@ -1065,7 +1173,7 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	str = dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
 
 	if (profile_applied)
-		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+		remove_config_tree_by_source(cmd, profile->source);
 
 	return str;
 }
@@ -1077,9 +1185,7 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 	int profile_applied = 0;
 	const char *str;
 
-	if (profile && !cmd->profile_params->global_profile)
-		profile_applied = override_config_tree_from_profile(cmd, profile);
-
+	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_STRING)
@@ -1090,7 +1196,7 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 	str = dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
 
 	if (profile_applied)
-		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+		remove_config_tree_by_source(cmd, profile->source);
 
 	return str;
 }
@@ -1102,9 +1208,7 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 	int profile_applied = 0;
 	int i;
 
-	if (profile && !cmd->profile_params->global_profile)
-		profile_applied = override_config_tree_from_profile(cmd, profile);
-
+	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_INT)
@@ -1113,7 +1217,7 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 	i = dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
 
 	if (profile_applied)
-		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+		remove_config_tree_by_source(cmd, profile->source);
 
 	return i;
 }
@@ -1125,9 +1229,7 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	int profile_applied = 0;
 	int i64;
 
-	if (profile && !cmd->profile_params->global_profile)
-		profile_applied = override_config_tree_from_profile(cmd, profile);
-
+	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_INT)
@@ -1136,7 +1238,7 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	i64 = dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
 
 	if (profile_applied)
-		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+		remove_config_tree_by_source(cmd, profile->source);
 
 	return i64;
 }
@@ -1148,9 +1250,7 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	int profile_applied = 0;
 	float f;
 
-	if (profile && !cmd->profile_params->global_profile)
-		profile_applied = override_config_tree_from_profile(cmd, profile);
-
+	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_FLOAT)
@@ -1159,7 +1259,7 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	f = dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile));
 
 	if (profile_applied)
-		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+		remove_config_tree_by_source(cmd, profile->source);
 
 	return f;
 }
@@ -1171,9 +1271,7 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	int profile_applied = 0;
 	int b;
 
-	if (profile && !cmd->profile_params->global_profile)
-		profile_applied = override_config_tree_from_profile(cmd, profile);
-
+	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_BOOL)
@@ -1182,7 +1280,7 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	b = dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile));
 
 	if (profile_applied)
-		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+		remove_config_tree_by_source(cmd, profile->source);
 
 	return b;
 }
@@ -1627,7 +1725,7 @@ static int _check_profile(struct cmd_context *cmd, struct profile *profile)
 
 	handle->cmd = cmd;
 	handle->cft = profile->cft;
-	handle->source = CONFIG_PROFILE;
+	handle->source = profile->source;
 	/* the check is compulsory - allow only profilable items in a profile config! */
 	handle->force_check = 1;
 	/* provide warning messages only if config/checks=1 */
@@ -1639,11 +1737,44 @@ static int _check_profile(struct cmd_context *cmd, struct profile *profile)
 	return r;
 }
 
-struct profile *add_profile(struct cmd_context *cmd, const char *profile_name)
+static int _get_profile_from_list(struct dm_list *list, const char *profile_name,
+				  config_source_t source, struct profile **profile_found)
+{
+	struct profile *profile;
+
+	dm_list_iterate_items(profile, list) {
+		if (!strcmp(profile->name, profile_name)) {
+			if (profile->source == source) {
+				*profile_found = profile;
+				return 1;
+			}
+			log_error(INTERNAL_ERROR "Profile %s already added as "
+				  "%s type, but requested type is %s.",
+				   profile_name,
+				   _config_source_names[profile->source],
+				   _config_source_names[source]);
+			return 0;
+		}
+	}
+
+	*profile_found = NULL;
+	return 1;
+}
+
+struct profile *add_profile(struct cmd_context *cmd, const char *profile_name, config_source_t source)
 {
 	struct profile *profile;
 
 	/* Do some sanity checks first. */
+	if (!_is_profile_based_config_source(source)) {
+		log_error(INTERNAL_ERROR "add_profile: incorrect configuration "
+			  "source, expected %s or %s but %s requested",
+			  _config_source_names[CONFIG_PROFILE_COMMAND],
+			  _config_source_names[CONFIG_PROFILE_METADATA],
+			  _config_source_names[source]);
+		return NULL;
+	}
+
 	if (!profile_name || !*profile_name) {
 		log_error("Undefined profile name.");
 		return NULL;
@@ -1654,14 +1785,29 @@ struct profile *add_profile(struct cmd_context *cmd, const char *profile_name)
 		return NULL;
 	}
 
-	/* Check if the profile is added already... */
-	dm_list_iterate_items(profile, &cmd->profile_params->profiles_to_load) {
-		if (!strcmp(profile->name, profile_name))
-			return profile;
-	}
-	dm_list_iterate_items(profile, &cmd->profile_params->profiles) {
-		if (!strcmp(profile->name, profile_name))
-			return profile;
+	/*
+	 * Check if the profile is on the list of profiles to be loaded or if
+	 * not found there, if it's on the list of already loaded profiles.
+	 */
+	if (!_get_profile_from_list(&cmd->profile_params->profiles_to_load,
+				    profile_name, source, &profile))
+		return_NULL;
+
+	if (profile)
+		profile->source = source;
+	else if (!_get_profile_from_list(&cmd->profile_params->profiles,
+					 profile_name, source, &profile))
+		return_NULL;
+
+	if (profile) {
+		if (profile->source != source) {
+			log_error(INTERNAL_ERROR "add_profile: loaded profile "
+				  "has incorrect type, expected %s but %s found",
+				   _config_source_names[source],
+				   _config_source_names[profile->source]);
+			return NULL;
+		}
+		return profile;
 	}
 
 	if (!(profile = dm_pool_zalloc(cmd->libmem, sizeof(*profile)))) {
@@ -1669,6 +1815,7 @@ struct profile *add_profile(struct cmd_context *cmd, const char *profile_name)
 		return NULL;
 	}
 
+	profile->source = source;
 	profile->name = dm_pool_strdup(cmd->libmem, profile_name);
 	dm_list_add(&cmd->profile_params->profiles_to_load, &profile->list);
 
@@ -1693,11 +1840,9 @@ int load_profile(struct cmd_context *cmd, struct profile *profile) {
 		return 0;
 	}
 
-	if (!(profile->cft = config_file_open_and_read(profile_path, CONFIG_PROFILE, cmd)))
+	if (!(profile->cft = config_file_open_and_read(profile_path, profile->source, cmd)))
 		return 0;
 
-	dm_list_move(&cmd->profile_params->profiles, &profile->list);
-
 	/*
 	 * *Profile must be valid* otherwise we'd end up with incorrect config!
 	 * If there were config items present that are not supposed to be
@@ -1708,25 +1853,28 @@ int load_profile(struct cmd_context *cmd, struct profile *profile) {
 	 * for profiles!
 	 */
 	if (!_check_profile(cmd, profile)) {
-		log_error("Ignoring invalid configuration profile %s.", profile->name);
-		/* if invalid, cut the whole tree and leave it empty */
-		dm_pool_free(profile->cft->mem, profile->cft->root);
-		profile->cft->root = NULL;
+		log_error("Ignoring invalid %s %s.",
+			  _config_source_names[profile->source], profile->name);
+		config_destroy(profile->cft);
+		profile->cft = NULL;
+		return 0;
 	}
 
+	dm_list_move(&cmd->profile_params->profiles, &profile->list);
 	return 1;
 }
 
 int load_pending_profiles(struct cmd_context *cmd)
 {
 	struct profile *profile, *temp_profile;
+	int r = 1;
 
 	dm_list_iterate_items_safe(profile, temp_profile, &cmd->profile_params->profiles_to_load) {
 		if (!load_profile(cmd, profile))
-			return 0;
+			r = 0;
 	}
 
-	return 1;
+	return r;
 }
 
 const char *get_default_devices_cache_dir_CFG(struct cmd_context *cmd, struct profile *profile)
diff --git a/lib/config/config.h b/lib/config/config.h
index f06fb68..0618045 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -30,21 +30,24 @@ typedef enum {
 	CONFIG_FILE,		/* one file config */
 	CONFIG_MERGED_FILES,	/* config that is a result of merging more config files */
 	CONFIG_STRING,		/* config string typed on cmdline using '--config' arg */
-	CONFIG_PROFILE,		/* profile config */
+	CONFIG_PROFILE_COMMAND,	/* command profile config */
+	CONFIG_PROFILE_METADATA,/* metadata profile config */
 	CONFIG_FILE_SPECIAL	/* special purpose file config (e.g. metadata, persistent filter...) */
 } config_source_t;
 
 struct profile {
 	struct dm_list list;
+	config_source_t source; /* either CONFIG_PROFILE_COMMAND or CONFIG_PROFILE_METADATA */
 	const char *name;
 	struct dm_config_tree *cft;
 };
 
 struct profile_params {
-	char dir[PATH_MAX];             /* subdir in LVM_SYSTEM_DIR where LVM looks for profiles */
-	struct profile *global_profile; /* profile that overrides any other VG/LV-based profile ('--profile' cmd line arg) */
-	struct dm_list profiles_to_load;/* list of profiles which are only added, but still need to be loaded for any use */
-	struct dm_list profiles;	/* list of profiles which are loaded already and which are ready for use */
+	char dir[PATH_MAX];                      /* subdir in LVM_SYSTEM_DIR where LVM looks for profiles */
+	struct profile *global_command_profile;  /* profile (as given by --commandprofile cmd arg) used as global command profile */
+	struct profile *global_metadata_profile; /* profile (as given by --metadataprofile cmd arg) that overrides any other VG/LV-based profile */
+	struct dm_list profiles_to_load;         /* list of profiles which are only added, but still need to be loaded for any use */
+	struct dm_list profiles;                 /* list of profiles which are loaded already and which are ready for use */
 };
 
 #define CFG_PATH_MAX_LEN 64
@@ -166,7 +169,7 @@ enum {
 #undef cfg_array_runtime
 };
 
-struct profile *add_profile(struct cmd_context *cmd, const char *profile_name);
+struct profile *add_profile(struct cmd_context *cmd, const char *profile_name, config_source_t source);
 int load_profile(struct cmd_context *cmd, struct profile *profile);
 int load_pending_profiles(struct cmd_context *cmd);
 
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 59603bb..7d4304e 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -576,7 +576,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	if (dm_config_get_str(lvn, "profile", &str)) {
 		log_debug_metadata("Adding profile configuration %s for LV %s/%s.",
 				   str, vg->name, lv->name);
-		lv->profile = add_profile(vg->cmd, str);
+		lv->profile = add_profile(vg->cmd, str, CONFIG_PROFILE_METADATA);
 		if (!lv->profile) {
 			log_error("Failed to add configuration profile %s for LV %s/%s",
 				  str, vg->name, lv->name);
@@ -814,7 +814,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	if (dm_config_get_str(vgn, "profile", &str)) {
 		log_debug_metadata("Adding profile configuration %s for VG %s.", str, vg->name);
-		vg->profile = add_profile(vg->cmd, str);
+		vg->profile = add_profile(vg->cmd, str, CONFIG_PROFILE_METADATA);
 		if (!vg->profile) {
 			log_error("Failed to add configuration profile %s for VG %s", str, vg->name);
 			goto bad;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0eaa719..91a15f2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4525,7 +4525,7 @@ struct logical_volume *lv_create_empty(const char *name,
 		goto_bad;
 
 	if (vg->fid->fmt->features & FMT_CONFIG_PROFILE)
-		lv->profile = vg->cmd->profile_params->global_profile;
+		lv->profile = vg->cmd->profile_params->global_metadata_profile;
  
 	return lv;
 bad:
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 5382b69..84b93db 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -417,7 +417,7 @@ void critical_section_inc(struct cmd_context *cmd, const char *reason)
 	 * entering the critical section all needed profiles are
 	 * loaded to avoid the disk access later.
 	 */
-	load_pending_profiles(cmd);
+	(void) load_pending_profiles(cmd);
 
 	if (!_critical_section) {
 		_critical_section = 1;
diff --git a/tools/args.h b/tools/args.h
index 2e63adb..6a594c3 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -99,6 +99,8 @@ arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", size_kb_arg, 0)
 arg(raidminrecoveryrate_ARG, '\0', "raidminrecoveryrate", size_kb_arg, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0)
 arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", size_kb_arg, 0)
+arg(commandprofile_ARG, '\0', "commandprofile", string_arg, 0)
+arg(metadataprofile_ARG, '\0', "metadataprofile", string_arg, 0)
 arg(profile_ARG, '\0', "profile", string_arg, 0)
 arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 5a69e44..6ed4f8d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -33,6 +33,7 @@ xx(devtypes,
    PERMITTED_READ_ONLY,
    "devtypes" "\n"
    "\t[--aligned]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--nameprefixes]\n"
@@ -56,6 +57,7 @@ xx(dumpconfig,
    "Dump configuration",
    PERMITTED_READ_ONLY,
    "dumpconfig\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-f|--file filename] \n"
    "\t[--type {current|default|diff|missing|new|profilable} \n"
    "\t[--atversion version]] \n"
@@ -99,6 +101,7 @@ xx(lvchange,
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous y|n]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[--deltag Tag]\n"
    "\t[--detachprofile]\n"
@@ -114,9 +117,9 @@ xx(lvchange,
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
+   "\t[--metadataprofile ProfileName]\n"
    "\t[-P|--partial] " "\n"
    "\t[-p|--permission r|rw]\n"
-   "\t[--profile ProfileName\n"
    "\t[--[raid]minrecoveryrate Rate]\n"
    "\t[--[raid]maxrecoveryrate Rate]\n"
    "\t[--[raid]syncaction {check|repair}\n"
@@ -136,9 +139,9 @@ xx(lvchange,
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
    contiguous_ARG, deltag_ARG, discards_ARG, detachprofile_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
-   ignoreskippedcluster_ARG,
-   major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG,
-   noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG, poll_ARG,
+   ignoreskippedcluster_ARG, major_ARG, metadataprofile_ARG, minor_ARG,
+   monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, noudevsync_ARG,
+   partial_ARG, permission_ARG, persistent_ARG, poll_ARG,
    raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG, raidsyncaction_ARG,
    raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG, resync_ARG,
    refresh_ARG, setactivationskip_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
@@ -155,6 +158,7 @@ xx(lvconvert,
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|-?|--help]\n"
@@ -169,10 +173,12 @@ xx(lvconvert,
    "lvconvert "
    "[--splitmirrors Images --trackchanges]\n"
    "[--splitmirrors Images --name SplitLogicalVolumeName]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\tLogicalVolume[Path] [SplittablePhysicalVolume[Path]...]\n\n"
 
    "lvconvert "
    "--splitsnapshot\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[--noudevsync]\n"
@@ -183,6 +189,7 @@ xx(lvconvert,
    "lvconvert "
    "[-s|--snapshot]\n"
    "\t[-c|--chunksize]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[--noudevsync]\n"
@@ -195,6 +202,7 @@ xx(lvconvert,
    "--merge\n"
    "\t[-b|--background]\n"
    "\t[-i|--interval seconds]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[-v|--verbose]\n"
@@ -212,6 +220,7 @@ xx(lvconvert,
    "\t[-T|--thin ExternalLogicalVolume[Path]\n"
    "\t [--originname NewExternalOriginVolumeName]]\n"
    "\t[-Z|--zero {y|n}]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n\n"
 
    "lvconvert "
@@ -221,11 +230,13 @@ xx(lvconvert,
    "\t[--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
    "\t [--poolmetadatasize size]\n"
    "\t [--poolmetadataspare {y|n}]]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\tCacheDataLogicalVolume[Path]\n\n"
 
    "lvconvert "
    "--type cache\n"
    "\t--cachepool CachePoolLogicalVolume[Path]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\tLogicalVolume[Path]\n\n",
 
    alloc_ARG, background_ARG, cachemode_ARG, cachepool_ARG, chunksize_ARG,
@@ -246,6 +257,7 @@ xx(lvcreate,
    "\t[--alloc AllocationPolicy]\n"
    "\t[--cachemode CacheMode]\n"
    "\t[-C|--contiguous {y|n}]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[--ignoremonitoring]\n"
@@ -256,6 +268,7 @@ xx(lvcreate,
    "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
+   "\t[--metadataprofile ProfileName]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
@@ -287,6 +300,7 @@ xx(lvcreate,
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous {y|n}]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[--discards {ignore|nopassdown|passdown}]\n"
    "\t[-h|-?|--help]\n"
@@ -299,6 +313,7 @@ xx(lvcreate,
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[--poolmetadatasize MetadataVolumeSize[bBsSkKmMgG]]\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
+   "\t[--metadataprofile ProfileName]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
@@ -313,14 +328,13 @@ xx(lvcreate,
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
    cachemode_ARG, chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG,
    extents_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
-   minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG, minrecoveryrate_ARG,
-   maxrecoveryrate_ARG, name_ARG, nosync_ARG, noudevsync_ARG,
-   permission_ARG, persistent_ARG, poolmetadatasize_ARG, poolmetadataspare_ARG,
-   raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG, readahead_ARG,
-   regionsize_ARG, setactivationskip_ARG, size_ARG, snapshot_ARG, stripes_ARG,
-   stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
-   type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
-   wipesignatures_ARG, zero_ARG)
+   metadataprofile_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG,
+   minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
+   noudevsync_ARG, permission_ARG, persistent_ARG, poolmetadatasize_ARG,
+   poolmetadataspare_ARG, raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
+   readahead_ARG, regionsize_ARG, setactivationskip_ARG, size_ARG, snapshot_ARG,
+   stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,
+   virtualoriginsize_ARG, virtualsize_ARG, wipesignatures_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
@@ -328,6 +342,7 @@ xx(lvdisplay,
    "lvdisplay\n"
    "\t[-a|--all]\n"
    "\t[-c|--colon]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -344,6 +359,7 @@ xx(lvdisplay,
    "lvdisplay --columns|-C\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -373,6 +389,7 @@ xx(lvextend,
    "lvextend\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--alloc AllocationPolicy]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
@@ -401,6 +418,7 @@ xx(lvmchange,
    "With the device mapper, this is obsolete and does nothing.",
    0,
    "lvmchange\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-R|--reset]\n"
@@ -413,6 +431,7 @@ xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
    PERMITTED_READ_ONLY,
    "lvmdiskscan\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-l|--lvmpartition]\n"
@@ -425,6 +444,7 @@ xx(lvmsadc,
    "Collect activity data",
    0,
    "lvmsadc\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-v|--verbose]\n"
@@ -435,6 +455,7 @@ xx(lvmsar,
    "Create activity report",
    0,
    "lvmsar\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--full]\n"
    "\t[-h|--help]\n"
@@ -450,6 +471,7 @@ xx(lvreduce,
    0,
    "lvreduce\n"
    "\t[-A|--autobackup y|n]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
@@ -472,6 +494,7 @@ xx(lvremove,
    0,
    "lvremove\n"
    "\t[-A|--autobackup y|n]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
@@ -488,6 +511,7 @@ xx(lvrename,
    0,
    "lvrename\n"
    "\t[-A|--autobackup {y|n}] " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|-?|--help] " "\n"
    "\t[--noudevsync]\n"
@@ -505,6 +529,7 @@ xx(lvresize,
    "lvresize\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--alloc AllocationPolicy]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
@@ -532,6 +557,7 @@ xx(lvs,
    "lvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -567,6 +593,7 @@ xx(lvscan,
    "lvscan " "\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice] " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|-?|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
@@ -584,6 +611,7 @@ xx(pvchange,
    "pvchange\n"
    "\t[-a|--all]\n"
    "\t[-A|--autobackup y|n]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
@@ -604,6 +632,7 @@ xx(pvresize,
    "Resize physical volume(s)",
    0,
    "pvresize " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
@@ -618,6 +647,7 @@ xx(pvck,
    "Check the consistency of physical volume(s)",
    0,
    "pvck "
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--labelsector sector] " "\n"
@@ -633,6 +663,7 @@ xx(pvcreate,
    "pvcreate " "\n"
    "\t[--norestorefile]\n"
    "\t[--restorefile file]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]" "\n"
    "\t[-f[f]|--force [--force]] " "\n"
    "\t[-h|-?|--help] " "\n"
@@ -663,6 +694,7 @@ xx(pvdata,
    0,
    "pvdata " "\n"
    "\t[-a|--all] " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-E|--physicalextent] " "\n"
    "\t[-h|-?|--help]" "\n"
@@ -682,6 +714,7 @@ xx(pvdisplay,
    CACHE_VGMETADATA | PERMITTED_READ_ONLY,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -698,6 +731,7 @@ xx(pvdisplay,
    "pvdisplay --columns|-C\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -727,6 +761,7 @@ xx(pvmove,
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n "
    "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
@@ -746,6 +781,7 @@ xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
    0,
    "pvremove " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]" "\n"
    "\t[-f[f]|--force [--force]] " "\n"
    "\t[-h|-?|--help] " "\n"
@@ -763,6 +799,7 @@ xx(pvs,
    "pvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
@@ -796,6 +833,7 @@ xx(pvscan,
    "pvscan " "\n"
    "\t[-b|--background]\n"
    "\t[--cache [-a|--activate ay] [ DevicePath | --major major --minor minor]...]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
    "\t[-h|-?|--help]" "\n"
@@ -825,6 +863,7 @@ xx(vgcfgbackup,
    "Backup volume group configuration(s)",
    PERMITTED_READ_ONLY,
    "vgcfgbackup " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-f|--file filename] " "\n"
    "\t[-h|-?|--help] " "\n"
@@ -841,6 +880,7 @@ xx(vgcfgrestore,
    "Restore volume group configuration",
    0,
    "vgcfgrestore " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-f|--file filename] " "\n"
    "\t[--force]\n"
@@ -861,6 +901,7 @@ xx(vgchange,
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
    "\t[-P|--partial] " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[--detachprofile] " "\n"
    "\t[-h|--help] " "\n"
@@ -868,6 +909,7 @@ xx(vgchange,
    "\t[--ignoremonitoring]\n"
    "\t[--ignoreskippedcluster]\n"
    "\t[-K|--ignoreactivationskip] \n"
+   "\t[--metadataprofile ProfileName]\n"
    "\t[--monitor {y|n}]\n"
    "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[--poll {y|n}]\n"
@@ -884,7 +926,6 @@ xx(vgchange,
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
    "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |" "\n"
    "\t -s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE] |" "\n"
-   "\t[--profile ProfileName\n"
    "\t --addtag Tag |\n"
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
@@ -892,16 +933,16 @@ xx(vgchange,
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, activate_ARG,
    available_ARG, clustered_ARG, deltag_ARG, detachprofile_ARG,
    ignoreactivationskip_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
-   ignoreskippedcluster_ARG,
-   logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
-   metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG,
-   physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
-   resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
+   ignoreskippedcluster_ARG, logicalvolume_ARG, maxphysicalvolumes_ARG,
+   metadataprofile_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
+   vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
+   refresh_ARG, resizeable_ARG, resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
    0,
    "vgck "
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-v|--verbose]\n"
@@ -912,6 +953,7 @@ xx(vgconvert,
    "Change volume group metadata format",
    0,
    "vgconvert  " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|--help] " "\n"
    "\t[--labelsector sector] " "\n"
@@ -936,9 +978,11 @@ xx(vgcreate,
    "\t[--addtag Tag] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
    "\t[-c|--clustered {y|n}] " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|--help]" "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
+   "\t[--metadataprofile ProfileName]\n"
    "\t[-M|--metadatatype 1|2] " "\n"
    "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
@@ -951,10 +995,10 @@ xx(vgcreate,
    "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
-   maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
-   force_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
-   pvmetadatacopies_ARG, metadatacopies_ARG, vgmetadatacopies_ARG,
-   dataalignment_ARG, dataalignmentoffset_ARG)
+   maxphysicalvolumes_ARG, metadataprofile_ARG, metadatatype_ARG,
+   physicalextentsize_ARG, test_ARG, force_ARG, zero_ARG, labelsector_ARG,
+   metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
+   vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
@@ -962,6 +1006,7 @@ xx(vgdisplay,
    "vgdisplay " "\n"
    "\t[-A|--activevolumegroups]" "\n"
    "\t[-c|--colon | -s|--short | -v|--verbose]" "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]" "\n"
@@ -975,6 +1020,7 @@ xx(vgdisplay,
    "\n"
    "vgdisplay --columns|-C\n"
    "\t[--aligned]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]" "\n"
@@ -1002,6 +1048,7 @@ xx(vgexport,
    0,
    "vgexport " "\n"
    "\t[-a|--all] " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|--help]" "\n"
    "\t[-v|--verbose] " "\n"
@@ -1016,6 +1063,7 @@ xx(vgextend,
    "vgextend\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--restoremissing]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
@@ -1037,6 +1085,7 @@ xx(vgimport,
    0,
    "vgimport " "\n"
    "\t[-a|--all]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-f|--force] " "\n"
    "\t[-h|--help] " "\n"
@@ -1052,6 +1101,7 @@ xx(vgmerge,
    0,
    "vgmerge\n"
    "\t[-A|--autobackup y|n]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-l|--list]\n"
@@ -1066,6 +1116,7 @@ xx(vgmknodes,
    "Create the special files for volume group devices in /dev",
    0,
    "vgmknodes\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -1082,6 +1133,7 @@ xx(vgreduce,
    "vgreduce\n"
    "\t[-a|--all]\n"
    "\t[-A|--autobackup y|n]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--mirrorsonly]\n"
@@ -1100,6 +1152,7 @@ xx(vgremove,
    "Remove volume group(s)",
    0,
    "vgremove\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
@@ -1116,6 +1169,7 @@ xx(vgrename,
    0,
    "vgrename\n"
    "\t[-A|--autobackup y|n]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-t|--test]\n"
@@ -1132,6 +1186,7 @@ xx(vgs,
    "vgs" "\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -1165,6 +1220,7 @@ xx(vgscan,
    PERMITTED_READ_ONLY,
    "vgscan "
    "\t[--cache]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -1182,6 +1238,7 @@ xx(vgsplit,
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
    "\t[-c|--clustered {y|n}] " "\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
diff --git a/tools/lvchange.c b/tools/lvchange.c
index bddc079..48e48d4 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -898,8 +898,11 @@ static int lvchange_profile(struct logical_volume *lv)
 		new_profile_name = "(inherited)";
 		lv->profile = NULL;
 	} else {
-		new_profile_name = arg_str_value(lv->vg->cmd, profile_ARG, NULL);
-		if (!(new_profile = add_profile(lv->vg->cmd, new_profile_name)))
+		if (arg_count(lv->vg->cmd, metadataprofile_ARG))
+			new_profile_name = arg_str_value(lv->vg->cmd, metadataprofile_ARG, NULL);
+		else
+			new_profile_name = arg_str_value(lv->vg->cmd, profile_ARG, NULL);
+		if (!(new_profile = add_profile(lv->vg->cmd, new_profile_name, CONFIG_PROFILE_METADATA)))
 			return_0;
 		lv->profile = new_profile;
 	}
@@ -944,7 +947,8 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 	     arg_count(cmd, discards_ARG) || arg_count(cmd, zero_ARG) ||
-	     arg_count(cmd, alloc_ARG) || arg_count(cmd, profile_ARG))) {
+	     arg_count(cmd, alloc_ARG) || arg_count(cmd, profile_ARG) ||
+	     arg_count(cmd, metadataprofile_ARG))) {
 		log_error("Only -a permitted with read-only volume "
 			  "group \"%s\"", lv->vg->name);
 		return EINVALID_CMD_LINE;
@@ -958,7 +962,8 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lv_is_origin(lv) && !lv_is_thin_volume(lv) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
-	     arg_count(cmd, alloc_ARG) || arg_count(cmd, profile_ARG))) {
+	     arg_count(cmd, alloc_ARG) || arg_count(cmd, profile_ARG) ||
+	     arg_count(cmd, metadataprofile_ARG))) {
 		log_error("Can't change logical volume \"%s\" under snapshot",
 			  lv->name);
 		return ECMD_FAILED;
@@ -1108,7 +1113,8 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* change configuration profile */
-	if (arg_count(cmd, profile_ARG) || arg_count(cmd, detachprofile_ARG)) {
+	if (arg_count(cmd, profile_ARG) || arg_count(cmd, metadataprofile_ARG) ||
+	    arg_count(cmd, detachprofile_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 		doit += lvchange_profile(lv);
@@ -1170,6 +1176,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) ||
 		arg_count(cmd, deltag_ARG) ||
+		arg_count(cmd, metadataprofile_ARG) ||
 		arg_count(cmd, profile_ARG) ||
 		arg_count(cmd, detachprofile_ARG) ||
 		arg_count(cmd, setactivationskip_ARG);
@@ -1194,8 +1201,9 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, profile_ARG) && arg_count(cmd, detachprofile_ARG)) {
-		log_error("Only one of --profile and --detachprofile permitted.");
+	if ((arg_count(cmd, profile_ARG) || arg_count(cmd, metadataprofile_ARG)) &&
+	     arg_count(cmd, detachprofile_ARG)) {
+		log_error("Only one of --metadataprofile and --detachprofile permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 69e5781..96e478f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -622,6 +622,7 @@ void lvm_register_commands(void)
 					    version_ARG, verbose_ARG, \
 					    yes_ARG, \
 					    quiet_ARG, config_ARG, \
+					    commandprofile_ARG, \
 					    profile_ARG, -1);
 #include "commands.h"
 #undef xx
@@ -1079,10 +1080,122 @@ static const char *_copy_command_line(struct cmd_context *cmd, int argc, char **
 	return NULL;
 }
 
-int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
+static int _prepare_profiles(struct cmd_context *cmd)
 {
-	struct dm_config_tree *config_string_cft, *config_profile_cft;
+	static const char _failed_to_add_profile_msg[] = "Failed to add %s %s.";
+	static const char _failed_to_apply_profile_msg[] = "Failed to apply %s %s.";
+	static const char _command_profile_source_name[] = "command profile";
+	static const char _metadata_profile_source_name[] = "metadata profile";
+	static const char _setting_global_profile_msg[] = "Setting global %s \"%s\".";
+
+	const char *name;
 	struct profile *profile;
+	config_source_t source;
+	const char *source_name;
+
+	if (arg_count(cmd, profile_ARG)) {
+		/*
+		 * If --profile is used with dumpconfig, it's used
+		 * to dump the profile without the profile being applied.
+		 */
+		if (!strcmp(cmd->command->name, "dumpconfig"))
+			return 1;
+
+		/*
+		 * If --profile is used with lvcreate/lvchange/vgchange,
+		 * it's recognized as shortcut to --metadataprofile.
+		 * The --commandprofile is assumed otherwise.
+		 */
+		if (!strcmp(cmd->command->name, "lvcreate") ||
+		    !strcmp(cmd->command->name, "vgcreate") ||
+		    !strcmp(cmd->command->name, "lvchange") ||
+		    !strcmp(cmd->command->name, "vgchange")) {
+			if (arg_count(cmd, metadataprofile_ARG)) {
+				log_error("Only one of --profile or "
+					  " --metadataprofile allowed.");
+				return 0;
+			}
+			source = CONFIG_PROFILE_METADATA;
+			source_name = _metadata_profile_source_name;
+		}
+		else {
+			if (arg_count(cmd, commandprofile_ARG)) {
+				log_error("Only one of --profile or "
+					  "--commandprofile allowed.");
+				return 0;
+			}
+			source = CONFIG_PROFILE_COMMAND;
+			source_name = _command_profile_source_name;
+		}
+
+		name = arg_str_value(cmd, profile_ARG, NULL);
+
+		if (!(profile = add_profile(cmd, name, source))) {
+			log_error(_failed_to_add_profile_msg, source_name, name);
+			return 0;
+		}
+
+		if (source == CONFIG_PROFILE_COMMAND) {
+			log_debug(_setting_global_profile_msg, _command_profile_source_name, profile->name);
+			cmd->profile_params->global_command_profile = profile;
+		} else if (source == CONFIG_PROFILE_METADATA) {
+			log_debug(_setting_global_profile_msg, _metadata_profile_source_name, profile->name);
+			/* This profile will override any VG/LV-based profile if present */
+			cmd->profile_params->global_metadata_profile = profile;
+		}
+
+		if (!override_config_tree_from_profile(cmd, profile)) {
+			log_error(_failed_to_apply_profile_msg, source_name, name);
+			return 0;
+		}
+
+	}
+
+	if (arg_count(cmd, commandprofile_ARG)) {
+		name = arg_str_value(cmd, commandprofile_ARG, NULL);
+		source_name = _command_profile_source_name;
+
+		if (!(profile = add_profile(cmd, name, CONFIG_PROFILE_COMMAND))) {
+			log_error(_failed_to_add_profile_msg, source_name, name);
+			return 0;
+		}
+		if (!override_config_tree_from_profile(cmd, profile)) {
+			log_error(_failed_to_apply_profile_msg, source_name, name);
+			return 0;
+		}
+
+		log_debug(_setting_global_profile_msg, _command_profile_source_name, profile->name);
+		cmd->profile_params->global_command_profile = profile;
+	}
+
+
+	if (arg_count(cmd, metadataprofile_ARG)) {
+		name = arg_str_value(cmd, metadataprofile_ARG, NULL);
+		source_name = _metadata_profile_source_name;
+
+		if (!(profile = add_profile(cmd, name, CONFIG_PROFILE_METADATA))) {
+			log_error(_failed_to_add_profile_msg, source_name, name);
+			return 0;
+		}
+		if (!override_config_tree_from_profile(cmd, profile)) {
+			log_error(_failed_to_apply_profile_msg, source_name, name);
+			return 0;
+		}
+
+		log_debug(_setting_global_profile_msg, _metadata_profile_source_name, profile->name);
+		cmd->profile_params->global_metadata_profile = profile;
+	}
+
+	if (!process_profilable_config(cmd))
+		return_0;
+
+	return 1;
+}
+
+int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct dm_config_tree *config_string_cft;
+	struct dm_config_tree *config_profile_command_cft, *config_profile_metadata_cft;
 	int ret = 0;
 	int locking_type;
 	int monitoring;
@@ -1131,19 +1244,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if (arg_count(cmd, profile_ARG)) {
-		if (!(profile = add_profile(cmd, arg_str_value(cmd, profile_ARG, NULL)))) {
-			log_error("Failed to add configuration profile.");
-			return ECMD_FAILED;
-		}
-		log_debug("Setting global configuration profile \"%s\".", profile->name);
-		/* This profile will override any VG/LV-based profile if present */
-		cmd->profile_params->global_profile = profile;
-		if (!override_config_tree_from_profile(cmd, profile)) {
-			log_error("Failed to apply configuration profile.");
-			return ECMD_FAILED;
-		}
-		if (!process_profilable_config(cmd))
+	if (arg_count(cmd, profile_ARG) ||
+	    arg_count(cmd, commandprofile_ARG) ||
+	    arg_count(cmd, metadataprofile_ARG)) {
+		if (!_prepare_profiles(cmd))
 			return_ECMD_FAILED;
 	}
 
@@ -1206,10 +1310,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if ((config_string_cft = remove_config_tree_by_source(cmd, CONFIG_STRING)))
 		dm_config_destroy(config_string_cft);
 
-	config_profile_cft = remove_config_tree_by_source(cmd, CONFIG_PROFILE);
-	cmd->profile_params->global_profile = NULL;
+	config_profile_command_cft = remove_config_tree_by_source(cmd, CONFIG_PROFILE_COMMAND);
+	config_profile_metadata_cft = remove_config_tree_by_source(cmd, CONFIG_PROFILE_METADATA);
+	cmd->profile_params->global_metadata_profile = NULL;
 
-	if (config_string_cft || config_profile_cft) {
+	if (config_string_cft || config_profile_command_cft || config_profile_metadata_cft) {
 		/* Move this? */
 		if (!refresh_toolcontext(cmd))
 			stack;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index d24b17e..05e7aea 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -441,8 +441,11 @@ static int _vgchange_profile(struct cmd_context *cmd,
 		new_profile_name = "(no profile)";
 		vg->profile = NULL;
 	} else {
-		new_profile_name = arg_str_value(cmd, profile_ARG, NULL);
-		if (!(new_profile = add_profile(cmd, new_profile_name)))
+		if (arg_count(cmd, metadataprofile_ARG))
+			new_profile_name = arg_str_value(cmd, metadataprofile_ARG, NULL);
+		else
+			new_profile_name = arg_str_value(cmd, profile_ARG, NULL);
+		if (!(new_profile = add_profile(cmd, new_profile_name, CONFIG_PROFILE_METADATA)))
 			return_0;
 		vg->profile = new_profile;
 	}
@@ -473,6 +476,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ alloc_ARG, &_vgchange_alloc },
 		{ clustered_ARG, &_vgchange_clustered },
 		{ vgmetadatacopies_ARG, &_vgchange_metadata_copies },
+		{ metadataprofile_ARG, &_vgchange_profile },
 		{ profile_ARG, &_vgchange_profile},
 		{ detachprofile_ARG, &_vgchange_profile},
 	};
@@ -547,6 +551,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	int update_partial_safe =
 		arg_count(cmd, deltag_ARG) ||
 		arg_count(cmd, addtag_ARG) ||
+		arg_count(cmd, metadataprofile_ARG) ||
 		arg_count(cmd, profile_ARG) ||
 		arg_count(cmd, detachprofile_ARG);
 	int update_partial_unsafe =
@@ -572,8 +577,9 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, profile_ARG) && arg_count(cmd, detachprofile_ARG)) {
-		log_error("Only one of --profile and --detachprofile permitted.");
+	if ((arg_count(cmd, profile_ARG) || arg_count(cmd, metadataprofile_ARG)) &&
+	     arg_count(cmd, detachprofile_ARG)) {
+		log_error("Only one of --metadataprofile and --detachprofile permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 45f4c04..9d701c8 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -63,7 +63,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (vg->fid->fmt->features & FMT_CONFIG_PROFILE)
-		vg->profile = vg->cmd->profile_params->global_profile;
+		vg->profile = vg->cmd->profile_params->global_metadata_profile;
 
 	if (!vg_set_extent_size(vg, vp_new.extent_size) ||
 	    !vg_set_max_lv(vg, vp_new.max_lv) ||


