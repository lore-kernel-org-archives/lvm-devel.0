From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 20:23:49 +0000 (UTC)
Subject: master - toolcontext: Include system_id in refresh.
Message-ID: <20150223202349.3A19260284@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b6934b009f57fe4677cf357bfb26746ce89747a
Commit:        6b6934b009f57fe4677cf357bfb26746ce89747a
Parent:        72e6888dc3aaeecc869715366b7d3fdcc7732992
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 20:21:00 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 20:21:00 2015 +0000

toolcontext: Include system_id in refresh.

Move _init_system_id() into _process_config() so it's also called when
refreshing the toolcontext.  Add WARNING to log_warn messages.
---
 lib/commands/toolcontext.c |   74 ++++++++++++++++++++++----------------------
 1 files changed, 37 insertions(+), 37 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1b0a427..0a253f3 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -102,7 +102,7 @@ static char *_read_system_id_from_file(struct cmd_context *cmd, const char *file
 	return NULL;
 }
 
-char *system_id_from_source(struct cmd_context *cmd, const char *source)
+static char *_system_id_from_source(struct cmd_context *cmd, const char *source)
 {
 	struct utsname uts;
 	char filebuf[PATH_MAX];
@@ -391,6 +391,39 @@ int process_profilable_config(struct cmd_context *cmd)
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
+		log_warn("WARNING: local/system_id is set, so should global/system_id_source be \"lvmlocal\" not \"%s\"?", source);
+
+	if (!strcmp(source, "none"))
+		return 1;
+
+	if ((cmd->system_id = _system_id_from_source(cmd, source)))
+		return 1;
+
+	/*
+	 * The source failed to resolve a system_id.  In this case allow
+	 * VGs with no system_id to be accessed, but not VGs with a system_id.
+	 */
+	log_warn("WARNING: No system ID found from system_id_source \"%s\".", source);
+	cmd->unknown_system_id = 1;
+
+	return 1;
+}
+
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
@@ -567,6 +600,9 @@ static int _process_config(struct cmd_context *cmd)
 
 	lvmetad_init(cmd);
 
+	if (!_init_system_id(cmd))
+		return_0;
+
 	return 1;
 }
 
@@ -1446,39 +1482,6 @@ static int _init_hostname(struct cmd_context *cmd)
 	return 1;
 }
 
-static int _init_system_id(struct cmd_context *cmd)
-{
-	const char *source;
-	int local_set;
-
-	cmd->system_id = NULL;
-
-	local_set = !!find_config_tree_str(cmd, local_system_id_CFG, NULL);
-
-	source = find_config_tree_str(cmd, global_system_id_source_CFG, NULL);
-	if (!source)
-		source = "none";
-
-	/* Defining local system_id but not using it is probably a config mistake. */
-	if (local_set && strcmp(source, "lvmlocal"))
-		log_warn("Local system_id is not used by system_id_source %s.", source);
-
-	if (!strcmp(source, "none"))
-		return 1;
-
-	if ((cmd->system_id = system_id_from_source(cmd, source)))
-		return 1;
-
-	/*
-	 * The source failed to resolve a system_id.  In this case allow
-	 * VGs with no system_id to be accessed, but not VGs with a system_id.
-	 */
-
-	log_warn("No system_id found from system_id_source %s.", source);
-	cmd->unknown_system_id = 1;
-	return 1;
-}
-
 static int _init_backup(struct cmd_context *cmd)
 {
 	uint32_t days, min;
@@ -1711,9 +1714,6 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (!_init_profiles(cmd))
 		goto_out;
 
-	if (!_init_system_id(cmd))
-		goto_out;
-
 	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
 						find_config_tree_node(cmd, devices_types_CFG, NULL))))
 		goto_out;


