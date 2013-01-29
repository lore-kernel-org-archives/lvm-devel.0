From: Tony Asleson <tasleson@redhat.com>
Date: Tue, 29 Jan 2013 16:22:20 -0600
Subject: [PATCH] python-lvm: Add calls for thinp
Message-ID: <1359498140-16209-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Methods added for creating a thinly provisioned pool and to
create a thinly provisioned logical volume from the thin pool.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 64 insertions(+)

diff --git a/python/liblvm.c b/python/liblvm.c
index 906825e..7d139ab 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -893,6 +893,37 @@ liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
 	return (PyObject *)lvobj;
 }
 
+static PyObject *
+liblvm_lvm_lv_thinpool(vgobject *self, PyObject *args)
+{
+	const char *pool_name = NULL;
+	uint64_t size = 0;
+	lvobject *lvobj = NULL;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "sK", &pool_name, &size)) {
+		return NULL;
+	}
+
+	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL )
+		return NULL;
+
+	lvobj->parent_vgobj = NULL;
+
+
+	if ((lvobj->lv = lvm_lv_thinpool(self->vg, pool_name, size)) == NULL) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+		Py_DECREF(lvobj);
+		return NULL;
+	}
+
+	lvobj->parent_vgobj = self;
+	Py_INCREF(lvobj->parent_vgobj);
+
+	return (PyObject *)lvobj;
+}
+
 static void
 liblvm_lv_dealloc(lvobject *self)
 {
@@ -1275,6 +1306,37 @@ liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
 }
 
 static PyObject *
+liblvm_lvm_lv_thin(lvobject *self, PyObject *args)
+{
+	const char *lv_name = NULL;
+	uint64_t size = 0;
+	lvobject *lvobj = NULL;
+
+	LV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "sK", &lv_name, &size)) {
+		return NULL;
+	}
+
+	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL )
+		return NULL;
+
+	lvobj->parent_vgobj = NULL;
+
+	if ((lvobj->lv = lvm_lv_thin(self->parent_vgobj->vg,
+			lvm_lv_get_name(self->lv), lv_name, size)) == NULL) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+		Py_DECREF(lvobj);
+		return NULL;
+	}
+
+	lvobj->parent_vgobj = self->parent_vgobj;
+	Py_INCREF(lvobj->parent_vgobj);
+
+	return (PyObject *)lvobj;
+}
+
+static PyObject *
 liblvm_lvm_lv_list_lvsegs(lvobject *self)
 {
 	struct dm_list *lvsegs;
@@ -1589,6 +1651,7 @@ static PyMethodDef liblvm_vg_methods[] = {
 	{ "pvFromUuid", 	(PyCFunction)liblvm_lvm_pv_from_uuid, METH_VARARGS },
 	{ "getTags",		(PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
 	{ "createLvLinear",	(PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
+	{ "createLvThinPool",	(PyCFunction)liblvm_lvm_lv_thinpool, METH_VARARGS},
 	{ NULL, NULL }		/* sentinel */
 };
 
@@ -1610,6 +1673,7 @@ static PyMethodDef liblvm_lv_methods[] = {
 	{ "resize",		(PyCFunction)liblvm_lvm_lv_resize, METH_VARARGS },
 	{ "listLVsegs",		(PyCFunction)liblvm_lvm_lv_list_lvsegs, METH_NOARGS },
 	{ "snapshot",		(PyCFunction)liblvm_lvm_lv_snapshot, METH_VARARGS },
+	{ "createLvThin",	(PyCFunction)liblvm_lvm_lv_thin, METH_VARARGS},
 	{ NULL, NULL }		/* sentinel */
 };
 
-- 
1.8.1


