From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Jul 2015 14:04:08 +0000 (UTC)
Subject: master - cleanup: toolcontext: make cmd_context more readable
Message-ID: <20150730140408.718706100F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6834b3237e2d523430a8b8a3ff24b0b27f7cb2f
Commit:        e6834b3237e2d523430a8b8a3ff24b0b27f7cb2f
Parent:        c0629c13fe2dfa8d6aaace242209f4bf7675345f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 30 16:01:02 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 30 16:01:02 2015 +0200

cleanup: toolcontext: make cmd_context more readable

Just shuffle the items and put them into logical groups so it's
visible at first sight what each group contains - it makes it a bit
easier to make heads and tails of the whole cmd_context monster.
---
 lib/commands/toolcontext.h |  134 ++++++++++++++++++++++++++------------------
 1 files changed, 79 insertions(+), 55 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 57feb01..d2fd8a2 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -69,29 +69,50 @@ struct cmd_context_initialized_parts {
 /* FIXME Split into tool & library contexts */
 /* command-instance-related variables needed by library */
 struct cmd_context {
-	struct dm_pool *libmem;	/* For permanent config data */
-	struct dm_pool *mem;	/* Transient: Cleared between each command */
-
-	const struct format_type *fmt;	/* Current format to use by default */
-	struct format_type *fmt_backup;	/* Format to use for backups */
-
-	struct dm_list formats;	/* Available formats */
-	struct dm_list segtypes;	/* Available segment types */
-	const char *system_id;
-	const char *hostname;
-	const char *kernel_vsn;
+	/*
+	 * Memory handlers.
+	 */
+	struct dm_pool *libmem;			/* for permanent config data */
+	struct dm_pool *mem;			/* transient: cleared between each command */
 
-	unsigned rand_seed;
-	char *linebuffer;
+	/*
+	 * Command line and arguments.
+	 */
 	const char *cmd_line;
 	struct command *command;
 	char **argv;
 	struct arg_values *arg_values;
 	struct dm_list arg_value_groups;
 
+	/*
+	 * Format handlers.
+	 */
+	const struct format_type *fmt;		/* current format to use by default */
+	struct format_type *fmt_backup;		/* format to use for backups */
+	struct dm_list formats;			/* available formats */
+	struct dm_list segtypes;		/* available segment types */
+
+	/*
+	 * Machine and system identification.
+	 */
+	const char *system_id;
+	const char *hostname;
+	const char *kernel_vsn;
+
+	/*
+	 * Device identification.
+	 */
+	struct dev_types *dev_types;		/* recognized extra device types. */
+
+	/*
+	 * Initialization state.
+	 */
 	struct cmd_context_initialized_parts initialized;
 
-	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
+	/*
+	 * Switches.
+	 */
+	unsigned is_long_lived:1;		/* optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
 	unsigned handles_unknown_segments:1;
 	unsigned use_linear_target:1;
@@ -102,68 +123,71 @@ struct cmd_context {
 	unsigned report_binary_values_as_numeric:1;
 	unsigned metadata_read_only:1;
 	unsigned ignore_clustered_vgs:1;
-	unsigned threaded:1;		/* Set if running within a thread e.g. clvmd */
-
-	const char *time_format;
-
-	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
+	unsigned threaded:1;			/* set if running within a thread e.g. clvmd */
+	unsigned independent_metadata_areas:1;	/* active formats have MDAs outside PVs */
 	unsigned unknown_system_id:1;
-	unsigned include_foreign_vgs:1; /* report/display cmds can reveal foreign VGs */
-	unsigned include_shared_vgs:1;  /* report/display cmds can reveal lockd VGs */
-	unsigned include_active_foreign_vgs:1; /* cmd should process foreign VGs with active LVs */
-	unsigned vg_read_print_access_error:1; /* print access errors from vg_read */
+	unsigned include_foreign_vgs:1;		/* report/display cmds can reveal foreign VGs */
+	unsigned include_shared_vgs:1;		/* report/display cmds can reveal lockd VGs */
+	unsigned include_active_foreign_vgs:1;	/* cmd should process foreign VGs with active LVs */
+	unsigned vg_read_print_access_error:1;	/* print access errors from vg_read */
 	unsigned lockd_gl_disable:1;
 	unsigned lockd_vg_disable:1;
 	unsigned lockd_lv_disable:1;
 	unsigned lockd_vg_default_sh:1;
 	unsigned lockd_vg_enforce_sh:1;
 
-	struct dev_types *dev_types;
-
 	/*
-	 * Use of filters depends on whether lvmetad is used or not:
-	 *
-	 *   - if lvmetad is used:
-	 *   	- cmd->lvmetad_filter used when scanning devices for lvmetad
-	 *   	- cmd->filter used when processing lvmetad responses
-	 *   	- cmd->full_filter used for remaining situations
-	 *
-	 *   - if lvmetad is not used:
-	 *   	- cmd->lvmetad_filter is NULL
-	 *   	- cmd->filter == cmd->full_filter used for all situations
-	 *
+	 * Filtering.
 	 */
-	struct dev_filter *lvmetad_filter;
-	struct dev_filter *filter;
-	struct dev_filter *full_filter;
-	int dump_filter;	/* Dump filter when exiting? */
-
-	struct dm_list config_files; /* master lvm config + any existing tag configs */
-	struct profile_params *profile_params; /* profile handling params including loaded profile configs */
-	struct dm_config_tree *cft; /* the whole cascade: CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES */
+	struct dev_filter *lvmetad_filter;	/* pre-lvmetad filter chain */
+	struct dev_filter *filter;		/* post-lvmetad filter chain */
+	struct dev_filter *full_filter;		/* lvmetad_filter + filter */
+	int dump_filter;			/* Dump filter when exiting? */
 
-	struct dm_hash_table *cft_def_hash; /* config definition hash used for validity check (item type + item recognized) */
-
-	/* selected settings with original default/configured value which can be changed during cmd processing */
-	struct config_info default_settings;
-	/* may contain changed values compared to default_settings */
-	struct config_info current_settings;
+	/*
+	 * Configuration.
+	 */
+	struct dm_list config_files; 		/* master lvm config + any existing tag configs */
+	struct profile_params *profile_params;	/* profile handling params including loaded profile configs */
+	struct dm_config_tree *cft;		/* the whole cascade: CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES */
+	struct dm_hash_table *cft_def_hash;	/* config definition hash used for validity check (item type + item recognized) */
+	struct config_info default_settings;	/* selected settings with original default/configured value which can be changed during cmd processing */
+	struct config_info current_settings; 	/* may contain changed values compared to default_settings */
 
+	/*
+	 * Archives and backups.
+	 */
 	struct archive_params *archive_params;
 	struct backup_params *backup_params;
 	const char *stripe_filler;
 
-	/* List of defined tags */
-	struct dm_list tags;
+	/*
+	 * Host tags.
+	 */
+	struct dm_list tags;			/* list of defined tags */
 	const char *report_list_item_separator;
 	int hosttags;
 
-	const char *lib_dir;		/* Cache value global/library_dir */
+	/*
+	 * Paths.
+	 */
+	const char *lib_dir;			/* cache value global/library_dir */
 	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
-	char display_buffer[NAME_LEN * 10];	/* Ring buffer for upto 10 longest vg/lv names */
-	unsigned display_lvname_idx;		/* Index to ring buffer */
+
+	/*
+	 * Buffers.
+	 */
+	char display_buffer[NAME_LEN * 10];	/* ring buffer for upto 10 longest vg/lv names */
+	unsigned display_lvname_idx;		/* index to ring buffer */
+	char *linebuffer;
+
+	/*
+	 * Others - unsorted.
+	 */
+	const char *time_format;
+	unsigned rand_seed;
 };
 
 /*


