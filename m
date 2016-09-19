From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 19 Sep 2016 20:38:27 +0000 (UTC)
Subject: master - lvmdbustest.py: Test with/without timeout values
Message-ID: <20160919203827.5CB1160D98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb2b2615107e84dc3aba7b3e4b6755ed01c18cb0
Commit:        cb2b2615107e84dc3aba7b3e4b6755ed01c18cb0
Parent:        5366e87574cbf9f13badea37b827ae5b97bcfdbf
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Sat Sep 17 00:11:59 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Sep 19 15:32:27 2016 -0500

lvmdbustest.py: Test with/without timeout values

Because of the different code paths we need to test job handling with
all operations.  Test now runs virtually everything with timeout == 0
and timeout == 15 so that we test both use cases.

Note:  If a client passes -1 for the timeout value they need to make
sure that their connection time out is also infinite.  Otherwise, if the client
times out the service side hangs any new dbus calls until the job
that is in progress completes.  Not sure why this behavior is occuring
at this time, but it appears a limitation/bug of the dbus-python library.
---
 test/dbus/lvmdbustest.py |  420 +++++++++++++++++++++++++++++-----------------
 1 files changed, 267 insertions(+), 153 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index c6fa4d6..9702ee8 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -19,6 +19,8 @@ import pyudev
 import os
 from testlib import *
 
+g_tmo = 0
+
 use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
 if use_session:
@@ -81,7 +83,7 @@ class TestDbusService(unittest.TestCase):
 		self.objs, self.bus = get_objects()
 		for v in self.objs[VG_INT]:
 			# print "DEBUG: Removing VG= ", v.Uuid, v.Name
-			v.Vg.Remove(-1, {})
+			self.handle_return(v.Vg.Remove(g_tmo, {}))
 
 		# Check to make sure the PVs we had to start exist, else re-create
 		# them
@@ -97,8 +99,25 @@ class TestDbusService(unittest.TestCase):
 					# print('Re-creating PV=', p)
 					self._pv_create(p)
 
+	def handle_return(self, rc):
+		if isinstance(rc, (tuple, list)):
+			# We have a tuple returned
+			if rc[0] != '/':
+				return rc[0]
+			else:
+				return self._wait_for_job(rc[1])
+		else:
+			if rc == '/':
+				return rc
+			else:
+				return self._wait_for_job(rc)
+
 	def _pv_create(self, device):
-		pv_path = self.objs[MANAGER_INT][0].Manager.PvCreate(device, -1, {})[0]
+
+		pv_path = self.handle_return(
+			self.objs[MANAGER_INT][0].Manager.PvCreate(
+				device, g_tmo, {})
+		)
 		self.assertTrue(pv_path is not None and len(pv_path) > 0)
 		return pv_path
 
@@ -124,11 +143,10 @@ class TestDbusService(unittest.TestCase):
 
 		vg_name = rs(8, '_vg')
 
-		vg_path = self.objs[MANAGER_INT][0].Manager.VgCreate(
-			vg_name,
-			pv_paths,
-			-1,
-			{})[0]
+		vg_path = self.handle_return(
+			self.objs[MANAGER_INT][0].Manager.VgCreate(
+				vg_name, pv_paths, g_tmo, {}))
+
 		self.assertTrue(vg_path is not None and len(vg_path) > 0)
 		return ClientProxy(self.bus, vg_path)
 
@@ -138,19 +156,19 @@ class TestDbusService(unittest.TestCase):
 
 	def test_vg_delete(self):
 		vg = self._vg_create().Vg
-		vg.Remove(-1, {})
+
+		self.handle_return(vg.Remove(g_tmo, {}))
 		self.assertEqual(self._refresh(), 0)
 
-	@staticmethod
-	def _pv_remove(pv):
-		rc = pv.Pv.Remove(-1, {})
+	def _pv_remove(self, pv):
+		rc = self.handle_return(pv.Pv.Remove(g_tmo, {}))
 		return rc
 
 	def test_pv_remove_add(self):
 		target = self.objs[PV_INT][0]
 
 		# Remove the PV
-		rc = TestDbusService._pv_remove(target)
+		rc = self._pv_remove(target)
 		self.assertTrue(rc == '/')
 		self.assertEqual(self._refresh(), 0)
 
@@ -168,14 +186,19 @@ class TestDbusService(unittest.TestCase):
 
 			vg = self._vg_create(pv_paths).Vg
 
-		lv_meta_path = vg.LvCreateRaid(
-			"meta_r5", "raid5", mib(4), 0, 0, -1, {})[0]
+		lv_meta_path = self.handle_return(
+			vg.LvCreateRaid(
+				"meta_r5", "raid5", mib(4), 0, 0, g_tmo, {})
+		)
 
-		lv_data_path = vg.LvCreateRaid(
-			"data_r5", "raid5", mib(16), 0, 0, -1, {})[0]
+		lv_data_path = self.handle_return(
+			vg.LvCreateRaid(
+				"data_r5", "raid5", mib(16), 0, 0, g_tmo, {})
+		)
 
