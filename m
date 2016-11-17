From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:44 +0000 (UTC)
Subject: master - lvmdbustest.py: Reduce test client introspection calls
Message-ID: <20161117173644.B45A060D85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=61f6be7d2b56177df4a855c048a954ced055ab0a
Commit:        61f6be7d2b56177df4a855c048a954ced055ab0a
Parent:        4f1171466fc6c18aa22c639a09a98de2e911c16f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 16 11:39:57 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbustest.py: Reduce test client introspection calls

The default dbus python library mode of operation is to leverage
introspection.  However, this introspection data isn't accessible
for users of the library and they have to specifically retrieve
the introspection data too. This resulted in many introspection
calls being made.  This change eliminates introspection calls if
we are testing multiple concurrent test clients.  If it's a single
client we will leverage a reduced amount of introspection data to
verify the introspection data is correct.  Typically clients don't
leverage introspection data nearly as much as this test client.
---
 test/dbus/lvmdbustest.py |  614 ++++++++++++++++++++++++++++++++++------------
 test/dbus/testlib.py     |  101 +++++----
 2 files changed, 510 insertions(+), 205 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 61d71b5..c1cfb0f 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -21,16 +21,31 @@ from testlib import *
 
 g_tmo = 0
 
+# Prefix on created objects to enable easier clean-up
 g_prefix = os.getenv('PREFIX', '')
 
+# Use the session bus instead of the system bus
 use_session = os.getenv('LVM_DBUSD_USE_SESSION', False)
+
+# Only use the devices listed in the ENV variable
 pv_device_list = os.getenv('LVM_DBUSD_PV_DEVICE_LIST', None)
 
+# Empty options dictionary (EOD)
+EOD = dbus.Dictionary({}, signature=dbus.Signature('sv'))
+# Base interfaces on LV objects
+LV_BASE_INT = (LV_COMMON_INT, LV_INT)
+
 if use_session:
 	bus = dbus.SessionBus(mainloop=DBusGMainLoop())
 else:
 	bus = dbus.SystemBus(mainloop=DBusGMainLoop())
 
+# If we have multiple clients we will globally disable introspection
+# validation to limit the massive amount of introspection calls we make as
+# that method prevents things from executing concurrently
+if pv_device_list:
+	validate_introspection = False
+
 
 def std_err_print(*args):
 	sys.stderr.write(' '.join(map(str, args)) + '\n')
@@ -55,23 +70,24 @@ def get_objects():
 		THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
 		CACHE_POOL_INT: [], CACHE_LV_INT: []}
 
-	manager = dbus.Interface(bus.get_object(
-		BUS_NAME, "/com/redhat/lvmdbus1"),
-		"org.freedesktop.DBus.ObjectManager")
+	object_manager_object = bus.get_object(
+		BUS_NAME, "/com/redhat/lvmdbus1", introspect=False)
 
-	objects = manager.GetManagedObjects()
+	manager_interface = dbus.Interface(object_manager_object,
+							"org.freedesktop.DBus.ObjectManager")
 
-	for object_path, val in list(objects.items()):
-		for interface, props in list(val.items()):
-			o = ClientProxy(bus, object_path, interface, props)
+	objects = manager_interface.GetManagedObjects()
 
+	for object_path, v in objects.items():
+		proxy = ClientProxy(bus, object_path, v)
+		for interface, prop in v.items():
 			if interface == PV_INT:
 				# If we have a list of PVs to use, lets only use those in
 				# the list
-				if pv_device_list and not (o.Pv.Name in pv_device_list):
+				# noinspection PyUnresolvedReferences
+				if pv_device_list and not (proxy.Pv.Name in pv_device_list):
 					continue
-
-			rc[interface].append(o)
+			rc[interface].append(proxy)
 
 	return rc, bus
 
@@ -83,7 +99,7 @@ def set_execution(lvmshell, test_result):
 		m = "forking & exec'ing"
 
 	lvm_manager = dbus.Interface(bus.get_object(
-		BUS_NAME, "/com/redhat/lvmdbus1/Manager"),
+		BUS_NAME, "/com/redhat/lvmdbus1/Manager", introspect=False),
 		"com.redhat.lvmdbus1.Manager")
 	rc = lvm_manager.UseLvmShell(lvmshell)
 
@@ -127,7 +143,10 @@ class TestDbusService(unittest.TestCase):
 
 		if pv_device_list is None:
 			for v in self.objs[VG_INT]:
-				self.handle_return(v.Vg.Remove(g_tmo, {}))
+				self.handle_return(
+					v.Vg.Remove(
+						dbus.Int32(g_tmo),
+						EOD))
 		else:
 			for p in self.objs[PV_INT]:
 				# When we remove a VG for a PV it could ripple across multiple
@@ -135,8 +154,9 @@ class TestDbusService(unittest.TestCase):
 				# the properties are current and correct.
 				p.update()
 				if p.Pv.Vg != '/':
-					v = ClientProxy(self.bus, p.Pv.Vg)
-					self.handle_return(v.Vg.Remove(g_tmo, {}))
+					v = ClientProxy(self.bus, p.Pv.Vg, interfaces=(VG_INT, ))
+					self.handle_return(
+						v.Vg.Remove(dbus.Int32(g_tmo), EOD))
 
 		# Check to make sure the PVs we had to start exist, else re-create
 		# them
@@ -175,7 +195,7 @@ class TestDbusService(unittest.TestCase):
 
 		pv_path = self.handle_return(
 			self.objs[MANAGER_INT][0].Manager.PvCreate(
-				device, g_tmo, {})
+				dbus.String(device), dbus.Int32(g_tmo), EOD)
 		)
 		self.assertTrue(pv_path is not None and len(pv_path) > 0)
 		return pv_path
@@ -203,10 +223,13 @@ class TestDbusService(unittest.TestCase):
 
 		vg_path = self.handle_return(
 			self.objs[MANAGER_INT][0].Manager.VgCreate(
-				vg_name, pv_paths, g_tmo, {}))
+				dbus.String(vg_name),
+				dbus.Array(pv_paths, signature=dbus.Signature('o')),
+				dbus.Int32(g_tmo),
+				EOD))
 
 		self.assertTrue(vg_path is not None and len(vg_path) > 0)
-		return ClientProxy(self.bus, vg_path)
+		return ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 	def test_vg_create(self):
 		self._vg_create()
@@ -215,11 +238,13 @@ class TestDbusService(unittest.TestCase):
 	def test_vg_delete(self):
 		vg = self._vg_create().Vg
 
-		self.handle_return(vg.Remove(g_tmo, {}))
+		self.handle_return(
+			vg.Remove(dbus.Int32(g_tmo), EOD))
 		self._check_consistency()
 
 	def _pv_remove(self, pv):
-		rc = self.handle_return(pv.Pv.Remove(g_tmo, {}))
+		rc = self.handle_return(
+			pv.Pv.Remove(dbus.Int32(g_tmo), EOD))
 		return rc
 
 	def test_pv_remove_add(self):
