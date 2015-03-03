From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  3 Mar 2015 22:45:56 +0000 (UTC)
Subject: master - lvchange, vgchange: fix the system_id check
Message-ID: <20150303224556.7691C60ECD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24774959221ab75038c336074470108a0727e672
Commit:        24774959221ab75038c336074470108a0727e672
Parent:        cccc2b2980f8321e5f8c8b553f50966f7e1b5abc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 3 16:45:16 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 3 16:45:16 2015 -0600

lvchange, vgchange: fix the system_id check

The check for matching system_id needs to check
that the system_id is not blank.
---
 tools/lvchange.c |    3 ++-
 tools/vgchange.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index bf7e356..0351e4e 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -191,7 +191,8 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 	 * a foreign VG, which allows the VG to be accessed by lvchange -a
 	 * so the LV can be deactivated.
 	 */
-	if (lv->vg->system_id && cmd->system_id &&
+	if (lv->vg->system_id && lv->vg->system_id[0] &&
+	    cmd->system_id && cmd->system_id[0] &&
 	    strcmp(lv->vg->system_id, cmd->system_id) &&
 	    is_change_activating(activate)) {
 		log_error("Cannot activate LVs in a foreign VG.");
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 38a129f..8371310 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -201,7 +201,8 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 	 * a foreign VG, which allows the VG to be accessed by vgchange -a
 	 * so the LV can be deactivated.
 	 */
-	if (vg->system_id && cmd->system_id &&
+	if (vg->system_id && vg->system_id[0] &&
+	    cmd->system_id && cmd->system_id[0] &&
 	    strcmp(vg->system_id, cmd->system_id) &&
 	    is_change_activating(activate)) {
 		log_error("Cannot activate LVs in a foreign VG.");


