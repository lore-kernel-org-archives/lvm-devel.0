From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 26 Jul 2013 21:47:35 +0000 (UTC)
Subject: master - python unit test: Limit PVs to use
Message-ID: <20130726214735.3589E60F18@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b28255aac9386db6d51cd1b501a9f39e81778a5
Commit:        9b28255aac9386db6d51cd1b501a9f39e81778a5
Parent:        df6f0f71b10748fb809fa4d04de7541773a83ac3
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jul 26 09:51:58 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jul 26 16:43:49 2013 -0500

python unit test: Limit PVs to use

When running in the context of the test framework
we need to limit our PVs to use to those created
in the framework.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/pytest.sh          |   13 +-
 test/api/python_lvm_unit.py |  471 ++++++++++++++++++++++++++++---------------
 2 files changed, 315 insertions(+), 169 deletions(-)

diff --git a/test/api/pytest.sh b/test/api/pytest.sh
index 1f6968b..791c9dc 100644
--- a/test/api/pytest.sh
+++ b/test/api/pytest.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2013 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -24,10 +24,11 @@ test -z "$python_lib" && skip
 
 export PYTHONPATH=`dirname $python_lib`:$PYTHONPATH
 
+#Setup which devices the unit test can use.
+export PY_UNIT_PVS=$(cat DEVICES)
+
+
+#We will skip until we can ensure it is correct.
 skip
 
-# skiped until fixed
-# FIXME - script must ONLY use  $(cat DEVICES) as PVs
-# it must NOT create/modify/remove volumes from other places
-python_lvm_unit.py -v
-# nemiver python ../api/python_lvm_unit.py -v -f
+python_lvm_unit.py -v -f
diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index cc18dce..bceb82c 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -1,6 +1,6 @@
 #!/usr/bin/env python
 
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2013 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -16,8 +16,16 @@ import unittest
 import random
 import string
 import lvm
+import os
 
 # Set of basic unit tests for the python bindings.
+#
+# *** WARNING ***
+#
+# This test tries to only modify configuration for the list of allowed
+# PVs, but an error in it could potentially cause data loss if run on a
+# production system.  Therefore it is strongly advised that this unit test
+# not be run on a system that contains data of value.
 
 
 def rs(l=10):
@@ -27,50 +35,152 @@ def rs(l=10):
 	return ''.join(random.choice(string.ascii_uppercase) for x in range(l))
 
 
+def _get_allowed_devices():
+	rc = os.environ.get('PY_UNIT_PVS')
+	if rc is not None:
+		rc = rc.split(' ')
+		rc.sort()
+	return rc
+
+
+def compare_pv(r, l):
+	r_name = r.getName()
+	l_name = l.getName()
+
+	if r_name > l_name:
+		return 1
+	elif r_name == l_name:
+		return 0
+	else:
+		return -1
+
+
+class AllowedPVS(object):
+	"""
+	We are only allowed to muck with certain PV, filter to only
+	the ones we can use.
+	"""
+
+	def __init__(self):
+		self.handle = None
+
+	def __enter__(self):
+		rc = []
+
+		allowed_dev = _get_allowed_devices()
+
+		if allowed_dev:
+			self.handle = lvm.listPvs()
+			self.pvs_all = self.handle.open()
+
+			for p in self.pvs_all:
+				if p.getName() in allowed_dev:
+					rc.append(p)
+
+		#Sort them consistently
+		rc.sort(compare_pv)
+		return rc
+
+	def __exit__(self, t_type, value, traceback):
+		if self.handle:
+			self.pvs_all = None
+			self.handle.close()
+
+
 class TestLvm(unittest.TestCase):
-	(FULL_PV, THIN_PV_A, THIN_PV_B, RESIZE_PV) = (0, 1, 2, 3)
 
-	def _get_pv_devices(self):
+	VG_P = 'py_unit_test_'
+
+	def _get_pv_device_names(self):
 		rc = []
-		with lvm.listPvs() as pvs:
+		with AllowedPVS() as pvs:
 			for p in pvs:
-				name = p.getName()
-				self.assertTrue(name is not None and len(name) > 0)
-				rc.append(name)
-				p = None
+				rc.append(p.getName())
 		return rc
 
-	def _createThick(self, device_list):
-		vg = lvm.vgCreate('full_vg')
+	def _createThickLV(self, device_list, name):
+		vg = lvm.vgCreate(TestLvm.VG_P + "_" + name)
 
 		for d in device_list:
 			vg.extend(d)
 
