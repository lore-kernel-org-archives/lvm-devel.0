From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:46 +0000 (UTC)
Subject: master - python-lvm: Improve unit test case(s)
Message-ID: <20130702192646.85AAA60FB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04efe869a440590d99a886cda74aaf259b8067d7
Commit:        04efe869a440590d99a886cda74aaf259b8067d7
Parent:        50db109e2068d8d5645bd4117b6022acf4b7f8ba
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jul 1 17:01:48 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

python-lvm: Improve unit test case(s)

Create/remove PV
Create/remove snapshots (old type & thin)
PV lookups based on name and UUID
PV resize

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/pytest.sh          |    7 +-
 test/api/python_lvm_unit.py |  332 +++++++++++++++++++++++++++++++++----------
 2 files changed, 259 insertions(+), 80 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index ad99624..a1a3cb4 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -13,15 +13,16 @@
 
 . lib/test
 
-aux prepare_vg 1
-lvcreate -n test -l 5 $vg
+#If you change this change the unit test case too.
+aux prepare_pvs 6
 
 #Locate the python binding library to use.
 python_lib=`find $abs_top_builddir -name lvm.so`
 if [ "$python_lib" != "" ]
 then
 	export PYTHONPATH=`dirname $python_lib`:$PYTHONPATH
-	python_lvm_unit.py
+	python_lvm_unit.py -v
+	#nemiver python ../api/python_lvm_unit.py -v -f
 else
 	echo "Unable to test python bindings as library not available"
 fi
diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index c4d7983..6491413 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -27,8 +27,130 @@ def rs(l=10):
 
 
 class TestLvm(unittest.TestCase):
+	(FULL_PV, THIN_PV_A, THIN_PV_B, RESIZE_PV) = (0, 1, 2, 3)
+
+
+	def _get_pv_devices(self):
+		rc = []
+		with lvm.listPvs() as pvs:
+			for p in pvs:
+				name = p.getName()
+				self.assertTrue(name is not None and len(name) > 0)
+				rc.append(name)
+				p = None
+		return rc
+
+	def _createThick(self, device_list):
+		vg = lvm.vgCreate('full_vg')
+
+		for d in device_list:
+			vg.extend(d)
+
+		new_extent = 1024 * 1024 * 2
+		vg.setExtentSize(new_extent)
+		self.assertEqual(vg.getExtentSize(), new_extent)
+
+		vg.createLvLinear('thick_lv', vg.getSize()/2)
+		vg.close()
+		vg = None
+
+	def _removeThick(self):
+		vg_name = 'full_vg'
+		vg = lvm.vgOpen(vg_name, 'w')
+
+		pvs = vg.listPVs()
+		lvs = vg.listLVs()
+
+		pe_devices = []
+
+		#Remove old snapshots first, then lv
+		for l in lvs:
+			attr = l.getAttr()
+			if attr[0] == 's':
+				l.remove()
+
+		for l in vg.listLVs():
+			l.remove()
+
+		for p in pvs:
+			pe_devices.append(p.getName())
+
+		for pv in pe_devices:
+			vg.reduce(pv)
+
+		vg.remove()
+		vg.close()
+
 	def setUp(self):
