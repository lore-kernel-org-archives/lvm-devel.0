From: Andy Grover <grover@fedoraproject.org>
Date: Fri, 14 Dec 2012 18:33:59 +0000 (UTC)
Subject: master - python-lvm: Small fixups to new create_lv_snapshot
Message-ID: <20121214183359.0822B16B9@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58b61c252a57e3e18e82cfd9cc24567339ca4508
Commit:        58b61c252a57e3e18e82cfd9cc24567339ca4508
Parent:        0db733f18ab8dd4e51c050938c699932c8dca08d
Author:        Andy Grover <agrover@redhat.com>
AuthorDate:    Fri Dec 14 10:17:29 2012 -0800
Committer:     Andy Grover <agrover@redhat.com>
CommitterDate: Fri Dec 14 10:30:26 2012 -0800

python-lvm: Small fixups to new create_lv_snapshot

Tabify

Remove use of asize, unneeded.

Don't initialize lvobj->parent_vgobj to NULL, the object ctor already
zeroed everything on alloc.

Redo call to lvm_lv_snapshot to use the liblvm snapshot implementation
we went with.

Add {}s to silence warning in lv_dealloc.

Rename snapshot function for consistency.

Update WHATS_NEW.

Signed-off-by: Andy Grover <agrover@redhat.com>
---
 WHATS_NEW       |    1 +
 python/liblvm.c |   23 +++++++----------------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 075fda2..697e4d2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add LV snapshot support to liblvm and python-lvm.
   Avoid a global lock in pvs when lvmetad is in use.
   Fix crash in pvscan --cache -aay triggered by non-mda PV.
   Allow lvconvert --stripes/stripesize only with --mirrors/--repair/--thinpool.
diff --git a/python/liblvm.c b/python/liblvm.c
index 11f5f72..3b1a4f2 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -897,8 +897,9 @@ static void
 liblvm_lv_dealloc(lvobject *self)
 {
 	/* We can dealloc an object that didn't get fully created */
-	if (self->parent_vgobj)	
+	if (self->parent_vgobj)	{
 		Py_DECREF(self->parent_vgobj);
+	}
 	PyObject_Del(self);
 }
 
@@ -1313,38 +1314,28 @@ liblvm_lvm_lv_list_lvsegs(lvobject *self)
 }
 
 static PyObject *
-liblvm_lvm_vg_create_lv_snapshot(lvobject *self, PyObject *args)
+liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 {
 	const char *vgname;
 	uint64_t size;
-	unsigned long asize;
 	lvobject *lvobj;
-	vgobject *vgobj;
-        const char *selfname = NULL;
 
 	LV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "sl", &vgname, &asize)) {
+	if (!PyArg_ParseTuple(args, "sl", &vgname, &size)) {
 		return NULL;
 	}
-        size = asize;
 
 	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
 		return NULL;
 
-	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
-	lvobj->parent_vgobj = NULL;
-
-        selfname = lvm_lv_get_name(self->lv);
-        vgobj = self->parent_vgobj;
-	if ((lvobj->lv = lvm_vg_create_lv_snapshot(vgobj->vg, selfname,
-                                                   vgname, size)) == NULL) {
+	if ((lvobj->lv = lvm_lv_snapshot(self->lv, vgname, size)) == NULL) {
 		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
 		Py_DECREF(lvobj);
 		return NULL;
 	}
 
-	lvobj->parent_vgobj = vgobj;
+	lvobj->parent_vgobj = self->parent_vgobj;
 	Py_INCREF(lvobj->parent_vgobj);
 
 	return (PyObject *)lvobj;
@@ -1618,7 +1609,7 @@ static PyMethodDef liblvm_lv_methods[] = {
 	{ "rename",		(PyCFunction)liblvm_lvm_lv_rename, METH_VARARGS },
 	{ "resize",		(PyCFunction)liblvm_lvm_lv_resize, METH_VARARGS },
 	{ "listLVsegs",		(PyCFunction)liblvm_lvm_lv_list_lvsegs, METH_NOARGS },
-	{ "snapshot",	(PyCFunction)liblvm_lvm_vg_create_lv_snapshot, METH_VARARGS },
+	{ "snapshot",		(PyCFunction)liblvm_lvm_lv_snapshot, METH_VARARGS },
 	{ NULL,	     NULL}   /* sentinel */
 };
 