-		new_extent = 1024 * 1024 * 2
-		vg.setExtentSize(new_extent)
-		self.assertEqual(vg.getExtentSize(), new_extent)
+		vg.createLvLinear(name, vg.getSize()/2)
+		vg.close()
+		vg = None
 
-		vg.createLvLinear('thick_lv', vg.getSize()/2)
+	def _createThinPool(self, device_list, pool_name):
+		vg = lvm.vgCreate(TestLvm.VG_P + "_" + pool_name)
+
+		for d in device_list:
+			vg.extend(d)
+
+		vg.createLvThinpool(pool_name, vg.getSize()/2, 0, 0,
+							lvm.THIN_DISCARDS_PASSDOWN, 1)
+		return vg
+
+	def _createThinLV(self, pv_devices, name):
+		thin_pool_name = 'thin_vg_pool_' + rs(4)
+		vg = self._createThinPool(pv_devices, thin_pool_name)
+		vg.createLvThin(thin_pool_name, name, vg.getSize()/8)
 		vg.close()
 		vg = None
 
-	def _removeThick(self):
-		vg_name = 'full_vg'
+	def _vg_names(self):
+		rc = []
+		vg_names = lvm.listVgNames()
+
+		for i in vg_names:
+			if i[0:len(TestLvm.VG_P)] == TestLvm.VG_P:
+				rc.append(i)
+
+		return rc
+
+	def _get_lv(self, lv_vol_type=None, lv_name=None):
+		vg_name_list = self._vg_names()
+		for vg_name in vg_name_list:
+			vg = lvm.vgOpen(vg_name, "w")
+			lvs = vg.listLVs()
+
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
+	def _remove_VG(self, vg_name):
 		vg = lvm.vgOpen(vg_name, 'w')
 
 		pvs = vg.listPVs()
-		lvs = vg.listLVs()
 
 		pe_devices = []
 
 		#Remove old snapshots first, then lv
-		for l in lvs:
+		for l in vg.listLVs():
 			attr = l.getAttr()
 			if attr[0] == 's':
 				l.remove()
 
+		lvs = vg.listLVs()
+
+		#Now remove any thin lVs
+		for l in vg.listLVs():
+			attr = l.getAttr()
+			if attr[0] == 'V':
+				l.remove()
+
+		#now remove the rest
 		for l in vg.listLVs():
-			l.remove()
+			name = l.getName()
+
+			#Don't remove the hidden ones
+			if 'tmeta' not in name and 'tdata' not in name:
+				l.remove()
 
 		for p in pvs:
 			pe_devices.append(p.getName())
@@ -81,37 +191,31 @@ class TestLvm(unittest.TestCase):
 		vg.remove()
 		vg.close()
 
+	def _clean_up(self):
+		#Clear out the testing PVs, but only if they contain stuff
+		#this unit test created
+		for vg_n in self._vg_names():
+			self._remove_VG(vg_n)
+
 	def setUp(self):
-		device_list = self._get_pv_devices()
+		device_list = self._get_pv_device_names()
 
-		#Make sure our prepare script is doing as expected.
+		#Make sure we have an adequate number of PVs to use
 		self.assertTrue(len(device_list) >= 4)
+		self._clean_up()
 
-		vg_names = lvm.listVgNames()
-
-		#If we don't have any volume groups lets setup one for
-		#those tests that are expecting one
-		if len(vg_names) == 0:
-			self._createThick([device_list[TestLvm.FULL_PV]])
-
-			vg = lvm.vgCreate('thin_vg')
-			vg.extend(device_list[TestLvm.THIN_PV_A])
-			vg.extend(device_list[TestLvm.THIN_PV_B])
-			vg.createLvThinpool('thin_pool', vg.getSize()/2, 0, 0,
-								lvm.THIN_DISCARDS_PASSDOWN, 1)
-			vg.createLvThin('thin_pool', 'thin_lv', vg.getSize()/3)
-			vg.close()
-			vg = None
+	def tearDown(self):
+		self._clean_up()
 
 	def testPVresize(self):
-		with lvm.listPvs() as pvs:
-			pv = pvs[TestLvm.RESIZE_PV]
+		with AllowedPVS() as pvs:
+			pv = pvs[0]
 			curr_size = pv.getSize()
 			dev_size = pv.getDevSize()
 			self.assertTrue(curr_size == dev_size)
 			pv.resize(curr_size/2)
