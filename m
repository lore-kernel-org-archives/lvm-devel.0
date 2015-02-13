From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 13 Feb 2015 16:14:18 +0000 (UTC)
Subject: master - system_id: use for VG ownership
Message-ID: <20150213161418.6D65460F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8cdec4c434a8b043a2a0a44252bfd11f40b0a8ec
Commit:        8cdec4c434a8b043a2a0a44252bfd11f40b0a8ec
Parent:        f5d06efbab4c7c77298b18b95c23111575a8db1a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 24 12:29:04 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 13 10:10:27 2015 -0600

system_id: use for VG ownership

See included lvmsystemid(7) for full description.
---
 conf/example.conf.in             |   13 ++
 conf/lvmlocal.conf.in            |   33 +++++
 lib/commands/toolcontext.c       |  136 ++++++++++++++++++-
 lib/commands/toolcontext.h       |    6 +
 lib/config/config_settings.h     |    7 +
 lib/config/defaults.h            |    1 +
 lib/format1/import-export.c      |    8 +
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.c          |  124 ++++++++++++++++-
 lib/metadata/vg.c                |   16 ++
 lib/metadata/vg.h                |    1 +
 lib/misc/lvm-string.c            |   35 +++++
 lib/misc/lvm-string.h            |    2 +
 lib/report/columns.h             |    3 +-
 lib/report/properties.c          |    2 +
 man/Makefile.in                  |    2 +-
 man/lvmsystemid.7.in             |  284 ++++++++++++++++++++++++++++++++++++++
 tools/args.h                     |    2 +
 tools/commands.h                 |    7 +-
 tools/reporter.c                 |   27 ++--
 tools/toollib.c                  |   54 +++++++-
 tools/toollib.h                  |    2 -
 tools/vgchange.c                 |   65 +++++++--
 tools/vgcreate.c                 |    1 +
 tools/vgexport.c                 |    1 +
 tools/vgimport.c                 |   12 ++
 26 files changed, 795 insertions(+), 51 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index f7b9da0..5ee0c4d 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -834,6 +834,19 @@ global {
     # See cache_check_executable how to obtain binaries.
     #
     # cache_dump_executable = "@CACHE_DUMP_CMD@"
+
+    # Defines the method lvm will use to find the local system_id.
+    # The options are: none, machineid, uname, lvmlocal, or file.
+    # Unset, or set to an empty string is equivalent to "none".
+    # See lvmsystemid(7) for more information.
+    #
+    # system_id_source = ""
+
+    # Specifies the path to a file containing the local system_id.
+    # It is only used when system_id_source = "file".
+    # See lvmsystemid(7) for more information.
+    #
+    # system_id_file = ""
 }
 
 activation {
diff --git a/conf/lvmlocal.conf.in b/conf/lvmlocal.conf.in
new file mode 100644
index 0000000..b95ab37
--- /dev/null
+++ b/conf/lvmlocal.conf.in
@@ -0,0 +1,33 @@
+# This is an example local configuration file for the LVM2 system.
+# It contains the default settings that would be used if there was no
+# @DEFAULT_SYS_DIR@/lvmlocal.conf file.
+#
+# Refer to 'man lvm.conf' for further information including the file layout.
+#
+# To put this file in a different directory and override @DEFAULT_SYS_DIR@ set
+# the environment variable LVM_SYSTEM_DIR before running the tools.
+#
+# N.B. Take care that each setting only appears once if uncommenting
+# example settings in this file.
+#
+# The lvmlocal.conf file should contain only the "local { }" section
+# which contains settings that should not be shared or repeated among
+# different hosts.
+#
+# This file should not be copied among hosts.
+
+local {
+    # This defines the system_id of the local host.  It is
+    # only used if lvm.conf system_id_source = "lvmlocal".
+    # When used, it should be set to a unique value.
+    # See lvmsystemid(7) for more information.
+    #
+    # system_id = ""
+
+    # This defines system_id's other than the local system_id
+    # that the local host is allowed to access.
+    # See lvmsystemid(7) for more information.
+    #
+    # allow_system_id = []
+}
+
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 7f92ef6..8cbe88f 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -55,6 +55,89 @@
 
 static const size_t linebuffer_size = 4096;
 
+
+/* Copy the input string, removing invalid characters. */
+
+char *system_id_from_string(struct cmd_context *cmd, const char *str)
+{
+	char *system_id;
+
+	if (!(system_id = dm_pool_zalloc(cmd->mem, strlen(str) + 1)))
+		return NULL;
+
+	copy_valid_chars(str, system_id);
+
+	if (!system_id[0])
+		return NULL;
+
+	return system_id;
+}
+
+static char *_read_system_id_from_file(struct cmd_context *cmd, const char *file)
+{
+	char line[NAME_LEN + 1];
+	FILE *fp;
+
+	if (!file || !strlen(file) || !file[0])
+		return NULL;
+
+	fp = fopen(file, "r");
+	if (!fp)
+		return NULL;
+
+	memset(line, 0, sizeof(line));
+
+	while (fgets(line, NAME_LEN, fp)) {
+		if (line[0] == '#' || line[0] == '\n')
+			continue;
+
+		fclose(fp);
+		return system_id_from_string(cmd, line);
+	}
+
+	fclose(fp);
+	return NULL;
+}
+
+char *system_id_from_source(struct cmd_context *cmd, const char *source)
+{
+	struct utsname uts;
+	char filebuf[PATH_MAX];
+	const char *file;
+	const char *etc_str;
+	const char *str;
+	char *system_id = NULL;
+
+	if (!strcmp(source, "uname")) {
+		if (!uname(&uts) && strncmp(uts.nodename, "localhost", 9))
+			system_id = system_id_from_string(cmd, uts.nodename);
+		goto out;
+	}
+
+	/* lvm.conf and lvmlocal.conf are merged into one config tree */
+	if (!strcmp(source, "lvmlocal")) {
+		if ((str = find_config_tree_str(cmd, local_system_id_CFG, NULL)))
+			system_id = system_id_from_string(cmd, str);
+		goto out;
+	}
+
+	if (!strcmp(source, "machineid")) {
+		memset(filebuf, 0, sizeof(filebuf));
+		etc_str = find_config_tree_str(cmd, global_etc_CFG, NULL);
+		if (dm_snprintf(filebuf, sizeof(filebuf), "%s/machine-id", etc_str) >= 0)
+			system_id = _read_system_id_from_file(cmd, filebuf);
+		goto out;
+	}
+
+	if (!strcmp(source, "file")) {
+		file = find_config_tree_str(cmd, global_system_id_file_CFG, NULL);
+		system_id = _read_system_id_from_file(cmd, file);
+		goto out;
+	}
+out:
+	return system_id;
+}
+
 static int _get_env_vars(struct cmd_context *cmd)
 {
 	const char *e;
@@ -572,7 +655,7 @@ static int _init_tags(struct cmd_context *cmd, struct dm_config_tree *cft)
 	return 1;
 }
 
-static int _load_config_file(struct cmd_context *cmd, const char *tag)
+static int _load_config_file(struct cmd_context *cmd, const char *tag, int local)
 {
 	static char config_file[PATH_MAX] = "";
 	const char *filler = "";
@@ -580,6 +663,10 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 
 	if (*tag)
 		filler = "_";
+	else if (local) {
+		filler = "";
+		tag = "local";
+	}
 
 	if (dm_snprintf(config_file, sizeof(config_file), "%s/lvm%s%s.conf",
 			 cmd->system_dir, filler, tag) < 0) {
@@ -607,7 +694,10 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 	return 1;
 }
 
-/* Find and read first config file */
+/*
+ * Find and read lvm.conf and lvmlocal.conf.
+ */
+
 static int _init_lvm_conf(struct cmd_context *cmd)
 {
 	/* No config file if LVM_SYSTEM_DIR is empty */
@@ -619,9 +709,11 @@ static int _init_lvm_conf(struct cmd_context *cmd)
 		return 1;
 	}
 
-	if (!_load_config_file(cmd, ""))
+	if (!_load_config_file(cmd, "", 0))
 		return_0;
 
+	_load_config_file(cmd, "", 1);
+
 	return 1;
 }
 
@@ -632,7 +724,7 @@ static int _init_tag_configs(struct cmd_context *cmd)
 
 	/* Tag list may grow while inside this loop */
 	dm_list_iterate_items(sl, &cmd->tags) {
-		if (!_load_config_file(cmd, sl->str))
+		if (!_load_config_file(cmd, sl->str, 0))
 			return_0;
 	}
 
@@ -1352,6 +1444,39 @@ static int _init_hostname(struct cmd_context *cmd)
 	return 1;
 }
 
