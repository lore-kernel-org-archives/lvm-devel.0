From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 11 Oct 2016 18:18:53 +0000 (UTC)
Subject: master - lvmdbustest.py: ws fixes
Message-ID: <20161011181853.BE49560DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e57fd9d96327f1f715748de99c23f9521a2d7b9b
Commit:        e57fd9d96327f1f715748de99c23f9521a2d7b9b
Parent:        9c56902365c4987b291e9ecdb853d9c4d14767c8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 11 12:22:31 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Oct 11 13:16:57 2016 -0500

lvmdbustest.py: ws fixes

---
 test/dbus/lvmdbustest.py |  159 ++++++++++++++++++++++++---------------------
 test/dbus/testlib.py     |   32 +++++-----
 2 files changed, 101 insertions(+), 90 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 9432c79..e5b8243 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -9,6 +9,7 @@
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
+# noinspection PyUnresolvedReferences
 import dbus
 # noinspection PyUnresolvedReferences
 from dbus.mainloop.glib import DBusGMainLoop
@@ -49,9 +50,10 @@ def lv_n(suffix=None):
 
 
 def get_objects():
-	rc = {MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
-			THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
-			CACHE_POOL_INT: [], CACHE_LV_INT: []}
+	rc = {
+		MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
+		THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
+		CACHE_POOL_INT: [], CACHE_LV_INT: []}
 
 	manager = dbus.Interface(bus.get_object(
 		BUSNAME, "/com/redhat/lvmdbus1"),
@@ -289,7 +291,7 @@ class TestDbusService(unittest.TestCase):
 		if len(self.objs[PV_INT]) >= 2:
 			vg = self._vg_create(
 				[self.objs[PV_INT][0].object_path,
-				self.objs[PV_INT][1].object_path]).Vg
+					self.objs[PV_INT][1].object_path]).Vg
 
 			path = self.handle_return(
 				vg.Reduce(False, [vg.Pvs[0]], g_tmo, {})
@@ -338,12 +340,14 @@ class TestDbusService(unittest.TestCase):
 
 		for l in lv_paths:
 			lv_proxy = ClientProxy(self.bus, l).LvCommon
-			self.assertTrue(lv_proxy.Vg == vg.object_path, "%s != %s" %
-							(lv_proxy.Vg, vg.object_path))
+			self.assertTrue(
+				lv_proxy.Vg == vg.object_path, "%s != %s" %
+				(lv_proxy.Vg, vg.object_path))
 			full_name = "%s/%s" % (new_name, lv_proxy.Name)
 			lv_path = mgr.LookUpByLvmId(full_name)
-			self.assertTrue(lv_path == lv_proxy.object_path, "%s != %s" %
-							(lv_path, lv_proxy.object_path))
+			self.assertTrue(
+				lv_path == lv_proxy.object_path, "%s != %s" %
+				(lv_path, lv_proxy.object_path))
 
 	def _verify_hidden_lookups(self, lv_common_object, vgname):
 		mgr = self.objs[MANAGER_INT][0].Manager
@@ -392,8 +396,9 @@ class TestDbusService(unittest.TestCase):
 			full_name = "%s/%s" % (vg_name_start, lv_name)
 
 			lookup_lv_path = mgr.LookUpByLvmId(full_name)
-			self.assertTrue(thin_lv_path == lookup_lv_path,
-							"%s != %s" % (thin_lv_path, lookup_lv_path))
+			self.assertTrue(
+				thin_lv_path == lookup_lv_path,
+				"%s != %s" % (thin_lv_path, lookup_lv_path))
 
 		# Rename the VG
 		new_name = 'renamed_' + vg.Name
@@ -411,13 +416,15 @@ class TestDbusService(unittest.TestCase):
 
 		for l in lv_paths:
 			lv_proxy = ClientProxy(self.bus, l).LvCommon
-			self.assertTrue(lv_proxy.Vg == vg.object_path, "%s != %s" %
-							(lv_proxy.Vg, vg.object_path))
+			self.assertTrue(
+				lv_proxy.Vg == vg.object_path, "%s != %s" %
+				(lv_proxy.Vg, vg.object_path))
 			full_name = "%s/%s" % (new_name, lv_proxy.Name)
 			# print('Full Name %s' % (full_name))
 			lv_path = mgr.LookUpByLvmId(full_name)
-			self.assertTrue(lv_path == lv_proxy.object_path, "%s != %s" %
-							(lv_path, lv_proxy.object_path))
+			self.assertTrue(
+				lv_path == lv_proxy.object_path, "%s != %s" %
+				(lv_path, lv_proxy.object_path))
 
 		# noinspection PyTypeChecker
 		self._verify_hidden_lookups(thin_pool.LvCommon, new_name)
@@ -444,13 +451,13 @@ class TestDbusService(unittest.TestCase):
 		self._test_lv_create(
 			vg.LvCreate,
 			(lv_n(), mib(4),
-			 dbus.Array([], '(ott)'), g_tmo, {}), vg)
+				dbus.Array([], '(ott)'), g_tmo, {}), vg)
 
 	def test_lv_create_job(self):
 
 		vg = self._vg_create().Vg
