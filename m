From: Tony Asleson <tasleson@redhat.com>
Date: Mon,  1 Apr 2013 16:35:00 -0500
Subject: [PATCH 6/7] lvm2app: Add function to retrieve list of PVs
In-Reply-To: <1364852101-14961-1-git-send-email-tasleson@redhat.com>
References: <1364852101-14961-1-git-send-email-tasleson@redhat.com>
Message-ID: <1364852101-14961-6-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As locks are held, you need to call the included function
to release the memory and locks when done transversing the
list of physical volumes.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata-exported.h |  12 +++-
 lib/metadata/metadata.c          |  81 +++++++++++++++------
 liblvm/lvm2app.h                 |  28 ++++++++
 liblvm/lvm_pv.c                  |  79 ++++++++++++++++++++
 python/liblvm.c                  | 152 ++++++++++++++++++++++++++++++++++++---
 5 files changed, 322 insertions(+), 30 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b9b925b..b73fdb9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -393,6 +393,11 @@ struct lv_list {
 	struct logical_volume *lv;
 };
 
+struct vg_list {
+	struct dm_list list;
+	struct volume_group *vg;
+};
+
 #define PV_PE_START_CALC ((uint64_t) -1) /* Calculate pe_start value */
 
 struct pvcreate_restorable_params {
@@ -480,7 +485,12 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_na
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				int warnings,
 				int scan_label_only);
-struct dm_list *get_pvs(struct cmd_context *cmd);
+
+#define get_pvs( cmd ) get_pvs_internal((cmd), NULL, NULL)
+#define get_pvs_perserve_vg( cmd, pv_list, vg_list ) get_pvs_internal((cmd), (pv_list), (vg_list))
+
+struct dm_list *get_pvs_internal(struct cmd_context *cmd,
+		struct dm_list *pvslist, struct dm_list *vgslist);
 
 /*
  * Add/remove LV to/from volume group
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 911a4c8..b6f54d4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3667,7 +3667,8 @@ struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal)
 	return lvmcache_get_vgids(cmd, include_internal);
 }
 
-static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvslist)
+static int _get_pvs(struct cmd_context *cmd, int warnings,
+		struct dm_list *pvslist, struct dm_list *vgslist)
 {
 	struct str_list *strl;
 	struct dm_list * uninitialized_var(results);
@@ -3677,18 +3678,11 @@ static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvsl
 	struct volume_group *vg;
 	int consistent = 0;
 	int old_pvmove;
+	struct vg_list *vgl_item = NULL;
+	int have_pv = 0;
 
 	lvmcache_label_scan(cmd, 0);
 
-	if (pvslist) {
-		if (!(results = dm_pool_alloc(cmd->mem, sizeof(*results)))) {
-			log_error("PV list allocation failed");
-			return 0;
-		}
-
-		dm_list_init(results);
-	}
-
 	/* Get list of VGs */
 	if (!(vgids = get_vgids(cmd, 1))) {
 		log_error("get_pvs: get_vgids failed");
@@ -3724,33 +3718,78 @@ static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvsl
 					release_vg(vg);
 					return 0;
 				}
-				dm_list_add(results, &pvl_copy->list);
+				/* If we are going to release the vg, don't store a pointer to
+				 * it in the pv structure.
+				 */
+				if (!vgslist) {
+					pvl_copy->pv->vg = NULL;
+				}
+				have_pv = 1;
+				dm_list_add(pvslist, &pvl_copy->list);
 			}
-		release_vg(vg);
+
+		/* In the case of the library we want to preserve the embedded volume
+		 * group as subsequent calls to retrieve data about the pv require it.
+		 */
+		if (!vgslist || have_pv == 0) {
+			release_vg(vg);
+		} else {
+			/* Add vg to list of vg objects that will be returned
+			 */
+			vgl_item = dm_pool_alloc(cmd->mem, sizeof(*vgl_item));
+			if (!vgl_item) {
+				log_error("VG list element allocation failed");
+				return 0;
+			}
+			vgl_item->vg = vg;
+			vg = NULL;
+			dm_list_add(vgslist, &vgl_item->list);
+		}
+		have_pv = 0;
 	}
 	init_pvmove(old_pvmove);
 
-	if (pvslist)
-		*pvslist = results;
-	else
+	if (!pvslist) {
 		dm_pool_free(cmd->mem, vgids);
-
+	}
 	return 1;
 }
 
