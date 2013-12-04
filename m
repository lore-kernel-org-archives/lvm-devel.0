From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:50 +0000 (UTC)
Subject: master - thin: activation of merging thin snapshot
Message-ID: <20131204133150.22FB460FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=971ab733b74e0ffecc3f9f60af48628cd3fba1db
Commit:        971ab733b74e0ffecc3f9f60af48628cd3fba1db
Parent:        ff112eee181748dbf827d91a7ebf0c0f1d7878a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 21:25:58 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:26 2013 +0100

thin: activation of merging thin snapshot

For merging thin snapshot we have to do couple extra
checks before we allow this operation.

We pretend  thin-snapshot and thin-origin
are tied together and we have to properly
maintain locking.
---
 tools/toollib.c |   30 +++++++++++++++++++++++++++++-
 1 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 183d832..65a7089 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1403,6 +1403,34 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		       activation_change_t activate)
 {
+	int r = 1;
+
+	if (lv_is_merging_origin(lv)) {
+		/*
+		 * For merging origin, its snapshot must be inactive.
+		 * If it's still active and cannot be deactivated
+		 * activation or deactivation of origin fails!
+		 *
+		 * When origin is deactivated and merging snapshot is thin
+		 * it allows to deactivate origin, but still report error,
+		 * since the thin snapshot remains active.
+		 *
+		 * User could retry to deactivate it with another
+		 * deactivation of origin, which is the only visible LV
+		 */
+		if (!deactivate_lv(cmd, find_snapshot(lv)->lv)) {
+			if ((activate != CHANGE_AN) && (activate != CHANGE_ALN)) {
+				log_error("Refusing to activate merging \"%s\" while snapshot \"%s\" is still active.",
+					  lv->name, find_snapshot(lv)->lv->name);
+				return 0;
+			}
+
+			log_error("Cannot fully deactivate merging origin \"%s\" while snapshot \"%s\" is still active.",
+				  lv->name, find_snapshot(lv)->lv->name);
+			r = 0; /* and continue to deactivate origin... */
+		}
+	}
+
 	if (!lv_active_change(cmd, lv, activate))
 		return_0;
 
@@ -1412,7 +1440,7 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 	    (lv->status & (PVMOVE|CONVERTING|MERGING)))
 		lv_spawn_background_polling(cmd, lv);
 
-	return 1;
+	return r;
 }
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)


