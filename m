From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 20 May 2015 17:48:13 +0000 (UTC)
Subject: master - lvmetad: Set up lvmcache & PV structs for outdated_pvs.
Message-ID: <20150520174813.EB5E560188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8d00e068762d0ebd7dd489d45c43927b7ffdc58
Commit:        e8d00e068762d0ebd7dd489d45c43927b7ffdc58
Parent:        55f33696928728e60f15dc7a557e55bf910dabdd
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 29 15:01:20 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed May 20 19:46:14 2015 +0200

lvmetad: Set up lvmcache & PV structs for outdated_pvs.

---
 lib/cache/lvmetad.c |   43 +++++++++++++++++++++++++++++++------------
 1 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a66f915..68162b6 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -395,6 +395,22 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _pv_update_struct_pv(struct physical_volume *pv, struct format_instance *fid)
+{
+	struct lvmcache_info *info;
+	if ((info = lvmcache_info_from_pvid((const char *)&pv->id, 0))) {
+		pv->label_sector = lvmcache_get_label(info)->sector;
+		pv->dev = lvmcache_device(info);
+		if (!pv->dev)
+			pv->status |= MISSING_PV;
+		if (!lvmcache_fid_add_mdas_pv(info, fid))
+			return_0;
+                pv->fid = fid;
+	} else
+		pv->status |= MISSING_PV; /* probably missing */
+	return 1;
+}
+
 struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgname, const char *vgid)
 {
 	struct volume_group *vg = NULL;
@@ -409,7 +425,6 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	struct format_type *fmt;
 	struct dm_config_node *pvcn;
 	struct pv_list *pvl;
-	struct lvmcache_info *info;
 
 	if (!lvmetad_active())
 		return NULL;
@@ -460,22 +475,26 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 			for (pvcn = pvcn->child; pvcn; pvcn = pvcn->sib)
 				_pv_populate_lvmcache(cmd, pvcn, fmt, 0);
 
+		if ((pvcn = dm_config_find_node(top, "metadata/outdated_pvs")))
+			for (pvcn = pvcn->child; pvcn; pvcn = pvcn->sib)
+				_pv_populate_lvmcache(cmd, pvcn, fmt, 0);
+
 		top->key = name;
 		if (!(vg = import_vg_from_config_tree(reply.cft, fid)))
 			goto_out;
 
 		dm_list_iterate_items(pvl, &vg->pvs) {
-			if ((info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0))) {
-				pvl->pv->label_sector = lvmcache_get_label(info)->sector;
-				pvl->pv->dev = lvmcache_device(info);
-				if (!pvl->pv->dev)
-					pvl->pv->status |= MISSING_PV;
-				if (!lvmcache_fid_add_mdas_pv(info, fid)) {
-					vg = NULL;
-					goto_out;	/* FIXME error path */
-				}
-			} else
-				pvl->pv->status |= MISSING_PV; /* probably missing */
+			if (!_pv_update_struct_pv(pvl->pv, fid)) {
+				vg = NULL;
+				goto_out;	/* FIXME error path */
+			}
+		}
+
+		dm_list_iterate_items(pvl, &vg->pvs_outdated) {
+			if (!_pv_update_struct_pv(pvl->pv, fid)) {
+				vg = NULL;
+				goto_out;	/* FIXME error path */
+			}
 		}
 
 		lvmcache_update_vg(vg, 0);


