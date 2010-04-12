From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 12 Apr 2010 17:21:38 +0200
Subject: [PATCH 10/22] Replicator: add find_replicator_vgs
In-Reply-To: <cover.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
Message-ID: <00f9ca873a90d0f025ca5c6fea457c54d23d33a9.1271085009.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding function find_replicator_vgs() to find all needed
VGs for replicator.

This function is later called before taking lock_vol().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/replicator_manip.c  |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0f00d7a..1ff8986 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -801,6 +801,8 @@ int vgs_list_read(struct cmd_context *cmd, struct dm_list *vgs_list,
 void vgs_list_release(struct dm_list *vgs_list,
 		      struct vgs_list *vnl_vg);
 
+int find_replicator_vgs(struct logical_volume *lv);
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 8b5d8fe..208efea 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -628,3 +628,35 @@ void vgs_list_release(struct dm_list *list, struct vgs_list *vgs_vg)
 		vgsl->vg = NULL;
 	}
 }
+
+/**
+ * Find all needed remote VGs for processing given LV.
+ * Missing VGs are added to VG's vgs list.
+ */
+int find_replicator_vgs(struct logical_volume *lv)
+{
+	struct replicator_site *rsite;
+	int ret = 1;
+
+	if (!lv_is_replicator_dev(lv))
+		return 1;
+
+	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
+		if (!rsite->vg_name ||
+		    vgs_list_lookup(&lv->vg->vgs, rsite->vg_name))
+			continue;
+		ret = 0;
+		/* Using cmd memory pool for list allocation */
+		if (!vgs_list_add(lv->vg->cmd->mem, &lv->vg->vgs,
+				      rsite->vg_name, NULL, 0)) {
+			lv->vg->missing_vgs = 0; /* do not retry */
+			stack;
+			break;
+		}
+
+		log_debug("VG: %s added as missing.", rsite->vg_name);
+		lv->vg->missing_vgs++;
+	}
+
+	return ret;
+}
-- 
1.7.0.1