-		(object_path, job_path) = vg.LvCreate(lv_n(), mib(4),
-			dbus.Array([], '(ott)'), 0, {})
+		(object_path, job_path) = vg.LvCreate(
+			lv_n(), mib(4), dbus.Array([], '(ott)'), 0, {})
 
 		self.assertTrue(object_path == '/')
 		self.assertTrue(job_path != '/')
@@ -471,9 +478,7 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(
-			vg.LvCreateStriped,
-			(lv_n(), mib(4), 2, 8, False,
-			 g_tmo, {}), vg)
+			vg.LvCreateStriped, (lv_n(), mib(4), 2, 8, False, g_tmo, {}), vg)
 
 	def test_lv_create_mirror(self):
 		pv_paths = []
@@ -481,8 +486,8 @@ class TestDbusService(unittest.TestCase):
 			pv_paths.append(pp.object_path)
 
 		vg = self._vg_create(pv_paths).Vg
-		self._test_lv_create(vg.LvCreateMirror,
-							 (lv_n(), mib(4), 2, g_tmo, {}), vg)
+		self._test_lv_create(
+			vg.LvCreateMirror, (lv_n(), mib(4), 2, g_tmo, {}), vg)
 
 	def test_lv_create_raid(self):
 		pv_paths = []
@@ -490,9 +495,8 @@ class TestDbusService(unittest.TestCase):
 			pv_paths.append(pp.object_path)
 
 		vg = self._vg_create(pv_paths).Vg
-		self._test_lv_create(vg.LvCreateRaid,
-							 (lv_n(), 'raid4',
-							  mib(16), 2, 8, g_tmo, {}), vg)
+		self._test_lv_create(
+			vg.LvCreateRaid, (lv_n(), 'raid4', mib(16), 2, 8, g_tmo, {}), vg)
 
 	def _create_lv(self, thinpool=False, size=None, vg=None):
 
@@ -535,8 +539,9 @@ class TestDbusService(unittest.TestCase):
 	def test_lv_thinpool_rename(self):
 		# Rename a thin pool
 		tp = self._create_lv(True)
-		self.assertTrue(THINPOOL_LV_PATH in tp.object_path,
-						"%s" % (tp.object_path))
+		self.assertTrue(
+			THINPOOL_LV_PATH in tp.object_path,
+			"%s" % (tp.object_path))
 
 		new_name = 'renamed_' + tp.LvCommon.Name
 		self.handle_return(tp.Lv.Rename(new_name, g_tmo, {}))
@@ -612,11 +617,13 @@ class TestDbusService(unittest.TestCase):
 
 		pv = vg.Pvs
 
-		pv_proxy = ClientProxy(self.bus, pv[0])
+		pvp = ClientProxy(self.bus, pv[0])
 
-		self._test_lv_create(vg.LvCreate, (lv_n(), mib(4),
-										   dbus.Array([[pv_proxy.object_path, 0, (pv_proxy.Pv.PeCount - 1)]],
-			'(ott)'), g_tmo, {}), vg)
+		self._test_lv_create(
+			vg.LvCreate,
+			(lv_n(), mib(4),
+				dbus.Array([[pvp.object_path, 0, (pvp.Pv.PeCount - 1)]],
+				'(ott)'), g_tmo, {}), vg)
 
 	def test_lv_resize(self):
 
