From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 12 Apr 2010 17:21:37 +0200
Subject: [PATCH 09/22] Replicator: add sorted vgs_list
In-Reply-To: <cover.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
Message-ID: <4ac472dac5d9b6fe6833e169e5ccddceab1fa014.1271085009.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce struct vgs_list to store information about needed
volume group name, vgid, flags and the pointer to opened VG.

Keep VGs list in alphabetical order for locking order.

Introduce functions:
vgs_list_add() add new vgs_list entry.
vgs_list_lookup() search for vgs_list for vg_name.
vgs_list_read() open list of VGs.
vgs_list_release() close VGs in reversed order.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |   20 ++++++
 lib/metadata/replicator_manip.c  |  138 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 158 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9c73dba..0f00d7a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -288,6 +288,15 @@ struct lv_segment_area {
 
 struct segment_type;
 
+/* List with vg_name, vgid and flags */
+struct vgs_list {
+	struct dm_list list;
+	const char *vg_name;
+	const char *vgid;
+	uint32_t flags;
+	struct volume_group *vg;
+};
+
 /* ++ Replicator datatypes */
 typedef enum {
 	REPLICATOR_STATE_PASSIVE,
@@ -780,6 +789,17 @@ int lv_is_rlog(const struct logical_volume *lv);
 int lv_is_slog(const struct logical_volume *lv);
 struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 /* --  metadata/replicator_manip.c */
+struct vgs_list *vgs_list_add(struct dm_pool *mem,
+			      struct dm_list *vg_nlist,
+			      const char *vg_name, const char *vgid,
+			      uint32_t flags);
+struct vgs_list *vgs_list_lookup(struct dm_list *vg_nlist,
+				 const char *vg_name);
+
+int vgs_list_read(struct cmd_context *cmd, struct dm_list *vgs_list,
+		  struct vgs_list *vnl_vg);
+void vgs_list_release(struct dm_list *vgs_list,
+		      struct vgs_list *vnl_vg);
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 7062a32..8b5d8fe 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -490,3 +490,141 @@ struct logical_volume *first_replicator_dev(const struct logical_volume *lv)
 
 	return NULL;
 }
+
+/**
+ * Add VG to sorted VGs list
+ *
+ * Maintain the alphabeticaly ordered list, avoid duplications.
+ *
+ * \return
+ * Returns newly created or already present vgs_list entry.
+ * Returns NULL in error case.
+ */
+struct vgs_list *vgs_list_add(struct dm_pool *mem,
+			      struct dm_list *list,
+			      const char *vg_name,
+			      const char *vgid,
+			      uint32_t flags)
+{
+	struct vgs_list *vgsl, *ins;
+
+	/* Is already in the list ? */
+	if ((vgsl = vgs_list_lookup(list, vg_name)))
+		return vgsl;
+
+	if (!(vgsl = dm_pool_alloc(mem, sizeof(*vgsl)))) {
+		log_error("Allocation of vgs_list failed.");
+		return NULL;
+	}
+
+	if (!(vgsl->vg_name = dm_pool_strdup(mem, vg_name))) {
+		dm_pool_free(mem, vgsl);
+		log_error("Allocation of vg_name failed.");
+		return NULL;
+	}
+
+	if (vgid &&
+	    !(vgsl->vgid = dm_pool_strdup(mem, vgid))) {
+		dm_pool_free(mem, vgsl);
+		log_error("Allocation of vgid failed.");
+		return NULL;
+	} else
+		vgsl->vgid = NULL;
+
+	vgsl->flags = flags;
+	vgsl->vg = NULL;
+	dm_list_iterate_items(ins, list)
+		if (strcmp(vg_name, ins->vg_name) < 0) {
+			list = &ins->list;
+			break;
+		}
+
+	dm_list_add(list, &vgsl->list);
+
+	return vgsl;
+}
+
+/**
+ * Find vgs_list with given vg_name in VGs list.
+ *
+ * \param list
+ * List of vgs_list elements.
+ * \param vg_name
+ * Name of VG to be found.
+ * \return
+ * Returns vgs_list element with VG if vg_name is found.
+ * Returns NULL if vg_name is not found.
+ */
+struct vgs_list *vgs_list_lookup(struct dm_list *l, const char *vg_name)
+{
+	struct vgs_list *vgsl;
+
+	dm_list_iterate_items(vgsl, l)
+		if (!strcmp(vg_name, vgsl->vg_name))
+			return vgsl;
+
+	return NULL;
+}
+
+/**
+ * Read and lock multiple VGs stored in vgs_list alphabeticaly.
+ * On the success list is spliced to vgs_vg->vg vgs list and left
+ * UNINITIALIZED and shall NOT be used until calling vgs_list_release().
+ *
+ * \param list
+ * Contains list of vgs_list entries.
+ * \param vgs_vg
+ * Contains master VGs list.
+ *
+ * \return
+ * Returns 1 if all VG in vgs_list are correctly openned and locked.
+ * Returns 0 if there is some problem with any VG.
+ * 
+ * (Needed to allow support for FAILED_INCONSISTENT)
+ */
+int vgs_list_read(struct cmd_context *cmd, struct dm_list *list,
+		  struct vgs_list *vgs_vg)
+{
+	struct vgs_list *vgsl;
+
+	/* Iterate through alphabeticaly ordered VGs list */
+	dm_list_iterate_items(vgsl, list) {
+		vgsl->vg = vg_read(cmd, vgsl->vg_name, vgsl->vgid, vgsl->flags);
+		if (vg_read_error(vgsl->vg)) {
+			log_debug("Failed to vg_read %s", vgsl->vg_name);
+			return 0;
+		}
+	}
+
+	dm_list_init(&vgs_vg->vg->vgs);
+	dm_list_splice(list, &vgs_vg->vg->vgs);
+
+	return 1;
+}
+
+/**
+ * Release opened and locked VGs from list.
+ * List is spliced back from vgs_vg to list.
+ *
+ * \param list
+ * Contains list of vgs_list entries.
+ * \param vgs_vg
+ * Contains master VG with vgs list of active VGs.
+ */
+void vgs_list_release(struct dm_list *list, struct vgs_list *vgs_vg)
+{
+	struct vgs_list *vgsl;
+
+	if (!vg_read_error(vgs_vg->vg)) {
+		dm_list_init(list);
+		dm_list_splice(&vgs_vg->vg->vgs, list);
+	}
+
+	dm_list_iterate_back_items(vgsl, list) {
+		if (vg_read_error(vgsl->vg))
+			vg_release(vgsl->vg);
+		else
+			unlock_and_release_vg(vgsl->vg->cmd, vgsl->vg, vgsl->vg_name);
+		vgsl->vg = NULL;
+	}
+}
-- 
1.7.0.1


