From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Mar 2010 17:17:11 +0200
Subject: [PATCH 10/22] Replicator: add lv_replicator_sites_check_vg
In-Reply-To: <cover.1269961680.git.zkabelac@redhat.com>
References: <cover.1269961680.git.zkabelac@redhat.com>
Message-ID: <a4ce322d5341d841fea7cd52ce7ab39ce9ae808a.1269961680.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding lv_replicator_sites_check_vg() which is called before
taking lock_vol().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/replicator_manip.c  |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3790391..c607c4f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -800,6 +800,8 @@ int vg_name_list_read(struct cmd_context *cmd, struct dm_list *vgs_list,
 void vg_name_list_release(struct dm_list *vgs_list,
 			  struct vg_name_list *vnl_vg);
 
+int lv_replicator_sites_check_vg(struct logical_volume *lv);
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index a81b433..cb336b4 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -461,3 +461,35 @@ void vg_name_list_release(struct dm_list *vgs_list,
 		vnl->vg = NULL;
 	}
 }
+
+/**
+ * Check whether all VGs are available for processing given LV
+ * Missing VGs are added to the list
+ */
+int lv_replicator_sites_check_vg(struct logical_volume *lv)
+{
+	struct replicator_site *rsite;
+	int ret = 1;
+
+	if (!lv_is_replicator_dev(lv))
+		return 1;
+
+	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
+		if (!rsite->vg_name ||
+		    vg_name_list_lookup(&lv->vg->vgs, rsite->vg_name))
+			continue;
+		ret = 0;
+		/* Using cmd memory pool for list allocation */
+		if (!vg_name_list_add(lv->vg->cmd->mem, &lv->vg->vgs,
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


