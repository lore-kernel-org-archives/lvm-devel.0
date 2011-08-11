From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Aug 2011 09:33:40 +0200
Subject: [PATCH 1/5] Add cache_vg
In-Reply-To: <cover.1313047685.git.zkabelac@redhat.com>
References: <cover.1313047685.git.zkabelac@redhat.com>
Message-ID: <e141f760142c56a5e5e2411317f4c6ee5ec26d1d.1313047685.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 WHATS_NEW               |    1 +
 lib/cache/lvmcache.c    |   41 +++++++++++++++++++++++++++++++++++++----
 lib/cache/lvmcache.h    |    7 +++++++
 lib/metadata/metadata.c |    6 ++++++
 lib/metadata/vg.c       |    9 +++++++++
 lib/metadata/vg.h       |    1 +
 6 files changed, 61 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 85398ad..22d4eb8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Cache and share generated VG structs.
   Add dmeventd monitoring shared library for RAID.
   Add RAID metadata devices to considered devices in _add_lv_to_dtree.
   Fix renaming of RAID logical volumes.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 517d2f3..45965cc 100644
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
@@ -90,6 +90,8 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 	}
 
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
+
+	release_vg(vginfo->cached_vg);
 }
 
 /*
@@ -662,6 +664,10 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
+	/* Use already-cached VG struct when available */
+	if ((vg = vginfo->cached_vg))
+		goto out;
+
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vginfo->vgname;
 	fic.context.vg_ref.vg_id = vgid;
@@ -677,17 +683,44 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
 		goto_bad;
 
-	log_debug("Using cached %smetadata for VG %s.",
-		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
+	/* Cache VG struct for reuse */
+	vginfo->cached_vg = vg;
+	vginfo->holders = 1;
+	vginfo->use_count = 0;
+	vg->vginfo = vginfo;
+
+out:
+	vginfo->holders++;
+	vginfo->use_count++;
+	log_debug("Using cached %smetadata for VG %s with %u holder(s).",
+		  vginfo->precommitted ? "pre-committed " : "",
+		  vginfo->vgname, vginfo->holders);
 
 	return vg;
 
 bad:
-	release_vg(vg);
 	_free_cached_vgmetadata(vginfo);
 	return NULL;
 }
 
+int lvmcache_decrement_holders(struct lvmcache_vginfo *vginfo)
+{
+	log_debug("VG %s decrementing %d holder(s) at %p.",
+		  vginfo->cached_vg->name, vginfo->holders, vginfo->cached_vg);
+
+	if (--vginfo->holders)
+		return 1;
+
+	if (vginfo->use_count > 1)
+		log_debug("VG %s reused %d times.",
+			  vginfo->cached_vg->name, vginfo->use_count);
+
+	vginfo->cached_vg->vginfo = NULL;
+	vginfo->cached_vg = NULL;
+
+	return 0;
+}
+
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				   int include_internal)
 {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 9aafff5..444ed33 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -50,6 +50,9 @@ struct lvmcache_vginfo {
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
 				/* Lifetime is directly tied to vgmetadata */
+	struct volume_group *cached_vg;
+	unsigned holders;
+	unsigned use_count;     /* Counter of vg reusage */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
@@ -122,6 +125,10 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 
 /* Returns cached volume group metadata. */
 struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
+
+/* Decrement vginfo holders in lvmcache. */
+int lvmcache_decrement_holders(struct lvmcache_vginfo *vginfo);
+
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ee29f25..44f5fa5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -866,6 +866,12 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 					    struct volume_group *vg,
 					    uint32_t failure)
 {
+	/* Never return a cached VG structure for a failure */
+	if (vg && vg->vginfo && failure != SUCCESS) {
+		release_vg(vg);
+		vg = NULL;
+	}
+
 	if (!vg && !(vg = alloc_vg("vg_make_handle", cmd, NULL)))
 		return_NULL;
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index ef88a4d..07336c5 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -18,6 +18,7 @@
 #include "display.h"
 #include "activate.h"
 #include "toolcontext.h"
+#include "lvmcache.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
@@ -49,6 +50,8 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
 
+	log_debug("Allocated VG %s at %p.", vg->name, vg);
+
 	return vg;
 }
 
@@ -62,6 +65,8 @@ static void _free_vg(struct volume_group *vg)
 		return;
 	}
 
+	log_debug("Freeing VG %s at %p.", vg->name, vg);
+
 	dm_pool_destroy(vg->vgmem);
 }
 
@@ -70,6 +75,10 @@ void release_vg(struct volume_group *vg)
 	if (!vg)
 		return;
 
+	/* Decrement holders and check if vg is still in use */
+	if (vg->vginfo && lvmcache_decrement_holders(vg->vginfo))
+		return;
+
 	_free_vg(vg);
 }
 
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 5248888..9c21f37 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -41,6 +41,7 @@ struct volume_group {
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
 	struct format_instance *fid;
+	struct lvmcache_vginfo *vginfo;
 	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
-- 
1.7.6


