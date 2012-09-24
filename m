From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:23 -0500
Subject: [PATCH 12/12] Add support for lvm_pv_list_pvsegs, lvm_pvseg_get_property
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-13-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 83 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 83 insertions(+)

diff --git a/liblvm.c b/liblvm.c
index 62521fd..a492fb6 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -54,10 +54,17 @@ typedef struct {
     lvmobject *lvm_obj;
 } lvsegobject;
 
+typedef struct {
+    PyObject_HEAD
+    pvseg_t    pv_seg;              /* pv segment handle */
+    lvmobject *lvm_obj;
+} pvsegobject;
+
 static PyTypeObject LibLVMvgType;
 static PyTypeObject LibLVMlvType;
 static PyTypeObject LibLVMpvType;
 static PyTypeObject LibLVMlvsegType;
+static PyTypeObject LibLVMpvsegType;
 
 static PyObject *LibLVMError;
 
@@ -1419,6 +1426,43 @@ liblvm_lvm_pv_resize(pvobject *self, PyObject *args)
     return Py_None;
 }
 
+static PyObject *
+liblvm_lvm_lv_list_pvsegs(pvobject *pv)
+{
+    struct dm_list *pvsegs;
+    pvseg_list_t *pvsegl;
+    PyObject *pytuple;
+    pvsegobject *self;
+    int i = 0;
+
+    PV_VALID(pv);
+
+    pvsegs = lvm_pv_list_pvsegs(pv->pv);
+    if(!pvsegs) {
+        return Py_BuildValue("()");
+    }
+
+    pytuple = PyTuple_New(dm_list_size(pvsegs));
+    if (!pytuple)
+        return NULL;
+
+    dm_list_iterate_items(pvsegl, pvsegs) {
+        /* Create and initialize the object */
+        self = PyObject_New(pvsegobject, &LibLVMpvsegType);
+        if (!self) {
+            Py_DECREF(pytuple);
+            return NULL;
+        }
+
+        self->pv_seg = pvsegl->pvseg;
+        self->lvm_obj = pv->lvm_obj;
+        PyTuple_SET_ITEM(pytuple, i, (PyObject *) self);
+        i++;
+    }
+
+    return pytuple;
+}
+
 /* LV seg methods */
 
 static void
@@ -1440,6 +1484,27 @@ liblvm_lvm_lvseg_get_property(lvsegobject *self,  PyObject *args)
     return get_property(self->lvm_obj, &prop_value);
 }
 
+/* PV seg methods */
+
+static void
+liblvm_pvseg_dealloc(pvsegobject *self)
+{
+    PyObject_Del(self);
+}
+
+static PyObject *
+liblvm_lvm_pvseg_get_property(pvsegobject *self,  PyObject *args)
+{
+    const char *name;
+    struct lvm_property_value prop_value;
+
+     if (!PyArg_ParseTuple(args, "s", &name))
+        return NULL;
+
+    prop_value = lvm_pvseg_get_property(self->pv_seg, name);
+    return get_property(self->lvm_obj, &prop_value);
+}
+
 /* ----------------------------------------------------------------------
  * Method tables and other bureaucracy
  */
@@ -1529,6 +1594,7 @@ static PyMethodDef liblvm_pv_methods[] = {
     { "getDevSize",          (PyCFunction)liblvm_lvm_pv_get_dev_size, METH_NOARGS },
     { "getFree",          (PyCFunction)liblvm_lvm_pv_get_free, METH_NOARGS },
     { "resize",          (PyCFunction)liblvm_lvm_pv_resize, METH_VARARGS },
+    { "listPVsegs",     (PyCFunction)liblvm_lvm_lv_list_pvsegs, METH_NOARGS },
     { NULL,             NULL}   /* sentinel */
 };
 
@@ -1536,6 +1602,10 @@ static PyMethodDef liblvm_lvseg_methods[] = {
     { "getProperty",        (PyCFunction)liblvm_lvm_lvseg_get_property, METH_VARARGS }
 };
 
+static PyMethodDef liblvm_pvseg_methods[] = {
+    { "getProperty",        (PyCFunction)liblvm_lvm_pvseg_get_property, METH_VARARGS }
+};
+
 static PyTypeObject LiblvmType = {
     PyObject_HEAD_INIT(&PyType_Type)
     .tp_name = "liblvm.Liblvm",
@@ -1592,6 +1662,17 @@ static PyTypeObject LibLVMlvsegType = {
     .tp_methods = liblvm_lvseg_methods,
 };
 
+static PyTypeObject LibLVMpvsegType = {
+    PyObject_HEAD_INIT(&PyType_Type)
+    .tp_name = "liblvm.Liblvm_pvseg",
+    .tp_basicsize = sizeof(pvsegobject),
+    .tp_new = PyType_GenericNew,
+    .tp_dealloc = (destructor)liblvm_pvseg_dealloc,
+    .tp_flags = Py_TPFLAGS_DEFAULT,
+    .tp_doc = "LVM Physical Volume Segment object",
+    .tp_methods = liblvm_pvseg_methods,
+};
+
 PyMODINIT_FUNC
 initlvm(void)
 {
@@ -1607,6 +1688,8 @@ initlvm(void)
         return;
     if (PyType_Ready(&LibLVMlvsegType) < 0)
         return;
+    if (PyType_Ready(&LibLVMpvsegType) < 0)
+        return;
 
     m = Py_InitModule3("lvm", Liblvm_methods, "Liblvm module");
     if (m == NULL)
-- 
1.7.11.4


