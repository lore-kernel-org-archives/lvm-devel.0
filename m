From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 29 Apr 2015 13:10:24 +0000 (UTC)
Subject: master - python: python 3 compat patch for lvm2
Message-ID: <20150429131024.094A760ECF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d8b31ffad4fb6e3f1e9a4f20387cd7f1e141085
Commit:        5d8b31ffad4fb6e3f1e9a4f20387cd7f1e141085
Parent:        4946c64092a04d6a5a7a09a31f7c74c193d3484f
Author:        bkabrda at redhat.com <bkabrda@redhat.com>
AuthorDate:    Tue Sep 2 15:42:01 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 29 15:09:56 2015 +0200

python: python 3 compat patch for lvm2

As provided by rhbz: 1136366
---
 WHATS_NEW                   |    1 +
 python/example.py           |   18 ++++----
 python/liblvm.c             |  103 +++++++++++++++++++++++++++++++------------
 test/api/python_lvm_unit.py |   18 ++-----
 4 files changed, 89 insertions(+), 51 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7873d37..1437825 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Make python bindings usable with python3 (and compatible with 2.6 & 2.7).
   Add lvmconfig -l|--list as shortcut for lvmconfig --type list --withsummary.
   Add lvmconfig --type list to display plain list of configuration settings.
   Introduce lvmconfig as the preferred form of 'lvm dumpconfig'.
diff --git a/python/example.py b/python/example.py
index 5c14ee1..07ebbf2 100644
--- a/python/example.py
+++ b/python/example.py
@@ -27,7 +27,7 @@ import lvm
 
 #Dump information about PV
 def print_pv(pv):
-    print 'PV name: ', pv.getName(), ' ID: ', pv.getUuid(), 'Size: ', pv.getSize()
+    print('PV name: ', pv.getName(), ' ID: ', pv.getUuid(), 'Size: ', pv.getSize())
 
 
 #Dump some information about a specific volume group
@@ -35,7 +35,7 @@ def print_vg(vg_name):
     #Open read only
     vg = lvm.vgOpen(vg_name, 'r')
 
-    print 'Volume group:', vg_name, 'Size: ', vg.getSize()
+    print('Volume group:', vg_name, 'Size: ', vg.getSize())
 
     #Retrieve a list of Physical volumes for this volume group
     pv_list = vg.listPVs()
@@ -48,9 +48,9 @@ def print_vg(vg_name):
     lv_list = vg.listLVs()
     if len(lv_list):
         for l in lv_list:
-            print 'LV name: ', l.getName(), ' ID: ', l.getUuid()
+            print('LV name: ', l.getName(), ' ID: ', l.getUuid())
     else:
-        print 'No logical volumes present!'
+        print('No logical volumes present!')
 
     vg.close()
 
@@ -75,14 +75,14 @@ def find_vg_with_free_space():
 def create_delete_logical_volume():
     vg_name = find_vg_with_free_space()
 
-    print 'Using volume group ', vg_name, ' for example'
+    print('Using volume group ', vg_name, ' for example')
 
     if vg_name:
         vg = lvm.vgOpen(vg_name, 'w')
         lv = vg.createLvLinear('python_lvm_ok_to_delete', vg.getFreeSize())
 
         if lv:
-            print 'New lv, id= ', lv.getUuid()
+            print('New lv, id= ', lv.getUuid())
 
             #Create a tag
             lv.addTag('Demo_tag')
@@ -97,16 +97,16 @@ def create_delete_logical_volume():
 
             #Try to rename
             lv.rename("python_lvm_renamed")
-            print 'LV name= ', lv.getName()
+            print('LV name= ', lv.getName())
             lv.remove()
 
         vg.close()
     else:
-        print 'No free space available to create demo lv!'
+        print('No free space available to create demo lv!')
 
 if __name__ == '__main__':
     #What version
-    print 'lvm version=', lvm.getVersion()
+    print('lvm version=', lvm.getVersion())
 
     #Get a list of volume group names
     vg_names = lvm.listVgNames()
