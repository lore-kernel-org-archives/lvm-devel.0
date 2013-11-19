From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:50 +0000 (UTC)
Subject: master - python_lvm_unit.py: Clean-up method names & scope
Message-ID: <20131119205650.14D4560D14@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=370520a310a44e6b9a48d9507bf2136748093029
Commit:        370520a310a44e6b9a48d9507bf2136748093029
Parent:        12d5e53953f1dacd911190cacc153dc2343878fe
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Nov 18 15:07:32 2013 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:40:45 2013 -0600

python_lvm_unit.py: Clean-up method names & scope

Changed naming of methods from camel case to all lower case with
underscores per guidelines.  Changed any methods that can be
static methods to static.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/python_lvm_unit.py |  300 +++++++++++++++++++++++--------------------
 1 files changed, 158 insertions(+), 142 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index 6c13149..fc8c198 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -39,11 +39,12 @@ def l(txt):
 		fh.flush()
 
 
-def rs(l=10):
+def rs(rand_len=10):
 	"""
 	Generate a random string
 	"""
-	return ''.join(random.choice(string.ascii_uppercase) for x in range(l))
+	return ''.join(random.choice(string.ascii_uppercase)
+				   for x in range(rand_len))
 
 
 def _get_allowed_devices():
@@ -54,9 +55,9 @@ def _get_allowed_devices():
 	return rc
 
 
-def compare_pv(r, l):
-	r_name = r.getName()
-	l_name = l.getName()
+def compare_pv(right, left):
+	r_name = right.getName()
+	l_name = left.getName()
 
 	if r_name > l_name:
 		return 1
@@ -74,6 +75,7 @@ class AllowedPVS(object):
 
 	def __init__(self):
 		self.handle = None
+		self.pvs_all = None
 
 	def __enter__(self):
 		rc = []
@@ -102,24 +104,27 @@ class TestLvm(unittest.TestCase):
 
 	VG_P = 'py_unit_test_'
 
-	def _get_pv_device_names(self):
+	@staticmethod
+	def _get_pv_device_names():
 		rc = []
 		with AllowedPVS() as pvs:
 			for p in pvs:
 				rc.append(p.getName())
 		return rc
 
-	def _createThickLV(self, device_list, name):
+	@staticmethod
+	def _create_thick_lv(device_list, name):
 		vg = lvm.vgCreate(TestLvm.VG_P + "_" + name)
 
 		for d in device_list:
 			vg.extend(d)
 
-		vg.createLvLinear(name, vg.getSize()/2)
+		vg.createLvLinear(name, vg.getSize() / 2)
 		vg.close()
 		vg = None
 
-	def _createThinPool(self, device_list, pool_name):
+	@staticmethod
+	def _create_thin_pool(device_list, pool_name):
 		vg = lvm.vgCreate(TestLvm.VG_P + "_" + pool_name)
 
 		for d in device_list:
@@ -129,14 +134,16 @@ class TestLvm(unittest.TestCase):
 							lvm.THIN_DISCARDS_PASSDOWN, 1)
 		return vg
 
-	def _createThinLV(self, pv_devices, name):
+	@staticmethod
+	def _create_thin_lv(pv_devices, name):
 		thin_pool_name = 'thin_vg_pool_' + rs(4)
-		vg = self._createThinPool(pv_devices, thin_pool_name)
+		vg = TestLvm._create_thin_pool(pv_devices, thin_pool_name)
 		vg.createLvThin(thin_pool_name, name, vg.getSize()/8)
 		vg.close()
 		vg = None
 
-	def _vg_names(self):
+	@staticmethod
+	def _vg_names():
 		rc = []
 		vg_names = lvm.listVgNames()
 
@@ -146,25 +153,27 @@ class TestLvm(unittest.TestCase):
 
 		return rc
 
-	def _get_lv(self, lv_vol_type=None, lv_name=None):
-		vg_name_list = self._vg_names()
+	@staticmethod
+	def _get_lv(lv_vol_type=None, lv_name=None):
+		vg_name_list = TestLvm._vg_names()
 		for vg_name in vg_name_list:
 			vg = lvm.vgOpen(vg_name, "w")
 			lvs = vg.listLVs()
 