-		with lvm.listPvs() as pvs:
-			pv = pvs[TestLvm.RESIZE_PV]
+		with AllowedPVS() as pvs:
+			pv = pvs[0]
 			resized_size = pv.getSize()
 			self.assertTrue(resized_size != curr_size)
 			pv.resize(dev_size)
@@ -120,29 +224,29 @@ class TestLvm(unittest.TestCase):
 		"""
 		Test removing and re-creating a PV
 		"""
-		target = None
+		target_name = None
 
-		with lvm.listPvs() as pvs:
-			pv = pvs[TestLvm.RESIZE_PV]
-			target = pv.getName()
-			lvm.pvRemove(target)
+		with AllowedPVS() as pvs:
+			pv = pvs[0]
+			target_name = pv.getName()
+			lvm.pvRemove(target_name)
 
-		with lvm.listPvs() as pvs:
+		with AllowedPVS() as pvs:
 			for p in pvs:
-				self.assertTrue(p.getName() != target)
+				self.assertTrue(p.getName() != target_name)
 
-		lvm.pvCreate(target, 0)
+		lvm.pvCreate(target_name, 0)
 
-		with lvm.listPvs() as pvs:
+		with AllowedPVS() as pvs:
 			found = False
 			for p in pvs:
-				if p.getName() == target:
+				if p.getName() == target_name:
 					found = True
 
 		self.assertTrue(found)
 
 	def testPvMethods(self):
-		with lvm.listPvs() as pvs:
+		with AllowedPVS() as pvs:
 			for p in pvs:
 				p.getName()
 				p.getUuid()
@@ -152,74 +256,32 @@ class TestLvm(unittest.TestCase):
 				p.getFree()
 				p = None
 
-	def tearDown(self):
-		pass
-
-	def testOpenClose(self):
-		pass
-
 	def testVersion(self):
 		version = lvm.getVersion()
 		self.assertNotEquals(version, None)
 		self.assertEquals(type(version), str)
 		self.assertTrue(len(version) > 0)
 
-	def testVgOpen(self):
-		vg_names = lvm.listVgNames()
-
-		for i in vg_names:
-			vg = lvm.vgOpen(i)
-			vg.close()
-
-	def _get_lv_test(self, lv_vol_type=None, lv_name=None):
-		vg_name_list = lvm.listVgNames()
-		for vgname in vg_name_list:
-			vg = lvm.vgOpen(vgname, "w")
-			lvs = vg.listLVs()
-
-			for l in lvs:
-				attr = l.getAttr()
-				if lv_vol_type or lv_name:
-					if lv_vol_type is not None and attr[0] == lv_vol_type:
-						return l, vg
-					elif lv_name is not None and lv_name == l.getName():
-						return l, vg
-				else:
-					return l, vg
-			vg.close()
-		return None, None
-
-	def _get_pv_test(self):
-		vg_name_list = lvm.listVgNames()
-		for vgname in vg_name_list:
-			vg = lvm.vgOpen(vgname, "w")
-			pvs = vg.listPVs()
-			if len(pvs):
-				return pvs[0], vg
-		return None, None
-
 	def testPvGetters(self):
-		pv, vg = self._get_pv_test()
-
-		self.assertEqual(type(pv.getName()), str)
-		self.assertTrue(len(pv.getName()) > 0)
+		with AllowedPVS() as pvs:
+			pv = pvs[0]
+			self.assertEqual(type(pv.getName()), str)
+			self.assertTrue(len(pv.getName()) > 0)
 
-		self.assertEqual(type(pv.getUuid()), str)
-		self.assertTrue(len(pv.getUuid()) > 0)
+			self.assertEqual(type(pv.getUuid()), str)
+			self.assertTrue(len(pv.getUuid()) > 0)
 
-		self.assertTrue(type(pv.getMdaCount()) == int or
-						type(pv.getMdaCount()) == long)
+			self.assertTrue(type(pv.getMdaCount()) == int or
+							type(pv.getMdaCount()) == long)
 
-		self.assertTrue(type(pv.getSize()) == int or
-						type(pv.getSize()) == long)
+			self.assertTrue(type(pv.getSize()) == int or
+							type(pv.getSize()) == long)
 
-		self.assertTrue(type(pv.getDevSize()) == int or
-						type(pv.getSize()) == long)
+			self.assertTrue(type(pv.getDevSize()) == int or
+							type(pv.getSize()) == long)
 
-		self.assertTrue(type(pv.getFree()) == int or
-						type(pv.getFree()) == long)
-
-		vg.close()
+			self.assertTrue(type(pv.getFree()) == int or
+							type(pv.getFree()) == long)
 
 	def _test_prop(self, prop_obj, prop, var_type, settable):
 		result = prop_obj.getProperty(prop)
