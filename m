From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 16 Apr 2019 02:27:58 -0400
Subject: stable-2.02 - Wiping require exclusive actvation
Message-ID: <201904160627.x3G6RwWW000439@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5d1f4f086f75148e25f7fda28bf2166e0c5a162
Commit:        f5d1f4f086f75148e25f7fda28bf2166e0c5a162
Parent:        699bf8609049058875d84f129d508d4ccbed3900
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Apr 15 20:39:23 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Apr 16 08:26:34 2019 +0200

Wiping require exclusive actvation

The master branch uses activate_lv only, but on the stable branch
activate_lv_excl_local was used. This patch restores the constraints.

Fix regression from bad cherry pick: 9b04851fc574ce9cffd30a51d2b750955239f316
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d039686..e72a1c9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7240,9 +7240,9 @@ int activate_and_wipe_lvlist(struct dm_list *lv_list, int commit)
 	was_active = alloca(sz);
 
 	dm_list_iterate_items(lvl, lv_list)
-		if (!(was_active[i++] = lv_is_active(lvl->lv))) {
+		if (!(was_active[i++] = lv_is_active_locally(lvl->lv))) {
 			lvl->lv->status |= LV_TEMPORARY;
-			if (!activate_lv(vg->cmd, lvl->lv)) {
+			if (!activate_lv_excl_local(vg->cmd, lvl->lv)) {
 				log_error("Failed to activate localy %s for wiping.",
 					  display_lvname(lvl->lv));
 				r = 0;


