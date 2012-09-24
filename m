From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:18 -0500
Subject: [PATCH 07/12] Add support for lvm_pv_from_[name|uuid]
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-8-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/liblvm.c b/liblvm.c
index 2ead1ce..cccc35a 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -939,6 +939,7 @@ liblvm_lvm_vg_list_pvs(vgobject *vg)
 }
 
 typedef lv_t (*lv_fetch_by_N)(vg_t vg, const char *id);
+typedef pv_t (*pv_fetch_by_N)(vg_t vg, const char *id);
 
 static PyObject *
 liblvm_lvm_lv_from_N(vgobject *self, PyObject *arg, lv_fetch_by_N method)
@@ -980,6 +981,46 @@ liblvm_lvm_lv_from_uuid(vgobject *self, PyObject *arg)
     return liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_uuid);
 }
 
+static PyObject *
+liblvm_lvm_pv_from_N(vgobject *self, PyObject *arg, pv_fetch_by_N method)
+{
+    const char *id;
+    pvobject *rc;
+    pv_t pv = NULL;
+
+    VG_VALID(self);
+
+    if (!PyArg_ParseTuple(arg, "s", &id))
+        return NULL;
+
+    pv = method(self->vg, id);
+    if( !pv ) {
+        PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+        return NULL;
+    }
+
+    rc = PyObject_New(pvobject, &LibLVMpvType);
+    if( !rc ) {
+        return NULL;
+    }
+
+    rc->pv = pv;
+    rc->lvm_obj = self->lvm_obj;
+    return (PyObject *)rc;
+}
+
+static PyObject *
+liblvm_lvm_pv_from_name(vgobject *self, PyObject *arg)
+{
+    return liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_name);
+}
+
+static PyObject *
+liblvm_lvm_pv_from_uuid(vgobject *self, PyObject *arg)
+{
+    return liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_uuid);
+}
+
 static void
 liblvm_pv_dealloc(pvobject *self)
 {
@@ -1316,6 +1357,8 @@ static PyMethodDef liblvm_vg_methods[] = {
     { "listPVs",          (PyCFunction)liblvm_lvm_vg_list_pvs, METH_NOARGS },
     { "lvFromName",       (PyCFunction)liblvm_lvm_lv_from_name, METH_VARARGS },
     { "lvFromUuid",       (PyCFunction)liblvm_lvm_lv_from_uuid, METH_VARARGS },
+    { "pvFromName",       (PyCFunction)liblvm_lvm_pv_from_name, METH_VARARGS },
+    { "pvFromUuid",       (PyCFunction)liblvm_lvm_pv_from_uuid, METH_VARARGS },
     { "getTags",          (PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
     { "createLvLinear",          (PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
     { NULL,             NULL}   /* sentinel */
-- 
1.7.11.4


