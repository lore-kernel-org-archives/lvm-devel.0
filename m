From: Andy Grover <grover@fedoraproject.org>
Date: Fri, 14 Dec 2012 18:33:56 +0000 (UTC)
Subject: master - python-lvm: Add snapshot support
Message-ID: <20121214183356.1552816B9@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0db733f18ab8dd4e51c050938c699932c8dca08d
Commit:        0db733f18ab8dd4e51c050938c699932c8dca08d
Parent:        90467a1412e8c227f83ba7825250e33a4d39607d
Author:        James Antill <james.antill@redhat.com>
AuthorDate:    Thu Dec 13 17:39:09 2012 -0800
Committer:     Andy Grover <agrover@redhat.com>
CommitterDate: Fri Dec 14 10:30:13 2012 -0800

python-lvm: Add snapshot support

Signed-off-by: Andy Grover <agrover@redhat.com>
---
 python/liblvm.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 6ccc5ba..11f5f72 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1312,6 +1312,44 @@ liblvm_lvm_lv_list_lvsegs(lvobject *self)
 	return pytuple;
 }
 
+static PyObject *
+liblvm_lvm_vg_create_lv_snapshot(lvobject *self, PyObject *args)
+{
+	const char *vgname;
+	uint64_t size;
+	unsigned long asize;
+	lvobject *lvobj;
+	vgobject *vgobj;
+        const char *selfname = NULL;
+
+	LV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "sl", &vgname, &asize)) {
+		return NULL;
+	}
+        size = asize;
+
+	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
+		return NULL;
+
+	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
+	lvobj->parent_vgobj = NULL;
+
+        selfname = lvm_lv_get_name(self->lv);
+        vgobj = self->parent_vgobj;
+	if ((lvobj->lv = lvm_vg_create_lv_snapshot(vgobj->vg, selfname,
+                                                   vgname, size)) == NULL) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+		Py_DECREF(lvobj);
+		return NULL;
+	}
+
+	lvobj->parent_vgobj = vgobj;
+	Py_INCREF(lvobj->parent_vgobj);
+
+	return (PyObject *)lvobj;
+}
+
 /* PV Methods */
 
 #define PV_VALID(pvobject)						\
@@ -1580,6 +1618,7 @@ static PyMethodDef liblvm_lv_methods[] = {
 	{ "rename",		(PyCFunction)liblvm_lvm_lv_rename, METH_VARARGS },
 	{ "resize",		(PyCFunction)liblvm_lvm_lv_resize, METH_VARARGS },
 	{ "listLVsegs",		(PyCFunction)liblvm_lvm_lv_list_lvsegs, METH_NOARGS },
+	{ "snapshot",	(PyCFunction)liblvm_lvm_vg_create_lv_snapshot, METH_VARARGS },
 	{ NULL,	     NULL}   /* sentinel */
 };
 