+static int _init_system_id(struct cmd_context *cmd)
+{
+	const char *source;
+	int local_set;
+
+	cmd->system_id = NULL;
+
+	local_set = !!find_config_tree_str(cmd, local_system_id_CFG, NULL);
+
+	source = find_config_tree_str(cmd, global_system_id_source_CFG, NULL);
+	if (!source)
+		source = "none";
+
+	/* Defining local system_id but not using it is probably a config mistake. */
+	if (local_set && strcmp(source, "lvmlocal"))
+		log_warn("Local system_id is not used by system_id_source %s.", source);
+
+	if (!strcmp(source, "none"))
+		return 1;
+
+	if ((cmd->system_id = system_id_from_source(cmd, source)))
+		return 1;
+
+	/*
+	 * The source failed to resolve a system_id.  In this case allow
+	 * VGs with no system_id to be accessed, but not VGs with a system_id.
+	 */
+
+	log_warn("No system_id found from system_id_source %s.", source);
+	cmd->unknown_system_id = 1;
+	return 1;
+}
+
 static int _init_backup(struct cmd_context *cmd)
 {
 	uint32_t days, min;
@@ -1580,6 +1705,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (!_init_profiles(cmd))
 		goto_out;
 
+	if (!_init_system_id(cmd))
+		goto_out;
+
 	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
 						find_config_tree_node(cmd, devices_types_CFG, NULL))))
 		goto_out;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index d99cc28..a3aaf7c 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -71,6 +71,7 @@ struct cmd_context {
 
 	struct dm_list formats;	/* Available formats */
 	struct dm_list segtypes;	/* Available segment types */
+	const char *system_id;
 	const char *hostname;
 	const char *kernel_vsn;
 
@@ -95,6 +96,8 @@ struct cmd_context {
 	unsigned threaded:1;		/* Set if running within a thread e.g. clvmd */
 
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
+	unsigned unknown_system_id:1;
+	unsigned include_foreign_vgs:1;
 
 	struct dev_types *dev_types;
 
@@ -160,4 +163,7 @@ int init_lvmcache_orphans(struct cmd_context *cmd);
 
 struct format_type *get_format_by_name(struct cmd_context *cmd, const char *format);
 
+char *system_id_from_source(struct cmd_context *cmd, const char *system_id_source);
+char *system_id_from_string(struct cmd_context *cmd, const char *system_id_string);
+
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index a34d32a..7360420 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -82,6 +82,7 @@ cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, CFG_ADVANCED, vs
 cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_ADVANCED | CFG_PROFILABLE, vsn(1, 0, 0), NULL)
 cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3), NULL)
 cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18), NULL)
+cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117), NULL)
 
 cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), "Configuration tree check on each LVM command execution.")
 cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), "Abort LVM command execution if configuration is invalid.")
