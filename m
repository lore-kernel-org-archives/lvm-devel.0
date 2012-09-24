From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:13 -0500
Subject: [PATCH 02/12] Add support for lvm_lv_rename.
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-3-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 23 ++++++++++++++++++++++-
 test.py  |  4 ++++
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/liblvm.c b/liblvm.c
index f46e158..4c6dcec 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -1,4 +1,4 @@
-/* -*- Mode: C; c-basic-offset: 4; tab-width: 4; indent-tabs-mode: nil -*- */ 
+/* -*- Mode: C; c-basic-offset: 4; tab-width: 4; indent-tabs-mode: nil -*- */
 /*
  * Liblvm -- Python interface to LVM2 API.
  *
@@ -970,6 +970,26 @@ liblvm_lvm_lv_get_tags(lvobject *self)
 }
 
 static PyObject *
+liblvm_lvm_lv_rename(lvobject *self, PyObject *args)
+{
+    const char *new_name;
+    int rval;
+
+    LV_VALID(self);
+
+    if (!PyArg_ParseTuple(args, "s", &new_name))
+        return NULL;
+
+     if ((rval = lvm_lv_rename(self->lv, new_name)) == -1) {
+        PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+        return NULL;
+    }
+
+    Py_INCREF(Py_None);
+    return Py_None;
+}
+
+static PyObject *
 liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
 {
     uint64_t new_size;
@@ -1111,6 +1131,7 @@ static PyMethodDef liblvm_lv_methods[] = {
     { "addTag",          (PyCFunction)liblvm_lvm_lv_add_tag, METH_VARARGS },
     { "removeTag",          (PyCFunction)liblvm_lvm_lv_remove_tag, METH_VARARGS },
     { "getTags",          (PyCFunction)liblvm_lvm_lv_get_tags, METH_NOARGS },
+    { "rename",         (PyCFunction)liblvm_lvm_lv_rename, METH_VARARGS },
     { "resize",          (PyCFunction)liblvm_lvm_lv_resize, METH_VARARGS },
     { NULL,             NULL}   /* sentinel */
 };
diff --git a/test.py b/test.py
index 7a2b078..940716b 100644
--- a/test.py
+++ b/test.py
@@ -75,6 +75,10 @@ def create_delete_logical_volume(h):
                 #Remove tag
                 lv.removeTag(t)
 
+            #Try to rename
+            lv.rename("python_lvm_ok_to_be_removed_shortly")
+            print 'LV name= ', lv.getName()
+
             lv.deactivate()
             lv.remove()
 
-- 
1.7.11.4


