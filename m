From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:51 -0400
Subject: master - lvmdbustest.py: Add tests for LV interface
Message-ID: <201910301545.x9UFjp8t017017@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f961311436bda50b219f6d2909d8602e37148611
Commit:        f961311436bda50b219f6d2909d8602e37148611
Parent:        1bbf97757736b49065bd6944d36e7a6db6f3aa7e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Oct 11 10:49:10 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Add tests for LV interface

Add tests for all the different LV types with the standard LV dbus
interface.  These tests shook out a couple of new bugs.
---
 test/dbus/lvmdbustest.py |  207 ++++++++++++++++++++++++++++++++++------------
 1 files changed, 154 insertions(+), 53 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index f8842ef..64a126a 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -58,8 +58,11 @@ if pv_device_list:
 	testlib.validate_introspection = False
 
 
-def vg_n():
-	return g_prefix + rs(8, '_vg')
+def vg_n(prefix=None):
+	name = rs(8, '_vg')
+	if prefix:
+		name = prefix + name
+	return name
 
 
 def lv_n(suffix=None):
@@ -315,12 +318,12 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(rc is not None and len(rc) > 0)
 		self._check_consistency()
 
-	def _vg_create(self, pv_paths=None):
+	def _vg_create(self, pv_paths=None, vg_prefix=None):
 
 		if not pv_paths:
-			pv_paths = [self.objs[PV_INT][0].object_path]
+			pv_paths = self._all_pv_object_paths()
 