-			for l in lvs:
-				attr = l.getAttr()
+			for lv in lvs:
+				attr = lv.getAttr()
 				if lv_vol_type or lv_name:
 					if lv_vol_type is not None and attr[0] == lv_vol_type:
-						return l, vg
-					elif lv_name is not None and lv_name == l.getName():
-						return l, vg
+						return lv, vg
+					elif lv_name is not None and lv_name == lv.getName():
+						return lv, vg
 				else:
-					return l, vg
+					return lv, vg
 			vg.close()
 		return None, None
 
-	def _remove_VG(self, vg_name):
+	@staticmethod
+	def _remove_vg(vg_name):
 		vg = lvm.vgOpen(vg_name, 'w')
 
 		pvs = vg.listPVs()
@@ -172,26 +181,26 @@ class TestLvm(unittest.TestCase):
 		pe_devices = []
 
 		#Remove old snapshots first, then lv
-		for l in vg.listLVs():
-			attr = l.getAttr()
+		for lv in vg.listLVs():
+			attr = lv.getAttr()
 			if attr[0] == 's':
-				l.remove()
+				lv.remove()
 
 		lvs = vg.listLVs()
 
 		#Now remove any thin lVs
-		for l in vg.listLVs():
-			attr = l.getAttr()
+		for lv in vg.listLVs():
+			attr = lv.getAttr()
 			if attr[0] == 'V':
-				l.remove()
+				lv.remove()
 
 		#now remove the rest
-		for l in vg.listLVs():
-			name = l.getName()
+		for lv in vg.listLVs():
+			name = lv.getName()
 
 			#Don't remove the hidden ones
-			if 'tmeta' not in name and 'tdata' not in name:
-				l.remove()
+			if '_tmeta' not in name and '_tdata' not in name:
+				lv.remove()
 
 		for p in pvs:
 			pe_devices.append(p.getName())
@@ -202,23 +211,28 @@ class TestLvm(unittest.TestCase):
 		vg.remove()
 		vg.close()
 
-	def _clean_up(self):
+	@staticmethod
+	def _clean_up():
 		#Clear out the testing PVs, but only if they contain stuff
 		#this unit test created
-		for vg_n in self._vg_names():
-			self._remove_VG(vg_n)
+		for vg_n in TestLvm._vg_names():
+			TestLvm._remove_vg(vg_n)
+
+		for d in TestLvm._get_pv_device_names():
+			lvm.pvRemove(d)
+			lvm.pvCreate(d)
 
 	def setUp(self):
-		device_list = self._get_pv_device_names()
+		device_list = TestLvm._get_pv_device_names()
 
 		#Make sure we have an adequate number of PVs to use
 		self.assertTrue(len(device_list) >= 4)
-		self._clean_up()
+		TestLvm._clean_up()
 
 	def tearDown(self):
-		self._clean_up()
+		TestLvm._clean_up()
 
-	def testPVresize(self):
+	def test_pv_resize(self):
 		with AllowedPVS() as pvs:
 			pv = pvs[0]
 			curr_size = pv.getSize()
@@ -231,7 +245,7 @@ class TestLvm(unittest.TestCase):
 			self.assertTrue(resized_size != curr_size)
 			pv.resize(dev_size)
 
-	def testPVlifecycle(self):
+	def test_pv_life_cycle(self):
 		"""
 		Test removing and re-creating a PV
 		"""
@@ -256,7 +270,8 @@ class TestLvm(unittest.TestCase):
 
 		self.assertTrue(found)
 
-	def testPvMethods(self):
+	@staticmethod
+	def test_pv_methods():
 		with AllowedPVS() as pvs:
 			for p in pvs:
 				p.getName()
@@ -267,13 +282,13 @@ class TestLvm(unittest.TestCase):
 				p.getFree()
 				p = None
 
-	def testVersion(self):
+	def test_version(self):
 		version = lvm.getVersion()
 		self.assertNotEquals(version, None)
 		self.assertEquals(type(version), str)
 		self.assertTrue(len(version) > 0)
 
-	def testPvGetters(self):
+	def test_pv_getters(self):
 		with AllowedPVS() as pvs:
 			pv = pvs[0]
 			self.assertEqual(type(pv.getName()), str)
