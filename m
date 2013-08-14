From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 14 Aug 2013 20:18:44 +0000 (UTC)
Subject: master - lvm2app: lvm_list_pvs_free seg. fault when no PVs
Message-ID: <20130814201844.6351760623@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c29c64f20dadbd9076d8729bd3d0cb724c4b39b0
Commit:        c29c64f20dadbd9076d8729bd3d0cb724c4b39b0
Parent:        732e609fe2e337fa7f4c2b3308d0bc6187269947
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 14 15:14:42 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Aug 14 15:17:39 2013 -0500

lvm2app: lvm_list_pvs_free seg. fault when no PVs

When the system has no PVs we don't have access to
the cmd pointer and it remains NULL which causes
a seg. fault when we try to free the VG lock.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_pv.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 2bd0ac0..e67e1eb 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -65,6 +65,7 @@ struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
 struct lvm_list_wrapper
 {
 	unsigned long magic;
+	struct cmd_context *cmd;
 	struct dm_list pvslist;
 	struct dm_list vgslist;
 };
@@ -84,6 +85,11 @@ struct dm_list *lvm_list_pvs(lvm_t libh)
 	struct lvm_list_wrapper *rc = NULL;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
 
+	/*
+	 * This memory will get cleared when the library handle
+	 * gets closed, don't try to free is as it doesn't work
+	 * like malloc/free do.
+	 */
 	if (!(rc = dm_pool_zalloc(cmd->mem, sizeof(*rc)))) {
 		log_errno(ENOMEM, "Memory allocation fail for pv list.");
 		return NULL;
@@ -95,9 +101,14 @@ struct dm_list *lvm_list_pvs(lvm_t libh)
 		dm_list_init(&rc->pvslist);
 		dm_list_init(&rc->vgslist);
 		if( !get_pvs_perserve_vg(cmd, &rc->pvslist, &rc->vgslist) ) {
-			dm_pool_free(cmd->mem, rc);
 			return NULL;
 		}
+
+		/*
+		 * If we have no PVs we still need to have access to cmd
+		 * pointer in the free call.
+		 */
+		rc->cmd = cmd;
 		rc->magic = 0xF005BA11;
 	}
 
@@ -109,7 +120,6 @@ int lvm_list_pvs_free(struct dm_list *pvlist)
 	struct lvm_list_wrapper *to_delete;
 	struct vg_list *vgl;
 	struct pv_list *pvl;
-	struct cmd_context *cmd = NULL;
 
 	if (pvlist) {
 		to_delete = dm_list_struct_base(pvlist, struct lvm_list_wrapper, pvslist);
@@ -119,17 +129,14 @@ int lvm_list_pvs_free(struct dm_list *pvlist)
 		}
 
 		dm_list_iterate_items(vgl, &to_delete->vgslist) {
-			cmd = vgl->vg->cmd;
 			release_vg(vgl->vg);
 		}
 
 		dm_list_iterate_items(pvl, &to_delete->pvslist)
 			free_pv_fid(pvl->pv);
 
-		unlock_vg(cmd, VG_GLOBAL);
-
+		unlock_vg(to_delete->cmd, VG_GLOBAL);
 		to_delete->magic = 0xA5A5A5A5;
-		dm_pool_free(cmd->mem, to_delete);
 	}
 
 	return 0;


