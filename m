From: David Teigland <teigland@sourceware.org>
Date: Fri, 1 Jun 2018 14:16:05 -0400
Subject: master - lvmlockd: clarify lock_type use for coverity
Message-ID: <201806011816.w51IG5Se002037@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09177b53dddadf89f976ad72ec293c61d0eee9ba
Commit:        09177b53dddadf89f976ad72ec293c61d0eee9ba
Parent:        b6f0f20da25ac4ab6b5294129fd2f383bf818062
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 1 10:12:04 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 1 13:15:22 2018 -0500

lvmlockd: clarify lock_type use for coverity

Make it clearer when vg->lock_type will be used so
coverity doesn't worry about it.
---
 lib/metadata/metadata.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6525cf9..1bbea19 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2929,13 +2929,15 @@ int vg_write(struct volume_group *vg)
 	struct lv_list *lvl;
 	int revert = 0, wrote = 0;
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lvl->lv->lock_args && !strcmp(lvl->lv->lock_args, "pending")) {
-			if (!lockd_init_lv_args(vg->cmd, vg, lvl->lv, vg->lock_type, &lvl->lv->lock_args)) {
-				log_error("Cannot allocate lock for new LV.");
-				return 0;
+	if (vg_is_shared(vg)) {
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			if (lvl->lv->lock_args && !strcmp(lvl->lv->lock_args, "pending")) {
+				if (!lockd_init_lv_args(vg->cmd, vg, lvl->lv, vg->lock_type, &lvl->lv->lock_args)) {
+					log_error("Cannot allocate lock for new LV.");
+					return 0;
+				}
+				lvl->lv->new_lock_args = 1;
 			}
-			lvl->lv->new_lock_args = 1;
 		}
 	}
 