@@ -301,7 +316,7 @@ class TestLvm(unittest.TestCase):
 		self.assertEqual(type(result[1]), bool)
 		self.assertTrue(result[1] == settable)
 
-	def testPvSegs(self):
+	def test_pv_segs(self):
 		with AllowedPVS() as pvs:
 			pv = pvs[0]
 			pv_segs = pv.listPVsegs()
@@ -311,39 +326,39 @@ class TestLvm(unittest.TestCase):
 			for i in pv_segs:
 				self._test_prop(i, 'pvseg_start', long, False)
 
-	def testPvProperty(self):
+	def test_pv_property(self):
 		with AllowedPVS() as pvs:
 			pv = pvs[0]
 			self._test_prop(pv, 'pv_mda_count', long, False)
 
-	def testLvProperty(self):
+	def test_lv_property(self):
 		lv_name = 'lv_test'
-		self._createThinLV(self._get_pv_device_names(), lv_name)
-		lv, vg = self._get_lv(None, lv_name)
+		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
+		lv, vg = TestLvm._get_lv(None, lv_name)
 		self._test_prop(lv, 'seg_count', long, False)
 		vg.close()
 
-	def testLvTags(self):
+	def test_lv_tags(self):
 		lv_name = 'lv_test'
-		self._createThinLV(self._get_pv_device_names(), lv_name)
-		lv, vg = self._get_lv(None, lv_name)
-		self._testTags(lv)
+		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
+		lv, vg = TestLvm._get_lv(None, lv_name)
+		self._test_tags(lv)
 		vg.close()
 
-	def testLvActiveInactive(self):
+	def test_lv_active_inactive(self):
 		lv_name = 'lv_test'
-		self._createThinLV(self._get_pv_device_names(), lv_name)
-		lv, vg = self._get_lv(None, lv_name)
+		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
+		lv, vg = TestLvm._get_lv(None, lv_name)
 		lv.deactivate()
 		self.assertTrue(lv.isActive() is False)
 		lv.activate()
 		self.assertTrue(lv.isActive() is True)
 		vg.close()
 
-	def testLvRename(self):
+	def test_lv_rename(self):
 		lv_name = 'lv_test'
-		self._createThinLV(self._get_pv_device_names(), lv_name)
-		lv, vg = self._get_lv(None, lv_name)
+		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
+		lv, vg = TestLvm._get_lv(None, lv_name)
 
 		current_name = lv.getName()
 		new_name = rs()
@@ -352,29 +367,29 @@ class TestLvm(unittest.TestCase):
 		lv.rename(current_name)
 		vg.close()
 
-	def testLvSnapshot(self):
+	def test_lv_snapshot(self):
 
 		thin_lv = 'thin_lv'
 		thick_lv = 'thick_lv'
 
-		device_names = self._get_pv_device_names()
+		device_names = TestLvm._get_pv_device_names()
 
-		self._createThinLV(device_names[0:2], thin_lv)
-		self._createThickLV(device_names[2:4], thick_lv)
+		TestLvm._create_thin_lv(device_names[0:2], thin_lv)
+		TestLvm._create_thick_lv(device_names[2:4], thick_lv)
 
-		lv, vg = self._get_lv(None, thick_lv)
+		lv, vg = TestLvm._get_lv(None, thick_lv)
 		lv.snapshot('thick_snap_shot', 1024*1024)
 		vg.close()
 
-		thick_ss, vg = self._get_lv(None, 'thick_snap_shot')
+		thick_ss, vg = TestLvm._get_lv(None, 'thick_snap_shot')
 		self.assertTrue(thick_ss is not None)
 		vg.close()
 
-		thin_lv, vg = self._get_lv(None, thin_lv)
+		thin_lv, vg = TestLvm._get_lv(None, thin_lv)
 		thin_lv.snapshot('thin_snap_shot')
 		vg.close()
 
-		thin_ss, vg = self._get_lv(None, 'thin_snap_shot')
+		thin_ss, vg = TestLvm._get_lv(None, 'thin_snap_shot')
 		self.assertTrue(thin_ss is not None)
 
 		origin = thin_ss.getOrigin()
@@ -382,38 +397,38 @@ class TestLvm(unittest.TestCase):
 
 		vg.close()
 
