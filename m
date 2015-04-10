From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Apr 2015 15:54:38 +0000 (UTC)
Subject: master - python: Unit test ws fixes
Message-ID: <20150410155438.0E7CD60A54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f29df9acfe430093c07cff06aa302e5e70c07965
Commit:        f29df9acfe430093c07cff06aa302e5e70c07965
Parent:        2b557b595a52782458b0d217d2ca114c7f8c62c7
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Apr 7 15:36:11 2015 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Apr 10 10:52:12 2015 -0500

python: Unit test ws fixes

    pep8 corrections for:
    - mixed leading ws (tabs & spaces)
    - spacing around arithmetic operators

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/python_lvm_unit.py |   85 ++++++++++++++++++++++++-------------------
 1 files changed, 47 insertions(+), 38 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index 424e4ce..455c9e8 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -44,8 +44,8 @@ def rs(rand_len=10):
 	"""
 	Generate a random string
 	"""
-	return ''.join(random.choice(string.ascii_uppercase)
-				   for x in range(rand_len))
+	return ''.join(
+		random.choice(string.ascii_uppercase)for x in range(rand_len))
 
 
 def _get_allowed_devices():
@@ -131,15 +131,15 @@ class TestLvm(unittest.TestCase):
 		for d in device_list:
 			vg.extend(d)
 
-		vg.createLvThinpool(pool_name, vg.getSize()/2, 0, 0,
-				    lvm.THIN_DISCARDS_PASSDOWN, 1)
+		vg.createLvThinpool(
+			pool_name, vg.getSize() / 2, 0, 0, lvm.THIN_DISCARDS_PASSDOWN, 1)
 		return vg
 
 	@staticmethod
 	def _create_thin_lv(pv_devices, name):
 		thin_pool_name = 'thin_vg_pool_' + rs(4)
 		vg = TestLvm._create_thin_pool(pv_devices, thin_pool_name)
-		vg.createLvThin(thin_pool_name, name, vg.getSize()/8)
+		vg.createLvThin(thin_pool_name, name, vg.getSize() / 8)
 		vg.close()
 		vg = None
 
@@ -239,7 +239,7 @@ class TestLvm(unittest.TestCase):
 			curr_size = pv.getSize()
 			dev_size = pv.getDevSize()
 			self.assertTrue(curr_size == dev_size)
-			pv.resize(curr_size/2)
+			pv.resize(curr_size / 2)
 		with AllowedPVS() as pvs:
 			pv = pvs[0]
 			resized_size = pv.getSize()
@@ -298,17 +298,21 @@ class TestLvm(unittest.TestCase):
 			self.assertEqual(type(pv.getUuid()), str)
 			self.assertTrue(len(pv.getUuid()) > 0)
 
-			self.assertTrue(type(pv.getMdaCount()) == int or
-							type(pv.getMdaCount()) == long)
+			self.assertTrue(
+				type(pv.getMdaCount()) == int or
+				type(pv.getMdaCount()) == long)
 
-			self.assertTrue(type(pv.getSize()) == int or
-							type(pv.getSize()) == long)
+			self.assertTrue(
+				type(pv.getSize()) == int or
+				type(pv.getSize()) == long)
 
-			self.assertTrue(type(pv.getDevSize()) == int or
-							type(pv.getSize()) == long)
+			self.assertTrue(
+				type(pv.getDevSize()) == int or
+				type(pv.getSize()) == long)
 
-			self.assertTrue(type(pv.getFree()) == int or
-							type(pv.getFree()) == long)
+			self.assertTrue(
+				type(pv.getFree()) == int or
+				type(pv.getFree()) == long)
 
 	def _test_prop(self, prop_obj, prop, var_type, settable):
 		result = prop_obj.getProperty(prop)
@@ -516,7 +520,7 @@ class TestLvm(unittest.TestCase):
 		lv, vg = TestLvm._get_lv(None, lv_name)
 
 		curr_size = lv.getSize()
-		lv.resize(curr_size+(1024*1024))
+		lv.resize(curr_size + (1024 * 1024))
 		latest = lv.getSize()
 		self.assertTrue(curr_size != latest)
 
@@ -542,8 +546,9 @@ class TestLvm(unittest.TestCase):
 
 		new_extent = 1024 * 1024 * 4
 
-		self.assertFalse(vg.getExtentSize() != new_extent,
-						 "Cannot determine if it works if they are the same")
+		self.assertFalse(
+			vg.getExtentSize() != new_extent,
+			"Cannot determine if it works if they are the same")
 
 		vg.setExtentSize(new_extent)
 		self.assertEqual(vg.getExtentSize(), new_extent)
@@ -602,8 +607,8 @@ class TestLvm(unittest.TestCase):
 			if len(lvs):
 				lv = lvs[0]
 				lv_name = lv.getName()
