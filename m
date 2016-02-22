From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 22 Feb 2016 22:11:00 +0000 (UTC)
Subject: master - lvmdbus: Make unit tests work in test env
Message-ID: <20160222221100.8467E602B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64aab5885d7afdbd63979b6f8520564ad2eb59ac
Commit:        64aab5885d7afdbd63979b6f8520564ad2eb59ac
Parent:        70d0b210e17884ab8cfc5f2a9be90461afb993c7
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Feb 22 14:03:31 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 22 16:07:54 2016 -0600

lvmdbus: Make unit tests work in test env

Reduced the size of LVs created and use actual PE numbers instead of hard
coding them to allow us to work with the loop back devices.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/dbus/lvmdbustest.py |   80 +++++++++++++++++++++++++++-------------------
 1 files changed, 47 insertions(+), 33 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index bdeb1a3..16fffdf 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -47,6 +47,10 @@ def rs(length, suffix, character_set=string.ascii_lowercase):
 bus = dbus.SystemBus(mainloop=DBusGMainLoop())
 
 
+def mib(s):
+	return 1024 * 1024 * s
+
+
 class DbusIntrospection(object):
 	@staticmethod
 	def introspect(xml_representation):
@@ -368,7 +372,7 @@ class TestDbusService(unittest.TestCase):
 
 		# Create some LVs in the VG
 		for i in range(0, 5):
-			lv_t = self._create_lv(size=1024 * 1024 * 16, vg=vg)
+			lv_t = self._create_lv(size=mib(4), vg=vg)
 			full_name = "%s/%s" % (vg_name_start, lv_t.LvCommon.Name)
 			lv_path = mgr.LookUpByLvmId(full_name)
 			self.assertTrue(lv_path == lv_t.object_path)
@@ -432,10 +436,10 @@ class TestDbusService(unittest.TestCase):
 		# Let's create a thin pool which uses a raid 5 meta and raid5 data
 		# areas
 		lv_meta_path = vg.LvCreateRaid(
-			"meta_r5", "raid5", 1024 * 1024 * 16, 0, 0, -1, {})[0]
+			"meta_r5", "raid5", mib(4), 0, 0, -1, {})[0]
 
 		lv_data_path = vg.LvCreateRaid(
-			"data_r5", "raid5", 1024 * 1024 * 512, 0, 0, -1, {})[0]
+			"data_r5", "raid5", mib(16), 0, 0, -1, {})[0]
 
 		thin_pool_path = vg.CreateThinPool(
 			lv_meta_path, lv_data_path, -1, {})[0]
@@ -450,7 +454,7 @@ class TestDbusService(unittest.TestCase):
 			lv_name = rs(8, '_lv')
 
 			thin_lv_path = thin_pool.ThinPool.LvCreate(
-				lv_name, 1024 * 1024 * 16, -1, {})[0]
+				lv_name, mib(16), -1, {})[0]
 
 			self.assertTrue(thin_lv_path != '/')
 
@@ -504,7 +508,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreate,
-			(rs(8, '_lv'), 1024 * 1024 * 4,
+			(rs(8, '_lv'), mib(4),
 			dbus.Array([], '(ott)'), -1, {}), vg)
 
 	def test_lv_create_linear(self):
@@ -512,7 +516,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}), vg)
+			(rs(8, '_lv'), mib(4), False, -1, {}), vg)
 
 	def test_lv_create_striped(self):
 		pv_paths = []
@@ -522,7 +526,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(
 			vg.LvCreateStriped,
-			(rs(8, '_lv'), 1024 * 1024 * 4, 2, 8, False,
+			(rs(8, '_lv'), mib(4), 2, 8, False,
 			-1, {}), vg)
 
 	def test_lv_create_mirror(self):
@@ -532,7 +536,7 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(vg.LvCreateMirror,
-			(rs(8, '_lv'), 1024 * 1024 * 4, 2, -1, {}), vg)
+			(rs(8, '_lv'), mib(4), 2, -1, {}), vg)
 
 	def test_lv_create_raid(self):
 		pv_paths = []