-		vg_name = vg_n()
+		vg_name = vg_n(prefix=vg_prefix)
 
 		vg_path = self.handle_return(
 			self.objs[MANAGER_INT][0].Manager.VgCreate(
@@ -721,7 +724,7 @@ class TestDbusService(unittest.TestCase):
 			vg = self._vg_create(self._all_pv_object_paths()).Vg
 
 		if size is None:
-			size = mib(4)
+			size = mib(8)
 
 		lv = self._test_lv_create(
 			vg.LvCreateLinear,
@@ -732,16 +735,16 @@ class TestDbusService(unittest.TestCase):
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 		return lv
 
+	def _create_thin_pool_lv(self):
+		return self._create_lv(True)
+
 	def test_lv_create_rounding(self):
 		self._create_lv(size=(mib(2) + 13))
 
 	def test_lv_create_thin_pool(self):
-		self._create_lv(True)
-
-	def test_lv_rename(self):
-		# Rename a regular LV
-		lv = self._create_lv()
+		self._create_thin_pool_lv()
 
+	def _rename_lv_test(self, lv):
 		path = self._lookup(lv.LvCommon.Name)
 		prev_path = path
 
@@ -755,6 +758,16 @@ class TestDbusService(unittest.TestCase):
 		self._check_consistency()
 		self.assertTrue(prev_path == path, "%s != %s" % (prev_path, path))
 
+		lv.update()
+		self.assertTrue(
+			lv.LvCommon.Name == new_name,
+			"%s != %s" % (lv.LvCommon.Name, new_name))
+
+	def test_lv_rename(self):
+		# Rename a regular LV
+		lv = self._create_lv()
+		self._rename_lv_test(lv)
+
 	def test_lv_thinpool_rename(self):
 		# Rename a thin pool
 		tp = self._create_lv(True)
@@ -804,26 +817,34 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(rc == '/')
 		self._check_consistency()
 
-	def test_lv_remove(self):
-		lv = self._create_lv().Lv
+	def _lv_remove(self, lv):
 		rc = self.handle_return(
-			lv.Remove(
+			lv.Lv.Remove(
 				dbus.Int32(g_tmo),
 				EOD))
 		self.assertTrue(rc == '/')
 		self._check_consistency()
 
-	def test_lv_snapshot(self):
-		lv_p = self._create_lv()
+	def test_lv_remove(self):
+		lv = self._create_lv()
+		self._lv_remove(lv)
+
+	def _take_lv_snapshot(self, lv_p):
 		ss_name = 'ss_' + lv_p.LvCommon.Name
 
-		rc = self.handle_return(lv_p.Lv.Snapshot(
+		ss_obj_path = self.handle_return(lv_p.Lv.Snapshot(
 			dbus.String(ss_name),
 			dbus.UInt64(0),
 			dbus.Int32(g_tmo),
 			EOD))
 
-		self.assertTrue(rc != '/')
+		self.assertTrue(ss_obj_path != '/')
+		return ClientProxy(
+			self.bus, ss_obj_path, interfaces=(LV_COMMON_INT, LV_INT))
+
+	def test_lv_snapshot(self):
+		lv_p = self._create_lv()
+		self._take_lv_snapshot(lv_p)
 
 	# noinspection PyUnresolvedReferences,PyUnusedLocal
 	def _wait_for_job(self, j_path):
@@ -866,21 +887,23 @@ class TestDbusService(unittest.TestCase):
 				dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
-	def test_lv_resize(self):
+	def _test_lv_resize(self, lv):
+		# Can't resize cache or thin pool volumes or vdo pool lv
+		if lv.LvCommon.Attr[0] == 'C' or lv.LvCommon.Attr[0] == 't' or \
+				lv.LvCommon.Attr[0] == 'd':
+			return
 
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
+		vg = ClientProxy(self.bus, lv.LvCommon.Vg, interfaces=(VG_INT,)).Vg
 
-		vg = self._vg_create(pv_paths).Vg
-		lv = self._create_lv(vg=vg, size=mib(16))
+		start_size = lv.LvCommon.SizeBytes
+
+		# Vdo are fairly big and need large re-size amounts.
+		if start_size > mib(4) * 3:
+			delta = mib(4)
+		else:
+			delta = 16384
 
-		for size in \
-			[
-			lv.LvCommon.SizeBytes + 4194304,
-			lv.LvCommon.SizeBytes - 4194304,
-			lv.LvCommon.SizeBytes + 2048,
-			lv.LvCommon.SizeBytes - 2048]:
+		for size in [start_size + delta, start_size - delta]:
 
 			pv_in_use = [i[0] for i in lv.LvCommon.Devices]
 			# Select a PV in the VG that isn't in use
@@ -915,6 +938,16 @@ class TestDbusService(unittest.TestCase):
 				# We are testing re-sizing to same size too...
 				self.assertTrue(lv.LvCommon.SizeBytes <= prev)
 
+	def test_lv_resize(self):
+
+		pv_paths = [
+			self.objs[PV_INT][0].object_path, self.objs[PV_INT][1].object_path]
+
+		vg = self._vg_create(pv_paths).Vg
+		lv = self._create_lv(vg=vg, size=mib(16))
+
+		self._test_lv_resize(lv)
+
 	def test_lv_resize_same(self):
 		vg = self._vg_create(self._all_pv_object_paths()).Vg
 		lv = self._create_lv(vg=vg)
@@ -945,10 +978,7 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(
 			pv_path_move != new_pv, "%s == %s" % (pv_path_move, new_pv))
 
-	def test_lv_activate_deactivate(self):
-		lv_p = self._create_lv()
-		lv_p.update()
-
+	def _test_activate_deactivate(self, lv_p):
 		self.handle_return(lv_p.Lv.Deactivate(
 			dbus.UInt64(0), dbus.Int32(g_tmo), EOD))
 		lv_p.update()
@@ -960,7 +990,17 @@ class TestDbusService(unittest.TestCase):
 
 		lv_p.update()
 		self.assertTrue(lv_p.LvCommon.Active)
-		self._check_consistency()
+
+		# Vdo property "IndexState" when getting activated goes from
+		# "opening" -> "online" after we have returned from the activate call
+		# thus when we try to check the consistency we fail as the property
+		# is changing on it's own and not because the lvmdbusd failed to
+		# refresh it's own state.  One solution is to not expose IndexState as
+		# a property.
+		# TODO Expose method to determine if Lv is partaking in VDO.
+		vg = ClientProxy(self.bus, lv_p.LvCommon.Vg, interfaces=(VG_INT,))
+		if "vdo" not in vg.Vg.Name:
+			self._check_consistency()
 
 		# Try control flags
 		for i in range(0, 5):
@@ -973,6 +1013,10 @@ class TestDbusService(unittest.TestCase):
 			self.assertTrue(lv_p.LvCommon.Active)
 			self._check_consistency()
 
+	def test_lv_activate_deactivate(self):
+		lv_p = self._create_lv()
+		self._test_activate_deactivate(lv_p)
+
 	def test_move(self):
 		lv = self._create_lv()
 
@@ -1157,15 +1201,13 @@ class TestDbusService(unittest.TestCase):
 		vg.update()
 		self.assertTrue([] == vg.Tags)
 
-	def test_lv_tags(self):
-		vg = self._vg_create().Vg
-		lv = self._create_lv(vg=vg)
-
+	def _test_lv_tags(self, lv):
 		t = ['Testing', 'tags']
 
 		self.handle_return(
 			lv.Lv.TagsAdd(
 				dbus.Array(t, 's'), dbus.Int32(g_tmo), EOD))
+		self._check_consistency()
 		lv.update()
 		self.assertTrue(t == lv.LvCommon.Tags)
 
@@ -1174,9 +1216,15 @@ class TestDbusService(unittest.TestCase):
 				dbus.Array(t, 's'),
 				dbus.Int32(g_tmo),
 				EOD))
+		self._check_consistency()
 		lv.update()
 		self.assertTrue([] == lv.LvCommon.Tags)
 
+	def test_lv_tags(self):
+		vg = self._vg_create().Vg
+		lv = self._create_lv(vg=vg)
+		self._test_lv_tags(lv)
+
 	def test_vg_allocation_policy_set(self):
 		vg = self._vg_create().Vg
 
@@ -1192,7 +1240,7 @@ class TestDbusService(unittest.TestCase):
 			self.assertTrue(prop)
 
 	def test_vg_max_pv(self):
-		vg = self._vg_create().Vg
+		vg = self._vg_create([self.objs[PV_INT][0].object_path]).Vg
 		for p in [0, 1, 10, 100, 100, 1024, 2 ** 32 - 1]:
 			rc = self.handle_return(
 				vg.MaxPvSet(
@@ -1441,10 +1489,10 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(
 			'/com/redhat/lvmdbus1/CachePool' in cache_pool.object_path)
 
-	def _create_cache_lv(self):
+	def _create_cache_lv(self, return_all=False):
 		vg, cache_pool = self._create_cache_pool()
 
-		lv_to_cache = self._create_lv(size=mib(8), vg=vg)
+		lv_to_cache = self._create_lv(size=mib(32), vg=vg)
 
 		c_lv_path = self.handle_return(
 			cache_pool.CachePool.CacheLv(
@@ -1454,12 +1502,15 @@ class TestDbusService(unittest.TestCase):
 
 		intf = (LV_COMMON_INT, LV_INT, CACHE_LV_INT)
 		cached_lv = ClientProxy(self.bus, c_lv_path, interfaces=intf)
-		return vg, cache_pool, cached_lv
+
+		if return_all:
+			return vg, cache_pool, cached_lv
+		return cached_lv
 
 	def test_cache_lv_create(self):
 
 		for destroy_cache in [True, False]:
-			vg, _, cached_lv = self._create_cache_lv()
+			vg, _, cached_lv = self._create_cache_lv(True)
 			uncached_lv_path = self.handle_return(
 				cached_lv.CachedLv.DetachCachePool(
 					dbus.Boolean(destroy_cache),
@@ -1484,7 +1535,7 @@ class TestDbusService(unittest.TestCase):
 			self.assertEqual(len(cur_objs[CACHE_LV_INT]), 2)
 			self._check_consistency()
 
-		_, _, cached_lv = self._create_cache_lv()
+		cached_lv = self._create_cache_lv()
 
 		verify_cache_lv_count()
 		new_name = 'renamed_' + cached_lv.LvCommon.Name
@@ -1796,11 +1847,11 @@ class TestDbusService(unittest.TestCase):
 		pool_name = lv_n("_vdo_pool")
 		lv_name = lv_n()
 
-		vg_proxy = self._vg_create()
+		vg_proxy = self._vg_create(vg_prefix="vdo_")
 		vdo_pool_object_path = self.handle_return(
 			vg_proxy.VgVdo.CreateVdoPoolandLv(
 				pool_name, lv_name,
-				dbus.UInt64(mib(4096)),
+				dbus.UInt64(mib(4096)),		# Appears to be minimum size
 				dbus.UInt64(mib(8192)),
 				dbus.Int32(g_tmo),
 				EOD))
@@ -1810,11 +1861,20 @@ class TestDbusService(unittest.TestCase):
 			vdo_pool_object_path,
 			self._lookup("%s/%s" % (vg_proxy.Vg.Name, pool_name)))
 
-		vdo_lv = self._lookup("%s/%s" % (vg_proxy.Vg.Name, lv_name))
-		self.assertNotEqual(vdo_lv, "/")
-		intf = (LV_COMMON_INT, LV_INT, VDOPOOL_INT)
-		pool_lv = ClientProxy(self.bus, vdo_lv, interfaces=intf)
-		return vg_proxy, pool_lv
+		vdo_pool_path = self._lookup("%s/%s" % (vg_proxy.Vg.Name, pool_name))
+		self.assertNotEqual(vdo_pool_path, "/")
+		intf = [LV_COMMON_INT, LV_INT]
+		vdo_lv_obj_path = self._lookup("%s/%s" % (vg_proxy.Vg.Name, lv_name))
+		vdo_lv = ClientProxy(self.bus, vdo_lv_obj_path, interfaces=intf)
+		intf.append(VDOPOOL_INT)
+		vdo_pool_lv = ClientProxy(self.bus, vdo_pool_path, interfaces=intf)
+		return vg_proxy, vdo_pool_lv, vdo_lv
+
+	def _create_vdo_lv(self):
+		return self._create_vdo_pool_and_lv()[2]
+
+	def _vdo_pool_lv(self):
+		return self._create_vdo_pool_and_lv()[1]
 
 	def test_vdo_pool_create(self):
 		# Basic vdo sanity testing
@@ -1825,9 +1885,50 @@ class TestDbusService(unittest.TestCase):
 		# the operation when if finds an existing vdo signature, which likely
 		# shouldn't exist.
 		for _ in range(0, 2):
-			vg, _ = self._create_vdo_pool_and_lv()
+			vg, _, _ = self._create_vdo_pool_and_lv()
 			self.handle_return(vg.Vg.Remove(dbus.Int32(g_tmo), EOD))
 
+	def _test_lv_method_interface(self, lv):
+		self._rename_lv_test(lv)
+		self._test_activate_deactivate(lv)
+		self._test_lv_tags(lv)
+		self._test_lv_resize(lv)
+
+	def _test_lv_method_interface_sequence(
+			self, lv, test_ss=True, remove_lv=True):
+		self._test_lv_method_interface(lv)
+
+		# We can't take a snapshot of a pool lv (not yet).
+		if test_ss:
+			ss_lv = self._take_lv_snapshot(lv)
+			self._test_lv_method_interface(ss_lv)
+			self._lv_remove(ss_lv)
+
+		if remove_lv:
+			self._lv_remove(lv)
+
+	def test_lv_interface_plain_lv(self):
+		self._test_lv_method_interface_sequence(self._create_lv())
+
+	def test_lv_interface_vdo_lv(self):
+		if not self.vdo:
+			raise unittest.SkipTest('vdo not supported')
+		self._test_lv_method_interface_sequence(self._create_vdo_lv())
+
+	def test_lv_interface_cache_lv(self):
+		self._test_lv_method_interface_sequence(
+			self._create_cache_lv(), remove_lv=False)
+
+	def test_lv_interface_thin_pool_lv(self):
+		self._test_lv_method_interface_sequence(
+			self._create_thin_pool_lv(), test_ss=False)
+
+	def test_lv_interface_vdo_pool_lv(self):
+		if not self.vdo:
+			raise unittest.SkipTest('vdo not supported')
+		self._test_lv_method_interface_sequence(
+			self._vdo_pool_lv(), test_ss=False)
+
 
 class AggregateResults(object):
 