-		thin_pool_path = vg.CreateThinPool(
-			lv_meta_path, lv_data_path, -1, {})[0]
+		thin_pool_path = self.handle_return(
+			vg.CreateThinPool(lv_meta_path, lv_data_path, g_tmo, {})
+		)
 
 		# Get thin pool client proxy
 		thin_pool = ClientProxy(self.bus, thin_pool_path)
@@ -197,8 +220,10 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(cache_pool.CachePool.MetaDataLv != '/')
 
 		# Cache the thin pool
-		cached_thin_pool_path = cache_pool.\
-			CachePool.CacheLv(thin_pool.object_path, -1, {})[0]
+		cached_thin_pool_path = self.handle_return(
+			cache_pool.CachePool.CacheLv(
+				thin_pool.object_path, g_tmo, {})
+		)
 
 		# Get object proxy for cached thin pool
 		cached_thin_pool_object = ClientProxy(self.bus, cached_thin_pool_path)
@@ -231,7 +256,10 @@ class TestDbusService(unittest.TestCase):
 			pv_next = self.objs[PV_INT][1]
 
 			vg = self._vg_create([pv_initial.object_path]).Vg
-			path = vg.Extend([pv_next.object_path], -1, {})
+
+			path = self.handle_return(
+				vg.Extend([pv_next.object_path], g_tmo, {})
+			)
 			self.assertTrue(path == '/')
 			self.assertEqual(self._refresh(), 0)
 
@@ -244,7 +272,9 @@ class TestDbusService(unittest.TestCase):
 				[self.objs[PV_INT][0].object_path,
 				self.objs[PV_INT][1].object_path]).Vg
 
-			path = vg.Reduce(False, [vg.Pvs[0]], -1, {})
+			path = self.handle_return(
+				vg.Reduce(False, [vg.Pvs[0]], g_tmo, {})
+			)
 			self.assertTrue(path == '/')
 			self.assertEqual(self._refresh(), 0)
 
@@ -271,7 +301,7 @@ class TestDbusService(unittest.TestCase):
 
 		new_name = 'renamed_' + vg.Name
 
-		path = vg.Rename(new_name, -1, {})
+		path = self.handle_return(vg.Rename(new_name, g_tmo, {}))
 		self.assertTrue(path == '/')
 		self.assertEqual(self._refresh(), 0)
 
@@ -326,8 +356,9 @@ class TestDbusService(unittest.TestCase):
 		for i in range(0, 5):
 			lv_name = rs(8, '_lv')
 
-			thin_lv_path = thin_pool.ThinPool.LvCreate(
-				lv_name, mib(16), -1, {})[0]
+			thin_lv_path = self.handle_return(
+				thin_pool.ThinPool.LvCreate(
+					lv_name, mib(16), g_tmo, {}))
 
 			self.assertTrue(thin_lv_path != '/')
 
@@ -339,8 +370,8 @@ class TestDbusService(unittest.TestCase):
 
 		# Rename the VG
 		new_name = 'renamed_' + vg.Name
+		path = self.handle_return(vg.Rename(new_name, g_tmo, {}))
 
-		path = vg.Rename(new_name, -1, {})
 		self.assertTrue(path == '/')
 		self.assertEqual(self._refresh(), 0)
 
@@ -366,8 +397,8 @@ class TestDbusService(unittest.TestCase):
 
 	def _test_lv_create(self, method, params, vg):
 		lv = None
-		path = method(*params)[0]
 
+		path = self.handle_return(method(*params))
 		self.assertTrue(vg)
 
 		if path:
@@ -386,7 +417,7 @@ class TestDbusService(unittest.TestCase):
 		self._test_lv_create(
 			vg.LvCreate,
 			(rs(8, '_lv'), mib(4),
-			dbus.Array([], '(ott)'), -1, {}), vg)
+			 dbus.Array([], '(ott)'), g_tmo, {}), vg)
 
 	def test_lv_create_job(self):
 
@@ -404,7 +435,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), mib(4), False, -1, {}), vg)
+			(rs(8, '_lv'), mib(4), False, g_tmo, {}), vg)
 
 	def test_lv_create_striped(self):
 		pv_paths = []
@@ -415,7 +446,7 @@ class TestDbusService(unittest.TestCase):
 		self._test_lv_create(
 			vg.LvCreateStriped,
 			(rs(8, '_lv'), mib(4), 2, 8, False,
-			-1, {}), vg)
+			 g_tmo, {}), vg)
 
 	def test_lv_create_mirror(self):
 		pv_paths = []
@@ -424,7 +455,7 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(vg.LvCreateMirror,
-			(rs(8, '_lv'), mib(4), 2, -1, {}), vg)
+							 (rs(8, '_lv'), mib(4), 2, g_tmo, {}), vg)
 
 	def test_lv_create_raid(self):
 		pv_paths = []
