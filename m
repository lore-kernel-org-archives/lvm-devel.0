From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Jul 2009 20:08:18 -0400
Subject: [PATCH 09/11] Add lvm_vg_create_lv_* liblvm functions.
In-Reply-To: <1248480500-472-9-git-send-email-dwysocha@redhat.com>
References: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
	<1248480500-472-2-git-send-email-dwysocha@redhat.com>
	<1248480500-472-3-git-send-email-dwysocha@redhat.com>
	<1248480500-472-4-git-send-email-dwysocha@redhat.com>
	<1248480500-472-5-git-send-email-dwysocha@redhat.com>
	<1248480500-472-6-git-send-email-dwysocha@redhat.com>
	<1248480500-472-7-git-send-email-dwysocha@redhat.com>
	<1248480500-472-8-git-send-email-dwysocha@redhat.com>
	<1248480500-472-9-git-send-email-dwysocha@redhat.com>
Message-ID: <1248480500-472-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Create a default linear or striped logical volume from a volume group.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    2 +
 liblvm/lvm.h             |   32 ++++++++++++++++++
 liblvm/lvm_lv.c          |   83 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 117 insertions(+), 0 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 08d5a60..257a13b 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -21,3 +21,5 @@ lvm_vg_list_pvs
 lvm_vg_list_lvs
 lvm_list_vg_names
 lvm_list_vg_ids
+lvm_vg_create_lv_linear
+lvm_vg_create_lv_striped
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index c2157a8..d906170 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -97,6 +97,38 @@ void lvm_destroy(lvm_t libh);
 int lvm_reload_config(lvm_t libh);
 
 /**
+ * Create a linear logical volume.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   name
+ *          Name of logical volume to create.
+ *
+ * \param   size
+ *          Size of logical volume in extents.
+ *
+ */
+lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
+
+/**
+ * Create a striped logical volume.
+ * The striped LV defaults to the following:
+ * - stripes == 1
+ * - stripe_size == 64KB
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   name
+ *          Name of logical volume to create.
+ *
+ * \param   size
+ *          Size of logical volume in extents.
+ */
+lv_t *lvm_vg_create_lv_striped(vg_t *vg, const char *name, uint64_t size);
+
+/**
  * Return stored error no describing last LVM API error.
  *
  * Users of liblvm should use lvm_errno to determine success or failure
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index d557350..098ad8d 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -16,6 +16,9 @@
 #include "lvm.h"
 #include "metadata-exported.h"
 #include "lvm-string.h"
+#include "defaults.h"
+#include "segtype.h"
+#include <string.h>
 
 char *lvm_lv_get_uuid(const lv_t *lv)
 {
@@ -38,3 +41,83 @@ char *lvm_lv_get_name(const lv_t *lv)
 	return name;
 }
 
+/* Set defaults for non-segment specific LV parameters */
+static void _lv_set_default_params(struct lvcreate_params *lp,
+				   vg_t *vg, const char *lvname,
+				   uint64_t extents)
+{
+	lp->zero = 1;
+	lp->major = -1;
+	lp->minor = -1;
+	lp->vg_name = vg->name;
+	lp->lv_name = lvname; /* FIXME: check this for safety */
+	lp->pvh = &vg->pvs;
+
+	lp->extents = extents;
+	lp->permission = LVM_READ | LVM_WRITE;
+	lp->read_ahead = DM_READ_AHEAD_NONE;
+	lp->alloc = ALLOC_INHERIT;
+	lp->tag = NULL;
+}
+
+/* Set default for linear segment specific LV parameters */
+static void _lv_set_default_linear_params(struct cmd_context *cmd,
+					  struct lvcreate_params *lp)
+{
+	lp->segtype = get_segtype_from_string(cmd, "striped");
+	lp->stripes = 1;
+	lp->stripe_size = DEFAULT_STRIPESIZE * 2;
+}
+
+/* Set defaults for striped segment specific LV parameters */
+static void _lv_set_default_striped_params(struct cmd_context *cmd,
+					   struct lvcreate_params *lp)
+{
+	lp->stripes = 1;
+	lp->stripe_size = DEFAULT_STRIPESIZE * 2;
+	lp->segtype = get_segtype_from_string(cmd, "striped");
+}
+
+lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size)
+{
+	struct lvcreate_params lp;
+	uint64_t extents;
+	struct lv_list *lvl;
+
+	/* FIXME: check for proper VG access */
+	if (vg_read_error(vg))
+		return NULL;
+	memset(&lp, 0, sizeof(lp));
+	extents = extents_from_size(vg->cmd, size, vg->extent_size);
+	_lv_set_default_params(&lp, vg, name, extents);
+	_lv_set_default_linear_params(vg->cmd, &lp);
+	if (!lv_create_single(vg, &lp))
+		return NULL;
+	lvl = find_lv_in_vg(vg, name);
+	if (!lvl)
+		return NULL;
+	return lvl->lv;
+}
+
+
+lv_t *lvm_vg_create_lv_striped(vg_t *vg, const char *name, uint64_t size)
+{
+	struct lvcreate_params lp;
+	uint64_t extents;
+	struct lv_list *lvl;
+
+	/* FIXME: check for proper VG access */
+	if (vg_read_error(vg))
+		return NULL;
+
+	memset(&lp, 0, sizeof(lp));
+	extents = extents_from_size(vg->cmd, size, vg->extent_size);
+	_lv_set_default_params(&lp, vg, name, extents);
+	_lv_set_default_striped_params(vg->cmd, &lp);
+	if (!lv_create_single(vg, &lp))
+		return NULL;
+	lvl = find_lv_in_vg(vg, name);
+	if (!lvl)
+		return NULL;
+	return lvl->lv;
+}
-- 
1.6.0.6


