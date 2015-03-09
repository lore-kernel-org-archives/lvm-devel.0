From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Mar 2015 19:05:00 +0000 (UTC)
Subject: master - vgchange: Additional system ID warnings.
Message-ID: <20150309190500.EDFDE60FF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=458b0210d1b4195171992f112aeb3a798d4509a3
Commit:        458b0210d1b4195171992f112aeb3a798d4509a3
Parent:        1334ea214ea1f55173f2ff7e3045cc72a8c4e7c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 9 19:03:11 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 9 19:03:11 2015 +0000

vgchange: Additional system ID warnings.

Also prompt before setting a system ID on a VG when none is set
on the host.
Put quotes round system ID in messages where it could be blank.
---
 tools/vgchange.c |   57 ++++++++++++++++++++++++++++-------------------------
 1 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 36b44a9..88a85d8 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -536,42 +536,45 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	if (!strcmp(vg->system_id, system_id)) {
-		log_error("Volume Group system ID is already %s", vg->system_id);
+		log_error("Volume Group system ID is already \"%s\".", vg->system_id);
 		return 0;
 	}
 
-	if (cmd->system_id && strcmp(system_id, cmd->system_id)) {
-		if (!*system_id) {
-			log_warn("WARNING: Removing the system ID allows unsafe access from other hosts.");
+	if (!*system_id && cmd->system_id && strcmp(system_id, cmd->system_id)) {
+		log_warn("WARNING: Removing the system ID allows unsafe access from other hosts.");
 
-			if (!arg_count(cmd, yes_ARG) &&
-			    yes_no_prompt("Remove system ID %s on volume group %s? [y/n]: ",
-					  vg->system_id, vg->name) == 'n') {
-				log_error("Volume group %s system ID not changed.", vg->name);
-				return 0;
-			}
-		} else {
-			if (lvs_in_vg_activated(vg)) {
-				log_error("Logical Volumes in VG %s must be deactivated before system ID can be changed.",
-					  vg->name);
-				return 0;
-			}
+		if (!arg_count(cmd, yes_ARG) &&
+		    yes_no_prompt("Remove system ID %s from volume group %s? [y/n]: ",
+				  vg->system_id, vg->name) == 'n') {
+			log_error("System ID of volume group %s not changed.", vg->name);
+			return 0;
+		}
+	}
 
-			log_warn("WARNING: Requested system ID %s does not match local system ID %s",
-				 system_id, cmd->system_id);
-			log_warn("WARNING: Volume group %s might become inaccessible from this machine.",
-				 vg->name);
+	if (*system_id && (!cmd->system_id || strcmp(system_id, cmd->system_id))) {
+		if (lvs_in_vg_activated(vg)) {
+			log_error("Logical Volumes in VG %s must be deactivated before system ID can be changed.",
+				  vg->name);
+			return 0;
+		}
 
-			if (!arg_count(cmd, yes_ARG) &&
-			    yes_no_prompt("Set foreign system ID %s on volume group %s? [y/n]: ",
-					  system_id, vg->name) == 'n') {
-				log_error("Volume group %s system ID not changed.", vg->name);
-				return 0;
-			}
+		if (cmd->system_id)
+			log_warn("WARNING: Requested system ID %s does not match local system ID %s.",
+				 system_id, cmd->system_id ? : "");
+		else
+			log_warn("WARNING: No local system ID is set.");
+		log_warn("WARNING: Volume group %s might become inaccessible from this machine.",
+			 vg->name);
+
+		if (!arg_count(cmd, yes_ARG) &&
+		    yes_no_prompt("Set foreign system ID %s on volume group %s? [y/n]: ",
+				  system_id, vg->name) == 'n') {
+			log_error("Volume group %s system ID not changed.", vg->name);
+			return 0;
 		}
 	}
 
-	log_verbose("Changing system ID for VG %s from %s to %s.",
+	log_verbose("Changing system ID for VG %s from \"%s\" to \"%s\".",
 		    vg->name, vg->system_id, system_id);
 
 	vg->system_id = system_id;