@@ -433,8 +464,8 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(vg.LvCreateRaid,
-			(rs(8, '_lv'), 'raid4',
-			mib(16), 2, 8, -1, {}), vg)
+							 (rs(8, '_lv'), 'raid4',
+							  mib(16), 2, 8, g_tmo, {}), vg)
 
 	def _create_lv(self, thinpool=False, size=None, vg=None):
 
@@ -450,7 +481,7 @@ class TestDbusService(unittest.TestCase):
 
 		return self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), size, thinpool, -1, {}), vg)
+			(rs(8, '_lv'), size, thinpool, g_tmo, {}), vg)
 
 	def test_lv_create_rounding(self):
 		self._create_lv(size=(mib(2) + 13))
@@ -466,7 +497,8 @@ class TestDbusService(unittest.TestCase):
 		prev_path = path
 
 		new_name = 'renamed_' + lv.LvCommon.Name
-		lv.Lv.Rename(new_name, -1, {})
+
+		self.handle_return(lv.Lv.Rename(new_name, g_tmo, {}))
 
 		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(new_name)
 
@@ -480,7 +512,7 @@ class TestDbusService(unittest.TestCase):
 						"%s" % (tp.object_path))
 
 		new_name = 'renamed_' + tp.LvCommon.Name
-		tp.Lv.Rename(new_name, -1, {})
+		self.handle_return(tp.Lv.Rename(new_name, g_tmo, {}))
 		tp.update()
 		self.assertEqual(self._refresh(), 0)
 		self.assertEqual(new_name, tp.LvCommon.Name)
@@ -493,17 +525,23 @@ class TestDbusService(unittest.TestCase):
 		# thinpool interface too
 		tp = self._create_lv(True)
 
-		thin_path = tp.ThinPool.LvCreate(
-			rs(10, '_thin_lv'), mib(8), -1, {})[0]
+		thin_path = self.handle_return(
+			tp.ThinPool.LvCreate(
+				rs(10, '_thin_lv'), mib(8), g_tmo, {})
+		)
 
 		lv = ClientProxy(self.bus, thin_path)
-		rc = lv.Lv.Rename('rename_test' + lv.LvCommon.Name, -1, {})
+
+		rc = self.handle_return(
+			lv.Lv.Rename('rename_test' + lv.LvCommon.Name, g_tmo, {})
+		)
+
 		self.assertTrue(rc == '/')
 		self.assertEqual(self._refresh(), 0)
 
 	def test_lv_remove(self):
 		lv = self._create_lv().Lv
-		rc = lv.Remove(-1, {})
+		rc = self.handle_return(lv.Remove(g_tmo, {}))
 		self.assertTrue(rc == '/')
 		self.assertEqual(self._refresh(), 0)
 
@@ -511,23 +549,10 @@ class TestDbusService(unittest.TestCase):
 		lv_p = self._create_lv()
 		ss_name = 'ss_' + lv_p.LvCommon.Name
 
-		# Test waiting to complete
-		ss, job = lv_p.Lv.Snapshot(ss_name, 0, -1, {})
-		self.assertTrue(ss != '/')
-		self.assertTrue(job == '/')
+		rc = self.handle_return(lv_p.Lv.Snapshot(
+			ss_name, 0, g_tmo, {}))
 
-		snapshot = ClientProxy(self.bus, ss)
-		self.assertTrue(snapshot.LvCommon.Name == ss_name)
-
-		self.assertEqual(self._refresh(), 0)
-
-		# Test getting a job returned immediately
-		rc, job = lv_p.Lv.Snapshot('ss2_' + lv_p.LvCommon.Name, 0, 0, {})
-		self.assertTrue(rc == '/')
-		self.assertTrue(job != '/')
-		self._wait_for_job(job)
-
-		self.assertEqual(self._refresh(), 0)
+		self.assertTrue(rc != '/')
 
 	# noinspection PyUnresolvedReferences
 	def _wait_for_job(self, j_path):
@@ -563,8 +588,8 @@ class TestDbusService(unittest.TestCase):
 		pv_proxy = ClientProxy(self.bus, pv[0])
 
 		self._test_lv_create(vg.LvCreate, (rs(8, '_lv'), mib(4),
-			dbus.Array([[pv_proxy.object_path, 0, (pv_proxy.Pv.PeCount - 1)]],
-			'(ott)'), -1, {}), vg)
+										   dbus.Array([[pv_proxy.object_path, 0, (pv_proxy.Pv.PeCount - 1)]],
+			'(ott)'), g_tmo, {}), vg)
 
 	def test_lv_resize(self):
 
@@ -590,12 +615,17 @@ class TestDbusService(unittest.TestCase):
 
 			if len(pv_empty):
 				p = ClientProxy(self.bus, pv_empty[0])
-				rc = lv.Lv.Resize(
-					size,
-					dbus.Array([[p.object_path, 0, p.Pv.PeCount - 1]], '(oii)'),
-					-1, {})
+
+				rc = self.handle_return(
+					lv.Lv.Resize(
+						size,
+						dbus.Array([[p.object_path, 0, p.Pv.PeCount - 1]],
+								   '(oii)'),
+						g_tmo, {}))
 			else:
