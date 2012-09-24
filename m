From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:16 -0500
Subject: [PATCH 05/12] Add support for lvm_lv_from_name
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-6-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/liblvm.c b/liblvm.c
index 0b2a436..b61f3da 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -938,6 +938,34 @@ liblvm_lvm_vg_list_pvs(vgobject *vg)
     return pytuple;
 }
 
+static PyObject *
+liblvm_lvm_lv_from_name(vgobject *self, PyObject *arg)
+{
+    const char *name;
+    lvobject *rc;
+    lv_t lv = NULL;
+
+    VG_VALID(self);
+
+    if (!PyArg_ParseTuple(arg, "s", &name))
+        return NULL;
+
+    lv = lvm_lv_from_name(self->vg, name);
+    if( !lv ) {
+        PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+        return NULL;
+    }
+
+    rc = PyObject_New(lvobject, &LibLVMlvType);
+    if( !rc ) {
+        return NULL;
+    }
+
+    rc->lv = lv;
+    rc->lvm_obj = self->lvm_obj;
+    return (PyObject *)rc;
+}
+
 static void
 liblvm_pv_dealloc(pvobject *self)
 {
@@ -1272,6 +1300,7 @@ static PyMethodDef liblvm_vg_methods[] = {
     { "getMaxLv",          (PyCFunction)liblvm_lvm_vg_get_max_lv, METH_NOARGS },
     { "listLVs",          (PyCFunction)liblvm_lvm_vg_list_lvs, METH_NOARGS },
     { "listPVs",          (PyCFunction)liblvm_lvm_vg_list_pvs, METH_NOARGS },
+    { "lvFromName",       (PyCFunction)liblvm_lvm_lv_from_name, METH_VARARGS },
     { "getTags",          (PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
     { "createLvLinear",          (PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
     { NULL,             NULL}   /* sentinel */
-- 
1.7.11.4


