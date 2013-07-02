From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:15 +0000 (UTC)
Subject: master - python-lvm: Add bindings for lvm_pv_remove
Message-ID: <20130702192615.2F38D60F45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45a0f9e45be5999095c71382361f37f7c24d86d6
Commit:        45a0f9e45be5999095c71382361f37f7c24d86d6
Parent:        e33ac7b1ed962abb5ccb3d12a5401c84a188bf92
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Apr 2 16:10:57 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

python-lvm: Add bindings for lvm_pv_remove

Method off of base lvm namespace "pvRemove".

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 6491274..9c2e658 100644
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


