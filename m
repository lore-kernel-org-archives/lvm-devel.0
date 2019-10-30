From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:43 -0400
Subject: master - lvmdbustest.py: WS corrections
Message-ID: <201910301544.x9UFihjG016803@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e1d3a6c552e8d23837c17934a83c3925cd40252d
Commit:        e1d3a6c552e8d23837c17934a83c3925cd40252d
Parent:        df2292020bd9298d511e4e2fb6a54fe0cb6e7607
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 9 11:45:41 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: WS corrections

---
 test/dbus/lvmdbustest.py |  123 ++++++++++++++++++++++------------------------
 1 files changed, 58 insertions(+), 65 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index c589fd1..a9d7fac 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -119,8 +119,8 @@ def get_objects():
 	object_manager_object = bus.get_object(
 		BUS_NAME, "/com/redhat/lvmdbus1", introspect=False)
 
-	manager_interface = dbus.Interface(object_manager_object,
-							"org.freedesktop.DBus.ObjectManager")
+	manager_interface = dbus.Interface(
+		object_manager_object, "org.freedesktop.DBus.ObjectManager")
 
 	objects = manager_interface.GetManagedObjects()
 
@@ -166,8 +166,8 @@ def call_lvm(command):
 	# in different locations on the same box
 	command.insert(0, LVM_EXECUTABLE)
 
-	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True,
-					env=os.environ)
+	process = Popen(
+		command, stdout=PIPE, stderr=PIPE, close_fds=True, env=os.environ)
 	out = process.communicate()
 
 	stdout_text = bytes(out[0]).decode("utf-8")
@@ -391,10 +391,8 @@ class TestDbusService(unittest.TestCase):
 		)
 
 		# Get thin pool client proxy
-		thin_pool = ClientProxy(self.bus, thin_pool_path,
-								interfaces=(LV_COMMON_INT,
-											LV_INT,
-											THINPOOL_INT))
+		intf = (LV_COMMON_INT, LV_INT, THINPOOL_INT)
+		thin_pool = ClientProxy(self.bus, thin_pool_path, interfaces=intf)
 
 		return vg, thin_pool
 
@@ -420,10 +418,9 @@ class TestDbusService(unittest.TestCase):
 		)
 
 		# Get object proxy for cached thin pool
-		cached_thin_pool_object = ClientProxy(self.bus, cached_thin_pool_path,
-												interfaces=(LV_COMMON_INT,
-															LV_INT,
-															THINPOOL_INT))
+		intf = (LV_COMMON_INT, LV_INT, THINPOOL_INT)
+		cached_thin_pool_object = ClientProxy(
+			self.bus, cached_thin_pool_path, interfaces=intf)
 
 		# Check properties on cache pool
 		self.assertTrue(cached_thin_pool_object.ThinPool.DataLv != '/')
@@ -494,8 +491,8 @@ class TestDbusService(unittest.TestCase):
 		lv_paths = vg.Lvs
 
 		for l in lv_paths:
-			lv_proxy = ClientProxy(self.bus, l,
-								   interfaces=(LV_COMMON_INT,)).LvCommon
+			lv_proxy = ClientProxy(
+				self.bus, l, interfaces=(LV_COMMON_INT,)).LvCommon
 			self.assertTrue(
 				lv_proxy.Vg == vg.object_path, "%s != %s" %
 				(lv_proxy.Vg, vg.object_path))
@@ -547,8 +544,8 @@ class TestDbusService(unittest.TestCase):
 		hidden_lv_paths = lv_common_object.HiddenLvs
 
 		for h in hidden_lv_paths:
-			h_lv = ClientProxy(self.bus, h,
-								interfaces=(LV_COMMON_INT,)).LvCommon
+			h_lv = ClientProxy(
+				self.bus, h, interfaces=(LV_COMMON_INT,)).LvCommon
 
 			if len(h_lv.HiddenLvs) > 0:
 				self._verify_hidden_lookups(h_lv, vgname)
