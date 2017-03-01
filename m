From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 1 Mar 2017 18:58:58 -0500
Subject: master - lvmdbustest.py: Validate LV lookups
Message-ID: <201703012358.v21Nww4P018029@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b0371e74ecb4ceab18e937508daa66a8d636259
Commit:        7b0371e74ecb4ceab18e937508daa66a8d636259
Parent:        83249f332709037256bf0f3c7c3d3663addaffc6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 1 17:26:23 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 1 17:47:04 2017 -0600

lvmdbustest.py: Validate LV lookups

Ensure that the LV lookups work as expected for newly created LVs.
---
 test/dbus/lvmdbustest.py |  108 ++++++++++++++++++++++++++++++++--------------
 1 files changed, 76 insertions(+), 32 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 800f590..c0a3d64 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -267,6 +267,9 @@ class TestDbusService(unittest.TestCase):
 
 	def _create_raid5_thin_pool(self, vg=None):
 
+		meta_name = "meta_r5"
+		data_name = "data_r5"
+
 		if not vg:
 			pv_paths = []
 			for pp in self.objs[PV_INT]:
@@ -276,7 +279,7 @@ class TestDbusService(unittest.TestCase):
 
 		lv_meta_path = self.handle_return(
 			vg.LvCreateRaid(
-				dbus.String("meta_r5"),
+				dbus.String(meta_name),
 				dbus.String("raid5"),
 				dbus.UInt64(mib(4)),
 				dbus.UInt32(0),
@@ -284,10 +287,11 @@ class TestDbusService(unittest.TestCase):
 				dbus.Int32(g_tmo),
 				EOD)
 		)
+		self._validate_lookup("%s/%s" % (vg.Name, meta_name), lv_meta_path)
 
 		lv_data_path = self.handle_return(
 			vg.LvCreateRaid(
-				dbus.String("data_r5"),
+				dbus.String(data_name),
 				dbus.String("raid5"),
 				dbus.UInt64(mib(16)),
 				dbus.UInt32(0),
@@ -296,6 +300,8 @@ class TestDbusService(unittest.TestCase):
 				EOD)
 		)
 
+		self._validate_lookup("%s/%s" % (vg.Name, data_name), lv_data_path)
+
 		thin_pool_path = self.handle_return(
 			vg.CreateThinPool(
 				dbus.ObjectPath(lv_meta_path),
@@ -492,6 +498,9 @@ class TestDbusService(unittest.TestCase):
 					dbus.Int32(g_tmo),
 					EOD))
 
+			self._validate_lookup(
+				"%s/%s" % (vg_name_start, lv_name), thin_lv_path)
+
 			self.assertTrue(thin_lv_path != '/')
 
 			full_name = "%s/%s" % (vg_name_start, lv_name)
@@ -549,75 +558,88 @@ class TestDbusService(unittest.TestCase):
 		return lv
 
 	def test_lv_create(self):
+		lv_name = lv_n()
 		vg = self._vg_create().Vg
-		self._test_lv_create(
+		lv = self._test_lv_create(
 			vg.LvCreate,
-			(dbus.String(lv_n()), dbus.UInt64(mib(4)),
+			(dbus.String(lv_name), dbus.UInt64(mib(4)),
 			dbus.Array([], signature='(ott)'), dbus.Int32(g_tmo),
 			EOD), vg, LV_BASE_INT)
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def test_lv_create_job(self):
-
+		lv_name = lv_n()
 		vg = self._vg_create().Vg
 		(object_path, job_path) = vg.LvCreate(
-			dbus.String(lv_n()), dbus.UInt64(mib(4)),
+			dbus.String(lv_name), dbus.UInt64(mib(4)),
 			dbus.Array([], signature='(ott)'), dbus.Int32(0),
 			EOD)
 
 		self.assertTrue(object_path == '/')
 		self.assertTrue(job_path != '/')
 		object_path = self._wait_for_job(job_path)
+
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), object_path)
 		self.assertTrue(object_path != '/')
 
 	def test_lv_create_linear(self):
 
+		lv_name = lv_n()
 		vg = self._vg_create().Vg