@@ -164,6 +165,7 @@ cfg(global_format_CFG, "format", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT
 cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
 cfg(global_proc_CFG, "proc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL)
+cfg(global_etc_CFG, "etc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ETC_DIR, vsn(2, 2, 117), NULL)
 cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, 0, CFG_TYPE_INT, 1, vsn(1, 0, 0), NULL)
 cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_WAIT_FOR_LOCKS, vsn(2, 2, 50), NULL)
 cfg(global_fallback_to_clustered_locking_CFG, "fallback_to_clustered_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING, vsn(2, 2, 42), NULL)
@@ -191,6 +193,8 @@ cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECT
 cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), NULL)
 cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), NULL)
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL)
+cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
 
 cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL)
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL)
@@ -277,4 +281,7 @@ cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_H
 cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18), NULL)
 cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
 
+cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg_array(local_allow_system_id_CFG, "allow_system_id", local_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+
 cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 9d2cff9..77604ab 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -29,6 +29,7 @@
 
 #define DEFAULT_DEV_DIR "/dev"
 #define DEFAULT_PROC_DIR "/proc"
+#define DEFAULT_ETC_DIR "/etc"
 #define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
 #define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
 #define DEFAULT_SYSFS_SCAN 1
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 8aa4d33..9318945 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -125,6 +125,7 @@ int import_pv(const struct format_type *fmt, struct dm_pool *mem,
 	return 1;
 }
 
+#if 0
 static int _system_id(struct cmd_context *cmd, char *s, const char *prefix)
 {
 
@@ -136,6 +137,7 @@ static int _system_id(struct cmd_context *cmd, char *s, const char *prefix)
 
 	return 1;
 }
+#endif
 
 int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused)),
 	      struct volume_group *vg,
@@ -156,11 +158,14 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 	}
 
 	/* Preserve existing system_id if it exists */
+#if 0
 	if (vg && *vg->system_id)
 		strncpy((char *)pvd->system_id, vg->system_id, sizeof(pvd->system_id));
+#endif
 
 	/* Is VG already exported or being exported? */
 	if (vg && vg_is_exported(vg)) {
+#if 0
 		/* Does system_id need setting? */
 		if (!*vg->system_id ||
 		    strncmp(vg->system_id, EXPORTED_TAG,
@@ -168,6 +173,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 			if (!_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG))
 				return_0;
 		}
+#endif
 		if (strlen((char *)pvd->vg_name) + sizeof(EXPORTED_TAG) >
 		    sizeof(pvd->vg_name)) {
 			log_error("Volume group name %s too long to export",
@@ -177,6 +183,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 		strcat((char *)pvd->vg_name, EXPORTED_TAG);
 	}
 
+#if 0
 	/* Is VG being imported? */
 	if (vg && !vg_is_exported(vg) && *vg->system_id &&
 	    !strncmp(vg->system_id, EXPORTED_TAG, sizeof(EXPORTED_TAG) - 1)) {
@@ -194,6 +201,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 	    (!*vg->system_id ||
 	     strncmp(vg->system_id, (char *)pvd->system_id, sizeof(pvd->system_id))))
 		    strncpy(vg->system_id, (char *)pvd->system_id, NAME_LEN);
+#endif
 
 	//pvd->pv_major = MAJOR(pv->dev);
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0ab97fa..6631b1f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -166,6 +166,7 @@
 #define FAILED_ALLOCATION	0x00000080U
 #define FAILED_EXIST		0x00000100U
 #define FAILED_RECOVERY		0x00000200U
+#define FAILED_SYSTEMID		0x00000400U
 #define SUCCESS			0x00000000U
 
 #define VGMETADATACOPIES_ALL UINT32_MAX
@@ -1177,6 +1178,7 @@ struct vgcreate_params {
 	alloc_policy_t alloc;
 	int clustered; /* FIXME: put this into a 'status' variable instead? */
 	uint32_t vgmetadatacopies;
+	const char *system_id;
 };
 
 int validate_major_minor(const struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 465eb84..138fdaf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4285,6 +4285,122 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 	return (struct volume_group *)vg;
 }
 
+static int allow_system_id(struct cmd_context *cmd, const char *system_id)
+{
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	const char *str;
+
+	if (!(cn = find_config_tree_node(cmd, local_allow_system_id_CFG, NULL)))
+		return 0;
+
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type == DM_CFG_EMPTY_ARRAY)
+			break;
+		if (cv->type != DM_CFG_STRING) {
+			log_error("Ignoring invalid string in allow_system_id list");
+			continue;
+		}
+		str = cv->v.str;
+		if (!*str) {
+			log_error("Ignoring empty string in config file");
+			continue;
+		}
+
+		if (!strcmp(str, system_id))
+			return 1;
+	}
+
+	return 0;
+}
+
+static int _access_vg_clustered(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (vg_is_clustered(vg) && !locking_is_clustered()) {
+		if (!cmd->ignore_clustered_vgs)
+			log_error("Skipping clustered volume group %s", vg->name);
+		else
+			log_verbose("Skipping clustered volume group %s", vg->name);
+		return 0;
+	}
+	return 1;
+}
+
+static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
+{
+	/*
+	 * A VG without a system_id can be accessed by anyone.
+	 */
+	if (!vg->system_id || !vg->system_id[0])
+		return 1;
+
+	/*
+	 * We sometimes want to report foreign vgs.
+	 */
+	if (cmd->include_foreign_vgs)
+		return 1;
+
+	/*
+	 * Allow VG access if the local host has active LVs in it.
+	 */
+	if (lvs_in_vg_activated(vg)) {
+		log_error("LVs should not be active in VG %s with foreign system id \"%s\"",
+			  vg->name, vg->system_id);
+		return 1;
+	}
+
+	/*
+	 * A host without a system_id cannot access a VG with a system_id.
+	 */
+	if (!cmd->system_id || cmd->unknown_system_id) {
+		log_warn("Cannot access VG %s with system id \"%s\" with unknown local system id.",
+			 vg->name, vg->system_id);
+		return 0;
+	}
+
+	/*
+	 * A host can access a VG with a matching system_id.
+	 */
+	if (!strcmp(vg->system_id, cmd->system_id))
+		return 1;
+
+	/*
+	 * A host can access a VG if the VG's system_id is in the allow list.
+	 */
+	if (allow_system_id(cmd, vg->system_id))
+		return 1;
+
+	/*
+	 * Silently ignore foreign VGs.  They will only cause the
+	 * command to fail if they were named as explicit command
+	 * args, in which case the command will fail indicating the
+	 * VG was not found.
+	 */
+
+	return 0;
+}
+
+/*
+ * FIXME: move _vg_bad_status_bits() checks in here.
+ */
+static int _access_vg(struct cmd_context *cmd, struct volume_group *vg, uint32_t *failure)
+{
+	if (!is_real_vg(vg->name))
+		return 1;
+
+	if (!_access_vg_clustered(cmd, vg)) {
+		*failure |= FAILED_CLUSTERED;
+		return 0;
+	}
+
+	if (!_access_vg_systemid(cmd, vg)) {
+		*failure |= FAILED_SYSTEMID;
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Consolidated locking, reading, and status flag checking.
  *
@@ -4344,14 +4460,8 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		goto bad;
 	}
 
-	if (vg_is_clustered(vg) && !locking_is_clustered()) {
-		if (!cmd->ignore_clustered_vgs)
-			log_error("Skipping clustered volume group %s", vg->name);
-		else
-			log_verbose("Skipping clustered volume group %s", vg->name);
-		failure |= FAILED_CLUSTERED;
+	if (!_access_vg(cmd, vg, &failure))
 		goto bad;
-	}
 
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure) {
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index fee3767..dbc791b 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -601,6 +601,22 @@ int vg_set_clustered(struct volume_group *vg, int clustered)
 	return 1;
 }
 