-				self.assertRaises(lvm.LibLVMError, vg.createLvLinear, lv_name,
-								  lv.getSize())
+				self.assertRaises(
+					lvm.LibLVMError, vg.createLvLinear, lv_name, lv.getSize())
 			vg.close()
 
 	def test_vg_uuids(self):
@@ -653,10 +658,10 @@ class TestLvm(unittest.TestCase):
 				pv_name_lookup = vg.pvFromName(name)
 				pv_uuid_lookup = vg.pvFromUuid(uuid)
 
-				self.assertTrue(pv_name_lookup.getName() ==
-								pv_uuid_lookup.getName())
-				self.assertTrue(pv_name_lookup.getUuid() ==
-								pv_uuid_lookup.getUuid())
+				self.assertTrue(
+					pv_name_lookup.getName() == pv_uuid_lookup.getName())
+				self.assertTrue(
+					pv_name_lookup.getUuid() == pv_uuid_lookup.getUuid())
 
 				self.assertTrue(name == pv_name_lookup.getName())
 				self.assertTrue(uuid == pv_uuid_lookup.getUuid())
@@ -738,9 +743,10 @@ class TestLvm(unittest.TestCase):
 			self.assertTrue(len(uuid) > 0)
 			vg.close()
 
-	RETURN_NUMERIC = ["getSeqno", "getSize", "getFreeSize", "getFreeSize",
-					  "getExtentSize", "getExtentCount", "getFreeExtentCount",
-					  "getPvCount", "getMaxPv", "getMaxLv"]
+	RETURN_NUMERIC = [
+		"getSeqno", "getSize", "getFreeSize", "getFreeSize",
+		"getExtentSize", "getExtentCount", "getFreeExtentCount",
+		"getPvCount", "getMaxPv", "getMaxLv"]
 
 	def test_vg_getters(self):
 		device_names = TestLvm._get_pv_device_names()
@@ -804,7 +810,7 @@ class TestLvm(unittest.TestCase):
 		i = 0
 		for d in device_names:
 			if i % 2 == 0:
-				TestLvm._create_thin_lv([d],  "thin_lv%d" % i)
+				TestLvm._create_thin_lv([d], "thin_lv%d" % i)
 			else:
 				TestLvm._create_thick_lv([d], "thick_lv%d" % i)
 			i += 1
@@ -854,7 +860,7 @@ class TestLvm(unittest.TestCase):
 			lvm.pvCreate(d)
 
 	def test_pv_create(self):
-		size = [0, 1024*1024*4]
+		size = [0, 1024 * 1024 * 4]
 		pvmeta_copies = [0, 1, 2]
 		pvmeta_size = [0, 255, 512, 1024]
 		data_alignment = [0, 2048, 4096]
@@ -873,9 +879,9 @@ class TestLvm(unittest.TestCase):
 		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, '')
 		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, d, 4)
 		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, d, 0, 4)
-		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, d, 0, 0, 0, 2**34)
-		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, d, 0, 0, 0, 4096,
-						  2**34)
+		self.assertRaises(lvm.LibLVMError, lvm.pvCreate, d, 0, 0, 0, 2 ** 34)
+		self.assertRaises(
+			lvm.LibLVMError, lvm.pvCreate, d, 0, 0, 0, 4096, 2 ** 34)
 
 		#Try a number of combinations and permutations
 		for s in size:
@@ -891,12 +897,14 @@ class TestLvm(unittest.TestCase):
 						lvm.pvCreate(d, s, copies, pv_size, align)
 						lvm.pvRemove(d)
 						for align_offset in data_alignment_offset:
-							lvm.pvCreate(d, s, copies, pv_size, align,
-										 align * align_offset)
+							lvm.pvCreate(
+								d, s, copies, pv_size, align,
+								align * align_offset)
 							lvm.pvRemove(d)
 							for z in zero:
-								lvm.pvCreate(d, s, copies, pv_size, align,
-											 align * align_offset, z)
+								lvm.pvCreate(
+									d, s, copies, pv_size, align,
+									align * align_offset, z)
 								lvm.pvRemove(d)
 
 		#Restore
@@ -960,7 +968,7 @@ class TestLvm(unittest.TestCase):
 				method(t)
 
 	def _test_bad_names(self, method, dupe_name):
-		 # Test for duplicate name
+		# Test for duplicate name
 		self.assertRaises(lvm.LibLVMError, method, dupe_name)
 
 		# Test for too long a name
@@ -983,8 +991,9 @@ class TestLvm(unittest.TestCase):
 
 	def _lv_reserved_names(self, method):
 		prefixes = ['snapshot', 'pvmove']
-		reserved = ['_mlog', '_mimage', '_pmspare', '_rimage', '_rmeta',
-					'_vorigin', '_tdata', '_tmeta']
+		reserved = [
+			'_mlog', '_mimage', '_pmspare', '_rimage', '_rmeta',
+			'_vorigin', '_tdata', '_tmeta']
 
 		for p in prefixes:
 			self.assertRaises(lvm.LibLVMError, method, p + rs(3))