@@ -229,34 +291,38 @@ class TestLvm(unittest.TestCase):
 		self.assertTrue(result[1] == settable)
 
 	def testPvSegs(self):
-		pv, vg = self._get_pv_test()
-		pv_segs = pv.listPVsegs()
+		with AllowedPVS() as pvs:
+			pv = pvs[0]
+			pv_segs = pv.listPVsegs()
 
-		#LVsegs returns a tuple, (value, bool settable)
-
-		#TODO: Test other properties of pv_seg
-		for i in pv_segs:
-			self._test_prop(i, 'pvseg_start', long, False)
-
-		vg.close()
+			#LVsegs returns a tuple, (value, bool settable)
+			#TODO: Test other properties of pv_seg
+			for i in pv_segs:
+				self._test_prop(i, 'pvseg_start', long, False)
 
 	def testPvProperty(self):
-		pv, vg = self._get_pv_test()
-		self._test_prop(pv, 'pv_mda_count', long, False)
-		vg.close()
+		with AllowedPVS() as pvs:
+			pv = pvs[0]
+			self._test_prop(pv, 'pv_mda_count', long, False)
 
 	def testLvProperty(self):
-		lv, vg = self._get_lv_test()
+		lv_name = 'lv_test'
+		self._createThinLV(self._get_pv_device_names(), lv_name)
+		lv, vg = self._get_lv(None, lv_name)
 		self._test_prop(lv, 'seg_count', long, False)
 		vg.close()
 
 	def testLvTags(self):
-		lv, vg = self._get_lv_test()
+		lv_name = 'lv_test'
+		self._createThinLV(self._get_pv_device_names(), lv_name)
+		lv, vg = self._get_lv(None, lv_name)
 		self._testTags(lv)
 		vg.close()
 
 	def testLvActiveInactive(self):
-		lv, vg = self._get_lv_test()
+		lv_name = 'lv_test'
+		self._createThinLV(self._get_pv_device_names(), lv_name)
+		lv, vg = self._get_lv(None, lv_name)
 		lv.deactivate()
 		self.assertTrue(lv.isActive() is False)
 		lv.activate()
@@ -264,7 +330,9 @@ class TestLvm(unittest.TestCase):
 		vg.close()
 
 	def testLvRename(self):
-		lv, vg = self._get_lv_test()
+		lv_name = 'lv_test'
+		self._createThinLV(self._get_pv_device_names(), lv_name)
+		lv, vg = self._get_lv(None, lv_name)
 
 		current_name = lv.getName()
 		new_name = rs()
@@ -275,71 +343,96 @@ class TestLvm(unittest.TestCase):
 
 	def testLvSnapshot(self):
 
-		#Cleanup existing if already present
-		to_remove = ['thick_lv_snapshot', 'thin_lv_snapshot']
+		thin_lv = 'thin_lv'
+		thick_lv = 'thick_lv'
 
-		for ss in to_remove:
-			snap, vg = self._get_lv_test(None, ss)
-			if snap:
-				snap.remove()
-				vg.close()
+		device_names = self._get_pv_device_names()
 
-		thick_lv, vg = self._get_lv_test(None, 'thick_lv')
+		self._createThinLV(device_names[0:2], thin_lv)
+		self._createThickLV(device_names[2:4], thick_lv)
 
-		self.assertEqual('thick_lv', thick_lv.getName())
-
-		thick_lv.snapshot('thick_lv_snapshot', 1024*1024)
+		lv, vg = self._get_lv(None, thick_lv)
+		lv.snapshot('thick_snap_shot', 1024*1024)
 		vg.close()
 
-		thin_lv, vg = self._get_lv_test(None, 'thin_lv')
-		thin_lv.snapshot('thin_lv_snapshot')
+		thick_ss, vg = self._get_lv(None, 'thick_snap_shot')
+		self.assertTrue(thick_ss is not None)
+		vg.close()
 
+		thin_lv, vg = self._get_lv(None, thin_lv)
+		thin_lv.snapshot('thin_snap_shot')
 		vg.close()
 
-		thin_ss, vg = self._get_lv_test(None, 'thin_lv_snapshot')
+		thin_ss, vg = self._get_lv(None, 'thin_snap_shot')
 		self.assertTrue(thin_ss is not None)
 
 		origin = thin_ss.getOrigin()
