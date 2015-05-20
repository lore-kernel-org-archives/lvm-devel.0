From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 20 May 2015 17:48:11 +0000 (UTC)
Subject: master - lvmetad: Provide entire pvmeta sections for outdated_pvs.
Message-ID: <20150520174811.D021860188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55f33696928728e60f15dc7a557e55bf910dabdd
Commit:        55f33696928728e60f15dc7a557e55bf910dabdd
Parent:        611c8b6d29ca164a22270cb9b3dcf7958063c712
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 29 15:00:28 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed May 20 19:46:14 2015 +0200

lvmetad: Provide entire pvmeta sections for outdated_pvs.

---
 daemons/lvmetad/lvmetad-core.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 40cf7d4..449e332 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -470,13 +470,29 @@ static void mark_outdated_pv(lvmetad_state *s, const char *vgid, const char *pvi
 	list->v = v;
 }
 
-static void chain_outdated_pvs(lvmetad_state *s, const char *vgid, struct dm_config_tree *metadata, struct dm_config_node *last)
+static void chain_outdated_pvs(lvmetad_state *s, const char *vgid, struct dm_config_tree *metadata_cft, struct dm_config_node *metadata)
 {
-	struct dm_config_tree *cft = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
-	if (!cft)
-		return; /* nothing to chain in */
-	last->sib = dm_config_clone_node(metadata, dm_config_find_node(cft->root, "outdated_pvs/pv_list"), 0);
-	last->sib->key = "outdated_pvs";
+	struct dm_config_tree *cft = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid), *pvmeta;
+	struct dm_config_node *pv, *res, *pvs = cft ? dm_config_find_node(cft->root, "outdated_pvs/pv_list") : NULL;
+	struct dm_config_value *pvs_v = pvs ? pvs->v : NULL;
+	if (!pvs_v)
+		return;
+	if (!(res = make_config_node(metadata_cft, "outdated_pvs", metadata_cft->root, 0)))
+		return; /* oops */
+	res->sib = metadata->child;
+	metadata->child = res;
+	for (; pvs_v && pvs_v->type != DM_CFG_EMPTY_ARRAY; pvs_v = pvs_v->next) {
+		pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvs_v->v.str);
+		if (!pvmeta) {
+			WARN(s, "metadata for PV %s not found", pvs_v->v.str);
+			continue;
+		}
+		if (!(pv = dm_config_clone_node(metadata_cft, pvmeta->root, 0)))
+			continue;
+		pv->key = dm_config_find_str(pv, "pvmeta/id", NULL);
+		pv->sib = res->child;
+		res->child = pv;
+	}
 }
 
 static response vg_lookup(lvmetad_state *s, request r)


