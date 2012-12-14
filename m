From: Andy Grover <grover@fedoraproject.org>
Date: Fri, 14 Dec 2012 18:34:01 +0000 (UTC)
Subject: master - python-lvm: whitespace in python/liblvm.c.
Message-ID: <20121214183401.76F2C16B9@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e3093979e901384aecb22e08d83b5acb2ef12c1
Commit:        0e3093979e901384aecb22e08d83b5acb2ef12c1
Parent:        58b61c252a57e3e18e82cfd9cc24567339ca4508
Author:        Andy Grover <agrover@redhat.com>
AuthorDate:    Fri Dec 14 10:32:35 2012 -0800
Committer:     Andy Grover <agrover@redhat.com>
CommitterDate: Fri Dec 14 10:32:35 2012 -0800

python-lvm: whitespace in python/liblvm.c.

Sorry, it bugged me. Should be perfect now.

Signed-off-by: Andy Grover <agrover@redhat.com>
---
 python/liblvm.c |   44 ++++++++++++++++++++++----------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 3b1a4f2..906825e 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -29,31 +29,31 @@ static lvm_t libh;
 
 typedef struct {
 	PyObject_HEAD
-	vg_t      vg;		    /* vg handle */
+	vg_t vg;		/* vg handle */
 } vgobject;
 
 typedef struct {
 	PyObject_HEAD
-	lv_t      lv;		    /* lv handle */
-	vgobject  *parent_vgobj;
+	lv_t lv;		/* lv handle */
+	vgobject *parent_vgobj;
 } lvobject;
 
 typedef struct {
 	PyObject_HEAD
-	pv_t      pv;		    /* pv handle */
-	vgobject  *parent_vgobj;
+	pv_t pv;		/* pv handle */
+	vgobject *parent_vgobj;
 } pvobject;
 
 typedef struct {
 	PyObject_HEAD
-	lvseg_t    lv_seg;	      /* lv segment handle */
-	lvobject  *parent_lvobj;
+	lvseg_t lv_seg;		/* lv segment handle */
+	lvobject *parent_lvobj;
 } lvsegobject;
 
 typedef struct {
 	PyObject_HEAD
-	pvseg_t    pv_seg;	      /* pv segment handle */
-	pvobject   *parent_pvobj;
+	pvseg_t pv_seg;		/* pv segment handle */
+	pvobject *parent_pvobj;
 } pvsegobject;
 
 static PyTypeObject LibLVMvgType;
@@ -643,7 +643,7 @@ get_property(struct lvm_property_value *prop)
 /* This will return a tuple of (value, bool) with the value being a string or
    integer and bool indicating if property is settable */
 static PyObject *
-liblvm_lvm_vg_get_property(vgobject *self,  PyObject *args)
+liblvm_lvm_vg_get_property(vgobject *self, PyObject *args)
 {
 	const char *name;
 	struct lvm_property_value prop_value;
@@ -658,7 +658,7 @@ liblvm_lvm_vg_get_property(vgobject *self,  PyObject *args)
 }
 
 static PyObject *