@@ -246,20 +271,38 @@ class TestDbusService(unittest.TestCase):
 
 		lv_meta_path = self.handle_return(
 			vg.LvCreateRaid(
-				"meta_r5", "raid5", mib(4), 0, 0, g_tmo, {})
+				dbus.String("meta_r5"),
+				dbus.String("raid5"),
+				dbus.UInt64(mib(4)),
+				dbus.UInt32(0),
+				dbus.UInt32(0),
+				dbus.Int32(g_tmo),
+				EOD)
 		)
 
 		lv_data_path = self.handle_return(
 			vg.LvCreateRaid(
-				"data_r5", "raid5", mib(16), 0, 0, g_tmo, {})
+				dbus.String("data_r5"),
+				dbus.String("raid5"),
+				dbus.UInt64(mib(16)),
+				dbus.UInt32(0),
+				dbus.UInt32(0),
+				dbus.Int32(g_tmo),
+				EOD)
 		)
 
 		thin_pool_path = self.handle_return(
-			vg.CreateThinPool(lv_meta_path, lv_data_path, g_tmo, {})
+			vg.CreateThinPool(
+				dbus.ObjectPath(lv_meta_path),
+				dbus.ObjectPath(lv_data_path),
+				dbus.Int32(g_tmo), EOD)
 		)
 
 		# Get thin pool client proxy
-		thin_pool = ClientProxy(self.bus, thin_pool_path)
+		thin_pool = ClientProxy(self.bus, thin_pool_path,
+								interfaces=(LV_COMMON_INT,
+											LV_INT,
+											THINPOOL_INT))
 
 		return vg, thin_pool
 
@@ -280,11 +323,15 @@ class TestDbusService(unittest.TestCase):
 		# Cache the thin pool
 		cached_thin_pool_path = self.handle_return(
 			cache_pool.CachePool.CacheLv(
-				thin_pool.object_path, g_tmo, {})
+				dbus.ObjectPath(thin_pool.object_path),
+				dbus.Int32(g_tmo), EOD)
 		)
 
 		# Get object proxy for cached thin pool
-		cached_thin_pool_object = ClientProxy(self.bus, cached_thin_pool_path)
+		cached_thin_pool_object = ClientProxy(self.bus, cached_thin_pool_path,
+												interfaces=(LV_COMMON_INT,
+															LV_INT,
+															THINPOOL_INT))
 
 		# Check properties on cache pool
 		self.assertTrue(cached_thin_pool_object.ThinPool.DataLv != '/')
@@ -316,7 +363,9 @@ class TestDbusService(unittest.TestCase):
 			vg = self._vg_create([pv_initial.object_path]).Vg
 
 			path = self.handle_return(
-				vg.Extend([pv_next.object_path], g_tmo, {})
+				vg.Extend(
+					dbus.Array([pv_next.object_path], signature="o"),
+					dbus.Int32(g_tmo), EOD)
 			)
 			self.assertTrue(path == '/')
 			self._check_consistency()
@@ -331,7 +380,9 @@ class TestDbusService(unittest.TestCase):
 					self.objs[PV_INT][1].object_path]).Vg
 
 			path = self.handle_return(
-				vg.Reduce(False, [vg.Pvs[0]], g_tmo, {})
+				vg.Reduce(
+					dbus.Boolean(False), dbus.Array([vg.Pvs[0]], signature='o'),
+					dbus.Int32(g_tmo), EOD)
 			)
 			self.assertTrue(path == '/')
 			self._check_consistency()
@@ -343,7 +394,7 @@ class TestDbusService(unittest.TestCase):
 		mgr = self.objs[MANAGER_INT][0].Manager
 
 		# Do a vg lookup
-		path = mgr.LookUpByLvmId(vg.Name)
+		path = mgr.LookUpByLvmId(dbus.String(vg.Name))
 
 		vg_name_start = vg.Name
 
@@ -354,17 +405,18 @@ class TestDbusService(unittest.TestCase):
 		for i in range(0, 5):
 			lv_t = self._create_lv(size=mib(4), vg=vg)
 			full_name = "%s/%s" % (vg_name_start, lv_t.LvCommon.Name)
-			lv_path = mgr.LookUpByLvmId(full_name)
+			lv_path = mgr.LookUpByLvmId(dbus.String(full_name))
 			self.assertTrue(lv_path == lv_t.object_path)
 
 		new_name = 'renamed_' + vg.Name
 
-		path = self.handle_return(vg.Rename(new_name, g_tmo, {}))
+		path = self.handle_return(
+			vg.Rename(dbus.String(new_name), dbus.Int32(g_tmo), EOD))
 		self.assertTrue(path == '/')
 		self._check_consistency()
 
 		# Do a vg lookup
-		path = mgr.LookUpByLvmId(new_name)
+		path = mgr.LookUpByLvmId(dbus.String(new_name))
 		self.assertTrue(path != '/', "%s" % (path))
 		self.assertTrue(prev_path == path, "%s != %s" % (prev_path, path))
 
@@ -376,12 +428,13 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(len(lv_paths) == 5)
 
 		for l in lv_paths:
-			lv_proxy = ClientProxy(self.bus, l).LvCommon
+			lv_proxy = ClientProxy(self.bus, l,
+									interfaces=(LV_COMMON_INT,)).LvCommon
 			self.assertTrue(
 				lv_proxy.Vg == vg.object_path, "%s != %s" %
 				(lv_proxy.Vg, vg.object_path))
 			full_name = "%s/%s" % (new_name, lv_proxy.Name)
-			lv_path = mgr.LookUpByLvmId(full_name)
+			lv_path = mgr.LookUpByLvmId(dbus.String(full_name))
 			self.assertTrue(
 				lv_path == lv_proxy.object_path, "%s != %s" %
 				(lv_path, lv_proxy.object_path))
@@ -392,14 +445,15 @@ class TestDbusService(unittest.TestCase):
 		hidden_lv_paths = lv_common_object.HiddenLvs
 
 		for h in hidden_lv_paths:
-			h_lv = ClientProxy(self.bus, h).LvCommon
+			h_lv = ClientProxy(self.bus, h,
+								interfaces=(LV_COMMON_INT,)).LvCommon
 
 			if len(h_lv.HiddenLvs) > 0:
 				self._verify_hidden_lookups(h_lv, vgname)
 
 			full_name = "%s/%s" % (vgname, h_lv.Name)
 			# print("Hidden check %s" % (full_name))
-			lookup_path = mgr.LookUpByLvmId(full_name)
+			lookup_path = mgr.LookUpByLvmId(dbus.String(full_name))
 			self.assertTrue(lookup_path != '/')
 			self.assertTrue(lookup_path == h_lv.object_path)
 
@@ -407,7 +461,7 @@ class TestDbusService(unittest.TestCase):
 			full_name = "%s/%s" % (vgname, h_lv.Name[1:-1])
 			# print("Hidden check %s" % (full_name))
 
-			lookup_path = mgr.LookUpByLvmId(full_name)
+			lookup_path = mgr.LookUpByLvmId(dbus.String(full_name))
 			self.assertTrue(lookup_path != '/')
 			self.assertTrue(lookup_path == h_lv.object_path)
 
@@ -426,20 +480,24 @@ class TestDbusService(unittest.TestCase):
 
 			thin_lv_path = self.handle_return(
 				thin_pool.ThinPool.LvCreate(
-					lv_name, mib(16), g_tmo, {}))
+					dbus.String(lv_name),
+					dbus.UInt64(mib(16)),
+					dbus.Int32(g_tmo),
+					EOD))
 
 			self.assertTrue(thin_lv_path != '/')
 
 			full_name = "%s/%s" % (vg_name_start, lv_name)
 
-			lookup_lv_path = mgr.LookUpByLvmId(full_name)
+			lookup_lv_path = mgr.LookUpByLvmId(dbus.String(full_name))
 			self.assertTrue(
 				thin_lv_path == lookup_lv_path,
 				"%s != %s" % (thin_lv_path, lookup_lv_path))
 
 		# Rename the VG
 		new_name = 'renamed_' + vg.Name
