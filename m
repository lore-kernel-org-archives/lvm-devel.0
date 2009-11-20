From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:51 -0500
Subject: [PATCH 11/15] lvm-merge-background-poll-on-lvvgchange
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-12-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

Start background polling of merging stores on:
- lvchange -ay or vgchange -ay.
- lvchange --refresh or vgchange --refresh.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 tools/toollib.c  |   14 +++++++++++++-
 tools/vgchange.c |    3 ++-
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index ada1302..85220eb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1262,6 +1262,18 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 	if (!r)
 		goto_out;
 
+	/*
+	 * check if snapshot merge should be polled
+	 * - unfortunately: even though the dev_manager will clear
+	 *   the lv's merge attributes if a merge is not possible;
+	 *   it is clearing a different instance of the lv (as
+	 *   retrieved with lv_from_lvid)
+	 * - fortunately: polldaemon will immediately shutdown if the
+	 *   origin doesn't have a status with a snapshot percentage
+	 */
+	if (lv_is_origin(lv) && lv->merging_snapshot)
+		lv_spawn_background_polling(cmd, lv);
+
 out:
 	return r;
 }
@@ -1296,7 +1308,7 @@ void lv_spawn_background_polling(struct cmd_context *cmd,
 		pvmove_poll(cmd, pvname, 1);
 	}
 
-	if (lv->status & CONVERTING) {
+	if (lv->status & CONVERTING || lv->merging_snapshot) {
 		log_verbose("Spawning background lvconvert process for %s",
 			lv->name);
 		lvconvert_poll(cmd, lv, 1);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index c1aa5cf..de1f418 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -104,7 +104,8 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 		}
 
 		if (activate != CHANGE_AN && activate != CHANGE_ALN &&
-		    (lv->status & (PVMOVE|CONVERTING)))
+		    (lv->status & (PVMOVE|CONVERTING) ||
+		     lv->merging_snapshot))
 			lv_spawn_background_polling(cmd, lv);
 
 		count++;
-- 
1.6.5.2