-struct dm_list *get_pvs(struct cmd_context *cmd)
+/* Retrieve a list of all physical volumes.
+ * @param 	cmd			Command context
+ * @param	pvslist		Set to NULL if you want memory for list created,
+ * 						else valid memory
+ * @param	vgslist		Set to NULL if you need the pv structures to contain
+ * 						valid vg pointer.  This is the list of VGs
+ * @returns NULL on errors, else pvslist which will equal passes in value if
+ * 	supplied.
+ */
+struct dm_list *get_pvs_internal(struct cmd_context *cmd,
+					struct dm_list *pvslist, struct dm_list *vgslist)
 {
-	struct dm_list *results;
+	struct dm_list *results = pvslist;
 
-	if (!_get_pvs(cmd, 1, &results))
-		return NULL;
+	if (NULL == results) {
+		if (!(results = dm_pool_alloc(cmd->mem, sizeof(*results)))) {
+			log_error("PV list allocation failed");
+			return 0;
+		}
+
+		dm_list_init(results);
+	}
 
+	if (!_get_pvs(cmd, 1, results, vgslist)) {
+		if (NULL == pvslist) {
+			dm_pool_free(cmd->mem, results);
+		}
+		return NULL;
+	}
 	return results;
 }
 
 int scan_vgs_for_pvs(struct cmd_context *cmd, int warnings)
 {
-	return _get_pvs(cmd, warnings, NULL);
+	return _get_pvs(cmd, warnings, NULL, NULL);
 }
 
 int pv_write(struct cmd_context *cmd __attribute__((unused)),
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 98585c0..a17d5ac 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -534,6 +534,34 @@ vg_t lvm_vg_create(lvm_t libh, const char *vg_name);
 struct dm_list *lvm_vg_list_lvs(vg_t vg);
 
 /**
+ * Return a list of PV handles for all.
+ *
+ * \memberof lvm_t
+ *
+ * \param   libh
+ * Library handle retrieved from lvm_init
+ *
+ * \return
+ * A list of lvm_pv_list structures containing pv handles for all physical
+ * volumes. If no PVs exist or a global lock was unable to be obtained a
+ * NULL is returned.
+ */
+struct dm_list *lvm_list_pvs(lvm_t libh);
+
+/**
+ * Free the resources used by acquiring the pvlist.  This should be called as
+ * soon as possible after processing the needed information from the pv list as
+ * a global locks are held.
+ *
+ * \param	pvlist
+ * PV list to be freed
+ * 
+ * \return
+ * 0 on success, else -1 with library errno and text set.
+ */
+int lvm_list_pvs_free(struct dm_list *pvlist);
+
+/**
  * Return a list of PV handles for a given VG handle.
  *
  * \memberof vg_t
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index bf9f630..dcb1a29 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -12,11 +12,14 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include <stddef.h>
 #include "lib.h"
 #include "metadata.h"
 #include "lvm-string.h"
 #include "lvm_misc.h"
 #include "lvm2app.h"
+#include "locking.h"
+#include "toolcontext.h"
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
@@ -60,6 +63,82 @@ struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
 	return get_property(NULL, NULL, NULL, NULL, pvseg, name);
 }
 
+
+#define address_of(p, t, m) ({                  \
+	const typeof( ((t *)0)->m ) *__mptr = (p);    \
+	(t *)( (char *)__mptr - offsetof(t,m) );})
+
+struct lvm_list_wrapper
+{
+	unsigned long magic;
+	struct dm_list pvslist;
+	struct dm_list vgslist;
+};
+
+
+struct dm_list *lvm_list_pvs(lvm_t libh)
+{
+	struct lvm_list_wrapper *rc = NULL;
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+
+
+	rc = dm_pool_zalloc(cmd->mem, sizeof(*rc));
+	if (!rc) {
+		log_errno(ENOMEM, "Memory allocation fail for pv list.");
+		return NULL;
+	}
+
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE)) {
+		log_errno(ENOLCK, "Unable to obtain global lock.");
+	} else {
+		dm_list_init(&rc->pvslist);
+		dm_list_init(&rc->vgslist);
+		if( !get_pvs_perserve_vg(cmd, &rc->pvslist, &rc->vgslist) ) {
+			dm_pool_free(cmd->mem, rc);
+			return NULL;
+		}
+		rc->magic = 0xF005BA11;
+	}
+
+	return &rc->pvslist;
+}
+
+int lvm_list_pvs_free(struct dm_list *pvlist)
+{
+	int rc = 0;
+	struct lvm_list_wrapper *to_delete = NULL;
+	struct vg_list *vgl = NULL;
+	struct vg_list *tmp_vgl = NULL;
+	struct pv_list *pvl = NULL;
+	struct pv_list *tmp_pvl = NULL;
+	struct cmd_context *cmd = NULL;
+
+	if (pvlist ) {
+		to_delete = address_of(pvlist, struct lvm_list_wrapper, pvslist);
+		if (to_delete->magic == 0xF005BA11) {
+
+			dm_list_iterate_items(vgl, &to_delete->vgslist) {
+				cmd = vgl->vg->cmd;
+				release_vg(vgl->vg);
+			}
+
+			dm_list_iterate_items(pvl, &to_delete->pvslist) {
+				free_pv_fid(pvl->pv);
+			}
+
+			unlock_vg(cmd, VG_GLOBAL);
+		} else {
+			log_errno(EINVAL, "Not a correct pvlist structure");
+			rc = -1;
+		}
+
+		to_delete->magic = 0xA5A5A5A5;
+		dm_pool_free(cmd->mem, to_delete);
+
+	}
+	return rc;
+}
+
 struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
 {
 	struct dm_list *list;
diff --git a/python/liblvm.c b/python/liblvm.c
index 906825e..928cab0 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -34,6 +34,11 @@ typedef struct {
 
 typedef struct {
 	PyObject_HEAD
+	struct dm_list *pvslist;
+} pvslistobject;
+
+typedef struct {
+	PyObject_HEAD
 	lv_t lv;		/* lv handle */
 	vgobject *parent_vgobj;
 } lvobject;
