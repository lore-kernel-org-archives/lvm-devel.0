From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:42 +0000 (UTC)
Subject: master - python-lvm: Bug fixes from unit tests.
Message-ID: <20130702192642.5E09C60DC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40feaa7bbeaca9a89f9b8e87b684c457cd10aa57
Commit:        40feaa7bbeaca9a89f9b8e87b684c457cd10aa57
Parent:        8882480083f9b4f769cc8756a2f641ae0452040d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 18 15:13:27 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

python-lvm: Bug fixes from unit tests.

After the last rebase, existing unit test case was
run which uncovered a number of errors that required
attention.

Uninitialized variables and changes to type of numeric
return type were addressed.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm_lv.c             |    7 ++++-
 liblvm/lvm_vg.c             |   11 ++++++++
 python/liblvm.c             |   56 ++++++++++++++++++++++++++++++-------------
 test/api/python_lvm_unit.py |   13 ++++-----
 4 files changed, 62 insertions(+), 25 deletions(-)

diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 081c73e..15bd813 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -611,7 +611,12 @@ lv_t lvm_lv_create(lv_create_params_t params)
 		}
 		if (!lv_create_single(params->vg, &params->lvp))
 				return_NULL;
-		if (!(lvl = find_lv_in_vg(params->vg, params->lvp.lv_name)))
+
+		/* In some case we are making a thin pool so lv_name is not valid, but
+		 * pool is.
+		 */
+		if (!(lvl = find_lv_in_vg(params->vg,
+				(params->lvp.lv_name) ? params->lvp.lv_name : params->lvp.pool)))
 			return_NULL;
 		return (lv_t) lvl->lv;
 	}
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a707589..955afdb 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -345,6 +345,17 @@ struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 int lvm_vg_set_property(const vg_t vg, const char *name,
 			struct lvm_property_value *value)
 {
+	/* At this point it is unknown if all property set paths make the
+	 * appropriate copy of the string.  We will allocate a copy on the vg so
+	 * that worst case we have two copies which will get freed when the vg gets
+	 * released.
+	 */
+
+	if (value->is_valid && value->is_string && value->value.string) {
+		value->value.string = dm_pool_strndup(vg->vgmem, value->value.string,
+				strlen(value->value.string) + 1);
+	}
+
 	return set_property(NULL, vg, NULL, NULL, name, value);
 }
 