-				rc = lv.Lv.Resize(size, dbus.Array([], '(oii)'), -1, {})
+				rc = self.handle_return(
+					lv.Lv.Resize(
+						size, dbus.Array([], '(oii)'), g_tmo, {}))
 
 			self.assertEqual(rc, '/')
 			self.assertEqual(self._refresh(), 0)
@@ -617,7 +647,8 @@ class TestDbusService(unittest.TestCase):
 		lv = self._create_lv(vg=vg)
 
 		with self.assertRaises(dbus.exceptions.DBusException):
-			lv.Lv.Resize(lv.LvCommon.SizeBytes, dbus.Array([], '(oii)'), -1, {})
+				lv.Lv.Resize(lv.LvCommon.SizeBytes, dbus.Array([], '(oii)'),
+							 -1, {})
 
 	def test_lv_move(self):
 		lv = self._create_lv()
@@ -625,8 +656,12 @@ class TestDbusService(unittest.TestCase):
 		pv_path_move = str(lv.LvCommon.Devices[0][0])
 
 		# Test moving a specific LV
-		job = lv.Lv.Move(pv_path_move, (0, 0), dbus.Array([], '(oii)'), 0, {})
-		self._wait_for_job(job)
+		rc = self.handle_return(
+			lv.Lv.Move(
+				pv_path_move,
+				(0, 0),
+				dbus.Array([], '(oii)'), g_tmo, {}))
+		self.assertTrue(rc == '/')
 		self.assertEqual(self._refresh(), 0)
 
 		lv.update()
@@ -638,12 +673,12 @@ class TestDbusService(unittest.TestCase):
 		lv_p = self._create_lv()
 		lv_p.update()
 
-		lv_p.Lv.Deactivate(0, -1, {})
+		self.handle_return(lv_p.Lv.Deactivate(0, g_tmo, {}))
 		lv_p.update()
 		self.assertFalse(lv_p.LvCommon.Active)
 		self.assertEqual(self._refresh(), 0)
 
-		lv_p.Lv.Activate(0, -1, {})
+		self.handle_return(lv_p.Lv.Activate(0, g_tmo, {}))
 
 		lv_p.update()
 		self.assertTrue(lv_p.LvCommon.Active)
@@ -651,7 +686,9 @@ class TestDbusService(unittest.TestCase):
 
 		# Try control flags
 		for i in range(0, 5):
-			lv_p.Lv.Activate(1 << i, -1, {})
+
+			self.handle_return(lv_p.Lv.Activate(1 << i, g_tmo, {}))
+
 			self.assertTrue(lv_p.LvCommon.Active)
 			self.assertEqual(self._refresh(), 0)
 
@@ -661,8 +698,10 @@ class TestDbusService(unittest.TestCase):
 		# Test moving without being LV specific
 		vg = ClientProxy(self.bus, lv.LvCommon.Vg).Vg
 		pv_to_move = str(lv.LvCommon.Devices[0][0])
-		job = vg.Move(pv_to_move, (0, 0), dbus.Array([], '(oii)'), 0, {})
-		self._wait_for_job(job)
+
+		rc = self.handle_return(vg.Move(
+			pv_to_move, (0, 0), dbus.Array([], '(oii)'), 0, {}))
+		self.assertEqual(rc, '/')
 		self.assertEqual(self._refresh(), 0)
 
 		# Test Vg.Move
@@ -680,10 +719,11 @@ class TestDbusService(unittest.TestCase):
 		# Fetch the destination
 		pv = ClientProxy(self.bus, dst).Pv
 
-		# Test range, move it to the middle of the new destination and blocking
-		# blocking for it to complete
-		job = vg.Move(
-			location, (0, 0), [(dst, pv.PeCount / 2, 0), ], -1, {})
+		# Test range, move it to the middle of the new destination
+		job = self.handle_return(
+			vg.Move(
+				location, (0, 0),
+				[(dst, pv.PeCount / 2, 0), ], g_tmo, {}))
 		self.assertEqual(job, '/')
 		self.assertEqual(self._refresh(), 0)
 
@@ -720,9 +760,10 @@ class TestDbusService(unittest.TestCase):
 
 			vg_proxy.update()
 			if vg_proxy.Vg.FreeCount > 0:
-				obj_path, job = vg_proxy.Vg.LvCreateLinear(
-					rs(8, "_lv"), mib(4), False, -1, {})
-				self.assertTrue(job == '/')
+				job = self.handle_return(
+					vg_proxy.Vg.LvCreateLinear(
+						rs(8, "_lv"), mib(4), False, g_tmo, {}))
+				self.assertTrue(job != '/')
 			else:
 				# We ran out of space, test will probably fail
 				break