-		path = self.handle_return(vg.Rename(new_name, g_tmo, {}))
+		path = self.handle_return(
+			vg.Rename(dbus.String(new_name), dbus.Int32(g_tmo), EOD))
 
 		self.assertTrue(path == '/')
 		self._check_consistency()
@@ -452,13 +510,14 @@ class TestDbusService(unittest.TestCase):
 		lv_paths = vg.Lvs
 
 		for l in lv_paths:
-			lv_proxy = ClientProxy(self.bus, l).LvCommon
+			lv_proxy = ClientProxy(self.bus, l,
+									interfaces=(LV_COMMON_INT,)).LvCommon
 			self.assertTrue(
 				lv_proxy.Vg == vg.object_path, "%s != %s" %
 				(lv_proxy.Vg, vg.object_path))
 			full_name = "%s/%s" % (new_name, lv_proxy.Name)
 			# print('Full Name %s' % (full_name))
-			lv_path = mgr.LookUpByLvmId(full_name)
+			lv_path = mgr.LookUpByLvmId(dbus.String(full_name))
 			self.assertTrue(
 				lv_path == lv_proxy.object_path, "%s != %s" %
 				(lv_path, lv_proxy.object_path))
@@ -466,14 +525,14 @@ class TestDbusService(unittest.TestCase):
 		# noinspection PyTypeChecker
 		self._verify_hidden_lookups(thin_pool.LvCommon, new_name)
 
-	def _test_lv_create(self, method, params, vg):
+	def _test_lv_create(self, method, params, vg, proxy_interfaces=None):
 		lv = None
 
 		path = self.handle_return(method(*params))
 		self.assertTrue(vg)
 
 		if path:
-			lv = ClientProxy(self.bus, path)
+			lv = ClientProxy(self.bus, path, interfaces=proxy_interfaces)
 			# TODO verify object properties
 
 		# We are quick enough now that we can get VolumeType changes from
@@ -487,14 +546,17 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreate,
-			(lv_n(), mib(4),
-				dbus.Array([], '(ott)'), g_tmo, {}), vg)
+			(dbus.String(lv_n()), dbus.UInt64(mib(4)),
+			dbus.Array([], signature='(ott)'), dbus.Int32(g_tmo),
+			EOD), vg, LV_BASE_INT)
 
 	def test_lv_create_job(self):
 
 		vg = self._vg_create().Vg
 		(object_path, job_path) = vg.LvCreate(
-			lv_n(), mib(4), dbus.Array([], '(ott)'), 0, {})
+			dbus.String(lv_n()), dbus.UInt64(mib(4)),
+			dbus.Array([], signature='(ott)'), dbus.Int32(0),
+			EOD)
 
 		self.assertTrue(object_path == '/')
 		self.assertTrue(job_path != '/')
@@ -506,7 +568,9 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreateLinear,
-			(lv_n(), mib(4), False, g_tmo, {}), vg)
+			(dbus.String(lv_n()), dbus.UInt64(mib(4)), dbus.Boolean(False),
+			dbus.Int32(g_tmo), EOD),
+			vg, LV_BASE_INT)
 
 	def test_lv_create_striped(self):
 		pv_paths = []
@@ -515,7 +579,11 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(
-			vg.LvCreateStriped, (lv_n(), mib(4), 2, 8, False, g_tmo, {}), vg)
+			vg.LvCreateStriped,
+			(dbus.String(lv_n()), dbus.UInt64(mib(4)),
+			dbus.UInt32(2), dbus.UInt32(8), dbus.Boolean(False),
+			dbus.Int32(g_tmo), EOD),
+			vg, LV_BASE_INT)
 
 	def test_lv_create_mirror(self):
 		pv_paths = []
@@ -524,7 +592,9 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(
-			vg.LvCreateMirror, (lv_n(), mib(4), 2, g_tmo, {}), vg)
+			vg.LvCreateMirror,
+			(dbus.String(lv_n()), dbus.UInt64(mib(4)), dbus.UInt32(2),
+			dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
 
 	def test_lv_create_raid(self):
 		pv_paths = []
@@ -533,10 +603,20 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(
-			vg.LvCreateRaid, (lv_n(), 'raid5', mib(16), 2, 8, g_tmo, {}), vg)
+			vg.LvCreateRaid,
+			(dbus.String(lv_n()), dbus.String('raid5'), dbus.UInt64(mib(16)),
+			dbus.UInt32(2), dbus.UInt32(8), dbus.Int32(g_tmo),
+			EOD),
+			vg,
+			LV_BASE_INT)
 
 	def _create_lv(self, thinpool=False, size=None, vg=None):
 
+		interfaces = list(LV_BASE_INT)
+
+		if thinpool:
+			interfaces.append(THINPOOL_INT)
+
 		if not vg:
 			pv_paths = []
 			for pp in self.objs[PV_INT]:
@@ -549,7 +629,9 @@ class TestDbusService(unittest.TestCase):
 
 		return self._test_lv_create(
 			vg.LvCreateLinear,
-			(lv_n(), size, thinpool, g_tmo, {}), vg)
+			(dbus.String(lv_n()), dbus.UInt64(size),
+			dbus.Boolean(thinpool), dbus.Int32(g_tmo), EOD),
+			vg, interfaces)
 
 	def test_lv_create_rounding(self):
 		self._create_lv(size=(mib(2) + 13))
@@ -566,9 +648,11 @@ class TestDbusService(unittest.TestCase):
 
 		new_name = 'renamed_' + lv.LvCommon.Name
 
-		self.handle_return(lv.Lv.Rename(new_name, g_tmo, {}))
+		self.handle_return(lv.Lv.Rename(dbus.String(new_name),
+										dbus.Int32(g_tmo), EOD))
 
-		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(new_name)
+		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(
+			dbus.String(new_name))
 
 		self._check_consistency()
 		self.assertTrue(prev_path == path, "%s != %s" % (prev_path, path))
@@ -581,7 +665,8 @@ class TestDbusService(unittest.TestCase):
 			"%s" % (tp.object_path))
 
 		new_name = 'renamed_' + tp.LvCommon.Name
-		self.handle_return(tp.Lv.Rename(new_name, g_tmo, {}))
+		self.handle_return(tp.Lv.Rename(
+			dbus.String(new_name), dbus.Int32(g_tmo), EOD))
 		tp.update()
 		self._check_consistency()
 		self.assertEqual(new_name, tp.LvCommon.Name)
@@ -596,13 +681,20 @@ class TestDbusService(unittest.TestCase):
 
 		thin_path = self.handle_return(
 			tp.ThinPool.LvCreate(
-				lv_n('_thin_lv'), mib(8), g_tmo, {})
+				dbus.String(lv_n('_thin_lv')),
+				dbus.UInt64(mib(8)),
+				dbus.Int32(g_tmo),
+				EOD)
 		)
 
-		lv = ClientProxy(self.bus, thin_path)
+		lv = ClientProxy(self.bus, thin_path,
+							interfaces=(LV_COMMON_INT, LV_INT))
 
 		rc = self.handle_return(
-			lv.Lv.Rename('rename_test' + lv.LvCommon.Name, g_tmo, {})
+			lv.Lv.Rename(
+				dbus.String('rename_test' + lv.LvCommon.Name),
+				dbus.Int32(g_tmo),
+				EOD)
 		)
 
 		self.assertTrue(rc == '/')
@@ -610,7 +702,10 @@ class TestDbusService(unittest.TestCase):
 
 	def test_lv_remove(self):
 		lv = self._create_lv().Lv