diff --git a/python/liblvm.c b/python/liblvm.c
index e696a81..cdeb4bf 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1,7 +1,7 @@
 /*
  * Liblvm -- Python interface to LVM2 API.
  *
- * Copyright (C) 2010, 2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010, 2013 Red Hat, Inc. All rights reserved.
  *
  * This program is free software: you can redistribute it and/or modify
  * it under the terms of the GNU Lesser General Public License as published by
@@ -79,6 +79,31 @@ static PyObject *LibLVMError;
 		}							\
 	} while (0)
 
+/**
+ * Ensure that we initialize all the bits to a sane state.
+ */
+static pvobject
+*create_py_pv(void)
+{
+	pvobject * pvobj = PyObject_New(pvobject, &LibLVMpvType);
+	if (pvobj) {
+		pvobj->pv = NULL;
+		pvobj->parent_vgobj = NULL;
+		pvobj->parent_pvslistobj = NULL;
+	}
+	return pvobj;
+}
+
+static vgobject
+*create_py_vg(void)
+{
+	vgobject *vgobj = PyObject_New(vgobject, &LibLVMvgType);
+	if (vgobj) {
+		vgobj->vg = NULL;
+	}
+	return vgobj;
+}
+
 static PyObject *
 liblvm_get_last_error(void)
 {
@@ -179,7 +204,7 @@ liblvm_lvm_pvlist_get(pvslistobject *pvsobj)
 
 	dm_list_iterate_items(pvl, pvsobj->pvslist) {
 		/* Create and initialize the object */
-		pvobj = PyObject_New(pvobject, &LibLVMpvType);
+		pvobj = create_py_pv();
 		if (!pvobj) {
 			Py_DECREF(pytuple);
 			return NULL;
@@ -434,7 +459,7 @@ liblvm_lvm_vg_open(PyObject *self, PyObject *args)
 	if (mode == NULL)
 		mode = "r";
 
-	if ((vgobj = PyObject_New(vgobject, &LibLVMvgType)) == NULL)
+	if ((vgobj = create_py_vg()) == NULL)
 		return NULL;
 
 	if ((vgobj->vg = lvm_vg_open(libh, vgname, mode, 0))== NULL) {
@@ -458,7 +483,7 @@ liblvm_lvm_vg_create(PyObject *self, PyObject *args)
 		return NULL;
 	}
 
-	if ((vgobj = PyObject_New(vgobject, &LibLVMvgType)) == NULL)
+	if ((vgobj = create_py_vg()) == NULL)
 		return NULL;
 
 	if ((vgobj->vg = lvm_vg_create(libh, vgname))== NULL) {
@@ -474,8 +499,10 @@ static void
 liblvm_vg_dealloc(vgobject *self)
 {
 	/* if already closed, don't reclose it */
-	if (self->vg != NULL)
+	if (self->vg != NULL) {
 		lvm_vg_close(self->vg);
+		self->vg = NULL;
+	}
 	PyObject_Del(self);
 }
 
@@ -822,9 +849,8 @@ liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 			goto bail;
 		}
 
-		/* Based on cursory code inspection this path may cause a memory
-		   leak when calling into set_property, need to verify*/
-		string_value = strdup(PyString_AsString(variant_type_arg));
+		string_value = PyString_AsString(variant_type_arg);
+
 		lvm_property.value.string = string_value;
 		if (!lvm_property.value.string) {
 			PyErr_NoMemory();
@@ -853,7 +879,9 @@ liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 
 			lvm_property.value.integer = temp_py_int;
 		} else if (PyObject_IsInstance(variant_type_arg, (PyObject*)&PyLong_Type)){
-			/* This will fail on negative numbers */
+			/* If PyLong_AsUnsignedLongLong function fails an OverflowError is
+			 * raised and (unsigned long long)-1 is returned
+			 */
 			unsigned long long temp_py_long = PyLong_AsUnsignedLongLong(variant_type_arg);
 			if (temp_py_long == (unsigned long long)-1) {
 				goto bail;
@@ -874,18 +902,12 @@ liblvm_lvm_vg_set_property(vgobject *self, PyObject *args)
 		goto lvmerror;
 	}
 
-	Py_DECREF(variant_type_arg);
 	Py_INCREF(Py_None);
 	return Py_None;
 
 lvmerror:
 	PyErr_SetObject(LibLVMError, liblvm_get_last_error());
 bail:
-	free(string_value);
-	if (variant_type_arg) {
-		Py_DECREF(variant_type_arg);
-		variant_type_arg = NULL;
-	}
 	return NULL;
 }
 
@@ -1167,7 +1189,7 @@ liblvm_lvm_vg_list_pvs(vgobject *self)
 
 	dm_list_iterate_items(pvl, pvs) {
 		/* Create and initialize the object */
-		pvobj = PyObject_New(pvobject, &LibLVMpvType);
+		pvobj = create_py_pv();
 		if (!pvobj) {
 			Py_DECREF(pytuple);
 			return NULL;
@@ -1247,7 +1269,7 @@ liblvm_lvm_pv_from_N(vgobject *self, PyObject *arg, pv_fetch_by_N method)
 		return NULL;
 	}
 
-	rc = PyObject_New(pvobject, &LibLVMpvType);
+	rc = create_py_pv();
 	if (!rc) {
 		return NULL;
 	}
diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index fdeca75..c4d7983 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -76,14 +76,13 @@ class TestLvm(unittest.TestCase):
 		self.assertEqual(type(pv.getUuid()), str)
 		self.assertTrue(len(pv.getUuid()) > 0)
 
-		self.assertEqual(type(pv.getMdaCount()), int)
-		self.assertEqual(type(pv.getMdaCount()), int)
+		self.assertTrue(type(pv.getMdaCount()) == int or type(pv.getMdaCount()) == long )
 
-		self.assertEqual(type(pv.getSize()), int)
+		self.assertTrue(type(pv.getSize()) == int or type(pv.getSize()) == long)
 
-		self.assertEqual(type(pv.getDevSize()), int)
+		self.assertTrue(type(pv.getDevSize()) == int or type(pv.getSize()) == long)
 
-		self.assertEqual(type(pv.getFree()), int)
+		self.assertTrue(type(pv.getFree()) == int or type(pv.getFree()) == long)
 
 	def _test_prop(self, prop_obj, prop, var_type, settable):
 		result = prop_obj.getProperty(prop)
@@ -327,7 +326,7 @@ class TestLvm(unittest.TestCase):
 			for method_name in TestLvm.RETURN_NUMERIC:
 				method = getattr(vg, method_name)
 				result = method()
-				self.assertTrue(type(result) == int)
+				self.assertTrue(type(result) == int or type(result)== long)
 
 			vg.close()
 
@@ -372,4 +371,4 @@ class TestLvm(unittest.TestCase):
 			vg.close()
 
 if __name__ == "__main__":
-	unittest.main()
\ No newline at end of file
+	unittest.main()


