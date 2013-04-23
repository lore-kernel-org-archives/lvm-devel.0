From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Apr 2013 12:40:28 +0000 (UTC)
Subject: master - raid: remove wrong pool free
Message-ID: <20130423124028.A46EC1ECB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68ef288901820b522e3765e5fbec972ea348e3b7
Commit:        68ef288901820b522e3765e5fbec972ea348e3b7
Parent:        1445d407949735c8fc17c9c0871d39224ef6d716
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 23 14:06:40 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 23 14:06:40 2013 +0200

raid: remove wrong pool free

No, we cannot free pool members here.
---
 tools/lvchange.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index cc3e96b..796e512 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -266,25 +266,19 @@ static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 {
 	struct cmd_context *cmd = seg->lv->vg->cmd;
-	struct lv_list *lvl, *tmp;
+	struct lv_list *lvl;
 
 	if (seg_is_raid(seg)) {
-		dm_list_iterate_items_safe(lvl, tmp, list) {
+		dm_list_iterate_items(lvl, list)
 			lv_set_hidden(lvl->lv);
-			dm_pool_free(cmd->mem, lvl);
-		}
 		return 1;
 	}
 
 	dm_list_iterate_items(lvl, list)
 		break;  /* get first item */
 
-	if (!attach_mirror_log(seg, lvl->lv)) {
-		dm_pool_free(cmd->mem, lvl);
+	if (!attach_mirror_log(seg, lvl->lv))
 		return_0;
-	}
-
-	dm_pool_free(cmd->mem, lvl);
 
 	return 1;
 }


