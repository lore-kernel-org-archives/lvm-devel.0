From: Tony Asleson <tasleson@redhat.com>
Date: Fri,  3 May 2013 18:38:52 -0500
Subject: [PATCH] python-lvm: Bindings for thin pool, thin lv creation.
Message-ID: <1367624332-16074-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 97 insertions(+)

diff --git a/python/liblvm.c b/python/liblvm.c
index 09892ca..0afee93 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1032,6 +1032,101 @@ liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
 	return (PyObject *)lvobj;
 }
 
+static PyObject *
+liblvm_lvm_vg_create_lv_thinpool(vgobject *self, PyObject *args)
+{
+	const char *pool_name;
+	uint64_t size = 0;
+	uint32_t chunk_size = 0;
+	uint64_t meta_size = 0;
+	int skip_zero = 0;
+	lvm_thin_discards_t discard = LVM_THIN_DISCARDS_PASSDOWN;
+	lvobject *lvobj;
+	lv_create_params_t lvp = NULL;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "sK|kKii", &pool_name, &size, &chunk_size,
+			&meta_size, &discard, &skip_zero)) {
+		return NULL;
+	}
+
+	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
+		return NULL;
+
+	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
+	lvobj->parent_vgobj = NULL;
+
+	lvp = lvm_lv_params_create_thin_pool(self->vg, pool_name, size, chunk_size,
+				meta_size, discard);
+
+	if (lvp) {
+		if (skip_zero) {
+			if ( -1 != lvm_lv_params_skip_zero_set(lvp, 1)) {
+				PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+							Py_DECREF(lvobj);
+							return NULL;
+			}
+		}
+
+		if ((lvobj->lv = lvm_lv_create(lvp)) == NULL) {
+			PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+			Py_DECREF(lvobj);
+			return NULL;
+		}
+	} else {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+				Py_DECREF(lvobj);
+				return NULL;
+	}
+
+	lvobj->parent_vgobj = self;
+	Py_INCREF(lvobj->parent_vgobj);
+
+	return (PyObject *)lvobj;
+}
+
+static PyObject *
+liblvm_lvm_vg_create_lv_thin(vgobject *self, PyObject *args)
+{
+	const char *pool_name;
+	const char *lv_name;
+	uint64_t size = 0;
+	lvobject *lvobj;
+	lv_create_params_t lvp = NULL;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "ssK", &pool_name, &lv_name, &size)) {
+		return NULL;
+	}
+
+	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
+		return NULL;
+
+	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
+	lvobj->parent_vgobj = NULL;
+
+	lvp = lvm_lv_params_create_thin(self->vg, pool_name, lv_name,size);
+
+	if (lvp) {
+		if ((lvobj->lv = lvm_lv_create(lvp)) == NULL) {
+			PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+			Py_DECREF(lvobj);
+			return NULL;
+		}
+	} else {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+				Py_DECREF(lvobj);
+				return NULL;
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
@@ -1759,6 +1854,8 @@ static PyMethodDef liblvm_vg_methods[] = {
 	{ "pvFromUuid", 	(PyCFunction)liblvm_lvm_pv_from_uuid, METH_VARARGS },
 	{ "getTags",		(PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
 	{ "createLvLinear",	(PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
+	{ "createLvThinpool", (PyCFunction)liblvm_lvm_vg_create_lv_thinpool, METH_VARARGS },
+	{ "createLvThin", 	(PyCFunction)liblvm_lvm_vg_create_lv_thin, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
-- 
1.8.1.4


