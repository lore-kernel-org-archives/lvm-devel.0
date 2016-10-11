From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 11 Oct 2016 18:18:51 +0000 (UTC)
Subject: master - lvmdbustest.py: Add $PREFIX support
Message-ID: <20161011181851.926EF60DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c56902365c4987b291e9ecdb853d9c4d14767c8
Commit:        9c56902365c4987b291e9ecdb853d9c4d14767c8
Parent:        595af62ebd8eca6b95266f617df67528f3b70fd8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 11 12:02:10 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Oct 11 13:16:57 2016 -0500

lvmdbustest.py: Add $PREFIX support

Use the env variable PREFIX for vg & lv names
---
 test/dbus/lvmdbustest.py |   52 +++++++++++++++++++++++++++++----------------
 1 files changed, 33 insertions(+), 19 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 1991c94..9432c79 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -21,6 +21,8 @@ from testlib import *
 
 g_tmo = 0
 
+g_prefix = os.getenv('PREFIX', '')
+
 use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
 if use_session:
@@ -34,6 +36,18 @@ def std_err_print(*args):
 	sys.stderr.flush()
 
 
+def vg_n():
+	return g_prefix + rs(8, '_vg')
+
+
+def lv_n(suffix=None):
+	if not suffix:
+		s = '_lv'
+	else:
+		s = suffix
+	return g_prefix + rs(8, s)
+
+
 def get_objects():
 	rc = {MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
 			THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
@@ -146,7 +160,7 @@ class TestDbusService(unittest.TestCase):
 		if not pv_paths:
 			pv_paths = [self.objs[PV_INT][0].object_path]
 
-		vg_name = rs(8, '_vg')
+		vg_name = vg_n()
 
 		vg_path = self.handle_return(
 			self.objs[MANAGER_INT][0].Manager.VgCreate(
@@ -367,7 +381,7 @@ class TestDbusService(unittest.TestCase):
 		self._verify_hidden_lookups(thin_pool.LvCommon, vg_name_start)
 
 		for i in range(0, 5):
-			lv_name = rs(8, '_lv')
+			lv_name = lv_n()
 
 			thin_lv_path = self.handle_return(
 				thin_pool.ThinPool.LvCreate(
@@ -429,13 +443,13 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreate,
-			(rs(8, '_lv'), mib(4),
+			(lv_n(), mib(4),
 			 dbus.Array([], '(ott)'), g_tmo, {}), vg)
 
 	def test_lv_create_job(self):
 
 		vg = self._vg_create().Vg
-		(object_path, job_path) = vg.LvCreate(rs(8, '_lv'), mib(4),
+		(object_path, job_path) = vg.LvCreate(lv_n(), mib(4),
 			dbus.Array([], '(ott)'), 0, {})
 
 		self.assertTrue(object_path == '/')
@@ -448,7 +462,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), mib(4), False, g_tmo, {}), vg)
+			(lv_n(), mib(4), False, g_tmo, {}), vg)
 
 	def test_lv_create_striped(self):
 		pv_paths = []
@@ -458,7 +472,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(
 			vg.LvCreateStriped,
-			(rs(8, '_lv'), mib(4), 2, 8, False,
+			(lv_n(), mib(4), 2, 8, False,
 			 g_tmo, {}), vg)
 
 	def test_lv_create_mirror(self):
@@ -468,7 +482,7 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(vg.LvCreateMirror,
-							 (rs(8, '_lv'), mib(4), 2, g_tmo, {}), vg)
+							 (lv_n(), mib(4), 2, g_tmo, {}), vg)
 
 	def test_lv_create_raid(self):
 		pv_paths = []
@@ -477,7 +491,7 @@ class TestDbusService(unittest.TestCase):
 
 		vg = self._vg_create(pv_paths).Vg
 		self._test_lv_create(vg.LvCreateRaid,
-							 (rs(8, '_lv'), 'raid4',
+							 (lv_n(), 'raid4',
 							  mib(16), 2, 8, g_tmo, {}), vg)
 
 	def _create_lv(self, thinpool=False, size=None, vg=None):
@@ -494,7 +508,7 @@ class TestDbusService(unittest.TestCase):
 
 		return self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), size, thinpool, g_tmo, {}), vg)
+			(lv_n(), size, thinpool, g_tmo, {}), vg)
 
 	def test_lv_create_rounding(self):
 		self._create_lv(size=(mib(2) + 13))
@@ -540,7 +554,7 @@ class TestDbusService(unittest.TestCase):
 
 		thin_path = self.handle_return(
 			tp.ThinPool.LvCreate(
-				rs(10, '_thin_lv'), mib(8), g_tmo, {})
+				lv_n('_thin_lv'), mib(8), g_tmo, {})
 		)
 
 		lv = ClientProxy(self.bus, thin_path)
@@ -600,7 +614,7 @@ class TestDbusService(unittest.TestCase):
 
 		pv_proxy = ClientProxy(self.bus, pv[0])
 
-		self._test_lv_create(vg.LvCreate, (rs(8, '_lv'), mib(4),
+		self._test_lv_create(vg.LvCreate, (lv_n(), mib(4),
 										   dbus.Array([[pv_proxy.object_path, 0, (pv_proxy.Pv.PeCount - 1)]],
 			'(ott)'), g_tmo, {}), vg)
 
@@ -745,7 +759,7 @@ class TestDbusService(unittest.TestCase):
 		for pp in self.objs[PV_INT]:
 			pv_paths.append(pp.object_path)
 
-		vg_name = rs(8, '_vg')
+		vg_name = vg_n()
 
 		# Test getting a job right away
 		vg_path, vg_job = self.objs[MANAGER_INT][0].Manager.VgCreate(
@@ -775,7 +789,7 @@ class TestDbusService(unittest.TestCase):
 			if vg_proxy.Vg.FreeCount > 0:
 				job = self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						rs(8, "_lv"), mib(4), False, g_tmo, {}))
+						lv_n(), mib(4), False, g_tmo, {}))
 				self.assertTrue(job != '/')
 			else:
 				# We ran out of space, test will probably fail
@@ -871,7 +885,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		lv = self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), mib(4), False, g_tmo, {}),
+			(lv_n(), mib(4), False, g_tmo, {}),
 			vg)
 
 		t = ['Testing', 'tags']
@@ -943,7 +957,7 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create().Vg
 		self._test_lv_create(
 			vg.LvCreateLinear,
-			(rs(8, '_lv'), mib(4), False, g_tmo, {}),
+			(lv_n(), mib(4), False, g_tmo, {}),
 			vg)
 
 		vg.update()
@@ -1102,7 +1116,7 @@ class TestDbusService(unittest.TestCase):
 
 		thin_path = self.handle_return(
 			tp.ThinPool.LvCreate(
-				rs(10, '_thin_lv'), mib(10), g_tmo, {}))
+				lv_n('_thin_lv'), mib(10), g_tmo, {}))
 
 		lv_p = ClientProxy(self.bus, thin_path)
 
@@ -1219,7 +1233,7 @@ class TestDbusService(unittest.TestCase):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						rs(8, '_lv') + c,
+						lv_n() + c,
 						mib(4), False, g_tmo, {}))
 
 		for r in ("_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
@@ -1227,14 +1241,14 @@ class TestDbusService(unittest.TestCase):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						rs(8, '_lv') + r,
+						lv_n() + r,
 						mib(4), False, g_tmo, {}))
 
 		for r in ("snapshot", "pvmove"):
 			with self.assertRaises(dbus.exceptions.DBusException):
 				self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						r + rs(8, '_lv'),
+						r + lv_n(),
 						mib(4), False, g_tmo, {}))
 
 	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"


