From: Andy Grover <agrover@redhat.com>
Date: Tue,  2 Oct 2012 09:03:43 -0700
Subject: [PATCH 2/4] python-lvm: feature parity with liblvm
In-Reply-To: <1349193825-32244-1-git-send-email-agrover@redhat.com>
References: <1349193825-32244-1-git-send-email-agrover@redhat.com>
Message-ID: <1349193825-32244-3-git-send-email-agrover@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Tony Asleson <tasleson@redhat.com>

This patch set brings python-lvm up to date with the features that are currently
in lvm2app.h.

Minimal unit testing has been done at this time.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
Signed-off-by: Andy Grover <agrover@redhat.com>
---
 liblvm/python/liblvm.c |  497 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 496 insertions(+), 1 deletions(-)

diff --git a/liblvm/python/liblvm.c b/liblvm/python/liblvm.c
index 79ca9c9..9ab9386 100644
--- a/liblvm/python/liblvm.c
+++ b/liblvm/python/liblvm.c
@@ -17,7 +17,8 @@
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  *
  * Authors: Lars Sjostrom (lars sjostrom redhat com)
- *	  Andy Grover (agrover redhat com)
+ *	    Andy Grover (agrover redhat com)
+ *	    Tony Asleson (tasleson redhat com)
  *
  */
 
@@ -47,9 +48,23 @@ typedef struct {
 	lvmobject *lvm_obj;
 } pvobject;
 
+typedef struct {
+	PyObject_HEAD
+	lvseg_t    lv_seg;	      /* lv segment handle */
+	lvmobject *lvm_obj;
+} lvsegobject;
+
+typedef struct {
+	PyObject_HEAD
+	pvseg_t    pv_seg;	      /* pv segment handle */
+	lvmobject *lvm_obj;
+} pvsegobject;
+
 static PyTypeObject LibLVMvgType;
 static PyTypeObject LibLVMlvType;
 static PyTypeObject LibLVMpvType;
+static PyTypeObject LibLVMlvsegType;
+static PyTypeObject LibLVMpvsegType;
 
 static PyObject *LibLVMError;
 
@@ -191,6 +206,21 @@ liblvm_lvm_list_vg_uuids(lvmobject *self)
 }
 
 static PyObject *
+liblvm_lvm_percent_to_float(lvmobject *self, PyObject *arg)
+{
+	double converted;
+	int percent;
+
+	LVM_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "i", &percent))
+		return NULL;
+
+	converted = lvm_percent_to_float(percent);
+	return Py_BuildValue("d", converted);
+}
+
+static PyObject *
 liblvm_lvm_vgname_from_pvid(lvmobject *self, PyObject *arg)
 {
 	const char *pvid;
@@ -228,6 +258,31 @@ liblvm_lvm_vgname_from_device(lvmobject *self, PyObject *arg)
 	return Py_BuildValue("s", vgname);
 }
 
+
+static PyObject *
+liblvm_lvm_config_find_bool(lvmobject *self, PyObject *arg)
+{
+	const char *config;
+	int rval;
+	PyObject *rc;
+
+	LVM_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "s", &config))
+		return NULL;
+
+	if ((rval = lvm_config_find_bool(self->libh, config, -10)) == -10) {
+		/* Retrieving error information yields no error in this case */
+		PyErr_Format(PyExc_ValueError, "config path not found");
+		return NULL;
+	}
+
+	rc = (rval) ? Py_True: Py_False;
+
+	Py_INCREF(rc);
+	return rc;
+}
+
 static PyObject *
 liblvm_lvm_config_reload(lvmobject *self)
 {
@@ -602,6 +657,151 @@ liblvm_lvm_vg_get_free_extent_count(vgobject *self)
 	return Py_BuildValue("l", lvm_vg_get_free_extent_count(self->vg));
 }
 
