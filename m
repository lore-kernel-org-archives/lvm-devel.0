From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:24:55 +0200
Subject: [PATCH 8/9] Remove unneeded import parameter from lv_create_empty.
In-Reply-To: <cover.1242227458.git.mbroz@redhat.com>
References: <cover.1242227458.git.mbroz@redhat.com>
Message-ID: <7f9bcfc1a61ece0e45547de1ab3a0d1016b8c5d0.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c          |    6 ++----
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/mirror.c            |    4 ++--
 lib/metadata/snapshot_manip.c    |    2 +-
 tools/lvcreate.c                 |    4 ++--
 tools/pvmove.c                   |    2 +-
 6 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 80c1197..1c758ea 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1812,7 +1812,6 @@ struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
 				       uint32_t status,
 				       alloc_policy_t alloc,
-				       int import,
 				       struct volume_group *vg)
 {
 	struct format_instance *fi = vg->fid;
@@ -1832,8 +1831,7 @@ struct logical_volume *lv_create_empty(const char *name,
 		return NULL;
 	}
 
-	if (!import)
-		log_verbose("Creating logical volume %s", name);
+	log_verbose("Creating logical volume %s", name);
 
 	if (!(lv = dm_pool_zalloc(vg->vgmem, sizeof(*lv))))
 		return_NULL;
@@ -2418,7 +2416,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	}
 
 	if (!(layer_lv = lv_create_empty(name, NULL, LVM_READ | LVM_WRITE,
-					 ALLOC_INHERIT, 0, lv_where->vg))) {
+					 ALLOC_INHERIT, lv_where->vg))) {
 		log_error("Creation of layer LV failed");
 		return NULL;
 	}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 680be10..1477a0b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -445,7 +445,6 @@ struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
 				       uint32_t status,
 				       alloc_policy_t alloc,
-				       int import,
 				       struct volume_group *vg);
 
 /* Write out LV contents */
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 087ce73..ed6f779 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -932,7 +932,7 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 	for (m = 0; m < num_mirrors; m++) {
 		if (!(img_lvs[m] = lv_create_empty(img_name,
 					     NULL, LVM_READ | LVM_WRITE,
-					     ALLOC_INHERIT, 0, lv->vg))) {
+					     ALLOC_INHERIT, lv->vg))) {
 			log_error("Aborting. Failed to create mirror image LV. "
 				  "Remove new LV and retry.");
 			return 0;
@@ -1266,7 +1266,7 @@ static struct logical_volume *_create_mirror_log(struct logical_volume *lv,
 
 	if (!(log_lv = lv_create_empty(log_name, NULL,
 				       VISIBLE_LV | LVM_READ | LVM_WRITE,
-				       alloc, 0, lv->vg)))
+				       alloc, lv->vg)))
 		return_NULL;
 
 	if (!lv_add_log_segment(ah, log_lv))
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index bf694f7..83bc385 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -105,7 +105,7 @@ int vg_add_snapshot(struct logical_volume *origin,
 
 	if (!(snap = lv_create_empty("snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
-				     ALLOC_INHERIT, 1, origin->vg)))
+				     ALLOC_INHERIT, origin->vg)))
 		return_0;
 
 	snap->le_count = extent_count;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 069cc0e..1d06c4b 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -577,7 +577,7 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 	}
 
 	if (!(lv = lv_create_empty(vorigin_name, NULL, permission,
-				   ALLOC_INHERIT, 0, vg)))
+				   ALLOC_INHERIT, vg)))
 		return_0;
 
 	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents, NULL, 0u, 0u,
@@ -824,7 +824,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
-				   status, lp->alloc, 0, vg)))
+				   status, lp->alloc, vg)))
 		return_0;
 
 	if (lp->read_ahead) {
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 55285df..d760802 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -191,7 +191,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
 					LVM_READ | LVM_WRITE,
-					ALLOC_CONTIGUOUS, 0, vg))) {
+					ALLOC_CONTIGUOUS, vg))) {
 		log_error("Creation of temporary pvmove LV failed");
 		return NULL;
 	}
-- 
1.6.2.4


