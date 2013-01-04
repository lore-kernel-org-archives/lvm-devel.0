From: Tony Asleson <tasleson@redhat.com>
Date: Fri,  4 Jan 2013 16:51:48 -0600
Subject: [PATCH 3/3] python-lvm: Add ability to disable vg auto write.
In-Reply-To: <1357339908-14608-1-git-send-email-tasleson@redhat.com>
References: <1357339908-14608-1-git-send-email-tasleson@redhat.com>
Message-ID: <1357339908-14608-3-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Previously, whenever changes were made to volume groups the changes
were immediately written out and committed.  With this change the
user has the ability to turn off this behavior and manually
save the changes for the vg.  A new method lvm.vgAutoWrite(bool)
has been added to control this behavior.  Default behavior matches
previous behavior, implicit calls to lvm_vg_write.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 79 insertions(+), 11 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 906825e..67f6f93 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -26,6 +26,9 @@
 
 static lvm_t libh;
 
+/*Determines if we should write out changes automatically for vg state change*/
+static int auto_vg_write;
+
 
 typedef struct {
 	PyObject_HEAD
@@ -88,6 +91,14 @@ liblvm_get_last_error(void)
 	return info;
 }
 
+static int lvm_vg_write_auto(vg_t vg)
+{
+	if (auto_vg_write) {
+		return lvm_vg_write(vg);
+	}
+	return 0;
+}
+
 static PyObject *
 liblvm_library_get_version(void)
 {
@@ -152,6 +163,27 @@ liblvm_lvm_list_vg_uuids(void)
 	return pytuple;
 }
 
+/* Return the previous value, set current to passed in */
+static PyObject *
+liblvm_lvm_vg_autowrite(PyObject *self, PyObject *arg)
+{
+	PyObject *prev = NULL;
+	int rval = 0;
+	int bool = 0;
+
+	LVM_VALID();
+
+	/* In later version of python they introduced "p" */
+	if (!PyArg_ParseTuple(arg, "i", &bool))
+		return NULL;
+
+	prev = (auto_vg_write) ? Py_True : Py_False;
+	Py_INCREF(prev);
+	auto_vg_write = bool;
+
+	return prev;
+}
+
 static PyObject *
 liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
 {
@@ -374,6 +406,32 @@ liblvm_lvm_vg_close(vgobject *self)
 }
 
 static PyObject *
+liblvm_lvm_vg_write(vgobject *self)
+{
+	int rval;
+
+	VG_VALID(self);
+
+	if (!auto_vg_write) {
+		rval = lvm_vg_write(self->vg);
+		if (-1 == rval) {
+			PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+			return NULL;
+		} else {
+			Py_INCREF(Py_None);
+			return Py_None;
+		}
+	}
+
+	/*
+	 * Can't call this function directly if you we have auto vg write
+	 * enabled
+	 */
+	PyErr_SetString(PyExc_ValueError, "lvm.vgAutoWrite() == True"); \
+	return NULL;
+}
+
+static PyObject *
 liblvm_lvm_vg_get_name(vgobject *self)
 {
 	VG_VALID(self);
@@ -400,14 +458,17 @@ liblvm_lvm_vg_remove(vgobject *self)
 	if ((rval = lvm_vg_remove(self->vg)) == -1)
 		goto error;
 
-	if (lvm_vg_write(self->vg) == -1)
-		goto error;
+	/* If we aren't writing out the change leave the object ref. alone */
+	if (auto_vg_write) {
 
-	/* Not much you can do with a vg that is removed so close it */
-	if (lvm_vg_close(self->vg) == -1)
-		goto error;
+		if (lvm_vg_write(self->vg) == -1)
+			goto error;
 
-	self->vg = NULL;
+		if (lvm_vg_close(self->vg) == -1)
+			goto error;
+
+		self->vg = NULL;
+	}
 
 	Py_INCREF(Py_None);
 	return Py_None;
@@ -432,8 +493,9 @@ liblvm_lvm_vg_extend(vgobject *self, PyObject *args)
 	if ((rval = lvm_vg_extend(self->vg, device)) == -1)
 		goto error;
 
-	if (lvm_vg_write(self->vg) == -1)
+	if (lvm_vg_write_auto(self->vg) == -1) {
 		goto error;
+	}
 
 	Py_INCREF(Py_None);
 	return Py_None;
@@ -458,8 +520,9 @@ liblvm_lvm_vg_reduce(vgobject *self, PyObject *args)
 	if ((rval = lvm_vg_reduce(self->vg, device)) == -1)
 		goto error;
 
-	if (lvm_vg_write(self->vg) == -1)
+	if (lvm_vg_write_auto(self->vg) == -1) {
 		goto error;
+	}
 
 	Py_INCREF(Py_None);
 	return Py_None;
@@ -483,8 +546,9 @@ liblvm_lvm_vg_add_tag(vgobject *self, PyObject *args)
 	if ((rval = lvm_vg_add_tag(self->vg, tag)) == -1)
 		goto error;
 
-	if (lvm_vg_write(self->vg) == -1)
+	if (lvm_vg_write_auto(self->vg) == -1) {
 		goto error;
+	}
 
 	return Py_BuildValue("i", rval);
 
@@ -508,8 +572,9 @@ liblvm_lvm_vg_remove_tag(vgobject *self, PyObject *args)
 	if ((rval = lvm_vg_remove_tag(self->vg, tag)) == -1)
 		goto error;
 
-	if (lvm_vg_write(self->vg) == -1)
+	if (lvm_vg_write_auto(self->vg) == -1) {
 		goto error;
+	}
 
 	Py_INCREF(Py_None);
 	return Py_None;
@@ -731,7 +796,7 @@ liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 		goto lvmerror;
 	}
 
-	if (lvm_vg_write(self->vg) == -1) {
+	if (lvm_vg_write_auto(self->vg) == -1) {
 		goto lvmerror;
 	}
 
@@ -1553,6 +1618,7 @@ static PyMethodDef Liblvm_methods[] = {
 	{ "percentToFloat",	(PyCFunction)liblvm_lvm_percent_to_float, METH_VARARGS },
 	{ "vgNameFromPvid",	(PyCFunction)liblvm_lvm_vgname_from_pvid, METH_VARARGS },
 	{ "vgNameFromDevice",	(PyCFunction)liblvm_lvm_vgname_from_device, METH_VARARGS },
+	{ "vgAutoWrite",	(PyCFunction)liblvm_lvm_vg_autowrite, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
@@ -1589,6 +1655,7 @@ static PyMethodDef liblvm_vg_methods[] = {
 	{ "pvFromUuid", 	(PyCFunction)liblvm_lvm_pv_from_uuid, METH_VARARGS },
 	{ "getTags",		(PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
 	{ "createLvLinear",	(PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
+	{ "write",			(PyCFunction)liblvm_lvm_vg_write, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
@@ -1704,6 +1771,7 @@ initlvm(void)
 {
 	PyObject *m;
 
+	auto_vg_write = 1;
 	libh = lvm_init(NULL);
 
 	if (PyType_Ready(&LibLVMvgType) < 0)
-- 
1.7.11.7


