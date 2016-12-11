From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:51 +0000 (UTC)
Subject: master - cleanup: reuse existing function
Message-ID: <20161211223451.A20A66038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6cd68c55ddc280bcba72961944d24c6a66da1c18
Commit:        6cd68c55ddc280bcba72961944d24c6a66da1c18
Parent:        6f84d3c69cdc161508fcc29e82f1167334466084
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 11 14:31:47 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

cleanup: reuse existing function

Call lv_update_and_reload implementation.
---
 tools/pvmove_poll.c |   34 ++--------------------------------
 1 files changed, 2 insertions(+), 32 deletions(-)

diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index 2cd746b..438d458 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -83,38 +83,8 @@ int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			   struct dm_list *lvs_changed __attribute__((unused)),
 			   unsigned flags __attribute__((unused)))
 {
-	log_verbose("Updating volume group metadata.");
-	if (!vg_write(vg)) {
-		log_error("ABORTING: Volume group metadata update failed.");
-		return 0;
-	}
-
-	if (!suspend_lv(cmd, lv_mirr)) {
-		vg_revert(vg);
-		log_error("ABORTING: Temporary pvmove mirror reload failed.");
-		if (!revert_lv(cmd, lv_mirr))
-			stack;
-		return 0;
-	}
-
-	/* Commit on-disk metadata */
-	if (!vg_commit(vg)) {
-		log_error("ABORTING: Volume group metadata update failed.");
-		if (!resume_lv(cmd, lv_mirr))
-			log_error("Unable to reactivate logical volume \"%s\".",
-				  lv_mirr->name);
-		if (!revert_lv(cmd, lv_mirr))
-			stack;
-		return 0;
-	}
-
-	if (!resume_lv(cmd, lv_mirr)) {
-		log_error("Unable to reactivate logical volume \"%s\".",
-			  lv_mirr->name);
-		return 0;
-	}
-
-	backup(vg);
+	if (!lv_update_and_reload(lv_mirr))
+		return_0;
 
 	return 1;
 }


