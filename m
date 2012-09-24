From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:21 -0500
Subject: [PATCH 10/12] Add support for lvm_config_find_bool
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-11-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/liblvm.c b/liblvm.c
index 7af81bd..e44b43d 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -244,6 +244,31 @@ liblvm_lvm_vgname_from_device(lvmobject *self, PyObject *arg)
     return Py_BuildValue("s", vgname);
 }
 
+
+static PyObject *
+liblvm_lvm_config_find_bool(lvmobject *self, PyObject *arg)
+{
+    const char *config;
+    int rval;
+    PyObject *rc;
+
+    LVM_VALID(self);
+
+    if (!PyArg_ParseTuple(arg, "s", &config))
+       return NULL;
+
+    if ((rval = lvm_config_find_bool(self->libh, config, -10)) == -10) {
+        /*Retrieving error information yields no error in this case*/
+        PyErr_Format(PyExc_ValueError, "config path not found");
+        return NULL;
+    }
+
+    rc = (rval) ? Py_True: Py_False;
+
+    Py_INCREF(rc);
+    return rc;
+}
+
 static PyObject *
 liblvm_lvm_config_reload(lvmobject *self)
 {
@@ -1360,6 +1385,7 @@ static PyMethodDef Liblvm_methods[] = {
     { "vgOpen",                (PyCFunction)liblvm_lvm_vg_open, METH_VARARGS },
     { "vgCreate",                (PyCFunction)liblvm_lvm_vg_create, METH_VARARGS },
     { "close",                  (PyCFunction)liblvm_close, METH_NOARGS },
+    { "configFindBool",        (PyCFunction)liblvm_lvm_config_find_bool, METH_VARARGS },
     { "configReload",          (PyCFunction)liblvm_lvm_config_reload, METH_NOARGS },
     { "configOverride",        (PyCFunction)liblvm_lvm_config_override, METH_VARARGS },
     { "scan",                   (PyCFunction)liblvm_lvm_scan, METH_NOARGS },
-- 
1.7.11.4


