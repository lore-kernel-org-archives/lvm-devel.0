From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:23:48 +0200
Subject: [PATCH 3/9] Tidy format1 import LV function.
In-Reply-To: <cover.1242227458.git.mbroz@redhat.com>
References: <cover.1242227458.git.mbroz@redhat.com>
Message-ID: <91f03ff617d9e2395587dbe395441a6537d4d571.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Later patch initializes lv->vg after the LV structure is prepared,
so pass through cmd context and do not use vg->cmd here.
Also move LV id calculation (which uses lv->vg too).

Also properly free memory pool if operation fails.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format1/disk-rep.h      |    3 ++-
 lib/format1/import-export.c |   13 ++++++++-----
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
index 4a3b31a..138794e 100644
--- a/lib/format1/disk-rep.h
+++ b/lib/format1/disk-rep.h
@@ -215,7 +215,8 @@ int import_vg(struct dm_pool *mem,
 	      struct volume_group *vg, struct disk_list *dl);
 int export_vg(struct vg_disk *vgd, struct volume_group *vg);
 
-int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lvd);
+int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
+	      struct logical_volume *lv, struct lv_disk *lvd);
 
 int import_extents(struct cmd_context *cmd, struct volume_group *vg,
 		   struct dm_list *pvds);
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 56800a2..b32a345 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -294,10 +294,9 @@ int export_vg(struct vg_disk *vgd, struct volume_group *vg)
 	return 1;
 }
 
-int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lvd)
+int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
+	      struct logical_volume *lv, struct lv_disk *lvd)
 {
-	lvid_from_lvnum(&lv->lvid, &lv->vg->id, lvd->lv_number);
-
 	if (!(lv->name = _create_lv_name(mem, (char *)lvd->lv_name)))
 		return_0;
 
@@ -331,7 +330,7 @@ int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lv
 		lv->alloc = ALLOC_NORMAL;
 
 	if (!lvd->lv_read_ahead)
-		lv->read_ahead = lv->vg->cmd->default_settings.read_ahead;
+		lv->read_ahead = cmd->default_settings.read_ahead;
 	else
 		lv->read_ahead = lvd->lv_read_ahead;
 
@@ -465,8 +464,12 @@ static struct logical_volume *_add_lv(struct dm_pool *mem,
 	lv = ll->lv;
 	lv->vg = vg;
 
-	if (!import_lv(mem, lv, lvd))
+	lvid_from_lvnum(&lv->lvid, &vg->id, lvd->lv_number);
+
+	if (!import_lv(vg->cmd, mem, lv, lvd)) {
+		dm_pool_free(mem, ll);
 		return_NULL;
+	}
 
 	dm_list_add(&vg->lvs, &ll->list);
 
-- 
1.6.2.4