@@ -634,8 +631,8 @@ class TestDbusService(unittest.TestCase):
 		lv = self._test_lv_create(
 			vg.LvCreate,
 			(dbus.String(lv_name), dbus.UInt64(mib(4)),
-			dbus.Array([], signature='(ott)'), dbus.Int32(g_tmo),
-			EOD), vg, LV_BASE_INT)
+				dbus.Array([], signature='(ott)'), dbus.Int32(g_tmo),
+				EOD), vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def test_lv_create_job(self):
@@ -660,8 +657,7 @@ class TestDbusService(unittest.TestCase):
 		lv = self._test_lv_create(
 			vg.LvCreateLinear,
 			(dbus.String(lv_name), dbus.UInt64(mib(4)), dbus.Boolean(False),
-			dbus.Int32(g_tmo), EOD),
-			vg, LV_BASE_INT)
+				dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def _all_pv_object_paths(self):
@@ -673,9 +669,8 @@ class TestDbusService(unittest.TestCase):
 		lv = self._test_lv_create(
 			vg.LvCreateStriped,
 			(dbus.String(lv_name), dbus.UInt64(mib(4)),
-			dbus.UInt32(2), dbus.UInt32(8), dbus.Boolean(False),
-			dbus.Int32(g_tmo), EOD),
-			vg, LV_BASE_INT)
+				dbus.UInt32(2), dbus.UInt32(8), dbus.Boolean(False),
+				dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def test_lv_create_mirror(self):
@@ -684,7 +679,7 @@ class TestDbusService(unittest.TestCase):
 		lv = self._test_lv_create(
 			vg.LvCreateMirror,
 			(dbus.String(lv_name), dbus.UInt64(mib(4)), dbus.UInt32(2),
-			dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
+				dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def test_lv_create_raid(self):
@@ -693,10 +688,8 @@ class TestDbusService(unittest.TestCase):
 		lv = self._test_lv_create(
 			vg.LvCreateRaid,
 			(dbus.String(lv_name), dbus.String('raid5'), dbus.UInt64(mib(16)),
-			dbus.UInt32(2), dbus.UInt32(8), dbus.Int32(g_tmo),
-			EOD),
-			vg,
-			LV_BASE_INT)
+				dbus.UInt32(2), dbus.UInt32(8), dbus.Int32(g_tmo), EOD),
+			vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def _create_lv(self, thinpool=False, size=None, vg=None, suffix=None):
@@ -716,7 +709,7 @@ class TestDbusService(unittest.TestCase):
 		lv = self._test_lv_create(
 			vg.LvCreateLinear,
 			(dbus.String(lv_name), dbus.UInt64(size),
-			dbus.Boolean(thinpool), dbus.Int32(g_tmo), EOD),
+				dbus.Boolean(thinpool), dbus.Int32(g_tmo), EOD),
 			vg, interfaces)
 
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
@@ -737,8 +730,8 @@ class TestDbusService(unittest.TestCase):
 
 		new_name = 'renamed_' + lv.LvCommon.Name
 
-		self.handle_return(lv.Lv.Rename(dbus.String(new_name),
-										dbus.Int32(g_tmo), EOD))
+		self.handle_return(
+			lv.Lv.Rename(dbus.String(new_name), dbus.Int32(g_tmo), EOD))
 
 		path = self._lookup(new_name)
 
@@ -774,8 +767,8 @@ class TestDbusService(unittest.TestCase):
 		)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), thin_path)
 
-		lv = ClientProxy(self.bus, thin_path,
-						 interfaces=(LV_COMMON_INT, LV_INT))
+		lv = ClientProxy(
+			self.bus, thin_path, interfaces=(LV_COMMON_INT, LV_INT))
 		return vg, thin_path, lv
 
 	# noinspection PyUnresolvedReferences
@@ -815,7 +808,7 @@ class TestDbusService(unittest.TestCase):
 
 		self.assertTrue(rc != '/')
 
-	# noinspection PyUnresolvedReferences
+	# noinspection PyUnresolvedReferences,PyUnusedLocal
 	def _wait_for_job(self, j_path):
 		rc = None
 		j = ClientProxy(self.bus, j_path, interfaces=(JOB_INT, )).Job
@@ -850,8 +843,9 @@ class TestDbusService(unittest.TestCase):
 			vg.LvCreate, (
 				dbus.String(lv_name),
 				dbus.UInt64(mib(4)),
-				dbus.Array([[pvp.object_path, 0, (pvp.Pv.PeCount - 1)]],
-				signature='(ott)'),
+				dbus.Array(
+					[[pvp.object_path, 0, (pvp.Pv.PeCount - 1)]],
+					signature='(ott)'),
 				dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
@@ -909,10 +903,10 @@ class TestDbusService(unittest.TestCase):
 		lv = self._create_lv(vg=vg)
 
 		with self.assertRaises(dbus.exceptions.DBusException):
-				lv.Lv.Resize(
-					dbus.UInt64(lv.LvCommon.SizeBytes),
-					dbus.Array([], '(oii)'),
-					dbus.Int32(-1), EOD)
+			lv.Lv.Resize(
+				dbus.UInt64(lv.LvCommon.SizeBytes),
+				dbus.Array([], '(oii)'),
+				dbus.Int32(-1), EOD)
 
 	def test_lv_move(self):
 		lv = self._create_lv()
@@ -1071,6 +1065,7 @@ class TestDbusService(unittest.TestCase):
 
 		return rc
 
+	# noinspection PyUnusedLocal
 	def test_job_handling_timer(self):
 
 		yes = False
@@ -1247,8 +1242,9 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(len(self.objs[PV_INT]) > 0)
 
 		if len(self.objs[PV_INT]) > 0:
-			pv = ClientProxy(self.bus, self.objs[PV_INT][0].object_path,
-								interfaces=(PV_INT, )).Pv
+			pv = ClientProxy(
+				self.bus, self.objs[PV_INT][0].object_path,
+				interfaces=(PV_INT, )).Pv
 
 			original_size = pv.SizeBytes
 
@@ -1365,8 +1361,8 @@ class TestDbusService(unittest.TestCase):
 				dbus.Int32(g_tmo),
 				EOD))
 