-		rc = self.handle_return(lv.Remove(g_tmo, {}))
+		rc = self.handle_return(
+			lv.Remove(
+				dbus.Int32(g_tmo),
+				EOD))
 		self.assertTrue(rc == '/')
 		self._check_consistency()
 
@@ -619,7 +714,10 @@ class TestDbusService(unittest.TestCase):
 		ss_name = 'ss_' + lv_p.LvCommon.Name
 
 		rc = self.handle_return(lv_p.Lv.Snapshot(
-			ss_name, 0, g_tmo, {}))
+			dbus.String(ss_name),
+			dbus.UInt64(0),
+			dbus.Int32(g_tmo),
+			EOD))
 
 		self.assertTrue(rc != '/')
 
@@ -627,7 +725,7 @@ class TestDbusService(unittest.TestCase):
 	def _wait_for_job(self, j_path):
 		import time
 		rc = None
-		j = ClientProxy(self.bus, j_path).Job
+		j = ClientProxy(self.bus, j_path, interfaces=(JOB_INT, )).Job
 
 		while True:
 			j.update()
@@ -654,13 +752,15 @@ class TestDbusService(unittest.TestCase):
 
 		pv = vg.Pvs
 
-		pvp = ClientProxy(self.bus, pv[0])
+		pvp = ClientProxy(self.bus, pv[0], interfaces=(PV_INT,))
 
 		self._test_lv_create(
-			vg.LvCreate,
-			(lv_n(), mib(4),
+			vg.LvCreate, (
+				dbus.String(lv_n()),
+				dbus.UInt64(mib(4)),
 				dbus.Array([[pvp.object_path, 0, (pvp.Pv.PeCount - 1)]],
-				'(ott)'), g_tmo, {}), vg)
+				signature='(ott)'),
+				dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
 
 	def test_lv_resize(self):
 
@@ -685,18 +785,20 @@ class TestDbusService(unittest.TestCase):
 			prev = lv.LvCommon.SizeBytes
 
 			if len(pv_empty):
-				p = ClientProxy(self.bus, pv_empty[0])
+				p = ClientProxy(self.bus, pv_empty[0], interfaces=(PV_INT,))
 
 				rc = self.handle_return(
 					lv.Lv.Resize(
-						size,
+						dbus.UInt64(size),
 						dbus.Array(
 							[[p.object_path, 0, p.Pv.PeCount - 1]], '(oii)'),
-						g_tmo, {}))
+						dbus.Int32(g_tmo), EOD))
 			else:
 				rc = self.handle_return(
 					lv.Lv.Resize(
-						size, dbus.Array([], '(oii)'), g_tmo, {}))
+						dbus.UInt64(size),
+						dbus.Array([], '(oii)'),
+						dbus.Int32(g_tmo), EOD))
 
 			self.assertEqual(rc, '/')
 			self._check_consistency()
@@ -719,7 +821,9 @@ class TestDbusService(unittest.TestCase):
 
 		with self.assertRaises(dbus.exceptions.DBusException):
 				lv.Lv.Resize(
-					lv.LvCommon.SizeBytes, dbus.Array([], '(oii)'), -1, {})
+					dbus.UInt64(lv.LvCommon.SizeBytes),
+					dbus.Array([], '(oii)'),
+					dbus.Int32(-1), EOD)
 
 	def test_lv_move(self):
 		lv = self._create_lv()
@@ -729,9 +833,10 @@ class TestDbusService(unittest.TestCase):
 		# Test moving a specific LV
 		rc = self.handle_return(
 			lv.Lv.Move(
-				pv_path_move,
-				(0, 0),
-				dbus.Array([], '(oii)'), g_tmo, {}))
+				dbus.ObjectPath(pv_path_move),
+				dbus.Struct((0, 0), signature='(tt)'),
+				dbus.Array([], '(ott)'), dbus.Int32(g_tmo),
+				EOD))
 		self.assertTrue(rc == '/')
 		self._check_consistency()
 
@@ -744,12 +849,14 @@ class TestDbusService(unittest.TestCase):
 		lv_p = self._create_lv()
 		lv_p.update()
 
-		self.handle_return(lv_p.Lv.Deactivate(0, g_tmo, {}))
+		self.handle_return(lv_p.Lv.Deactivate(
+			dbus.UInt64(0), dbus.Int32(g_tmo), EOD))
 		lv_p.update()
 		self.assertFalse(lv_p.LvCommon.Active)
 		self._check_consistency()
 
-		self.handle_return(lv_p.Lv.Activate(0, g_tmo, {}))
+		self.handle_return(lv_p.Lv.Activate(
+			dbus.UInt64(0), dbus.Int32(g_tmo), EOD))
 
 		lv_p.update()
 		self.assertTrue(lv_p.LvCommon.Active)
@@ -758,7 +865,10 @@ class TestDbusService(unittest.TestCase):
 		# Try control flags
 		for i in range(0, 5):
 
-			self.handle_return(lv_p.Lv.Activate(1 << i, g_tmo, {}))
+			self.handle_return(lv_p.Lv.Activate(
+				dbus.UInt64(1 << i),
+				dbus.Int32(g_tmo),
+				EOD))
 
 			self.assertTrue(lv_p.LvCommon.Active)
 			self._check_consistency()
@@ -767,11 +877,16 @@ class TestDbusService(unittest.TestCase):
 		lv = self._create_lv()
 
 		# Test moving without being LV specific
-		vg = ClientProxy(self.bus, lv.LvCommon.Vg).Vg
+		vg = ClientProxy(self.bus, lv.LvCommon.Vg, interfaces=(VG_INT, )).Vg
 		pv_to_move = str(lv.LvCommon.Devices[0][0])
 
-		rc = self.handle_return(vg.Move(
-			pv_to_move, (0, 0), dbus.Array([], '(oii)'), 0, {}))
+		rc = self.handle_return(
+			vg.Move(
+				dbus.ObjectPath(pv_to_move),
+				dbus.Struct((0, 0), signature='tt'),
+				dbus.Array([], '(ott)'),
+				dbus.Int32(0),
+				EOD))
 		self.assertEqual(rc, '/')
 		self._check_consistency()
 
@@ -788,13 +903,16 @@ class TestDbusService(unittest.TestCase):
 				dst = p
 
 		# Fetch the destination
-		pv = ClientProxy(self.bus, dst).Pv
+		pv = ClientProxy(self.bus, dst, interfaces=(PV_INT, )).Pv
 
 		# Test range, move it to the middle of the new destination
 		job = self.handle_return(
 			vg.Move(
-				location, (0, 0),
-				[(dst, pv.PeCount / 2, 0), ], g_tmo, {}))
+				dbus.ObjectPath(location),
+				dbus.Struct((0, 0), signature='tt'),
+				dbus.Array([(dst, pv.PeCount / 2, 0), ], '(ott)'),
+				dbus.Int32(g_tmo),
+				EOD))
 		self.assertEqual(job, '/')
 		self._check_consistency()
 
@@ -807,8 +925,10 @@ class TestDbusService(unittest.TestCase):
 
 		# Test getting a job right away
 		vg_path, vg_job = self.objs[MANAGER_INT][0].Manager.VgCreate(
-			vg_name, pv_paths,
-			0, {})
+			dbus.String(vg_name),
+			dbus.Array(pv_paths, 'o'),
+			dbus.Int32(0),
+			EOD)
 
 		self.assertTrue(vg_path == '/')
 		self.assertTrue(vg_job and len(vg_job) > 0)