@@ -542,7 +546,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(vg.LvCreateRaid,
 			(rs(8, '_lv'), 'raid4',
-			1024 * 1024 * 16, 2, 8, -1, {}), vg)
+			mib(16), 2, 8, -1, {}), vg)
 
 	def _create_lv(self, thinpool=False, size=None, vg=None):
 
@@ -554,14 +558,14 @@ class TestDbusService(unittest.TestCase):
 			vg = self._vg_create(pv_paths).Vg
 
 		if size is None:
-			size = 1024 * 1024 * 128
+			size = mib(4)
 
 		return self._test_lv_create(
 			vg.LvCreateLinear,
 			(rs(8, '_lv'), size, thinpool, -1, {}), vg)
 
 	def test_lv_create_rounding(self):
-		self._create_lv(size=1024 * 1024 * 2 + 13)
+		self._create_lv(size=(mib(2) + 13))
 
 	def test_lv_create_thin_pool(self):
 		self._create_lv(True)
@@ -602,7 +606,7 @@ class TestDbusService(unittest.TestCase):
 		tp = self._create_lv(True)
 
 		thin_path = tp.ThinPool.LvCreate(
-			rs(10, '_thin_lv'), 1024 * 1024 * 10, -1, {})[0]
+			rs(10, '_thin_lv'), mib(8), -1, {})[0]
 
 		lv = ClientProxy(self.bus, thin_path)
 		rc = lv.Lv.Rename('rename_test' + lv.LvCommon.Name, -1, {})
@@ -668,9 +672,11 @@ class TestDbusService(unittest.TestCase):
 
 		pv = vg.Pvs
 
-		self._test_lv_create(vg.LvCreate,
-				(rs(8, '_lv'), 1024 * 1024 * 4,
-				dbus.Array([[pv[0], 0, 100]], '(ott)'), -1, {}), vg)
+		pv_proxy = ClientProxy(self.bus, pv[0])
+
+		self._test_lv_create(vg.LvCreate, (rs(8, '_lv'), mib(4),
+			dbus.Array([[pv_proxy.object_path, 0, (pv_proxy.Pv.PeCount - 1)]],
+			'(ott)'), -1, {}), vg)
 
 	def test_lv_resize(self):
 
@@ -679,7 +685,7 @@ class TestDbusService(unittest.TestCase):
 			pv_paths.append(pp.object_path)
 
 		vg = self._vg_create(pv_paths).Vg
-		lv = self._create_lv(vg=vg)
+		lv = self._create_lv(vg=vg, size=mib(16))
 
 		for size in [
 					lv.LvCommon.SizeBytes + 4194304,
@@ -694,8 +700,10 @@ class TestDbusService(unittest.TestCase):
 			prev = lv.LvCommon.SizeBytes
 
 			if len(pv_empty):
+				p = ClientProxy(self.bus, pv_empty[0])
 				rc = lv.Lv.Resize(
-					size, dbus.Array([[pv_empty[0], 0, 100]], '(oii)'),
+					size,
+					dbus.Array([[p.object_path, 0, p.Pv.PeCount - 1]], '(oii)'),
 					-1, {})
 			else:
 				rc = lv.Lv.Resize(size, dbus.Array([], '(oii)'), -1, {})
@@ -817,17 +825,23 @@ class TestDbusService(unittest.TestCase):
 		# add a number of LVs and then remove the VG and all the contained
 		# LVs which appears to consistently run a little slow.
 
-		vg = self._vg_create(pv_paths).Vg
+		vg_proxy = self._vg_create(pv_paths)
 
 		for i in range(0, num_lvs):
-			obj_path, job = vg.LvCreateLinear(
-				rs(8, "_lv"), 1024 * 1024 * 4, False, -1, {})
-			self.assertTrue(job == '/')
+
+			vg_proxy.update()
+			if vg_proxy.Vg.FreeCount > 0:
+				obj_path, job = vg_proxy.Vg.LvCreateLinear(
+					rs(8, "_lv"), mib(4), False, -1, {})
+				self.assertTrue(job == '/')
+			else:
+				# We ran out of space, test will probably fail
+				break
 
 		# Make sure that we are honoring the timeout
 		start = time.time()
 
-		remove_job = vg.Remove(1, {})
+		remove_job = vg_proxy.Vg.Remove(1, {})
 
 		end = time.time()
 
@@ -902,7 +916,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		lv = self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
+			(rs(8, '_lv'), mib(4), False, -1, {}),
 			vg)
 
 		t = ['Testing', 'tags']
