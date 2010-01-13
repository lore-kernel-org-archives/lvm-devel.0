From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:09 +0100
Subject: [PATCH 05/18] Replicator: add sorted vg_name_list
In-Reply-To: <cover.1263389894.git.zkabelac@redhat.com>
References: <cover.1263389894.git.zkabelac@redhat.com>
Message-ID: <e375768465b945065722b2e98ecfedac135987ac.1263389894.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce struct vg_name_list to store information about needed
volume group name and the pointer to opened VG.

VG must be opened in alphabetical order, thus elements in the list
are being kept ordered all the time.

Introduce functions vg_name_list_add(), vg_name_list_lookup().
They extend dm_list functionality.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |   17 ++++++++++++++
 lib/metadata/replicator_manip.c  |   45 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a80ad68..72f0e72 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -283,6 +283,14 @@ struct lv_segment_area {
 
 struct segment_type;
 
+/* List with VG names
+ * similar to  str_list with one extra pointer */
+struct vg_name_list {
+	struct dm_list list;
+	const char *name;
+	struct volume_group *vg;
+};
+
 /* ++ replicator datatypes */
 typedef enum {
 	REPLICATOR_ACTION_WARN,
@@ -790,6 +798,15 @@ int lv_is_slog(const struct logical_volume *lv);
 /* Returns first replicator-dev in site in case the LV is replicator-dev, NULL otherwise */
 struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 /* --  metadata/replicator_manip.c */
+/*
+ * Maintain the alphabeticaly ordered list, avoid duplications
+ * return either newly created or already present vg_name_list entry
+ */
+struct vg_name_list *vg_name_list_add(struct dm_pool *mem, struct dm_list *,
+				      const char *name);
+/* Find element with given name in vg_name_list list */
+struct vg_name_list *vg_name_list_lookup(struct dm_list *, const char *name);
+
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 0c5b9a1..afcbd86 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -314,3 +314,48 @@ struct logical_volume *first_replicator_dev(const struct logical_volume *lv)
 
 	return NULL;
 }
+
+/* Add to sorted list */
+struct vg_name_list *vg_name_list_add(struct dm_pool *mem, struct dm_list *l,
+				      const char *name)
+{
+	struct vg_name_list *vnl, *ins;
+
+	/* Is already in the list ? */
+	if ((vnl = vg_name_list_lookup(l, name)))
+		return vnl;
+
+	if (!(vnl = dm_pool_alloc(mem, sizeof(*vnl)))) {
+		log_error("Allocation of vg_name_list failed.");
+		return NULL;
+	}
+
+	if (!(vnl->name = dm_pool_strdup(mem, name))) {
+		dm_pool_free(mem, vnl);
+		log_error("Allocation of name failed.");
+		return NULL;
+	}
+
+	vnl->vg = NULL;
+	dm_list_iterate_items(ins, l)
+		if (strcmp(name, ins->name) < 0) {
+			l = &ins->list;
+			break;
+		}
+
+	dm_list_add(l, &vnl->list);
+
+	return vnl;
+}
+
+/* Lookup element with given name in ordered vg_name_list */
+struct vg_name_list *vg_name_list_lookup(struct dm_list *l, const char *name)
+{
+	struct vg_name_list *vnl;
+
+	dm_list_iterate_items(vnl, l)
+		if (!strcmp(name, vnl->name))
+			return vnl;
+
+	return NULL;
+}
-- 
1.6.6


