From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 25 Oct 2012 23:10:24 +0000 (UTC)
Subject: master - python-lvm: Memory leaks & seg. fault fixes
Message-ID: <20121025231025.03D411212@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bbff143d54b890f3b9c91b302f0322469ba56ef6
Commit:        bbff143d54b890f3b9c91b302f0322469ba56ef6
Parent:        291909ecafbf5594c145516c19c2ce87c874ffb1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 25 17:31:11 2012 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Oct 25 18:09:10 2012 -0500

python-lvm: Memory leaks & seg. fault fixes

Issues found (thus far) in unit test developemnt for python bindings.

Added Py_DECREF(ptr) in liblvm_lvm_vg_open & liblvm_lvm_vg_create
in error paths so that we correctly clean up memory.

Added a call to lvm_vg_close when we remove a vg.  The code was
clearing out the vg pointer which prevented us from actually
calling lvm_vg_close in the close path.

liblvm_lvm_vg_create_lv_linear was not initializing
lvobj->parent_vgobj and if lvm_vg_create_lv_linear failed
we went through liblvm_lv_dealloc on clean up and tried to
Py_DECREF an invalid pointer.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 4da2999..831493e 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -309,6 +309,7 @@ liblvm_lvm_vg_open(PyObject *self, PyObject *args)
 
 	if ((vgobj->vg = lvm_vg_open(libh, vgname, mode, 0))== NULL) {
 		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+		Py_DECREF(vgobj);
 		return NULL;
 	}
 
@@ -332,6 +333,7 @@ liblvm_lvm_vg_create(PyObject *self, PyObject *args)
 
 	if ((vgobj->vg = lvm_vg_create(libh, vgname))== NULL) {
 		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+		Py_DECREF(vgobj);
 		return NULL;
 	}
 
@@ -401,6 +403,10 @@ liblvm_lvm_vg_remove(vgobject *self)
 	if (lvm_vg_write(self->vg) == -1)
 		goto error;
 
+	/* Not much you can do with a vg that is removed so close it */
+	if (lvm_vg_close(self->vg) == -1)
+		goto error;
+
 	self->vg = NULL;
 
 	Py_INCREF(Py_None);
@@ -872,6 +878,9 @@ liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
 	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
 		return NULL;
 
+	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
+	lvobj->parent_vgobj = NULL;
+
 	if ((lvobj->lv = lvm_vg_create_lv_linear(self->vg, vgname, size)) == NULL) {
 		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
 		Py_DECREF(lvobj);
@@ -887,7 +896,9 @@ liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
 static void
 liblvm_lv_dealloc(lvobject *self)
 {
-	Py_DECREF(self->parent_vgobj);
+	/* We can dealloc an object that didn't get fully created */
+	if (self->parent_vgobj)	
+		Py_DECREF(self->parent_vgobj);
 	PyObject_Del(self);
 }
 