@@ -968,7 +982,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
+			(rs(8, '_lv'), mib(4), False, -1, {}),
 			vg)
 
 		vg.update()
@@ -1081,9 +1095,9 @@ class TestDbusService(unittest.TestCase):
 
 	def test_snapshot_merge(self):
 		# Create a non-thin LV and merge it
-		ss_size = 1024 * 1024 * 512
+		ss_size = mib(8)
 
-		lv_p = self._create_lv(size=1024 * 1024 * 1024)
+		lv_p = self._create_lv(size=mib(16))
 		ss_name = lv_p.LvCommon.Name + '_snap'
 		snapshot_path = lv_p.Lv.Snapshot(ss_name, ss_size, -1, {})[0]
 		ss = ClientProxy(self.bus, snapshot_path)
@@ -1101,7 +1115,7 @@ class TestDbusService(unittest.TestCase):
 		tp = self._create_lv(True)
 
 		thin_path = tp.ThinPool.LvCreate(
-			rs(10, '_thin_lv'), 1024 * 1024 * 10, -1, {})[0]
+			rs(10, '_thin_lv'), mib(10), -1, {})[0]
 
 		lv_p = ClientProxy(self.bus, thin_path)
 
@@ -1115,8 +1129,8 @@ class TestDbusService(unittest.TestCase):
 	def _create_cache_pool(self):
 		vg = self._vg_create().Vg
 
-		md = self._create_lv(size=(1024 * 1024 * 8), vg=vg)
-		data = self._create_lv(size=(1024 * 1024 * 256), vg=vg)
+		md = self._create_lv(size=(mib(8)), vg=vg)
+		data = self._create_lv(size=(mib(8)), vg=vg)
 
 		cache_pool_path = vg.CreateCachePool(
 			md.object_path, data.object_path, -1, {})[0]
@@ -1137,7 +1151,7 @@ class TestDbusService(unittest.TestCase):
 		for destroy_cache in [True, False]:
 			vg, cache_pool = self._create_cache_pool()
 
-			lv_to_cache = self._create_lv(size=(1024 * 1024 * 1024), vg=vg)
+			lv_to_cache = self._create_lv(size=mib(8), vg=vg)
 
 			c_lv_path = cache_pool.CachePool.CacheLv(
 				lv_to_cache.object_path, -1, {})[0]
@@ -1196,18 +1210,18 @@ class TestDbusService(unittest.TestCase):
 		for c in bad_chars:
 			with self.assertRaises(dbus.exceptions.DBusException):
 				vg_proxy.Vg.LvCreateLinear(rs(8, '_lv') + c,
-					1024 * 1024 * 4, False, -1, {})
+					mib(4), False, -1, {})
 
 		for r in ("_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
 			"_pmspare", "_rimage", "_rmeta", "_tdata", "_tmeta", "_vorigin"):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				vg_proxy.Vg.LvCreateLinear(rs(8, '_lv') + r,
-					1024 * 1024 * 4, False, -1, {})
+					mib(4), False, -1, {})
 
 		for r in ("snapshot", "pvmove"):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				vg_proxy.Vg.LvCreateLinear(r + rs(8, '_lv'),
-					1024 * 1024 * 4, False, -1, {})
+					mib(4), False, -1, {})
 
 	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
 


