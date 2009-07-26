From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:34:36 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_lv.c
Message-ID: <20090726023436.17181.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:34:36

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_lv.c 

Log message:
	Add lvm_vg_create_lv_linear liblvm function.
	
	Create a default linear logical volume from a volume group.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/liblvm/.exported_symbols	2009/07/24 12:48:21	1.8
+++ LVM2/liblvm/.exported_symbols	2009/07/26 02:34:36	1.9
@@ -21,3 +21,4 @@
 lvm_vg_list_lvs
 lvm_list_vg_names
 lvm_list_vg_ids
+lvm_vg_create_lv_linear
--- LVM2/liblvm/lvm.h	2009/07/26 01:54:40	1.13
+++ LVM2/liblvm/lvm.h	2009/07/26 02:34:36	1.14
@@ -97,6 +97,26 @@
 int lvm_reload_config(lvm_t libh);
 
 /**
+ * Create a linear logical volume.
+ * This API commits the change to disk and does _not_ require calling
+ * lvm_vg_write.
+ * FIXME: This API should probably not commit to disk but require calling
+ * lvm_vg_write.  However, this appears to be non-trivial change until
+ * lv_create_single is refactored by segtype.
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
  * Return stored error no describing last LVM API error.
  *
  * Users of liblvm should use lvm_errno to determine success or failure
--- LVM2/liblvm/lvm_lv.c	2009/07/23 23:40:05	1.1
+++ LVM2/liblvm/lvm_lv.c	2009/07/26 02:34:36	1.2
@@ -16,6 +16,9 @@
 #include "lvm.h"
 #include "metadata-exported.h"
 #include "lvm-string.h"
+#include "defaults.h"
+#include "segtype.h"
+#include <string.h>
 
 char *lvm_lv_get_uuid(const lv_t *lv)
 {
@@ -38,3 +41,52 @@
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


