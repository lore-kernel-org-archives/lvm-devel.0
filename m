From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  2 Apr 2013 16:16:32 -0500
Subject: [PATCH 2/3] python-lvm: Add bindings for lvm_pv_remove
In-Reply-To: <1364937393-12997-1-git-send-email-tasleson@redhat.com>
References: <1364937393-12997-1-git-send-email-tasleson@redhat.com>
Message-ID: <1364937393-12997-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Method off of base lvm namespace "pvRemove".

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/python/liblvm.c b/python/liblvm.c
index 928cab0..9d0d8f8 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -244,6 +244,25 @@ liblvm_lvm_list_pvs(void)
 }
 
 static PyObject *
+liblvm_lvm_pv_remove(PyObject *self, PyObject *arg)
+{
+	const char *pv_name;
+	LVM_VALID();
+
+	if (!PyArg_ParseTuple(arg, "s", &pv_name))
+			return NULL;
+
+	int rc = lvm_pv_remove(libh, pv_name);
+	if (0 != rc) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
 liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
 {
 	double converted;
@@ -1664,6 +1683,7 @@ static PyMethodDef Liblvm_methods[] = {
 	{ "listVgNames",	(PyCFunction)liblvm_lvm_list_vg_names, METH_NOARGS },
 	{ "listVgUuids",	(PyCFunction)liblvm_lvm_list_vg_uuids, METH_NOARGS },
 	{ "listPvs",		(PyCFunction)liblvm_lvm_list_pvs, METH_NOARGS },
+	{ "pvRemove",		(PyCFunction)liblvm_lvm_pv_remove, METH_VARARGS },
 	{ "percentToFloat",	(PyCFunction)liblvm_lvm_percent_to_float, METH_VARARGS },
 	{ "vgNameFromPvid",	(PyCFunction)liblvm_lvm_vgname_from_pvid, METH_VARARGS },
 	{ "vgNameFromDevice",	(PyCFunction)liblvm_lvm_vgname_from_device, METH_VARARGS },
-- 
1.8.1.4


