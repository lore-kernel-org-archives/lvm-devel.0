From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:19 -0500
Subject: [PATCH 08/12] Add support for lvm_lv_get_property
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-9-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 80 +++++++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 51 insertions(+), 29 deletions(-)

diff --git a/liblvm.c b/liblvm.c
index cccc35a..1fa13fe 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -618,6 +618,38 @@ liblvm_lvm_vg_get_free_extent_count(vgobject *self)
     return Py_BuildValue("l", lvm_vg_get_free_extent_count(self->vg));
 }
 
+/* Builds a python tuple ([string|number], bool) from a struct lvm_property_value */
+static PyObject *
+get_property(lvmobject *h, struct lvm_property_value *prop)
+{
+    PyObject *pytuple;
+    PyObject *setable;
+
+    if( !prop->is_valid ) {
+        PyErr_SetObject(LibLVMError, liblvm_get_last_error(h));
+        return NULL;
+    }
+
+    pytuple = PyTuple_New(2);
+    if (!pytuple)
+        return NULL;
+
+    if( prop->is_integer ) {
+        PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop->value.integer));
+    } else {
+        PyTuple_SET_ITEM(pytuple, 0, PyString_FromString(prop->value.string));
+    }
+
+    if (prop->is_settable) {
+        setable = Py_True;
+    } else {
+        setable = Py_False;
+    }
+
+    Py_INCREF(setable);
+    PyTuple_SET_ITEM(pytuple, 1, setable);
+    return pytuple;
+}
 
 /* This will return a tuple of (value, bool) with the value being a string or
    integer and bool indicating if property is settable */
@@ -626,7 +658,6 @@ liblvm_lvm_vg_get_property(vgobject *self,  PyObject *args)
 {
     const char *name;
     struct lvm_property_value prop_value;
-    PyObject * pytuple;
 
     VG_VALID(self);
 
@@ -634,34 +665,7 @@ liblvm_lvm_vg_get_property(vgobject *self,  PyObject *args)
         return NULL;
 
     prop_value = lvm_vg_get_property(self->vg, name);
-
-    if( !prop_value.is_valid ) {
-        PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
-        return NULL;
-    } else {
-        PyObject *setable;
-
-        pytuple = PyTuple_New(2);
-        if (!pytuple)
-            return NULL;
-
-        if( prop_value.is_integer ) {
-            PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop_value.value.integer));
-        } else {
-            PyTuple_SET_ITEM(pytuple, 0, PyString_FromString(prop_value.value.string));
-        }
-
-        if (prop_value.is_settable) {
-            setable = Py_True;
-        } else {
-            setable = Py_False;
-        }
-
-        Py_INCREF(setable);
-        PyTuple_SET_ITEM(pytuple, 1, setable);
-    }
-
-    return pytuple;
+    return get_property(self->lvm_obj, &prop_value);
 }
 
 static PyObject *
@@ -1104,6 +1108,23 @@ liblvm_lvm_vg_remove_lv(lvobject *self)
     return Py_None;
 }
 
+/* This will return a tuple of (value, bool) with the value being a string or
+   integer and bool indicating if property is settable */
+static PyObject *
+liblvm_lvm_lv_get_property(lvobject *self,  PyObject *args)
+{
+    const char *name;
+    struct lvm_property_value prop_value;
+
+    LV_VALID(self);
+
+     if (!PyArg_ParseTuple(args, "s", &name))
+        return NULL;
+
+    prop_value = lvm_lv_get_property(self->lv, name);
+    return get_property(self->lvm_obj, &prop_value);
+}
+
 static PyObject *
 liblvm_lvm_lv_get_size(lvobject *self)
 {
@@ -1371,6 +1392,7 @@ static PyMethodDef liblvm_lv_methods[] = {
     { "activate",          (PyCFunction)liblvm_lvm_lv_activate, METH_NOARGS },
     { "deactivate",          (PyCFunction)liblvm_lvm_lv_deactivate, METH_NOARGS },
     { "remove",          (PyCFunction)liblvm_lvm_vg_remove_lv, METH_NOARGS },
+    { "getProperty",        (PyCFunction)liblvm_lvm_lv_get_property, METH_VARARGS },
     { "getSize",          (PyCFunction)liblvm_lvm_lv_get_size, METH_NOARGS },
     { "isActive",          (PyCFunction)liblvm_lvm_lv_is_active, METH_NOARGS },
     { "isSuspended",          (PyCFunction)liblvm_lvm_lv_is_suspended, METH_NOARGS },
-- 
1.7.11.4