@@ -646,8 +653,8 @@ class TestDbusService(unittest.TestCase):
 				rc = self.handle_return(
 					lv.Lv.Resize(
 						size,
-						dbus.Array([[p.object_path, 0, p.Pv.PeCount - 1]],
-								   '(oii)'),
+						dbus.Array(
+							[[p.object_path, 0, p.Pv.PeCount - 1]], '(oii)'),
 						g_tmo, {}))
 			else:
 				rc = self.handle_return(
@@ -674,8 +681,8 @@ class TestDbusService(unittest.TestCase):
 		lv = self._create_lv(vg=vg)
 
 		with self.assertRaises(dbus.exceptions.DBusException):
-				lv.Lv.Resize(lv.LvCommon.SizeBytes, dbus.Array([], '(oii)'),
-							 -1, {})
+				lv.Lv.Resize(
+					lv.LvCommon.SizeBytes, dbus.Array([], '(oii)'), -1, {})
 
 	def test_lv_move(self):
 		lv = self._create_lv()
@@ -693,8 +700,8 @@ class TestDbusService(unittest.TestCase):
 
 		lv.update()
 		new_pv = str(lv.LvCommon.Devices[0][0])
-		self.assertTrue(pv_path_move != new_pv, "%s == %s" %
-						(pv_path_move, new_pv))
+		self.assertTrue(
+			pv_path_move != new_pv, "%s == %s" % (pv_path_move, new_pv))
 
 	def test_lv_activate_deactivate(self):
 		lv_p = self._create_lv()
@@ -923,8 +930,9 @@ class TestDbusService(unittest.TestCase):
 				vg.MaxPvSet(p, g_tmo, {}))
 			self.assertEqual(rc, '/')
 			vg.update()
-			self.assertTrue(vg.MaxPv == p, "Expected %s != Actual %s" %
-							(str(p), str(vg.MaxPv)))
+			self.assertTrue(
+				vg.MaxPv == p,
+				"Expected %s != Actual %s" % (str(p), str(vg.MaxPv)))
 
 	def test_vg_max_lv(self):
 		vg = self._vg_create().Vg
@@ -935,8 +943,9 @@ class TestDbusService(unittest.TestCase):
 			rc = self.handle_return(vg.MaxLvSet(p, g_tmo, {}))
 			self.assertEqual(rc, '/')
 			vg.update()
-			self.assertTrue(vg.MaxLv == p, "Expected %s != Actual %s" %
-							(str(p), str(vg.MaxLv)))
+			self.assertTrue(
+				vg.MaxLv == p,
+				"Expected %s != Actual %s" % (str(p), str(vg.MaxLv)))
 
 	def test_vg_uuid_gen(self):
 		# TODO renable test case when
@@ -950,8 +959,9 @@ class TestDbusService(unittest.TestCase):
 			rc = self.handle_return(vg.UuidGenerate(g_tmo, {}))
 			self.assertEqual(rc, '/')
 			vg.update()
-			self.assertTrue(vg.Uuid != prev_uuid, "Expected %s != Actual %s" %
-							(vg.Uuid, prev_uuid))
+			self.assertTrue(
+				vg.Uuid != prev_uuid,
+				"Expected %s != Actual %s" % (vg.Uuid, prev_uuid))
 
 	def test_vg_activate_deactivate(self):
 		vg = self._vg_create().Vg
