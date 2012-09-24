From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:20 -0500
Subject: [PATCH 09/12] Add support for lvm_pv_get_property
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-10-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/liblvm.c b/liblvm.c
index 1fa13fe..7af81bd 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -1272,6 +1272,14 @@ liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
 
 /* PV Methods */
 
+#define PV_VALID(pvobject) \
+    do {                   \
+    if (!pvobject->pv || !pvobject->lvm_obj) {                                               \
+        PyErr_SetString(PyExc_UnboundLocalError, "PV object invalid"); \
+        return NULL; \
+        } \
+    } while (0)
+
 static PyObject *
 liblvm_lvm_pv_get_name(pvobject *self)
 {
@@ -1291,6 +1299,21 @@ liblvm_lvm_pv_get_mda_count(pvobject *self)
 }
 
 static PyObject *
+liblvm_lvm_pv_get_property(pvobject *self,  PyObject *args)
+{
+    const char *name;
+    struct lvm_property_value prop_value;
+
+    PV_VALID(self);
+
+     if (!PyArg_ParseTuple(args, "s", &name))
+        return NULL;
+
+    prop_value = lvm_pv_get_property(self->pv, name);
+    return get_property(self->lvm_obj, &prop_value);
+}
+
+static PyObject *
 liblvm_lvm_pv_get_dev_size(pvobject *self)
 {
     return Py_BuildValue("l", lvm_pv_get_dev_size(self->pv));
@@ -1409,6 +1432,7 @@ static PyMethodDef liblvm_pv_methods[] = {
     { "getName",          (PyCFunction)liblvm_lvm_pv_get_name, METH_NOARGS },
     { "getUuid",          (PyCFunction)liblvm_lvm_pv_get_uuid, METH_NOARGS },
     { "getMdaCount",          (PyCFunction)liblvm_lvm_pv_get_mda_count, METH_NOARGS },
+    { "getProperty",        (PyCFunction)liblvm_lvm_pv_get_property, METH_VARARGS },
     { "getSize",          (PyCFunction)liblvm_lvm_pv_get_size, METH_NOARGS },
     { "getDevSize",          (PyCFunction)liblvm_lvm_pv_get_dev_size, METH_NOARGS },
     { "getFree",          (PyCFunction)liblvm_lvm_pv_get_free, METH_NOARGS },
-- 
1.7.11.4


