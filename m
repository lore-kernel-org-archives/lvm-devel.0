From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Jul 2011 15:43:54 +0200
Subject: [PATCH 3/7] Add cache_vg
In-Reply-To: <cover.1311082436.git.zkabelac@redhat.com>
References: <cover.1311082436.git.zkabelac@redhat.com>
Message-ID: <0d579ab1351afeee92e03872aa129ffb980c6f3e.1311082436.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 WHATS_NEW               |    2 ++
 lib/cache/lvmcache.c    |   24 ++++++++++++++++++++----
 lib/cache/lvmcache.h    |    1 +
 lib/metadata/metadata.c |    6 ++++++
 lib/metadata/vg.c       |   17 ++++++++++++++++-
 lib/metadata/vg.h       |    3 +++
 6 files changed, 48 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fb26132..732ece0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.87 - 
 ===============================
+  Cache and share generated VG structs.
+  Add ref count to struct volume_group and use release_vg instead of free_vg.
 
 Version 2.02.86 - 8th July 2011
 ===============================
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a2d6aa1..c9c3220 100644
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
@@ -90,6 +90,10 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 	}
 
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
+
+	release_vg(vginfo->cached_vg);
+
+	vginfo->cached_vg = NULL;
 }
 
 /*
@@ -662,6 +666,12 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
+	/*
+	 * Use already-cached VG struct when available
+	 */
+	if ((vg = vginfo->cached_vg))
+		goto out;	
+
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vginfo->vgname;
 	fic.context.vg_ref.vg_id = vgid;
@@ -678,13 +688,19 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
 		goto_bad;
 
-	log_debug("Using cached %smetadata for VG %s.",
-		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
+	/*
+	 * Cache VG struct for potential reuse
+	 */
+	vginfo->cached_vg = vg;
+
+out:
+	increment_vg_holders(vg);
+	log_debug("Using cached %smetadata for VG %s with %u holder(s).",
+		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname, vg->holders);
 
 	return vg;
 
 bad:
-	release_vg(vg);
 	_free_cached_vgmetadata(vginfo);
 	return NULL;
 }
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 9aafff5..5f0a4d0 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -50,6 +50,7 @@ struct lvmcache_vginfo {
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
 				/* Lifetime is directly tied to vgmetadata */
+	struct volume_group *cached_vg;
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6401207..35770bf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -866,6 +866,12 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 					    struct volume_group *vg,
 					    uint32_t failure)
 {
+	/* Never return a shared VG struct for a failure */
+	if (vg && vg->holders > 1 && failure != SUCCESS) {
+		release_vg(vg);
+		vg = NULL;
+	}
+
 	if (!vg && !(vg = alloc_vg("vg_make_handle", cmd, NULL)))
 		return_NULL;
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index ef88a4d..08b78af 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -42,6 +42,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	vg->cmd = cmd;
 	vg->vgmem = vgmem;
 	vg->alloc = ALLOC_NORMAL;
+	vg->holders = 1;
 
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->pvs_to_create);
@@ -49,9 +50,18 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
 
+	log_debug("Allocated VG %s with 1 holder at %p.", vg->name, vg);
+
 	return vg;
 }
 
+void increment_vg_holders(struct volume_group *vg)
+{
+	vg->holders++;
+
+	log_debug("Incrementing VG %s holder(s) to %d at %p.", vg->name, vg->holders, vg);
+}
+
 static void _free_vg(struct volume_group *vg)
 {
 	vg_set_fid(vg, NULL);
@@ -62,6 +72,8 @@ static void _free_vg(struct volume_group *vg)
 		return;
 	}
 
+	log_debug("Freeing VG %s at %p.", vg->name, vg);
+
 	dm_pool_destroy(vg->vgmem);
 }
 
@@ -70,7 +82,10 @@ void release_vg(struct volume_group *vg)
 	if (!vg)
 		return;
 
-	_free_vg(vg);
+	log_debug("Releasing VG %s with %d holder(s) at %p.", vg->name, vg->holders, vg);
+
+	if (!--vg->holders)
+		_free_vg(vg);
 }
 
 char *vg_fmt_dup(const struct volume_group *vg)
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index a3dc218..9366e0f 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -41,6 +41,7 @@ struct volume_group {
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
 	struct format_instance *fid;
+	unsigned holders;
 	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
@@ -111,6 +112,8 @@ struct volume_group {
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name);
 
+void increment_vg_holders(struct volume_group *vg);
+
 /*
  * release_vg() must be called on every struct volume_group allocated
  * by vg_create() or vg_read_internal() to free it when no longer required.
-- 
1.7.6


