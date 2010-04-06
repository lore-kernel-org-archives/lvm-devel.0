From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  6 Apr 2010 19:53:19 -0400
Subject: [PATCH 4/5] Call add_pvl_to_vgs() and del_pvl_from_vgs() from more places.
In-Reply-To: <1270598000-9771-4-git-send-email-dwysocha@redhat.com>
References: <1270598000-9771-1-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-2-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-3-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1270598000-9771-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Now that we have library functions to add/delete a pv from the vg->pvs
list, call them from everywhere.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_pool/import_export.c |    3 +--
 lib/metadata/metadata.c         |   11 ++++-------
 tools/lvconvert.c               |    3 +--
 tools/vgmerge.c                 |   14 +++++---------
 tools/vgreduce.c                |    4 +---
 5 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index d464364..7e04895 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -119,8 +119,7 @@ int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
 		pl->pv = pvl->pv;
 		pvl->mdas = NULL;
 		pvl->pe_ranges = NULL;
-		vg->pv_count++;
-		dm_list_add(&vg->pvs, &pvl->list);
+		add_pvl_to_vgs(vg, pvl);
 	}
 
 	return 1;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index dd986a1..85fa097 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -338,10 +338,8 @@ int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	    _vg_bad_status_bits(vg_to, RESIZEABLE_VG))
 		return 0;
 
-	dm_list_move(&vg_to->pvs, &pvl->list);
-
-	vg_from->pv_count--;
-	vg_to->pv_count++;
+	del_pvl_from_vgs(vg_from, pvl);
+	add_pvl_to_vgs(vg_to, pvl);
 
 	pv = pvl->pv;
 
@@ -508,7 +506,7 @@ int vg_remove_check(struct volume_group *vg)
 		return 0;
 
 	dm_list_iterate_items_safe(pvl, tpvl, &vg->pvs) {
-		dm_list_del(&pvl->list);
+		del_pvl_from_vgs(vg, pvl);
 		dm_list_add(&vg->removed_pvs, &pvl->list);
 	}
 	return 1;
@@ -2501,8 +2499,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 			goto bad;
 		}
 		pvl->pv = pv;
-		dm_list_add(&vg->pvs, &pvl->list);
-		vg->pv_count++;
+		add_pvl_to_vgs(vg, pvl);
 	}
 
 	return vg;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 35ffac2..57581c8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -736,8 +736,7 @@ static void _remove_missing_empty_pv(struct volume_group *vg, struct dm_list *re
 			/* FIXME: duplication of vgreduce code, move this to library */
 			vg->free_count -= pvl_vg->pv->pe_count;
 			vg->extent_count -= pvl_vg->pv->pe_count;
-			vg->pv_count--;
-			dm_list_del(&pvl_vg->list);
+			del_pvl_from_vgs(vg, pvl_vg);
 
 			removed++;
 		}
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 4a6721d..299bed7 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -31,6 +31,7 @@ static struct volume_group *_vgmerge_vg_read(struct cmd_context *cmd,
 static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 			   const char *vg_name_from)
 {
+	struct pv_list *pvl, *tpvl;
 	struct volume_group *vg_to, *vg_from;
 	struct lv_list *lvl1, *lvl2;
 	int r = ECMD_FAILED;
@@ -82,16 +83,11 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	drop_cached_metadata(vg_from);
 
 	/* Merge volume groups */
-	while (!dm_list_empty(&vg_from->pvs)) {
-		struct dm_list *pvh = vg_from->pvs.n;
-		struct physical_volume *pv;
-
-		dm_list_move(&vg_to->pvs, pvh);
-
-		pv = dm_list_item(pvh, struct pv_list)->pv;
-		pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
+	dm_list_iterate_items_safe(pvl, tpvl, &vg_from->pvs) {
+		del_pvl_from_vgs(vg_from, pvl);
+		add_pvl_to_vgs(vg_to, pvl);
+		pvl->pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
 	}
-	vg_to->pv_count += vg_from->pv_count;
 
 	/* Fix up LVIDs */
 	dm_list_iterate_items(lvl1, &vg_to->lvs) {
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index eb228a3..287db41 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -39,9 +39,7 @@ static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 
 	vg->free_count -= pvl->pv->pe_count;
 	vg->extent_count -= pvl->pv->pe_count;
-	vg->pv_count--;
-
-	dm_list_del(&pvl->list);
+	del_pvl_from_vgs(vg, pvl);
 
 	return 1;
 }
-- 
1.6.0.6