@@ -1032,8 +1042,9 @@ class TestDbusService(unittest.TestCase):
 
 		self.assertEqual(
 			self.handle_return(
-				mgr.PvScan(False, True, dbus.Array([], 's'),
-						   dbus.Array([], '(ii)'), g_tmo, {})), '/')
+				mgr.PvScan(
+					False, True, dbus.Array([], 's'),
+					dbus.Array([], '(ii)'), g_tmo, {})), '/')
 
 		self.assertEqual(self._refresh(), 0)
 		self.assertEqual(
@@ -1063,13 +1074,8 @@ class TestDbusService(unittest.TestCase):
 			mm.append((int(d.properties['MAJOR']), int(d.properties['MINOR'])))
 
 		self.assertEqual(
-
 			self.handle_return(
-				mgr.PvScan
-				(False, True,
-				 block_path,
-				 mm, g_tmo, {})
-			), '/')
+				mgr.PvScan(False, True, block_path, mm, g_tmo, {})), '/')
 
 		self.assertEqual(self._refresh(), 0)
 
@@ -1150,8 +1156,8 @@ class TestDbusService(unittest.TestCase):
 
 		vg, cache_pool = self._create_cache_pool()
 
-		self.assertTrue('/com/redhat/lvmdbus1/CachePool' in
-						cache_pool.object_path)
+		self.assertTrue(
+			'/com/redhat/lvmdbus1/CachePool' in cache_pool.object_path)
 
 	def test_cache_lv_create(self):
 
@@ -1167,11 +1173,10 @@ class TestDbusService(unittest.TestCase):
 			cached_lv = ClientProxy(self.bus, c_lv_path)
 
 			uncached_lv_path = self.handle_return(
-				cached_lv.CachedLv.DetachCachePool(
-					destroy_cache, g_tmo, {}))
+				cached_lv.CachedLv.DetachCachePool(destroy_cache, g_tmo, {}))
 
-			self.assertTrue('/com/redhat/lvmdbus1/Lv' in
-							uncached_lv_path)
+			self.assertTrue(
+				'/com/redhat/lvmdbus1/Lv' in uncached_lv_path)
 
 			rc = self.handle_return(vg.Remove(g_tmo, {}))
 			self.assertTrue(rc == '/')
@@ -1236,19 +1241,21 @@ class TestDbusService(unittest.TestCase):
 						lv_n() + c,
 						mib(4), False, g_tmo, {}))
 
-		for r in ("_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
-			"_pmspare", "_rimage", "_rmeta", "_tdata", "_tmeta", "_vorigin"):
+		for reserved in (
+				"_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
+				"_pmspare", "_rimage", "_rmeta", "_tdata", "_tmeta",
+				"_vorigin"):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						lv_n() + r,
+						lv_n() + reserved,
 						mib(4), False, g_tmo, {}))
 
-		for r in ("snapshot", "pvmove"):
+		for reserved in ("snapshot", "pvmove"):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						r + lv_n(),
+						reserved + lv_n(),
 						mib(4), False, g_tmo, {}))
 
 	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
@@ -1288,16 +1295,18 @@ class TestDbusService(unittest.TestCase):
 		for i in range(1, 64):
 			tag = rs(i, "", self._ALLOWABLE_TAG_CH)
 
