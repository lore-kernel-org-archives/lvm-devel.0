From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 20:41:48 +0000 (UTC)
Subject: master - systemid: Add warnings if invalid.
Message-ID: <20150223204148.CDA7F60FAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2ed5feee504185faeba8e85c32769b5dba8a3f2
Commit:        c2ed5feee504185faeba8e85c32769b5dba8a3f2
Parent:        6b6934b009f57fe4677cf357bfb26746ce89747a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 20:36:27 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 20:36:27 2015 +0000

systemid: Add warnings if invalid.

Add WARNING messages if there are problems setting the requested
system ID.
Ban "localhost" as a prefix regardless of the system_id_source.
Use cmd->hostname instead of calling uname again.
Make system_id_source values case-insensitive (as with new settings like
log_debug_classes) and also accept machine-id to match the filename.
---
 lib/commands/toolcontext.c |   38 ++++++++++++++++++++++++--------------
 lib/commands/toolcontext.h |    1 -
 2 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 0a253f3..164b344 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -55,20 +55,29 @@
 
 static const size_t linebuffer_size = 4096;
 
-
-/* Copy the input string, removing invalid characters. */
-
+/*
+ * Copy the input string, removing invalid characters.
+ */
 char *system_id_from_string(struct cmd_context *cmd, const char *str)
 {
 	char *system_id;
 
-	if (!(system_id = dm_pool_zalloc(cmd->mem, strlen(str) + 1)))
+	if (!(system_id = dm_pool_zalloc(cmd->mem, strlen(str) + 1))) {
+		log_warn("WARNING: Failed to allocate system ID.");
 		return NULL;
+	}
 
 	copy_systemid_chars(str, system_id);
 
-	if (!system_id[0])
+	if (!*system_id) {
+		log_warn("WARNING: Invalid system ID format: %s", str);
+		return NULL;
+	}
+
+	if (!strncmp(system_id, "localhost", 9)) {
+		log_warn("WARNING: System ID may not begin with the string \"localhost\".");
 		return NULL;
+	}
 
 	return system_id;
 }
@@ -104,39 +113,40 @@ static char *_read_system_id_from_file(struct cmd_context *cmd, const char *file
 
 static char *_system_id_from_source(struct cmd_context *cmd, const char *source)
 {
-	struct utsname uts;
 	char filebuf[PATH_MAX];
 	const char *file;
 	const char *etc_str;
 	const char *str;
 	char *system_id = NULL;
 
-	if (!strcmp(source, "uname")) {
-		if (!uname(&uts) && strncmp(uts.nodename, "localhost", 9))
-			system_id = system_id_from_string(cmd, uts.nodename);
+	if (!strcasecmp(source, "uname")) {
+		if (cmd->hostname)
+			system_id = system_id_from_string(cmd, cmd->hostname);
 		goto out;
 	}
 
 	/* lvm.conf and lvmlocal.conf are merged into one config tree */
-	if (!strcmp(source, "lvmlocal")) {
+	if (!strcasecmp(source, "lvmlocal")) {
 		if ((str = find_config_tree_str(cmd, local_system_id_CFG, NULL)))
 			system_id = system_id_from_string(cmd, str);
 		goto out;
 	}
 
-	if (!strcmp(source, "machineid")) {
-		memset(filebuf, 0, sizeof(filebuf));
+	if (!strcasecmp(source, "machineid") || !strcasecmp(source, "machine-id")) {
 		etc_str = find_config_tree_str(cmd, global_etc_CFG, NULL);
-		if (dm_snprintf(filebuf, sizeof(filebuf), "%s/machine-id", etc_str) >= 0)
+		if (dm_snprintf(filebuf, sizeof(filebuf), "%s/machine-id", etc_str) != -1)
 			system_id = _read_system_id_from_file(cmd, filebuf);
 		goto out;
 	}
 
-	if (!strcmp(source, "file")) {
+	if (!strcasecmp(source, "file")) {
 		file = find_config_tree_str(cmd, global_system_id_file_CFG, NULL);
 		system_id = _read_system_id_from_file(cmd, file);
 		goto out;
 	}
+
+	log_warn("WARNING: Unrecognised system_id_source \"%s\".", source);
+
 out:
 	return system_id;
 }
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index a3aaf7c..8b3e48e 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -163,7 +163,6 @@ int init_lvmcache_orphans(struct cmd_context *cmd);
 
 struct format_type *get_format_by_name(struct cmd_context *cmd, const char *format);
 
-char *system_id_from_source(struct cmd_context *cmd, const char *system_id_source);
 char *system_id_from_string(struct cmd_context *cmd, const char *system_id_string);
 
 #endif


