From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  5 Apr 2010 15:51:37 -0400
Subject: [PATCH 3/5] Refactor format1 vg->pvs list add and vg->pv_count.
In-Reply-To: <1270497099-13259-3-git-send-email-dwysocha@redhat.com>
References: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-2-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1270497099-13259-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Refactor adding to the vg->pvs list and incrementing the count, which
will allow further refactoring.  Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format1/disk-rep.h      |    3 +--
 lib/format1/format1.c       |    2 +-
 lib/format1/import-export.c |    9 ++++-----
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
index 138794e..b91be39 100644
--- a/lib/format1/disk-rep.h
+++ b/lib/format1/disk-rep.h
@@ -224,8 +224,7 @@ int export_extents(struct disk_list *dl, uint32_t lv_num,
 		   struct logical_volume *lv, struct physical_volume *pv);
 
 int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
-	       struct volume_group *vg,
-	       struct dm_list *pvds, struct dm_list *results, uint32_t *count);
+	       struct volume_group *vg, struct dm_list *pvds);
 
 int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct dm_list *pvds);
 int export_lvs(struct disk_list *dl, struct volume_group *vg,
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index b6a2c15..1167e04 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -142,7 +142,7 @@ static struct volume_group *_build_vg(struct format_instance *fid,
 	if (!import_vg(mem, vg, dl))
 		goto_bad;
 
-	if (!import_pvs(fid->fmt, mem, vg, pvs, &vg->pvs, &vg->pv_count))
+	if (!import_pvs(fid->fmt, mem, vg, pvs))
 		goto_bad;
 
 	if (!import_lvs(mem, vg, pvs))
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index cd7cc7f..2ffc19e 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -422,13 +422,12 @@ int export_extents(struct disk_list *dl, uint32_t lv_num,
 }
 
 int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
-	       struct volume_group *vg,
-	       struct dm_list *pvds, struct dm_list *results, uint32_t *count)
+	       struct volume_group *vg, struct dm_list *pvds)
 {
 	struct disk_list *dl;
 	struct pv_list *pvl;
 
-	*count = 0;
+	vg->pv_count = 0;
 	dm_list_iterate_items(dl, pvds) {
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
 		    !(pvl->pv = dm_pool_alloc(mem, sizeof(*pvl->pv))))
@@ -438,8 +437,8 @@ int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
 			return_0;
 
 		pvl->pv->fmt = fmt;
-		dm_list_add(results, &pvl->list);
-		(*count)++;
+		dm_list_add(&vg->pvs, &pvl->list);
+		vg->pv_count++;
 	}
 
 	return 1;
-- 
1.6.0.6