@@ -833,7 +953,11 @@ class TestDbusService(unittest.TestCase):
 			if vg_proxy.Vg.FreeCount > 0:
 				job = self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						lv_n(), mib(4), False, g_tmo, {}))
+						dbus.String(lv_n()),
+						dbus.UInt64(mib(4)),
+						dbus.Boolean(False),
+						dbus.Int32(g_tmo),
+						EOD))
 				self.assertTrue(job != '/')
 			else:
 				# We ran out of space, test will probably fail
@@ -842,7 +966,7 @@ class TestDbusService(unittest.TestCase):
 		# Make sure that we are honoring the timeout
 		start = time.time()
 
-		remove_job = vg_proxy.Vg.Remove(1, {})
+		remove_job = vg_proxy.Vg.Remove(dbus.Int32(1), EOD)
 
 		end = time.time()
 
@@ -891,12 +1015,16 @@ class TestDbusService(unittest.TestCase):
 
 		# Get the PVs
 		for p in vg.Pvs:
-			pvs.append(ClientProxy(self.bus, p).Pv)
+			pvs.append(ClientProxy(self.bus, p, interfaces=(PV_INT, )).Pv)
 
 		for tags_value in [['hello'], ['foo', 'bar']]:
 
 			rc = self.handle_return(
-				vg.PvTagsAdd(vg.Pvs, tags_value, g_tmo, {}))
+				vg.PvTagsAdd(
+					dbus.Array(vg.Pvs, 'o'),
+					dbus.Array(tags_value, 's'),
+					dbus.Int32(g_tmo),
+					EOD))
 			self.assertTrue(rc == '/')
 
 			for p in pvs:
@@ -904,7 +1032,11 @@ class TestDbusService(unittest.TestCase):
 				self.assertTrue(sorted(tags_value) == p.Tags)
 
 			rc = self.handle_return(
-				vg.PvTagsDel(vg.Pvs, tags_value, g_tmo, {}))
+				vg.PvTagsDel(
+					dbus.Array(vg.Pvs, 'o'),
+					dbus.Array(tags_value, 's'),
+					dbus.Int32(g_tmo),
+					EOD))
 			self.assertEqual(rc, '/')
 
 			for p in pvs:
@@ -916,12 +1048,20 @@ class TestDbusService(unittest.TestCase):
 
 		t = ['Testing', 'tags']
 
-		self.handle_return(vg.TagsAdd(t, g_tmo, {}))
+		self.handle_return(
+			vg.TagsAdd(
+				dbus.Array(t, 's'),
+				dbus.Int32(g_tmo),
+				EOD))
 
 		vg.update()
 		self.assertTrue(t == vg.Tags)
 
-		self.handle_return(vg.TagsDel(t, g_tmo, {}))
+		self.handle_return(
+			vg.TagsDel(
+				dbus.Array(t, 's'),
+				dbus.Int32(g_tmo),
+				EOD))
 		vg.update()
 		self.assertTrue([] == vg.Tags)
 
@@ -929,18 +1069,26 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		lv = self._test_lv_create(
 			vg.LvCreateLinear,
-			(lv_n(), mib(4), False, g_tmo, {}),
-			vg)
+			(dbus.String(lv_n()),
+			dbus.UInt64(mib(4)),
+			dbus.Boolean(False),
+			dbus.Int32(g_tmo),
+			EOD),
+			vg, LV_BASE_INT)
 
 		t = ['Testing', 'tags']
 
 		self.handle_return(
-			lv.Lv.TagsAdd(t, g_tmo, {}))
+			lv.Lv.TagsAdd(
+				dbus.Array(t, 's'), dbus.Int32(g_tmo), EOD))
 		lv.update()
 		self.assertTrue(t == lv.LvCommon.Tags)
 
 		self.handle_return(
-			lv.Lv.TagsDel(t, g_tmo, {}))
+			lv.Lv.TagsDel(
+				dbus.Array(t, 's'),
+				dbus.Int32(g_tmo),
+				EOD))
 		lv.update()
 		self.assertTrue([] == lv.LvCommon.Tags)
 
@@ -949,7 +1097,8 @@ class TestDbusService(unittest.TestCase):
 
 		for p in ['anywhere', 'contiguous', 'cling', 'normal']:
 			rc = self.handle_return(
-				vg.AllocationPolicySet(p, g_tmo, {}))
+				vg.AllocationPolicySet(
+					dbus.String(p), dbus.Int32(g_tmo), EOD))
 
 			self.assertEqual(rc, '/')
 			vg.update()