-		pass
+		device_list = self._get_pv_devices()
+
+		#Make sure our prepare script is doing as expected.
+		self.assertTrue(len(device_list) >= 4)
+
+		vg_names = lvm.listVgNames()
+
+		#If we don't have any volume groups lets setup one for
+		#those tests that are expecting one
+		if len(vg_names) == 0:
+			self._createThick([device_list[TestLvm.FULL_PV]])
+
+			vg = lvm.vgCreate('thin_vg')
+			vg.extend(device_list[TestLvm.THIN_PV_A])
+			vg.extend(device_list[TestLvm.THIN_PV_B])
+			vg.createLvThinpool('thin_pool', vg.getSize()/2, 0, 0,
+					lvm.THIN_DISCARDS_PASSDOWN, 1)
+			vg.createLvThin('thin_pool', 'thin_lv', vg.getSize()/3)
+			vg.close()
+			vg = None
+
+	def testPVresize(self):
+		with lvm.listPvs() as pvs:
+			pv = pvs[TestLvm.RESIZE_PV]
+			curr_size = pv.getSize()
+			dev_size = pv.getDevSize()
+			self.assertTrue(curr_size == dev_size)
+			pv.resize(curr_size/2)
+		with lvm.listPvs() as pvs:
+			pv = pvs[TestLvm.RESIZE_PV]
+			resized_size = pv.getSize()
+			self.assertTrue(resized_size != curr_size)
+			pv.resize(dev_size)
+
+	def testPVlifecycle(self):
+		"""
+		Test removing and re-creating a PV
+		"""
+		target = None
+
+		with lvm.listPvs() as pvs:
+			pv = pvs[TestLvm.RESIZE_PV]
+			target = pv.getName()
+			lvm.pvRemove(target)
+
+		with lvm.listPvs() as pvs:
+			for p in pvs:
+				self.assertTrue(p.getName() != target)
+
+		lvm.pvCreate(target, 0)
+
+		with lvm.listPvs() as pvs:
+			found = False
+			for p in pvs:
+				if p.getName() == target:
+					found = True
+
+		self.assertTrue(found)
+
+	def testPvMethods(self):
+		with lvm.listPvs() as pvs:
+			for p in pvs:
+				p.getName()
+				p.getUuid()
+				p.getMdaCount()
+				p.getSize()
+				p.getDevSize()
+				p.getFree()
+				p = None
 
 	def tearDown(self):
 		pass
@@ -49,26 +171,35 @@ class TestLvm(unittest.TestCase):
 			vg = lvm.vgOpen(i)
 			vg.close()
 
-	def _get_lv_test(self, mode='r'):
+	def _get_lv_test(self, lv_vol_type=None, lv_name=None):
 		vg_name_list = lvm.listVgNames()
 		for vgname in vg_name_list:
-			vg = lvm.vgOpen(vgname, mode)
+			vg = lvm.vgOpen(vgname, "w")
 			lvs = vg.listLVs()
-			if len(lvs):
-				return lvs[0]
-		return None
 
-	def _get_pv_test(self, mode='r'):
+			for l in lvs:
+				attr = l.getAttr()
+				if lv_vol_type or lv_name:
+					if lv_vol_type is not None and attr[0] == lv_vol_type:
+						return l, vg
+					elif lv_name is not None and lv_name == l.getName():
+						return l, vg
+				else:
+					return l, vg
+			vg.close()
+		return None, None
+
+	def _get_pv_test(self):
 		vg_name_list = lvm.listVgNames()
 		for vgname in vg_name_list:
-			vg = lvm.vgOpen(vgname, mode)
+			vg = lvm.vgOpen(vgname, "w")
 			pvs = vg.listPVs()
 			if len(pvs):
-				return pvs[0]
-		return None
+				return pvs[0], vg
+		return None, None
 
 	def testPvGetters(self):
-		pv = self._get_pv_test()
+		pv, vg = self._get_pv_test()
 
 		self.assertEqual(type(pv.getName()), str)
 		self.assertTrue(len(pv.getName()) > 0)
@@ -84,6 +215,8 @@ class TestLvm(unittest.TestCase):
 
 		self.assertTrue(type(pv.getFree()) == int or type(pv.getFree()) == long)
 
+		vg.close()
+
 	def _test_prop(self, prop_obj, prop, var_type, settable):
 		result = prop_obj.getProperty(prop)
 
@@ -92,7 +225,7 @@ class TestLvm(unittest.TestCase):
 		self.assertTrue(result[1] == settable)
 
 	def testPvSegs(self):
-		pv = self._get_pv_test("r")
+		pv, vg = self._get_pv_test()
 		pv_segs = pv.listPVsegs()
 
 		#LVsegs returns a tuple, (value, bool settable)
@@ -101,53 +234,96 @@ class TestLvm(unittest.TestCase):
 		for i in pv_segs:
 			self._test_prop(i, 'pvseg_start', long, False)
 
+		vg.close()
+
 	def testPvProperty(self):
-		pv = self._get_pv_test("r")
+		pv, vg = self._get_pv_test()
 		self._test_prop(pv, 'pv_mda_count', long, False)
+		vg.close()
 
 	def testLvProperty(self):
-		lv = self._get_lv_test("r")
+		lv, vg = self._get_lv_test()
 		self._test_prop(lv, 'seg_count', long, False)
