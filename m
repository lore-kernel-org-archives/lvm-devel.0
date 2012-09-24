From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 24 Sep 2012 18:29:14 -0500
Subject: [PATCH 03/12] Add support for lvm_percent_to_float
In-Reply-To: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
References: <1348529363-13997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1348529363-13997-4-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/liblvm.c b/liblvm.c
index 4c6dcec..a5bd730 100644
--- a/liblvm.c
+++ b/liblvm.c
@@ -192,6 +192,21 @@ liblvm_lvm_list_vg_uuids(lvmobject *self)
 }
 
 static PyObject *
+liblvm_lvm_percent_to_float(lvmobject *self, PyObject *arg)
+{
+    double converted;
+    int percent;
+
+    LVM_VALID(self);
+
+    if (!PyArg_ParseTuple(arg, "i", &percent))
+        return NULL;
+
+    converted = lvm_percent_to_float(percent);
+    return Py_BuildValue("d", converted);
+}
+
+static PyObject *
 liblvm_lvm_vgname_from_pvid(lvmobject *self, PyObject *arg)
 {
     const char *pvid;
@@ -1082,6 +1097,7 @@ static PyMethodDef Liblvm_methods[] = {
     { "scan",                   (PyCFunction)liblvm_lvm_scan, METH_NOARGS },
     { "listVgNames",          (PyCFunction)liblvm_lvm_list_vg_names, METH_NOARGS },
     { "listVgUuids",          (PyCFunction)liblvm_lvm_list_vg_uuids, METH_NOARGS },
+    { "percentToFloat",        (PyCFunction)liblvm_lvm_percent_to_float, METH_VARARGS },
     { "vgNameFromPvid",        (PyCFunction)liblvm_lvm_vgname_from_pvid, METH_VARARGS },
     { "vgNameFromDevice",        (PyCFunction)liblvm_lvm_vgname_from_device, METH_VARARGS },
 
-- 
1.7.11.4


