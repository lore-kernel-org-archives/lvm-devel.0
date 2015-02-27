From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 27 Feb 2015 19:42:19 +0000 (UTC)
Subject: master - system_id: apply consistent naming
Message-ID: <20150227194219.891C861219@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c32efc7f7ed9fa3257e667cd8b70d8a5c8379b4b
Commit:        c32efc7f7ed9fa3257e667cd8b70d8a5c8379b4b
Parent:        e09f8a82f19dde6ab56a678e7ba289a658445080
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 27 13:32:00 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 27 13:32:00 2015 -0600

system_id: apply consistent naming

In log messages refer to it as system ID (not System ID).

Do not put quotes around the system_id string when printing.

On the command line use systemid.

In code, metadata, and config files use system_id.

In lvmsystemid refer to the concept/entity as system_id.
---
 lib/commands/toolcontext.c |    4 ++--
 lib/metadata/metadata.c    |    8 ++++----
 lib/metadata/vg.c          |    2 +-
 man/lvmsystemid.7.in       |    2 +-
 tools/lvmcmdline.c         |    4 ++--
 tools/pvscan.c             |    2 +-
 tools/toollib.c            |    6 +++---
 tools/vgchange.c           |   10 +++++-----
 8 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1936ea7..25d9826 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -80,7 +80,7 @@ const char *system_id_from_string(struct cmd_context *cmd, const char *str)
 	}
 
 	if (!strncmp(system_id, "localhost", 9)) {
-		log_warn("WARNING: System ID may not begin with the string \"localhost\".");
+		log_warn("WARNING: system ID may not begin with the string \"localhost\".");
 		return NULL;
 	}
 
@@ -459,7 +459,7 @@ static int _init_system_id(struct cmd_context *cmd)
 	 * The source failed to resolve a system_id.  In this case allow
 	 * VGs with no system_id to be accessed, but not VGs with a system_id.
 	 */