+/* Builds a python tuple ([string|number], bool) from a struct lvm_property_value */
+static PyObject *
+get_property(lvmobject *h, struct lvm_property_value *prop)
+{
+	PyObject *pytuple;
+	PyObject *setable;
+
+	if( !prop->is_valid ) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(h));
+		return NULL;
+	}
+
+	pytuple = PyTuple_New(2);
+	if (!pytuple)
+		return NULL;
+
+	if( prop->is_integer ) {
+		PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop->value.integer));
+	} else {
+		PyTuple_SET_ITEM(pytuple, 0, PyString_FromString(prop->value.string));
+	}
+
+	if (prop->is_settable) {
+		setable = Py_True;
+	} else {
+		setable = Py_False;
+	}
+
+	Py_INCREF(setable);
+	PyTuple_SET_ITEM(pytuple, 1, setable);
+	return pytuple;
+}
+
+/* This will return a tuple of (value, bool) with the value being a string or
+   integer and bool indicating if property is settable */
+static PyObject *
+liblvm_lvm_vg_get_property(vgobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_vg_get_property(self->vg, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
+static PyObject *
+liblvm_lvm_vg_set_property(vgobject *self,  PyObject *args)
+{
+	const char *property_name = NULL;
+	PyObject *variant_type_arg = NULL;
+	struct lvm_property_value lvm_property;
+	char *string_value = NULL;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "sO", &property_name, &variant_type_arg))
+		return NULL;
+
+	lvm_property = lvm_vg_get_property(self->vg, property_name);
+
+	if( !lvm_property.is_valid ) {
+		goto lvmerror;
+	}
+
+	if(PyObject_IsInstance(variant_type_arg, (PyObject*)&PyString_Type)) {
+
+		if (!lvm_property.is_string) {
+			PyErr_Format(PyExc_ValueError, "Property requires string value");
+			goto bail;
+		}
+
+		/* Based on cursory code inspection this path may cause a memory
+		   leak when calling into set_property, need to verify*/
+		string_value = strdup(PyString_AsString(variant_type_arg));
+		lvm_property.value.string = string_value;
+		if(!lvm_property.value.string) {
+			PyErr_NoMemory();
+			goto bail;
+		}
+
+	} else {
+
+		if (!lvm_property.is_integer) {
+			PyErr_Format(PyExc_ValueError, "Property requires numeric value");
+			goto bail;
+		}
+
+		if(PyObject_IsInstance(variant_type_arg, (PyObject*)&PyInt_Type)) {
+			int temp_py_int = PyInt_AsLong(variant_type_arg);
+
+			/* -1 could be valid, need to see if an exception was gen. */
+			if( -1 == temp_py_int ) {
+				if( PyErr_Occurred() ) {
+					goto bail;
+				}
+			}
+
+			if (temp_py_int < 0) {
+				PyErr_Format(PyExc_ValueError, "Positive integers only!");
+				goto bail;
+			}
+
+			lvm_property.value.integer = temp_py_int;
+		} else if(PyObject_IsInstance(variant_type_arg, (PyObject*)&PyLong_Type)){
+			/* This will fail on negative numbers */
+			unsigned long long temp_py_long = PyLong_AsUnsignedLongLong(variant_type_arg);
+			if( (unsigned long long)-1 == temp_py_long ) {
+				goto bail;
+			}
+
+			lvm_property.value.integer = temp_py_long;
+		} else {
+			PyErr_Format(PyExc_ValueError, "supported value types are numeric and string");
+			goto bail;
+		}
+	}
+
+	if( -1 == lvm_vg_set_property(self->vg, property_name, &lvm_property) ) {
+		goto lvmerror;
+	}
+
+	if( -1 == lvm_vg_write(self->vg)) {
+		goto lvmerror;
+	}
+
+	Py_DECREF(variant_type_arg);
+	Py_INCREF(Py_None);
+	return Py_None;
+
+lvmerror:
+	PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+bail:
+	free(string_value);
+	if( variant_type_arg ) {
+		Py_DECREF(variant_type_arg);
+		variant_type_arg = NULL;
+	}
+	return NULL;
+}
+
 static PyObject *
 liblvm_lvm_vg_get_pv_count(vgobject *self)
 {
@@ -781,6 +981,89 @@ liblvm_lvm_vg_list_pvs(vgobject *vg)
 	return pytuple;
 }
 
