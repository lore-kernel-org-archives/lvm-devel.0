From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:32:56 +0000 (UTC)
Subject: master - toolcontext: add a few comments for struct cmd_context and rename config_valid -> config_initialized
Message-ID: <20130702133256.3C7E360DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8769033e078c79ee4167c5186d7407d1729fd8a4
Commit:        8769033e078c79ee4167c5186d7407d1729fd8a4
Parent:        0cd47947359d2ba093dc7da5e489cafb34b038d0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 26 12:29:19 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:22:11 2013 +0200

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
index 5f99b0b..b7e3d46 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1507,9 +1507,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
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
@@ -1624,7 +1624,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	cft_cmdline = remove_config_tree_by_source(cmd, CONFIG_STRING);
 	_destroy_config(cmd);
 
-	cmd->config_valid = 0;
+	cmd->config_initialized = 0;
 
 	cmd->hosttags = 0;
 
@@ -1681,7 +1681,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
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
index 6efa29a..3aa4206 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1080,7 +1080,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			goto_out;
 		}
 
-	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
+	if (arg_count(cmd, config_ARG) || !cmd->config_initialized || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
 			old_cft = remove_config_tree_by_source(cmd, CONFIG_STRING);