-		self.assertTrue('thin_lv', origin)
+		self.assertTrue(thin_lv, origin)
 
 		vg.close()
 
 	def testLvSuspend(self):
-		lv, vg = self._get_lv_test()
+		lv_name = 'lv_test'
+		self._createThinLV(self._get_pv_device_names(), lv_name)
+		lv, vg = self._get_lv(None, lv_name)
 
 		result = lv.isSuspended()
 		self.assertTrue(type(result) == bool)
 		vg.close()
 
 	def testLvSize(self):
-		lv, vg = self._get_lv_test()
+		lv_name = 'lv_test'
+		self._createThinLV(self._get_pv_device_names(), lv_name)
+		lv, vg = self._get_lv(None, lv_name)
+
 		result = lv.getSize()
 		self.assertTrue(type(result) == int or type(result) == long)
 		vg.close()
 
 	def testLvResize(self):
-		lv, vg = self._get_lv_test('V')
+		lv_name = 'lv_test'
+		self._createThinLV(self._get_pv_device_names(), lv_name)
+		lv, vg = self._get_lv(None, lv_name)
+
 		curr_size = lv.getSize()
 		lv.resize(curr_size+(1024*1024))
 		latest = lv.getSize()
 		self.assertTrue(curr_size != latest)
 
 	def testLvSeg(self):
-		lv, vg = self._get_lv_test()
+		lv_name = 'lv_test'
+		self._createThinLV(self._get_pv_device_names(), lv_name)
+		lv, vg = self._get_lv(None, lv_name)
 
 		lv_segs = lv.listLVsegs()
 
 		#LVsegs returns a tuple, (value, bool settable)
-
 		#TODO: Test other properties of lv_seg
 		for i in lv_segs:
 			self._test_prop(i, 'seg_start_pe', long, False)
 
 		vg.close()
 
+	def testGetSetExtentSize(self):
+		thick_lv = 'get_set_prop'
+		device_names = self._get_pv_device_names()
+		self._createThickLV(device_names[0:2], thick_lv)
+		lv, vg = self._get_lv(None, thick_lv)
+
+		new_extent = 1024 * 1024 * 4
+
+		self.assertFalse(vg.getExtentSize() != new_extent,
+						 "Cannot determine if it works if they are the same")
+
+		vg.setExtentSize(new_extent)
+		self.assertEqual(vg.getExtentSize(), new_extent)
+		vg.close()
+
 	def testVGsetGetProp(self):
-		vg_name = 'full_vg'
-		vg = lvm.vgOpen(vg_name, 'w')
+		thick_lv = 'get_set_prop'
+		device_names = self._get_pv_device_names()
+		self._createThickLV(device_names[0:2], thick_lv)
+		lv, vg = self._get_lv(None, thick_lv)
 
 		self.assertTrue(vg is not None)
 		if vg:
@@ -348,18 +441,23 @@ class TestLvm(unittest.TestCase):
 			vg.close()
 
 	def testVGremoveRestore(self):
-
 		#Store off the list of physical devices
-		pe_devices = []
-		vg = lvm.vgOpen('full_vg', 'w')
+		pv_devices = []
+
+		thick_lv = 'get_set_prop'
+		device_names = self._get_pv_device_names()
+		self._createThickLV(device_names[0:2], thick_lv)
+		lv, vg = self._get_lv(None, thick_lv)
+
+		vg_name = vg.getName()
 
 		pvs = vg.listPVs()
 		for p in pvs:
-			pe_devices.append(p.getName())
+			pv_devices.append(p.getName())
 		vg.close()
 
-		self._removeThick()
-		self._createThick(pe_devices)
+		self._remove_VG(vg_name)
+		self._createThickLV(pv_devices, thick_lv)
 
 	def testVgNames(self):
 		vg = lvm.listVgNames()