-		self._test_lv_create(
+		lv = self._test_lv_create(
 			vg.LvCreateLinear,
-			(dbus.String(lv_n()), dbus.UInt64(mib(4)), dbus.Boolean(False),
+			(dbus.String(lv_name), dbus.UInt64(mib(4)), dbus.Boolean(False),
 			dbus.Int32(g_tmo), EOD),
 			vg, LV_BASE_INT)
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def test_lv_create_striped(self):
+		lv_name = lv_n()
 		pv_paths = []
 		for pp in self.objs[PV_INT]:
 			pv_paths.append(pp.object_path)
 
 		vg = self._vg_create(pv_paths).Vg
-		self._test_lv_create(
+		lv = self._test_lv_create(
 			vg.LvCreateStriped,
-			(dbus.String(lv_n()), dbus.UInt64(mib(4)),
+			(dbus.String(lv_name), dbus.UInt64(mib(4)),
 			dbus.UInt32(2), dbus.UInt32(8), dbus.Boolean(False),
 			dbus.Int32(g_tmo), EOD),
 			vg, LV_BASE_INT)
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def test_lv_create_mirror(self):
+		lv_name = lv_n()
 		pv_paths = []
 		for pp in self.objs[PV_INT]:
 			pv_paths.append(pp.object_path)
 
 		vg = self._vg_create(pv_paths).Vg
-		self._test_lv_create(
+		lv = self._test_lv_create(
 			vg.LvCreateMirror,
-			(dbus.String(lv_n()), dbus.UInt64(mib(4)), dbus.UInt32(2),
+			(dbus.String(lv_name), dbus.UInt64(mib(4)), dbus.UInt32(2),
 			dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def test_lv_create_raid(self):
+		lv_name = lv_n()
 		pv_paths = []
 		for pp in self.objs[PV_INT]:
 			pv_paths.append(pp.object_path)
 
 		vg = self._vg_create(pv_paths).Vg
-		self._test_lv_create(
+		lv = self._test_lv_create(
 			vg.LvCreateRaid,
-			(dbus.String(lv_n()), dbus.String('raid5'), dbus.UInt64(mib(16)),
+			(dbus.String(lv_name), dbus.String('raid5'), dbus.UInt64(mib(16)),
 			dbus.UInt32(2), dbus.UInt32(8), dbus.Int32(g_tmo),
 			EOD),
 			vg,
 			LV_BASE_INT)
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def _create_lv(self, thinpool=False, size=None, vg=None):
 
+		lv_name = lv_n()
 		interfaces = list(LV_BASE_INT)
 
 		if thinpool:
@@ -633,12 +655,15 @@ class TestDbusService(unittest.TestCase):
 		if size is None:
 			size = mib(4)
 
-		return self._test_lv_create(
+		lv = self._test_lv_create(
 			vg.LvCreateLinear,
-			(dbus.String(lv_n()), dbus.UInt64(size),
+			(dbus.String(lv_name), dbus.UInt64(size),
 			dbus.Boolean(thinpool), dbus.Int32(g_tmo), EOD),
 			vg, interfaces)
 
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
+		return lv
+
 	def test_lv_create_rounding(self):
 		self._create_lv(size=(mib(2) + 13))
 
@@ -682,26 +707,32 @@ class TestDbusService(unittest.TestCase):
 
 		# This returns a LV with the LV interface, need to get a proxy for
 		# thinpool interface too
-		tp = self._create_lv(True)
+		vg = self._vg_create().Vg
+		tp = self._create_lv(thinpool=True, vg=vg)
+
+		lv_name = lv_n('_thin_lv')
 
 		thin_path = self.handle_return(
 			tp.ThinPool.LvCreate(
-				dbus.String(lv_n('_thin_lv')),
+				dbus.String(lv_name),
 				dbus.UInt64(mib(8)),
 				dbus.Int32(g_tmo),
 				EOD)
 		)
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), thin_path)
 
 		lv = ClientProxy(self.bus, thin_path,
 							interfaces=(LV_COMMON_INT, LV_INT))
 
+		re_named = 'rename_test' + lv.LvCommon.Name
 		rc = self.handle_return(
 			lv.Lv.Rename(
-				dbus.String('rename_test' + lv.LvCommon.Name),
+				dbus.String(re_named),
 				dbus.Int32(g_tmo),
 				EOD)
 		)
 
+		self._validate_lookup("%s/%s" % (vg.Name, re_named), thin_path)
 		self.assertTrue(rc == '/')
 		self._check_consistency()
 
@@ -753,18 +784,18 @@ class TestDbusService(unittest.TestCase):
 
 	def test_lv_create_pv_specific(self):
 		vg = self._vg_create().Vg
-
+		lv_name = lv_n()
 		pv = vg.Pvs
-
 		pvp = ClientProxy(self.bus, pv[0], interfaces=(PV_INT,))
 
-		self._test_lv_create(
+		lv = self._test_lv_create(
 			vg.LvCreate, (
-				dbus.String(lv_n()),
+				dbus.String(lv_name),
 				dbus.UInt64(mib(4)),
 				dbus.Array([[pvp.object_path, 0, (pvp.Pv.PeCount - 1)]],
 				signature='(ott)'),
 				dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
 	def test_lv_resize(self):
 
@@ -951,17 +982,20 @@ class TestDbusService(unittest.TestCase):
 		vg_proxy = self._vg_create(pv_paths)
 
 		for i in range(0, num_lvs):
-
+			lv_name = lv_n()
 			vg_proxy.update()
 			if vg_proxy.Vg.FreeCount > 0:
-				job = self.handle_return(
+				lv_path = self.handle_return(
 					vg_proxy.Vg.LvCreateLinear(
-						dbus.String(lv_n()),
+						dbus.String(lv_name),
 						dbus.UInt64(mib(4)),
 						dbus.Boolean(False),
 						dbus.Int32(g_tmo),
 						EOD))
-				self.assertTrue(job != '/')
+				self.assertTrue(lv_path != '/')
+				self._validate_lookup(
+					"%s/%s" % (vg_proxy.Vg.Name, lv_name), lv_path)
+
 			else:
 				# We ran out of space, test will probably fail
 				break
@@ -1070,15 +1104,18 @@ class TestDbusService(unittest.TestCase):
 
 	def test_lv_tags(self):
 		vg = self._vg_create().Vg
+		lv_name = lv_n()
 		lv = self._test_lv_create(
 			vg.LvCreateLinear,
-			(dbus.String(lv_n()),
+			(dbus.String(lv_name),
 			dbus.UInt64(mib(4)),
 			dbus.Boolean(False),
 			dbus.Int32(g_tmo),
 			EOD),
 			vg, LV_BASE_INT)
 
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
+
 		t = ['Testing', 'tags']
 
 		self.handle_return(
@@ -1154,15 +1191,18 @@ class TestDbusService(unittest.TestCase):
 
 	def test_vg_activate_deactivate(self):
 		vg = self._vg_create().Vg
-		self._test_lv_create(
+		lv_name = lv_n()
+		lv = self._test_lv_create(
 			vg.LvCreateLinear, (
-				dbus.String(lv_n()),
+				dbus.String(lv_name),
 				dbus.UInt64(mib(4)),
 				dbus.Boolean(False),
 				dbus.Int32(g_tmo),
 				EOD),
 			vg, LV_BASE_INT)
 
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
+
 		vg.update()
 
 		rc = self.handle_return(
@@ -1367,15 +1407,19 @@ class TestDbusService(unittest.TestCase):
 
 	def test_snapshot_merge_thin(self):
 		# Create a thin LV, snapshot it and merge it
-		tp = self._create_lv(True)
+		vg = self._vg_create().Vg
+		tp = self._create_lv(thinpool=True, vg=vg)
+		lv_name = lv_n('_thin_lv')
 
 		thin_path = self.handle_return(
 			tp.ThinPool.LvCreate(
-				dbus.String(lv_n('_thin_lv')),
+				dbus.String(lv_name),
 				dbus.UInt64(mib(10)),
 				dbus.Int32(g_tmo),
 				EOD))
 
+		self._validate_lookup("%s/%s" % (vg.Name, lv_name), thin_path)
+
 		lv_p = ClientProxy(self.bus, thin_path,
 							interfaces=(LV_INT, LV_COMMON_INT))
 


