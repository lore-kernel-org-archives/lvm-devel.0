From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:28 +0200
Subject: [PATCH 10/11] Share VG multiple times
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <26057f0f769666604ef8a60111c1a9ae0e074a30.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Saves CPU by skipping creation of the same volume_group structure.

Structure vginfo is extended vg_cache and counters.

It tracks the number of reuses of every cached VG.
For lv_suspend we occasionaly need to reference the same VG more then
once - it's the reason for reference counter.

Caching is not used when VG is opened RW recover mode.

As there is far more case when sharing is possible - use rather specific
code to drop VG from lvmcache in this case - such VG is then unlocked.
and it is fully modifiable.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c    |   73 ++++++++++++++++++++++++++++++++++++++++++++++-
 lib/cache/lvmcache.h    |    5 +++
 lib/metadata/metadata.c |   24 ++++++++++++++-
 lib/metadata/vg.h       |    2 +
 4 files changed, 101 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0e92fa3..b19d963 100644
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
@@ -89,6 +89,11 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 		vginfo->cft = NULL;
 	}
 
+	free_vg(vginfo->vg_cache);
+	if (!lvmcache_release_vg(vginfo->vg_cache) &&
+	    vginfo->vg_ref_count > 1)
+		log_error(INTERNAL_ERROR "Cache releases referenced multi VGs.");
+
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
 }
 
@@ -662,6 +667,17 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
+	/* Check whether we have already cached VG */
+	if (vginfo->vg_cache)  {
+		if (vginfo->vg_ref_count > 2)
+			/* For lv_suspend we need lv and lv_precommit */
+			log_error(INTERNAL_ERROR "More then one shared VG.");
+		vg = vginfo->vg_cache;
+		vginfo->vg_ref_count++;
+		vginfo->vg_use_count++;
+		goto out;
+	}
+
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vginfo->vgname;
 	fic.context.vg_ref.vg_id = vgid;
@@ -678,6 +694,15 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
 		goto_bad;
 
+	/* Put VG into lvmcache */
+	vg->vginfo = vginfo;
+	vginfo->vg_cache = vg;
+	vginfo->vg_ref_count = 2; /* Keep 1 reference for lvmcache */
+	vginfo->vg_use_count = 1;
+
+	if (!dm_pool_lock(vg->vgmem, 1))
+		goto_bad;
+out:
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
 
@@ -689,6 +714,52 @@ bad:
 	return NULL;
 }
 
+/**
+ * Release a referenced VG in lvmcache
+ * and with the last reference unlock memory pool.
+ */
+int lvmcache_release_vg(struct volume_group *vg)
+{
+	if (!vg || !vg->vginfo)
+		return 1;
+
+	if (--vg->vginfo->vg_ref_count)
+		return 0;
+
+	log_debug("Released VG:%p %s from cache (used:%d).",
+		  vg, vg->name, vg->vginfo->vg_use_count);
+
+	/* Debug perform crc check only when it's been used more then once */
+	if (!dm_pool_unlock(vg->vgmem, vg->vginfo->vg_use_count > 1))
+		log_error(INTERNAL_ERROR "VG mempool.");
+
+	vg->vginfo->vg_cache = NULL;
+	vg->vginfo = NULL;
+
+	return 1;
+}
+
+/**
+ * Drop VG from lvmcache.
+ *
+ * This is used for 'write' operations.
+ * Note: VG must not be shared in this moment.
+ */
+int lvmcache_drop_vg(struct volume_group *vg)
+{
+	if (!vg || !vg->vginfo)
+		return 1; /* Already dropped */
+
+	free_vg(vg);
+
+	if (!lvmcache_release_vg(vg)) {
+		log_error(INTERNAL_ERROR "Dropping referenced VG.");
+		return 0;
+	}
+
+	return 1;
+}
+
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				   int include_internal)
 {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 9aafff5..f5c1131 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -50,6 +50,9 @@ struct lvmcache_vginfo {
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
 				/* Lifetime is directly tied to vgmetadata */
+	struct volume_group *vg_cache; /* Cached VG */
+	unsigned vg_ref_count; /* Cached VG ref counter */
+	unsigned vg_use_count; /* Cached VG usage */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
@@ -122,6 +125,8 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 
 /* Returns cached volume group metadata. */
 struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
+int lvmcache_release_vg(struct volume_group *vg);
+int lvmcache_drop_vg(struct volume_group *vg);
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9e235a1..1cd1e6c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -866,6 +866,12 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 					    struct volume_group *vg,
 					    uint32_t failure)
 {
+	if (vg && vg->vginfo && (failure != SUCCESS)) {
+		/* Avoid overwrite of cached VG */
+		free_vg(vg);
+		vg = NULL;
+	}
+
 	if (!vg && !(vg = alloc_vg("vg_make_handle", cmd, NULL)))
 		return_NULL;
 
@@ -2864,8 +2870,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	    (use_precommitted || !*consistent || !(correct_vg->status & INCONSISTENT_VG))) {
 		if (!(correct_vg->status & INCONSISTENT_VG))
 			*consistent = 1;
-		else	/* Inconsistent but we can't repair it */
+		else {
+			/* Do not keep such VG in cache */
+			if (!lvmcache_drop_vg(correct_vg))
+				return_NULL;
+			/* Inconsistent but we can't repair it */
 			correct_vg->status &= ~INCONSISTENT_VG;
+		}
 
 		return correct_vg;
 	} else {
@@ -3289,6 +3300,11 @@ void free_vg(struct volume_group *vg)
 	if (!vg)
 		return;
 
+	log_debug("Releasing VG %s (vg:%p, info:%p).", vg->name, vg, vg->vginfo);
+
+	if (!lvmcache_release_vg(vg))
+		return;    /* Still referenced, do not destroy mempool */
+
 	vg_set_fid(vg, NULL);
 
 	if (vg->cmd && vg->vgmem == vg->cmd->mem) {
@@ -3827,7 +3843,11 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 		return_NULL;
 	}
 
-	return (struct volume_group *)vg;
+	/* RW access is needed here -> remove from cache */
+	if (!lvmcache_drop_vg(vg))
+		return_NULL;
+
+	return vg;
 }
 
 /*
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index bebe6cf..2cda69b 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -20,6 +20,7 @@ struct dm_pool;
 struct format_instance;
 struct dm_list;
 struct id;
+struct lvmcache_vginfo;
 
 typedef enum {
 	ALLOC_INVALID,
@@ -41,6 +42,7 @@ struct volume_group {
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
 	struct format_instance *fid;
+	struct lvmcache_vginfo *vginfo;	/* Backward reference to lvmcache */
 	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
-- 
1.7.5.2


