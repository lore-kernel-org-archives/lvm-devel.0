From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 25 Feb 2015 14:11:14 +0000 (UTC)
Subject: master - systemid: Allow empty systemid with warnings.
Message-ID: <20150225141114.B869F60D30@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ac6a4cd7079fa97f866cde5ba3adedbf7fd61cba
Commit:        ac6a4cd7079fa97f866cde5ba3adedbf7fd61cba
Parent:        7d615a3fe58e76af4d3b192298d55a60de9b0d5d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Feb 25 14:12:24 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Feb 25 14:12:24 2015 +0000

systemid: Allow empty systemid with warnings.

Add warning messages when empty system ID is set.
---
 lib/commands/toolcontext.c |   13 +++++++++--
 tools/toollib.c            |   10 ++++++--
 tools/vgchange.c           |   46 +++++++++++++++++++++++++------------------
 3 files changed, 44 insertions(+), 25 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 7539b4a..c917b0a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -62,6 +62,11 @@ const char *system_id_from_string(struct cmd_context *cmd, const char *str)
 {
 	char *system_id;
 
+	if (!str || !*str) {
+		log_warn("WARNING: Empty system ID supplied.");
+		return "";
+	}
+
 	if (!(system_id = dm_pool_zalloc(cmd->mem, strlen(str) + 1))) {
 		log_warn("WARNING: Failed to allocate system ID.");
 		return NULL;
@@ -109,13 +114,13 @@ static const char *_read_system_id_from_file(struct cmd_context *cmd, const char
 		if (!*start || *start == '#')
 			continue;
 
-		if (system_id) {
+		if (system_id && *system_id) {
 			log_warn("WARNING: Ignoring extra line(s) in system ID file %s.", file);
 			break;
 		}
 
 		/* Remove any comments from end of line */
-		for (end = start; *end; start++)
+		for (end = start; *end; end++)
 			if (*end == '#') {
 				*end = '\0';
 				break;
@@ -445,8 +450,10 @@ static int _init_system_id(struct cmd_context *cmd)
 	if (!strcmp(source, "none"))
 		return 1;
 
-	if ((cmd->system_id = _system_id_from_source(cmd, source)))
+	if ((system_id = _system_id_from_source(cmd, source)) && *system_id) {
+		cmd->system_id = system_id;
 		return 1;
+	}
 
 	/*
 	 * The source failed to resolve a system_id.  In this case allow
diff --git a/tools/toollib.c b/tools/toollib.c
index b8b0bad..628bc55 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -770,9 +770,13 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 
 		/* FIXME Take local/extra_system_ids into account */
 		if (vp_new->system_id && cmd->system_id &&
-		    strcmp(vp_new->system_id, cmd->system_id))
-			log_warn("VG with system ID \"%s\" might become inaccessible as local system ID is \"%s\"",
-				 vp_new->system_id, cmd->system_id);
+		    strcmp(vp_new->system_id, cmd->system_id)) {
+			if (*vp_new->system_id)
+				log_warn("VG with system ID \"%s\" might become inaccessible as local system ID is \"%s\"",
+					 vp_new->system_id, cmd->system_id);
+			else
+				log_warn("WARNING: A VG without a system ID allows concurrent access from other hosts.");
+		}
 	}
 
 	return 1;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 0b78230..8d5b48a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -494,36 +494,44 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 	const char *system_id;
 	const char *system_id_arg_str = arg_str_value(cmd, systemid_ARG, NULL);
 
-	if (!system_id_arg_str || !*system_id_arg_str) {
-		log_error("Invalid system ID supplied: %s", system_id_arg_str);
+	if (!(system_id = system_id_from_string(cmd, system_id_arg_str))) {
+		log_error("Unable to set system ID.");
 		return 0;
 	}
 
-	if (!(system_id = system_id_from_string(cmd, system_id_arg_str)))
-		return_0;
-
 	if (!strcmp(vg->system_id, system_id)) {
 		log_error("Volume Group system ID is already \"%s\"", vg->system_id);
 		return 0;
 	}
 
 	if (cmd->system_id && strcmp(system_id, cmd->system_id)) {
-		if (lvs_in_vg_activated(vg)) {
-			log_error("Logical Volumes in VG %s must be deactivated before system ID can be changed.",
-				  vg->name);
-			return 0;
-		}
+		if (!*system_id) {
+			log_warn("WARNING: Removing the system ID allows concurrent access from other hosts.");
+
+			if (!arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Remove system ID %s on volume group %s? [y/n]: ",
+					  vg->system_id, vg->name) == 'n') {
+				log_error("Volume group \"%s\" system ID not changed.", vg->name);
+				return 0;
+			}
+		} else {
+			if (lvs_in_vg_activated(vg)) {
+				log_error("Logical Volumes in VG %s must be deactivated before system ID can be changed.",
+					  vg->name);
+				return 0;
+			}
 
-		log_warn("WARNING: Requested system ID \"%s\" does not match local system ID \"%s\"",
-			 system_id, cmd->system_id);
-		log_warn("WARNING: Volume group %s might become inaccessible from this machine.",
-			 vg->name);
+			log_warn("WARNING: Requested system ID \"%s\" does not match local system ID \"%s\"",
+				 system_id, cmd->system_id);
+			log_warn("WARNING: Volume group %s might become inaccessible from this machine.",
+				 vg->name);
 
-		if (!arg_count(cmd, yes_ARG) &&
-		    yes_no_prompt("Set foreign system ID %s on volume group %s? [y/n]: ",
-				  system_id, vg->name) == 'n') {
-			log_error("Volume group \"%s\" system ID not changed.", vg->name);
-			return 0;
+			if (!arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Set foreign system ID %s on volume group %s? [y/n]: ",
+					  system_id, vg->name) == 'n') {
+				log_error("Volume group \"%s\" system ID not changed.", vg->name);
+				return 0;
+			}
 		}
 	}
 


