From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 14 Nov 2013 08:42:59 -0600
Subject: [PATCH 02/13] python-lvm: Robustness improvements.
In-Reply-To: <1384440190-5759-1-git-send-email-tasleson@redhat.com>
References: <1384440190-5759-1-git-send-email-tasleson@redhat.com>
Message-ID: <1384440190-5759-3-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add checks so if a user recycles the library handle
any left over references to old libraries are caught.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c | 219 ++++++++++++++++++++++++++------------------------------
 1 file changed, 103 insertions(+), 116 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 42a327e..36b64e4 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -30,11 +30,13 @@ static lvm_t _libh;
 typedef struct {
 	PyObject_HEAD
 	vg_t vg;		/* vg handle */
+	lvm_t libh_copy;
 } vgobject;
 
 typedef struct {
 	PyObject_HEAD
 	struct dm_list *pvslist;
+	lvm_t libh_copy;
 } pvslistobject;
 
 typedef struct {
@@ -71,9 +73,14 @@ static PyTypeObject _LibLVMpvsegType;
 
 static PyObject *_LibLVMError;
 
-#define LVM_VALID() \
+#define LVM_VALID(ptr) \
 	do { \
-		if (!_libh) { \
+		if (ptr && _libh) { \
+			if (ptr != _libh) { \
+				PyErr_SetString(PyExc_UnboundLocalError, "LVM handle reference stale"); \
+				return NULL; \
+			} \
+		} else if (!_libh) { \
 			PyErr_SetString(PyExc_UnboundLocalError, "LVM handle invalid"); \
 			return NULL; \
 		} \
@@ -99,17 +106,42 @@ static vgobject *_create_py_vg(void)
 {
 	vgobject *vgobj = PyObject_New(vgobject, &_LibLVMvgType);
 
-	if (vgobj)
+	if (vgobj) {
 		vgobj->vg = NULL;
+		vgobj->libh_copy = _libh;
+	}
 
 	return vgobj;
 }
 
+static pvslistobject *_create_py_pvlist(void)
+{
+	pvslistobject *pvlistobj = PyObject_New(pvslistobject, &_LibLVMpvlistType);
+
+	if (pvlistobj) {
+		pvlistobj->pvslist = NULL;
+		pvlistobj->libh_copy = _libh;
+	}
+
+	return pvlistobj;
+}
+
+static lvobject *_create_py_lv(vgobject *parent, lv_t lv)
+{
+	lvobject * lvobj = PyObject_New(lvobject, &_LibLVMlvType);
+	if (lvobj) {
+		lvobj->parent_vgobj = parent;
+		Py_INCREF(lvobj->parent_vgobj);
+		lvobj->lv = lv;
+	}
+	return lvobj;
+}
+
 static PyObject *_liblvm_get_last_error(void)
 {
 	PyObject *info;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!(info = PyTuple_New(2)))
 		return NULL;
@@ -122,7 +154,7 @@ static PyObject *_liblvm_get_last_error(void)
 
 static PyObject *_liblvm_library_get_version(void)
 {
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	return Py_BuildValue("s", lvm_library_get_version());
 }
@@ -131,7 +163,7 @@ static const char _gc_doc[] = "Garbage collect the C library";
 
 static PyObject *_liblvm_lvm_gc(void)
 {
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	lvm_quit(_libh);
 
@@ -152,7 +184,7 @@ static PyObject *_liblvm_lvm_list_vg_names(void)
 	PyObject * pytuple;
 	int i = 0;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!(vgnames = lvm_list_vg_names(_libh))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
@@ -177,7 +209,7 @@ static PyObject *_liblvm_lvm_list_vg_uuids(void)
 	PyObject * pytuple;
 	int i = 0;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!(uuids = lvm_list_vg_uuids(_libh))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
@@ -261,23 +293,16 @@ static PyObject *_liblvm_pvlist_dealloc(pvslistobject *self)
 
 static PyObject *_liblvm_lvm_list_pvs(void)
 {
-	pvslistobject *pvslistobj;
-
-	LVM_VALID();
-
-	if (!(pvslistobj = PyObject_New(pvslistobject, &_LibLVMpvlistType)))
-		return NULL;
+	LVM_VALID(NULL);
 
-	pvslistobj->pvslist = NULL;
-
-	return (PyObject *)pvslistobj;
+	return (PyObject *)_create_py_pvlist();
 }
 
 static PyObject *_liblvm_lvm_pv_remove(PyObject *self, PyObject *arg)
 {
 	const char *pv_name;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!PyArg_ParseTuple(arg, "s", &pv_name))
 		return NULL;
@@ -297,7 +322,7 @@ static PyObject *_liblvm_lvm_pv_create(PyObject *self, PyObject *arg)
 	const char *pv_name;
 	unsigned long long size;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!PyArg_ParseTuple(arg, "sK", &pv_name, &size))
 		return NULL;
@@ -317,7 +342,7 @@ static PyObject *_liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
 	double converted;
 	int percent;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!PyArg_ParseTuple(arg, "i", &percent))
 		return NULL;
@@ -332,7 +357,7 @@ static PyObject *_liblvm_lvm_vgname_from_pvid(PyObject *self, PyObject *arg)
 	const char *pvid;
 	const char *vgname;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!PyArg_ParseTuple(arg, "s", &pvid))
 		return NULL;
@@ -350,7 +375,7 @@ static PyObject *_liblvm_lvm_vgname_from_device(PyObject *self, PyObject *arg)
 	const char *device;
 	const char *vgname;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!PyArg_ParseTuple(arg, "s", &device))
 		return NULL;