@@ -777,14 +818,19 @@ class TestDbusService(unittest.TestCase):
 			pvs.append(ClientProxy(self.bus, p).Pv)
 
 		for tags_value in [['hello'], ['foo', 'bar']]:
-			rc = vg.PvTagsAdd(vg.Pvs, tags_value, -1, {})
+
+			rc = self.handle_return(
+				vg.PvTagsAdd(vg.Pvs, tags_value, g_tmo, {}))
 			self.assertTrue(rc == '/')
 
 			for p in pvs:
 				p.update()
 				self.assertTrue(sorted(tags_value) == p.Tags)
 
-			vg.PvTagsDel(vg.Pvs, tags_value, -1, {})
+			rc = self.handle_return(
+				vg.PvTagsDel(vg.Pvs, tags_value, g_tmo, {}))
+			self.assertEqual(rc, '/')
+
 			for p in pvs:
 				p.update()
 				self.assertTrue([] == p.Tags)
@@ -794,10 +840,12 @@ class TestDbusService(unittest.TestCase):
 
 		t = ['Testing', 'tags']
 
-		vg.TagsAdd(t, -1, {})
+		self.handle_return(vg.TagsAdd(t, g_tmo, {}))
+
 		vg.update()
 		self.assertTrue(t == vg.Tags)
-		vg.TagsDel(t, -1, {})
+
+		self.handle_return(vg.TagsDel(t, g_tmo, {}))
 		vg.update()
 		self.assertTrue([] == vg.Tags)
 
@@ -805,15 +853,18 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		lv = self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), mib(4), False, -1, {}),
+			(rs(8, '_lv'), mib(4), False, g_tmo, {}),
 			vg)
 
 		t = ['Testing', 'tags']
 
-		lv.Lv.TagsAdd(t, -1, {})
+		self.handle_return(
+			lv.Lv.TagsAdd(t, g_tmo, {}))
 		lv.update()
 		self.assertTrue(t == lv.LvCommon.Tags)
-		lv.Lv.TagsDel(t, -1, {})
+
+		self.handle_return(
+			lv.Lv.TagsDel(t, g_tmo, {}))
 		lv.update()
 		self.assertTrue([] == lv.LvCommon.Tags)
 
@@ -821,7 +872,9 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 
 		for p in ['anywhere', 'contiguous', 'cling', 'normal']:
-			rc = vg.AllocationPolicySet(p, -1, {})
+			rc = self.handle_return(
+				vg.AllocationPolicySet(p, g_tmo, {}))
+
 			self.assertEqual(rc, '/')
 			vg.update()
 
@@ -834,7 +887,8 @@ class TestDbusService(unittest.TestCase):
 		# BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
 		# TODO: Add a test back for larger values here when bug is resolved
 		for p in [0, 1, 10, 100, 100, 1024, 2 ** 32 - 1]:
-			rc = vg.MaxPvSet(p, -1, {})
+			rc = self.handle_return(
+				vg.MaxPvSet(p, g_tmo, {}))
 			self.assertEqual(rc, '/')
 			vg.update()
 			self.assertTrue(vg.MaxPv == p, "Expected %s != Actual %s" %
@@ -846,7 +900,7 @@ class TestDbusService(unittest.TestCase):
 		# BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
 		# TODO: Add a test back for larger values here when bug is resolved
 		for p in [0, 1, 10, 100, 100, 1024, 2 ** 32 - 1]:
-			rc = vg.MaxLvSet(p, -1, {})
+			rc = self.handle_return(vg.MaxLvSet(p, g_tmo, {}))
 			self.assertEqual(rc, '/')
 			vg.update()
 			self.assertTrue(vg.MaxLv == p, "Expected %s != Actual %s" %
@@ -861,7 +915,7 @@ class TestDbusService(unittest.TestCase):
 		if False:
 			vg = self._vg_create().Vg
 			prev_uuid = vg.Uuid
-			rc = vg.UuidGenerate(-1, {})
+			rc = self.handle_return(vg.UuidGenerate(g_tmo, {}))
 			self.assertEqual(rc, '/')
 			vg.update()
 			self.assertTrue(vg.Uuid != prev_uuid, "Expected %s != Actual %s" %
@@ -871,20 +925,23 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), mib(4), False, -1, {}),
+			(rs(8, '_lv'), mib(4), False, g_tmo, {}),
 			vg)
 
 		vg.update()
 
-		vg.Deactivate(0, -1, {})
+		rc = self.handle_return(vg.Deactivate(0, g_tmo, {}))
+		self.assertEqual(rc, '/')
 		self.assertEqual(self._refresh(), 0)
 
-		vg.Activate(0, -1, {})
+		rc = self.handle_return(vg.Activate(0, g_tmo, {}))
+
+		self.assertEqual(rc, '/')
 		self.assertEqual(self._refresh(), 0)
 
 		# Try control flags
 		for i in range(0, 5):
-			vg.Activate(1 << i, -1, {})
+			self.handle_return(vg.Activate(1 << i, g_tmo, {}))
 
 	def test_pv_resize(self):
 