-liblvm_lvm_vg_set_property(vgobject *self,  PyObject *args)
+liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 {
 	const char *property_name = NULL;
 	PyObject *variant_type_arg = NULL;
@@ -1277,8 +1277,8 @@ liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
 static PyObject *
 liblvm_lvm_lv_list_lvsegs(lvobject *self)
 {
-	struct dm_list  *lvsegs;
-	lvseg_list_t    *lvsegl;
+	struct dm_list *lvsegs;
+	lvseg_list_t *lvsegl;
 	PyObject * pytuple;
 	lvsegobject *lvsegobj;
 	int i = 0;
@@ -1377,7 +1377,7 @@ liblvm_lvm_pv_get_mda_count(pvobject *self)
 }
 
 static PyObject *
-liblvm_lvm_pv_get_property(pvobject *self,  PyObject *args)
+liblvm_lvm_pv_get_property(pvobject *self, PyObject *args)
 {
 	const char *name;
 	struct lvm_property_value prop_value;
@@ -1491,7 +1491,7 @@ liblvm_lvseg_dealloc(lvsegobject *self)
 }
 
 static PyObject *
-liblvm_lvm_lvseg_get_property(lvsegobject *self,  PyObject *args)
+liblvm_lvm_lvseg_get_property(lvsegobject *self, PyObject *args)
 {
 	const char *name;
 	struct lvm_property_value prop_value;
@@ -1521,7 +1521,7 @@ liblvm_pvseg_dealloc(pvsegobject *self)
 }
 
 static PyObject *
-liblvm_lvm_pvseg_get_property(pvsegobject *self,  PyObject *args)
+liblvm_lvm_pvseg_get_property(pvsegobject *self, PyObject *args)
 {
 	const char *name;
 	struct lvm_property_value prop_value;
@@ -1553,7 +1553,7 @@ static PyMethodDef Liblvm_methods[] = {
 	{ "percentToFloat",	(PyCFunction)liblvm_lvm_percent_to_float, METH_VARARGS },
 	{ "vgNameFromPvid",	(PyCFunction)liblvm_lvm_vgname_from_pvid, METH_VARARGS },
 	{ "vgNameFromDevice",	(PyCFunction)liblvm_lvm_vgname_from_device, METH_VARARGS },
-	{ NULL,	     NULL}	   /* sentinel */
+	{ NULL, NULL }		/* sentinel */
 };
 
 static PyMethodDef liblvm_vg_methods[] = {
@@ -1589,7 +1589,7 @@ static PyMethodDef liblvm_vg_methods[] = {
 	{ "pvFromUuid", 	(PyCFunction)liblvm_lvm_pv_from_uuid, METH_VARARGS },
 	{ "getTags",		(PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
 	{ "createLvLinear",	(PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
-	{ NULL,	     NULL}   /* sentinel */
+	{ NULL, NULL }		/* sentinel */
 };
 
 static PyMethodDef liblvm_lv_methods[] = {
@@ -1610,7 +1610,7 @@ static PyMethodDef liblvm_lv_methods[] = {
 	{ "resize",		(PyCFunction)liblvm_lvm_lv_resize, METH_VARARGS },
 	{ "listLVsegs",		(PyCFunction)liblvm_lvm_lv_list_lvsegs, METH_NOARGS },
 	{ "snapshot",		(PyCFunction)liblvm_lvm_lv_snapshot, METH_VARARGS },
-	{ NULL,	     NULL}   /* sentinel */
+	{ NULL, NULL }		/* sentinel */
 };
 
 static PyMethodDef liblvm_pv_methods[] = {
@@ -1624,17 +1624,17 @@ static PyMethodDef liblvm_pv_methods[] = {
 	{ "getFree",		(PyCFunction)liblvm_lvm_pv_get_free, METH_NOARGS },
 	{ "resize",		(PyCFunction)liblvm_lvm_pv_resize, METH_VARARGS },
 	{ "listPVsegs", 	(PyCFunction)liblvm_lvm_pv_list_pvsegs, METH_NOARGS },
-	{ NULL,	     NULL}   /* sentinel */
+	{ NULL, NULL }		/* sentinel */
 };
 
 static PyMethodDef liblvm_lvseg_methods[] = {
 	{ "getProperty", 	(PyCFunction)liblvm_lvm_lvseg_get_property, METH_VARARGS },
-	{ NULL,	     NULL}   /* sentinel */
+	{ NULL, NULL }		/* sentinel */
 };
 
 static PyMethodDef liblvm_pvseg_methods[] = {
 	{ "getProperty", 	(PyCFunction)liblvm_lvm_pvseg_get_property, METH_VARARGS },
-	{ NULL,	     NULL}   /* sentinel */
+	{ NULL, NULL }		/* sentinel */
 };
 
 static PyTypeObject LibLVMvgType = {


