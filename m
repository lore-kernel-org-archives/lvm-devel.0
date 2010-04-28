From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:34:26 +0200
Subject: [PATCH 11/23] Replicator: add find_replicator_vgs
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <6dc1961ed79771cea0f927928e4dc11f543ac2e0.1272457502.git.zkabelac@redhat.com>
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
index c5a31d6..4c70626 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -809,6 +809,8 @@ struct cmd_vg *cmd_vg_lookup(struct dm_list *cmd_vgs,
 int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs);
 void cmd_vg_release(struct dm_list *cmd_vgs);
 
+int find_replicator_vgs(struct logical_volume *lv);
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 82ce23c..abd34b3 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -602,3 +602,35 @@ void cmd_vg_release(struct dm_list *cmd_vgs)
 		cvl->vg = NULL;
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
+		if (!rsite->vg_name || !lv->vg->cmd_vgs ||
+		    cmd_vg_lookup(lv->vg->cmd_vgs, rsite->vg_name, NULL))
+			continue;
+		ret = 0;
+		/* Using cmd memory pool for cmd_vg list allocation */
+		if (!cmd_vg_add(lv->vg->cmd->mem, lv->vg->cmd_vgs,
+				rsite->vg_name, NULL, 0)) {
+			lv->vg->cmd_missing_vgs = 0; /* do not retry */
+			stack;
+			break;
+		}
+
+		log_debug("VG: %s added as missing.", rsite->vg_name);
+		lv->vg->cmd_missing_vgs++;
+	}
+
+	return ret;
+}
-- 
1.7.0.1


