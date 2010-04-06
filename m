From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  6 Apr 2010 19:53:16 -0400
Subject: [PATCH 1/5] Remove unnecessary parameter from import_pool_pvs().
In-Reply-To: <1270598000-9771-1-git-send-email-dwysocha@redhat.com>
References: <1270598000-9771-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1270598000-9771-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The dm_list * parameter is unnecessary since we are passing in 'vg'
and the only caller of import_pool_pvs() passes '&vg->pvs' in the
dm_list * parameter.  Just use vg->pvs directly in the function.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_pool/disk_rep.h      |    2 +-
 lib/format_pool/format_pool.c   |    2 +-
 lib/format_pool/import_export.c |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/format_pool/disk_rep.h b/lib/format_pool/disk_rep.h
index fb33cd8..fff7343 100644
--- a/lib/format_pool/disk_rep.h
+++ b/lib/format_pool/disk_rep.h
@@ -141,7 +141,7 @@ int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct dm_list
 int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem,
 		    struct dm_list *pls);
 int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
-		    struct dm_list *pvs, struct dm_pool *mem, struct dm_list *pls);
+		    struct dm_pool *mem, struct dm_list *pls);
 int import_pool_pv(const struct format_type *fmt, struct dm_pool *mem,
 		   struct volume_group *vg, struct physical_volume *pv,
 		   struct pool_list *pl);
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 26321c1..d8a09ec 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -129,7 +129,7 @@ static struct volume_group *_build_vg_from_pds(struct format_instance
 	if (!import_pool_vg(vg, smem, pds))
 		return_NULL;
 
-	if (!import_pool_pvs(fid->fmt, vg, &vg->pvs, smem, pds))
+	if (!import_pool_pvs(fid->fmt, vg, smem, pds))
 		return_NULL;
 
 	if (!import_pool_lvs(vg, smem, pds))
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index b383557..032d428 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -100,7 +100,7 @@ int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list
 }
 
 int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
-		    struct dm_list *pvs, struct dm_pool *mem, struct dm_list *pls)
+		    struct dm_pool *mem, struct dm_list *pls)
 {
 	struct pv_list *pvl;
 	struct pool_list *pl;
@@ -120,7 +120,7 @@ int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
 		pl->pv = pvl->pv;
 		pvl->mdas = NULL;
 		pvl->pe_ranges = NULL;
-		dm_list_add(pvs, &pvl->list);
+		dm_list_add(&vg->pvs, &pvl->list);
 	}
 
 	return 1;
-- 
1.6.0.6


