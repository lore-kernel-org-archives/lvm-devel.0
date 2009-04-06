From: Milan Broz <mbroz@redhat.com>
Date: Mon, 06 Apr 2009 10:31:30 +0200
Subject: [PATCH] fix pv copy function and add pv list copy helper
Message-ID: <49D9BDE2.9000101@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Properly copy the whole pv structure for later use.

The all_pvs list, used in vg_read, should make its own private
copy of pv structures, otherwise (when vg will use its own pool)
it will point to released memory pool.
The same applies for get_pvs() call.

Patch adds pv_list copy helper and adds explicit memory pool
parameter into _copy_pv.

(Please note that all these helper functions cannot guarantee that
vg related fields are valid - proper vg read & lock must be used
if hti is requested.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |   51 +++++++++++++++++++++++++++++++++++------------
 1 files changed, 38 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c90de6f..9824eff 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -198,11 +198,10 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	return 1;
 }
 
-static int _copy_pv(struct physical_volume *pv_to,
+static int _copy_pv(struct dm_pool *pvmem,
+		    struct physical_volume *pv_to,
 		    struct physical_volume *pv_from)
 {
-	struct dm_pool *pvmem = pv_from->fmt->cmd->mem;
-
 	memcpy(pv_to, pv_from, sizeof(*pv_to));
 
 	if (!(pv_to->vg_name = dm_pool_strdup(pvmem, pv_from->vg_name)))
@@ -217,6 +216,25 @@ static int _copy_pv(struct physical_volume *pv_to,
 	return 1;
 }
 
+static struct pv_list *_copy_pvl(struct dm_pool *pvmem, struct pv_list *pvl_from)
+{
+	struct pv_list *pvl_to = NULL;
+
+	if (!(pvl_to = dm_pool_zalloc(pvmem, sizeof(*pvl_to))))
+		return_NULL;
+
+	if (!(pvl_to->pv = dm_pool_alloc(pvmem, sizeof(*pvl_to->pv))))
+		goto_bad;
+
+	if(!_copy_pv(pvmem, pvl_to->pv, pvl_from->pv))
+		goto_bad;
+
+	return pvl_to;
+bad:
+	dm_pool_free(pvmem, pvl_to);
+	return NULL;
+}
+
 int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 			 const char *vgid, const char *pvid,
 			 struct physical_volume *pv)
@@ -237,7 +255,7 @@ int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
-			if (!_copy_pv(pv, pvl->pv)) {
+			if (!_copy_pv(fmt->cmd->mem, pv, pvl->pv)) {
 				log_error("internal PV duplication failed");
 				return_0;
 			}
@@ -1669,7 +1687,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	return vg;
 }
 
-static int _update_pv_list(struct dm_list *all_pvs, struct volume_group *vg)
+static int _update_pv_list(struct dm_pool *pvmem, struct dm_list *all_pvs, struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
 
@@ -1678,13 +1696,15 @@ static int _update_pv_list(struct dm_list *all_pvs, struct volume_group *vg)
 			if (pvl->pv->dev == pvl2->pv->dev)
 				goto next_pv;
 		}
-		/* PV is not on list so add it.  Note that we don't copy it. */
-       		if (!(pvl2 = dm_pool_zalloc(vg->cmd->mem, sizeof(*pvl2)))) {
+
+		/*
+		 * PV is not on list so add it.
+		 */
+		if (!(pvl2 = _copy_pvl(pvmem, pvl))) {
 			log_error("pv_list allocation for '%s' failed",
 				  pv_dev_name(pvl->pv));
 			return 0;
 		}
-		pvl2->pv = pvl->pv;
 		dm_list_add(all_pvs, &pvl2->list);
   next_pv:
 		;
@@ -1899,7 +1919,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			}
 			if (!correct_vg) {
 				correct_vg = vg;
-				if (!_update_pv_list(&all_pvs, correct_vg))
+				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg))
 					return_NULL;
 				continue;
 			}
@@ -1913,7 +1933,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			/* FIXME Also ensure contents same - checksums same? */
 			if (correct_vg->seqno != vg->seqno) {
 				inconsistent = 1;
-				if (!_update_pv_list(&all_pvs, vg))
+				if (!_update_pv_list(cmd->mem, &all_pvs, vg))
 					return_NULL;
 				if (vg->seqno > correct_vg->seqno)
 					correct_vg = vg;
@@ -2203,7 +2223,7 @@ static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
 	struct str_list *strl;
 	struct dm_list * uninitialized_var(results);
 	const char *vgname, *vgid;
-	struct dm_list *pvh, *tmp;
+	struct pv_list *pvl, *pvl_copy;
 	struct dm_list *vgids;
 	struct volume_group *vg;
 	int consistent = 0;
@@ -2249,8 +2269,13 @@ static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
 
 		/* Move PVs onto results list */
 		if (pvslist)
-			dm_list_iterate_safe(pvh, tmp, &vg->pvs)
-				dm_list_add(results, pvh);
+			dm_list_iterate_items(pvl, &vg->pvs) {
+				if (!(pvl_copy = _copy_pvl(cmd->mem, pvl))) {
+					log_error("PV list allocation failed");
+					return 0;
+				}
+				dm_list_add(results, &pvl_copy->list);
+			}
 	}
 	init_pvmove(old_pvmove);
 



