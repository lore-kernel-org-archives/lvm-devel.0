From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:47 +0000 (UTC)
Subject: master - pvmove: fix activation order
Message-ID: <20161211223447.5CA076038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3903f915f83634f91946550fda85d60b72ce3a88
Commit:        3903f915f83634f91946550fda85d60b72ce3a88
Parent:        67f9e6b175815d7a91a10ecc3d5098d30dbfed91
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 11 14:26:17 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:22:36 2016 +0100

pvmove: fix activation order

For proper locking we need to gain lock first for mirror which
needs to be deactivated later to be working in cluster.
---
 WHATS_NEW           |    1 +
 tools/pvmove_poll.c |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 63cdb89..ea15903 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Fix pvmove leaving -pvmove0 error device in clustered VG.
   Avoid adding extra '_' at end of raid extracted images or metadata.
   Optimize another _rmeta clearing code.
   Fix deactivation of raid orphan devices for clustered VG.
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index ea4be24..2cd746b 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -157,17 +157,17 @@ int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
+	/* Unsuspend LVs */
+	if (!resume_lvs(cmd, lvs_changed))
+		stack;
+
 	/* Release mirror LV.  (No pending I/O because it's been suspended.) */
-	if (!resume_lv(cmd, lv_mirr)) {
+	if (!activate_lv_excl_local(cmd, lv_mirr)) {
 		log_error("Unable to reactivate logical volume \"%s\"",
 			  lv_mirr->name);
 		r = 0;
 	}
 
-	/* Unsuspend LVs */
-	if (!resume_lvs(cmd, lvs_changed))
-		stack;
-
 	/* Deactivate mirror LV */
 	if (!deactivate_lv(cmd, lv_mirr)) {
 		log_error("ABORTING: Unable to deactivate temporary logical "