-	log_warn("WARNING: No system ID found from system_id_source \"%s\".", source);
+	log_warn("WARNING: No system ID found from system_id_source %s.", source);
 	cmd->unknown_system_id = 1;
 
 	return 1;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5ae3780..68651f5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4383,7 +4383,7 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	 * LVM1 VGs must not be accessed if a new-style LVM2 system ID is set.
 	 */
 	if (cmd->system_id && systemid_on_pvs(vg)) {
-		log_error("Cannot access VG %s with LVM1 system ID \"%s\" when host system ID is set.",
+		log_error("Cannot access VG %s with LVM1 system ID %s when host system ID is set.",
 			  vg->name, vg->lvm1_system_id);
 		return 0;
 	}
@@ -4416,7 +4416,7 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	 * Allow VG access if the local host has active LVs in it.
 	 */
 	if (lvs_in_vg_activated(vg)) {
-		log_warn("WARNING: Found LVs active in VG %s with foreign system ID \"%s\".  Possible data corruption.",
+		log_warn("WARNING: Found LVs active in VG %s with foreign system ID %s.  Possible data corruption.",
 			  vg->name, vg->system_id);
 		if (cmd->include_active_foreign_vgs)
 			return 1;
@@ -4427,7 +4427,7 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	 * A host without a system_id cannot access a VG with a system_id.
 	 */
 	if (!cmd->system_id || cmd->unknown_system_id) {
-		log_error("Cannot access VG %s with system id \"%s\" with unknown local system ID.",
+		log_error("Cannot access VG %s with system ID %s with unknown local system ID.",
 			  vg->name, vg->system_id);
 		return 0;
 	}
@@ -4436,7 +4436,7 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	 * Some commands always produce an error when accessing foreign VG.
 	 */
 	if (cmd->error_foreign_vgs) {
-		log_error("Cannot access VG %s with system id \"%s\" with local system ID %s.",
+		log_error("Cannot access VG %s with system ID %s with local system ID %s.",
 			  vg->name, vg->system_id, cmd->system_id);
 		return 0;
 	}
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 0143b7b..446aa7c 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -611,7 +611,7 @@ int vg_set_system_id(struct volume_group *vg, const char *system_id)
 	}
 
 	if (systemid_on_pvs(vg)) {
-		log_error("Metadata format %s does not support this type of system id.",
+		log_error("Metadata format %s does not support this type of system ID.",
 			  vg->fid->fmt->name);
 		return 0;
 	}
diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index 42eee31..c5e69be 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -1,7 +1,7 @@
 .TH "LVMSYSTEMID" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 
 .SH NAME
-lvmsystemid \(em LVM system id
+lvmsystemid \(em LVM system ID
 
 .SH DESCRIPTION
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 255fa41..f9acd60 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -981,7 +981,7 @@ int systemid(struct cmd_context *cmd __attribute__((unused)),
 	     int argc __attribute__((unused)),
 	     char **argv __attribute__((unused)))
 {
-	log_print("System ID: %s", cmd->system_id ? : "");
+	log_print("system ID: %s", cmd->system_id ? : "");
 
 	return ECMD_PROCESSED;
 }
@@ -1468,7 +1468,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	init_dmeventd_monitor(monitoring);
 
 	log_debug("Processing: %s", cmd->cmd_line);
-	log_debug("System ID: %s", cmd->system_id ? : "");
+	log_debug("system ID: %s", cmd->system_id ? : "");
 
 #ifdef O_DIRECT_SUPPORT
 	log_debug("O_DIRECT will be used");
diff --git a/tools/pvscan.c b/tools/pvscan.c
index a04a4b2..5709172 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -43,7 +43,7 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 		/* pv_show(pv); */
 
 		/* FIXME - Moved to Volume Group structure */
-		/* log_print("System Id             %s", pv->vg->system_id); */
+		/* log_print("system ID             %s", pv->vg->system_id); */
 
 		/* log_print(" "); */
 		/* return; */
diff --git a/tools/toollib.c b/tools/toollib.c
index 7d1c380..19c23fe 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -200,7 +200,7 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 	 */
 	if (read_error & FAILED_SYSTEMID) {
 		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
-			log_error("Cannot access VG %s with system id \"%s\" with local system ID %s.",
+			log_error("Cannot access VG %s with system ID %s with local system ID %s.",
 				  vg->name, vg->system_id, vg->cmd->system_id);
 			return 1;
 		} else {
@@ -758,7 +758,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	/* A clustered VG has no system ID. */
 	if (vp_new->clustered) {
 		if (arg_is_set(cmd, systemid_ARG)) {
-			log_error("System ID cannot be set on clustered Volume Groups.");
+			log_error("system ID cannot be set on clustered Volume Groups.");
 			return 0;
 		}
 		vp_new->system_id = NULL;
@@ -772,7 +772,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		if (vp_new->system_id && cmd->system_id &&
 		    strcmp(vp_new->system_id, cmd->system_id)) {
 			if (*vp_new->system_id)
-				log_warn("VG with system ID \"%s\" might become inaccessible as local system ID is \"%s\"",
+				log_warn("VG with system ID %s might become inaccessible as local system ID is %s",
 					 vp_new->system_id, cmd->system_id);
 			else
 				log_warn("WARNING: A VG without a system ID allows unsafe access from other hosts.");
diff --git a/tools/vgchange.c b/tools/vgchange.c
index bf3d97d..199ee82 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -516,7 +516,7 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	if (!strcmp(vg->system_id, system_id)) {
-		log_error("Volume Group system ID is already \"%s\"", vg->system_id);
+		log_error("Volume Group system ID is already %s", vg->system_id);
 		return 0;
 	}
 
@@ -527,7 +527,7 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 			if (!arg_count(cmd, yes_ARG) &&
 			    yes_no_prompt("Remove system ID %s on volume group %s? [y/n]: ",
 					  vg->system_id, vg->name) == 'n') {
-				log_error("Volume group \"%s\" system ID not changed.", vg->name);
+				log_error("Volume group %s system ID not changed.", vg->name);
 				return 0;
 			}
 		} else {
@@ -537,7 +537,7 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 				return 0;
 			}
 
-			log_warn("WARNING: Requested system ID \"%s\" does not match local system ID \"%s\"",
+			log_warn("WARNING: Requested system ID %s does not match local system ID %s",
 				 system_id, cmd->system_id);
 			log_warn("WARNING: Volume group %s might become inaccessible from this machine.",
 				 vg->name);
@@ -545,13 +545,13 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 			if (!arg_count(cmd, yes_ARG) &&
 			    yes_no_prompt("Set foreign system ID %s on volume group %s? [y/n]: ",
 					  system_id, vg->name) == 'n') {
-				log_error("Volume group \"%s\" system ID not changed.", vg->name);
+				log_error("Volume group %s system ID not changed.", vg->name);
 				return 0;
 			}
 		}
 	}
 
-	log_verbose("Changing system ID for VG %s: %s -> %s.",
+	log_verbose("Changing system ID for VG %s from %s to %s.",
 		    vg->name, vg->system_id, system_id);
 
 	vg->system_id = system_id;


