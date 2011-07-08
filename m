From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  8 Jul 2011 17:52:23 +0200
Subject: [PATCH 1/3] Share VG multiple times
In-Reply-To: <cover.1310140154.git.zkabelac@redhat.com>
References: <cover.1310140154.git.zkabelac@redhat.com>
Message-ID: <ef895307fafd258c45f7413c833b9a49f13e8419.1310140154.git.zkabelac@redhat.com>
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
 lib/cache/lvmcache.c    |   67 ++++++++++++++++++++++++++++++++++++++++++++++-
 lib/cache/lvmcache.h    |    5 +++
 lib/metadata/metadata.c |   26 +++++++++++++++++-
 lib/metadata/vg.h       |    2 +
 4 files changed, 97 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0e92fa3..275087f 100644
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
@@ -89,6 +89,12 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 		vginfo->cft = NULL;
 	}
 
+	/* Release cached VG, and check there is at most 1 user */
+	/* Note: 1 reference is allowed during precommit lvmcache update */
+	free_vg(vginfo->vg_cache);
+	if (vginfo->vg_cache && !lvmcache_release_vg(vginfo->vg_cache))
+		log_error(INTERNAL_ERROR "Cache releases referenced VG.");
+
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
 }
 
@@ -662,6 +668,17 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
+	/* Use already cached VG when available */
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
@@ -678,6 +695,13 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
 		goto_bad;
 
+	/* Put VG into lvmcache */
+	vg->vginfo = vginfo;
+	vginfo->vg_cache = vg;
+	vginfo->vg_ref_count = 2; /* Keep 1 reference for lvmcache */
+	vginfo->vg_use_count = 1;
+
+out:
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
 
@@ -689,6 +713,47 @@ bad:
 	return NULL;
 }
 
+/**
+ * Release a referenced VG from lvmcache.
+ */
+int lvmcache_release_vg(struct volume_group *vg)
+{
+	if (!vg->vginfo)
+		return 1;
+
+	if (--vg->vginfo->vg_ref_count)
+		return 0; /* Still referenced */
+
+	log_debug("Released VG:%p %s from cache (used:%d).",
+		  vg, vg->name, vg->vginfo->vg_use_count);
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
+	if (!vg->vginfo)
+		return 1; /* Not cached */
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
index 842885f..d7fb6c3 100644
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
 
@@ -2865,8 +2871,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	    (use_precommitted || !*consistent || !(correct_vg->status & INCONSISTENT_VG))) {
 		if (!(correct_vg->status & INCONSISTENT_VG))
 			*consistent = 1;
-		else	/* Inconsistent but we can't repair it */
+		else {
+			/* Inconsistent VG is being modified, no caching */
+			if (!lvmcache_drop_vg(correct_vg))
+				return_NULL;
+			/* Inconsistent but we can't repair it */
 			correct_vg->status &= ~INCONSISTENT_VG;
+		}
 
 		return correct_vg;
 	} else {
@@ -3312,6 +3323,11 @@ void free_vg(struct volume_group *vg)
 	if (!vg)
 		return;
 
+	log_debug("Releasing VG %s (vg:%p, info:%p).", vg->name, vg, vg->vginfo);
+
+	if (!lvmcache_release_vg(vg))
+		return;    /* Still referenced, do not destroy mempool */
+
 	vg_set_fid(vg, NULL);
 
 	if (vg->cmd && vg->vgmem == vg->cmd->mem) {
@@ -3850,7 +3866,13 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 		return_NULL;
 	}
 
-	return (struct volume_group *)vg;
+	/* Test if the VG is not accidentally from lvmcache */
+	if (vg->vginfo) {
+		log_error(INTERNAL_ERROR "Recovered VG is in the cache.");
+		return NULL;
+	}
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
1.7.6