diff --git a/python/liblvm.c b/python/liblvm.c
index 1c9b5c4..6151745 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -25,6 +25,23 @@
 #include "lvm2app.h"
 #include "defaults.h"
 
+#if PY_MAJOR_VERSION >= 3
+#define IS_PY3K
+#define PYINTTYPE_CHECK PyLong_Check
+#define PYINTTYPE_ASLONG PyLong_AsLong
+#define PYINTTYPE_FROMLONG PyLong_FromLong
+#define PYSTRYPE_CHECK PyUnicode_Check
+#define PYSTRTYPE_ASSTRING PyUnicode_AsUTF8
+#define PYSTRTYPE_FROMSTRING PyUnicode_FromString
+#else
+#define PYINTTYPE_CHECK PyInt_Check
+#define PYINTTYPE_ASLONG PyInt_AsLong
+#define PYINTTYPE_FROMLONG PyInt_FromLong
+#define PYSTRYPE_CHECK PyString_Check
+#define PYSTRTYPE_ASSTRING PyString_AsString
+#define PYSTRTYPE_FROMSTRING PyString_FromString
+#endif
+
 static lvm_t _libh;
 
 
@@ -148,10 +165,10 @@ static PyObject *_liblvm_get_last_error(void)
 	if (!(info = PyTuple_New(2)))
 		return NULL;
 
-	PyTuple_SetItem(info, 0, PyInt_FromLong((long) lvm_errno(_libh)));
+	PyTuple_SetItem(info, 0, PYINTTYPE_FROMLONG((long) lvm_errno(_libh)));
 	msg = lvm_errmsg(_libh);
-	PyTuple_SetItem(info, 1, ((msg) ? PyString_FromString(msg) :
-			PyString_FromString("Memory error while retrieving error message")));
+	PyTuple_SetItem(info, 1, ((msg) ? PYSTRTYPE_FROMSTRING(msg) :
+			PYSTRTYPE_FROMSTRING("Memory error while retrieving error message")));
 
 	return info;
 }
@@ -199,7 +216,7 @@ static PyObject *_liblvm_lvm_list_vg_names(void)
 		return NULL;
 
 	dm_list_iterate_items(strl, vgnames) {
-		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
+		PyTuple_SET_ITEM(pytuple, i, PYSTRTYPE_FROMSTRING(strl->str));
 		i++;
 	}
 
@@ -224,7 +241,7 @@ static PyObject *_liblvm_lvm_list_vg_uuids(void)
 		return NULL;
 
 	dm_list_iterate_items(strl, uuids) {
-		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
+		PyTuple_SET_ITEM(pytuple, i, PYSTRTYPE_FROMSTRING(strl->str));
 		i++;
 	}
 
@@ -856,7 +873,7 @@ static PyObject *get_property(struct lvm_property_value *prop)
 	if (prop->is_integer)
 		PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop->value.integer));
 	else
-		PyTuple_SET_ITEM(pytuple, 0, PyString_FromString(prop->value.string));
+		PyTuple_SET_ITEM(pytuple, 0, PYSTRTYPE_FROMSTRING(prop->value.string));
 
 	if (prop->is_settable)
 		setable = Py_True;
@@ -904,14 +921,14 @@ static PyObject *_liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 	if (!lvm_property.is_valid)
 		goto lvmerror;
 