-	def testLvSuspend(self):
+	def test_lv_suspend(self):
 		lv_name = 'lv_test'
-		self._createThinLV(self._get_pv_device_names(), lv_name)
-		lv, vg = self._get_lv(None, lv_name)
+		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
+		lv, vg = TestLvm._get_lv(None, lv_name)
 
 		result = lv.isSuspended()
 		self.assertTrue(type(result) == bool)
 		vg.close()
 
-	def testLvSize(self):
+	def test_lv_size(self):
 		lv_name = 'lv_test'
-		self._createThinLV(self._get_pv_device_names(), lv_name)
-		lv, vg = self._get_lv(None, lv_name)
+		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
+		lv, vg = TestLvm._get_lv(None, lv_name)
 
 		result = lv.getSize()
 		self.assertTrue(type(result) == int or type(result) == long)
 		vg.close()
 
-	def testLvResize(self):
+	def test_lv_resize(self):
 		lv_name = 'lv_test'
-		self._createThinLV(self._get_pv_device_names(), lv_name)
-		lv, vg = self._get_lv(None, lv_name)
+		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
+		lv, vg = TestLvm._get_lv(None, lv_name)
 
 		curr_size = lv.getSize()
 		lv.resize(curr_size+(1024*1024))
 		latest = lv.getSize()
 		self.assertTrue(curr_size != latest)
 
-	def testLvSeg(self):
+	def test_lv_seg(self):
 		lv_name = 'lv_test'
-		self._createThinLV(self._get_pv_device_names(), lv_name)
-		lv, vg = self._get_lv(None, lv_name)
+		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
+		lv, vg = TestLvm._get_lv(None, lv_name)
 
 		lv_segs = lv.listLVsegs()
 
@@ -424,11 +439,11 @@ class TestLvm(unittest.TestCase):
 
 		vg.close()
 
-	def testGetSetExtentSize(self):
+	def test_get_set_extend_size(self):
 		thick_lv = 'get_set_prop'
-		device_names = self._get_pv_device_names()
-		self._createThickLV(device_names[0:2], thick_lv)
-		lv, vg = self._get_lv(None, thick_lv)
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thick_lv(device_names[0:2], thick_lv)
+		lv, vg = TestLvm._get_lv(None, thick_lv)
 
 		new_extent = 1024 * 1024 * 4
 
@@ -439,11 +454,11 @@ class TestLvm(unittest.TestCase):
 		self.assertEqual(vg.getExtentSize(), new_extent)
 		vg.close()
 
-	def testVGsetGetProp(self):
+	def test_vg_get_set_prop(self):
 		thick_lv = 'get_set_prop'
-		device_names = self._get_pv_device_names()
-		self._createThickLV(device_names[0:2], thick_lv)
-		lv, vg = self._get_lv(None, thick_lv)
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thick_lv(device_names[0:2], thick_lv)
+		lv, vg = TestLvm._get_lv(None, thick_lv)
 
 		self.assertTrue(vg is not None)
 		if vg:
@@ -451,14 +466,14 @@ class TestLvm(unittest.TestCase):
 			vg.setProperty('vg_mda_copies', vg_mda_copies[0])
 			vg.close()
 
-	def testVGremoveRestore(self):
+	def test_vg_remove_restore(self):
 		#Store off the list of physical devices
 		pv_devices = []
 
 		thick_lv = 'get_set_prop'
-		device_names = self._get_pv_device_names()
-		self._createThickLV(device_names[0:2], thick_lv)
-		lv, vg = self._get_lv(None, thick_lv)
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thick_lv(device_names[0:2], thick_lv)
+		lv, vg = TestLvm._get_lv(None, thick_lv)
 
 		vg_name = vg.getName()
 
@@ -467,22 +482,22 @@ class TestLvm(unittest.TestCase):
 			pv_devices.append(p.getName())
 		vg.close()
 
-		self._remove_VG(vg_name)
-		self._createThickLV(pv_devices, thick_lv)
+		TestLvm._remove_vg(vg_name)
+		self._create_thick_lv(pv_devices, thick_lv)
 
-	def testVgNames(self):
+	def test_vg_names(self):
 		vg = lvm.listVgNames()
 		self.assertTrue(isinstance(vg, tuple))
 
