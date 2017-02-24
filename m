From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 24 Feb 2017 20:19:43 +0000 (UTC)
Subject: master - lvconvert: fix handling args in combining snapshots
Message-ID: <20170224201943.0CF2260257@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84cceaf9b9f0f323c78e9818c2b54c97d71b392f
Commit:        84cceaf9b9f0f323c78e9818c2b54c97d71b392f
Parent:        74ba326007205ebbb5afca7c8f74a8b19e9dcb50
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 24 14:17:58 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 24 14:17:58 2017 -0600

lvconvert: fix handling args in combining snapshots

Fixes commit 286d39ee3c433, which was correct except
for a reversed strstr.  Now uses strchr, and modifies
a copy of the name so the original argv is preserved.
---
 tools/lvconvert.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 183421a..c82dab2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3668,8 +3668,9 @@ static int _lvconvert_combine_split_snapshot_single(struct cmd_context *cmd,
 int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *vgname = NULL;
-	const char *lvname1;
-	const char *lvname2;
+	const char *lvname1_orig;
+	const char *lvname2_orig;
+	const char *lvname1_split;
 	char *vglv;
 	int vglv_sz;
 
@@ -3687,20 +3688,25 @@ int lvconvert_combine_split_snapshot_cmd(struct cmd_context *cmd, int argc, char
 	 * This is the only instance in all commands.
 	 */
 
-	lvname1 = cmd->position_argv[0];
-	lvname2 = cmd->position_argv[1];
+	lvname1_orig = cmd->position_argv[0];
+	lvname2_orig = cmd->position_argv[1];
 
-	if (strstr("/", lvname1) && !strstr("/", lvname2) && !getenv("LVM_VG_NAME")) {
-		if (!validate_lvname_param(cmd, &vgname, &lvname1))
+	if (strchr(lvname1_orig, '/') && !strchr(lvname2_orig, '/') && !getenv("LVM_VG_NAME")) {
+		if (!(lvname1_split = dm_pool_strdup(cmd->mem, lvname1_orig)))
 			return_ECMD_FAILED;
 
-		vglv_sz = strlen(vgname) + strlen(lvname2) + 2;
+		if (!validate_lvname_param(cmd, &vgname, &lvname1_split))
+			return_ECMD_FAILED;
+
+		vglv_sz = strlen(vgname) + strlen(lvname2_orig) + 2;
 		if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
-		    dm_snprintf(vglv, vglv_sz, "%s/%s", vgname, lvname2) < 0) {
+		    dm_snprintf(vglv, vglv_sz, "%s/%s", vgname, lvname2_orig) < 0) {
        			log_error("vg/lv string alloc failed.");
 			return_ECMD_FAILED;
 		}
 
+		/* vglv is now vgname/lvname2 and replaces lvname2_orig */
+
 		cmd->position_argv[1] = vglv;
 	}
 