+/* The input string has already been validated. */
+
+int vg_set_system_id(struct volume_group *vg, const char *system_id)
+{
+	if (!system_id) {
+		vg->system_id = NULL;
+		return 1;
+	}
+
+	if (!(vg->system_id = dm_pool_strdup(vg->vgmem, system_id))) {
+		log_error("vg_set_system_id no mem");
+		return 0;
+	}
+	return 1;
+}
+
 char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg)
 {
 	char *repstr;
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index fffe9a7..23d60ac 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -144,6 +144,7 @@ uint32_t vg_seqno(const struct volume_group *vg);
 uint64_t vg_status(const struct volume_group *vg);
 int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);
 int vg_set_clustered(struct volume_group *vg, int clustered);
+int vg_set_system_id(struct volume_group *vg, const char *system_id);
 uint64_t vg_size(const struct volume_group *vg);
 uint64_t vg_free(const struct volume_group *vg);
 uint64_t vg_extent_size(const struct volume_group *vg);
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 4ed1b28..05d168a 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -101,6 +101,41 @@ int validate_name(const char *n)
 	return (_validate_name(n) == NAME_VALID) ? 1 : 0;
 }
 
+/*
+ * Copy valid characters from source to destination.
+ * Invalid characters are skipped.  Copying is stopped
+ * when NAME_LEN characters have been copied.
+ */
+
+void copy_valid_chars(const char *src, char *dst)
+{
+	const char *s = src;
+	char *d = dst;
+	int len = 0;
+	int i;
+	char c;
+
+	if (!s || !*s)
+		return;
+
+	for (i = 0; i < strlen(src); i++) {
+		c = *s;
+
+		if (!isalnum(c) && c != '.' && c != '_' && c != '-' && c != '+') {
+			s++;
+			continue;
+		}
+
+		*d = *s;
+		d++;
+		s++;
+		len++;
+
+		if (len == NAME_LEN)
+			break;
+	}
+}
+
 static const char *_lvname_has_reserved_prefix(const char *lvname)
 {
 	static const char _prefixes[][12] = {
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 6a13e9e..0615f41 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -44,6 +44,8 @@ int validate_name(const char *n);
 name_error_t validate_name_detailed(const char *n);
 int validate_tag(const char *n);
 
+void copy_valid_chars(const char *src, char *dst);
+
 int apply_lvname_restrictions(const char *name);
 int is_reserved_lvname(const char *name);
 
diff --git a/lib/report/columns.h b/lib/report/columns.h
index f1d27ef..1dd56ac 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -139,7 +139,8 @@ FIELD(VGS, vg, STR, "AllocPol", cmd, 10, vgallocationpolicy, vg_allocation_polic
 FIELD(VGS, vg, BIN, "Clustered", cmd, 10, vgclustered, vg_clustered, "Set if VG is clustered.", 0)
 FIELD(VGS, vg, SIZ, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in current units.", 0)
 FIELD(VGS, vg, SIZ, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
-FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, vg_sysid, "System ID indicating when and where it was created.", 0)
+FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, vg_sysid, "System ID of the VG indicating its owner.", 0)
+FIELD(VGS, vg, STR, "System ID", system_id, 9, string, vg_systemid, "System ID of the VG indicating its owner.", 0)
 FIELD(VGS, vg, SIZ, "Ext", extent_size, 3, size32, vg_extent_size, "Size of Physical Extents in current units.", 0)
 FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, vg_extent_count, "Total number of Physical Extents.", 0)
 FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, vg_free_count, "Total number of unallocated Physical Extents.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c1c9563..4c1f6f5 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -362,6 +362,8 @@ GET_VG_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
 #define _vg_free_set prop_not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_sysid, vg_system_id_dup(vg))
 #define _vg_sysid_set prop_not_implemented_set
+GET_VG_STR_PROPERTY_FN(vg_systemid, vg_system_id_dup(vg))
+#define _vg_systemid_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_extent_size, (SECTOR_SIZE * vg->extent_size))
 #define _vg_extent_size_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_extent_count, vg->extent_count)
diff --git a/man/Makefile.in b/man/Makefile.in
index c42f07a..09d02ae 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -41,7 +41,7 @@ LVMETAD =
 endif
 
 MAN5=lvm.conf.5
-MAN7=
+MAN7=lvmsystemid.7
 MAN8=lvm-dumpconfig.8 \
 	lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
new file mode 100644
index 0000000..15b69a2
--- /dev/null
+++ b/man/lvmsystemid.7.in
@@ -0,0 +1,284 @@
+.TH "LVMSYSTEMID" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+
+.SH NAME
+lvmsystemid \(em LVM system id
+
+.SH DESCRIPTION
+
+Local VG's may exist on shared storage where they are visible to multiple
+hosts.  These VG's are intended to be used by only a single machine, even
+though they are visible to many.  A system_id identifying a single host
+can be assigned to a VG to indicate the VG's owner.  The VG owner can use
+the VG as usual, and all other hosts will ignore it.  This protects the VG
+from accidental use by other hosts.
+
+The system_id is not a dynamic property, and can only be changed in very
+limited circumstances (see vgexport and vgimport).  Even limited changes
+to the VG system_id are not perfectly reflected across hosts.  A more
+coherent view of shared storage requires using an inter-host locking
+system to coordinate access and update caches.
+
+The system_id is a string uniquely identifying a host.  It can be manually
+set to a custom value or it can be assigned automatically by lvm using a
+unique identifier already available on the host, e.g. machine-id or uname.
+
+In vgcreate, the local system_id is saved in the new VG metadata.  The
+local host owns the new VG, and other hosts will ignore it.
+
+A VG without a system_id can be used by any host, and a VG with a
+system_id can only be used by a host with a matching system_id.  A
+"foreign VG" is a VG with a system_id as viewed by a host with a system_id
+that does not match the VG's system_id.  (Or from a host without a
+system_id.)
+
+To benefit fully from system_id, all hosts must have system_id set, and
+VGs must have system_id set.  Two hosts should not be assigned the same
+system_id.  Doing so defeats the purpose of the system_id.
+
+Valid system_id characters are the same as valid VG name characters.  If a
+system_id contains invalid characters, those characters are omitted and
+remaining characters are used.  If a system_id is longer than the maximum
+name length, the characters up to the maximum length are used.  The
+maximum length of a system_id is 128 characters.
+
+.SS Types of VG access
+A "local VG" is meant to be used by a single host.
+.br
+A "shared VG" is meant to be used by multiple hosts.
+.br
+These can be further distinguished as:
+
+.B Unrestricted:
+A local VG that has no system_id.  This VG type is unprotected and
+accessible to any host.
+
+.B Owned:
+A local VG that has a system_id set, as viewed from the one host with a
+matching system_id (the owner).  This VG type is by definition acessible.
+
+.B Foreign:
+A local VG that has a system_id set, as viewed from any host with an
+unmatching system_id (or no system_id).  It is owned by another host.
+This VG type is by definition not accessible.
+
+.B Exported:
+A local VG that has been exported with vgexport and has no system_id.
+This VG type can only be accessed by vgimport which will change it to
+owned.
+
+.B Clustered:
+A shared VG with the clustered flag set, and no system_id.  This VG type
+is only accessible to hosts using clvmd.
+
+.SS system_id_source
+
+A host's own system_id can be defined in a number of ways.  lvm.conf
+global/system_id_source defines the method lvm will use to find the local
+system_id:
+
+.TP
+.B none
+.br
+
+lvm will not use a system_id.  lvm is allowed to access VGs without a
+system_id, and will create new VGs without a system_id.  An undefined
+system_id_source is equivalent to none.
+
+.I lvm.conf
+.nf
+global {
+    system_id_source = "none"
+}
+.fi
+
+.TP
+.B machineid
+.br
+
+The content of /etc/machine-id is used as the system_id if available.
+See
+.BR machine-id (5)
+and
+.BR systemd-machine-id-setup (1)
+to check if machine-id is available on the host.
+
+.I lvm.conf
+.nf
+global {
+    system_id_source = "machineid"
+}
+.fi
+
+.TP
+.B uname
+.br
+
+The string utsname.nodename from
+.BR uname (2)
+is used as the system_id.  A uname beginning with "localhost"
+is ignored and equivalent to none.
+
+.I lvm.conf
+.nf
+global {
+    system_id_source = "uname"
+}
+.fi
+
+.TP
+.B lvmlocal
+.br
+
+The system_id is defined in lvmlocal.conf local/system_id.
+
+.I lvm.conf
+.nf
+global {
+    system_id_source = "lvmlocal"
+}
+.fi
+
+.I lvmlocal.conf
+.nf
+local {
+    system_id = "example_name"
+}
+.fi
+
+.TP
+.B file
+.br
+
+The system_id is defined in a file specified by lvm.conf
+global/system_id_file.
+
+.I lvm.conf
+.nf
+global {
+    system_id_source = "file"
+    system_id_file = "/path/to/file"
+}
+.fi
+
+.LP
+
+Changing system_id_source will often cause the system_id to change, which
+may prevent the host from using VGs that it previously used (see
+allow_system_id below to handle this.)
+
+If a system_id_source other than none fails to resolve a system_id, the
+host will be allowed to access VGs with no system_id, but will not be
+allowed to access VGs with a defined system_id.
+
+.SS allow_system_id
+
+In some cases, it may be useful for a host to access VGs with different
+system_id's, e.g. if a host's system_id changes, and it wants to use VGs
+that it created with its old system_id.  To allow a host to access VGs
+with other system_id's, those other system_id's can be listed in
+lvmlocal.conf local/allow_system_id.
+
+.I lvmlocal.conf
+.nf
+local {
+    allow_system_id = [ "my_other_name" ]
+}
+.fi
+
+.SS vgcreate
+
+In vgcreate, a host sets its own system_id in the VG metadata.
+To override this and set another system_id:
+
+.B vgcreate --systemid
+.I SystemID VG Devices
+
+Overriding the system_id makes it possible for a host to create a VG that
+it may not be able to use.  Another host with a system_id matching the one
+specified may not recognize the new VG without manually rescanning
+devices.
+
+.SS report/display
+
+The system_id of a VG is displayed with the "systemid" reporting option.
+
+Report/display commands ignore foreign VGs by default.  To report foreign
+VGs, the --foreign option can be used.  This causes all VGs to be read
+from disk.
+
+.B vgs --foreign -o+systemid
+
+When a host with no system_id sees foreign VGs, it warns about them as
+they are skipped.  The host should be assigned a system_id, after which
+standard reporting commands will silently ignore foreign VGs.
+
+.SS vgexport/vgimport
+
+vgexport clears the system_id.
+
+Other hosts will continue to see a newly exported VG as foreign because of
+local caching (when lvmetad is used).  Manually updating the local lvmetad
+cache with pvscan --cache will allow a host to recognize the newly
+exported VG.
+
+vgimport sets the VG system_id to the local system_id as determined by
+lvm.conf system_id_sources.  vgimport automatically scans storage for
+newly exported VGs.
+
+After vgimport, the exporting host will continue to see the VG as
+exported, and not owned by the new host.  Manually updating the local
+cache with pvscan --cache will allow a host to recognize the newly
+imported VG as foreign.
+
+.SS vgchange
+
+If a VG has a system_id, changing it with vgchange requires --force.
+vgchange --systemid is accepted just as with vgcreate.
+
+If a host's system_id is changed, the system_id of its own VG's can be
+changed to match.  Using allow_system_id is a way to avoid using force
+with vgchange.
+
+To move a VG from one host to another, vgexport and vgimport should be
+used.
+
+.SS clustered VGs
+
+A "clustered" VG should have no system_id set, allowing multiple hosts to
+use it via clvm.  Changing a VG to clustered will clear the existing
+system_id.  Changing a VG to not clustered will set the system_id to the
+host running the vgchange command.
+
+.SS creation_host
+
+In vgcreate, the VG metadata field creation_host is set by default to the
+host's uname.  The creation_host cannot be changed, and is not used to
+control access.  When system_id_source is "uname", the system_id and
+creation_host will be the same.
+
+.SS orphans
+
+Orphan PVs are unused devices; they are not currently used in any VG.
+Because of this, they are not protected by a system_id, and any host can
+use them.  Coodination of changes to orphan PVs is beyond the scope of
+system_id.  The same is true of any block device that is not a PV.
+
+The effects of this are especially evident when lvm uses lvmetad caching.
+For example, if multiple hosts see an orphan PV, and one host creates a VG
+using the orphan, the other hosts will continue to report the PV as an
+orphan.  Nothing would automatically prevent the other hosts from using
+the newly allocated PV.  If the other hosts run a command to rescan
+devices, and update lvmetad, they would then recognize the PV has become
+used by another host.  A command that rescans devices could be pvscan
+--cache, or vgs --foreign.
+
+.SH SEE ALSO
+.BR vgcreate (8),
+.BR vgchange (8),
+.BR vgimport (8),
+.BR vgexport (8),
+.BR lvm.conf (5),
+.BR machine-id (5),
+.BR uname (2),
+.BR vgs (8)
+
diff --git a/tools/args.h b/tools/args.h
index 80e9155..a40cfb0 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -41,6 +41,7 @@ arg(discards_ARG, '\0', "discards", discards_arg, 0)
 arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
 arg(errorwhenfull_ARG, '\0', "errorwhenfull", yes_no_arg, 0)
 arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
+arg(foreign_ARG, '\0', "foreign", NULL, 0)
 arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
@@ -99,6 +100,7 @@ arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)	/* FIXME Use custom validation fn */
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
+arg(systemid_ARG, '\0', "systemid", string_arg, 0)
 arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
 arg(trackchanges_ARG, '\0', "trackchanges", NULL, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index febd851..e82cfe4 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -975,7 +975,7 @@ xx(vgchange,
    metadataprofile_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
    vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
    refresh_ARG, resizeable_ARG, resizable_ARG, select_ARG, sysinit_ARG,
-   test_ARG, uuid_ARG)
+   systemid_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
@@ -1037,7 +1037,8 @@ xx(vgcreate,
    maxphysicalvolumes_ARG, metadataprofile_ARG, metadatatype_ARG,
    physicalextentsize_ARG, test_ARG, force_ARG, zero_ARG, labelsector_ARG,
    metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
-   vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
+   vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
+   systemid_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
@@ -1259,7 +1260,7 @@ xx(vgs,
    ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG,
    nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    readonly_ARG, rows_ARG, select_ARG, separator_ARG, sort_ARG,
-   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG, foreign_ARG)
 
 xx(vgscan,
    "Search for all volume groups",
diff --git a/tools/reporter.c b/tools/reporter.c
index eb62bcf..ef74dc4 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -382,14 +382,6 @@ static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		      struct volume_group *vg,
 		      struct processing_handle *handle)
 {
-	int skip;
-
-	if (ignore_vg(vg, vg_name, 0, &skip))
-		return_ECMD_FAILED;
-
-	if (skip)
-		return ECMD_PROCESSED;
-
 	return process_each_pv_in_vg(cmd, vg, handle, &_pvs_single);
 }
 
@@ -397,14 +389,6 @@ static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
 			 struct processing_handle *handle)
 {
-	int skip;
-
-	if (ignore_vg(vg, vg_name, 0, &skip))
-		return_ECMD_FAILED;
-
-	if (skip)
-		return ECMD_PROCESSED;
-
 	return process_each_pv_in_vg(cmd, vg, handle, &_pvsegs_single);
 }
 
@@ -597,6 +581,17 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	int lv_info_needed, lv_segment_status_needed;
 	int lock_global = 0;
 
+	/*
+	 * When reporting foreign VGs we want to refresh our cached
+	 * copy of them, since other hosts have probably made changes
+	 * to their own VGs.  We also want to override the default
+	 * behavior which skips over foreign VGs.
+	 */
+	if (arg_is_set(cmd, foreign_ARG) && lvmetad_used()) {
+		lvmetad_pvscan_all_devs(cmd, NULL);
+		cmd->include_foreign_vgs = 1;
+	}
+
 	aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
 	buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
 	headings = find_config_tree_bool(cmd, report_headings_CFG, NULL);
diff --git a/tools/toollib.c b/tools/toollib.c
index df3f479..b7e4f53 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -17,6 +17,7 @@
 #include <sys/stat.h>
 #include <signal.h>
 #include <sys/wait.h>
+#include <sys/utsname.h>
 
 struct device_id_list {
 	struct dm_list list;
@@ -175,7 +176,8 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
  *
  * Case c covers the other errors returned when reading the VG.
  */
-int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *skip)
+static int ignore_vg(struct volume_group *vg, const char *vg_name,
+		     struct dm_list *arg_vgnames, int allow_inconsistent, int *skip)
 {
 	uint32_t read_error = vg_read_error(vg);
 	*skip = 0;
@@ -189,6 +191,25 @@ int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsiste
 		*skip = 1;
 	}
 
+	/*
+	 * Commands that operate on "all vgs" shouldn't be bothered by
+	 * skipping a foreign VG, and the command shouldn't fail when
+	 * one is skipped.  But, if the command explicitly asked to
+	 * operate on a foreign VG and it's skipped, then the command
+	 * would expect to fail.
+	 */
+	if (read_error & FAILED_SYSTEMID) {
+		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
+			log_error("Skipping volume group %s with system id %s",
+				  vg->name, vg->system_id);
+			return 1;
+		} else {
+			read_error &= ~FAILED_SYSTEMID; /* Check for other errors */
+			log_verbose("Skipping volume group %s", vg_name);
+			*skip = 1;
+		}
+	}
+
 	if (read_error != SUCCESS) {
 		log_error("Cannot process volume group %s", vg_name);
 		return 1;
@@ -653,6 +674,7 @@ int vgcreate_params_set_defaults(struct cmd_context *cmd,
 		vp_def->alloc = vg->alloc;
 		vp_def->clustered = vg_is_clustered(vg);
 		vp_def->vgmetadatacopies = vg->mda_copies;
+		vp_def->system_id = vg->system_id ? dm_pool_strdup(cmd->mem, vg->system_id) : NULL;
 	} else {
 		vp_def->vg_name = NULL;
 		extent_size = find_config_tree_int64(cmd,
@@ -667,6 +689,7 @@ int vgcreate_params_set_defaults(struct cmd_context *cmd,
 		vp_def->alloc = DEFAULT_ALLOC_POLICY;
 		vp_def->clustered = DEFAULT_CLUSTERED;
 		vp_def->vgmetadatacopies = DEFAULT_VGMETADATACOPIES;
+		vp_def->system_id = cmd->system_id ? dm_pool_strdup(cmd->mem, cmd->system_id) : NULL;
 	}
 
 	return 1;
@@ -682,6 +705,8 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 				  struct vgcreate_params *vp_new,
 				  struct vgcreate_params *vp_def)
 {
+	const char *arg_str;
+
 	vp_new->vg_name = skip_dev_dir(cmd, vp_def->vg_name, NULL);
 	vp_new->max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG,
 					vp_def->max_lv);
@@ -730,6 +755,27 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		vp_new->vgmetadatacopies = find_config_tree_int(cmd, metadata_vgmetadatacopies_CFG, NULL);
 	}
 
+	if ((arg_str = arg_str_value(cmd, systemid_ARG, NULL))) {
+		vp_new->system_id = system_id_from_string(cmd, arg_str);
+	} else {
+		vp_new->system_id = vp_def->system_id;
+	}
+
+	if (arg_str) {
+		if (!vp_new->system_id)
+			log_warn("No local system id found, VG will not have a system id.");
+
+		if (vp_new->system_id && cmd->system_id &&
+		    strcmp(vp_new->system_id, cmd->system_id)) {
+			log_warn("VG system id \"%s\" will not be accessible to local system id \"%s\"",
+				 vp_new->system_id, cmd->system_id);
+		}
+	}
+
+	/* A clustered vg has no system_id. */
+	if (vp_new->clustered)
+		vp_new->system_id = NULL;
+
 	return 1;
 }
 
@@ -1744,7 +1790,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		skip = 0;
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags);
-		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+		if (ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			release_vg(vg);
@@ -2184,7 +2230,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		}
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags);
-		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+		if (ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			release_vg(vg);
@@ -2658,7 +2704,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		skip = 0;
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags | READ_WARN_INCONSISTENT);
-		if (ignore_vg(vg, vg_name, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+		if (ignore_vg(vg, vg_name, NULL, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			release_vg(vg);
diff --git a/tools/toollib.h b/tools/toollib.h
index b9d4680..75eed87 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -21,8 +21,6 @@
 
 int become_daemon(struct cmd_context *cmd, int skip_lvm);
 
-int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *skip);
-
 /*
  * The "struct processing_handle" is used as a handle for processing
  * functions (process_each_* and related).
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e3f852b..d56b3df 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -332,6 +332,11 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 		}
 	}
 
+	if (clustered)
+		vg->system_id = NULL;
+	else if (cmd->system_id && cmd->system_id[0])
+		vg->system_id = dm_pool_strdup(cmd->mem, cmd->system_id);
+
 	if (!vg_set_clustered(vg, clustered))
 		return_0;
 
@@ -471,6 +476,38 @@ static int _vgchange_profile(struct cmd_context *cmd,
 	return 1;
 }
 
+/*
+ * This function will not be called unless the local host is allowed to use the
+ * VG.  Either the VG has no system_id, or the VG and host have matching
+ * system_ids, or the host has the VG's current system_id in its
+ * allow_system_id list.  This function is not allowed to change the system_id
+ * of a foreign VG (VG owned by another host).
+ */
+
+static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
+{
+	const char *arg_str = arg_str_value(cmd, systemid_ARG, NULL);
+	char *system_id;
+
+	if (!arg_str)
+		return 0;
+
+	system_id = system_id_from_string(cmd, arg_str);
+
+	if (system_id && cmd->system_id && strcmp(system_id, cmd->system_id)) {
+		log_warn("VG \"%s\" system id \"%s\" does not match local system id \"%s\"",
+			 vg->name, system_id, cmd->system_id);
+
+		if (yes_no_prompt("Change system id? [y/n]: ") == 'n') {
+			log_error("Volume group \"%s\" not changed.", vg->name);
+			return 0;
+		}
+	}
+
+	vg->system_id = system_id;
+	return 1;
+}
+
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   struct processing_handle *handle __attribute__((unused)))
@@ -494,8 +531,9 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ clustered_ARG, &_vgchange_clustered },
 		{ vgmetadatacopies_ARG, &_vgchange_metadata_copies },
 		{ metadataprofile_ARG, &_vgchange_profile },
-		{ profile_ARG, &_vgchange_profile},
-		{ detachprofile_ARG, &_vgchange_profile},
+		{ profile_ARG, &_vgchange_profile },
+		{ detachprofile_ARG, &_vgchange_profile },
+		{ systemid_ARG, &_vgchange_system_id },
 	};
 
 	if (vg_is_exported(vg)) {
@@ -589,13 +627,19 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
-	/* Update commands that can be combined */
+	int noupdate =
+		arg_count(cmd, activate_ARG) ||
+		arg_count(cmd, monitor_ARG) ||
+		arg_count(cmd, poll_ARG) ||
+		arg_count(cmd, refresh_ARG);
+
 	int update_partial_safe =
 		arg_count(cmd, deltag_ARG) ||
 		arg_count(cmd, addtag_ARG) ||
 		arg_count(cmd, metadataprofile_ARG) ||
 		arg_count(cmd, profile_ARG) ||
 		arg_count(cmd, detachprofile_ARG);
+
 	int update_partial_unsafe =
 		arg_count(cmd, logicalvolume_ARG) ||
 		arg_count(cmd, maxphysicalvolumes_ARG) ||
@@ -604,18 +648,13 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, physicalextentsize_ARG) ||
 		arg_count(cmd, clustered_ARG) ||
 		arg_count(cmd, alloc_ARG) ||
