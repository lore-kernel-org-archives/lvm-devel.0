From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 24 Jul 2013 13:37:15 -0500
Subject: [PATCH] lvm2app: Add filtered LV list ability in library.
In-Reply-To: <1374691035-9627-1-git-send-email-tasleson@redhat.com>
References: <1374691035-9627-1-git-send-email-tasleson@redhat.com>
Message-ID: <1374691035-9627-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Added lvm_vg_list_filtered_lvs to library.  Allows
returned list to be all or just the visible at this
time.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h | 28 ++++++++++++++++++++++++++++
 liblvm/lvm_vg.c  | 24 ++++++++++++++++++------
 python/liblvm.c  | 26 ++++++++++++++++++++++----
 3 files changed, 68 insertions(+), 10 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index cb6766c..a56ad9e 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -542,6 +542,34 @@ vg_t lvm_vg_create(lvm_t libh, const char *vg_name);
  */
 struct dm_list *lvm_vg_list_lvs(vg_t vg);
 
+
+/**
+ *  Filter values for lvm_vg_list_filtered_lvs
+ */
+#define LVM_VG_LV_LIST_ALL 1
+#define LVM_VG_LV_LIST_VISIBLE 0
+
+/**
+ * Return a list of LV handles for a given VG handle with a filter
+ * which allows the caller to return all or just the visible LVs.
+ *
+ * \memberof vg_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param	filter
+ * Use #define LVM_VG_LV_LIST_ALL or LVM_VG_LV_LIST_VISIBILE
+ *
+ *
+ * \return
+ * A list of lvm_lv_list structures containing lv handles for this vg.
+ * If no LVs exist on the given VG, NULL is returned.  If an invalid
+ * filter is passed, this function will return NULL and library errno
+ * will be set to EINVAL.
+ */
+struct dm_list *lvm_vg_list_filtered_lvs(vg_t vg, int32_t filter);
+
 /**
  * Return a list of PV handles for all.
  *
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 3f4968e..4852435 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -236,10 +236,20 @@ struct dm_list *lvm_vg_list_pvs(vg_t vg)
 
 struct dm_list *lvm_vg_list_lvs(vg_t vg)
 {
+	return lvm_vg_list_filtered_lvs(vg, LVM_VG_LV_LIST_ALL);
+}
+
+struct dm_list *lvm_vg_list_filtered_lvs(vg_t vg, int32_t filter)
+{
 	struct dm_list *list;
 	lv_list_t *lvs;
 	struct lv_list *lvl;
 
+	if (filter != LVM_VG_LV_LIST_ALL && filter != LVM_VG_LV_LIST_VISIBLE) {
+		log_errno(EINVAL, "Incorrect filter value");
+		return NULL;
+	}
+
 	if (dm_list_empty(&vg->lvs))
 		return NULL;
 
@@ -250,13 +260,15 @@ struct dm_list *lvm_vg_list_lvs(vg_t vg)
 	dm_list_init(list);
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
-			log_errno(ENOMEM,
-				"Memory allocation fail for lvm_lv_list.");
-			return NULL;
+		if (filter || lv_is_visible(lvl->lv)) {
+			if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
+				log_errno(ENOMEM,
+					"Memory allocation fail for lvm_lv_list.");
+				return NULL;
+			}
+			lvs->lv = lvl->lv;
+			dm_list_add(list, &lvs->list);
 		}
-		lvs->lv = lvl->lv;
-		dm_list_add(list, &lvs->list);
 	}
 	return list;
 }
diff --git a/python/liblvm.c b/python/liblvm.c
index d6a7b8d..b1d9fc3 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -922,19 +922,29 @@ static PyObject *_liblvm_lvm_vg_set_extent_size(vgobject *self, PyObject *args)
 	return Py_None;
 }
 
-static PyObject *_liblvm_lvm_vg_list_lvs(vgobject *self)
+static PyObject *_liblvm_lvm_vg_list_lvs(vgobject *self, PyObject *args)
 {
 	struct dm_list *lvs;
 	struct lvm_lv_list *lvl;
 	PyObject * pytuple;
 	lvobject * lvobj;
 	int i = 0;
+	uint32_t filter = LVM_VG_LV_LIST_ALL;
 
 	VG_VALID(self);
 
+	if (!PyArg_ParseTuple(args, "|l", &filter))
+		return NULL;
+
 	/* unlike other LVM api calls, if there are no results, we get NULL */
-	if (!(lvs = lvm_vg_list_lvs(self->vg)))
-		return Py_BuildValue("()");
+	if (!(lvs = lvm_vg_list_filtered_lvs(self->vg, filter))) {
+		if (!lvm_errno(_libh)) {
+			return Py_BuildValue("()");
+		} else {
+			PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+			return NULL;
+		}
+	}
 
 	if (!(pytuple = PyTuple_New(dm_list_size(lvs))))
 		return NULL;
@@ -1775,7 +1785,7 @@ static PyMethodDef _liblvm_vg_methods[] = {
 	{ "getPvCount",		(PyCFunction)_liblvm_lvm_vg_get_pv_count, METH_NOARGS },
 	{ "getMaxPv",		(PyCFunction)_liblvm_lvm_vg_get_max_pv, METH_NOARGS },
 	{ "getMaxLv",		(PyCFunction)_liblvm_lvm_vg_get_max_lv, METH_NOARGS },
-	{ "listLVs",		(PyCFunction)_liblvm_lvm_vg_list_lvs, METH_NOARGS },
+	{ "listLVs",		(PyCFunction)_liblvm_lvm_vg_list_lvs, METH_VARARGS },
 	{ "listPVs",		(PyCFunction)_liblvm_lvm_vg_list_pvs, METH_NOARGS },
 	{ "lvFromName", 	(PyCFunction)_liblvm_lvm_lv_from_name, METH_VARARGS },
 	{ "lvFromUuid", 	(PyCFunction)_liblvm_lvm_lv_from_uuid, METH_VARARGS },
@@ -1940,6 +1950,14 @@ PyMODINIT_FUNC initlvm(void)
 	if (!(m = Py_InitModule3("lvm", _Liblvm_methods, "Liblvm module")))
 		return;
 
+	if (PyModule_AddIntConstant(m, "VG_LV_LIST_ALL",
+					LVM_VG_LV_LIST_ALL) < 0)
+		return;
+
+	if (PyModule_AddIntConstant(m, "VG_LV_LIST_VISIBLE",
+					LVM_VG_LV_LIST_VISIBLE) < 0)
+		return;
+
 	if (PyModule_AddIntConstant(m, "THIN_DISCARDS_IGNORE",
 				    LVM_THIN_DISCARDS_IGNORE) < 0)
 		return;
-- 
1.8.1.4


