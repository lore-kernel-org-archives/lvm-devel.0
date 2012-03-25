From: Milan Broz <mbroz@redhat.com>
Date: Sun, 25 Mar 2012 22:56:06 +0200
Subject: [PATCH 4/4] Keep exclusive activation in pvmove if LV is already active.
In-Reply-To: <cover.1332708600.git.mbroz@redhat.com>
References: <cover.1332708600.git.mbroz@redhat.com>
Message-ID: <544ffe1d194519a28038b0c6c01062dc8a4039ca.1332708600.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Pvmove should never try to downgrade exclusive lock
for LVs.

This allows pvmove to work again for exclusive activated LVs.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW             |    1 +
 lib/locking/locking.c |    2 +-
 tools/pvmove.c        |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 13cb12d..eb5f53b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Keep exclusive activation in pvmove if LV is already active.
   Disallow pvmove for exclusive LV if some affected LVs are not exclusively activated.
   Remove unused and wrongly set cluster VG flag from clvmd lock query command.
   Fix pvmove for exclusively activated LV pvmove in clustered VG. (2.02.86)
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 1b4e0ac..228078a 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -574,7 +574,7 @@ int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusiv
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, lvs) {
-		if (!exclusive) {
+		if (!exclusive && !lv_is_active_exclusive(lvl->lv)) {
 			if (!activate_lv(cmd, lvl->lv)) {
 				log_error("Failed to activate %s", lvl->lv->name);
 				return 0;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index a6bcfc3..4573dbd 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -296,7 +296,7 @@ static int _activate_lv(struct cmd_context *cmd, struct logical_volume *lv_mirr,
 {
 	int r = 0;
 
-	if (exclusive)
+	if (exclusive || lv_is_active_exclusive(lv_mirr))
 		r = activate_lv_excl(cmd, lv_mirr);
 	else
 		r = activate_lv(cmd, lv_mirr);
-- 
1.7.9.1


