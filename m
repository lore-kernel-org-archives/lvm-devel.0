From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 12 Apr 2010 17:21:39 +0200
Subject: [PATCH 11/22] Replicator: add read and release VGs for rsites
In-Reply-To: <cover.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
Message-ID: <c0e23123eeda6b015b747f792c5e71ef978f566e.1271085009.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add function to read and release remote VGs for replicator sites
in activation context.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |    3 ++
 lib/metadata/replicator_manip.c  |   56 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1ff8986..d0c86d9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -803,6 +803,9 @@ void vgs_list_release(struct dm_list *vgs_list,
 
 int find_replicator_vgs(struct logical_volume *lv);
 
+int lv_read_replicator_vgs(struct logical_volume *lv);
+void lv_release_replicator_vgs(struct logical_volume *lv);
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 208efea..9682c14 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -660,3 +660,59 @@ int find_replicator_vgs(struct logical_volume *lv)
 
 	return ret;
 }
+
+/**
+ * Resolve all remote VGs from replicators' sites
+ * This function is used in activation context and needs all VGs already locked
+ */
+int lv_read_replicator_vgs(struct logical_volume *lv)
+{
+	struct replicator_device *rdev;
+	struct replicator_site *rsite;
+	struct volume_group *vg;
+
+	if (!lv_is_replicator_dev(lv))
+		return 1;
+
+	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
+		if (!rsite->vg_name)
+			continue;
+		vg = vg_read(lv->vg->cmd, rsite->vg_name, 0, 0); // READ_WITHOUT_LOCK
+		if (vg_read_error(vg)) {
+			log_error("Unable to read volume group %s",
+				  rsite->vg_name);
+			goto bad;
+		}
+		rsite->vg = vg;
+		/* CHECKME: handling missing LVs needs to be better */
+		dm_list_iterate_items(rdev, &rsite->rdevices)
+			if (!(rdev->lv = find_lv(vg, rdev->name))) {
+				log_error("Unable to find %s in volume group %s",
+					  rdev->name, rsite->vg_name);
+				goto bad;
+			}
+	}
+
+	return 1;
+bad:
+	lv_release_replicator_vgs(lv);
+	return 0;
+}
+
+/**
+ * Release all VG resources taken by replicators' sites
+ * This function is used in activation context and needs all VGs already locked
+ */
+void lv_release_replicator_vgs(struct logical_volume *lv)
+{
+	struct replicator_site *rsite;
+
+	if (!lv_is_replicator_dev(lv))
+		return;
+
+	dm_list_iterate_back_items(rsite, &first_seg(lv)->replicator->rsites)
+		if (rsite->vg_name && rsite->vg) {
+			vg_release(rsite->vg);
+			rsite->vg = NULL;
+		}
+}
-- 
1.7.0.1


