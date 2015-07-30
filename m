From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Jul 2015 11:57:55 +0000 (UTC)
Subject: master - refactor: toolcontext: add struct cmd_context_initialized_parts
Message-ID: <20150730115755.5385060EAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b0c464a3462c568931c22fe71cc4f80b7ead508
Commit:        6b0c464a3462c568931c22fe71cc4f80b7ead508
Parent:        9aabf441bdb8480f2e99722955fedcb4a19d760d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 30 09:59:39 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 30 13:54:05 2015 +0200

refactor: toolcontext: add struct cmd_context_initialized_parts

Add struct cmd_context_initialized_parts to wrap up information
about which cmd context pieces are initialized and add variable
of this struct type into struct cmd_context.

Also, move existing "config_initialized" variable that was directly
part of cmd_context into the new cmd_context.initialized wrapper.

We'll be adding more items into the struct cmd_context_initialized_parts
with subsequent patches...
---
 daemons/clvmd/lvm-functions.c |    2 +-
 lib/commands/toolcontext.c    |    8 ++++----
 lib/commands/toolcontext.h    |    8 +++++++-
 tools/lvmcmdline.c            |    2 +-
 4 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index dafffcc..e7dbfde 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -510,7 +510,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, critical_section = %d\n",
 		 resource, decode_locking_cmd(command), decode_flags(lock_flags), critical_section());
 
-	if (!cmd->config_initialized || config_files_changed(cmd)) {
+	if (!cmd->initialized.config || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (do_refresh_cache()) {
 			log_error("Updated config file invalid. Aborting.");
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 3fe2bb2..da0ca22 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1851,9 +1851,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	cmd->default_settings.cache_vgmetadata = 1;
 	cmd->current_settings = cmd->default_settings;
 
-	cmd->config_initialized = 1;
+	cmd->initialized.config = 1;
 out:
-	if (!cmd->config_initialized) {
+	if (!cmd->initialized.config) {
 		destroy_toolcontext(cmd);
 		cmd = NULL;
 	}
@@ -1979,7 +1979,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 
 	_destroy_config(cmd);
 
-	cmd->config_initialized = 0;
+	cmd->initialized.config = 0;
 
 	cmd->hosttags = 0;
 
@@ -2057,7 +2057,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_init_backup(cmd))
 		return_0;
 
-	cmd->config_initialized = 1;
+	cmd->initialized.config = 1;
 
 	reset_lvm_errno(1);
 	return 1;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4e8998d..c59024b 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -60,6 +60,10 @@ struct config_tree_list {
 	struct dm_config_tree *cft;
 };
 
+struct cmd_context_initialized_parts {
+	unsigned config:1; /* used to reinitialize config if previous init was not successful */
+};
+
 /* FIXME Split into tool & library contexts */
 /* command-instance-related variables needed by library */
 struct cmd_context {
@@ -82,6 +86,9 @@ struct cmd_context {
 	char **argv;
 	struct arg_values *arg_values;
 	struct dm_list arg_value_groups;
+
+	struct cmd_context_initialized_parts initialized;
+
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
 	unsigned handles_unknown_segments:1;
@@ -132,7 +139,6 @@ struct cmd_context {
 	struct dm_list config_files; /* master lvm config + any existing tag configs */
 	struct profile_params *profile_params; /* profile handling params including loaded profile configs */
 	struct dm_config_tree *cft; /* the whole cascade: CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES */
-	int config_initialized; /* used to reinitialize config if previous init was not successful */
 
 	struct dm_hash_table *cft_def_hash; /* config definition hash used for validity check (item type + item recognized) */
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9e0d029..98a2c30 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1541,7 +1541,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			goto_out;
 		}
 
-	if (arg_count(cmd, config_ARG) || !cmd->config_initialized || config_files_changed(cmd)) {
+	if (arg_count(cmd, config_ARG) || !cmd->initialized.config || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
 			if ((config_string_cft = remove_config_tree_by_source(cmd, CONFIG_STRING)))