-	def testDupeLvCreate(self):
+	def test_dupe_lv_create(self):
 		"""
 		Try to create a lv with the same name expecting a failure
 		Note: This was causing a seg. fault previously
 		"""
 		thick_lv = 'dupe_name'
-		device_names = self._get_pv_device_names()
-		self._createThickLV(device_names[0:2], thick_lv)
-		lv, vg = self._get_lv(None, thick_lv)
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thick_lv(device_names[0:2], thick_lv)
+		lv, vg = TestLvm._get_lv(None, thick_lv)
 
 		self.assertTrue(vg is not None)
 
@@ -496,11 +511,11 @@ class TestLvm(unittest.TestCase):
 								  lv.getSize())
 			vg.close()
 
-	def testVgUuids(self):
+	def test_vg_uuids(self):
 
-		device_names = self._get_pv_device_names()
-		self._createThinLV(device_names[0:2], 'thin')
-		self._createThickLV(device_names[2:4], 'thick')
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thin_lv(device_names[0:2], 'thin')
+		TestLvm._create_thick_lv(device_names[2:4], 'thick')
 
 		vgs_uuids = lvm.listVgUuids()
 
@@ -523,12 +538,12 @@ class TestLvm(unittest.TestCase):
 
 		self.assertTrue(len(vgs_uuids) == 0)
 
-	def testPvLookupFromVG(self):
-		device_names = self._get_pv_device_names()
-		self._createThinLV(device_names[0:2], 'thin')
-		self._createThickLV(device_names[2:4], 'thick')
+	def test_pv_lookup_from_vg(self):
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thin_lv(device_names[0:2], 'thin')
+		TestLvm._create_thick_lv(device_names[2:4], 'thick')
 
-		vg_names = self._vg_names()
+		vg_names = TestLvm._vg_names()
 
 		self.assertTrue(len(vg_names) > 0)
 
@@ -558,31 +573,31 @@ class TestLvm(unittest.TestCase):
 			pvs = None
 			vg.close()
 
-	def testPercentToFloat(self):
+	def test_percent_to_float(self):
 		self.assertEqual(lvm.percentToFloat(0), 0.0)
 		self.assertEqual(lvm.percentToFloat(1000000), 1.0)
 		self.assertEqual(lvm.percentToFloat(1000000 / 2), 0.5)
 
-	def testScan(self):
+	def test_scan(self):
 		self.assertEqual(lvm.scan(), None)
 
-	def testConfigReload(self):
+	def test_config_reload(self):
 		self.assertEqual(lvm.configReload(), None)
 
-	def testConfig_override(self):
+	def test_config_override(self):
 		self.assertEquals(lvm.configOverride("global.test = 1"), None)
 
-	def testConfigFindBool(self):
+	def test_config_find_bool(self):
 		either_or = lvm.configFindBool("global/fallback_to_local_locking")
 		self.assertTrue(type(either_or) == bool)
 		self.assertTrue(lvm.configFindBool("global/locking_type"))
 
-	def testVgFromPVLookups(self):
-		device_names = self._get_pv_device_names()
-		self._createThinLV(device_names[0:2], 'thin')
-		self._createThickLV(device_names[2:4], 'thick')
+	def test_vg_from_pv_lookups(self):
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thin_lv(device_names[0:2], 'thin')
+		TestLvm._create_thick_lv(device_names[2:4], 'thick')
 
-		vgname_list = self._vg_names()
+		vgname_list = TestLvm._vg_names()
 
 		self.assertTrue(len(vgname_list) > 0)
 
@@ -598,12 +613,12 @@ class TestLvm(unittest.TestCase):
 				self.assertEqual(vg_name, lvm.vgNameFromDevice(pv.getName()))
 			vg.close()
 
-	def testVgGetName(self):
-		device_names = self._get_pv_device_names()
-		self._createThinLV(device_names[0:2], 'thin')
-		self._createThickLV(device_names[2:4], 'thick')
+	def test_vg_get_name(self):
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thin_lv(device_names[0:2], 'thin')
+		TestLvm._create_thick_lv(device_names[2:4], 'thick')
 
-		vgname_list = self._vg_names()
+		vgname_list = TestLvm._vg_names()
 
 		self.assertTrue(len(vgname_list) > 0)
 
