From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 May 2020 14:03:18 +0000 (GMT)
Subject: master - cov: check for deactivation failure
Message-ID: <20200520140318.D12FB395B08C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=33fdeaf3f18c02f13fb20e9a7fe8bf99e8e21cba
Commit:        33fdeaf3f18c02f13fb20e9a7fe8bf99e8e21cba
Parent:        2a304d7a75b572282c288c60497c7c489e7c3cbd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 17:44:03 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 20 15:55:39 2020 +0200

cov: check for deactivation failure

---
 tools/vgchange.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index a10bf1165..58c8ddc84 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -991,8 +991,13 @@ static int _vgchange_locktype_single(struct cmd_context *cmd, const char *vg_nam
 	 * deactivate it.
 	 */
 	if (vg->lock_type && !strcmp(vg->lock_type, "sanlock") &&
-	    (cmd->command->command_enum == vgchange_locktype_CMD))
-		deactivate_lv(cmd, vg->sanlock_lv);
+	    (cmd->command->command_enum == vgchange_locktype_CMD)) {
+		if (!deactivate_lv(cmd, vg->sanlock_lv)) {
+			log_error("Failed to deativate %s.",
+				  display_lvname(vg->sanlock_lv));
+			return ECMD_FAILED;
+		}
+	}
 
 	log_print_unless_silent("Volume group \"%s\" successfully changed", vg->name);
 