@@ -964,7 +1113,8 @@ class TestDbusService(unittest.TestCase):
 		# TODO: Add a test back for larger values here when bug is resolved
 		for p in [0, 1, 10, 100, 100, 1024, 2 ** 32 - 1]:
 			rc = self.handle_return(
-				vg.MaxPvSet(p, g_tmo, {}))
+				vg.MaxPvSet(
+					dbus.UInt64(p), dbus.Int32(g_tmo), EOD))
 			self.assertEqual(rc, '/')
 			vg.update()
 			self.assertTrue(
@@ -977,7 +1127,9 @@ class TestDbusService(unittest.TestCase):
 		# BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
 		# TODO: Add a test back for larger values here when bug is resolved
 		for p in [0, 1, 10, 100, 100, 1024, 2 ** 32 - 1]:
-			rc = self.handle_return(vg.MaxLvSet(p, g_tmo, {}))
+			rc = self.handle_return(
+				vg.MaxLvSet(
+					dbus.UInt64(p), dbus.Int32(g_tmo), EOD))
 			self.assertEqual(rc, '/')
 			vg.update()
 			self.assertTrue(
@@ -993,7 +1145,10 @@ class TestDbusService(unittest.TestCase):
 		if False:
 			vg = self._vg_create().Vg
 			prev_uuid = vg.Uuid
-			rc = self.handle_return(vg.UuidGenerate(g_tmo, {}))
+			rc = self.handle_return(
+				vg.UuidGenerate(
+					dbus.Int32(g_tmo),
+					EOD))
 			self.assertEqual(rc, '/')
 			vg.update()
 			self.assertTrue(
@@ -1003,43 +1158,64 @@ class TestDbusService(unittest.TestCase):
 	def test_vg_activate_deactivate(self):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
-			vg.LvCreateLinear,
-			(lv_n(), mib(4), False, g_tmo, {}),
-			vg)
+			vg.LvCreateLinear, (
+				dbus.String(lv_n()),
+				dbus.UInt64(mib(4)),
+				dbus.Boolean(False),
+				dbus.Int32(g_tmo),
+				EOD),
+			vg, LV_BASE_INT)
 
 		vg.update()
 
-		rc = self.handle_return(vg.Deactivate(0, g_tmo, {}))
+		rc = self.handle_return(
+			vg.Deactivate(
+				dbus.UInt64(0), dbus.Int32(g_tmo), EOD))
 		self.assertEqual(rc, '/')
 		self._check_consistency()
 
-		rc = self.handle_return(vg.Activate(0, g_tmo, {}))
+		rc = self.handle_return(
+			vg.Activate(
+				dbus.UInt64(0), dbus.Int32(g_tmo), EOD))
 
 		self.assertEqual(rc, '/')
 		self._check_consistency()
 
 		# Try control flags
 		for i in range(0, 5):
-			self.handle_return(vg.Activate(1 << i, g_tmo, {}))
+			self.handle_return(
+				vg.Activate(
+					dbus.UInt64(1 << i),
+					dbus.Int32(g_tmo),
+					EOD))
 
 	def test_pv_resize(self):
 
 		self.assertTrue(len(self.objs[PV_INT]) > 0)
 
 		if len(self.objs[PV_INT]) > 0:
-			pv = ClientProxy(self.bus, self.objs[PV_INT][0].object_path).Pv
+			pv = ClientProxy(self.bus, self.objs[PV_INT][0].object_path,
+								interfaces=(PV_INT, )).Pv
 
 			original_size = pv.SizeBytes
 
 			new_size = original_size / 2
 
-			self.handle_return(pv.ReSize(new_size, g_tmo, {}))
+			self.handle_return(
+				pv.ReSize(
+					dbus.UInt64(new_size),
+					dbus.Int32(g_tmo),
+					EOD))
 
 			self._check_consistency()
 			pv.update()
 
 			self.assertTrue(pv.SizeBytes != original_size)
-			self.handle_return(pv.ReSize(0, g_tmo, {}))
+			self.handle_return(
+				pv.ReSize(
+					dbus.UInt64(0),
+					dbus.Int32(g_tmo),
+					EOD))
 			self._check_consistency()
 			pv.update()
 			self.assertTrue(pv.SizeBytes == original_size)
@@ -1052,16 +1228,28 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 
-		pv = ClientProxy(self.bus, vg.Pvs[0]).Pv
+		pv = ClientProxy(self.bus, vg.Pvs[0], interfaces=(PV_INT, )).Pv
 
-		self.handle_return(pv.AllocationEnabled(False, g_tmo, {}))
+		self.handle_return(
+			pv.AllocationEnabled(
+				dbus.Boolean(False),
+				dbus.Int32(g_tmo),
+				EOD))
 
 		pv.update()
 		self.assertFalse(pv.Allocatable)
 
-		self.handle_return(pv.AllocationEnabled(True, g_tmo, {}))
+		self.handle_return(
+			pv.AllocationEnabled(
+				dbus.Boolean(True),
+				dbus.Int32(g_tmo),
+				EOD))
 
-		self.handle_return(pv.AllocationEnabled(True, g_tmo, {}))
+		self.handle_return(
+			pv.AllocationEnabled(
+				dbus.Boolean(True),
+				dbus.Int32(g_tmo),
+				EOD))
 		pv.update()
 		self.assertTrue(pv.Allocatable)
 
@@ -1080,16 +1268,23 @@ class TestDbusService(unittest.TestCase):
 		self.assertEqual(
 			self.handle_return(
 				mgr.PvScan(
-					False, True, dbus.Array([], 's'),
-					dbus.Array([], '(ii)'), g_tmo, {})), '/')
+					dbus.Boolean(False),
+					dbus.Boolean(True),
+					dbus.Array([], 's'),
+					dbus.Array([], '(ii)'),
+					dbus.Int32(g_tmo),
+					EOD)), '/')
 
 		self._check_consistency()
 		self.assertEqual(
 			self.handle_return(
 				mgr.PvScan(
-					False, False,
+					dbus.Boolean(False),
+					dbus.Boolean(False),
 					dbus.Array([], 's'),
-					dbus.Array([], '(ii)'), g_tmo, {})), '/')
+					dbus.Array([], '(ii)'),
+					dbus.Int32(g_tmo),
+					EOD)), '/')
 
 		self._check_consistency()
 
@@ -1100,9 +1295,12 @@ class TestDbusService(unittest.TestCase):
 		self.assertEqual(
 			self.handle_return(
 				mgr.PvScan(
-					False, True,
-					block_path,
-					dbus.Array([], '(ii)'), g_tmo, {})), '/')
+					dbus.Boolean(False),
+					dbus.Boolean(True),
+					dbus.Array(block_path, 's'),
+					dbus.Array([], '(ii)'),
+					dbus.Int32(g_tmo),
+					EOD)), '/')
 
 		self._check_consistency()
 
@@ -1112,16 +1310,25 @@ class TestDbusService(unittest.TestCase):
 
 		self.assertEqual(
 			self.handle_return(
-				mgr.PvScan(False, True, block_path, mm, g_tmo, {})), '/')
+				mgr.PvScan(
+					dbus.Boolean(False),
+					dbus.Boolean(True),
+					dbus.Array(block_path, 's'),
+					dbus.Array(mm, '(ii)'),
+					dbus.Int32(g_tmo),
+					EOD)), '/')
 
 		self._check_consistency()
 
 		self.assertEqual(
 			self.handle_return(
 				mgr.PvScan(
-					False, True,
+					dbus.Boolean(False),
+					dbus.Boolean(True),
 					dbus.Array([], 's'),
-					mm, g_tmo, {})), '/')
+					dbus.Array(mm, '(ii)'),
+					dbus.Int32(g_tmo),
+					EOD)), '/')
 		self._check_consistency()
 
 	@staticmethod
@@ -1143,14 +1350,22 @@ class TestDbusService(unittest.TestCase):
 		ss_name = lv_p.LvCommon.Name + '_snap'
 
 		snapshot_path = self.handle_return(
-			lv_p.Lv.Snapshot(ss_name, ss_size, g_tmo, {}))
+			lv_p.Lv.Snapshot(
+				dbus.String(ss_name),
+				dbus.UInt64(ss_size),
+				dbus.Int32(g_tmo),
+				EOD))
 
-		ss = ClientProxy(self.bus, snapshot_path)
+		ss = ClientProxy(self.bus, snapshot_path,
+							interfaces=(LV_COMMON_INT, LV_INT, SNAPSHOT_INT, ))
 
 		# Write some data to snapshot so merge takes some time
 		TestDbusService._write_some_data(ss.LvCommon.Path, ss_size / 2)
 
-		job_path = self.handle_return(ss.Snapshot.Merge(g_tmo, {}))
+		job_path = self.handle_return(
+			ss.Snapshot.Merge(
+				dbus.Int32(g_tmo),
+				EOD))
 		self.assertEqual(job_path, '/')
 
 	def test_snapshot_merge_thin(self):
@@ -1159,17 +1374,28 @@ class TestDbusService(unittest.TestCase):
 
 		thin_path = self.handle_return(
 			tp.ThinPool.LvCreate(
-				lv_n('_thin_lv'), mib(10), g_tmo, {}))
+				dbus.String(lv_n('_thin_lv')),
+				dbus.UInt64(mib(10)),
+				dbus.Int32(g_tmo),
+				EOD))
 
-		lv_p = ClientProxy(self.bus, thin_path)
+		lv_p = ClientProxy(self.bus, thin_path,
+							interfaces=(LV_INT, LV_COMMON_INT))
 
 		ss_name = lv_p.LvCommon.Name + '_snap'
 		snapshot_path = self.handle_return(
-			lv_p.Lv.Snapshot(ss_name, 0, g_tmo, {}))
+			lv_p.Lv.Snapshot(
+				dbus.String(ss_name),
+				dbus.UInt64(0),
+				dbus.Int32(g_tmo),
+				EOD))
+
+		ss = ClientProxy(self.bus, snapshot_path,
+							interfaces=(LV_INT, LV_COMMON_INT, SNAPSHOT_INT))
 
-		ss = ClientProxy(self.bus, snapshot_path)
 		job_path = self.handle_return(
-			ss.Snapshot.Merge(g_tmo, {})
+			ss.Snapshot.Merge(
+				dbus.Int32(g_tmo), EOD)
 		)
 		self.assertTrue(job_path == '/')
 
