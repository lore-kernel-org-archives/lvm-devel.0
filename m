From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:22 -0500
Subject: [PATCH 11/12] Add support for lvm_lv_list_lvsegs, lvm_lvseg_get_property
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-12-git-send-email-tasleson@redhat.com>
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
index e44b43d..62521fd 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -48,9 +48,16 @@ typedef struct {
     lvmobject *lvm_obj;
 } pvobject;
 
+typedef struct {
+    PyObject_HEAD
+    lvseg_t    lv_seg;              /* lv segment handle */
+    lvmobject *lvm_obj;
+} lvsegobject;
+
 static PyTypeObject LibLVMvgType;
 static PyTypeObject LibLVMlvType;
 static PyTypeObject LibLVMpvType;
+static PyTypeObject LibLVMlvsegType;
 
 static PyObject *LibLVMError;
 
@@ -1295,6 +1302,43 @@ liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
     return Py_None;
 }
 
+static PyObject *
+liblvm_lvm_lv_list_lvsegs(lvobject *lv)
+{
+    struct dm_list  *lvsegs;
+    lvseg_list_t    *lvsegl;
+    PyObject * pytuple;
+    lvsegobject *self;
+    int i = 0;
+
+    LV_VALID(lv);
+
+    lvsegs = lvm_lv_list_lvsegs(lv->lv);
+    if(!lvsegs) {
+        return Py_BuildValue("()");
+    }
+
+    pytuple = PyTuple_New(dm_list_size(lvsegs));
+    if (!pytuple)
+        return NULL;
+
+    dm_list_iterate_items(lvsegl, lvsegs) {
+        /* Create and initialize the object */
+        self = PyObject_New(lvsegobject, &LibLVMlvsegType);
+        if (!self) {
+            Py_DECREF(pytuple);
+            return NULL;
+        }
+
+        self->lv_seg = lvsegl->lvseg;
+        self->lvm_obj = lv->lvm_obj;
+        PyTuple_SET_ITEM(pytuple, i, (PyObject *) self);
+        i++;
+    }
+
+    return pytuple;
+}
+
 /* PV Methods */
 
 #define PV_VALID(pvobject) \
@@ -1375,6 +1419,27 @@ liblvm_lvm_pv_resize(pvobject *self, PyObject *args)
     return Py_None;
 }
 
+/* LV seg methods */
+
+static void
+liblvm_lvseg_dealloc(lvsegobject *self)
+{
+    PyObject_Del(self);
+}
+
+static PyObject *
+liblvm_lvm_lvseg_get_property(lvsegobject *self,  PyObject *args)
+{
+    const char *name;
+    struct lvm_property_value prop_value;
+
+     if (!PyArg_ParseTuple(args, "s", &name))
+        return NULL;
+
+    prop_value = lvm_lvseg_get_property(self->lv_seg, name);
+    return get_property(self->lvm_obj, &prop_value);
+}
+
 /* ----------------------------------------------------------------------
  * Method tables and other bureaucracy
  */
@@ -1450,6 +1515,7 @@ static PyMethodDef liblvm_lv_methods[] = {
     { "getTags",          (PyCFunction)liblvm_lvm_lv_get_tags, METH_NOARGS },
     { "rename",         (PyCFunction)liblvm_lvm_lv_rename, METH_VARARGS },
     { "resize",          (PyCFunction)liblvm_lvm_lv_resize, METH_VARARGS },
+    { "listLVsegs",          (PyCFunction)liblvm_lvm_lv_list_lvsegs, METH_NOARGS },
     { NULL,             NULL}   /* sentinel */
 };
 
@@ -1466,6 +1532,10 @@ static PyMethodDef liblvm_pv_methods[] = {
     { NULL,             NULL}   /* sentinel */
 };
 
+static PyMethodDef liblvm_lvseg_methods[] = {
+    { "getProperty",        (PyCFunction)liblvm_lvm_lvseg_get_property, METH_VARARGS }
+};
+
 static PyTypeObject LiblvmType = {
     PyObject_HEAD_INIT(&PyType_Type)
     .tp_name = "liblvm.Liblvm",
@@ -1511,6 +1581,17 @@ static PyTypeObject LibLVMpvType = {
     .tp_methods = liblvm_pv_methods,
 };
 
+static PyTypeObject LibLVMlvsegType = {
+    PyObject_HEAD_INIT(&PyType_Type)
+    .tp_name = "liblvm.Liblvm_lvseg",
+    .tp_basicsize = sizeof(lvsegobject),
+    .tp_new = PyType_GenericNew,
+    .tp_dealloc = (destructor)liblvm_lvseg_dealloc,
+    .tp_flags = Py_TPFLAGS_DEFAULT,
+    .tp_doc = "LVM Logical Volume Segment object",
+    .tp_methods = liblvm_lvseg_methods,
+};
+
 PyMODINIT_FUNC
 initlvm(void)
 {
@@ -1524,6 +1605,8 @@ initlvm(void)
         return;
     if (PyType_Ready(&LibLVMpvType) < 0)
         return;
+    if (PyType_Ready(&LibLVMlvsegType) < 0)
+        return;
 
     m = Py_InitModule3("lvm", Liblvm_methods, "Liblvm module");
     if (m == NULL)
-- 
1.7.11.4


