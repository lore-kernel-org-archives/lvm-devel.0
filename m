From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  3 Apr 2013 16:56:11 -0500
Subject: [PATCH 4/4] python-lvm: Add pvCreate python method
In-Reply-To: <1365026171-12944-1-git-send-email-tasleson@redhat.com>
References: <1365026171-12944-1-git-send-email-tasleson@redhat.com>
Message-ID: <1365026171-12944-4-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Added to base namespace.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/python/liblvm.c b/python/liblvm.c
index 9d0d8f8..c76a3d0 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -263,6 +263,26 @@ liblvm_lvm_pv_remove(PyObject *self, PyObject *arg)
 }
 
 static PyObject *
+liblvm_lvm_pv_create(PyObject *self, PyObject *arg)
+{
+	const char *pv_name;
+	uint64_t size;
+	LVM_VALID();
+
+	if (!PyArg_ParseTuple(arg, "sl", &pv_name, &size))
+			return NULL;
+
+	int rc = lvm_pv_create(libh, pv_name, size);
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
@@ -1683,6 +1703,7 @@ static PyMethodDef Liblvm_methods[] = {
 	{ "listVgNames",	(PyCFunction)liblvm_lvm_list_vg_names, METH_NOARGS },
 	{ "listVgUuids",	(PyCFunction)liblvm_lvm_list_vg_uuids, METH_NOARGS },
 	{ "listPvs",		(PyCFunction)liblvm_lvm_list_pvs, METH_NOARGS },
+	{ "pvCreate",		(PyCFunction)liblvm_lvm_pv_create, METH_VARARGS },
 	{ "pvRemove",		(PyCFunction)liblvm_lvm_pv_remove, METH_VARARGS },
 	{ "percentToFloat",	(PyCFunction)liblvm_lvm_percent_to_float, METH_VARARGS },
 	{ "vgNameFromPvid",	(PyCFunction)liblvm_lvm_vgname_from_pvid, METH_VARARGS },
-- 
1.8.1.4