@@ -1183,9 +1409,13 @@ class TestDbusService(unittest.TestCase):
 
 		cache_pool_path = self.handle_return(
 			vg.CreateCachePool(
-				md.object_path, data.object_path, g_tmo, {}))
+				dbus.ObjectPath(md.object_path),
+				dbus.ObjectPath(data.object_path),
+				dbus.Int32(g_tmo),
+				EOD))
 
-		cp = ClientProxy(self.bus, cache_pool_path)
+		cp = ClientProxy(self.bus, cache_pool_path,
+							interfaces=(CACHE_POOL_INT, ))
 
 		return vg, cp
 
@@ -1205,29 +1435,39 @@ class TestDbusService(unittest.TestCase):
 
 			c_lv_path = self.handle_return(
 				cache_pool.CachePool.CacheLv(
-					lv_to_cache.object_path, g_tmo, {}))
+					dbus.ObjectPath(lv_to_cache.object_path),
+					dbus.Int32(g_tmo),
+					EOD))
 
-			cached_lv = ClientProxy(self.bus, c_lv_path)
+			cached_lv = ClientProxy(self.bus, c_lv_path,
+									interfaces=(LV_COMMON_INT, LV_INT,
+												CACHE_LV_INT))
 
 			uncached_lv_path = self.handle_return(
-				cached_lv.CachedLv.DetachCachePool(destroy_cache, g_tmo, {}))
+				cached_lv.CachedLv.DetachCachePool(
+					dbus.Boolean(destroy_cache),
+					dbus.Int32(g_tmo),
+					EOD))
 
 			self.assertTrue(
 				'/com/redhat/lvmdbus1/Lv' in uncached_lv_path)
 
-			rc = self.handle_return(vg.Remove(g_tmo, {}))
+			rc = self.handle_return(
+				vg.Remove(dbus.Int32(g_tmo), EOD))
 			self.assertTrue(rc == '/')
 
 	def test_vg_change(self):
 		vg_proxy = self._vg_create()
 
 		result = self.handle_return(vg_proxy.Vg.Change(
-			g_tmo, {'-a': 'ay'}))
+			dbus.Int32(g_tmo),
+			dbus.Dictionary({'-a': 'ay'}, 'sv')))
 		self.assertTrue(result == '/')
 
 		result = self.handle_return(
-			vg_proxy.Vg.Change(g_tmo, {'-a': 'n'})
-		)
+			vg_proxy.Vg.Change(
+				dbus.Int32(g_tmo),
+				dbus.Dictionary({'-a': 'n'}, 'sv')))
 		self.assertTrue(result == '/')
 
 	@staticmethod
@@ -1242,7 +1482,10 @@ class TestDbusService(unittest.TestCase):
 		# Pv device path
 		with self.assertRaises(dbus.exceptions.DBusException):
 			self.handle_return(
-				mgr.PvCreate("/dev/space in name", g_tmo, {}))
+				mgr.PvCreate(
+					dbus.String("/dev/space in name"),
+					dbus.Int32(g_tmo),
+					EOD))
 
 		# VG Name testing...
 		# Go through all bad characters
@@ -1251,32 +1494,51 @@ class TestDbusService(unittest.TestCase):
 		for c in bad_chars:
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
-					mgr.VgCreate("name%s" % (c), pv_paths, g_tmo, {}))
+					mgr.VgCreate(
+						dbus.String("name%s" % (c)),
+						dbus.Array(pv_paths, 'o'),
+						dbus.Int32(g_tmo),
+						EOD))
 
 		# Bad names
 		for bad in [".", ".."]:
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
-					mgr.VgCreate(bad, pv_paths, g_tmo, {}))
+					mgr.VgCreate(
+						dbus.String(bad),
+						dbus.Array(pv_paths, 'o'),
+						dbus.Int32(g_tmo),
+						EOD))
 
 		# Exceed name length
 		for i in [128, 1024, 4096]:
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
-					mgr.VgCreate('T' * i, pv_paths, g_tmo, {}))
+					mgr.VgCreate(
+						dbus.String('T' * i),
+						dbus.Array(pv_paths, 'o'),
+						dbus.Int32(g_tmo),
+						EOD))
 
 		# Create a VG and try to create LVs with different bad names
 		vg_path = self.handle_return(
-			mgr.VgCreate(vg_n(), pv_paths, g_tmo, {}))
+			mgr.VgCreate(
+				dbus.String(vg_n()),
+				dbus.Array(pv_paths, 'o'),
+				dbus.Int32(g_tmo),
+				EOD))
 
-		vg_proxy = ClientProxy(self.bus, vg_path)
+		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 		for c in bad_chars:
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						lv_n() + c,
-						mib(4), False, g_tmo, {}))
+						dbus.String(lv_n() + c),
+						dbus.UInt64(mib(4)),
+						dbus.Boolean(False),
+						dbus.Int32(g_tmo),
+						EOD))
 
 		for reserved in (
 				"_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
@@ -1285,15 +1547,21 @@ class TestDbusService(unittest.TestCase):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						lv_n() + reserved,
-						mib(4), False, g_tmo, {}))
+						dbus.String(lv_n() + reserved),
+						dbus.UInt64(mib(4)),
+						dbus.Boolean(False),
+						dbus.Int32(g_tmo),
+						EOD))
 
 		for reserved in ("snapshot", "pvmove"):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						reserved + lv_n(),
-						mib(4), False, g_tmo, {}))
+						dbus.String(reserved + lv_n()),
+						dbus.UInt64(mib(4)),
+						dbus.Boolean(False),
+						dbus.Int32(g_tmo),
+						EOD))
 
 	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
 
@@ -1306,34 +1574,49 @@ class TestDbusService(unittest.TestCase):
 		pv_paths = [self.objs[PV_INT][0].object_path]
 
 		vg_path = self.handle_return(
-			mgr.VgCreate(vg_n(), pv_paths, g_tmo, {}))
-		vg_proxy = ClientProxy(self.bus, vg_path)
+			mgr.VgCreate(
+				dbus.String(vg_n()),
+				dbus.Array(pv_paths, 'o'),
+				dbus.Int32(g_tmo),
+				EOD))
+		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 		for c in self._invalid_tag_characters():
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.TagsAdd(
-						[c], g_tmo, {}))
+						dbus.Array([c], 's'),
+						dbus.Int32(g_tmo),
+						EOD))
 
 		for c in self._invalid_tag_characters():
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.TagsAdd(
-						["a%sb" % (c)], g_tmo, {}))
+						dbus.Array(["a%sb" % (c)], 's'),
+						dbus.Int32(g_tmo),
+						EOD))
 
 	def test_tag_names(self):
 		mgr = self.objs[MANAGER_INT][0].Manager
 		pv_paths = [self.objs[PV_INT][0].object_path]
 
 		vg_path = self.handle_return(
-			mgr.VgCreate(vg_n(), pv_paths, g_tmo, {}))
-		vg_proxy = ClientProxy(self.bus, vg_path)
+			mgr.VgCreate(
+				dbus.String(vg_n()),
+				dbus.Array(pv_paths, 'o'),
+				dbus.Int32(g_tmo),
+				EOD))
+		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 		for i in range(1, 64):
 			tag = rs(i, "", self._ALLOWABLE_TAG_CH)
 
 			tmp = self.handle_return(
-				vg_proxy.Vg.TagsAdd([tag], g_tmo, {}))
+				vg_proxy.Vg.TagsAdd(
+					dbus.Array([tag], 's'),
+					dbus.Int32(g_tmo),
+					EOD))
 			self.assertTrue(tmp == '/')
 			vg_proxy.update()
 