-			r = self.handle_return(
+			tmp = self.handle_return(
 				vg_proxy.Vg.TagsAdd([tag], g_tmo, {}))
-			self.assertTrue(r == '/')
+			self.assertTrue(tmp == '/')
 			vg_proxy.update()
 
-			self.assertTrue(tag in vg_proxy.Vg.Tags, "%s not in %s" %
-				(tag, str(vg_proxy.Vg.Tags)))
+			self.assertTrue(
+				tag in vg_proxy.Vg.Tags,
+				"%s not in %s" % (tag, str(vg_proxy.Vg.Tags)))
 
-			self.assertEqual(i, len(vg_proxy.Vg.Tags), "%d != %d" %
-				(i, len(vg_proxy.Vg.Tags)))
+			self.assertEqual(
+				i, len(vg_proxy.Vg.Tags),
+				"%d != %d" % (i, len(vg_proxy.Vg.Tags)))
 
 	def test_tag_regression(self):
 		mgr = self.objs[MANAGER_INT][0].Manager
@@ -1309,14 +1318,15 @@ class TestDbusService(unittest.TestCase):
 
 		tag = '--h/K.6g0A4FOEatf3+k_nI/Yp&L_u2oy-=j649x:+dUcYWPEo6.IWT0c'
 
-		r = self.handle_return(
+		tmp = self.handle_return(
 			vg_proxy.Vg.TagsAdd([tag], g_tmo, {})
 		)
-		self.assertTrue(r == '/')
+		self.assertTrue(tmp == '/')
 		vg_proxy.update()
 
-		self.assertTrue(tag in vg_proxy.Vg.Tags, "%s not in %s" %
-						(tag, str(vg_proxy.Vg.Tags)))
+		self.assertTrue(
+			tag in vg_proxy.Vg.Tags,
+			"%s not in %s" % (tag, str(vg_proxy.Vg.Tags)))
 
 
 class AggregateResults(object):
@@ -1364,7 +1374,8 @@ if __name__ == '__main__':
 			r.register_result(unittest.main(exit=False))
 		else:
 			r.register_fail()
-			std_err_print("ERROR: Unable to dynamically configure "
-				"service to use lvm shell!")
+			std_err_print(
+				"ERROR: Unable to dynamically configure service to use "
+				"lvm shell!")
 
 	r.exit_run()
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index b382482..d88ebbd 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -32,8 +32,7 @@ THINPOOL_LV_PATH = '/' + THINPOOL_INT.replace('.', '/')
 
 
 def rs(length, suffix, character_set=string.ascii_lowercase):
-	return ''.join(random.choice(character_set)
-				for _ in range(length)) + suffix
+	return ''.join(random.choice(character_set) for _ in range(length)) + suffix
 
 
 def mib(s):
@@ -50,8 +49,7 @@ class DbusIntrospection(object):
 		for c in root:
 			if c.tag == "interface":
 				in_f = c.attrib['name']
-				interfaces[in_f] = \
-					dict(methods=OrderedDict(), properties={})
+				interfaces[in_f] = dict(methods=OrderedDict(), properties={})
 				for nested in c:
 					if nested.tag == "method":
 						mn = nested.attrib['name']
@@ -71,7 +69,8 @@ class DbusIntrospection(object):
 									v = dict(
 											name=mn,
 											a_dir=arg_dir,
-											a_type=arg_type)
+											a_type=arg_type
+									)
 									interfaces[in_f]['methods'][mn][n] = v
 
 					elif nested.tag == 'property':
@@ -148,10 +147,9 @@ def verify_type(value, dbus_str_rep):
 		# print("%s ~= %s" % (dbus_str_rep, actual_str_rep))
 		# Unless we have a full filled out type we won't match exactly
 		if not dbus_str_rep.startswith(actual_str_rep):
-			raise RuntimeError("Incorrect type, expected= %s actual "
-								"= %s object= %s" %
-								(dbus_str_rep, actual_str_rep,
-								str(type(value))))
+			raise RuntimeError(
+				"Incorrect type, expected= %s actual = %s object= %s" %
+				(dbus_str_rep, actual_str_rep, str(type(value))))
 
 
 class RemoteObject(object):
@@ -174,12 +172,14 @@ class RemoteObject(object):
 		if props:
 			for kl, vl in list(props.items()):
 				# Verify type is correct!
-				verify_type(vl,
+				verify_type(
+					vl,
 					self.introspect[self.interface]['properties'][kl]['p_type'])
 				setattr(self, kl, vl)
 
-	def __init__(self, specified_bus, object_path, interface, introspect,
-				 properties=None):
+	def __init__(
+			self, specified_bus, object_path, interface, introspect,
+			properties=None):
 		self.object_path = object_path
 		self.interface = interface
 		self.bus = specified_bus
@@ -238,11 +238,11 @@ class ClientProxy(object):
 			# print('Client proxy has interface: %s %s' % (k, sn))
 
 			if interface and interface == k and props is not None:
-				ro = RemoteObject(specified_bus, object_path, k,
-								  self.intro_spect, props)
+				ro = RemoteObject(
+					specified_bus, object_path, k, self.intro_spect, props)
 			else:
-				ro = RemoteObject(specified_bus, object_path, k,
-								  self.intro_spect)
+				ro = RemoteObject(
+					specified_bus, object_path, k, self.intro_spect)
 
 			setattr(self, sn, ro)
 


