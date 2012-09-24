From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:17 -0500
Subject: [PATCH 06/12] Add support for lvm_lv_from_uuid
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-7-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/liblvm.c b/liblvm.c
index b61f3da..2ead1ce 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -938,19 +938,21 @@ liblvm_lvm_vg_list_pvs(vgobject *vg)
     return pytuple;
 }
 
+typedef lv_t (*lv_fetch_by_N)(vg_t vg, const char *id);
+
 static PyObject *
-liblvm_lvm_lv_from_name(vgobject *self, PyObject *arg)
+liblvm_lvm_lv_from_N(vgobject *self, PyObject *arg, lv_fetch_by_N method)
 {
-    const char *name;
+    const char *id;
     lvobject *rc;
     lv_t lv = NULL;
 
     VG_VALID(self);
 
-    if (!PyArg_ParseTuple(arg, "s", &name))
+    if (!PyArg_ParseTuple(arg, "s", &id))
         return NULL;
 
-    lv = lvm_lv_from_name(self->vg, name);
+    lv = method(self->vg, id);
     if( !lv ) {
         PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
         return NULL;
@@ -966,6 +968,18 @@ liblvm_lvm_lv_from_name(vgobject *self, PyObject *arg)
     return (PyObject *)rc;
 }
 
+static PyObject *
+liblvm_lvm_lv_from_name(vgobject *self, PyObject *arg)
+{
+    return liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_name);
+}
+
+static PyObject *
+liblvm_lvm_lv_from_uuid(vgobject *self, PyObject *arg)
+{
+    return liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_uuid);
+}
+
 static void
 liblvm_pv_dealloc(pvobject *self)
 {
@@ -1301,6 +1315,7 @@ static PyMethodDef liblvm_vg_methods[] = {
     { "listLVs",          (PyCFunction)liblvm_lvm_vg_list_lvs, METH_NOARGS },
     { "listPVs",          (PyCFunction)liblvm_lvm_vg_list_pvs, METH_NOARGS },
     { "lvFromName",       (PyCFunction)liblvm_lvm_lv_from_name, METH_VARARGS },
+    { "lvFromUuid",       (PyCFunction)liblvm_lvm_lv_from_uuid, METH_VARARGS },
     { "getTags",          (PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
     { "createLvLinear",          (PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
     { NULL,             NULL}   /* sentinel */
-- 
1.7.11.4


