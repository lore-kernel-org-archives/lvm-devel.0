From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Apr 2015 15:54:35 +0000 (UTC)
Subject: master - python: Make lv addTag/removeTag persistent
Message-ID: <20150410155435.DE2AD60972@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b557b595a52782458b0d217d2ca114c7f8c62c7
Commit:        2b557b595a52782458b0d217d2ca114c7f8c62c7
Parent:        394250ef6759243e59de41dd6cfced544c041c76
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Apr 7 15:25:20 2015 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Apr 10 10:38:43 2015 -0500

python: Make lv addTag/removeTag persistent

Added lvm_vg_write in the addTag/removeTag paths to make the
changes persist.  Added unit test to ensure functionality.

https://bugzilla.redhat.com/show_bug.cgi?id=1210020

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 python/liblvm.c             |   27 ++++++++----
 test/api/pytest.sh          |    1 +
 test/api/python_lvm_unit.py |   94 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 113 insertions(+), 9 deletions(-)

diff --git a/python/liblvm.c b/python/liblvm.c
index 3828f27..74d65ea 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1444,13 +1444,18 @@ static PyObject *_liblvm_lvm_lv_add_tag(lvobject *self, PyObject *args)
 	if (!PyArg_ParseTuple(args, "s", &tag))
 		return NULL;
 
-	if (lvm_lv_add_tag(self->lv, tag) == -1) {
-		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		return NULL;
-	}
+	if (lvm_lv_add_tag(self->lv, tag) == -1)
+        goto error;
+
+    if (lvm_vg_write(self->parent_vgobj->vg) == -1)
+		goto error;
 
 	Py_INCREF(Py_None);
 	return Py_None;
+
+error:
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+	return NULL;
 }
 
 static PyObject *_liblvm_lvm_lv_remove_tag(lvobject *self, PyObject *args)
@@ -1462,14 +1467,18 @@ static PyObject *_liblvm_lvm_lv_remove_tag(lvobject *self, PyObject *args)
 	if (!PyArg_ParseTuple(args, "s", &tag))
 		return NULL;
 
-	if (lvm_lv_remove_tag(self->lv, tag) == -1) {
-		PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
-		return NULL;
-	}
+	if (lvm_lv_remove_tag(self->lv, tag) == -1)
+        goto error;
 
-	Py_INCREF(Py_None);
+    if (lvm_vg_write(self->parent_vgobj->vg) == -1)
+        goto error;
 
+	Py_INCREF(Py_None);
 	return Py_None;
+
+error:
+	PyErr_SetObject(_LibLVMError, _liblvm_get_last_error());
+	return NULL;
 }
 
 static PyObject *_liblvm_lvm_lv_get_tags(lvobject *self)
diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 36f55fa..00ab051 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -45,6 +45,7 @@ export PY_UNIT_PVS=$(cat DEVICES)
 #python_lvm_unit.py -v -f
 
 # Run individual tests for shorter error trace
+python_lvm_unit.py -v TestLvm.test_lv_persistence
 python_lvm_unit.py -v TestLvm.test_config_find_bool
 python_lvm_unit.py -v TestLvm.test_config_override
 python_lvm_unit.py -v TestLvm.test_config_reload
diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index 2f22fae..424e4ce 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -368,6 +368,100 @@ class TestLvm(unittest.TestCase):
 		lv.rename(current_name)
 		vg.close()
 
+	def test_lv_persistence(self):
+		# Make changes to the lv, close the vg and re-open to make sure that
+		# the changes persist
+		lv_name = 'lv_test_persist'
+		TestLvm._create_thick_lv(TestLvm._get_pv_device_names(), lv_name)
+
+		# Test rename
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		current_name = lv.getName()
+		new_name = rs()
+		lv.rename(new_name)
+
+		vg.close()
+		vg = None
+
+		lv, vg = TestLvm._get_lv(None, new_name)
+
+		self.assertTrue(lv is not None)
+
+		if lv and vg:
+			lv.rename(lv_name)
+			vg.close()
+			vg = None
+
+		# Test lv tag add
+		tag = 'hello_world'
+
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		lv.addTag(tag)
+		vg.close()
+		vg = None
+
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		tags = lv.getTags()
+
+		self.assertTrue(tag in tags)
+		vg.close()
+		vg = None
+
+		# Test lv tag delete
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		self.assertTrue(lv is not None and vg is not None)
+
+		if lv and vg:
+			tags = lv.getTags()
+
+			for t in tags:
+				lv.removeTag(t)
+
+			vg.close()
+			vg = None
+
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		self.assertTrue(lv is not None and vg is not None)
+
+		if lv and vg:
+			tags = lv.getTags()
+
+			if tags:
+				self.assertEqual(len(tags), 0)
+			vg.close()
+			vg = None
+
+		# Test lv deactivate
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		self.assertTrue(lv is not None and vg is not None)
+
+		if lv and vg:
+			lv.deactivate()
+			vg.close()
+			vg = None
+
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		self.assertTrue(lv is not None and vg is not None)
+		if lv and vg:
+			self.assertFalse(lv.isActive())
+			vg.close()
+			vg = None
+
+		# Test lv activate
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		self.assertTrue(lv is not None and vg is not None)
+		if lv and vg:
+			lv.activate()
+			vg.close()
+			vg = None
+
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		self.assertTrue(lv is not None and vg is not None)
+		if lv and vg:
+			self.assertTrue(lv.isActive())
+			vg.close()
+			vg = None
+
 	def test_lv_snapshot(self):
 
 		thin_lv = 'thin_lv'