@@ -370,7 +395,7 @@ static PyObject *_liblvm_lvm_config_find_bool(PyObject *self, PyObject *arg)
 	int rval;
 	PyObject *rc;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!PyArg_ParseTuple(arg, "s", &config))
 		return NULL;
@@ -390,7 +415,7 @@ static PyObject *_liblvm_lvm_config_find_bool(PyObject *self, PyObject *arg)
 
 static PyObject *_liblvm_lvm_config_reload(void)
 {
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (lvm_config_reload(_libh) == -1) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
@@ -405,7 +430,7 @@ static PyObject *_liblvm_lvm_config_reload(void)
 
 static PyObject *_liblvm_lvm_scan(void)
 {
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (lvm_scan(_libh) == -1) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
@@ -421,7 +446,7 @@ static PyObject *_liblvm_lvm_config_override(PyObject *self, PyObject *arg)
 {
 	const char *config;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!PyArg_ParseTuple(arg, "s", &config))
 		return NULL;
@@ -447,7 +472,7 @@ static PyObject *_liblvm_lvm_vg_open(PyObject *self, PyObject *args)
 
 	vgobject *vgobj;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!PyArg_ParseTuple(args, "s|s", &vgname, &mode))
 		return NULL;
@@ -472,7 +497,7 @@ static PyObject *_liblvm_lvm_vg_create(PyObject *self, PyObject *args)
 	const char *vgname;
 	vgobject *vgobj;
 
-	LVM_VALID();
+	LVM_VALID(NULL);
 
 	if (!PyArg_ParseTuple(args, "s", &vgname))
 		return NULL;
@@ -495,6 +520,7 @@ static void liblvm_vg_dealloc(vgobject *self)
 	if (self->vg != NULL) {
 		lvm_vg_close(self->vg);
 		self->vg = NULL;
+		self->libh_copy = NULL;
 	}
 
 	PyObject_Del(self);
@@ -504,20 +530,20 @@ static void liblvm_vg_dealloc(vgobject *self)
 
 #define VG_VALID(vgobject) \
 	do { \
-		LVM_VALID(); \
-		if (!vgobject->vg) { \
+		if (!vgobject || !vgobject->vg) { \
 			PyErr_SetString(PyExc_UnboundLocalError, "VG object invalid"); \
 			return NULL; \
 		} \
+		LVM_VALID(vgobject->libh_copy); \
 	} while (0)
 
 #define PVSLIST_VALID(pvslistobject) \
 	do { \
-		LVM_VALID(); \
-		if (!pvslistobject->pvslist) { \
+		if (!pvslistobject || !pvslistobject->pvslist) { \
 			PyErr_SetString(PyExc_UnboundLocalError, "PVS object invalid"); \
 			return NULL; \
 		} \
+		LVM_VALID(pvslistobject->libh_copy); \
 	} while (0)
 
 static PyObject *_liblvm_lvm_vg_close(vgobject *self)
@@ -526,6 +552,7 @@ static PyObject *_liblvm_lvm_vg_close(vgobject *self)
 	if (self->vg) {
 		lvm_vg_close(self->vg);
 		self->vg = NULL;
+		self->libh_copy = NULL;
 	}
 
 	Py_INCREF(Py_None);
@@ -941,15 +968,11 @@ static PyObject *_liblvm_lvm_vg_list_lvs(vgobject *self)
 
 	dm_list_iterate_items(lvl, lvs) {
 		/* Create and initialize the object */
-		if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType))) {
+		if (!(lvobj = _create_py_lv(self, lvl->lv))) {
 			Py_DECREF(pytuple);
 			return NULL;
 		}
 
-		lvobj->parent_vgobj = self;
-		Py_INCREF(lvobj->parent_vgobj);
-
-		lvobj->lv = lvl->lv;
 		PyTuple_SET_ITEM(pytuple, i, (PyObject *) lvobj);
 		i++;
 	}
@@ -986,29 +1009,19 @@ static PyObject *_liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
 {
 	const char *vgname;
 	unsigned long long size;
-	lvobject *lvobj;
+	lv_t lv;
 
 	VG_VALID(self);
 
 	if (!PyArg_ParseTuple(args, "sK", &vgname, &size))
 		return NULL;
 
-	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
-		return NULL;
-
-	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
-	lvobj->parent_vgobj = NULL;
-
-	if (!(lvobj->lv = lvm_vg_create_lv_linear(self->vg, vgname, size))) {
+	if (!(lv = lvm_vg_create_lv_linear(self->vg, vgname, size))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		Py_DECREF(lvobj);
 		return NULL;
 	}
 
-	lvobj->parent_vgobj = self;
-	Py_INCREF(lvobj->parent_vgobj);
-
-	return (PyObject *)lvobj;
+	return (PyObject *)_create_py_lv(self, lv);
 }
 
 static PyObject *_liblvm_lvm_vg_create_lv_thinpool(vgobject *self, PyObject *args)
@@ -1019,7 +1032,7 @@ static PyObject *_liblvm_lvm_vg_create_lv_thinpool(vgobject *self, PyObject *arg
 	unsigned long chunk_size = 0;
 	int skip_zero = 0;
 	lvm_thin_discards_t discard = LVM_THIN_DISCARDS_PASSDOWN;
-	lvobject *lvobj;
+	lv_t lv;
 	lv_create_params_t lvp = NULL;
 	struct lvm_property_value prop_value;
 
@@ -1029,17 +1042,10 @@ static PyObject *_liblvm_lvm_vg_create_lv_thinpool(vgobject *self, PyObject *arg
 			      &meta_size, &discard, &skip_zero))
 		return NULL;
 
-	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
-		return NULL;
-
-	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
-	lvobj->parent_vgobj = NULL;
-
 	if (!(lvp = lvm_lv_params_create_thin_pool(self->vg, pool_name, size, chunk_size,
 						   meta_size, discard))) {
 
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		Py_DECREF(lvobj);
 		return NULL;
 	}
 
@@ -1051,23 +1057,20 @@ static PyObject *_liblvm_lvm_vg_create_lv_thinpool(vgobject *self, PyObject *arg
 
 			if (lvm_lv_params_set_property(lvp, "skip_zero",
 						       &prop_value) == -1) {
-				PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-				Py_DECREF(lvobj);
-				return NULL;
+				goto error;
 			}
 		}
 	}
 
-	if (!(lvobj->lv = lvm_lv_create(lvp))) {
-		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		Py_DECREF(lvobj);
-		return NULL;
+	if (!(lv = lvm_lv_create(lvp))) {
+		goto error;
 	}
 
-	lvobj->parent_vgobj = self;
-	Py_INCREF(lvobj->parent_vgobj);
+	return (PyObject *)_create_py_lv(self, lv);
 
-	return (PyObject *)lvobj;
+error:
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+	return NULL;
 }
 
 static PyObject *_liblvm_lvm_vg_create_lv_thin(vgobject *self, PyObject *args)
@@ -1075,7 +1078,7 @@ static PyObject *_liblvm_lvm_vg_create_lv_thin(vgobject *self, PyObject *args)
 	const char *pool_name;
 	const char *lv_name;
 	unsigned long long size = 0;
-	lvobject *lvobj;
+	lv_t lv;
 	lv_create_params_t lvp = NULL;
 
 	VG_VALID(self);
@@ -1083,28 +1086,17 @@ static PyObject *_liblvm_lvm_vg_create_lv_thin(vgobject *self, PyObject *args)
 	if (!PyArg_ParseTuple(args, "ssK", &pool_name, &lv_name, &size))
 		return NULL;
 
-	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
-		return NULL;
-
-	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
-	lvobj->parent_vgobj = NULL;
-
 	if (!(lvp = lvm_lv_params_create_thin(self->vg, pool_name, lv_name,size))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		Py_DECREF(lvobj);
 		return NULL;
 	}
 
-	if (!(lvobj->lv = lvm_lv_create(lvp))) {
+	if (!(lv = lvm_lv_create(lvp))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		Py_DECREF(lvobj);
 		return NULL;
 	}
 
-	lvobj->parent_vgobj = self;
-	Py_INCREF(lvobj->parent_vgobj);
-
-	return (PyObject *)lvobj;
+	return (PyObject *)_create_py_lv(self, lv);
 }
 
 static void liblvm_lv_dealloc(lvobject *self)
@@ -1157,7 +1149,6 @@ typedef pv_t (*pv_fetch_by_N)(vg_t vg, const char *id);
 static PyObject *_liblvm_lvm_lv_from_N(vgobject *self, PyObject *arg, lv_fetch_by_N method)
 {
 	const char *id;
-	lvobject *lvobj;
 	lv_t lv = NULL;
 
 	VG_VALID(self);
@@ -1170,15 +1161,7 @@ static PyObject *_liblvm_lvm_lv_from_N(vgobject *self, PyObject *arg, lv_fetch_b
 		return NULL;
 	}
 
-	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
-		return NULL;
-
-	lvobj->parent_vgobj = self;
-	Py_INCREF(lvobj->parent_vgobj);
-
-	lvobj->lv = lv;
-
-	return (PyObject *)lvobj;
+	return (PyObject *)_create_py_lv(self, lv);
 }
 
 static PyObject *_liblvm_lvm_lv_from_name(vgobject *self, PyObject *arg)
@@ -1242,12 +1225,12 @@ static void _liblvm_pv_dealloc(pvobject *self)
 /* LV Methods */
 
 #define LV_VALID(lvobject) \
-	do { \
-		VG_VALID(lvobject->parent_vgobj); \
-		if (!lvobject->lv) { \
+	do {					\
+		if (!lvobject || !lvobject->lv) { 	\
 			PyErr_SetString(PyExc_UnboundLocalError, "LV object invalid"); \
-			return NULL; \
-		} \
+			return NULL;	\
+		}\
+		VG_VALID(lvobject->parent_vgobj); \
 	} while (0)
 
 static PyObject *_liblvm_lvm_lv_get_attr(lvobject *self)
@@ -1510,7 +1493,7 @@ static PyObject *_liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 {
 	const char *snap_name;
 	unsigned long long size = 0;
-	lvobject *lvobj;
+	lv_t lv;
 	lv_create_params_t lvp = NULL;
 
 	LV_VALID(self);
@@ -1518,43 +1501,33 @@ static PyObject *_liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 	if (!PyArg_ParseTuple(args, "s|K", &snap_name, &size))
 		return NULL;
 
-	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
-		return NULL;
-
-	lvobj->parent_vgobj = NULL;
-
 	if (!(lvp = lvm_lv_params_create_snapshot(self->lv, snap_name, size))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		Py_DECREF(lvobj);
 		return NULL;
 	}
 
-	if (!(lvobj->lv = lvm_lv_create(lvp))) {
+	if (!(lv = lvm_lv_create(lvp))) {
 		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		Py_DECREF(lvobj);
 		return NULL;
 	}
 
-	lvobj->parent_vgobj = self->parent_vgobj;
-	Py_INCREF(lvobj->parent_vgobj);
-
-	return (PyObject *)lvobj;
+	return (PyObject *)_create_py_lv(self->parent_vgobj, lv);
 }
 
 /* PV Methods */
 
 #define PV_VALID(pvobject) \
 	do { \
+		if (!pvobject || !pvobject->pv) { \
+			PyErr_SetString(PyExc_UnboundLocalError, "PV object invalid"); \
+			return NULL; \
+		} \
 		if (pvobject->parent_vgobj) { \
 			VG_VALID(pvobject->parent_vgobj); \
 		} \
 		if (pvobject->parent_pvslistobj) { \
 			PVSLIST_VALID(pvobject->parent_pvslistobj); \
 		} \
-		if (!pvobject->pv) { \
-			PyErr_SetString(PyExc_UnboundLocalError, "PV object invalid"); \
-			return NULL; \
-		} \
 	} while (0)
 
 static PyObject *_liblvm_lvm_pv_get_name(pvobject *self)
@@ -1673,7 +1646,14 @@ static PyObject *_liblvm_lvm_pv_list_pvsegs(pvobject *self)
  * No way to close/destroy an lvseg, just need to make sure parents are
  * still good
  */
-#define LVSEG_VALID(lvsegobject) LV_VALID(lvsegobject->parent_lvobj)
+#define LVSEG_VALID(lvsegobject) \
+	do { \
+		if ( !lvsegobject || !lvsegobject->parent_lvobj ) { \
+			PyErr_SetString(PyExc_UnboundLocalError, "LV segment object invalid"); \
+			return NULL; \
+		} \
+		LV_VALID(lvsegobject->parent_lvobj); \
+	} while(0)
 
 static void _liblvm_lvseg_dealloc(lvsegobject *self)
 {
@@ -1702,7 +1682,14 @@ static PyObject *_liblvm_lvm_lvseg_get_property(lvsegobject *self, PyObject *arg
  * No way to close/destroy a pvseg, just need to make sure parents are
  * still good
  */
-#define PVSEG_VALID(pvsegobject) PV_VALID(pvsegobject->parent_pvobj)
+#define PVSEG_VALID(pvsegobject) \
+	do { \
+		if (!pvsegobject || !pvsegobject->parent_pvobj) { \
+			PyErr_SetString(PyExc_UnboundLocalError, "PV segment object invalid"); \
+			return NULL; \
+		} \
+		PV_VALID(pvsegobject->parent_pvobj); \
+	} while(0)
 
 static void _liblvm_pvseg_dealloc(pvsegobject *self)
 {
-- 
1.8.2.1


