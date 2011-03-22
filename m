From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:21:57 +0100
Subject: [PATCH 3/6] Share VG multiple times
In-Reply-To: <cover.1300828168.git.zkabelac@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
Message-ID: <c17c93112a51e0a81b7154c83ecd1636770eeca5.1300828168.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Saves time of the creation of the same volume_group structure.

Structure vginfo is extended with linked list of vg_pool_list elements.

It tracks the number of reuses of every cached VG.  As especially clvmd
and few other situation requires more then 1 parsed VG - so using
this vg_pool implementation.

Sharing is not used when VG is opened RW recover mode.
As there is far more case when sharing is possible - use rather specific
lvmcache_drop_vg() call to drop parsed VG from cache - such VG is then
unlocked moved away from the vg pool and it is fully modifiable.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c    |  104 +++++++++++++++++++++++++++++++++++++++++++++-
 lib/cache/lvmcache.h    |    3 +
 lib/metadata/metadata.c |   20 ++++++++-
 lib/metadata/vg.h       |    2 +
 4 files changed, 124 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d0de34f..9ee009d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -38,6 +38,13 @@ static int _has_scanned = 0;
 static int _vgs_locked = 0;
 static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
 
+struct vg_pool_list {
+	struct dm_list list;    /* vg_pool list */
+	struct volume_group *vg;
+	int in_use;
+	unsigned use_count;	/* Reuse counter for statistics */
+};
+
 int lvmcache_init(void)
 {
 	/*
@@ -76,6 +83,10 @@ int lvmcache_init(void)
 /* Volume Group metadata cache functions */
 static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 {
+	struct vg_pool_list *vgpl, *tvgpl;
+	struct volume_group *vg;
+	int in_use;
+
 	if (!vginfo || !vginfo->vgmetadata)
 		return;
 
@@ -89,6 +100,17 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 		vginfo->cft = NULL;
 	}
 
+	dm_list_iterate_items_safe(vgpl, tvgpl, &vginfo->vg_pool) {
+		vg = vgpl->vg;
+		in_use = vgpl->in_use;
+		if (!lvmcache_drop_vg(vg))
+			stack;
+		if (in_use)
+			log_debug("Unpooling referenced VG:%p %s", vg, vg->name);
+		else
+			free_vg(vg);
+	}
+
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
 }
 
@@ -637,6 +659,7 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg = NULL;
+	struct vg_pool_list *vgpl = NULL;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 	int vg_missing;
@@ -663,12 +686,32 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
+	/* Try to find some usable VG in pool - short list is expected */
+	dm_list_iterate_items(vgpl, &vginfo->vg_pool)  {
+		if (!vgpl->in_use) {
+			if (!dm_pool_restore(vgpl->vg->vgmem, 0))
+				/* Should not happen, but ignore such VG */
+				stack;
+			else {
+				vg = vgpl->vg;
+				vgpl->in_use = 1;
+				vgpl->use_count++;
+				goto out;
+			}
+		}
+	}
+
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vginfo->vgname;
 	fic.context.vg_ref.vg_id = vgid;
 	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic)))
 		return_NULL;
 