+		vg.close()
 
 	def testLvTags(self):
-		lv = self._get_lv_test("w")
+		lv, vg = self._get_lv_test()
 		self._testTags(lv)
+		vg.close()
 
 	def testLvActiveInactive(self):
-		lv = self._get_lv_test("w")
+		lv, vg = self._get_lv_test()
 		lv.deactivate()
 		self.assertTrue(lv.isActive() == False)
 		lv.activate()
 		self.assertTrue(lv.isActive() == True)
+		vg.close()
 
 	def testLvRename(self):
-		lv = self._get_lv_test("w")
+		lv, vg = self._get_lv_test()
 
 		current_name = lv.getName()
 		new_name = rs()
 		lv.rename(new_name)
 		self.assertEqual(lv.getName(), new_name)
 		lv.rename(current_name)
+		vg.close()
+
+	def testLvSnapshot(self):
+
+		#Cleanup existing if already present
+		to_remove = [ 'thick_lv_snapshot', 'thin_lv_snapshot']
+
+		for ss in to_remove:
+			snap, vg = self._get_lv_test(None, ss)
+			if snap:
+				snap.remove()
+				vg.close()
+
+
+		thick_lv, vg = self._get_lv_test(None, 'thick_lv')
+
+		self.assertEqual('thick_lv', thick_lv.getName())
+
+		thick_lv.snapshot('thick_lv_snapshot', 1024*1024)
+		vg.close()
+
+		thin_lv, vg = self._get_lv_test(None, 'thin_lv')
+		thin_lv.snapshot('thin_lv_snapshot')
+
+		vg.close()
+
+		thin_ss, vg = self._get_lv_test(None, 'thin_lv_snapshot')
+		self.assertTrue(thin_ss is not None)
+
+		origin = thin_ss.getOrigin()
+		self.assertTrue('thin_lv', origin)
+
+		vg.close()
+
 
 	def testLvSuspend(self):
-		lv = self._get_lv_test("r")
+		lv, vg = self._get_lv_test()
 
 		result = lv.isSuspended()
-		self.assertTrue(type(result), bool)
+		self.assertTrue(type(result) == bool)
+		vg.close()
 
 	def testLvSize(self):
-		lv = self._get_lv_test("r")
+		lv, vg = self._get_lv_test()
 		result = lv.getSize()
-		self.assertTrue(type(result), bool)
+		self.assertTrue(type(result) == int or type(result)== long)
+		vg.close()
 
 	def testLvResize(self):
-		pass    #Not implemented!
-
-	def testPvResize(self):
-		pass    #Patch available, not committed
+		lv, vg = self._get_lv_test('V')
+		curr_size = lv.getSize()
+		lv.resize(curr_size+(1024*1024))
+		latest = lv.getSize()
+		self.assertTrue(curr_size != latest)
 
 	def testLvSeg(self):
-		lv = self._get_lv_test("r")
+		lv, vg = self._get_lv_test()
 
 		lv_segs = lv.listLVsegs()
 
@@ -157,62 +333,31 @@ class TestLvm(unittest.TestCase):
 		for i in lv_segs:
 			self._test_prop(i, 'seg_start_pe', long, False)
 
-	def testLvMisc(self):
-		#Need to look at lack of vg_write in vg create
-
-		#For this to work cleanly we will remove an existing lv & vg and then
-		#put it back so that the test framework can clean it up.
-		vg_name_list = lvm.listVgNames()
+		vg.close()
 
-		if len(vg_name_list):
-			vg_name = vg_name_list[0]
-
-			vg = lvm.vgOpen(vg_name, "w")
+	def testVGsetGetProp(self):
+		vg_name = 'full_vg'
+		vg = lvm.vgOpen(vg_name, 'w')
 
+		self.assertTrue(vg is not None)
+		if vg:
 			vg_mda_copies = vg.getProperty('vg_mda_copies')
 			vg.setProperty('vg_mda_copies', vg_mda_copies[0])
-
-			pvs = vg.listPVs()
-			lvs = vg.listLVs()
-
-			pe_devices = []
-			for p in pvs:
-				pe_devices.append(p.getName())
-
-			self.assertEquals(len(lvs), 1)
-
-			lv = lvs[0]
-
-			lv_name = lv.getName()
-			lv_size = lv.getSize()
-
-			lv.remove()
-			lv = None
-
-			vg.reduce(pe_devices[0])
-
-			vg.remove()
 			vg.close()
 
