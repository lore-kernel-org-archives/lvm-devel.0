From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 16:29:12 -0500
Subject: [PATCH 5/5] lvm-stack-on-activate-and-deactivate-failures
In-Reply-To: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
References: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258752552-1589-5-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add missing 'stack;' for all activate_lv and deactivate_lv callers.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/activate/activate.c |    3 ++-
 lib/locking/locking.c   |    3 ++-
 tools/pvmove.c          |   11 +++++++++--
 tools/vgchange.c        |   20 +++++++++++++++-----
 4 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b3a70db..7256dab 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -710,7 +710,8 @@ int lv_is_active(struct logical_volume *lv)
 	 * FIXME: check status to not deactivate already activate device
 	 */
 	if (activate_lv_excl(lv->vg->cmd, lv)) {
-		deactivate_lv(lv->vg->cmd, lv);
+		if (!deactivate_lv(lv->vg->cmd, lv))
+			stack;
 		return 0;
 	}
 
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index de890b2..8b89b23 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -483,7 +483,8 @@ int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusiv
 			log_error("Failed to activate %s", lvl->lv->name);
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
-				activate_lv(cmd, lvl->lv);
+				if (!activate_lv(cmd, lvl->lv))
+					stack;
 			}
 			return 0;
 		}
diff --git a/tools/pvmove.c b/tools/pvmove.c
index a56e377..0819746 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -261,10 +261,17 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
 			unsigned exclusive)
 {
+	int r = 0;
+
 	if (exclusive)
-		return activate_lv_excl(cmd, lv_mirr);
+		r = activate_lv_excl(cmd, lv_mirr);
+	else
+		r = activate_lv(cmd, lv_mirr);
 
-	return activate_lv(cmd, lv_mirr);
+	if (!r)
+		stack;
+
+	return r;
 }
 
 static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 80ac6e7..c1aa5cf 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -79,19 +79,29 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 			continue;
 
 		if (activate == CHANGE_AN) {
-			if (!deactivate_lv(cmd, lv))
+			if (!deactivate_lv(cmd, lv)) {
+				stack;
 				continue;
+			}
 		} else if (activate == CHANGE_ALN) {
-			if (!deactivate_lv_local(cmd, lv))
+			if (!deactivate_lv_local(cmd, lv)) {
+				stack;
 				continue;
+			}
 		} else if (lv_is_origin(lv) || (activate == CHANGE_AE)) {
-			if (!activate_lv_excl(cmd, lv))
+			if (!activate_lv_excl(cmd, lv)) {
+				stack;
 				continue;
+			}
 		} else if (activate == CHANGE_ALY) {
-			if (!activate_lv_local(cmd, lv))
+			if (!activate_lv_local(cmd, lv)) {
+				stack;
 				continue;
-		} else if (!activate_lv(cmd, lv))
+			}
+		} else if (!activate_lv(cmd, lv)) {
+			stack;
 			continue;
+		}
 
 		if (activate != CHANGE_AN && activate != CHANGE_ALN &&
 		    (lv->status & (PVMOVE|CONVERTING)))
-- 
1.6.5.2


