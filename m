From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 23 Jul 2013 19:03:05 +0000 (UTC)
Subject: master - lvm2app: lvm_vg_list_lvs filter hidden LVs
Message-ID: <20130723190305.9850E60D4C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2b51476007aae91acfc121a7fd2ce04f3b08781
Commit:        a2b51476007aae91acfc121a7fd2ce04f3b08781
Parent:        31de670318c9794690601468def392cd7e4eb0fc
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jul 23 14:57:53 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 23 14:01:20 2013 -0500

lvm2app: lvm_vg_list_lvs filter hidden LVs

The function lvm_vg_list_lvs was returning all logical
volumes, including *_tmeta and *_tdata.  Added check
to verify that LV is visible before including in list
of returned logical volumes.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_vg.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 3f4968e..f0da83b 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -250,13 +250,15 @@ struct dm_list *lvm_vg_list_lvs(vg_t vg)
 	dm_list_init(list);
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
-			log_errno(ENOMEM,
-				"Memory allocation fail for lvm_lv_list.");
-			return NULL;
+		if (lv_is_visible(lvl->lv)) {
+			if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
+				log_errno(ENOMEM,
+					"Memory allocation fail for lvm_lv_list.");
+				return NULL;
+			}
+			lvs->lv = lvl->lv;
+			dm_list_add(list, &lvs->list);
 		}
-		lvs->lv = lvl->lv;
-		dm_list_add(list, &lvs->list);
 	}
 	return list;
 }


