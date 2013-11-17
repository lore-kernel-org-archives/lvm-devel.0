From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:42 +0000 (UTC)
Subject: master - metadata: Fix handling of orphan PV linking & re-linking.
Message-ID: <20131117222642.03C826103A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba6d6f002837d0fa2f27ad3660cfde7887870401
Commit:        ba6d6f002837d0fa2f27ad3660cfde7887870401
Parent:        651d5093edde3e0ebee9d75be1c9834efc152d91
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Feb 19 03:13:59 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:27 2013 +0100

metadata: Fix handling of orphan PV linking & re-linking.

---
 lib/metadata/metadata.c |   31 ++++++++++++++++++++++++++++---
 1 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b67d596..fa480c8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -269,6 +269,12 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
 
+	dm_list_iterate_items(pvl, &fid->fmt->orphan_vg->pvs)
+		if (pv == pvl->pv) { /* unlink from orphan */
+			dm_list_del(&pvl->list);
+			break;
+		}
+
 	if (pv->status & UNLABELLED_PV) {
 		if (!(pvc = dm_pool_zalloc(mem, sizeof(*pvc)))) {
 			log_error("pv_to_create allocation for '%s' failed", pv_name);
@@ -2810,8 +2816,10 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg = NULL;
 	struct _vg_read_orphan_baton baton;
-	struct pv_list *pvl;
+	struct pv_list *pvl, *pvl_;
+	struct pv_list head;
 
+	dm_list_init(&head.list);
 	lvmcache_label_scan(cmd, 0);
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
@@ -2822,14 +2830,31 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 		return_NULL;
 
 	vg = fmt->orphan_vg;
-	dm_list_iterate_items(pvl, &vg->pvs)
-		pv_set_fid(pvl->pv, NULL);
+restart:
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (pvl->pv->status & UNLABELLED_PV ) {
+			dm_list_del(&pvl->list);
+			dm_list_add(&head.list, &pvl->list);
+			goto restart;
+		} else
+			pv_set_fid(pvl->pv, NULL);
+	}
 	dm_list_init(&vg->pvs);
 	vg->pv_count = 0;
+	vg->extent_count = 0;
+	vg->free_count = 0;
 
 	baton.warnings = warnings;
 	baton.vg = vg;
 
+	while (!dm_list_empty(&head.list)) {
+		pvl = (struct pv_list *) dm_list_first(&head.list);
+		dm_list_del(&pvl->list);
+		add_pvl_to_vgs(vg, pvl);
+		vg->extent_count += pvl->pv->pe_count;
+		vg->free_count += pvl->pv->pe_count;
+	}
+
 	if (!lvmcache_foreach_pv(vginfo, _vg_read_orphan_pv, &baton))
 		return_NULL;
 