-	if (PyObject_IsInstance(variant_type_arg, (PyObject*)&PyString_Type)) {
+	if (PYSTRYPE_CHECK(variant_type_arg)) {
 
 		if (!lvm_property.is_string) {
 			PyErr_Format(PyExc_ValueError, "Property requires string value");
 			goto bail;
 		}
 
-		if (!(string_value = PyString_AsString(variant_type_arg))) {
+		if (!(string_value = PYSTRTYPE_ASSTRING(variant_type_arg))) {
 			PyErr_NoMemory();
 			goto bail;
 		}
@@ -924,8 +941,8 @@ static PyObject *_liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 			goto bail;
 		}
 
-		if (PyObject_IsInstance(variant_type_arg, (PyObject*)&PyInt_Type)) {
-			temp_py_int = PyInt_AsLong(variant_type_arg);
+		if (PYINTTYPE_CHECK(variant_type_arg)) {
+			temp_py_int = PYINTTYPE_ASLONG(variant_type_arg);
 
 			/* -1 could be valid, need to see if an exception was gen. */
 			if (temp_py_int == -1 && PyErr_Occurred())
@@ -1056,7 +1073,7 @@ static PyObject *_liblvm_lvm_vg_get_tags(vgobject *self)
 		return NULL;
 
 	dm_list_iterate_items(strl, tagsl) {
-		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
+		PyTuple_SET_ITEM(pytuple, i, PYSTRTYPE_FROMSTRING(strl->str));
 		i++;
 	}
 
@@ -1499,7 +1516,7 @@ static PyObject *_liblvm_lvm_lv_get_tags(lvobject *self)
 		return NULL;
 
 	dm_list_iterate_items(strl, tagsl) {
-		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
+		PyTuple_SET_ITEM(pytuple, i, PYSTRTYPE_FROMSTRING(strl->str));
 		i++;
 	}
 
@@ -1923,7 +1940,7 @@ static PyMethodDef _liblvm_pvseg_methods[] = {
 };
 
 static PyTypeObject _LibLVMvgType = {
-	PyObject_HEAD_INIT(&PyType_Type)
+	PyVarObject_HEAD_INIT(&PyType_Type, 0)
 	.tp_name = "lvm.Liblvm_vg",
 	.tp_basicsize = sizeof(vgobject),
 	.tp_new = PyType_GenericNew,
@@ -1934,7 +1951,7 @@ static PyTypeObject _LibLVMvgType = {
 };
 
 static PyTypeObject _LibLVMlvType = {
-	PyObject_HEAD_INIT(&PyType_Type)
+	PyVarObject_HEAD_INIT(&PyType_Type, 0)
 	.tp_name = "lvm.Liblvm_lv",
 	.tp_basicsize = sizeof(lvobject),
 	.tp_new = PyType_GenericNew,
@@ -1945,7 +1962,7 @@ static PyTypeObject _LibLVMlvType = {
 };
 
 static PyTypeObject _LibLVMpvlistType = {
-	PyObject_HEAD_INIT(&PyType_Type)
+	PyVarObject_HEAD_INIT(&PyType_Type, 0)
 	.tp_name = "lvm.Liblvm_pvlist",
 	.tp_basicsize = sizeof(pvslistobject),
 	.tp_new = PyType_GenericNew,
@@ -1956,7 +1973,7 @@ static PyTypeObject _LibLVMpvlistType = {
 };
 
 static PyTypeObject _LibLVMpvType = {
-	PyObject_HEAD_INIT(&PyType_Type)
+	PyVarObject_HEAD_INIT(&PyType_Type, 0)
 	.tp_name = "lvm.Liblvm_pv",
 	.tp_basicsize = sizeof(pvobject),
 	.tp_new = PyType_GenericNew,
@@ -1967,7 +1984,7 @@ static PyTypeObject _LibLVMpvType = {
 };
 
 static PyTypeObject _LibLVMlvsegType = {
-	PyObject_HEAD_INIT(&PyType_Type)
+	PyVarObject_HEAD_INIT(&PyType_Type, 0)
 	.tp_name = "lvm.Liblvm_lvseg",
 	.tp_basicsize = sizeof(lvsegobject),
 	.tp_new = PyType_GenericNew,
@@ -1978,7 +1995,7 @@ static PyTypeObject _LibLVMlvsegType = {
 };
 
 static PyTypeObject _LibLVMpvsegType = {
-	PyObject_HEAD_INIT(&PyType_Type)
+	PyVarObject_HEAD_INIT(&PyType_Type, 0)
 	.tp_name = "lvm.Liblvm_pvseg",
 	.tp_basicsize = sizeof(pvsegobject),
 	.tp_new = PyType_GenericNew,
@@ -1996,40 +2013,65 @@ static void _liblvm_cleanup(void)
 	}
 }
 
+#ifdef IS_PY3K
+static struct PyModuleDef moduledef = {
+	PyModuleDef_HEAD_INIT,
+	"lvm",
+	"Liblvm module",
+	-1,
+	_Liblvm_methods,
+	NULL,
+	NULL,
+	NULL,
+	NULL
+};
+
+#define MODINITERROR return NULL
+PyObject *
+PyInit_lvm(void)
+
+#else
+#define MODINITERROR return
 PyMODINIT_FUNC initlvm(void);
 PyMODINIT_FUNC initlvm(void)
+#endif
 {
 	PyObject *m;
 
 	_libh = lvm_init(NULL);
 
 	if (PyType_Ready(&_LibLVMvgType) < 0)
-		return;
+		MODINITERROR;
 	if (PyType_Ready(&_LibLVMlvType) < 0)
-		return;
+		MODINITERROR;
 	if (PyType_Ready(&_LibLVMpvType) < 0)
-		return;
+		MODINITERROR;
 	if (PyType_Ready(&_LibLVMlvsegType) < 0)
-		return;
+		MODINITERROR;
 	if (PyType_Ready(&_LibLVMpvsegType) < 0)
-		return;
+		MODINITERROR;
 	if (PyType_Ready(&_LibLVMpvlistType) < 0)
-		return;
+		MODINITERROR;
 
-	if (!(m = Py_InitModule3("lvm", _Liblvm_methods, "Liblvm module")))
-		return;
+#ifdef IS_PY3K
+	m = PyModule_Create(&moduledef);
+#else
+	m = Py_InitModule3("lvm", _Liblvm_methods, "Liblvm module");
+#endif
+	if (m == NULL)
+		MODINITERROR;
 
 	if (PyModule_AddIntConstant(m, "THIN_DISCARDS_IGNORE",
 				    LVM_THIN_DISCARDS_IGNORE) < 0)
-		return;
+		MODINITERROR;
 
 	if (PyModule_AddIntConstant(m, "THIN_DISCARDS_NO_PASSDOWN",
 				    LVM_THIN_DISCARDS_NO_PASSDOWN) < 0)
-		return;
+		MODINITERROR;
 
 	if (PyModule_AddIntConstant(m, "THIN_DISCARDS_PASSDOWN",
 				    LVM_THIN_DISCARDS_PASSDOWN) < 0)
-		return;
+		MODINITERROR;
 
 	if ((_LibLVMError = PyErr_NewException((char*)"lvm.LibLVMError", NULL, NULL))) {
 		/* Each call to PyModule_AddObject decrefs it; compensate: */
@@ -2040,4 +2082,7 @@ PyMODINIT_FUNC initlvm(void)
 	}
 
 	Py_AtExit(_liblvm_cleanup);
+#ifdef IS_PY3K
+	return m;
+#endif
 }
diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index 455c9e8..e66ebda 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -18,6 +18,10 @@ import string
 import lvm
 import os
 import itertools
+import sys
+
+if sys.version_info[0] > 2:
+    long = int
 
 # Set of basic unit tests for the python bindings.
 #
@@ -56,18 +60,6 @@ def _get_allowed_devices():
 	return rc
 
 
-def compare_pv(right, left):
-	r_name = right.getName()
-	l_name = left.getName()
-
-	if r_name > l_name:
-		return 1
-	elif r_name == l_name:
-		return 0
-	else:
-		return -1
-
-
 class AllowedPVS(object):
 	"""
 	We are only allowed to muck with certain PV, filter to only
@@ -92,7 +84,7 @@ class AllowedPVS(object):
 					rc.append(p)
 
 		#Sort them consistently
-		rc.sort(compare_pv)
+		rc.sort(key=lambda x: x.getName())
 		return rc
 
 	def __exit__(self, t_type, value, traceback):


