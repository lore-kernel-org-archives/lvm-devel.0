From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:34:25 +0200
Subject: [PATCH 10/23] Replicator: add sorted cmd_vg list
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <4357ba341359fd18e5e024778f62f7dc02656d3f.1272457502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce struct cmd_vg to store information about needed
volume group name, vgid, flags and the pointer to opened VG.

Keep VGs list in alphabetical order for locking order.

Introduce functions:
cmd_vg_add() add new cmd_vg entry.
cmd_vg_lookup() search cmd_vgs for vg_name.
cmd_vg_read() open VGs in cmd_vgs list.
cmd_vg_release() close VGs in reversed order.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |   16 +++++
 lib/metadata/replicator_manip.c  |  125 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 141 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index da1a230..c5a31d6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -298,6 +298,15 @@ struct lv_segment_area {
 
 struct segment_type;
 
+/* List with vg_name, vgid and flags */
+struct cmd_vg {
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
@@ -792,6 +801,13 @@ int lv_is_rlog(const struct logical_volume *lv);
 int lv_is_slog(const struct logical_volume *lv);
 struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 /* --  metadata/replicator_manip.c */
+struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,
+			  const char *vg_name, const char *vgid,
+			  uint32_t flags);
+struct cmd_vg *cmd_vg_lookup(struct dm_list *cmd_vgs,
+			     const char *vg_name, const char *vgid);
+int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs);
+void cmd_vg_release(struct dm_list *cmd_vgs);
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint32_t lv_type);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 26a0797..82ce23c 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -13,6 +13,7 @@
  */
 
 #include "lib.h"
+#include "locking.h"
 #include "metadata.h"
 #include "segtype.h"
 
@@ -477,3 +478,127 @@ struct logical_volume *first_replicator_dev(const struct logical_volume *lv)
 
 	return NULL;
 }
+
+/**
+ * Add VG open parameters to sorted cmd_vg list.
+ *
+ * Maintain the alphabeticaly ordered list, avoid duplications.
+ *
+ * \return	Returns newly created or already present cmd_vg entry,
+ *		or NULL in error case.
+ */
+struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,
+			  const char *vg_name, const char *vgid,
+			  uint32_t flags)
+{
+	struct cmd_vg *cvl, *ins;
+
+	if (!vg_name && !vgid) {
+		log_error("Either vg_name or vgid must be set.");
+		return NULL;
+	}
+
+	/* Is it already in the list ? */
+	if ((cvl = cmd_vg_lookup(cmd_vgs, vg_name, vgid)))
+		return cvl;
+
+	if (!(cvl = dm_pool_zalloc(mem, sizeof(*cvl)))) {
+		log_error("Allocation of cmd_vg failed.");
+		return NULL;
+	}
+
+	if (vg_name && !(cvl->vg_name = dm_pool_strdup(mem, vg_name))) {
+		dm_pool_free(mem, cvl);
+		log_error("Allocation of vg_name failed.");
+		return NULL;
+	}
+
+	if (vgid && !(cvl->vgid = dm_pool_strdup(mem, vgid))) {
+		dm_pool_free(mem, cvl);
+		log_error("Allocation of vgid failed.");
+		return NULL;
+	}
+
+	cvl->flags = flags;
+
+	if (vg_name)
+		dm_list_iterate_items(ins, cmd_vgs)
+			if (strcmp(vg_name, ins->vg_name) < 0) {
+				cmd_vgs = &ins->list; /* new position */
+				break;
+			}
+
+	dm_list_add(cmd_vgs, &cvl->list);
+
+	return cvl;
+}
+
+/**
+ * Find cmd_vg with given vg_name in cmd_vgs list.
+ *
+ * \param cmd_vgs	List of cmd_vg entries.
+ *
+ * \param vg_name	Name of VG to be found.
+
+ * \param vgid		UUID of VG to be found.
+ *
+ * \return		Returns cmd_vg entry if vg_name or vgid is found,
+ *			NULL otherwise.
+ */
+struct cmd_vg *cmd_vg_lookup(struct dm_list *cmd_vgs,
+			     const char *vg_name, const char *vgid)
+{
+	struct cmd_vg *cvl;
+
+	dm_list_iterate_items(cvl, cmd_vgs)
+		if ((vgid && cvl->vgid && !strcmp(vgid, cvl->vgid)) ||
+		    (vg_name && cvl->vg_name && !strcmp(vg_name, cvl->vg_name)))
+			return cvl;
+	return NULL;
+}
+
+/**
+ * Read and lock multiple VGs stored in cmd_vgs list alphabeticaly.
+ * On the success list head pointer is set to VGs' cmd_vgs.
+ * (supports FAILED_INCONSISTENT)
+ *
+ * \param cmd_vg	Contains list of cmd_vg entries.
+ *
+ * \return		Returns 1 if all VG in cmd_vgs list are correctly
+ *			openned and locked, 0 otherwise.
+ */
+int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs)
+{
+	struct cmd_vg *cvl;
+
+	/* Iterate through alphabeticaly ordered cmd_vg list */
+	dm_list_iterate_items(cvl, cmd_vgs) {
+		cvl->vg = vg_read(cmd, cvl->vg_name, cvl->vgid, cvl->flags);
+		if (vg_read_error(cvl->vg)) {
+			log_debug("Failed to vg_read %s", cvl->vg_name);
+			return 0;
+		}
+		cvl->vg->cmd_vgs = cmd_vgs;	/* Make it usable in VG */
+	}
+
+	return 1;
+}
+
+/**
+ * Release opened and locked VGs from list.
+ *
+ * \param cmd_vgs	Contains list of cmd_vg entries.
+ */
+void cmd_vg_release(struct dm_list *cmd_vgs)
+{
+	struct cmd_vg *cvl;
+
+	/* Backward iterate cmd_vg list */
+	dm_list_iterate_back_items(cvl, cmd_vgs) {
+		if (vg_read_error(cvl->vg))
+			vg_release(cvl->vg);
+		else
+			unlock_and_release_vg(cvl->vg->cmd, cvl->vg, cvl->vg_name);
+		cvl->vg = NULL;
+	}
+}
-- 
1.7.0.1


