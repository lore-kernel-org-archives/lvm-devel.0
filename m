From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:43 +0000 (UTC)
Subject: master - python-lvm: VG/LV name validation.
Message-ID: <20131119205643.B8A3D60EA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c7a7d4d8433965313120254b68199525871b6a6
Commit:        0c7a7d4d8433965313120254b68199525871b6a6
Parent:        0dd247502ace2dd20763d1b664edc280a255de06
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 26 11:39:40 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:40:40 2013 -0600

python-lvm: VG/LV name validation.

Python portion of
https://bugzilla.redhat.com/show_bug.cgi?id=883689

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 033de82..330ef14 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -391,6 +391,25 @@ static PyObject *_liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
 	return Py_BuildValue("d", converted);
 }
 
+static PyObject *_liblvm_lvm_vg_name_validate(PyObject *self, PyObject *arg)
+{
+	const char *name;
+
+	LVM_VALID(NULL);
+
+	if (!PyArg_ParseTuple(arg, "s", &name))
+		return NULL;
+
+	if (lvm_vg_name_validate(_libh, name) < 0) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+
+	return Py_None;
+}
+
 static PyObject *_liblvm_lvm_vgname_from_pvid(PyObject *self, PyObject *arg)
 {
 	const char *pvid;
@@ -1213,6 +1232,25 @@ static PyObject *_liblvm_lvm_lv_from_uuid(vgobject *self, PyObject *arg)
 	return _liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_uuid);
 }
 
+static PyObject *_liblvm_lvm_lv_name_validate(vgobject *self, PyObject *args)
+{
+	const char *name;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	if (lvm_lv_name_validate(self->vg, name) < 0) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+
+	return Py_None;
+}
+
 static PyObject *_liblvm_lvm_pv_from_N(vgobject *self, PyObject *arg, pv_fetch_by_N method)
 {
 	const char *id;
@@ -1771,6 +1809,7 @@ static PyMethodDef _Liblvm_methods[] = {
 	{ "pvCreate",		(PyCFunction)_liblvm_lvm_pv_create, METH_VARARGS },
 	{ "pvRemove",		(PyCFunction)_liblvm_lvm_pv_remove, METH_VARARGS },
 	{ "percentToFloat",	(PyCFunction)_liblvm_lvm_percent_to_float, METH_VARARGS },
+	{ "vgNameValidate",	(PyCFunction)_liblvm_lvm_vg_name_validate, METH_VARARGS },
 	{ "vgNameFromPvid",	(PyCFunction)_liblvm_lvm_vgname_from_pvid, METH_VARARGS },
 	{ "vgNameFromDevice",	(PyCFunction)_liblvm_lvm_vgname_from_device, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
@@ -1805,6 +1844,7 @@ static PyMethodDef _liblvm_vg_methods[] = {
 	{ "listPVs",		(PyCFunction)_liblvm_lvm_vg_list_pvs, METH_NOARGS },
 	{ "lvFromName", 	(PyCFunction)_liblvm_lvm_lv_from_name, METH_VARARGS },
 	{ "lvFromUuid", 	(PyCFunction)_liblvm_lvm_lv_from_uuid, METH_VARARGS },
+	{ "lvNameValidate",	(PyCFunction)_liblvm_lvm_lv_name_validate, METH_VARARGS },
 	{ "pvFromName", 	(PyCFunction)_liblvm_lvm_pv_from_name, METH_VARARGS },
 	{ "pvFromUuid", 	(PyCFunction)_liblvm_lvm_pv_from_uuid, METH_VARARGS },
 	{ "getTags",		(PyCFunction)_liblvm_lvm_vg_get_tags, METH_NOARGS },


