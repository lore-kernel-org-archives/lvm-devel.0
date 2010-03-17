From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:47:03 +0100
Subject: [PATCH 10/25] Replicator: add read/release VG for rsites
In-Reply-To: <cover.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
Message-ID: <ff943e8f13986e09f475316f6a8e50905316a051.1268833246.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add function to read/release remote VGs from replicator sites
in activation context.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/replicator_manip.c  |   56 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 3e1da12..cf73bf8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -801,6 +801,8 @@ void vg_name_list_release(struct dm_list *vgs_list,
 			  struct vg_name_list *vnl_vg);
 
 int lv_replicator_sites_check_vg(struct logical_volume *lv);
+int lv_replicator_sites_read(struct logical_volume *lv);
+void lv_replicator_sites_release(struct logical_volume *lv);
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index d5e3cda..57e0346 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -518,3 +518,59 @@ int lv_replicator_sites_check_vg(struct logical_volume *lv)
 
 	return ret;
 }
+
+/**
+ * Resolve all remote VGs from replicator sites
+ * This function is used in activation context and needs all VGs already locked
+ */
+int lv_replicator_sites_read(struct logical_volume *lv)
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
+	lv_replicator_sites_release(lv);
+	return 0;
+}
+
+/**
+ * Release all VG reources taken by replicator sites
+ * This function is used in activation context and needs all VGs already locked
+ */
+void lv_replicator_sites_release(struct logical_volume *lv)
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