@@ -370,12 +468,14 @@ class TestLvm(unittest.TestCase):
 		Try to create a lv with the same name expecting a failure
 		Note: This was causing a seg. fault previously
 		"""
-		vgs = lvm.listVgNames()
+		thick_lv = 'dupe_name'
+		device_names = self._get_pv_device_names()
+		self._createThickLV(device_names[0:2], thick_lv)
+		lv, vg = self._get_lv(None, thick_lv)
 
-		if len(vgs):
-			vg_name = vgs[0]
-			vg = lvm.vgOpen(vg_name, "w")
+		self.assertTrue(vg is not None)
 
+		if vg:
 			lvs = vg.listLVs()
 
 			if len(lvs):
@@ -383,14 +483,20 @@ class TestLvm(unittest.TestCase):
 				lv_name = lv.getName()
 				self.assertRaises(lvm.LibLVMError, vg.createLvLinear, lv_name,
 								  lv.getSize())
+			vg.close()
 
 	def testVgUuids(self):
+
+		device_names = self._get_pv_device_names()
+		self._createThinLV(device_names[0:2], 'thin')
+		self._createThickLV(device_names[2:4], 'thick')
+
 		vgs_uuids = lvm.listVgUuids()
 
+		self.assertTrue(len(vgs_uuids) > 0)
 		self.assertTrue(isinstance(vgs_uuids, tuple))
 
 		vgs_uuids = list(vgs_uuids)
-
 		vgs_names = lvm.listVgNames()
 
 		for vg_name in vgs_names:
@@ -407,7 +513,13 @@ class TestLvm(unittest.TestCase):
 		self.assertTrue(len(vgs_uuids) == 0)
 
 	def testPvLookupFromVG(self):
-		vg_names = lvm.listVgNames()
+		device_names = self._get_pv_device_names()
+		self._createThinLV(device_names[0:2], 'thin')
+		self._createThickLV(device_names[2:4], 'thick')
+
+		vg_names = self._vg_names()
+
+		self.assertTrue(len(vg_names) > 0)
 
 		for vg_name in vg_names:
 			vg = lvm.vgOpen(vg_name, 'w')
@@ -455,7 +567,14 @@ class TestLvm(unittest.TestCase):
 		self.assertTrue(lvm.configFindBool("global/locking_type"))
 
 	def testVgFromPVLookups(self):
-		vgname_list = lvm.listVgNames()
+		device_names = self._get_pv_device_names()
+		self._createThinLV(device_names[0:2], 'thin')
+		self._createThickLV(device_names[2:4], 'thick')
+
+		vgname_list = self._vg_names()
+
+		self.assertTrue(len(vgname_list) > 0)
+
 		for vg_name in vgname_list:
 			vg = lvm.vgOpen(vg_name, 'r')
 
@@ -469,7 +588,13 @@ class TestLvm(unittest.TestCase):
 			vg.close()
 
 	def testVgGetName(self):
-		vgname_list = lvm.listVgNames()
+		device_names = self._get_pv_device_names()
+		self._createThinLV(device_names[0:2], 'thin')
+		self._createThickLV(device_names[2:4], 'thick')
+
+		vgname_list = self._vg_names()
+
+		self.assertTrue(len(vgname_list) > 0)
 
 		for vg_name in vgname_list:
 			vg = lvm.vgOpen(vg_name, 'r')
@@ -477,7 +602,13 @@ class TestLvm(unittest.TestCase):
 			vg.close()
 
 	def testVgGetUuid(self):
-		vgname_list = lvm.listVgNames()
+		device_names = self._get_pv_device_names()
+		self._createThinLV(device_names[0:2], 'thin')
+		self._createThickLV(device_names[2:4], 'thick')
+
+		vgname_list = self._vg_names()
+
+		self.assertTrue(len(vgname_list) > 0)
 
 		for vg_name in vgname_list:
 			vg = lvm.vgOpen(vg_name, 'r')
@@ -491,7 +622,13 @@ class TestLvm(unittest.TestCase):
 					  "getPvCount", "getMaxPv", "getMaxLv"]
 
 	def testVgGetters(self):
-		vg_name_list = lvm.listVgNames()
+		device_names = self._get_pv_device_names()
+		self._createThinLV(device_names[0:2], 'thin')
+		self._createThickLV(device_names[2:4], 'thick')
+
+		vg_name_list = self._vg_names()
+
+		self.assertTrue(len(vg_name_list) > 0)
 
 		for vg_name in vg_name_list:
 			vg = lvm.vgOpen(vg_name, 'r')
@@ -541,9 +678,17 @@ class TestLvm(unittest.TestCase):
 			self.assertTrue(e in current_tags)
 
 	def testVgTags(self):
-		vg_name_list = lvm.listVgNames()
+		device_names = self._get_pv_device_names()
 
-		for vg_name in vg_name_list:
+		i = 0
+		for d in device_names:
+			if i % 2 == 0:
+				self._createThinLV([d],  "thin_lv%d" % i)
+			else:
+				self._createThickLV([d], "thick_lv%d" % i)
+			i += 1
+
+		for vg_name in self._vg_names():
 			vg = lvm.vgOpen(vg_name, 'w')
 			self._testTags(vg)
 			vg.close()