+typedef lv_t (*lv_fetch_by_N)(vg_t vg, const char *id);
+typedef pv_t (*pv_fetch_by_N)(vg_t vg, const char *id);
+
+static PyObject *
+liblvm_lvm_lv_from_N(vgobject *self, PyObject *arg, lv_fetch_by_N method)
+{
+	const char *id;
+	lvobject *rc;
+	lv_t lv = NULL;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "s", &id))
+		return NULL;
+
+	lv = method(self->vg, id);
+	if( !lv ) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	rc = PyObject_New(lvobject, &LibLVMlvType);
+	if( !rc ) {
+		return NULL;
+	}
+
+	rc->lv = lv;
+	rc->lvm_obj = self->lvm_obj;
+	return (PyObject *)rc;
+}
+
+static PyObject *
+liblvm_lvm_lv_from_name(vgobject *self, PyObject *arg)
+{
+	return liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_name);
+}
+
+static PyObject *
+liblvm_lvm_lv_from_uuid(vgobject *self, PyObject *arg)
+{
+	return liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_uuid);
+}
+
+static PyObject *
+liblvm_lvm_pv_from_N(vgobject *self, PyObject *arg, pv_fetch_by_N method)
+{
+	const char *id;
+	pvobject *rc;
+	pv_t pv = NULL;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "s", &id))
+		return NULL;
+
+	pv = method(self->vg, id);
+	if( !pv ) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	rc = PyObject_New(pvobject, &LibLVMpvType);
+	if( !rc ) {
+		return NULL;
+	}
+
+	rc->pv = pv;
+	rc->lvm_obj = self->lvm_obj;
+	return (PyObject *)rc;
+}
+
+static PyObject *
+liblvm_lvm_pv_from_name(vgobject *self, PyObject *arg)
+{
+	return liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_name);
+}
+
+static PyObject *
+liblvm_lvm_pv_from_uuid(vgobject *self, PyObject *arg)
+{
+	return liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_uuid);
+}
+
 static void
 liblvm_pv_dealloc(pvobject *self)
 {
@@ -864,6 +1147,23 @@ liblvm_lvm_vg_remove_lv(lvobject *self)
 	return Py_None;
 }
 