-			nvg = lvm.vgCreate(vg_name)
-			for p in pe_devices:
-				nvg.extend(p)
-
-			#2MiB extent size
-			new_extent = 1024 * 1024 * 2
-
-			nvg.setExtentSize(new_extent)
-			self.assertEqual(nvg.getExtentSize(), new_extent)
-
-			v = nvg.createLvLinear(lv_name, lv_size)
+	def testVGremoveRestore(self):
 
-			lv_find_name = nvg.lvFromName(lv_name)
-			lv_find_uuid = nvg.lvFromUuid(v.getUuid())
+		#Store off the list of physical devices
+		pe_devices = []
+		vg = lvm.vgOpen('full_vg', 'w')
 
-			self.assertTrue(lv_find_name.getName() == v.getName())
-			self.assertTrue(lv_find_uuid.getUuid() == v.getUuid())
+		pvs = vg.listPVs()
+		for p in pvs:
+			pe_devices.append(p.getName())
+		vg.close()
 
-			nvg.close()
+		self._removeThick()
+		self._createThick(pe_devices)
 
 	def testVgNames(self):
 		vg = lvm.listVgNames()
@@ -234,7 +379,8 @@ class TestLvm(unittest.TestCase):
 			if len(lvs):
 				lv = lvs[0]
 				lv_name = lv.getName()
-				self.assertRaises(lvm.LibLVMError, vg.createLvLinear, lv_name,
+				self.assertRaises(lvm.LibLVMError,
+					vg.createLvLinear, lv_name,
 					lv.getSize())
 
 	def testVgUuids(self):
@@ -249,15 +395,46 @@ class TestLvm(unittest.TestCase):
 		for vg_name in vgs_names:
 			vg = lvm.vgOpen(vg_name, "r")
 
-			#TODO Write/fix BUG, vg uuid don't match between lvm.listVgUuids
-			# and vg.getUuid()
+			#TODO Write/fix BUG, vg uuid don't match between
+			#lvm.listVgUuids and vg.getUuid()
 			vg_uuid_search = vg.getUuid().replace('-', '')
 
 			self.assertTrue(vg_uuid_search in vgs_uuids)
 			vgs_uuids.remove(vg_uuid_search)
+			vg.close()
 
 		self.assertTrue(len(vgs_uuids) == 0)
 
+	def testPvLookupFromVG(self):
+		vg_names = lvm.listVgNames()
+
+		for vg_name in vg_names:
+			vg = lvm.vgOpen(vg_name, 'w')
+			pvs = vg.listPVs()
+
+			for p in pvs:
+				name = p.getName()
+				uuid = p.getUuid()
+
+				pv_name_lookup = vg.pvFromName(name)
+				pv_uuid_lookup = vg.pvFromUuid(uuid)
+
+				self.assertTrue(pv_name_lookup.getName() == \
+						pv_uuid_lookup.getName())
+				self.assertTrue(pv_name_lookup.getUuid() == \
+						pv_uuid_lookup.getUuid())
+
+				self.assertTrue(name == pv_name_lookup.getName())
+				self.assertTrue(uuid == pv_uuid_lookup.getUuid())
+
+				pv_name_lookup = None
+				pv_uuid_lookup = None
+				p = None
+
+			pvs = None
+			vg.close()
+
+
 	def testPercentToFloat(self):
 		self.assertEqual(lvm.percentToFloat(0), 0.0)
 		self.assertEqual(lvm.percentToFloat(1000000), 1.0)
@@ -273,8 +450,9 @@ class TestLvm(unittest.TestCase):
 		self.assertEquals(lvm.configOverride("global.test = 1"), None)
 
 	def testConfigFindBool(self):
+		either_or = lvm.configFindBool("global/fallback_to_local_locking")
+		self.assertTrue(type(either_or) == bool)
 		self.assertTrue(lvm.configFindBool("global/locking_type"))
-		self.assertFalse(lvm.configFindBool("global/fallback_to_local_locking"))
 
 	def testVgFromPVLookups(self):
 		vgname_list = lvm.listVgNames()


