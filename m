From: Milan Broz <mbroz@redhat.com>
Date: Mon, 06 Apr 2009 10:32:14 +0200
Subject: [PATCH 2/6] vg mempool: introduce separate vg mempool
Message-ID: <49D9BE0E.5090901@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce memory pool per volume group.

Since now, all code reading volume group is responsible for releasing
the memory allocated by calling vg_release(vg).
(For simplicity of use, vg_releae can be called for vg == NULL,
the same logic like free(NULL)).

Also providing simple macro for unlocking & releasing in one step,
tools usually uses this approach.

The global memory pool (cmd->mem) should be used only for global
physical volume operations.

This patch have to be applied with all subsequent patches to complete
memory pool per vg logic.

Using separate memory pool has quite bit memory saving impact when
using large VGs, this is mainly needed when we have to use
preallocated and locked memory (and should not overflow from that
memory space).

(To fix some memory allocation with PV manipulation tools like
pvs, pvdisplay another patches are neeeded - but this is separate issue.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format1/format1.c            |   12 +++++----
 lib/format_pool/format_pool.c    |    6 +++-
 lib/format_text/import_vsn1.c    |   13 +++++++---
 lib/locking/locking.h            |    3 ++
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.c          |   50 +++++++++++++++++++++++++++----------
 lib/metadata/metadata.h          |    1 +
 7 files changed, 62 insertions(+), 25 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index a679c09..2a998ef 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -111,9 +111,9 @@ static int _check_vgs(struct dm_list *pvs)
 }
 
 static struct volume_group *_build_vg(struct format_instance *fid,
-				      struct dm_list *pvs)
+				      struct dm_list *pvs,
+				      struct dm_pool *mem)
 {
-	struct dm_pool *mem = fid->fmt->cmd->mem;
 	struct volume_group *vg = dm_pool_alloc(mem, sizeof(*vg));
 	struct disk_list *dl;
 
@@ -126,6 +126,7 @@ static struct volume_group *_build_vg(struct format_instance *fid,
 	memset(vg, 0, sizeof(*vg));
 
 	vg->cmd = fid->fmt->cmd;
+	vg->vgmem = mem;
 	vg->fid = fid;
 	vg->seqno = 0;
 	dm_list_init(&vg->pvs);
@@ -178,12 +179,13 @@ static struct volume_group *_format1_vg_read(struct format_instance *fid,
 	    (fid->fmt, vg_name, fid->fmt->cmd->filter, mem, &pvs))
 		goto_bad;
 
-	if (!(vg = _build_vg(fid, &pvs)))
+	if (!(vg = _build_vg(fid, &pvs, mem)))
 		goto_bad;
 
-      bad:
-	dm_pool_destroy(mem);
 	return vg;
+bad:
+	dm_pool_destroy(mem);
+	return NULL;
 }
 
 static struct disk_list *_flatten_pv(struct format_instance *fid,
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index aa22722..4647b0e 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -113,6 +113,7 @@ static struct volume_group *_build_vg_from_pds(struct format_instance
 	}
 
 	vg->cmd = fid->fmt->cmd;
+	vg->vgmem = mem;
 	vg->fid = fid;
 	vg->name = NULL;
 	vg->status = 0;
@@ -182,9 +183,10 @@ static struct volume_group *_pool_vg_read(struct format_instance *fid,
 	if (!(vg = _build_vg_from_pds(fid, mem, &pds)))
 		goto_out;
 
-      out:
-	dm_pool_destroy(mem);
 	return vg;
+out:
+	dm_pool_destroy(mem);
+	return NULL;
 }
 
 static int _pool_pv_setup(const struct format_type *fmt __attribute((unused)),
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 7703fe2..fcb11d2 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -662,18 +662,23 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	struct config_node *vgn, *cn;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL;
-	struct dm_pool *mem = fid->fmt->cmd->mem;
+	struct dm_pool *mem = dm_pool_create("lvm2 vg_read", VG_MEMPOOL_SIZE);
+
+	if (!mem)
+		return_NULL;
 
 	/* skip any top-level values */
 	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib) ;
 
 	if (!vgn) {
 		log_error("Couldn't find volume group in file.");
-		return NULL;
+		goto bad;
 	}
 
 	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
-		return_NULL;
+		goto_bad;
+
+	vg->vgmem = mem;
 	vg->cmd = fid->fmt->cmd;
 
 	/* FIXME Determine format type from file contents */
@@ -807,7 +812,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if (pv_hash)
 		dm_hash_destroy(pv_hash);
 
-	dm_pool_free(mem, vg);
+	dm_pool_destroy(mem);
 	return NULL;
 }
 
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index a00d742..71122c3 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -115,6 +115,9 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
 
 #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
+#define unlock_release_vg(cmd, vg, vol) do { unlock_vg(cmd, vol); \
+					     vg_release(vg); \
+					} while (0)
 
 #define resume_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME)
 #define suspend_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD)
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2850bb4..c95f744 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -212,6 +212,7 @@ struct format_instance {
 
 struct volume_group {
 	struct cmd_context *cmd;
+	struct dm_pool *vgmem;
 	struct format_instance *fid;
 	uint32_t seqno;		/* Metadata sequence number */
 
@@ -437,6 +438,7 @@ int vg_change_pesize(struct cmd_context *cmd, struct volume_group *vg,
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
+void vg_release(struct volume_group *vg);
 /* Manipulate LVs */
 struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9824eff..dd6ce54 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -29,6 +29,7 @@
 #include "archiver.h"
 #include "defaults.h"
 
+#include <assert.h>
 #include <sys/param.h>
 
 /*
@@ -517,18 +518,22 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 			       int pv_count, char **pv_names)
 {
 	struct volume_group *vg;
-	struct dm_pool *mem = cmd->mem;
 	int consistent = 0;
-
-	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
-		return_NULL;
+	struct dm_pool *mem;
 
 	/* is this vg name already in use ? */
-	if (vg_read_internal(cmd, vg_name, NULL, &consistent)) {
+	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 		log_err("A volume group called '%s' already exists.", vg_name);
-		goto bad;
+		vg_release(vg);
+		return NULL;
 	}
 
+	if (!(mem = dm_pool_create("lvm2 vg_create", VG_MEMPOOL_SIZE)))
+		return_NULL;
+
+	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
+		goto_bad;
+
 	if (!id_create(&vg->id)) {
 		log_err("Couldn't create uuid for volume group '%s'.", vg_name);
 		goto bad;
@@ -537,6 +542,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 	/* Strip dev_dir if present */
 	vg_name = strip_dir(vg_name, cmd->dev_dir);
 
+	vg->vgmem = mem;
 	vg->cmd = cmd;
 
 	if (!(vg->name = dm_pool_strdup(mem, vg_name)))
@@ -589,7 +595,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 	return vg;
 
       bad:
-	dm_pool_free(mem, vg);
+	dm_pool_destroy(mem);
 	return NULL;
 }
 
@@ -1643,23 +1649,28 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	struct pv_list *pvl;
 	struct volume_group *vg;
 	struct physical_volume *pv;
+	struct dm_pool *mem;
 
 	lvmcache_label_scan(cmd, 0);
 
 	if (!(vginfo = vginfo_from_vgname(orphan_vgname, NULL)))
 		return_NULL;
 
-	if (!(vg = dm_pool_zalloc(cmd->mem, sizeof(*vg)))) {
+	if (!(mem = dm_pool_create("vg_read orphan", VG_MEMPOOL_SIZE)))
+		return_NULL;
+
+	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg)))) {
 		log_error("vg allocation failed");
 		return NULL;
 	}
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	vg->vgmem = mem;
 	vg->cmd = cmd;
