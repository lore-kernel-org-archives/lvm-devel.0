From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:15 -0500
Subject: [PATCH 04/12] Add support for lvm_vg_[get|set]_property
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-5-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 143 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 143 insertions(+)

diff --git a/liblvm.c b/liblvm.c
index a5bd730..0b2a436 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -618,6 +618,147 @@ liblvm_lvm_vg_get_free_extent_count(vgobject *self)
     return Py_BuildValue("l", lvm_vg_get_free_extent_count(self->vg));
 }
 
+
+/* This will return a tuple of (value, bool) with the value being a string or
+   integer and bool indicating if property is settable */
+static PyObject *
+liblvm_lvm_vg_get_property(vgobject *self,  PyObject *args)
+{
+    const char *name;
+    struct lvm_property_value prop_value;
+    PyObject * pytuple;
+
+    VG_VALID(self);
+
+     if (!PyArg_ParseTuple(args, "s", &name))
+        return NULL;
+
+    prop_value = lvm_vg_get_property(self->vg, name);
+
+    if( !prop_value.is_valid ) {
+        PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+        return NULL;
+    } else {
+        PyObject *setable;
+
+        pytuple = PyTuple_New(2);
+        if (!pytuple)
+            return NULL;
+
+        if( prop_value.is_integer ) {
+            PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop_value.value.integer));
+        } else {
+            PyTuple_SET_ITEM(pytuple, 0, PyString_FromString(prop_value.value.string));
+        }
+
+        if (prop_value.is_settable) {
+            setable = Py_True;
+        } else {
+            setable = Py_False;
+        }
+
+        Py_INCREF(setable);
+        PyTuple_SET_ITEM(pytuple, 1, setable);
+    }
+
+    return pytuple;
+}
+
+static PyObject *
+liblvm_lvm_vg_set_property(vgobject *self,  PyObject *args)
+{
+    const char *property_name = NULL;
+    PyObject *variant_type_arg = NULL;
+    struct lvm_property_value lvm_property;
+    char *string_value = NULL;
+
+    VG_VALID(self);
+
+    if (!PyArg_ParseTuple(args, "sO", &property_name, &variant_type_arg))
+        return NULL;
+
+    lvm_property = lvm_vg_get_property(self->vg, property_name);
+
+    if( !lvm_property.is_valid ) {
+        goto lvmerror;
+    }
+
+    if(PyObject_IsInstance(variant_type_arg, (PyObject*)&PyString_Type)) {
+
+        if (!lvm_property.is_string) {
+            PyErr_Format(PyExc_ValueError, "Property requires string value");
+            goto bail;
+        }
+
+        /* Based on cursory code inspection this path may cause a memory
+            leak when calling into set_property, need to verify*/
+        string_value = strdup(PyString_AsString(variant_type_arg));
+        lvm_property.value.string = string_value;
+        if(!lvm_property.value.string) {
+            PyErr_NoMemory();
+            goto bail;
+        }
+
+    } else {
+
+        if (!lvm_property.is_integer) {
+            PyErr_Format(PyExc_ValueError, "Property requires numeric value");
+            goto bail;
+        }
+
+        if(PyObject_IsInstance(variant_type_arg, (PyObject*)&PyInt_Type)) {
+            int temp_py_int = PyInt_AsLong(variant_type_arg);
+
+            /* -1 could be valid, need to see if an exception was gen. */
+            if( -1 == temp_py_int ) {
+                if( PyErr_Occurred() ) {
+                    goto bail;
+                }
+            }
+
+            if (temp_py_int < 0) {
+                PyErr_Format(PyExc_ValueError, "Positive integers only!");
+                goto bail;
+            }
+
+            lvm_property.value.integer = temp_py_int;
+        } else if(PyObject_IsInstance(variant_type_arg, (PyObject*)&PyLong_Type)){
+            /* This will fail on negative numbers */
+            unsigned long long temp_py_long = PyLong_AsUnsignedLongLong(variant_type_arg);
+            if( (unsigned long long)-1 == temp_py_long ) {
+                goto bail;
+            }
+
+            lvm_property.value.integer = temp_py_long;
+        } else {
+            PyErr_Format(PyExc_ValueError, "supported value types are numeric and string");
+            goto bail;
+        }
+    }
+
+    if( -1 == lvm_vg_set_property(self->vg, property_name, &lvm_property) ) {
+        goto lvmerror;
+    }
+
+    if( -1 == lvm_vg_write(self->vg)) {
+        goto lvmerror;
+    }
+
+    Py_DECREF(variant_type_arg);
+    Py_INCREF(Py_None);
+    return Py_None;
+
+ lvmerror:
+    PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+ bail:
+    free(string_value);
+    if( variant_type_arg ) {
+        Py_DECREF(variant_type_arg);
+        variant_type_arg = NULL;
+    }
+    return NULL;
+}
+
 static PyObject *
 liblvm_lvm_vg_get_pv_count(vgobject *self)
 {
@@ -1124,6 +1265,8 @@ static PyMethodDef liblvm_vg_methods[] = {
     { "getExtentSize",          (PyCFunction)liblvm_lvm_vg_get_extent_size, METH_NOARGS },
     { "getExtentCount",          (PyCFunction)liblvm_lvm_vg_get_extent_count, METH_NOARGS },
     { "getFreeExtentCount",  (PyCFunction)liblvm_lvm_vg_get_free_extent_count, METH_NOARGS },
+    { "getProperty",          (PyCFunction)liblvm_lvm_vg_get_property, METH_VARARGS },
+    { "setProperty",          (PyCFunction)liblvm_lvm_vg_set_property, METH_VARARGS },
     { "getPvCount",          (PyCFunction)liblvm_lvm_vg_get_pv_count, METH_NOARGS },
     { "getMaxPv",          (PyCFunction)liblvm_lvm_vg_get_max_pv, METH_NOARGS },
     { "getMaxLv",          (PyCFunction)liblvm_lvm_vg_get_max_lv, METH_NOARGS },
-- 
1.7.11.4