+/* This will return a tuple of (value, bool) with the value being a string or
+   integer and bool indicating if property is settable */
+static PyObject *
+liblvm_lvm_lv_get_property(lvobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	LV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_lv_get_property(self->lv, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
 static PyObject *
 liblvm_lvm_lv_get_size(lvobject *self)
 {
@@ -969,6 +1269,26 @@ liblvm_lvm_lv_get_tags(lvobject *self)
 }
 
 static PyObject *
+liblvm_lvm_lv_rename(lvobject *self, PyObject *args)
+{
+	const char *new_name;
+	int rval;
+
+	LV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &new_name))
+		return NULL;
+
+	if ((rval = lvm_lv_rename(self->lv, new_name)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
 liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
 {
 	uint64_t new_size;
@@ -989,8 +1309,53 @@ liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
 	return Py_None;
 }
 
+static PyObject *
+liblvm_lvm_lv_list_lvsegs(lvobject *lv)
+{
+	struct dm_list  *lvsegs;
+	lvseg_list_t    *lvsegl;
+	PyObject * pytuple;
+	lvsegobject *self;
+	int i = 0;
+
+	LV_VALID(lv);
+
+	lvsegs = lvm_lv_list_lvsegs(lv->lv);
+	if(!lvsegs) {
+		return Py_BuildValue("()");
+	}
+
+	pytuple = PyTuple_New(dm_list_size(lvsegs));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(lvsegl, lvsegs) {
+		/* Create and initialize the object */
+		self = PyObject_New(lvsegobject, &LibLVMlvsegType);
+		if (!self) {
+			Py_DECREF(pytuple);
+			return NULL;
+		}
+
+		self->lv_seg = lvsegl->lvseg;
+		self->lvm_obj = lv->lvm_obj;
+		PyTuple_SET_ITEM(pytuple, i, (PyObject *) self);
+		i++;
+	}
+
+	return pytuple;
+}
+
 /* PV Methods */
 
+#define PV_VALID(pvobject)						\
+	do {								\
+		if (!pvobject->pv || !pvobject->lvm_obj) {		\
+			PyErr_SetString(PyExc_UnboundLocalError, "PV object invalid"); \
+			return NULL;					\
+		}							\
+	} while (0)
+
 static PyObject *
 liblvm_lvm_pv_get_name(pvobject *self)
 {
@@ -1010,6 +1375,21 @@ liblvm_lvm_pv_get_mda_count(pvobject *self)
 }
 
 static PyObject *
+liblvm_lvm_pv_get_property(pvobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	PV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_pv_get_property(self->pv, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
+static PyObject *
 liblvm_lvm_pv_get_dev_size(pvobject *self)
 {
 	return Py_BuildValue("l", lvm_pv_get_dev_size(self->pv));
@@ -1046,6 +1426,85 @@ liblvm_lvm_pv_resize(pvobject *self, PyObject *args)
 	return Py_None;
 }
 
+static PyObject *
+liblvm_lvm_lv_list_pvsegs(pvobject *pv)
+{
+	struct dm_list *pvsegs;
+	pvseg_list_t *pvsegl;
+	PyObject *pytuple;
+	pvsegobject *self;
+	int i = 0;
+
+	PV_VALID(pv);
+
+	pvsegs = lvm_pv_list_pvsegs(pv->pv);
+	if(!pvsegs) {
+		return Py_BuildValue("()");
+	}
+
+	pytuple = PyTuple_New(dm_list_size(pvsegs));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(pvsegl, pvsegs) {
+		/* Create and initialize the object */
+		self = PyObject_New(pvsegobject, &LibLVMpvsegType);
+		if (!self) {
+			Py_DECREF(pytuple);
+			return NULL;
+		}
+
+		self->pv_seg = pvsegl->pvseg;
+		self->lvm_obj = pv->lvm_obj;
+		PyTuple_SET_ITEM(pytuple, i, (PyObject *) self);
+		i++;
+	}
+
+	return pytuple;
+}
+
+/* LV seg methods */
+
+static void
+liblvm_lvseg_dealloc(lvsegobject *self)
+{
+	PyObject_Del(self);
+}
+
+static PyObject *
+liblvm_lvm_lvseg_get_property(lvsegobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_lvseg_get_property(self->lv_seg, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
+/* PV seg methods */
+
+static void
+liblvm_pvseg_dealloc(pvsegobject *self)
+{
+	PyObject_Del(self);
+}
+
+static PyObject *
+liblvm_lvm_pvseg_get_property(pvsegobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_pvseg_get_property(self->pv_seg, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
 /* ----------------------------------------------------------------------
  * Method tables and other bureaucracy
  */
@@ -1138,6 +1597,16 @@ static PyMethodDef liblvm_pv_methods[] = {
 	{ NULL,	     NULL}   /* sentinel */
 };
 
+static PyMethodDef liblvm_lvseg_methods[] = {
+	{ "getProperty", 	(PyCFunction)liblvm_lvm_lvseg_get_property, METH_VARARGS },
+	{ NULL,	     NULL}   /* sentinel */
+};
+
+static PyMethodDef liblvm_pvseg_methods[] = {
+	{ "getProperty", 	(PyCFunction)liblvm_lvm_pvseg_get_property, METH_VARARGS },
+	{ NULL,	     NULL}   /* sentinel */
+};
+
 static PyTypeObject LiblvmType = {
 	PyObject_HEAD_INIT(&PyType_Type)
 	.tp_name = "liblvm.Liblvm",
@@ -1183,6 +1652,28 @@ static PyTypeObject LibLVMpvType = {
 	.tp_methods = liblvm_pv_methods,
 };
 
+static PyTypeObject LibLVMlvsegType = {
+	PyObject_HEAD_INIT(&PyType_Type)
+	.tp_name = "liblvm.Liblvm_lvseg",
+	.tp_basicsize = sizeof(lvsegobject),
+	.tp_new = PyType_GenericNew,
+	.tp_dealloc = (destructor)liblvm_lvseg_dealloc,
+	.tp_flags = Py_TPFLAGS_DEFAULT,
+	.tp_doc = "LVM Logical Volume Segment object",
+	.tp_methods = liblvm_lvseg_methods,
+};
+
+static PyTypeObject LibLVMpvsegType = {
+	PyObject_HEAD_INIT(&PyType_Type)
+	.tp_name = "liblvm.Liblvm_pvseg",
+	.tp_basicsize = sizeof(pvsegobject),
+	.tp_new = PyType_GenericNew,
+	.tp_dealloc = (destructor)liblvm_pvseg_dealloc,
+	.tp_flags = Py_TPFLAGS_DEFAULT,
+	.tp_doc = "LVM Physical Volume Segment object",
+	.tp_methods = liblvm_pvseg_methods,
+};
+
 PyMODINIT_FUNC
 initlvm(void)
 {
@@ -1196,6 +1687,10 @@ initlvm(void)
 		return;
 	if (PyType_Ready(&LibLVMpvType) < 0)
 		return;
+	if (PyType_Ready(&LibLVMlvsegType) < 0)
+		return;
+	if (PyType_Ready(&LibLVMpvsegType) < 0)
+		return;
 
 	m = Py_InitModule3("lvm", Liblvm_methods, "Liblvm module");
 	if (m == NULL)
-- 
1.7.1


