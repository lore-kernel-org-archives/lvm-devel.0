From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:11 +0000 (UTC)
Subject: master - cleanup: lvm complient style
Message-ID: <20130722104212.0008361478@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4ad728610db1751af1eab2c8c7d6130a3742394
Commit:        d4ad728610db1751af1eab2c8c7d6130a3742394
Parent:        05a70f2da306164f3c604c50d69e74090b0028bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 19 15:33:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:21 2013 +0200

cleanup: lvm complient style

drop unused assignments.
---
 python/liblvm.c | 1161 ++++++++++++++++++++++++-------------------------------
 1 files changed, 511 insertions(+), 650 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 8fa26ea..d6a7b8d 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -24,7 +24,7 @@
 #include <Python.h>
 #include "lvm2app.h"
 
-static lvm_t libh;
+static lvm_t _libh;
 
 
 typedef struct {
@@ -62,92 +62,90 @@ typedef struct {
 	pvobject *parent_pvobj;
 } pvsegobject;
 
-static PyTypeObject LibLVMvgType;
-static PyTypeObject LibLVMlvType;
-static PyTypeObject LibLVMpvlistType;
-static PyTypeObject LibLVMpvType;
-static PyTypeObject LibLVMlvsegType;
-static PyTypeObject LibLVMpvsegType;
+static PyTypeObject _LibLVMvgType;
+static PyTypeObject _LibLVMlvType;
+static PyTypeObject _LibLVMpvlistType;
+static PyTypeObject _LibLVMpvType;
+static PyTypeObject _LibLVMlvsegType;
+static PyTypeObject _LibLVMpvsegType;
 
-static PyObject *LibLVMError;
+static PyObject *_LibLVMError;
 
-#define LVM_VALID()							\
-	do {								\
-		if (!libh) {						\
+#define LVM_VALID() \
+	do { \
+		if (!_libh) { \
 			PyErr_SetString(PyExc_UnboundLocalError, "LVM handle invalid"); \
-			return NULL;					\
-		}							\
+			return NULL; \
+		} \
 	} while (0)
 
 /**
  * Ensure that we initialize all the bits to a sane state.
  */
-static pvobject
-*create_py_pv(void)
+static pvobject *_create_py_pv(void)
 {
-	pvobject * pvobj = PyObject_New(pvobject, &LibLVMpvType);
+	pvobject * pvobj = PyObject_New(pvobject, &_LibLVMpvType);
+
 	if (pvobj) {
 		pvobj->pv = NULL;
 		pvobj->parent_vgobj = NULL;
 		pvobj->parent_pvslistobj = NULL;
 	}
+
 	return pvobj;
 }
 
-static vgobject
-*create_py_vg(void)
+static vgobject *_create_py_vg(void)
 {
-	vgobject *vgobj = PyObject_New(vgobject, &LibLVMvgType);
-	if (vgobj) {
+	vgobject *vgobj = PyObject_New(vgobject, &_LibLVMvgType);
+
+	if (vgobj)
 		vgobj->vg = NULL;
-	}
+
 	return vgobj;
 }
 
-static PyObject *
-liblvm_get_last_error(void)
+static PyObject *_liblvm_get_last_error(void)
 {
 	PyObject *info;
 
 	LVM_VALID();
 
-	if ((info = PyTuple_New(2)) == NULL)
+	if (!(info = PyTuple_New(2)))
 		return NULL;
 
-	PyTuple_SetItem(info, 0, PyInt_FromLong((long) lvm_errno(libh)));
-	PyTuple_SetItem(info, 1, PyString_FromString(lvm_errmsg(libh)));
+	PyTuple_SetItem(info, 0, PyInt_FromLong((long) lvm_errno(_libh)));
+	PyTuple_SetItem(info, 1, PyString_FromString(lvm_errmsg(_libh)));
 
 	return info;
 }
 
-static PyObject *
-liblvm_library_get_version(void)
+static PyObject *_liblvm_library_get_version(void)
 {
 	LVM_VALID();
 
 	return Py_BuildValue("s", lvm_library_get_version());
 }
 
-const static char gc_doc[] = "Garbage collect the C library";
+static const char _gc_doc[] = "Garbage collect the C library";
 
-static PyObject *
-liblvm_lvm_gc(void)
+static PyObject *_liblvm_lvm_gc(void)
 {
 	LVM_VALID();
 
-	lvm_quit(libh);
-	libh = lvm_init(NULL);
+	lvm_quit(_libh);
 
-	if (!libh) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
-				return NULL;
+	if (!(_libh = lvm_init(NULL))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+		return NULL;
 	}
+
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_list_vg_names(void)
+static PyObject *_liblvm_lvm_list_vg_names(void)
 {
 	struct dm_list *vgnames;
 	struct lvm_str_list *strl;
@@ -156,14 +154,12 @@ liblvm_lvm_list_vg_names(void)
 
 	LVM_VALID();
 
-	vgnames = lvm_list_vg_names(libh);
-	if (!vgnames) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(vgnames = lvm_list_vg_names(_libh))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
-	pytuple = PyTuple_New(dm_list_size(vgnames));
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(dm_list_size(vgnames))))
 		return NULL;
 
 	dm_list_iterate_items(strl, vgnames) {
@@ -174,8 +170,7 @@ liblvm_lvm_list_vg_names(void)
 	return pytuple;
 }
 
-static PyObject *
-liblvm_lvm_list_vg_uuids(void)
+static PyObject *_liblvm_lvm_list_vg_uuids(void)
 {
 	struct dm_list *uuids;
 	struct lvm_str_list *strl;
@@ -184,14 +179,12 @@ liblvm_lvm_list_vg_uuids(void)
 
 	LVM_VALID();
 
-	uuids = lvm_list_vg_uuids(libh);
-	if (!uuids) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(uuids = lvm_list_vg_uuids(_libh))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
-	pytuple = PyTuple_New(dm_list_size(uuids));
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(dm_list_size(uuids))))
 		return NULL;
 
 	dm_list_iterate_items(strl, uuids) {
@@ -202,8 +195,7 @@ liblvm_lvm_list_vg_uuids(void)
 	return pytuple;
 }
 
-static PyObject *
-liblvm_lvm_pvlist_get(pvslistobject *pvsobj)
+static PyObject *_liblvm_lvm_pvlist_get(pvslistobject *pvsobj)
 {
 	struct lvm_pv_list *pvl;
 	PyObject * pytuple;
@@ -211,19 +203,17 @@ liblvm_lvm_pvlist_get(pvslistobject *pvsobj)
 	int i = 0;
 
 	/* unlike other LVM api calls, if there are no results, we get NULL */
-	pvsobj->pvslist = lvm_list_pvs(libh);
+	pvsobj->pvslist = lvm_list_pvs(_libh);
 
 	if (!pvsobj->pvslist)
 		return Py_BuildValue("()");
 
-	pytuple = PyTuple_New(dm_list_size(pvsobj->pvslist));
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(dm_list_size(pvsobj->pvslist))))
 		return NULL;
 
 	dm_list_iterate_items(pvl, pvsobj->pvslist) {
 		/* Create and initialize the object */
-		pvobj = create_py_pv();
-		if (!pvobj) {
+		if (!(pvobj = _create_py_pv())) {
 			Py_DECREF(pytuple);
 			return NULL;
 		}
@@ -241,92 +231,88 @@ liblvm_lvm_pvlist_get(pvslistobject *pvsobj)
 	return pytuple;
 }
 
-static PyObject *
-liblvm_lvm_pvlist_put(pvslistobject *self)
+static PyObject *_liblvm_lvm_pvlist_put(pvslistobject *self)
 {
-	int rc = 0;
 	if (self->pvslist) {
-		rc = lvm_list_pvs_free(self->pvslist);
-
-		if ( 0 != rc ) {
-			PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+		if (lvm_list_pvs_free(self->pvslist)) {
+			PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 			return NULL;
 		}
 
 		self->pvslist = NULL;
 		Py_INCREF(Py_None);
+
 		return Py_None;
 	}
+
 	return NULL;
 }
 
-static PyObject *
-liblvm_pvlist_dealloc(pvslistobject *self)
+static PyObject *_liblvm_pvlist_dealloc(pvslistobject *self)
 {
-	if (self->pvslist) {
-		liblvm_lvm_pvlist_put(self);
-	}
+	if (self->pvslist)
+		_liblvm_lvm_pvlist_put(self);
 
 	PyObject_Del(self);
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_list_pvs(void)
+static PyObject *_liblvm_lvm_list_pvs(void)
 {
 	pvslistobject *pvslistobj;
 
 	LVM_VALID();
 
-	if ((pvslistobj = PyObject_New(pvslistobject, &LibLVMpvlistType)) == NULL)
-			return NULL;
+	if (!(pvslistobj = PyObject_New(pvslistobject, &_LibLVMpvlistType)))
+		return NULL;
 
 	pvslistobj->pvslist = NULL;
+
 	return (PyObject *)pvslistobj;
 }
 
-static PyObject *
-liblvm_lvm_pv_remove(PyObject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_pv_remove(PyObject *self, PyObject *arg)
 {
 	const char *pv_name;
+
 	LVM_VALID();
 
 	if (!PyArg_ParseTuple(arg, "s", &pv_name))
-			return NULL;
+		return NULL;
 
-	int rc = lvm_pv_remove(libh, pv_name);
-	if (0 != rc) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_pv_remove(_libh, pv_name) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_pv_create(PyObject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_pv_create(PyObject *self, PyObject *arg)
 {
 	const char *pv_name;
 	uint64_t size;
+
 	LVM_VALID();
 
 	if (!PyArg_ParseTuple(arg, "sl", &pv_name, &size))
-			return NULL;
+		return NULL;
 
-	int rc = lvm_pv_create(libh, pv_name, size);
-	if (0 != rc) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_pv_create(_libh, pv_name, size) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
 {
 	double converted;
 	int percent;
@@ -337,11 +323,11 @@ liblvm_lvm_percent_to_float(PyObject *self, PyObject *arg)
 		return NULL;
 
 	converted = lvm_percent_to_float(percent);
+
 	return Py_BuildValue("d", converted);
 }
 
-static PyObject *
-liblvm_lvm_vgname_from_pvid(PyObject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_vgname_from_pvid(PyObject *self, PyObject *arg)
 {
 	const char *pvid;
 	const char *vgname;
@@ -351,16 +337,15 @@ liblvm_lvm_vgname_from_pvid(PyObject *self, PyObject *arg)
 	if (!PyArg_ParseTuple(arg, "s", &pvid))
 		return NULL;
 
-	if ((vgname = lvm_vgname_from_pvid(libh, pvid)) == NULL) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(vgname = lvm_vgname_from_pvid(_libh, pvid))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	return Py_BuildValue("s", vgname);
 }
 
-static PyObject *
-liblvm_lvm_vgname_from_device(PyObject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_vgname_from_device(PyObject *self, PyObject *arg)
 {
 	const char *device;
 	const char *vgname;
@@ -370,8 +355,8 @@ liblvm_lvm_vgname_from_device(PyObject *self, PyObject *arg)
 	if (!PyArg_ParseTuple(arg, "s", &device))
 		return NULL;
 
-	if ((vgname = lvm_vgname_from_device(libh, device)) == NULL) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(vgname = lvm_vgname_from_device(_libh, device))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
@@ -379,8 +364,7 @@ liblvm_lvm_vgname_from_device(PyObject *self, PyObject *arg)
 }
 
 
-static PyObject *
-liblvm_lvm_config_find_bool(PyObject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_config_find_bool(PyObject *self, PyObject *arg)
 {
 	const char *config;
 	int rval;
@@ -391,7 +375,7 @@ liblvm_lvm_config_find_bool(PyObject *self, PyObject *arg)
 	if (!PyArg_ParseTuple(arg, "s", &config))
 		return NULL;
 
-	if ((rval = lvm_config_find_bool(libh, config, -10)) == -10) {
+	if ((rval = lvm_config_find_bool(_libh, config, -10)) == -10) {
 		/* Retrieving error information yields no error in this case */
 		PyErr_Format(PyExc_ValueError, "config path not found");
 		return NULL;
@@ -400,59 +384,55 @@ liblvm_lvm_config_find_bool(PyObject *self, PyObject *arg)
 	rc = (rval) ? Py_True: Py_False;
 
 	Py_INCREF(rc);
+
 	return rc;
 }
 
-static PyObject *
-liblvm_lvm_config_reload(void)
+static PyObject *_liblvm_lvm_config_reload(void)
 {
-	int rval;
-
 	LVM_VALID();
 
-	if ((rval = lvm_config_reload(libh)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_config_reload(_libh) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
 
-static PyObject *
-liblvm_lvm_scan(void)
+static PyObject *_liblvm_lvm_scan(void)
 {
-	int rval;
-
 	LVM_VALID();
 
-	if ((rval = lvm_scan(libh)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_scan(_libh) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_config_override(PyObject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_config_override(PyObject *self, PyObject *arg)
 {
 	const char *config;
-	int rval;
 
 	LVM_VALID();
 
 	if (!PyArg_ParseTuple(arg, "s", &config))
 		return NULL;
 
-	if ((rval = lvm_config_override(libh, config)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_config_override(_libh, config) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 /* ----------------------------------------------------------------------
@@ -460,8 +440,7 @@ liblvm_lvm_config_override(PyObject *self, PyObject *arg)
  */
 
 
-static PyObject *
-liblvm_lvm_vg_open(PyObject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_open(PyObject *self, PyObject *args)
 {
 	const char *vgname;
 	const char *mode = NULL;
@@ -470,18 +449,17 @@ liblvm_lvm_vg_open(PyObject *self, PyObject *args)
 
 	LVM_VALID();
 
-	if (!PyArg_ParseTuple(args, "s|s", &vgname, &mode)) {
+	if (!PyArg_ParseTuple(args, "s|s", &vgname, &mode))
 		return NULL;
-	}
 
 	if (mode == NULL)
 		mode = "r";
 
-	if ((vgobj = create_py_vg()) == NULL)
+	if (!(vgobj = _create_py_vg()))
 		return NULL;
 
-	if ((vgobj->vg = lvm_vg_open(libh, vgname, mode, 0))== NULL) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(vgobj->vg = lvm_vg_open(_libh, vgname, mode, 0))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		Py_DECREF(vgobj);
 		return NULL;
 	}
@@ -489,23 +467,21 @@ liblvm_lvm_vg_open(PyObject *self, PyObject *args)
 	return (PyObject *)vgobj;
 }
 
-static PyObject *
-liblvm_lvm_vg_create(PyObject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_create(PyObject *self, PyObject *args)
 {
 	const char *vgname;
 	vgobject *vgobj;
 
 	LVM_VALID();
 
-	if (!PyArg_ParseTuple(args, "s", &vgname)) {
+	if (!PyArg_ParseTuple(args, "s", &vgname))
 		return NULL;
-	}
 
-	if ((vgobj = create_py_vg()) == NULL)
+	if (!(vgobj = _create_py_vg()))
 		return NULL;
 
-	if ((vgobj->vg = lvm_vg_create(libh, vgname))== NULL) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(vgobj->vg = lvm_vg_create(_libh, vgname))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		Py_DECREF(vgobj);
 		return NULL;
 	}
@@ -513,52 +489,51 @@ liblvm_lvm_vg_create(PyObject *self, PyObject *args)
 	return (PyObject *)vgobj;
 }
 
-static void
-liblvm_vg_dealloc(vgobject *self)
+static void liblvm_vg_dealloc(vgobject *self)
 {
 	/* if already closed, don't reclose it */
 	if (self->vg != NULL) {
 		lvm_vg_close(self->vg);
 		self->vg = NULL;
 	}
+
 	PyObject_Del(self);
 }
 
 /* VG Methods */
 
-#define VG_VALID(vgobject)						\
-	do {								\
-		LVM_VALID();						\
-		if (!vgobject->vg) {					\
+#define VG_VALID(vgobject) \
+	do { \
+		LVM_VALID(); \
+		if (!vgobject->vg) { \
 			PyErr_SetString(PyExc_UnboundLocalError, "VG object invalid"); \
-			return NULL;					\
-		}							\
+			return NULL; \
+		} \
 	} while (0)
 
-#define PVSLIST_VALID(pvslistobject)			\
-	do {										\
-		LVM_VALID();							\
-		if (!pvslistobject->pvslist) {			\
+#define PVSLIST_VALID(pvslistobject) \
+	do { \
+		LVM_VALID(); \
+		if (!pvslistobject->pvslist) { \
 			PyErr_SetString(PyExc_UnboundLocalError, "PVS object invalid"); \
-			return NULL;						\
-		}										\
+			return NULL; \
+		} \
 	} while (0)
 
-static PyObject *
-liblvm_lvm_vg_close(vgobject *self)
+static PyObject *_liblvm_lvm_vg_close(vgobject *self)
 {
 	/* if already closed, don't reclose it */
-	if (self->vg != NULL)
+	if (self->vg) {
 		lvm_vg_close(self->vg);
-
-	self->vg = NULL;
+		self->vg = NULL;
+	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_vg_get_name(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_name(vgobject *self)
 {
 	VG_VALID(self);
 
@@ -566,22 +541,18 @@ liblvm_lvm_vg_get_name(vgobject *self)
 }
 
 
-static PyObject *
-liblvm_lvm_vg_get_uuid(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_uuid(vgobject *self)
 {
 	VG_VALID(self);
 
 	return Py_BuildValue("s", lvm_vg_get_uuid(self->vg));
 }
 
-static PyObject *
-liblvm_lvm_vg_remove(vgobject *self)
+static PyObject *_liblvm_lvm_vg_remove(vgobject *self)
 {
-	int rval;
-
 	VG_VALID(self);
 
-	if ((rval = lvm_vg_remove(self->vg)) == -1)
+	if (lvm_vg_remove(self->vg) == -1)
 		goto error;
 
 	if (lvm_vg_write(self->vg) == -1)
@@ -594,18 +565,18 @@ liblvm_lvm_vg_remove(vgobject *self)
 	self->vg = NULL;
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 
 error:
-	PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+
 	return NULL;
 }
 
-static PyObject *
-liblvm_lvm_vg_extend(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_extend(vgobject *self, PyObject *args)
 {
 	const char *device;
-	int rval;
 
 	VG_VALID(self);
 
@@ -613,7 +584,7 @@ liblvm_lvm_vg_extend(vgobject *self, PyObject *args)
 		return NULL;
 	}
 
-	if ((rval = lvm_vg_extend(self->vg, device)) == -1)
+	if (lvm_vg_extend(self->vg, device) == -1)
 		goto error;
 
 	if (lvm_vg_write(self->vg) == -1)
@@ -623,38 +594,37 @@ liblvm_lvm_vg_extend(vgobject *self, PyObject *args)
 	return Py_None;
 
 error:
-	PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+
 	return NULL;
 }
 
-static PyObject *
-liblvm_lvm_vg_reduce(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_reduce(vgobject *self, PyObject *args)
 {
 	const char *device;
-	int rval;
 
 	VG_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "s", &device)) {
+	if (!PyArg_ParseTuple(args, "s", &device))
 		return NULL;
-	}
 
-	if ((rval = lvm_vg_reduce(self->vg, device)) == -1)
+	if (lvm_vg_reduce(self->vg, device) == -1)
 		goto error;
 
 	if (lvm_vg_write(self->vg) == -1)
 		goto error;
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 
 error:
-	PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+
 	return NULL;
 }
 
-static PyObject *
-liblvm_lvm_vg_add_tag(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_add_tag(vgobject *self, PyObject *args)
 {
 	const char *tag;
 	int rval;
@@ -673,39 +643,37 @@ liblvm_lvm_vg_add_tag(vgobject *self, PyObject *args)
 	return Py_BuildValue("i", rval);
 
 error:
-	PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+
 	return NULL;
 }
 
-static PyObject *
-liblvm_lvm_vg_remove_tag(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_remove_tag(vgobject *self, PyObject *args)
 {
 	const char *tag;
-	int rval;
 
 	VG_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "s", &tag)) {
+	if (!PyArg_ParseTuple(args, "s", &tag))
 		return NULL;
-	}
 
-	if ((rval = lvm_vg_remove_tag(self->vg, tag)) == -1)
+	if (lvm_vg_remove_tag(self->vg, tag) == -1)
 		goto error;
 
 	if (lvm_vg_write(self->vg) == -1)
 		goto error;
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 
 error:
-	PyErr_SetObject(LibLVMError, liblvm_get_last_error());
-	return NULL;
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 
+	return NULL;
 }
 
-static PyObject *
-liblvm_lvm_vg_is_clustered(vgobject *self)
+static PyObject *_liblvm_lvm_vg_is_clustered(vgobject *self)
 {
 	PyObject *rval;
 
@@ -714,11 +682,11 @@ liblvm_lvm_vg_is_clustered(vgobject *self)
 	rval = ( lvm_vg_is_clustered(self->vg) == 1) ? Py_True : Py_False;
 
 	Py_INCREF(rval);
+
 	return rval;
 }
 
-static PyObject *
-liblvm_lvm_vg_is_exported(vgobject *self)
+static PyObject *_liblvm_lvm_vg_is_exported(vgobject *self)
 {
 	PyObject *rval;
 
@@ -727,11 +695,11 @@ liblvm_lvm_vg_is_exported(vgobject *self)
 	rval = ( lvm_vg_is_exported(self->vg) == 1) ? Py_True : Py_False;
 
 	Py_INCREF(rval);
+
 	return rval;
 }
 
-static PyObject *
-liblvm_lvm_vg_is_partial(vgobject *self)
+static PyObject *_liblvm_lvm_vg_is_partial(vgobject *self)
 {
 	PyObject *rval;
 
@@ -740,51 +708,46 @@ liblvm_lvm_vg_is_partial(vgobject *self)
 	rval = ( lvm_vg_is_partial(self->vg) == 1) ? Py_True : Py_False;
 
 	Py_INCREF(rval);
+
 	return rval;
 }
 
-static PyObject *
-liblvm_lvm_vg_get_seqno(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_seqno(vgobject *self)
 {
 	VG_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_seqno(self->vg));
 }
 
-static PyObject *
-liblvm_lvm_vg_get_size(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_size(vgobject *self)
 {
 	VG_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_size(self->vg));
 }
 
-static PyObject *
-liblvm_lvm_vg_get_free_size(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_free_size(vgobject *self)
 {
 	VG_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_free_size(self->vg));
 }
 
-static PyObject *
-liblvm_lvm_vg_get_extent_size(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_extent_size(vgobject *self)
 {
 	VG_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_extent_size(self->vg));
 }
 
-static PyObject *
-liblvm_lvm_vg_get_extent_count(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_extent_count(vgobject *self)
 {
 	VG_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_extent_count(self->vg));
 }
 
-static PyObject *
-liblvm_lvm_vg_get_free_extent_count(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_free_extent_count(vgobject *self)
 {
 	VG_VALID(self);
 
@@ -792,42 +755,38 @@ liblvm_lvm_vg_get_free_extent_count(vgobject *self)
 }
 
 /* Builds a python tuple ([string|number], bool) from a struct lvm_property_value */
-static PyObject *
-get_property(struct lvm_property_value *prop)
+static PyObject *get_property(struct lvm_property_value *prop)
 {
 	PyObject *pytuple;
 	PyObject *setable;
 
 	if (!prop->is_valid) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
-	pytuple = PyTuple_New(2);
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(2)))
 		return NULL;
 
-	if (prop->is_integer) {
+	if (prop->is_integer)
 		PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop->value.integer));
-	} else {
+	else
 		PyTuple_SET_ITEM(pytuple, 0, PyString_FromString(prop->value.string));
-	}
 
-	if (prop->is_settable) {
+	if (prop->is_settable)
 		setable = Py_True;
-	} else {
+	else
 		setable = Py_False;
-	}
 
 	Py_INCREF(setable);
 	PyTuple_SET_ITEM(pytuple, 1, setable);
+
 	return pytuple;
 }
 
 /* This will return a tuple of (value, bool) with the value being a string or
    integer and bool indicating if property is settable */
-static PyObject *
-liblvm_lvm_vg_get_property(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_get_property(vgobject *self, PyObject *args)
 {
 	const char *name;
 	struct lvm_property_value prop_value;
@@ -838,16 +797,18 @@ liblvm_lvm_vg_get_property(vgobject *self, PyObject *args)
 		return NULL;
 
 	prop_value = lvm_vg_get_property(self->vg, name);
+
 	return get_property(&prop_value);
 }
 
-static PyObject *
-liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 {
 	const char *property_name = NULL;
 	PyObject *variant_type_arg = NULL;
 	struct lvm_property_value lvm_property;
 	char *string_value = NULL;
+	int temp_py_int;
+	unsigned long long temp_py_long;
 
 	VG_VALID(self);
 
@@ -855,10 +816,8 @@ liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 		return NULL;
 
 	lvm_property = lvm_vg_get_property(self->vg, property_name);
-
-	if (!lvm_property.is_valid ) {
+	if (!lvm_property.is_valid)
 		goto lvmerror;
-	}
 
 	if (PyObject_IsInstance(variant_type_arg, (PyObject*)&PyString_Type)) {
 
@@ -867,14 +826,12 @@ liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 			goto bail;
 		}
 
-		string_value = PyString_AsString(variant_type_arg);
-
-		lvm_property.value.string = string_value;
-		if (!lvm_property.value.string) {
+		if (!(string_value = PyString_AsString(variant_type_arg))) {
 			PyErr_NoMemory();
 			goto bail;
 		}
 
+		lvm_property.value.string = string_value;
 	} else {
 
 		if (!lvm_property.is_integer) {
@@ -883,12 +840,11 @@ liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 		}
 
 		if (PyObject_IsInstance(variant_type_arg, (PyObject*)&PyInt_Type)) {
-			int temp_py_int = PyInt_AsLong(variant_type_arg);
+			temp_py_int = PyInt_AsLong(variant_type_arg);
 
 			/* -1 could be valid, need to see if an exception was gen. */
-			if (temp_py_int == -1 && PyErr_Occurred()) {
+			if (temp_py_int == -1 && PyErr_Occurred())
 				goto bail;
-			}
 
 			if (temp_py_int < 0) {
 				PyErr_Format(PyExc_ValueError, "Positive integers only!");
@@ -900,10 +856,8 @@ liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 			/* If PyLong_AsUnsignedLongLong function fails an OverflowError is
 			 * raised and (unsigned long long)-1 is returned
 			 */
-			unsigned long long temp_py_long = PyLong_AsUnsignedLongLong(variant_type_arg);
-			if (temp_py_long == (unsigned long long)-1) {
+			if ((temp_py_long = PyLong_AsUnsignedLongLong(variant_type_arg)) == ~0ULL)
 				goto bail;
-			}
 
 			lvm_property.value.integer = temp_py_long;
 		} else {
@@ -912,70 +866,63 @@ liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 		}
 	}
 
-	if (lvm_vg_set_property(self->vg, property_name, &lvm_property) == -1) {
+	if (lvm_vg_set_property(self->vg, property_name, &lvm_property) == -1)
 		goto lvmerror;
-	}
 
-	if (lvm_vg_write(self->vg) == -1) {
+	if (lvm_vg_write(self->vg) == -1)
 		goto lvmerror;
-	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 
 lvmerror:
-	PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 bail:
 	return NULL;
 }
 
-static PyObject *
-liblvm_lvm_vg_get_pv_count(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_pv_count(vgobject *self)
 {
 	VG_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_pv_count(self->vg));
 }
 
-static PyObject *
-liblvm_lvm_vg_get_max_pv(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_max_pv(vgobject *self)
 {
 	VG_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_max_pv(self->vg));
 }
 
-static PyObject *
-liblvm_lvm_vg_get_max_lv(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_max_lv(vgobject *self)
 {
 	VG_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_vg_get_max_lv(self->vg));
 }
 
-static PyObject *
-liblvm_lvm_vg_set_extent_size(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_set_extent_size(vgobject *self, PyObject *args)
 {
 	uint32_t new_size;
-	int rval;
 
 	VG_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "l", &new_size)) {
+	if (!PyArg_ParseTuple(args, "l", &new_size))
 		return NULL;
-	}
 
-	if ((rval = lvm_vg_set_extent_size(self->vg, new_size)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_vg_set_extent_size(self->vg, new_size) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_vg_list_lvs(vgobject *self)
+static PyObject *_liblvm_lvm_vg_list_lvs(vgobject *self)
 {
 	struct dm_list *lvs;
 	struct lvm_lv_list *lvl;
@@ -986,18 +933,15 @@ liblvm_lvm_vg_list_lvs(vgobject *self)
 	VG_VALID(self);
 
 	/* unlike other LVM api calls, if there are no results, we get NULL */
-	lvs = lvm_vg_list_lvs(self->vg);
-	if (!lvs)
+	if (!(lvs = lvm_vg_list_lvs(self->vg)))
 		return Py_BuildValue("()");
 
-	pytuple = PyTuple_New(dm_list_size(lvs));
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(dm_list_size(lvs))))
 		return NULL;
 
 	dm_list_iterate_items(lvl, lvs) {
 		/* Create and initialize the object */
-		lvobj = PyObject_New(lvobject, &LibLVMlvType);
-		if (!lvobj) {
+		if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType))) {
 			Py_DECREF(pytuple);
 			return NULL;
 		}
@@ -1013,8 +957,7 @@ liblvm_lvm_vg_list_lvs(vgobject *self)
 	return pytuple;
 }
 
-static PyObject *
-liblvm_lvm_vg_get_tags(vgobject *self)
+static PyObject *_liblvm_lvm_vg_get_tags(vgobject *self)
 {
 	struct dm_list *tags;
 	struct lvm_str_list *strl;
@@ -1023,14 +966,12 @@ liblvm_lvm_vg_get_tags(vgobject *self)
 
 	VG_VALID(self);
 
-	tags = lvm_vg_get_tags(self->vg);
-	if (!tags) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(tags = lvm_vg_get_tags(self->vg))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
-	pytuple = PyTuple_New(dm_list_size(tags));
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(dm_list_size(tags))))
 		return NULL;
 
 	dm_list_iterate_items(strl, tags) {
@@ -1041,8 +982,7 @@ liblvm_lvm_vg_get_tags(vgobject *self)
 	return pytuple;
 }
 
-static PyObject *
-liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
 {
 	const char *vgname;
 	uint64_t size;
@@ -1050,18 +990,17 @@ liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
 
 	VG_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "sl", &vgname, &size)) {
+	if (!PyArg_ParseTuple(args, "sl", &vgname, &size))
 		return NULL;
-	}
 
-	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
+	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
 		return NULL;
 
 	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
 	lvobj->parent_vgobj = NULL;
 
-	if ((lvobj->lv = lvm_vg_create_lv_linear(self->vg, vgname, size)) == NULL) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(lvobj->lv = lvm_vg_create_lv_linear(self->vg, vgname, size))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		Py_DECREF(lvobj);
 		return NULL;
 	}
@@ -1072,8 +1011,7 @@ liblvm_lvm_vg_create_lv_linear(vgobject *self, PyObject *args)
 	return (PyObject *)lvobj;
 }
 
-static PyObject *
-liblvm_lvm_vg_create_lv_thinpool(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_create_lv_thinpool(vgobject *self, PyObject *args)
 {
 	const char *pool_name;
 	uint64_t size = 0;
@@ -1088,44 +1026,42 @@ liblvm_lvm_vg_create_lv_thinpool(vgobject *self, PyObject *args)
 	VG_VALID(self);
 
 	if (!PyArg_ParseTuple(args, "sK|kKii", &pool_name, &size, &chunk_size,
-			&meta_size, &discard, &skip_zero)) {
+			      &meta_size, &discard, &skip_zero))
 		return NULL;
-	}
 
-	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
+	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
 		return NULL;
 
 	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
 	lvobj->parent_vgobj = NULL;
 
-	lvp = lvm_lv_params_create_thin_pool(self->vg, pool_name, size, chunk_size,
-				meta_size, discard);
+	if (!(lvp = lvm_lv_params_create_thin_pool(self->vg, pool_name, size, chunk_size,
+						   meta_size, discard))) {
 
-	if (lvp) {
-		if (skip_zero) {
-			prop_value = lvm_lv_params_get_property(lvp, "skip_zero");
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+		Py_DECREF(lvobj);
+		return NULL;
+	}
 
-			if (prop_value.is_valid) {
-				prop_value.value.integer = 1;
+	if (skip_zero) {
+		prop_value = lvm_lv_params_get_property(lvp, "skip_zero");
 
-				if( -1 == lvm_lv_params_set_property(lvp, "skip_zero",
-						&prop_value)) {
-					PyErr_SetObject(LibLVMError, liblvm_get_last_error());
-					Py_DECREF(lvobj);
-					return NULL;
-				}
-			}
-		}
+		if (prop_value.is_valid) {
+			prop_value.value.integer = 1;
 
-		if ((lvobj->lv = lvm_lv_create(lvp)) == NULL) {
-			PyErr_SetObject(LibLVMError, liblvm_get_last_error());
-			Py_DECREF(lvobj);
-			return NULL;
-		}
-	} else {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+			if (lvm_lv_params_set_property(lvp, "skip_zero",
+						       &prop_value) == -1) {
+				PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 				Py_DECREF(lvobj);
 				return NULL;
+			}
+		}
+	}
+
+	if (!(lvobj->lv = lvm_lv_create(lvp))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+		Py_DECREF(lvobj);
+		return NULL;
 	}
 
 	lvobj->parent_vgobj = self;
@@ -1134,8 +1070,7 @@ liblvm_lvm_vg_create_lv_thinpool(vgobject *self, PyObject *args)
 	return (PyObject *)lvobj;
 }
 
-static PyObject *
-liblvm_lvm_vg_create_lv_thin(vgobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_vg_create_lv_thin(vgobject *self, PyObject *args)
 {
 	const char *pool_name;
 	const char *lv_name;
@@ -1145,28 +1080,25 @@ liblvm_lvm_vg_create_lv_thin(vgobject *self, PyObject *args)
 
 	VG_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "ssK", &pool_name, &lv_name, &size)) {
+	if (!PyArg_ParseTuple(args, "ssK", &pool_name, &lv_name, &size))
 		return NULL;
-	}
 
-	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
+	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
 		return NULL;
 
 	/* Initialize the parent ptr in case lv create fails and we dealloc lvobj */
 	lvobj->parent_vgobj = NULL;
 
-	lvp = lvm_lv_params_create_thin(self->vg, pool_name, lv_name,size);
+	if (!(lvp = lvm_lv_params_create_thin(self->vg, pool_name, lv_name,size))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+		Py_DECREF(lvobj);
+		return NULL;
+	}
 
-	if (lvp) {
-		if ((lvobj->lv = lvm_lv_create(lvp)) == NULL) {
-			PyErr_SetObject(LibLVMError, liblvm_get_last_error());
-			Py_DECREF(lvobj);
-			return NULL;
-		}
-	} else {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
-				Py_DECREF(lvobj);
-				return NULL;
+	if (!(lvobj->lv = lvm_lv_create(lvp))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+		Py_DECREF(lvobj);
+		return NULL;
 	}
 
 	lvobj->parent_vgobj = self;
@@ -1175,18 +1107,16 @@ liblvm_lvm_vg_create_lv_thin(vgobject *self, PyObject *args)
 	return (PyObject *)lvobj;
 }
 
-static void
-liblvm_lv_dealloc(lvobject *self)
+static void liblvm_lv_dealloc(lvobject *self)
 {
 	/* We can dealloc an object that didn't get fully created */
-	if (self->parent_vgobj)	{
+	if (self->parent_vgobj)
 		Py_DECREF(self->parent_vgobj);
-	}
+
 	PyObject_Del(self);
 }
 
-static PyObject *
-liblvm_lvm_vg_list_pvs(vgobject *self)
+static PyObject *_liblvm_lvm_vg_list_pvs(vgobject *self)
 {
 	struct dm_list *pvs;
 	struct lvm_pv_list *pvl;
@@ -1197,18 +1127,15 @@ liblvm_lvm_vg_list_pvs(vgobject *self)
 	VG_VALID(self);
 
 	/* unlike other LVM api calls, if there are no results, we get NULL */
-	pvs = lvm_vg_list_pvs(self->vg);
-	if (!pvs)
+	if (!(pvs = lvm_vg_list_pvs(self->vg)))
 		return Py_BuildValue("()");
 
-	pytuple = PyTuple_New(dm_list_size(pvs));
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(dm_list_size(pvs))))
 		return NULL;
 
 	dm_list_iterate_items(pvl, pvs) {
 		/* Create and initialize the object */
-		pvobj = create_py_pv();
-		if (!pvobj) {
+		if (!(pvobj = _create_py_pv())) {
 			Py_DECREF(pytuple);
 			return NULL;
 		}
@@ -1227,8 +1154,7 @@ liblvm_lvm_vg_list_pvs(vgobject *self)
 typedef lv_t (*lv_fetch_by_N)(vg_t vg, const char *id);
 typedef pv_t (*pv_fetch_by_N)(vg_t vg, const char *id);
 
-static PyObject *
-liblvm_lvm_lv_from_N(vgobject *self, PyObject *arg, lv_fetch_by_N method)
+static PyObject *_liblvm_lvm_lv_from_N(vgobject *self, PyObject *arg, lv_fetch_by_N method)
 {
 	const char *id;
 	lvobject *lvobj;
@@ -1239,38 +1165,33 @@ liblvm_lvm_lv_from_N(vgobject *self, PyObject *arg, lv_fetch_by_N method)
 	if (!PyArg_ParseTuple(arg, "s", &id))
 		return NULL;
 
-	lv = method(self->vg, id);
-	if (!lv) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(lv = method(self->vg, id))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
-	lvobj = PyObject_New(lvobject, &LibLVMlvType);
-	if (!lvobj) {
+	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
 		return NULL;
-	}
 
 	lvobj->parent_vgobj = self;
 	Py_INCREF(lvobj->parent_vgobj);
 
 	lvobj->lv = lv;
+
 	return (PyObject *)lvobj;
 }
 
-static PyObject *
-liblvm_lvm_lv_from_name(vgobject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_lv_from_name(vgobject *self, PyObject *arg)
 {
-	return liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_name);
+	return _liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_name);
 }
 
-static PyObject *
-liblvm_lvm_lv_from_uuid(vgobject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_lv_from_uuid(vgobject *self, PyObject *arg)
 {
-	return liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_uuid);
+	return _liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_uuid);
 }
 
-static PyObject *
-liblvm_lvm_pv_from_N(vgobject *self, PyObject *arg, pv_fetch_by_N method)
+static PyObject *_liblvm_lvm_pv_from_N(vgobject *self, PyObject *arg, pv_fetch_by_N method)
 {
 	const char *id;
 	pvobject *rc;
@@ -1281,44 +1202,37 @@ liblvm_lvm_pv_from_N(vgobject *self, PyObject *arg, pv_fetch_by_N method)
 	if (!PyArg_ParseTuple(arg, "s", &id))
 		return NULL;
 
-	pv = method(self->vg, id);
-	if (!pv) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(pv = method(self->vg, id))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
-	rc = create_py_pv();
-	if (!rc) {
+	if (!(rc = _create_py_pv()))
 		return NULL;
-	}
 
 	Py_INCREF(self);
 	rc->pv = pv;
+
 	return (PyObject *)rc;
 }
 
-static PyObject *
-liblvm_lvm_pv_from_name(vgobject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_pv_from_name(vgobject *self, PyObject *arg)
 {
-	return liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_name);
+	return _liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_name);
 }
 
-static PyObject *
-liblvm_lvm_pv_from_uuid(vgobject *self, PyObject *arg)
+static PyObject *_liblvm_lvm_pv_from_uuid(vgobject *self, PyObject *arg)
 {
-	return liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_uuid);
+	return _liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_uuid);
 }
 
-static void
-liblvm_pv_dealloc(pvobject *self)
+static void _liblvm_pv_dealloc(pvobject *self)
 {
-	if (self->parent_vgobj) {
+	if (self->parent_vgobj)
 		Py_DECREF(self->parent_vgobj);
-	}
 
-	if (self->parent_pvslistobj) {
+	if (self->parent_pvslistobj)
 		Py_DECREF(self->parent_pvslistobj);
-	}
 
 	self->parent_vgobj = NULL;
 	self->parent_pvslistobj = NULL;
@@ -1327,101 +1241,90 @@ liblvm_pv_dealloc(pvobject *self)
 
 /* LV Methods */
 
-#define LV_VALID(lvobject)						\
-	do {								\
-		VG_VALID(lvobject->parent_vgobj);			\
-		if (!lvobject->lv) {					\
+#define LV_VALID(lvobject) \
+	do { \
+		VG_VALID(lvobject->parent_vgobj); \
+		if (!lvobject->lv) { \
 			PyErr_SetString(PyExc_UnboundLocalError, "LV object invalid"); \
-			return NULL;					\
-		}							\
+			return NULL; \
+		} \
 	} while (0)
 
-static PyObject *
-liblvm_lvm_lv_get_attr(lvobject *self)
+static PyObject *_liblvm_lvm_lv_get_attr(lvobject *self)
 {
 	LV_VALID(self);
 
 	return Py_BuildValue("s", lvm_lv_get_attr(self->lv));
 }
 
-static PyObject *
-liblvm_lvm_lv_get_origin(lvobject *self)
+static PyObject *_liblvm_lvm_lv_get_origin(lvobject *self)
 {
 	LV_VALID(self);
 
 	return Py_BuildValue("s", lvm_lv_get_origin(self->lv));
 }
 
-static PyObject *
-liblvm_lvm_lv_get_name(lvobject *self)
+static PyObject *_liblvm_lvm_lv_get_name(lvobject *self)
 {
 	LV_VALID(self);
 
 	return Py_BuildValue("s", lvm_lv_get_name(self->lv));
 }
 
-static PyObject *
-liblvm_lvm_lv_get_uuid(lvobject *self)
+static PyObject *_liblvm_lvm_lv_get_uuid(lvobject *self)
 {
 	LV_VALID(self);
 
 	return Py_BuildValue("s", lvm_lv_get_uuid(self->lv));
 }
 
-static PyObject *
-liblvm_lvm_lv_activate(lvobject *self)
+static PyObject *_liblvm_lvm_lv_activate(lvobject *self)
 {
-	int rval;
-
 	LV_VALID(self);
 
-	if ((rval = lvm_lv_activate(self->lv)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_lv_activate(self->lv) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_lv_deactivate(lvobject *self)
+static PyObject *_liblvm_lvm_lv_deactivate(lvobject *self)
 {
-	int rval;
-
 	LV_VALID(self);
 
-	if ((rval = lvm_lv_deactivate(self->lv)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_lv_deactivate(self->lv) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_vg_remove_lv(lvobject *self)
+static PyObject *_liblvm_lvm_vg_remove_lv(lvobject *self)
 {
-	int rval;
-
 	LV_VALID(self);
 
-	if ((rval = lvm_vg_remove_lv(self->lv)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_vg_remove_lv(self->lv) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	self->lv = NULL;
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
 /* This will return a tuple of (value, bool) with the value being a string or
    integer and bool indicating if property is settable */
-static PyObject *
-liblvm_lvm_lv_get_property(lvobject *self, PyObject *args)
+static PyObject * _liblvm_lvm_lv_get_property(lvobject *self, PyObject *args)
 {
 	const char *name;
 	struct lvm_property_value prop_value;
@@ -1432,57 +1335,54 @@ liblvm_lvm_lv_get_property(lvobject *self, PyObject *args)
 		return NULL;
 
 	prop_value = lvm_lv_get_property(self->lv, name);
+
 	return get_property(&prop_value);
 }
 
-static PyObject *
-liblvm_lvm_lv_get_size(lvobject *self)
+static PyObject *_liblvm_lvm_lv_get_size(lvobject *self)
 {
 	LV_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_lv_get_size(self->lv));
 }
 
-static PyObject *
-liblvm_lvm_lv_is_active(lvobject *self)
+static PyObject *_liblvm_lvm_lv_is_active(lvobject *self)
 {
 	PyObject *rval;
 
 	LV_VALID(self);
 
-	rval = ( lvm_lv_is_active(self->lv) == 1) ? Py_True : Py_False;
+	rval = (lvm_lv_is_active(self->lv) == 1) ? Py_True : Py_False;
 
 	Py_INCREF(rval);
+
 	return rval;
 }
 
-static PyObject *
-liblvm_lvm_lv_is_suspended(lvobject *self)
+static PyObject *_liblvm_lvm_lv_is_suspended(lvobject *self)
 {
 	PyObject *rval;
 
 	LV_VALID(self);
 
-	rval = ( lvm_lv_is_suspended(self->lv) == 1) ? Py_True : Py_False;
+	rval = (lvm_lv_is_suspended(self->lv) == 1) ? Py_True : Py_False;
 
 	Py_INCREF(rval);
+
 	return rval;
 }
 
-static PyObject *
-liblvm_lvm_lv_add_tag(lvobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_lv_add_tag(lvobject *self, PyObject *args)
 {
 	const char *tag;
-	int rval;
 
 	LV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "s", &tag)) {
+	if (!PyArg_ParseTuple(args, "s", &tag))
 		return NULL;
-	}
 
-	if ((rval = lvm_lv_add_tag(self->lv, tag)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_lv_add_tag(self->lv, tag) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
@@ -1490,29 +1390,26 @@ liblvm_lvm_lv_add_tag(lvobject *self, PyObject *args)
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_lv_remove_tag(lvobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_lv_remove_tag(lvobject *self, PyObject *args)
 {
 	const char *tag;
-	int rval;
 
 	LV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "s", &tag)) {
+	if (!PyArg_ParseTuple(args, "s", &tag))
 		return NULL;
-	}
 
-	if ((rval = lvm_lv_remove_tag(self->lv, tag)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_lv_remove_tag(self->lv, tag) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_lv_get_tags(lvobject *self)
+static PyObject *_liblvm_lvm_lv_get_tags(lvobject *self)
 {
 	struct dm_list *tags;
 	struct lvm_str_list *strl;
@@ -1521,14 +1418,12 @@ liblvm_lvm_lv_get_tags(lvobject *self)
 
 	LV_VALID(self);
 
-	tags = lvm_lv_get_tags(self->lv);
-	if (!tags) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (!(tags = lvm_lv_get_tags(self->lv))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
-	pytuple = PyTuple_New(dm_list_size(tags));
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(dm_list_size(tags))))
 		return NULL;
 
 	dm_list_iterate_items(strl, tags) {
@@ -1539,49 +1434,45 @@ liblvm_lvm_lv_get_tags(lvobject *self)
 	return pytuple;
 }
 
-static PyObject *
-liblvm_lvm_lv_rename(lvobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_lv_rename(lvobject *self, PyObject *args)
 {
 	const char *new_name;
-	int rval;
 
 	LV_VALID(self);
 
 	if (!PyArg_ParseTuple(args, "s", &new_name))
 		return NULL;
 
-	if ((rval = lvm_lv_rename(self->lv, new_name)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_lv_rename(self->lv, new_name) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
 {
 	uint64_t new_size;
-	int rval;
 
 	LV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "l", &new_size)) {
+	if (!PyArg_ParseTuple(args, "l", &new_size))
 		return NULL;
-	}
 
-	if ((rval = lvm_lv_resize(self->lv, new_size)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_lv_resize(self->lv, new_size) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_lv_list_lvsegs(lvobject *self)
+static PyObject *_liblvm_lvm_lv_list_lvsegs(lvobject *self)
 {
 	struct dm_list *lvsegs;
 	lvseg_list_t *lvsegl;
@@ -1591,19 +1482,15 @@ liblvm_lvm_lv_list_lvsegs(lvobject *self)
 
 	LV_VALID(self);
 
-	lvsegs = lvm_lv_list_lvsegs(self->lv);
-	if (!lvsegs) {
+	if (!(lvsegs = lvm_lv_list_lvsegs(self->lv)))
 		return Py_BuildValue("()");
-	}
 
-	pytuple = PyTuple_New(dm_list_size(lvsegs));
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(dm_list_size(lvsegs))))
 		return NULL;
 
 	dm_list_iterate_items(lvsegl, lvsegs) {
 		/* Create and initialize the object */
-		lvsegobj = PyObject_New(lvsegobject, &LibLVMlvsegType);
-		if (!lvsegobj) {
+		if (!(lvsegobj = PyObject_New(lvsegobject, &_LibLVMlvsegType))) {
 			Py_DECREF(pytuple);
 			return NULL;
 		}
@@ -1619,8 +1506,7 @@ liblvm_lvm_lv_list_lvsegs(lvobject *self)
 	return pytuple;
 }
 
-static PyObject *
-liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 {
 	const char *snap_name;
 	uint64_t size = 0;
@@ -1629,75 +1515,70 @@ liblvm_lvm_lv_snapshot(lvobject *self, PyObject *args)
 
 	LV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "s|K", &snap_name, &size)) {
+	if (!PyArg_ParseTuple(args, "s|K", &snap_name, &size))
 		return NULL;
-	}
 
-	if ((lvobj = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
+	if (!(lvobj = PyObject_New(lvobject, &_LibLVMlvType)))
 		return NULL;
 
 	lvobj->parent_vgobj = NULL;
 
-	lvp = lvm_lv_params_create_snapshot(self->lv, snap_name, size);
-	if (lvp) {
-		if ((lvobj->lv = lvm_lv_create(lvp)) == NULL) {
-			PyErr_SetObject(LibLVMError, liblvm_get_last_error());
-			Py_DECREF(lvobj);
-			return NULL;
-		}
-	} else {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
-						Py_DECREF(lvobj);
-						return NULL;
+	if (!(lvp = lvm_lv_params_create_snapshot(self->lv, snap_name, size))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+		Py_DECREF(lvobj);
+		return NULL;
+	}
+
+	if (!(lvobj->lv = lvm_lv_create(lvp))) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+		Py_DECREF(lvobj);
+		return NULL;
 	}
 
 	lvobj->parent_vgobj = self->parent_vgobj;
 	Py_INCREF(lvobj->parent_vgobj);
+
 	return (PyObject *)lvobj;
 }
 
 /* PV Methods */
 
-#define PV_VALID(pvobject)								\
-	do {												\
-		if (pvobject->parent_vgobj) {					\
-			VG_VALID(pvobject->parent_vgobj);			\
-		}												\
-		if (pvobject->parent_pvslistobj) {				\
-			PVSLIST_VALID(pvobject->parent_pvslistobj);	\
-		}												\
-		if (!pvobject->pv) {							\
+#define PV_VALID(pvobject) \
+	do { \
+		if (pvobject->parent_vgobj) { \
+			VG_VALID(pvobject->parent_vgobj); \
+		} \
+		if (pvobject->parent_pvslistobj) { \
+			PVSLIST_VALID(pvobject->parent_pvslistobj); \
+		} \
+		if (!pvobject->pv) { \
 			PyErr_SetString(PyExc_UnboundLocalError, "PV object invalid"); \
-			return NULL;								\
-		}												\
+			return NULL; \
+		} \
 	} while (0)
 
-static PyObject *
-liblvm_lvm_pv_get_name(pvobject *self)
+static PyObject *_liblvm_lvm_pv_get_name(pvobject *self)
 {
 	PV_VALID(self);
 
 	return Py_BuildValue("s", lvm_pv_get_name(self->pv));
 }
 
-static PyObject *
-liblvm_lvm_pv_get_uuid(pvobject *self)
+static PyObject *_liblvm_lvm_pv_get_uuid(pvobject *self)
 {
 	PV_VALID(self);
 
 	return Py_BuildValue("s", lvm_pv_get_uuid(self->pv));
 }
 
-static PyObject *
-liblvm_lvm_pv_get_mda_count(pvobject *self)
+static PyObject *_liblvm_lvm_pv_get_mda_count(pvobject *self)
 {
 	PV_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_pv_get_mda_count(self->pv));
 }
 
-static PyObject *
-liblvm_lvm_pv_get_property(pvobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_pv_get_property(pvobject *self, PyObject *args)
 {
 	const char *name;
 	struct lvm_property_value prop_value;
@@ -1708,56 +1589,51 @@ liblvm_lvm_pv_get_property(pvobject *self, PyObject *args)
 		return NULL;
 
 	prop_value = lvm_pv_get_property(self->pv, name);
+
 	return get_property(&prop_value);
 }
 
-static PyObject *
-liblvm_lvm_pv_get_dev_size(pvobject *self)
+static PyObject *_liblvm_lvm_pv_get_dev_size(pvobject *self)
 {
 	PV_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_pv_get_dev_size(self->pv));
 }
 
-static PyObject *
-liblvm_lvm_pv_get_size(pvobject *self)
+static PyObject *_liblvm_lvm_pv_get_size(pvobject *self)
 {
 	PV_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_pv_get_size(self->pv));
 }
 
-static PyObject *
-liblvm_lvm_pv_get_free(pvobject *self)
+static PyObject *_liblvm_lvm_pv_get_free(pvobject *self)
 {
 	PV_VALID(self);
 
 	return Py_BuildValue("K", (unsigned long long)lvm_pv_get_free(self->pv));
 }
 
-static PyObject *
-liblvm_lvm_pv_resize(pvobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_pv_resize(pvobject *self, PyObject *args)
 {
 	uint64_t new_size;
-	int rval;
 
 	PV_VALID(self);
 
-	if (!PyArg_ParseTuple(args, "l", &new_size)) {
+	if (!PyArg_ParseTuple(args, "l", &new_size))
 		return NULL;
-	}
 
-	if ((rval = lvm_pv_resize(self->pv, new_size)) == -1) {
-		PyErr_SetObject(LibLVMError, liblvm_get_last_error());
+	if (lvm_pv_resize(self->pv, new_size) == -1) {
+		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
 		return NULL;
 	}
 
 	Py_INCREF(Py_None);
+
 	return Py_None;
 }
 
-static PyObject *
-liblvm_lvm_pv_list_pvsegs(pvobject *self)
+static PyObject *_liblvm_lvm_pv_list_pvsegs(pvobject *self)
 {
 	struct dm_list *pvsegs;
 	pvseg_list_t *pvsegl;
@@ -1767,19 +1643,15 @@ liblvm_lvm_pv_list_pvsegs(pvobject *self)
 
 	PV_VALID(self);
 
-	pvsegs = lvm_pv_list_pvsegs(self->pv);
-	if (!pvsegs) {
+	if (!(pvsegs = lvm_pv_list_pvsegs(self->pv)))
 		return Py_BuildValue("()");
-	}
 
-	pytuple = PyTuple_New(dm_list_size(pvsegs));
-	if (!pytuple)
+	if (!(pytuple = PyTuple_New(dm_list_size(pvsegs))))
 		return NULL;
 
 	dm_list_iterate_items(pvsegl, pvsegs) {
 		/* Create and initialize the object */
-		pvsegobj = PyObject_New(pvsegobject, &LibLVMpvsegType);
-		if (!pvsegobj) {
+		if (!(pvsegobj = PyObject_New(pvsegobject, &_LibLVMpvsegType))) {
 			Py_DECREF(pytuple);
 			return NULL;
 		}
@@ -1803,15 +1675,13 @@ liblvm_lvm_pv_list_pvsegs(pvobject *self)
  */
 #define LVSEG_VALID(lvsegobject) LV_VALID(lvsegobject->parent_lvobj)
 
-static void
-liblvm_lvseg_dealloc(lvsegobject *self)
+static void _liblvm_lvseg_dealloc(lvsegobject *self)
 {
 	Py_DECREF(self->parent_lvobj);
 	PyObject_Del(self);
 }
 
-static PyObject *
-liblvm_lvm_lvseg_get_property(lvsegobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_lvseg_get_property(lvsegobject *self, PyObject *args)
 {
 	const char *name;
 	struct lvm_property_value prop_value;
@@ -1822,6 +1692,7 @@ liblvm_lvm_lvseg_get_property(lvsegobject *self, PyObject *args)
 		return NULL;
 
 	prop_value = lvm_lvseg_get_property(self->lv_seg, name);
+
 	return get_property(&prop_value);
 }
 
@@ -1833,15 +1704,13 @@ liblvm_lvm_lvseg_get_property(lvsegobject *self, PyObject *args)
  */
 #define PVSEG_VALID(pvsegobject) PV_VALID(pvsegobject->parent_pvobj)
 
-static void
-liblvm_pvseg_dealloc(pvsegobject *self)
+static void _liblvm_pvseg_dealloc(pvsegobject *self)
 {
 	Py_DECREF(self->parent_pvobj);
 	PyObject_Del(self);
 }
 
-static PyObject *
-liblvm_lvm_pvseg_get_property(pvsegobject *self, PyObject *args)
+static PyObject *_liblvm_lvm_pvseg_get_property(pvsegobject *self, PyObject *args)
 {
 	const char *name;
 	struct lvm_property_value prop_value;
@@ -1852,6 +1721,7 @@ liblvm_lvm_pvseg_get_property(pvsegobject *self, PyObject *args)
 		return NULL;
 
 	prop_value = lvm_pvseg_get_property(self->pv_seg, name);
+
 	return get_property(&prop_value);
 }
 
@@ -1859,122 +1729,122 @@ liblvm_lvm_pvseg_get_property(pvsegobject *self, PyObject *args)
  * Method tables and other bureaucracy
  */
 
-static PyMethodDef Liblvm_methods[] = {
+static PyMethodDef _Liblvm_methods[] = {
 	/* LVM methods */
-	{ "getVersion",		(PyCFunction)liblvm_library_get_version, METH_NOARGS },
-	{ "gc",				(PyCFunction)liblvm_lvm_gc, METH_NOARGS, gc_doc },
-	{ "vgOpen",		(PyCFunction)liblvm_lvm_vg_open, METH_VARARGS },
-	{ "vgCreate",		(PyCFunction)liblvm_lvm_vg_create, METH_VARARGS },
-	{ "configFindBool",	(PyCFunction)liblvm_lvm_config_find_bool, METH_VARARGS },
-	{ "configReload",	(PyCFunction)liblvm_lvm_config_reload, METH_NOARGS },
-	{ "configOverride",	(PyCFunction)liblvm_lvm_config_override, METH_VARARGS },
-	{ "scan",		(PyCFunction)liblvm_lvm_scan, METH_NOARGS },
-	{ "listVgNames",	(PyCFunction)liblvm_lvm_list_vg_names, METH_NOARGS },
-	{ "listVgUuids",	(PyCFunction)liblvm_lvm_list_vg_uuids, METH_NOARGS },
-	{ "listPvs",		(PyCFunction)liblvm_lvm_list_pvs, METH_NOARGS },
-	{ "pvCreate",		(PyCFunction)liblvm_lvm_pv_create, METH_VARARGS },
-	{ "pvRemove",		(PyCFunction)liblvm_lvm_pv_remove, METH_VARARGS },
-	{ "percentToFloat",	(PyCFunction)liblvm_lvm_percent_to_float, METH_VARARGS },
-	{ "vgNameFromPvid",	(PyCFunction)liblvm_lvm_vgname_from_pvid, METH_VARARGS },
-	{ "vgNameFromDevice",	(PyCFunction)liblvm_lvm_vgname_from_device, METH_VARARGS },
+	{ "getVersion",		(PyCFunction)_liblvm_library_get_version, METH_NOARGS },
+	{ "gc",			(PyCFunction)_liblvm_lvm_gc, METH_NOARGS, _gc_doc },
+	{ "vgOpen",		(PyCFunction)_liblvm_lvm_vg_open, METH_VARARGS },
+	{ "vgCreate",		(PyCFunction)_liblvm_lvm_vg_create, METH_VARARGS },
+	{ "configFindBool",	(PyCFunction)_liblvm_lvm_config_find_bool, METH_VARARGS },
+	{ "configReload",	(PyCFunction)_liblvm_lvm_config_reload, METH_NOARGS },
+	{ "configOverride",	(PyCFunction)_liblvm_lvm_config_override, METH_VARARGS },
+	{ "scan",		(PyCFunction)_liblvm_lvm_scan, METH_NOARGS },
+	{ "listVgNames",	(PyCFunction)_liblvm_lvm_list_vg_names, METH_NOARGS },
+	{ "listVgUuids",	(PyCFunction)_liblvm_lvm_list_vg_uuids, METH_NOARGS },
+	{ "listPvs",		(PyCFunction)_liblvm_lvm_list_pvs, METH_NOARGS },
+	{ "pvCreate",		(PyCFunction)_liblvm_lvm_pv_create, METH_VARARGS },
+	{ "pvRemove",		(PyCFunction)_liblvm_lvm_pv_remove, METH_VARARGS },
+	{ "percentToFloat",	(PyCFunction)_liblvm_lvm_percent_to_float, METH_VARARGS },
+	{ "vgNameFromPvid",	(PyCFunction)_liblvm_lvm_vgname_from_pvid, METH_VARARGS },
+	{ "vgNameFromDevice",	(PyCFunction)_liblvm_lvm_vgname_from_device, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
-static PyMethodDef liblvm_vg_methods[] = {
+static PyMethodDef _liblvm_vg_methods[] = {
 	/* vg methods */
-	{ "getName",		(PyCFunction)liblvm_lvm_vg_get_name, METH_NOARGS },
-	{ "getUuid",		(PyCFunction)liblvm_lvm_vg_get_uuid, METH_NOARGS },
-	{ "close",		(PyCFunction)liblvm_lvm_vg_close, METH_NOARGS },
-	{ "remove",		(PyCFunction)liblvm_lvm_vg_remove, METH_NOARGS },
-	{ "extend",		(PyCFunction)liblvm_lvm_vg_extend, METH_VARARGS },
-	{ "reduce",		(PyCFunction)liblvm_lvm_vg_reduce, METH_VARARGS },
-	{ "addTag",		(PyCFunction)liblvm_lvm_vg_add_tag, METH_VARARGS },
-	{ "removeTag",		(PyCFunction)liblvm_lvm_vg_remove_tag, METH_VARARGS },
-	{ "setExtentSize",	(PyCFunction)liblvm_lvm_vg_set_extent_size, METH_VARARGS },
-	{ "isClustered",	(PyCFunction)liblvm_lvm_vg_is_clustered, METH_NOARGS },
-	{ "isExported",		(PyCFunction)liblvm_lvm_vg_is_exported, METH_NOARGS },
-	{ "isPartial",		(PyCFunction)liblvm_lvm_vg_is_partial, METH_NOARGS },
-	{ "getSeqno",		(PyCFunction)liblvm_lvm_vg_get_seqno, METH_NOARGS },
-	{ "getSize",		(PyCFunction)liblvm_lvm_vg_get_size, METH_NOARGS },
-	{ "getFreeSize",	(PyCFunction)liblvm_lvm_vg_get_free_size, METH_NOARGS },
-	{ "getExtentSize",	(PyCFunction)liblvm_lvm_vg_get_extent_size, METH_NOARGS },
-	{ "getExtentCount",	(PyCFunction)liblvm_lvm_vg_get_extent_count, METH_NOARGS },
-	{ "getFreeExtentCount",	(PyCFunction)liblvm_lvm_vg_get_free_extent_count, METH_NOARGS },
-	{ "getProperty",	(PyCFunction)liblvm_lvm_vg_get_property, METH_VARARGS },
-	{ "setProperty",	(PyCFunction)liblvm_lvm_vg_set_property, METH_VARARGS },
-	{ "getPvCount",		(PyCFunction)liblvm_lvm_vg_get_pv_count, METH_NOARGS },
-	{ "getMaxPv",		(PyCFunction)liblvm_lvm_vg_get_max_pv, METH_NOARGS },
-	{ "getMaxLv",		(PyCFunction)liblvm_lvm_vg_get_max_lv, METH_NOARGS },
-	{ "listLVs",		(PyCFunction)liblvm_lvm_vg_list_lvs, METH_NOARGS },
-	{ "listPVs",		(PyCFunction)liblvm_lvm_vg_list_pvs, METH_NOARGS },
-	{ "lvFromName", 	(PyCFunction)liblvm_lvm_lv_from_name, METH_VARARGS },
-	{ "lvFromUuid", 	(PyCFunction)liblvm_lvm_lv_from_uuid, METH_VARARGS },
-	{ "pvFromName", 	(PyCFunction)liblvm_lvm_pv_from_name, METH_VARARGS },
-	{ "pvFromUuid", 	(PyCFunction)liblvm_lvm_pv_from_uuid, METH_VARARGS },
-	{ "getTags",		(PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
-	{ "createLvLinear",	(PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
-	{ "createLvThinpool", (PyCFunction)liblvm_lvm_vg_create_lv_thinpool, METH_VARARGS },
-	{ "createLvThin", 	(PyCFunction)liblvm_lvm_vg_create_lv_thin, METH_VARARGS },
+	{ "getName",		(PyCFunction)_liblvm_lvm_vg_get_name, METH_NOARGS },
+	{ "getUuid",		(PyCFunction)_liblvm_lvm_vg_get_uuid, METH_NOARGS },
+	{ "close",		(PyCFunction)_liblvm_lvm_vg_close, METH_NOARGS },
+	{ "remove",		(PyCFunction)_liblvm_lvm_vg_remove, METH_NOARGS },
+	{ "extend",		(PyCFunction)_liblvm_lvm_vg_extend, METH_VARARGS },
+	{ "reduce",		(PyCFunction)_liblvm_lvm_vg_reduce, METH_VARARGS },
+	{ "addTag",		(PyCFunction)_liblvm_lvm_vg_add_tag, METH_VARARGS },
+	{ "removeTag",		(PyCFunction)_liblvm_lvm_vg_remove_tag, METH_VARARGS },
+	{ "setExtentSize",	(PyCFunction)_liblvm_lvm_vg_set_extent_size, METH_VARARGS },
+	{ "isClustered",	(PyCFunction)_liblvm_lvm_vg_is_clustered, METH_NOARGS },
+	{ "isExported",		(PyCFunction)_liblvm_lvm_vg_is_exported, METH_NOARGS },
+	{ "isPartial",		(PyCFunction)_liblvm_lvm_vg_is_partial, METH_NOARGS },
+	{ "getSeqno",		(PyCFunction)_liblvm_lvm_vg_get_seqno, METH_NOARGS },
+	{ "getSize",		(PyCFunction)_liblvm_lvm_vg_get_size, METH_NOARGS },
+	{ "getFreeSize",	(PyCFunction)_liblvm_lvm_vg_get_free_size, METH_NOARGS },
+	{ "getExtentSize",	(PyCFunction)_liblvm_lvm_vg_get_extent_size, METH_NOARGS },
+	{ "getExtentCount",	(PyCFunction)_liblvm_lvm_vg_get_extent_count, METH_NOARGS },
+	{ "getFreeExtentCount",	(PyCFunction)_liblvm_lvm_vg_get_free_extent_count, METH_NOARGS },
+	{ "getProperty",	(PyCFunction)_liblvm_lvm_vg_get_property, METH_VARARGS },
+	{ "setProperty",	(PyCFunction)_liblvm_lvm_vg_set_property, METH_VARARGS },
+	{ "getPvCount",		(PyCFunction)_liblvm_lvm_vg_get_pv_count, METH_NOARGS },
+	{ "getMaxPv",		(PyCFunction)_liblvm_lvm_vg_get_max_pv, METH_NOARGS },
+	{ "getMaxLv",		(PyCFunction)_liblvm_lvm_vg_get_max_lv, METH_NOARGS },
+	{ "listLVs",		(PyCFunction)_liblvm_lvm_vg_list_lvs, METH_NOARGS },
+	{ "listPVs",		(PyCFunction)_liblvm_lvm_vg_list_pvs, METH_NOARGS },
+	{ "lvFromName", 	(PyCFunction)_liblvm_lvm_lv_from_name, METH_VARARGS },
+	{ "lvFromUuid", 	(PyCFunction)_liblvm_lvm_lv_from_uuid, METH_VARARGS },
+	{ "pvFromName", 	(PyCFunction)_liblvm_lvm_pv_from_name, METH_VARARGS },
+	{ "pvFromUuid", 	(PyCFunction)_liblvm_lvm_pv_from_uuid, METH_VARARGS },
+	{ "getTags",		(PyCFunction)_liblvm_lvm_vg_get_tags, METH_NOARGS },
+	{ "createLvLinear",	(PyCFunction)_liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
+	{ "createLvThinpool",	(PyCFunction)_liblvm_lvm_vg_create_lv_thinpool, METH_VARARGS },
+	{ "createLvThin", 	(PyCFunction)_liblvm_lvm_vg_create_lv_thin, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
-static PyMethodDef liblvm_lv_methods[] = {
+static PyMethodDef _liblvm_lv_methods[] = {
 	/* lv methods */
-	{ "getAttr",		(PyCFunction)liblvm_lvm_lv_get_attr, METH_NOARGS },
-	{ "getName",		(PyCFunction)liblvm_lvm_lv_get_name, METH_NOARGS },
-	{ "getOrigin",		(PyCFunction)liblvm_lvm_lv_get_origin, METH_NOARGS },
-	{ "getUuid",		(PyCFunction)liblvm_lvm_lv_get_uuid, METH_NOARGS },
-	{ "activate",		(PyCFunction)liblvm_lvm_lv_activate, METH_NOARGS },
-	{ "deactivate",		(PyCFunction)liblvm_lvm_lv_deactivate, METH_NOARGS },
-	{ "remove",		(PyCFunction)liblvm_lvm_vg_remove_lv, METH_NOARGS },
-	{ "getProperty",	(PyCFunction)liblvm_lvm_lv_get_property, METH_VARARGS },
-	{ "getSize",		(PyCFunction)liblvm_lvm_lv_get_size, METH_NOARGS },
-	{ "isActive",		(PyCFunction)liblvm_lvm_lv_is_active, METH_NOARGS },
-	{ "isSuspended",	(PyCFunction)liblvm_lvm_lv_is_suspended, METH_NOARGS },
-	{ "addTag",		(PyCFunction)liblvm_lvm_lv_add_tag, METH_VARARGS },
-	{ "removeTag",		(PyCFunction)liblvm_lvm_lv_remove_tag, METH_VARARGS },
-	{ "getTags",		(PyCFunction)liblvm_lvm_lv_get_tags, METH_NOARGS },
-	{ "rename",		(PyCFunction)liblvm_lvm_lv_rename, METH_VARARGS },
-	{ "resize",		(PyCFunction)liblvm_lvm_lv_resize, METH_VARARGS },
-	{ "listLVsegs",		(PyCFunction)liblvm_lvm_lv_list_lvsegs, METH_NOARGS },
-	{ "snapshot",		(PyCFunction)liblvm_lvm_lv_snapshot, METH_VARARGS },
+	{ "getAttr",		(PyCFunction)_liblvm_lvm_lv_get_attr, METH_NOARGS },
+	{ "getName",		(PyCFunction)_liblvm_lvm_lv_get_name, METH_NOARGS },
+	{ "getOrigin",		(PyCFunction)_liblvm_lvm_lv_get_origin, METH_NOARGS },
+	{ "getUuid",		(PyCFunction)_liblvm_lvm_lv_get_uuid, METH_NOARGS },
+	{ "activate",		(PyCFunction)_liblvm_lvm_lv_activate, METH_NOARGS },
+	{ "deactivate",		(PyCFunction)_liblvm_lvm_lv_deactivate, METH_NOARGS },
+	{ "remove",		(PyCFunction)_liblvm_lvm_vg_remove_lv, METH_NOARGS },
+	{ "getProperty",	(PyCFunction)_liblvm_lvm_lv_get_property, METH_VARARGS },
+	{ "getSize",		(PyCFunction)_liblvm_lvm_lv_get_size, METH_NOARGS },
+	{ "isActive",		(PyCFunction)_liblvm_lvm_lv_is_active, METH_NOARGS },
+	{ "isSuspended",	(PyCFunction)_liblvm_lvm_lv_is_suspended, METH_NOARGS },
+	{ "addTag",		(PyCFunction)_liblvm_lvm_lv_add_tag, METH_VARARGS },
+	{ "removeTag",		(PyCFunction)_liblvm_lvm_lv_remove_tag, METH_VARARGS },
+	{ "getTags",		(PyCFunction)_liblvm_lvm_lv_get_tags, METH_NOARGS },
+	{ "rename",		(PyCFunction)_liblvm_lvm_lv_rename, METH_VARARGS },
+	{ "resize",		(PyCFunction)_liblvm_lvm_lv_resize, METH_VARARGS },
+	{ "listLVsegs",		(PyCFunction)_liblvm_lvm_lv_list_lvsegs, METH_NOARGS },
+	{ "snapshot",		(PyCFunction)_liblvm_lvm_lv_snapshot, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
-static PyMethodDef liblvm_pv_list_methods[] = {
+static PyMethodDef _liblvm_pv_list_methods[] = {
 	/* pv list methods */
-	{ "__enter__", 	(PyCFunction)liblvm_lvm_pvlist_get, METH_VARARGS },
-	{ "__exit__", 	(PyCFunction)liblvm_lvm_pvlist_put, METH_VARARGS },
-	{ "open",		(PyCFunction)liblvm_lvm_pvlist_get, METH_VARARGS },
-	{ "close",		(PyCFunction)liblvm_lvm_pvlist_put, METH_VARARGS },
+	{ "__enter__", 		(PyCFunction)_liblvm_lvm_pvlist_get, METH_VARARGS },
+	{ "__exit__", 		(PyCFunction)_liblvm_lvm_pvlist_put, METH_VARARGS },
+	{ "open",		(PyCFunction)_liblvm_lvm_pvlist_get, METH_VARARGS },
+	{ "close",		(PyCFunction)_liblvm_lvm_pvlist_put, METH_VARARGS },
 	{ NULL, NULL }
 };
 
-static PyMethodDef liblvm_pv_methods[] = {
+static PyMethodDef _liblvm_pv_methods[] = {
 	/* pv methods */
-	{ "getName",		(PyCFunction)liblvm_lvm_pv_get_name, METH_NOARGS },
-	{ "getUuid",		(PyCFunction)liblvm_lvm_pv_get_uuid, METH_NOARGS },
-	{ "getMdaCount",	(PyCFunction)liblvm_lvm_pv_get_mda_count, METH_NOARGS },
-	{ "getProperty",	(PyCFunction)liblvm_lvm_pv_get_property, METH_VARARGS },
-	{ "getSize",		(PyCFunction)liblvm_lvm_pv_get_size, METH_NOARGS },
-	{ "getDevSize",		(PyCFunction)liblvm_lvm_pv_get_dev_size, METH_NOARGS },
-	{ "getFree",		(PyCFunction)liblvm_lvm_pv_get_free, METH_NOARGS },
-	{ "resize",		(PyCFunction)liblvm_lvm_pv_resize, METH_VARARGS },
-	{ "listPVsegs", 	(PyCFunction)liblvm_lvm_pv_list_pvsegs, METH_NOARGS },
+	{ "getName",		(PyCFunction)_liblvm_lvm_pv_get_name, METH_NOARGS },
+	{ "getUuid",		(PyCFunction)_liblvm_lvm_pv_get_uuid, METH_NOARGS },
+	{ "getMdaCount",	(PyCFunction)_liblvm_lvm_pv_get_mda_count, METH_NOARGS },
+	{ "getProperty",	(PyCFunction)_liblvm_lvm_pv_get_property, METH_VARARGS },
+	{ "getSize",		(PyCFunction)_liblvm_lvm_pv_get_size, METH_NOARGS },
+	{ "getDevSize",		(PyCFunction)_liblvm_lvm_pv_get_dev_size, METH_NOARGS },
+	{ "getFree",		(PyCFunction)_liblvm_lvm_pv_get_free, METH_NOARGS },
+	{ "resize",		(PyCFunction)_liblvm_lvm_pv_resize, METH_VARARGS },
+	{ "listPVsegs", 	(PyCFunction)_liblvm_lvm_pv_list_pvsegs, METH_NOARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
-static PyMethodDef liblvm_lvseg_methods[] = {
-	{ "getProperty", 	(PyCFunction)liblvm_lvm_lvseg_get_property, METH_VARARGS },
+static PyMethodDef _liblvm_lvseg_methods[] = {
+	{ "getProperty", 	(PyCFunction)_liblvm_lvm_lvseg_get_property, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
-static PyMethodDef liblvm_pvseg_methods[] = {
-	{ "getProperty", 	(PyCFunction)liblvm_lvm_pvseg_get_property, METH_VARARGS },
+static PyMethodDef _liblvm_pvseg_methods[] = {
+	{ "getProperty", 	(PyCFunction)_liblvm_lvm_pvseg_get_property, METH_VARARGS },
 	{ NULL, NULL }		/* sentinel */
 };
 
-static PyTypeObject LibLVMvgType = {
+static PyTypeObject _LibLVMvgType = {
 	PyObject_HEAD_INIT(&PyType_Type)
 	.tp_name = "liblvm.Liblvm_vg",
 	.tp_basicsize = sizeof(vgobject),
@@ -1982,10 +1852,10 @@ static PyTypeObject LibLVMvgType = {
 	.tp_dealloc = (destructor)liblvm_vg_dealloc,
 	.tp_flags = Py_TPFLAGS_DEFAULT,
 	.tp_doc = "LVM Volume Group object",
-	.tp_methods = liblvm_vg_methods,
+	.tp_methods = _liblvm_vg_methods,
 };
 
-static PyTypeObject LibLVMlvType = {
+static PyTypeObject _LibLVMlvType = {
 	PyObject_HEAD_INIT(&PyType_Type)
 	.tp_name = "liblvm.Liblvm_lv",
 	.tp_basicsize = sizeof(lvobject),
@@ -1993,111 +1863,102 @@ static PyTypeObject LibLVMlvType = {
 	.tp_dealloc = (destructor)liblvm_lv_dealloc,
 	.tp_flags = Py_TPFLAGS_DEFAULT,
 	.tp_doc = "LVM Logical Volume object",
-	.tp_methods = liblvm_lv_methods,
+	.tp_methods = _liblvm_lv_methods,
 };
 
-static PyTypeObject LibLVMpvlistType = {
+static PyTypeObject _LibLVMpvlistType = {
 	PyObject_HEAD_INIT(&PyType_Type)
-		.tp_name = "liblvm.Liblvm_pvlist",
-		.tp_basicsize = sizeof(pvslistobject),
-		.tp_new = PyType_GenericNew,
-		.tp_dealloc = (destructor)liblvm_pvlist_dealloc,
-		.tp_flags = Py_TPFLAGS_DEFAULT,
-		.tp_doc = "LVM Physical Volume list object",
-		.tp_methods = liblvm_pv_list_methods,
+	.tp_name = "liblvm.Liblvm_pvlist",
+	.tp_basicsize = sizeof(pvslistobject),
+	.tp_new = PyType_GenericNew,
+	.tp_dealloc = (destructor)_liblvm_pvlist_dealloc,
+	.tp_flags = Py_TPFLAGS_DEFAULT,
+	.tp_doc = "LVM Physical Volume list object",
+	.tp_methods = _liblvm_pv_list_methods,
 };
 
-static PyTypeObject LibLVMpvType = {
+static PyTypeObject _LibLVMpvType = {
 	PyObject_HEAD_INIT(&PyType_Type)
 	.tp_name = "liblvm.Liblvm_pv",
 	.tp_basicsize = sizeof(pvobject),
 	.tp_new = PyType_GenericNew,
-	.tp_dealloc = (destructor)liblvm_pv_dealloc,
+	.tp_dealloc = (destructor)_liblvm_pv_dealloc,
 	.tp_flags = Py_TPFLAGS_DEFAULT,
 	.tp_doc = "LVM Physical Volume object",
-	.tp_methods = liblvm_pv_methods,
+	.tp_methods = _liblvm_pv_methods,
 };
 
-static PyTypeObject LibLVMlvsegType = {
+static PyTypeObject _LibLVMlvsegType = {
 	PyObject_HEAD_INIT(&PyType_Type)
 	.tp_name = "liblvm.Liblvm_lvseg",
 	.tp_basicsize = sizeof(lvsegobject),
 	.tp_new = PyType_GenericNew,
-	.tp_dealloc = (destructor)liblvm_lvseg_dealloc,
+	.tp_dealloc = (destructor)_liblvm_lvseg_dealloc,
 	.tp_flags = Py_TPFLAGS_DEFAULT,
 	.tp_doc = "LVM Logical Volume Segment object",
-	.tp_methods = liblvm_lvseg_methods,
+	.tp_methods = _liblvm_lvseg_methods,
 };
 
-static PyTypeObject LibLVMpvsegType = {
+static PyTypeObject _LibLVMpvsegType = {
 	PyObject_HEAD_INIT(&PyType_Type)
 	.tp_name = "liblvm.Liblvm_pvseg",
 	.tp_basicsize = sizeof(pvsegobject),
 	.tp_new = PyType_GenericNew,
-	.tp_dealloc = (destructor)liblvm_pvseg_dealloc,
+	.tp_dealloc = (destructor)_liblvm_pvseg_dealloc,
 	.tp_flags = Py_TPFLAGS_DEFAULT,
 	.tp_doc = "LVM Physical Volume Segment object",
-	.tp_methods = liblvm_pvseg_methods,
+	.tp_methods = _liblvm_pvseg_methods,
 };
 
-static void
-liblvm_cleanup(void)
+static void _liblvm_cleanup(void)
 {
-	if (libh) {
-		lvm_quit(libh);
-		libh = NULL;
+	if (_libh) {
+		lvm_quit(_libh);
+		_libh = NULL;
 	}
 }
 
-PyMODINIT_FUNC
-initlvm(void)
+PyMODINIT_FUNC initlvm(void)
 {
 	PyObject *m;
 
-	libh = lvm_init(NULL);
+	_libh = lvm_init(NULL);
 
-	if (PyType_Ready(&LibLVMvgType) < 0)
+	if (PyType_Ready(&_LibLVMvgType) < 0)
 		return;
-	if (PyType_Ready(&LibLVMlvType) < 0)
+	if (PyType_Ready(&_LibLVMlvType) < 0)
 		return;
-	if (PyType_Ready(&LibLVMpvType) < 0)
+	if (PyType_Ready(&_LibLVMpvType) < 0)
 		return;
-	if (PyType_Ready(&LibLVMlvsegType) < 0)
+	if (PyType_Ready(&_LibLVMlvsegType) < 0)
 		return;
-	if (PyType_Ready(&LibLVMpvsegType) < 0)
+	if (PyType_Ready(&_LibLVMpvsegType) < 0)
 		return;
-	if (PyType_Ready(&LibLVMpvlistType) < 0)
-			return;
-
-	m = Py_InitModule3("lvm", Liblvm_methods, "Liblvm module");
-	if (m == NULL)
+	if (PyType_Ready(&_LibLVMpvlistType) < 0)
 		return;
 
+	if (!(m = Py_InitModule3("lvm", _Liblvm_methods, "Liblvm module")))
+		return;
 
-	if (-1 == PyModule_AddIntConstant(m, "THIN_DISCARDS_IGNORE",
-										LVM_THIN_DISCARDS_IGNORE)) {
+	if (PyModule_AddIntConstant(m, "THIN_DISCARDS_IGNORE",
+				    LVM_THIN_DISCARDS_IGNORE) < 0)
 		return;
-	}
 
-	if (-1 == PyModule_AddIntConstant(m, "THIN_DISCARDS_NO_PASSDOWN",
-											LVM_THIN_DISCARDS_NO_PASSDOWN)) {
+	if (PyModule_AddIntConstant(m, "THIN_DISCARDS_NO_PASSDOWN",
+				    LVM_THIN_DISCARDS_NO_PASSDOWN) < 0)
 		return;
-	}
 
-	if ( -1 == PyModule_AddIntConstant(m, "THIN_DISCARDS_PASSDOWN",
-											LVM_THIN_DISCARDS_PASSDOWN)) {
+	if (PyModule_AddIntConstant(m, "THIN_DISCARDS_PASSDOWN",
+				    LVM_THIN_DISCARDS_PASSDOWN) < 0)
 		return;
-	}
 
-	LibLVMError = PyErr_NewException("Liblvm.LibLVMError",
-					 NULL, NULL);
-	if (LibLVMError) {
+	if ((_LibLVMError = PyErr_NewException("Liblvm._LibLVMError", NULL, NULL))) {
 		/* Each call to PyModule_AddObject decrefs it; compensate: */
-		Py_INCREF(LibLVMError);
-		Py_INCREF(LibLVMError);
-		PyModule_AddObject(m, "error", LibLVMError);
-		PyModule_AddObject(m, "LibLVMError", LibLVMError);
+		Py_INCREF(_LibLVMError);
+		Py_INCREF(_LibLVMError);
+		PyModule_AddObject(m, "error", _LibLVMError);
+		PyModule_AddObject(m, "_LibLVMError", _LibLVMError);
 	}
 
-	Py_AtExit(liblvm_cleanup);
+	Py_AtExit(_liblvm_cleanup);
 }


