From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Feb 2011 14:52:16 +0100
Subject: [PATCH 2/3] Add VG refcount and cache created VG structure
In-Reply-To: <cover.1298466569.git.zkabelac@redhat.com>
References: <cover.1298466569.git.zkabelac@redhat.com>
Message-ID: <e7846e868f7d69e5ed6ce8a700c9d5857630be79.1298466569.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Imported VG from config tree is now cached in lvmcache_vginfo for
read-only code path..

Extended lvmcache_get_vg() with new parameter 'consistent'.
It passing information about how the metadata are going to be used.
For 'read-only' case it is == '0'.

VG structure has reference counter to support shared usage of VG.
(One copy is kept by cache - and 2nd is processed by the code and
released with free_vg()).

Sharing of 'write' MDA is not being made - after writting,
metadata cache is flushed and new data is read back and parsed again.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c    |   53 +++++++++++++++++++++++++++++++----------------
 lib/cache/lvmcache.h    |    4 ++-
 lib/metadata/metadata.c |    5 +++-
 lib/metadata/vg.c       |    1 +
 lib/metadata/vg.h       |    1 +
 5 files changed, 44 insertions(+), 20 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0a8693c..7c53b14 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -89,6 +89,11 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 		vginfo->cft = NULL;
 	}
 
+	if (vginfo->vg) {
+		free_vg(vginfo->vg);
+		vginfo->vg = NULL;
+	}
+
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
 }
 
@@ -624,7 +629,7 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 	return r;
 }
 
-struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
+struct volume_group *lvmcache_get_vg(const char *vgid, int consistent, unsigned precommitted)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg;
@@ -653,25 +658,37 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
-	fic.context.vg_ref.vg_name = vginfo->vgname;
-	fic.context.vg_ref.vg_id = vgid;
-	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic)))
-		return_NULL;
+	if (vginfo->vg && (consistent == 0)) {
+		vg = vginfo->vg;
+		++vg->refcount;  /* Share with caller */
+		log_debug("Sharing VG %s (%d)", vginfo->vgname, vg->refcount);
+	} else {
+		fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+		fic.context.vg_ref.vg_name = vginfo->vgname;
+		fic.context.vg_ref.vg_id = vgid;
+		if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic)))
+			return_NULL;
 
-	/* Build config tree from vgmetadata, if not yet cached */
-	if (!vginfo->cft &&
-	    !(vginfo->cft =
-	      create_config_tree_from_string(fid->fmt->cmd,
-					     vginfo->vgmetadata))) {
-		_free_cached_vgmetadata(vginfo);
-		return_NULL;
-	}
+		/* Build config tree from vgmetadata, if not yet cached */
+		if (!vginfo->cft &&
+		    !(vginfo->cft =
+		      create_config_tree_from_string(fid->fmt->cmd,
+						     vginfo->vgmetadata))) {
+			_free_cached_vgmetadata(vginfo);
+			return_NULL;
+		}
 
-	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
-		_free_cached_vgmetadata(vginfo);
-		return_NULL;
-	}
+		if (!(vg = import_vg_from_config_tree(vginfo->cft, fid))) {
+			_free_cached_vgmetadata(vginfo);
+			return_NULL;
+		}
+
+		/* Cache only 'read-only' imported VG metadata */
+		if (consistent == 0) {
+			vginfo->vg = vg;
+			++vg->refcount; /* Keep copy for cache */
+		}
+	} 
 
 	log_debug("Using cached %smetadata for VG %s.",
 		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 080f3b5..19ef423 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -49,6 +49,8 @@ struct lvmcache_vginfo {
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
 				/* Lifetime is directly tied to vgmetadata */
+	struct volume_group *vg; /* Cached parsed VG structure */
+				/* Lifetime is directly tied to vgmetadata */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
@@ -120,7 +122,7 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 				const char *vgid);
 
 /* Returns cached volume group metadata. */
-struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted);
+struct volume_group *lvmcache_get_vg(const char *vgid, int consistent, unsigned precommitted);
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d75a1cf..563f0cb 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2860,7 +2860,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * Also return if use_precommitted is set due to the FIXME in
 	 * the missing PV logic below.
 	 */
-	if ((correct_vg = lvmcache_get_vg(vgid, precommitted)) &&
+	if ((correct_vg = lvmcache_get_vg(vgid, *consistent, precommitted)) &&
 	    (use_precommitted || !*consistent || !(correct_vg->status & INCONSISTENT_VG))) {
 		if (!(correct_vg->status & INCONSISTENT_VG))
 			*consistent = 1;
@@ -3272,6 +3272,9 @@ void free_vg(struct volume_group *vg)
 	if (!vg)
 		return;
 
+	if (--vg->refcount)
+		return;
+
 	if (vg->cmd && vg->vgmem == vg->cmd->mem) {
 		log_error(INTERNAL_ERROR "global memory pool used for VG %s",
 			  vg->name);
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 392d23c..e21645c 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -31,6 +31,7 @@ struct volume_group *alloc_vg(struct cmd_context *cmd)
 		return NULL;
 	}
 
+	vg->refcount = 1;
 	vg->cmd = cmd;
 	vg->vgmem = vgmem;
 	vg->alloc = ALLOC_NORMAL;
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index c00fb74..ad6e071 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -37,6 +37,7 @@ struct volume_group {
 	struct format_instance *fid;
 	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
+	uint32_t refcount;	/* Reference counter */
 	uint32_t seqno;		/* Metadata sequence number */
 
 	alloc_policy_t alloc;
-- 
1.7.4.1


