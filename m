From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 14 Apr 2016 22:43:09 +0000 (UTC)
Subject: master - activation: Log when pending snap merge postponed.
Message-ID: <20160414224309.4C64E61C20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=150cff9cce019e3211d99dbdceaccf77db1e503a
Commit:        150cff9cce019e3211d99dbdceaccf77db1e503a
Parent:        7ae5f6fc5c300413e740d4fa537090f0a4be5d2c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 14 23:42:56 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 14 23:42:56 2016 +0100

activation: Log when pending snap merge postponed.

---
 lib/activate/dev_manager.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a0e05ad..d25c07e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2700,8 +2700,10 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		     dinfo->open_count)) {
 			if (seg_is_thin_volume(seg) ||
 			    /* FIXME Is there anything simpler to check for instead? */
-			    !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))
+			    !lv_has_target_type(dm->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE)) {
+				log_debug_activation("Postponing pending snapshot merge for origin LV %s.", display_lvname(lv));
 				laopts->no_merging = 1;
+			}
 		}
 	}
 