@@ -897,12 +954,13 @@ class TestDbusService(unittest.TestCase):
 
 			new_size = original_size / 2
 
-			pv.ReSize(new_size, -1, {})
+			self.handle_return(pv.ReSize(new_size, g_tmo, {}))
+
 			self.assertEqual(self._refresh(), 0)
 			pv.update()
 
 			self.assertTrue(pv.SizeBytes != original_size)
-			pv.ReSize(0, -1, {})
+			self.handle_return(pv.ReSize(0, g_tmo, {}))
 			self.assertEqual(self._refresh(), 0)
 			pv.update()
 			self.assertTrue(pv.SizeBytes == original_size)
@@ -917,11 +975,14 @@ class TestDbusService(unittest.TestCase):
 
 		pv = ClientProxy(self.bus, vg.Pvs[0]).Pv
 
-		pv.AllocationEnabled(False, -1, {})
+		self.handle_return(pv.AllocationEnabled(False, g_tmo, {}))
+
 		pv.update()
 		self.assertFalse(pv.Allocatable)
 
-		pv.AllocationEnabled(True, -1, {})
+		self.handle_return(pv.AllocationEnabled(True, g_tmo, {}))
+
+		self.handle_return(pv.AllocationEnabled(True, g_tmo, {}))
 		pv.update()
 		self.assertTrue(pv.Allocatable)
 
@@ -938,24 +999,30 @@ class TestDbusService(unittest.TestCase):
 		mgr = self._manager().Manager
 
 		self.assertEqual(
-			mgr.PvScan(
-				False, True, dbus.Array([], 's'),
-				dbus.Array([], '(ii)'), -1, {}), '/')
+			self.handle_return(
+				mgr.PvScan(False, True, dbus.Array([], 's'),
+						   dbus.Array([], '(ii)'), g_tmo, {})), '/')
+
 		self.assertEqual(self._refresh(), 0)
 		self.assertEqual(
-			mgr.PvScan(
-				False, False,
-				dbus.Array([], 's'),
-				dbus.Array([], '(ii)'), -1, {}), '/')
+			self.handle_return(
+				mgr.PvScan(
+					False, False,
+					dbus.Array([], 's'),
+					dbus.Array([], '(ii)'), g_tmo, {})), '/')
+
 		self.assertEqual(self._refresh(), 0)
 
 		block_path = []
 		for d in devices:
 			block_path.append(d['DEVNAME'])
 
-		self.assertEqual(mgr.PvScan(False, True,
-									block_path,
-									dbus.Array([], '(ii)'), -1, {}), '/')
+		self.assertEqual(
+			self.handle_return(
+				mgr.PvScan(
+					False, True,
+					block_path,
+					dbus.Array([], '(ii)'), g_tmo, {})), '/')
 
 		self.assertEqual(self._refresh(), 0)
 
@@ -963,18 +1030,23 @@ class TestDbusService(unittest.TestCase):
 		for d in devices:
 			mm.append((int(d['MAJOR']), int(d['MINOR'])))
 
-		self.assertEqual(mgr.PvScan(False, True,
-									block_path,
-									mm, -1, {}), '/')
+		self.assertEqual(
+
+			self.handle_return(
+				mgr.PvScan
+				(False, True,
+				 block_path,
+				 mm, g_tmo, {})
+			), '/')
 
 		self.assertEqual(self._refresh(), 0)
 
 		self.assertEqual(
-			mgr.PvScan(
-				False, True,
-				dbus.Array([], 's'),
-				mm, -1, {}), '/')
-
+			self.handle_return(
+				mgr.PvScan(
+					False, True,
+					dbus.Array([], 's'),
+					mm, g_tmo, {})), '/')
 		self.assertEqual(self._refresh(), 0)
 
 	@staticmethod
@@ -994,32 +1066,37 @@ class TestDbusService(unittest.TestCase):
 
 		lv_p = self._create_lv(size=mib(16))
 		ss_name = lv_p.LvCommon.Name + '_snap'
-		snapshot_path = lv_p.Lv.Snapshot(ss_name, ss_size, -1, {})[0]
+
+		snapshot_path = self.handle_return(
+			lv_p.Lv.Snapshot(ss_name, ss_size, g_tmo, {}))
+
 		ss = ClientProxy(self.bus, snapshot_path)
 
 		# Write some data to snapshot so merge takes some time
 		TestDbusService._write_some_data(ss.LvCommon.Path, ss_size / 2)
 
-		job_path = ss.Snapshot.Merge(0, {})
-
-		self.assertTrue(job_path != '/')
-		self._wait_for_job(job_path)
+		job_path = self.handle_return(ss.Snapshot.Merge(g_tmo, {}))
+		self.assertEqual(job_path, '/')
 
 	def test_snapshot_merge_thin(self):
 		# Create a thin LV, snapshot it and merge it
 		tp = self._create_lv(True)
 