-		arg_count(cmd, vgmetadatacopies_ARG);
+		arg_count(cmd, vgmetadatacopies_ARG) ||
+		arg_count(cmd, systemid_ARG);
+
 	int update = update_partial_safe || update_partial_unsafe;
 
-	if (!update &&
-	    !arg_count(cmd, activate_ARG) &&
-	    !arg_count(cmd, monitor_ARG) &&
-	    !arg_count(cmd, poll_ARG) &&
-	    !arg_count(cmd, refresh_ARG)) {
-		log_error("Need 1 or more of -a, -c, -l, -p, -s, -x, "
-			  "--refresh, --uuid, --alloc, --addtag, --deltag, "
-			  "--monitor, --poll, --vgmetadatacopies or "
-			  "--metadatacopies");
+	if (!update && !noupdate) {
+		log_error("Need one or more command options.");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index ed6c4d9..5e03845 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -71,6 +71,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	    !vg_set_max_pv(vg, vp_new.max_pv) ||
 	    !vg_set_alloc_policy(vg, vp_new.alloc) ||
 	    !vg_set_clustered(vg, vp_new.clustered) ||
+	    !vg_set_system_id(vg, vp_new.system_id) ||
 	    !vg_set_mda_copies(vg, vp_new.vgmetadatacopies))
 		goto bad_orphan;
 
diff --git a/tools/vgexport.c b/tools/vgexport.c
index d4be3c7..4bed421 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -32,6 +32,7 @@ static int vgexport_single(struct cmd_context *cmd __attribute__((unused)),
 		goto_bad;
 
 	vg->status |= EXPORTED_VG;
+	vg->system_id = NULL;
 
 	dm_list_iterate_items(pvl, &vg->pvs)
 		pvl->pv->status |= EXPORTED_VG;
diff --git a/tools/vgimport.c b/tools/vgimport.c
index d5ca7c3..41fd393 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -37,6 +37,7 @@ static int vgimport_single(struct cmd_context *cmd __attribute__((unused)),
 		goto_bad;
 
 	vg->status &= ~EXPORTED_VG;
+	vg->system_id = cmd->system_id ? dm_pool_strdup(cmd->mem, cmd->system_id) : NULL;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
@@ -84,6 +85,17 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		cmd->handles_missing_pvs = 1;
 	}
 
+	/*
+	 * Rescan devices and update lvmetad.  lvmetad may hold a copy of the
+	 * VG from before it was exported, if it was exported by another host.
+	 * We need to reread it to see that it's been exported before we can
+	 * import it.
+	 */
+	if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL)) {
+		log_error("Failed to scan devices.");
+		return ECMD_FAILED;
+	}
+
 	return process_each_vg(cmd, argc, argv,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			       NULL,


