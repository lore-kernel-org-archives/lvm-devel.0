From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:47:01 +0100
Subject: [PATCH 08/25] Replicator: add sorted vg_name_list
In-Reply-To: <cover.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
Message-ID: <805dce431c20b6fa3c9f1ca9b128a5404f16b993.1268833246.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce struct vg_name_list to store information about needed
volume group name, vgid, flags and the pointer to opened VG.

Keep VG in list in alphabetical order for locking order.

Introduce functions vg_name_list_add(), vg_name_list_lookup(),
vg_name_list_splice().  They extend dm_list functionality.

vg_name_list_read() open list of VGs.
vg_name_list_release close VGs in reversed order.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |   21 ++++++
 lib/metadata/replicator_manip.c  |  148 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 169 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ac0681e..594c0b0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -288,6 +288,15 @@ struct lv_segment_area {
 
 struct segment_type;
 
+/* List with VG names */
+struct vg_name_list {
+	struct dm_list list;
+	const char *vg_name;
+	const char *vgid;
+	uint32_t flags;
+	struct volume_group *vg;
+};
+
 /* ++ replicator datatypes */
 typedef enum {
 	REPLICATOR_STATE_PASSIVE,
@@ -778,6 +787,18 @@ int lv_is_rlog(const struct logical_volume *lv);
 int lv_is_slog(const struct logical_volume *lv);
 struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 /* --  metadata/replicator_manip.c */
+void vg_name_list_splice(struct dm_list *list, struct dm_list *head);
+struct vg_name_list *vg_name_list_add(struct dm_pool *mem,
+				      struct dm_list *vg_nlist,
+				      const char *vg_name, const char *vgid,
+				      uint32_t flags);
+struct vg_name_list *vg_name_list_lookup(struct dm_list *vg_nlist,
+					 const char *vg_name);
+
+int vg_name_list_read(struct cmd_context *cmd, struct dm_list *vgs_list,
+		      struct vg_name_list *vnl_vg);
+void vg_name_list_release(struct dm_list *vgs_list,
+			  struct vg_name_list *vnl_vg);
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 8ecb3a1..52a7fcb 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -338,3 +338,151 @@ struct logical_volume *first_replicator_dev(const struct logical_volume *lv)
 
 	return NULL;
 }
+
+/**
+ * Join 'list' to 'head'
+ * CHECKME: introduce generic dm_list_splice()?
+ * syntax similar to linux kernel's list_splice()
+ */
+void vg_name_list_splice(struct dm_list *list, struct dm_list *head)
+{
+	struct dm_list *first = list->n;
+	struct dm_list *last = list->p;
+	struct dm_list *at = head->n;
+
+	struct vg_name_list *vnl;
+	dm_list_iterate_items(vnl, list)
+		log_debug("Before from list %s", vnl->vg_name);
+	dm_list_iterate_items(vnl, head)
+		log_debug("Before to head %s", vnl->vg_name);
+	first->p = head;
+	head->n = first;
+	last->n = at;
+	at->p = last;
+
+	dm_list_iterate_items(vnl, head)
+		log_debug("After head %s", vnl->vg_name);
+}
+
+/**
+ * Add to sorted list
+ *
+ * Maintain the alphabeticaly ordered list, avoid duplications
+ * return either newly created or already present vg_name_list entry
+ */
+struct vg_name_list *vg_name_list_add(struct dm_pool *mem,
+				      struct dm_list *l,
+				      const char *vg_name,
+				      const char *vgid,
+				      uint32_t flags)
+{
+	struct vg_name_list *vnl, *ins;
+
+	/* Is already in the list ? */
+	if ((vnl = vg_name_list_lookup(l, vg_name)))
+		return vnl;
+
+	if (!(vnl = dm_pool_alloc(mem, sizeof(*vnl)))) {
+		log_error("Allocation of vg_name_list failed.");
+		return NULL;
+	}
+
+	if (!(vnl->vg_name = dm_pool_strdup(mem, vg_name))) {
+		dm_pool_free(mem, vnl);
+		log_error("Allocation of vg_name failed.");
+		return NULL;
+	}
+
+	if (vgid &&
+	    !(vnl->vgid = dm_pool_strdup(mem, vgid))) {
+		dm_pool_free(mem, vnl);
+		log_error("Allocation of vgid failed.");
+		return NULL;
+	} else
+		vnl->vgid = NULL;
+
+	vnl->flags = flags;
+	vnl->vg = NULL;
+	dm_list_iterate_items(ins, l)
+		if (strcmp(vg_name, ins->vg_name) < 0) {
+			l = &ins->list;
+			break;
+		}
+
+	dm_list_add(l, &vnl->list);
+
+	return vnl;
+}
+
+/**
+ * Find element with given vg_name in vg_name_list list
+ */
+struct vg_name_list *vg_name_list_lookup(struct dm_list *l, const char *vg_name)
+{
+	struct vg_name_list *vnl;
+
+	dm_list_iterate_items(vnl, l)
+		if (!strcmp(vg_name, vnl->vg_name))
+			return vnl;
+
+	return NULL;
+}
+
+/**
+ * Read and lock multiple VGs stored in vgs_list alphabeticaly
+ * \param vgs_list
+ * When vnl_vg is correctly opened vgs_list is spliced to vnl_vg->vg->vgs
+ * and left uninitialized and shall not be used until call of
+ * vg_name_list_release().
+ *
+ * \return
+ * Returns 1 if all VG in vgs_list are correctly openned and locked.
+ * Returns 0 if there is some problem with any VG.
+ * 
+ * (Needed to allow support for FAILED_INCONSISTENT)
+ */
+int vg_name_list_read(struct cmd_context *cmd, struct dm_list *vgs_list,
+		      struct vg_name_list *vnl_vg)
+{
+	struct vg_name_list *vnl;
+
+	/* Iterate through alphabeticaly ordered vg_name_list */
+	dm_list_iterate_items(vnl, vgs_list) {
+		vnl->vg = vg_read(cmd, vnl->vg_name, vnl->vgid, vnl->flags);
+		if (vg_read_error(vnl->vg)) {
+			log_debug("Failed to vg_read %s", vnl->vg_name);
+			return 0;
+		}
+	}
+
+	dm_list_init(&vnl_vg->vg->vgs);
+	vg_name_list_splice(vgs_list, &vnl_vg->vg->vgs);
+
+	return 1;
+}
+
+/**
+ * Release opened and locked VGs from vg_nlist
+ *
+ * \param vgs_list
+ * \param vnl_vg
+ * Contains VG with vg_name_list of active VGs, list is spliced to vgs_list
+ */
+void vg_name_list_release(struct dm_list *vgs_list,
+			  struct vg_name_list *vnl_vg)
+{
+	struct vg_name_list *vnl;
+
+	if (vnl_vg->vg) {
+		dm_list_init(vgs_list);
+		vg_name_list_splice(&vnl_vg->vg->vgs, vgs_list);
+	}
+
+	dm_list_iterate_back_items(vnl, vgs_list) {
+		if (vg_read_error(vnl->vg))
+			vg_release(vnl->vg);
+		else
+			unlock_and_release_vg(vnl->vg->cmd, vnl->vg, vnl->vg_name);
+		vnl->vg = NULL;
+	}
+}
-- 
1.7.0.1


