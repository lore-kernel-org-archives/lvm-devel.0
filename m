From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 15 Nov 2012 20:53:23 -0600
Subject: [PATCH 2/2] python-lvm: Add lv snapshot
In-Reply-To: <1353034403-17049-1-git-send-email-tasleson@redhat.com>
References: <1353034403-17049-1-git-send-email-tasleson@redhat.com>
Message-ID: <1353034403-17049-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 68 ++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 51 insertions(+), 17 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 831493e..c31a62f 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -72,6 +72,15 @@ static PyObject *LibLVMError;
 		}							\
 	} while (0)
 
+#define LV_VALID(lvobject)						\
+	do {								\
+		VG_VALID(lvobject->parent_vgobj);			\
+		if (!lvobject->lv) {					\
+			PyErr_SetString(PyExc_UnboundLocalError, "LV object invalid"); \
+			return NULL;					\
+		}							\
+	} while (0)
+
 static PyObject *
 liblvm_get_last_error(void)
 {
@@ -862,16 +871,26 @@ liblvm_lvm_vg_get_tags(vgobject *self)
 	return pytuple;
 }
 
+enum lv_create { PY_LV_LINEAR, PY_LV_SNAPSHOT };
+
 static PyObject *
-liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
+_liblvm_lv_create(void *self, PyObject *args, enum lv_create op)
 {
-	const char *vgname;
+	const char *name;
 	uint64_t size;
 	lvobject *lvobj;
+	vgobject *vgp = NULL;
+	lvobject *lvp = NULL;
 
-	VG_VALID(self);
+	if (op == PY_LV_LINEAR) {
+		vgp = (vgobject *)self;
+		VG_VALID(vgp);
+	} else {
+		lvp = (lvobject *)self;
+		LV_VALID(lvp);
+	}
 
-	if (!PyArg_ParseTuple(args, "sl", &vgname, &size)) {
+	if (!PyArg_ParseTuple(args, "sl", &name, &size)) {
 		return NULL;
 	}
 
@@ -881,23 +900,47 @@ liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
 	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
 	lvobj->parent_vgobj = NULL;
 
-	if ((lvobj->lv = lvm_vg_create_lv_linear(self->vg, vgname, size)) == NULL) {
+	if (op == PY_LV_LINEAR) {
+		lvobj->lv = lvm_vg_create_lv_linear(vgp->vg, name, size);
+
+		if(lvobj->lv) {
+			lvobj->parent_vgobj = self;
+		}
+	} else {
+		lvobj->lv = lvm_lv_snapshot(lvp->lv, name, size);
+		if(lvobj->lv) {
+			lvobj->parent_vgobj = lvp->parent_vgobj;
+		}
+	}
+
+	if(!lvobj->lv) {
 		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
 		Py_DECREF(lvobj);
 		return NULL;
 	}
 
-	lvobj->parent_vgobj = self;
 	Py_INCREF(lvobj->parent_vgobj);
 
 	return (PyObject *)lvobj;
 }
 
+static PyObject *
+liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
+{
+	return _liblvm_lv_create(self, args, PY_LV_LINEAR);
+}
+
+static PyObject *
+liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
+{
+	return _liblvm_lv_create(self, args, PY_LV_SNAPSHOT);
+}
+
 static void
 liblvm_lv_dealloc(lvobject *self)
 {
 	/* We can dealloc an object that didn't get fully created */
-	if (self->parent_vgobj)	
+	if (self->parent_vgobj)
 		Py_DECREF(self->parent_vgobj);
 	PyObject_Del(self);
 }
@@ -1035,16 +1078,6 @@ liblvm_pv_dealloc(pvobject *self)
 
 /* LV Methods */
 
-#define LV_VALID(lvobject)						\
-	do {								\
-		VG_VALID(lvobject->parent_vgobj);			\
-		if (!lvobject->lv) {					\
-			PyErr_SetString(PyExc_UnboundLocalError, "LV object invalid"); \
-			return NULL;					\
-		}							\
-	} while (0)
-
-
 static PyObject *
 liblvm_lvm_lv_get_name(lvobject *self)
 {
@@ -1580,6 +1613,7 @@ static PyMethodDef liblvm_lv_methods[] = {
 	{ "rename",		(PyCFunction)liblvm_lvm_lv_rename, METH_VARARGS },
 	{ "resize",		(PyCFunction)liblvm_lvm_lv_resize, METH_VARARGS },
 	{ "listLVsegs",		(PyCFunction)liblvm_lvm_lv_list_lvsegs, METH_NOARGS },
+	{ "snapshot",		(PyCFunction)liblvm_lvm_lv_snapshot, METH_VARARGS },
 	{ NULL,	     NULL}   /* sentinel */
 };
 
-- 
1.7.11.7