-	if (!(vg->name = dm_pool_strdup(cmd->mem, orphan_vgname))) {
+	if (!(vg->name = dm_pool_strdup(mem, orphan_vgname))) {
 		log_error("vg name allocation failed");
-		return NULL;
+		goto bad;
 	}
 
 	/* create format instance with appropriate metadata area */
@@ -1667,17 +1678,16 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 							  orphan_vgname, NULL,
 							  NULL))) {
 		log_error("Failed to create format instance");
-		dm_pool_free(cmd->mem, vg);
-		return NULL;
+		goto bad;
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(pv = _pv_read(cmd, dev_name(info->dev), NULL, NULL, 1, 0))) {
 			continue;
 		}
-		if (!(pvl = dm_pool_zalloc(cmd->mem, sizeof(*pvl)))) {
+		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
 			log_error("pv_list allocation failed");
-			return NULL;
+			goto bad;
 		}
 		pvl->pv = pv;
 		dm_list_add(&vg->pvs, &pvl->list);
@@ -1685,6 +1695,9 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	}
 
 	return vg;
+bad:
+	dm_pool_destroy(mem);
+	return NULL;
 }
 
 static int _update_pv_list(struct dm_pool *pvmem, struct dm_list *all_pvs, struct volume_group *vg)
@@ -2040,6 +2053,15 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 	return vg;
 }
 
+void vg_release(struct volume_group *vg)
+{
+	if (!vg || !vg->vgmem)
+		return;
+
+	assert(vg->vgmem != vg->cmd->mem);
+	dm_pool_destroy(vg->vgmem);
+}
+
 /* This is only called by lv_from_lvid, which is only called from
  * activate.c so we know the appropriate VG lock is already held and
  * the vg_read_internal is therefore safe.
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index fbcf82b..115d0bf 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -35,6 +35,7 @@
 //#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 #define MIRROR_LOG_OFFSET	2	/* sectors */
+#define VG_MEMPOOL_SIZE		10240	/* in KB, hint only */
 
 /*
  * Ceiling(n / sz)



