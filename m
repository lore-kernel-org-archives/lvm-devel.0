From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 26 Jul 2013 21:47:33 +0000 (UTC)
Subject: master - python unit test: White space/pep8 cleanup
Message-ID: <20130726214733.17E8360F18@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df6f0f71b10748fb809fa4d04de7541773a83ac3
Commit:        df6f0f71b10748fb809fa4d04de7541773a83ac3
Parent:        46a1202a610e717f5c59db54417eeee022b21e83
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Jul 25 18:24:52 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jul 26 10:24:08 2013 -0500

python unit test: White space/pep8 cleanup

pep8 compliant, except for using tabs instead of
spaces.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/python_lvm_unit.py |   52 +++++++++++++++++++++---------------------
 1 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index 7c1fdc3..cc18dce 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -19,6 +19,7 @@ import lvm
 
 # Set of basic unit tests for the python bindings.
 
+
 def rs(l=10):
 	"""
 	Generate a random string
@@ -29,7 +30,6 @@ def rs(l=10):
 class TestLvm(unittest.TestCase):
 	(FULL_PV, THIN_PV_A, THIN_PV_B, RESIZE_PV) = (0, 1, 2, 3)
 
-
 	def _get_pv_devices(self):
 		rc = []
 		with lvm.listPvs() as pvs:
@@ -46,9 +46,9 @@ class TestLvm(unittest.TestCase):
 		for d in device_list:
 			vg.extend(d)
 
-		#new_extent = 1024 * 1024 * 2
-		#vg.setExtentSize(new_extent)
-		#self.assertEqual(vg.getExtentSize(), new_extent)
+		new_extent = 1024 * 1024 * 2
+		vg.setExtentSize(new_extent)
+		self.assertEqual(vg.getExtentSize(), new_extent)
 
 		vg.createLvLinear('thick_lv', vg.getSize()/2)
 		vg.close()
@@ -98,7 +98,7 @@ class TestLvm(unittest.TestCase):
 			vg.extend(device_list[TestLvm.THIN_PV_A])
 			vg.extend(device_list[TestLvm.THIN_PV_B])
 			vg.createLvThinpool('thin_pool', vg.getSize()/2, 0, 0,
-					lvm.THIN_DISCARDS_PASSDOWN, 1)
+								lvm.THIN_DISCARDS_PASSDOWN, 1)
 			vg.createLvThin('thin_pool', 'thin_lv', vg.getSize()/3)
 			vg.close()
 			vg = None
@@ -207,13 +207,17 @@ class TestLvm(unittest.TestCase):
 		self.assertEqual(type(pv.getUuid()), str)
 		self.assertTrue(len(pv.getUuid()) > 0)
 
-		self.assertTrue(type(pv.getMdaCount()) == int or type(pv.getMdaCount()) == long )
+		self.assertTrue(type(pv.getMdaCount()) == int or
+						type(pv.getMdaCount()) == long)
 
-		self.assertTrue(type(pv.getSize()) == int or type(pv.getSize()) == long)
+		self.assertTrue(type(pv.getSize()) == int or
+						type(pv.getSize()) == long)
 
-		self.assertTrue(type(pv.getDevSize()) == int or type(pv.getSize()) == long)
+		self.assertTrue(type(pv.getDevSize()) == int or
+						type(pv.getSize()) == long)
 
-		self.assertTrue(type(pv.getFree()) == int or type(pv.getFree()) == long)
+		self.assertTrue(type(pv.getFree()) == int or
+						type(pv.getFree()) == long)
 
 		vg.close()
 
@@ -254,9 +258,9 @@ class TestLvm(unittest.TestCase):
 	def testLvActiveInactive(self):
 		lv, vg = self._get_lv_test()
 		lv.deactivate()
-		self.assertTrue(lv.isActive() == False)
+		self.assertTrue(lv.isActive() is False)
 		lv.activate()
-		self.assertTrue(lv.isActive() == True)
+		self.assertTrue(lv.isActive() is True)
 		vg.close()
 
 	def testLvRename(self):
@@ -272,7 +276,7 @@ class TestLvm(unittest.TestCase):
 	def testLvSnapshot(self):
 
 		#Cleanup existing if already present
-		to_remove = [ 'thick_lv_snapshot', 'thin_lv_snapshot']
+		to_remove = ['thick_lv_snapshot', 'thin_lv_snapshot']
 
 		for ss in to_remove:
 			snap, vg = self._get_lv_test(None, ss)
@@ -280,7 +284,6 @@ class TestLvm(unittest.TestCase):
 				snap.remove()
 				vg.close()
 
-
 		thick_lv, vg = self._get_lv_test(None, 'thick_lv')
 
 		self.assertEqual('thick_lv', thick_lv.getName())
@@ -301,7 +304,6 @@ class TestLvm(unittest.TestCase):
 
 		vg.close()
 
-
 	def testLvSuspend(self):
 		lv, vg = self._get_lv_test()
 
@@ -312,7 +314,7 @@ class TestLvm(unittest.TestCase):
 	def testLvSize(self):
 		lv, vg = self._get_lv_test()
 		result = lv.getSize()
-		self.assertTrue(type(result) == int or type(result)== long)
+		self.assertTrue(type(result) == int or type(result) == long)
 		vg.close()
 
 	def testLvResize(self):
@@ -379,9 +381,8 @@ class TestLvm(unittest.TestCase):
 			if len(lvs):
 				lv = lvs[0]
 				lv_name = lv.getName()
-				self.assertRaises(lvm.LibLVMError,
-					vg.createLvLinear, lv_name,
-					lv.getSize())
+				self.assertRaises(lvm.LibLVMError, vg.createLvLinear, lv_name,
+								  lv.getSize())
 
 	def testVgUuids(self):
 		vgs_uuids = lvm.listVgUuids()
@@ -419,10 +420,10 @@ class TestLvm(unittest.TestCase):
 				pv_name_lookup = vg.pvFromName(name)
 				pv_uuid_lookup = vg.pvFromUuid(uuid)
 
-				self.assertTrue(pv_name_lookup.getName() == \
-						pv_uuid_lookup.getName())
-				self.assertTrue(pv_name_lookup.getUuid() == \
-						pv_uuid_lookup.getUuid())
+				self.assertTrue(pv_name_lookup.getName() ==
+								pv_uuid_lookup.getName())
+				self.assertTrue(pv_name_lookup.getUuid() ==
+								pv_uuid_lookup.getUuid())
 
 				self.assertTrue(name == pv_name_lookup.getName())
 				self.assertTrue(uuid == pv_uuid_lookup.getUuid())
@@ -434,7 +435,6 @@ class TestLvm(unittest.TestCase):
 			pvs = None
 			vg.close()
 
-
 	def testPercentToFloat(self):
 		self.assertEqual(lvm.percentToFloat(0), 0.0)
 		self.assertEqual(lvm.percentToFloat(1000000), 1.0)
@@ -486,7 +486,6 @@ class TestLvm(unittest.TestCase):
 			self.assertTrue(len(uuid) > 0)
 			vg.close()
 
-
 	RETURN_NUMERIC = ["getSeqno", "getSize", "getFreeSize", "getFreeSize",
 					  "getExtentSize", "getExtentCount", "getFreeExtentCount",
 					  "getPvCount", "getMaxPv", "getMaxLv"]
@@ -504,7 +503,7 @@ class TestLvm(unittest.TestCase):
 			for method_name in TestLvm.RETURN_NUMERIC:
 				method = getattr(vg, method_name)
 				result = method()
-				self.assertTrue(type(result) == int or type(result)== long)
+				self.assertTrue(type(result) == int or type(result) == long)
 
 			vg.close()
 
@@ -526,7 +525,8 @@ class TestLvm(unittest.TestCase):
 		num_remove = len(created_tags)
 
 		for i in range(num_remove):
-			tag_to_remove = created_tags[random.randint(0, len(created_tags) - 1)]
+			tag_to_remove = created_tags[
+				random.randint(0, len(created_tags) - 1)]
 
 			created_tags.remove(tag_to_remove)
 


