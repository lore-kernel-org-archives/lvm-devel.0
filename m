From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:36 +0000 (UTC)
Subject: master - python-lvm: Bindings for thin pool, thin lv creation V3
Message-ID: <20130702192636.1861260FB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a3472b2b34d2ef82cc04eb89bd29dfb456e2d47
Commit:        2a3472b2b34d2ef82cc04eb89bd29dfb456e2d47
Parent:        f576b32203e4c1001764d26225fc6dffa97e4da0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri May 3 19:37:52 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

python-lvm: Bindings for thin pool, thin lv creation V3

V2: Bug fix.
V3: Use updated property interface, add constants for discard.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |  121 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 121 insertions(+), 0 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 305fd50..e631ab1 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1032,6 +1032,109 @@ liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
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
+	struct lvm_property_value prop_value;
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
+			prop_value = lvm_lv_params_get_property(lvp, "skip_zero");
+
+			if (prop_value.is_valid) {
+				prop_value.value.integer = 1;
+
+				if( -1 == lvm_lv_params_set_property(lvp, "skip_zero",
+						&prop_value)) {
+					PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+					Py_DECREF(lvobj);
+					return NULL;
+				}
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
@@ -1759,6 +1862,8 @@ static PyMethodDef liblvm_vg_methods[] = {
 	{ "pvFromUuid", 	(PyCFunction)liblvm_lvm_pv_from_uuid, METH_VARARGS },
 	{ "getTags",		(PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
 	{ "createLvLinear",	(PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
+	{ "createLvThinpool", (PyCFunction)liblvm_lvm_vg_create_lv_thinpool, METH_VARARGS },
+	{ "createLvThin", 	(PyCFunction)liblvm_lvm_vg_create_lv_thin, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
@@ -1915,6 +2020,22 @@ initlvm(void)
 	if (m == NULL)
 		return;
 
+
+	if (-1 == PyModule_AddIntConstant(m, "THIN_DISCARDS_IGNORE",
+										LVM_THIN_DISCARDS_IGNORE)) {
+		return;
+	}
+
+	if (-1 == PyModule_AddIntConstant(m, "THIN_DISCARDS_NO_PASSDOWN",
+											LVM_THIN_DISCARDS_NO_PASSDOWN)) {
+		return;
+	}
+
+	if ( -1 == PyModule_AddIntConstant(m, "THIN_DISCARDS_PASSDOWN",
+											LVM_THIN_DISCARDS_PASSDOWN)) {
+		return;
+	}
+
 	LibLVMError = PyErr_NewException("Liblvm.LibLVMError",
 					 NULL, NULL);
 	if (LibLVMError) {


