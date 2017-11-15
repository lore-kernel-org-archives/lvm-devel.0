From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:43 -0500
Subject: master - cleanup: update log messages
Message-ID: <201711151309.vAFD9hXU001957@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9d04ecc7b3574efb1772e84e8796b7044b830220
Commit:        9d04ecc7b3574efb1772e84e8796b7044b830220
Parent:        838592a17119814adc5564569ef431fb0000c639
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 14 11:35:25 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 14:03:22 2017 +0100

cleanup: update log messages

---
 lib/locking/locking.c |    2 +-
 tools/pvmove_poll.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 0426744..acf3327 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -412,7 +412,7 @@ int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs,
 
 	dm_list_iterate_items(lvl, lvs) {
 		if (!suspend_lv(cmd, lvl->lv)) {
-			log_error("Failed to suspend %s", lvl->lv->name);
+			log_error("Failed to suspend %s", display_lvname(lvl->lv));
 			if (vg_to_revert)
 				vg_revert(vg_to_revert);
 			/*
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index 438d458..5bddee4 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -141,7 +141,7 @@ int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 	/* Deactivate mirror LV */
 	if (!deactivate_lv(cmd, lv_mirr)) {
 		log_error("ABORTING: Unable to deactivate temporary logical "
-			  "volume \"%s\"", lv_mirr->name);
+			  "volume %s.", display_lvname(lv_mirr));
 		r = 0;
 	}
 


