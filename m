From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:56:11 +0000 (UTC)
Subject: dev-peter-config-profiles - toolcontext: add a few comments for struct cmd_context and rename config_valid -> config_initialized
Message-ID: <20130626145611.76540615EB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fb82a545af104e2e2db0fffdc06f1f3e6df1f41
Commit:        6fb82a545af104e2e2db0fffdc06f1f3e6df1f41
Parent:        1d6b2534876615584899cbfb94a4cece8d5a1644
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 26 12:29:19 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:51 2013 +0200

toolcontext: add a few comments for struct cmd_context and rename config_valid -> config_initialized

Just to make it more clear and also not to confuse
config_valid with check against config definition
(and its 'valid' flag within the config defintion tree).
---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/commands/toolcontext.c    |    8 ++++----
 lib/commands/toolcontext.h    |   14 ++++++++------
 tools/lvmcmdline.c            |    2 +-
 4 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 9d62675..5f1658d 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -508,7 +508,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, critical_section = %d\n",
 		 resource, decode_locking_cmd(command), decode_flags(lock_flags), critical_section());
 
-	if (!cmd->config_valid || config_files_changed(cmd)) {
+	if (!cmd->config_initialized || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (do_refresh_cache()) {
 			log_error("Updated config file invalid. Aborting.");
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d736521..50c96d4 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1585,9 +1585,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	cmd->default_settings.cache_vgmetadata = 1;
 	cmd->current_settings = cmd->default_settings;
 
-	cmd->config_valid = 1;
+	cmd->config_initialized = 1;
 out:
-	if (cmd->config_valid != 1) {
+	if (!cmd->config_initialized) {
 		destroy_toolcontext(cmd);
 		cmd = NULL;
 	}
@@ -1702,7 +1702,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	cft_cmdline = remove_config_tree_by_source(cmd, CONFIG_STRING);
 	_destroy_config(cmd);
 
-	cmd->config_valid = 0;
+	cmd->config_initialized = 0;
 
 	cmd->hosttags = 0;
 
@@ -1759,7 +1759,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_init_backup(cmd))
 		return 0;
 
-	cmd->config_valid = 1;
+	cmd->config_initialized = 1;
 
 	reset_lvm_errno(1);
 	return 1;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 7551245..42a4e54 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -98,14 +98,16 @@ struct cmd_context {
 	struct dev_filter *lvmetad_filter;
 	int dump_filter;	/* Dump filter when exiting? */
 
-	struct dm_list config_files;
-	int config_valid;
-	struct dm_config_tree *cft;
+	struct dm_list config_files; /* master lvm config + any existing tag configs */
+	struct profile_params *profile_params; /* profile handling params including loaded profile configs */
+	struct dm_config_tree *cft; /* the whole cascade: CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES */
+	int config_initialized; /* used to reinitialize config if previous init was not successful */
+	struct dm_hash_table *cft_def_hash; /* config definition hash used for validity check (item type + item recognized) */
+
+	/* selected settings with original default/configured value which can be changed during cmd processing */
 	struct config_info default_settings;
+	/* may contain changed values compared to default_settings */
 	struct config_info current_settings;
-	struct dm_hash_table *cft_def_hash; /* cft definition hash used for validity check */
-
-	struct profile_params *profile_params;
 
 	struct archive_params *archive_params;
 	struct backup_params *backup_params;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e87842b..388906e 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1082,7 +1082,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			goto_out;
 		}
 
-	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
+	if (arg_count(cmd, config_ARG) || !cmd->config_initialized || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
 			old_cft = remove_config_tree_by_source(cmd, CONFIG_STRING);