@@ -612,12 +627,12 @@ class TestLvm(unittest.TestCase):
 			self.assertEqual(vg.getName(), vg_name)
 			vg.close()
 
-	def testVgGetUuid(self):
-		device_names = self._get_pv_device_names()
-		self._createThinLV(device_names[0:2], 'thin')
-		self._createThickLV(device_names[2:4], 'thick')
+	def test_vg_get_uuid(self):
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thin_lv(device_names[0:2], 'thin')
+		TestLvm._create_thick_lv(device_names[2:4], 'thick')
 
-		vgname_list = self._vg_names()
+		vgname_list = TestLvm._vg_names()
 
 		self.assertTrue(len(vgname_list) > 0)
 
@@ -632,12 +647,12 @@ class TestLvm(unittest.TestCase):
 					  "getExtentSize", "getExtentCount", "getFreeExtentCount",
 					  "getPvCount", "getMaxPv", "getMaxLv"]
 
-	def testVgGetters(self):
-		device_names = self._get_pv_device_names()
-		self._createThinLV(device_names[0:2], 'thin')
-		self._createThickLV(device_names[2:4], 'thick')
+	def test_vg_getters(self):
+		device_names = TestLvm._get_pv_device_names()
+		TestLvm._create_thin_lv(device_names[0:2], 'thin')
+		TestLvm._create_thick_lv(device_names[2:4], 'thick')
 
-		vg_name_list = self._vg_names()
+		vg_name_list = TestLvm._vg_names()
 
 		self.assertTrue(len(vg_name_list) > 0)
 
@@ -655,7 +670,7 @@ class TestLvm(unittest.TestCase):
 
 			vg.close()
 
-	def _testTags(self, tag_obj):
+	def _test_tags(self, tag_obj):
 		existing_tags = tag_obj.getTags()
 		self.assertTrue(type(existing_tags) == tuple)
 
@@ -688,23 +703,24 @@ class TestLvm(unittest.TestCase):
 		for e in existing_tags:
 			self.assertTrue(e in current_tags)
 
-	def testVgTags(self):
-		device_names = self._get_pv_device_names()
+	def test_vg_tags(self):
+		device_names = TestLvm._get_pv_device_names()
 
 		i = 0
 		for d in device_names:
 			if i % 2 == 0:
-				self._createThinLV([d],  "thin_lv%d" % i)
+				TestLvm._create_thin_lv([d],  "thin_lv%d" % i)
 			else:
-				self._createThickLV([d], "thick_lv%d" % i)
+				TestLvm._create_thick_lv([d], "thick_lv%d" % i)
 			i += 1
 
-		for vg_name in self._vg_names():
+		for vg_name in TestLvm._vg_names():
 			vg = lvm.vgOpen(vg_name, 'w')
-			self._testTags(vg)
+			self._test_tags(vg)
 			vg.close()
 
-	def testListing(self):
+	@staticmethod
+	def test_listing():
 
 		env = os.environ
 
@@ -719,12 +735,12 @@ class TestLvm(unittest.TestCase):
 		for v in lvm.listVgNames():
 			l('vg= %s' % v)
 
-	def testPVemptylisting(self):
+	def test_pv_empty_listing(self):
 		#We had a bug where we would seg. fault if we had no PVs.
 
 		l('testPVemptylisting entry')
 
-		device_names = self._get_pv_device_names()
+		device_names = TestLvm._get_pv_device_names()
 
 		for d in device_names:
 			l("Removing %s" % d)
@@ -742,7 +758,7 @@ class TestLvm(unittest.TestCase):
 		for d in device_names:
 			lvm.pvCreate(d)
 
-	def testPVCreate(self):
+	def test_pv_create(self):
 		size = [0, 1024*1024*4]
 		pvmeta_copies = [0, 1, 2]
 		pvmeta_size = [0, 255, 512, 1024]
@@ -750,7 +766,7 @@ class TestLvm(unittest.TestCase):
 		data_alignment_offset = [1, 1, 1]
 		zero = [0, 1]
 
-		device_names = self._get_pv_device_names()
+		device_names = TestLvm._get_pv_device_names()
 
 		for d in device_names:
 			lvm.pvRemove(d)


