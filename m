From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Jul 2013 00:51:48 +0000 (UTC)
Subject: master - Revert "lvm2app: lvm_vg_list_lvs filter hidden LVs"
Message-ID: <20130724005148.850B3613F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf09cf0cd398d97e41f406aee5fa6b07c23a563b
Commit:        cf09cf0cd398d97e41f406aee5fa6b07c23a563b
Parent:        5597dc3652babd9a27064e001d654d5df7297ca7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 24 01:49:18 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 24 01:49:18 2013 +0100

Revert "lvm2app: lvm_vg_list_lvs filter hidden LVs"

This reverts commit a2b51476007aae91acfc121a7fd2ce04f3b08781.

The function has behaved like this for a long time so let's
not change this part of the API.
---
 liblvm/lvm_vg.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index f0da83b..3f4968e 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -250,15 +250,13 @@ struct dm_list *lvm_vg_list_lvs(vg_t vg)
 	dm_list_init(list);
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lv_is_visible(lvl->lv)) {
-			if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
-				log_errno(ENOMEM,
-					"Memory allocation fail for lvm_lv_list.");
-				return NULL;
-			}
-			lvs->lv = lvl->lv;
-			dm_list_add(list, &lvs->list);
+		if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_lv_list.");
+			return NULL;
 		}
+		lvs->lv = lvl->lv;
+		dm_list_add(list, &lvs->list);
 	}
 	return list;
 }


