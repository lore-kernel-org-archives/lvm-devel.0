From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:25 +0000 (UTC)
Subject: master - python-lvm: Add pvCreate python method
Message-ID: <20130702192625.ABCC560DE3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=588a16cadbb9000da8d5405ad69d3ed7024fd0fb
Commit:        588a16cadbb9000da8d5405ad69d3ed7024fd0fb
Parent:        6d6ccded3590b46f214561db38e1ce084b643c13
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Apr 3 17:54:12 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

python-lvm: Add pvCreate python method

Added to base namespace.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 9c2e658..4d35c94 100644
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