@@ -1350,14 +1633,20 @@ class TestDbusService(unittest.TestCase):
 		pv_paths = [self.objs[PV_INT][0].object_path]
 
 		vg_path = self.handle_return(
-			mgr.VgCreate(vg_n(), pv_paths, g_tmo, {}))
-		vg_proxy = ClientProxy(self.bus, vg_path)
+			mgr.VgCreate(
+				dbus.String(vg_n()),
+				dbus.Array(pv_paths, 'o'),
+				dbus.Int32(g_tmo),
+				EOD))
+		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 		tag = '--h/K.6g0A4FOEatf3+k_nI/Yp&L_u2oy-=j649x:+dUcYWPEo6.IWT0c'
 
 		tmp = self.handle_return(
-			vg_proxy.Vg.TagsAdd([tag], g_tmo, {})
-		)
+			vg_proxy.Vg.TagsAdd(
+				dbus.Array([tag], 's'),
+				dbus.Int32(g_tmo),
+				EOD))
 		self.assertTrue(tmp == '/')
 		vg_proxy.update()
 
@@ -1414,4 +1703,7 @@ if __name__ == '__main__':
 			if set_execution(True, r):
 				r.register_result(unittest.main(exit=False))
 
+		if not r.no_errors:
+			break
+
 	r.exit_run()
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index 7f8456f..de61361 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -29,10 +29,12 @@ LV_COMMON_INT = BASE_INTERFACE + ".LvCommon"
 JOB_INT = BASE_INTERFACE + ".Job"
 CACHE_POOL_INT = BASE_INTERFACE + ".CachePool"
 CACHE_LV_INT = BASE_INTERFACE + ".CachedLv"
-
 THINPOOL_LV_PATH = '/' + THINPOOL_INT.replace('.', '/')
 
 
+validate_introspection = True
+
+
 def rs(length, suffix, character_set=string.ascii_lowercase):
 	return ''.join(random.choice(character_set) for _ in range(length)) + suffix
 
@@ -154,19 +156,16 @@ def verify_type(value, dbus_str_rep):
 				(dbus_str_rep, actual_str_rep, str(type(value))))
 
 
-class RemoteObject(object):
+class RemoteInterface(object):
 	def _set_props(self, props=None):
-		# print 'Fetching properties'
 		if not props:
-			# prop_fetch = dbus.Interface(self.bus.get_object(
-			#    BUSNAME, self.object_path), 'org.freedesktop.DBus.Properties')
-
-			for i in range(0, 3):
+			for _ in range(0, 3):
 				try:
-					prop_fetch = dbus.Interface(self.bus.get_object(
-						BUS_NAME, self.object_path),
+					prop_obj = self.bus.get_object(
+						BUS_NAME, self.object_path, introspect=False)
+					prop_interface = dbus.Interface(prop_obj,
 						'org.freedesktop.DBus.Properties')
-					props = prop_fetch.GetAll(self.interface)
+					props = prop_interface.GetAll(self.interface)
 					break
 				except dbus.exceptions.DBusException as dbe:
 					if "GetAll" not in str(dbe):
@@ -174,9 +173,9 @@ class RemoteObject(object):
 		if props:
 			for kl, vl in list(props.items()):
 				# Verify type is correct!
-				verify_type(
-					vl,
-					self.introspect[self.interface]['properties'][kl]['p_type'])
+				if self.introspect:
+					verify_type(vl, self.introspect[self.interface]
+					['properties'][kl]['p_type'])
 				setattr(self, kl, vl)
 
 	def __init__(
@@ -188,7 +187,7 @@ class RemoteObject(object):
 		self.introspect = introspect
 
 		self.dbus_method = dbus.Interface(specified_bus.get_object(
-			BUS_NAME, self.object_path), self.interface)
+			BUS_NAME, self.object_path, introspect=False), self.interface)
 
 		self._set_props(properties)
 
@@ -203,13 +202,14 @@ class RemoteObject(object):
 		# print("DEBUG: %s.%s result %s" %
 		# (self.interface, _method_name, str(type(result))))
 
-		if 'RETURN_VALUE' in self.introspect[
-				self.interface]['methods'][_method_name]:
-			r_type = self.introspect[
-				self.interface]['methods'][
-				_method_name]['RETURN_VALUE']['a_type']
+		if self.introspect:
+			if 'RETURN_VALUE' in self.introspect[
+					self.interface]['methods'][_method_name]:
+				r_type = self.introspect[
+					self.interface]['methods'][
+					_method_name]['RETURN_VALUE']['a_type']
 
-			verify_type(result, r_type)
+				verify_type(result, r_type)
 
 		return result
 
@@ -222,36 +222,49 @@ class ClientProxy(object):
 	def _intf_short_name(nm):
 		return nm.split('.')[-1:][0]
 
-	def __init__(self, specified_bus, object_path, interface=None, props=None):
-		i = dbus.Interface(specified_bus.get_object(
-			BUS_NAME, object_path), 'org.freedesktop.DBus.Introspectable')
-
-		introspection_xml = i.Introspect()
+	def get_introspect(self):
+		i = dbus.Interface(self.bus.get_object(
+			BUS_NAME, self.object_path, introspect=False),
+			'org.freedesktop.DBus.Introspectable')
 
-		# import xml.dom.minidom
-		#
-		# xml = xml.dom.minidom.parseString(introspection_xml)
-		# print(xml.toprettyxml())
+		return DbusIntrospection.introspect(i.Introspect())
 
-		self.intro_spect = DbusIntrospection.introspect(introspection_xml)
+	def _common(self, interface, introspect, properties):
+		short_name = ClientProxy._intf_short_name(interface)
+		self.short_interface_names.append(short_name)
+		ro = RemoteInterface(self.bus, self.object_path, interface, introspect,
+								properties)
+		setattr(self, short_name, ro)
 
-		for k in self.intro_spect.keys():
-			sn = ClientProxy._intf_short_name(k)
-			# print('Client proxy has interface: %s %s' % (k, sn))
-
-			if interface and interface == k and props is not None:
-				ro = RemoteObject(
-					specified_bus, object_path, k, self.intro_spect, props)
-			else:
-				ro = RemoteObject(
-					specified_bus, object_path, k, self.intro_spect)
+	def __init__(self, specified_bus, object_path, interface_prop_hash=None,
+					interfaces=None):
+		self.object_path = object_path
+		self.short_interface_names = []
+		self.bus = specified_bus
 
-			setattr(self, sn, ro)
+		if interface_prop_hash:
+			assert interfaces is None
+		if interfaces:
+			assert interface_prop_hash is None
+
+		if interface_prop_hash and not validate_introspection:
+			# We have everything including the values of the properties
+			for i, props in interface_prop_hash.items():
+				self._common(i, None, props)
+		elif interfaces and not validate_introspection:
+			# We are retrieving the values of the properties
+			for i in interfaces:
+				self._common(i, None, None)
+		else:
+			# We need to query the interfaces and gather all the properties
+			# for each interface, as we have the introspection data we
+			# will also utilize it to verify what we get back verifies
+			introspect = self.get_introspect()
 
-		self.object_path = object_path
+			for i in list(introspect.keys()):
+				self._common(i, introspect, None)
 
 	def update(self):
 		# Go through all interfaces and update them
-		for int_f in self.intro_spect.keys():
-			sn = ClientProxy._intf_short_name(int_f)
+		for sn in self.short_interface_names:
 			getattr(self, sn).update()


