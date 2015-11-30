From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 30 Nov 2015 17:49:10 +0000 (UTC)
Subject: master - system_id: refactor check for allowed system_id
Message-ID: <20151130174910.16CD5607B9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05ac8367980afb0b660fc312b228337e256a38e8
Commit:        05ac8367980afb0b660fc312b228337e256a38e8
Parent:        d3ca18e489d48cc7c7b2a877b95b5a9a324e8e30
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 11:46:55 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 30 11:46:55 2015 -0600

system_id: refactor check for allowed system_id

Refactor the code that checks for an allowable system_id
so that it can be used from other places.
---
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.c          |   49 ++++++++++++++++++++++++-------------
 2 files changed, 34 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f009687..8242db1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1238,4 +1238,6 @@ int validate_vg_rename_params(struct cmd_context *cmd,
 
 int is_lockd_type(const char *lock_type);
 
+int is_system_id_allowed(struct cmd_context *cmd, const char *system_id);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7ee928d..bf030d3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4854,39 +4854,53 @@ static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg
 	return 1;
 }
 
-static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
+int is_system_id_allowed(struct cmd_context *cmd, const char *system_id)
 {
 	/*
-	 * LVM1 VGs must not be accessed if a new-style LVM2 system ID is set.
+	 * A VG without a system_id can be accessed by anyone.
 	 */
-	if (cmd->system_id && systemid_on_pvs(vg)) {
-		log_error("Cannot access VG %s with LVM1 system ID %s when host system ID is set.",
-			  vg->name, vg->lvm1_system_id);
-		return 0;
-	}
+	if (!system_id || !system_id[0])
+		return 1;
 
 	/*
-	 * A VG without a system_id can be accessed by anyone.
+	 * Allowed if the host and VG system_id's match.
 	 */
-	if (!vg->system_id || !vg->system_id[0])
+	if (cmd->system_id && !strcmp(cmd->system_id, system_id))
 		return 1;
 
 	/*
-	 * A few commands allow read-only access to foreign VGs.
+	 * Allowed if a host's extra system_id matches.
 	 */
-	if (cmd->include_foreign_vgs)
+	if (cmd->system_id && _allow_extra_system_id(cmd, system_id))
 		return 1;
 
 	/*
-	 * A host can access a VG with a matching system_id.
+	 * Not allowed if the host does not have a system_id
+	 * and the VG does, or if the host and VG's system_id's
+	 * do not match.
 	 */
-	if (cmd->system_id && !strcmp(vg->system_id, cmd->system_id))
-		return 1;
 
+	return 0;
+}
+
+static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
+{
 	/*
-	 * A host can access a VG if the VG's system_id is in extra_system_ids list.
+	 * LVM1 VGs must not be accessed if a new-style LVM2 system ID is set.
 	 */
-	if (cmd->system_id && _allow_extra_system_id(cmd, vg->system_id))
+	if (cmd->system_id && systemid_on_pvs(vg)) {
+		log_error("Cannot access VG %s with LVM1 system ID %s when host system ID is set.",
+			  vg->name, vg->lvm1_system_id);
+		return 0;
+	}
+
+	/*
+	 * A few commands allow read-only access to foreign VGs.
+	 */
+	if (cmd->include_foreign_vgs)
+		return 1;
+
+	if (is_system_id_allowed(cmd, vg->system_id))
 		return 1;
 
 	/*
@@ -4901,7 +4915,8 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	/*
-	 * A host without a system_id cannot access a VG with a system_id.
+	 * Print an error when reading a VG that has a system_id
+	 * and the host system_id is unknown.
 	 */
 	if (!cmd->system_id || cmd->unknown_system_id) {
 		log_error("Cannot access VG %s with system ID %s with unknown local system ID.",