-		thin_path = tp.ThinPool.LvCreate(
-			rs(10, '_thin_lv'), mib(10), -1, {})[0]
+		thin_path = self.handle_return(
+			tp.ThinPool.LvCreate(
+				rs(10, '_thin_lv'), mib(10), g_tmo, {}))
 
 		lv_p = ClientProxy(self.bus, thin_path)
 
 		ss_name = lv_p.LvCommon.Name + '_snap'
-		snapshot_path = lv_p.Lv.Snapshot(ss_name, 0, -1, {})[0]
+		snapshot_path = self.handle_return(
+			lv_p.Lv.Snapshot(ss_name, 0, g_tmo, {}))
+
 		ss = ClientProxy(self.bus, snapshot_path)
-		job_path = ss.Snapshot.Merge(0, {})
-		self.assertTrue(job_path != '/')
-		self._wait_for_job(job_path)
+		job_path = self.handle_return(
+			ss.Snapshot.Merge(g_tmo, {})
+		)
+		self.assertTrue(job_path == '/')
 
 	def _create_cache_pool(self, vg=None):
 
@@ -1029,8 +1106,9 @@ class TestDbusService(unittest.TestCase):
 		md = self._create_lv(size=(mib(8)), vg=vg)
 		data = self._create_lv(size=(mib(8)), vg=vg)
 
-		cache_pool_path = vg.CreateCachePool(
-			md.object_path, data.object_path, -1, {})[0]
+		cache_pool_path = self.handle_return(
+			vg.CreateCachePool(
+				md.object_path, data.object_path, g_tmo, {}))
 
 		cp = ClientProxy(self.bus, cache_pool_path)
 
@@ -1050,24 +1128,32 @@ class TestDbusService(unittest.TestCase):
 
 			lv_to_cache = self._create_lv(size=mib(8), vg=vg)
 
-			c_lv_path = cache_pool.CachePool.CacheLv(
-				lv_to_cache.object_path, -1, {})[0]
+			c_lv_path = self.handle_return(
+				cache_pool.CachePool.CacheLv(
+					lv_to_cache.object_path, g_tmo, {}))
 
 			cached_lv = ClientProxy(self.bus, c_lv_path)
 
-			uncached_lv_path = \
-				cached_lv.CachedLv.DetachCachePool(destroy_cache, -1, {})[0]
+			uncached_lv_path = self.handle_return(
+				cached_lv.CachedLv.DetachCachePool(
+					destroy_cache, g_tmo, {}))
 
 			self.assertTrue('/com/redhat/lvmdbus1/Lv' in
 							uncached_lv_path)
 
-			vg.Remove(-1, {})
+			rc = self.handle_return(vg.Remove(g_tmo, {}))
+			self.assertTrue(rc == '/')
 
 	def test_vg_change(self):
 		vg_proxy = self._vg_create()
-		result = vg_proxy.Vg.Change(-1, {'-a': 'ay'})
+
+		result = self.handle_return(vg_proxy.Vg.Change(
+			g_tmo, {'-a': 'ay'}))
 		self.assertTrue(result == '/')
-		result = vg_proxy.Vg.Change(-1, {'-a': 'n'})
+
+		result = self.handle_return(
+			vg_proxy.Vg.Change(g_tmo, {'-a': 'n'})
+		)
 		self.assertTrue(result == '/')
 
 	@staticmethod
@@ -1081,7 +1167,8 @@ class TestDbusService(unittest.TestCase):
 
 		# Pv device path
 		with self.assertRaises(dbus.exceptions.DBusException):
-			mgr.PvCreate("/dev/space in name", -1, {})
+			self.handle_return(
+				mgr.PvCreate("/dev/space in name", g_tmo, {}))
 
 		# VG Name testing...
 		# Go through all bad characters
@@ -1089,37 +1176,48 @@ class TestDbusService(unittest.TestCase):
 		bad_chars = TestDbusService._invalid_vg_lv_name_characters()
 		for c in bad_chars:
 			with self.assertRaises(dbus.exceptions.DBusException):
-				mgr.VgCreate("name%s" % (c), pv_paths, -1, {})
+				self.handle_return(
+					mgr.VgCreate("name%s" % (c), pv_paths, g_tmo, {}))
 
 		# Bad names
 		for bad in [".", ".."]:
 			with self.assertRaises(dbus.exceptions.DBusException):
-				mgr.VgCreate(bad, pv_paths, -1, {})
+				self.handle_return(
+					mgr.VgCreate(bad, pv_paths, g_tmo, {}))
 
 		# Exceed name length
 		for i in [128, 1024, 4096]:
 			with self.assertRaises(dbus.exceptions.DBusException):
-				mgr.VgCreate('T' * i, pv_paths, -1, {})
+				self.handle_return(
+					mgr.VgCreate('T' * i, pv_paths, g_tmo, {}))
 
 		# Create a VG and try to create LVs with different bad names