+	if (!(vgpl = dm_zalloc(sizeof(*vgpl)))) {
+		log_error("Failed to allocate memory for pool list.");
+		goto bad;
+	}
+
 	/* Build config tree from vgmetadata, if not yet cached */
 	if (!vginfo->cft &&
 	    !(vginfo->cft =
@@ -685,17 +728,71 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 		vg_mark_partial_lvs(vg);
 	}
 
-	log_debug("Using cached %smetadata for VG %s.",
-		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
+	/* Add to VGs pool */
+	vg->vg_pool = vgpl;
+	vgpl->vg = vg;
+	vgpl->in_use = 1; /* Also for goto_bad fail path */
+	dm_list_add(&vginfo->vg_pool, &vgpl->list);
+	log_debug("Add VG:%p %s to the vginfo %p vg_pool (%d).",
+		  vg, vg->name, vginfo, dm_list_size(&vginfo->vg_pool));
+	if (!dm_pool_lock(vg->vgmem, 8 + dm_list_size(&vg->lvs)))
+		goto_bad;
+out:
+	log_debug("Using cached (%u) %smetadata for VG %s.", vgpl->use_count,
+		  vginfo->precommitted ? "pre-committed " : "", vginfo->vgname);
 
 	return vg;
 
 bad:
 	free_vg(vg);
 	_free_cached_vgmetadata(vginfo);
+	dm_free(vgpl);
 	return NULL;
 }
 
+/**
+ * Put back VG as reusable in vg_pool list
+ */
+int lvmcache_put_vg(struct volume_group *vg)
+{
+	if (!vg->vg_pool || !vg->vg_pool->in_use)
+		return 0;
+
+	log_debug("Putting back to cache list VG:%p %s (reused:%d).",
+		  vg, vg->name, vg->vg_pool->use_count);
+	vg->vg_pool->in_use = 0;
+	return 1;
+}
+
+/**
+ * Drop VG from the vginfo vg_pool list so it can be used
+ * for modification.
+ */
+int lvmcache_drop_vg(struct volume_group *vg)
+{
+	if (!vg->vg_pool)
+		return 0;
+
+	log_debug("Dropping VG:%p %s from cache (reused:%d).",
+		  vg, vg->name, vg->vg_pool->use_count);
+
+	/* Debug perform crc check */
+	if (!vg->vg_pool->in_use &&
+	    vg->vg_pool->use_count &&
+	    !dm_pool_restore(vg->vgmem, 1))
+		/* Should not happen, but ignore such VG */
+		stack;
+
+	if (!dm_pool_unlock(vg->vgmem))
+		stack;
+
+	dm_list_del(&vg->vg_pool->list);
+	dm_free(vg->vg_pool);
+	vg->vg_pool = NULL;
+
+	return 1;
+}
+
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				   int include_internal)
 {
@@ -1117,6 +1214,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 			return 0;
 		}
 		dm_list_init(&vginfo->infos);
+		dm_list_init(&vginfo->vg_pool);
 
 		/*
 		 * If we're scanning and there's an invalidated entry, remove it.
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index f13cad2..6360f30 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -50,6 +50,7 @@ struct lvmcache_vginfo {
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
 				/* Lifetime is directly tied to vgmetadata */
+	struct dm_list vg_pool; /* List of cached parsed struct volume_group */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
@@ -122,6 +123,8 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 
 /* Returns cached volume group metadata. */
 struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
+int lvmcache_put_vg(struct volume_group *vg);
+int lvmcache_drop_vg(struct volume_group *vg);
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b6312a0..e466821 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -855,6 +855,12 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 					    struct volume_group *vg,
 					    uint32_t failure)
 {
+	if (vg && vg->vg_pool && (failure != SUCCESS)) {
+		/* Avoid overwrite of shared VG structure */
+		free_vg(vg);
+		vg = NULL;
+	}
+
 	if (!vg && !(vg = alloc_vg("vg_make_handle", cmd, NULL)))
 		return_NULL;
 
@@ -2816,8 +2822,11 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	    (use_precommitted || !*consistent || !(correct_vg->status & INCONSISTENT_VG))) {
 		if (!(correct_vg->status & INCONSISTENT_VG))
 			*consistent = 1;
-		else	/* Inconsistent but we can't repair it */
+		else { 
+			lvmcache_drop_vg(correct_vg);
+			/* Inconsistent but we can't repair it */
 			correct_vg->status &= ~INCONSISTENT_VG;
+		}
 
 		return correct_vg;
 	} else {
@@ -3243,6 +3252,11 @@ void free_vg(struct volume_group *vg)
 	if (!vg)
 		return;
 
+	log_debug("Releasing VG:%p %s.", vg, vg->name);
+
+	if (lvmcache_put_vg(vg))
+		return;
+
 	dm_list_iterate_items(pvl, &vg->pvs)
 		pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
 
@@ -3789,7 +3803,9 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 		return_NULL;
 	}
 
-	return (struct volume_group *)vg;
+	lvmcache_drop_vg(vg);
+
+	return vg;
 }
 
 /*
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 2cc6047..e153c76 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -20,6 +20,7 @@ struct dm_pool;
 struct format_instance;
 struct dm_list;
 struct id;
+struct vg_pool_list;
 
 typedef enum {
 	ALLOC_INVALID,
@@ -35,6 +36,7 @@ struct volume_group {
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
 	struct format_instance *fid;
+	struct vg_pool_list *vg_pool; /* Backward reference to lvmcache */
 	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
-- 
1.7.4.1