@@ -42,6 +47,7 @@ typedef struct {
 	PyObject_HEAD
 	pv_t pv;		/* pv handle */
 	vgobject *parent_vgobj;
+	pvslistobject *parent_pvslistobj;
 } pvobject;
 
 typedef struct {
@@ -58,6 +64,7 @@ typedef struct {
 
 static PyTypeObject LibLVMvgType;
 static PyTypeObject LibLVMlvType;
+static PyTypeObject LibLVMpvlistType;
 static PyTypeObject LibLVMpvType;
 static PyTypeObject LibLVMlvsegType;
 static PyTypeObject LibLVMpvsegType;
@@ -153,6 +160,90 @@ liblvm_lvm_list_vg_uuids(void)
 }
 
 static PyObject *
+liblvm_lvm_pvlist_get(pvslistobject *pvsobj)
+{
+	struct lvm_pv_list *pvl;
+	PyObject * pytuple;
+	pvobject * pvobj;
+	int i = 0;
+
+	/* unlike other LVM api calls, if there are no results, we get NULL */
+	pvsobj->pvslist = lvm_list_pvs(libh);
+
+	if (!pvsobj->pvslist)
+		return Py_BuildValue("()");
+
+	pytuple = PyTuple_New(dm_list_size(pvsobj->pvslist));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(pvl, pvsobj->pvslist) {
+		/* Create and initialize the object */
+		pvobj = PyObject_New(pvobject, &LibLVMpvType);
+		if (!pvobj) {
+			Py_DECREF(pytuple);
+			return NULL;
+		}
+
+		/* We don't have a parent vg object to be concerned about */
+		pvobj->parent_vgobj = NULL;
+		pvobj->parent_pvslistobj = pvsobj;
+		Py_INCREF(pvobj->parent_pvslistobj);
+
+		pvobj->pv = pvl->pv;
+		PyTuple_SET_ITEM(pytuple, i, (PyObject *) pvobj);
+		i++;
+	}
+
+	return pytuple;
+}
+
+static PyObject *
+liblvm_lvm_pvlist_put(pvslistobject *self)
+{
+	int rc = 0;
+	if (self->pvslist) {
+		rc = lvm_list_pvs_free(self->pvslist);
+
+		if ( 0 != rc ) {
+			PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+			return NULL;
+		}
+
+		self->pvslist = NULL;
+		Py_INCREF(Py_None);
+		return Py_None;
+	}
+	return NULL;
+}
+
+static PyObject *
+liblvm_pvlist_dealloc(pvslistobject *self)
+{
+	if (self->pvslist) {
+		liblvm_lvm_pvlist_put(self);
+	}
+
+	PyObject_Del(self);
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_list_pvs(void)
+{
+	pvslistobject *pvslistobj;
+
+	LVM_VALID();
+
+	if ((pvslistobj = PyObject_New(pvslistobject, &LibLVMpvlistType)) == NULL)
+			return NULL;
+
+	pvslistobj->pvslist = NULL;
+	return (PyObject *)pvslistobj;
+}
+
+static PyObject *
 liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
 {
 	double converted;
@@ -360,6 +451,15 @@ liblvm_vg_dealloc(vgobject *self)
 		}							\
 	} while (0)
 
+#define PVSLIST_VALID(pvslistobject)			\
+	do {										\
+		LVM_VALID();							\
+		if (!pvslistobject->pvslist) {			\
+			PyErr_SetString(PyExc_UnboundLocalError, "PVS object invalid"); \
+			return NULL;						\
+		}										\
+	} while (0)
+
 static PyObject *
 liblvm_lvm_vg_close(vgobject *self)
 {
@@ -1030,7 +1130,16 @@ liblvm_lvm_pv_from_uuid(vgobject *self, PyObject *arg)
 static void
 liblvm_pv_dealloc(pvobject *self)
 {
-	Py_DECREF(self->parent_vgobj);
+	if (self->parent_vgobj) {
+		Py_DECREF(self->parent_vgobj);
+	}
+
+	if (self->parent_pvslistobj) {
+		Py_DECREF(self->parent_pvslistobj);
+	}
+
+	self->parent_vgobj = NULL;
+	self->parent_pvslistobj = NULL;
 	PyObject_Del(self);
 }
 
@@ -1337,19 +1446,23 @@ liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 
 	lvobj->parent_vgobj = self->parent_vgobj;
 	Py_INCREF(lvobj->parent_vgobj);
-
 	return (PyObject *)lvobj;
 }
 
 /* PV Methods */
 
-#define PV_VALID(pvobject)						\
-	do {								\
-		VG_VALID(pvobject->parent_vgobj);			\
-		if (!pvobject->pv) {					\
+#define PV_VALID(pvobject)								\
+	do {												\
+		if (pvobject->parent_vgobj) {					\
+			VG_VALID(pvobject->parent_vgobj);			\
+		}												\
+		if (pvobject->parent_pvslistobj) {				\
+			PVSLIST_VALID(pvobject->parent_pvslistobj);	\
+		}												\
+		if (!pvobject->pv) {							\
 			PyErr_SetString(PyExc_UnboundLocalError, "PV object invalid"); \
-			return NULL;					\
-		}							\
+			return NULL;								\
+		}												\
 	} while (0)
 
 static PyObject *
@@ -1550,6 +1663,7 @@ static PyMethodDef Liblvm_methods[] = {
 	{ "scan",		(PyCFunction)liblvm_lvm_scan, METH_NOARGS },
 	{ "listVgNames",	(PyCFunction)liblvm_lvm_list_vg_names, METH_NOARGS },
 	{ "listVgUuids",	(PyCFunction)liblvm_lvm_list_vg_uuids, METH_NOARGS },
+	{ "listPvs",		(PyCFunction)liblvm_lvm_list_pvs, METH_NOARGS },
 	{ "percentToFloat",	(PyCFunction)liblvm_lvm_percent_to_float, METH_VARARGS },
 	{ "vgNameFromPvid",	(PyCFunction)liblvm_lvm_vgname_from_pvid, METH_VARARGS },
 	{ "vgNameFromDevice",	(PyCFunction)liblvm_lvm_vgname_from_device, METH_VARARGS },
@@ -1613,6 +1727,15 @@ static PyMethodDef liblvm_lv_methods[] = {
 	{ NULL, NULL }		/* sentinel */
 };
 
+static PyMethodDef liblvm_pv_list_methods[] = {
+	/* pv list methods */
+	{ "__enter__", 	(PyCFunction)liblvm_lvm_pvlist_get, METH_VARARGS },
+	{ "__exit__", 	(PyCFunction)liblvm_lvm_pvlist_put, METH_VARARGS },
+	{ "open",		(PyCFunction)liblvm_lvm_pvlist_get, METH_VARARGS }, 
+	{ "close",		(PyCFunction)liblvm_lvm_pvlist_put, METH_VARARGS }, 
+	{ NULL, NULL }
+};
+
 static PyMethodDef liblvm_pv_methods[] = {
 	/* pv methods */
 	{ "getName",		(PyCFunction)liblvm_lvm_pv_get_name, METH_NOARGS },
@@ -1659,6 +1782,17 @@ static PyTypeObject LibLVMlvType = {
 	.tp_methods = liblvm_lv_methods,
 };
 
+static PyTypeObject LibLVMpvlistType = {
+	PyObject_HEAD_INIT(&PyType_Type)
+		.tp_name = "liblvm.Liblvm_pvlist",
+		.tp_basicsize = sizeof(pvslistobject),
+		.tp_new = PyType_GenericNew,
+		.tp_dealloc = (destructor)liblvm_pvlist_dealloc,
+		.tp_flags = Py_TPFLAGS_DEFAULT,
+		.tp_doc = "LVM Physical Volume list object",
+		.tp_methods = liblvm_pv_list_methods,
+};
+
 static PyTypeObject LibLVMpvType = {
 	PyObject_HEAD_INIT(&PyType_Type)
 	.tp_name = "liblvm.Liblvm_pv",
@@ -1716,6 +1850,8 @@ initlvm(void)
 		return;
 	if (PyType_Ready(&LibLVMpvsegType) < 0)
 		return;
+	if (PyType_Ready(&LibLVMpvlistType) < 0)
+			return;
 
 	m = Py_InitModule3("lvm", Liblvm_methods, "Liblvm module");
 	if (m == NULL)
-- 
1.8.1.4