-		vg_path = mgr.VgCreate("test", pv_paths, -1, {})[0]
+		vg_path = self.handle_return(
+			mgr.VgCreate("test", pv_paths, g_tmo, {}))
+
 		vg_proxy = ClientProxy(self.bus, vg_path)
 
 		for c in bad_chars:
 			with self.assertRaises(dbus.exceptions.DBusException):
-				vg_proxy.Vg.LvCreateLinear(rs(8, '_lv') + c,
-					mib(4), False, -1, {})
+				self.handle_return(
+					vg_proxy.Vg.LvCreateLinear(
+						rs(8, '_lv') + c,
+						mib(4), False, g_tmo, {}))
 
 		for r in ("_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
 			"_pmspare", "_rimage", "_rmeta", "_tdata", "_tmeta", "_vorigin"):
 			with self.assertRaises(dbus.exceptions.DBusException):
-				vg_proxy.Vg.LvCreateLinear(rs(8, '_lv') + r,
-					mib(4), False, -1, {})
+				self.handle_return(
+					vg_proxy.Vg.LvCreateLinear(
+						rs(8, '_lv') + r,
+						mib(4), False, g_tmo, {}))
 
 		for r in ("snapshot", "pvmove"):
 			with self.assertRaises(dbus.exceptions.DBusException):
-				vg_proxy.Vg.LvCreateLinear(r + rs(8, '_lv'),
-					mib(4), False, -1, {})
+				self.handle_return(
+					vg_proxy.Vg.LvCreateLinear(
+						r + rs(8, '_lv'),
+						mib(4), False, g_tmo, {}))
 
 	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
 
@@ -1131,27 +1229,35 @@ class TestDbusService(unittest.TestCase):
 		mgr = self.objs[MANAGER_INT][0].Manager
 		pv_paths = [self.objs[PV_INT][0].object_path]
 
-		vg_path = mgr.VgCreate("test", pv_paths, -1, {})[0]
+		vg_path = self.handle_return(
+			mgr.VgCreate("test", pv_paths, g_tmo, {}))
 		vg_proxy = ClientProxy(self.bus, vg_path)
 
 		for c in self._invalid_tag_characters():
 			with self.assertRaises(dbus.exceptions.DBusException):
-				vg_proxy.Vg.TagsAdd([c], -1, {})
+				self.handle_return(
+					vg_proxy.Vg.TagsAdd(
+						[c], g_tmo, {}))
 
 		for c in self._invalid_tag_characters():
 			with self.assertRaises(dbus.exceptions.DBusException):
-				vg_proxy.Vg.TagsAdd(["a%sb" % (c)], -1, {})
+				self.handle_return(
+					vg_proxy.Vg.TagsAdd(
+						["a%sb" % (c)], g_tmo, {}))
 
 	def test_tag_names(self):
 		mgr = self.objs[MANAGER_INT][0].Manager
 		pv_paths = [self.objs[PV_INT][0].object_path]
 
-		vg_path = mgr.VgCreate("test", pv_paths, -1, {})[0]
+		vg_path = self.handle_return(
+			mgr.VgCreate("test", pv_paths, g_tmo, {}))
 		vg_proxy = ClientProxy(self.bus, vg_path)
 
 		for i in range(1, 64):
 			tag = rs(i, "", self._ALLOWABLE_TAG_CH)
-			r = vg_proxy.Vg.TagsAdd([tag], -1, {})
+
+			r = self.handle_return(
+				vg_proxy.Vg.TagsAdd([tag], g_tmo, {}))
 			self.assertTrue(r == '/')
 			vg_proxy.update()
 
@@ -1165,12 +1271,15 @@ class TestDbusService(unittest.TestCase):
 		mgr = self.objs[MANAGER_INT][0].Manager
 		pv_paths = [self.objs[PV_INT][0].object_path]
 
-		vg_path = mgr.VgCreate("test", pv_paths, -1, {})[0]
+		vg_path = self.handle_return(
+			mgr.VgCreate("test", pv_paths, g_tmo, {}))
 		vg_proxy = ClientProxy(self.bus, vg_path)
 
 		tag = '--h/K.6g0A4FOEatf3+k_nI/Yp&L_u2oy-=j649x:+dUcYWPEo6.IWT0c'
 
-		r = vg_proxy.Vg.TagsAdd([tag], -1, {})
+		r = self.handle_return(
+			vg_proxy.Vg.TagsAdd([tag], g_tmo, {})
+		)
 		self.assertTrue(r == '/')
 		vg_proxy.update()
 
@@ -1190,9 +1299,14 @@ if __name__ == '__main__':
 	else:
 		print('\n *** Testing fork & exec *** \n')
 		unittest.main(exit=False)
+		g_tmo = 15
+		unittest.main(exit=False)
 		# Test lvm shell
 		print('\n *** Testing lvm shell *** \n')
 		if set_execution(True):
+			g_tmo = 0
+			unittest.main(exit=False)
+			g_tmo = 15
 			unittest.main()
 		else:
 			print("WARNING: Unable to dynamically configure "