-		ss = ClientProxy(self.bus, snapshot_path,
-							interfaces=(LV_COMMON_INT, LV_INT, SNAPSHOT_INT, ))
+		intf = (LV_COMMON_INT, LV_INT, SNAPSHOT_INT, )
+		ss = ClientProxy(self.bus, snapshot_path, interfaces=intf)
 
 		# Write some data to snapshot so merge takes some time
 		TestDbusService._write_some_data(ss.LvCommon.Path, ss_size // 2)
@@ -1389,8 +1385,8 @@ class TestDbusService(unittest.TestCase):
 				dbus.Int32(g_tmo),
 				EOD))
 
-		ss = ClientProxy(self.bus, snapshot_path,
-							interfaces=(LV_INT, LV_COMMON_INT, SNAPSHOT_INT))
+		intf = (LV_INT, LV_COMMON_INT, SNAPSHOT_INT)
+		ss = ClientProxy(self.bus, snapshot_path, interfaces=intf)
 
 		job_path = self.handle_return(
 			ss.Snapshot.Merge(
@@ -1413,8 +1409,8 @@ class TestDbusService(unittest.TestCase):
 				dbus.Int32(g_tmo),
 				EOD))
 
-		cp = ClientProxy(self.bus, cache_pool_path,
-							interfaces=(CACHE_POOL_INT, ))
+		intf = (CACHE_POOL_INT, )
+		cp = ClientProxy(self.bus, cache_pool_path, interfaces=intf)
 
 		return vg, cp
 
@@ -1438,9 +1434,8 @@ class TestDbusService(unittest.TestCase):
 					dbus.Int32(g_tmo),
 					EOD))
 
-			cached_lv = ClientProxy(self.bus, c_lv_path,
-									interfaces=(LV_COMMON_INT, LV_INT,
-												CACHE_LV_INT))
+			intf = (LV_COMMON_INT, LV_INT, CACHE_LV_INT)
+			cached_lv = ClientProxy(self.bus, c_lv_path, interfaces=intf)
 
 			uncached_lv_path = self.handle_return(
 				cached_lv.CachedLv.DetachCachePool(
@@ -1475,13 +1470,12 @@ class TestDbusService(unittest.TestCase):
 		cur_objs, _ = get_objects()
 		self.assertEqual(len(cur_objs[CACHE_LV_INT]), 2)
 
-		cached_lv = ClientProxy(self.bus, c_lv_path,
-								interfaces=(LV_COMMON_INT, LV_INT,
-											CACHE_LV_INT))
+		intf = (LV_COMMON_INT, LV_INT, CACHE_LV_INT)
+		cached_lv = ClientProxy(self.bus, c_lv_path, interfaces=intf)
 		new_name = 'renamed_' + cached_lv.LvCommon.Name
 
-		self.handle_return(cached_lv.Lv.Rename(dbus.String(new_name),
-												dbus.Int32(g_tmo), EOD))
+		self.handle_return(
+			cached_lv.Lv.Rename(dbus.String(new_name), dbus.Int32(g_tmo), EOD))
 
 		# Make sure we only have expected # of cached LV
 		cur_objs, _ = get_objects()
@@ -1707,23 +1701,22 @@ class TestDbusService(unittest.TestCase):
 		pv = ClientProxy(self.bus, pv_object_path, interfaces=(PV_INT,))
 
 		self.assertEqual(pv.Pv.Vg, vg.object_path)
-		self.assertIn(pv_object_path, vg.Vg.Pvs,
-						"Expecting PV object path in Vg.Pvs")
+		self.assertIn(
+			pv_object_path, vg.Vg.Pvs, "Expecting PV object path in Vg.Pvs")
 
-		lv = self._create_lv(vg=vg.Vg, size=vg.Vg.FreeBytes,
-								suffix="_pv")
+		lv = self._create_lv(
+			vg=vg.Vg, size=vg.Vg.FreeBytes, suffix="_pv")
 		device_path = '/dev/%s/%s' % (vg.Vg.Name, lv.LvCommon.Name)
 		new_pv_object_path = self._pv_create(device_path)
 
 		vg.update()
 
 		self.assertEqual(lv.LvCommon.Vg, vg.object_path)
-		self.assertIn(lv.object_path, vg.Vg.Lvs,
-						"Expecting LV object path in Vg.Lvs")
+		self.assertIn(
+			lv.object_path, vg.Vg.Lvs, "Expecting LV object path in Vg.Lvs")
 
-		new_pv_proxy = ClientProxy(self.bus,
-									new_pv_object_path,
-									interfaces=(PV_INT, ))
+		new_pv_proxy = ClientProxy(
+			self.bus, new_pv_object_path, interfaces=(PV_INT, ))
 		self.assertEqual(new_pv_proxy.Pv.Name, device_path)
 
 		return new_pv_object_path


