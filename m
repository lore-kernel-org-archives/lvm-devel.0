From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:07 -0400
Subject: master - lvmdbustest.py: Add func. _all_pv_object_paths
Message-ID: <201910301544.x9UFi7F9016673@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4666f63ade186e960c5f70399389e0d2fb28c81
Commit:        a4666f63ade186e960c5f70399389e0d2fb28c81
Parent:        b8d496911765ec07f80eee174623e503506e7401
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 15:25:17 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Add func. _all_pv_object_paths

This is needed in a number of places.
---
 test/dbus/lvmdbustest.py |   67 ++++++++++-----------------------------------
 1 files changed, 15 insertions(+), 52 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 1ab4ce6..d3e1f53 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -356,11 +356,7 @@ class TestDbusService(unittest.TestCase):
 		data_name = "data_r5"
 
 		if not vg:
-			pv_paths = []
-			for pp in self.objs[PV_INT]:
-				pv_paths.append(pp.object_path)
-
-			vg = self._vg_create(pv_paths).Vg
+			vg = self._vg_create(self._all_pv_object_paths()).Vg
 
 		lv_meta_path = self.handle_return(
 			vg.LvCreateRaid(
@@ -668,13 +664,12 @@ class TestDbusService(unittest.TestCase):
 			vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
+	def _all_pv_object_paths(self):
+		return [pp.object_path for pp in self.objs[PV_INT]]
+
 	def test_lv_create_striped(self):
 		lv_name = lv_n()
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
-
-		vg = self._vg_create(pv_paths).Vg
+		vg = self._vg_create(self._all_pv_object_paths()).Vg
 		lv = self._test_lv_create(
 			vg.LvCreateStriped,
 			(dbus.String(lv_name), dbus.UInt64(mib(4)),
@@ -685,11 +680,7 @@ class TestDbusService(unittest.TestCase):
 
 	def test_lv_create_mirror(self):
 		lv_name = lv_n()
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
-
-		vg = self._vg_create(pv_paths).Vg
+		vg = self._vg_create(self._all_pv_object_paths()).Vg
 		lv = self._test_lv_create(
 			vg.LvCreateMirror,
 			(dbus.String(lv_name), dbus.UInt64(mib(4)), dbus.UInt32(2),
@@ -698,11 +689,7 @@ class TestDbusService(unittest.TestCase):
 
 	def test_lv_create_raid(self):
 		lv_name = lv_n()
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
-
-		vg = self._vg_create(pv_paths).Vg
+		vg = self._vg_create(self._all_pv_object_paths()).Vg
 		lv = self._test_lv_create(
 			vg.LvCreateRaid,
 			(dbus.String(lv_name), dbus.String('raid5'), dbus.UInt64(mib(16)),
@@ -721,11 +708,7 @@ class TestDbusService(unittest.TestCase):
 			interfaces.append(THINPOOL_INT)
 
 		if not vg:
-			pv_paths = []
-			for pp in self.objs[PV_INT]:
-				pv_paths.append(pp.object_path)
-
-			vg = self._vg_create(pv_paths).Vg
+			vg = self._vg_create(self._all_pv_object_paths()).Vg
 
 		if size is None:
 			size = mib(4)
@@ -922,11 +905,7 @@ class TestDbusService(unittest.TestCase):
 				self.assertTrue(lv.LvCommon.SizeBytes <= prev)
 
 	def test_lv_resize_same(self):
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
-
-		vg = self._vg_create(pv_paths).Vg
+		vg = self._vg_create(self._all_pv_object_paths()).Vg
 		lv = self._create_lv(vg=vg)
 
 		with self.assertRaises(dbus.exceptions.DBusException):
@@ -1025,10 +1004,7 @@ class TestDbusService(unittest.TestCase):
 		self._check_consistency()
 
 	def test_job_handling(self):
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
-
+		pv_paths = self._all_pv_object_paths()
 		vg_name = vg_n()
 
 		# Test getting a job right away
@@ -1046,15 +1022,12 @@ class TestDbusService(unittest.TestCase):
 
 	def _test_expired_timer(self, num_lvs):
 		rc = False
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
 
 		# In small configurations lvm is pretty snappy, so lets create a VG
 		# add a number of LVs and then remove the VG and all the contained
 		# LVs which appears to consistently run a little slow.
 
-		vg_proxy = self._vg_create(pv_paths)
+		vg_proxy = self._vg_create(self._all_pv_object_paths())
 
 		for i in range(0, num_lvs):
 			lv_name = lv_n()
@@ -1118,12 +1091,7 @@ class TestDbusService(unittest.TestCase):
 
 	def test_pv_tags(self):
 		pvs = []
-
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
-
-		vg = self._vg_create(pv_paths).Vg
+		vg = self._vg_create(self._all_pv_object_paths()).Vg
 
 		# Get the PVs
 		for p in vg.Pvs:
@@ -1333,12 +1301,7 @@ class TestDbusService(unittest.TestCase):
 			self.assertTrue(pv.SizeBytes == original_size)
 
 	def test_pv_allocation(self):
-
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
-
-		vg = self._vg_create(pv_paths).Vg
+		vg = self._vg_create(self._all_pv_object_paths()).Vg
 
 		pv = ClientProxy(self.bus, vg.Pvs[0], interfaces=(PV_INT, )).Pv
 
@@ -1753,10 +1716,10 @@ class TestDbusService(unittest.TestCase):
 		vg_name = vg_n()
 
 		# Get all the PV device paths
-		pv_paths = [p.Pv.Name for p in self.objs[PV_INT]]
+		pv_device_paths = [p.Pv.Name for p in self.objs[PV_INT]]
 
 		cmd = ['vgcreate', vg_name]
-		cmd.extend(pv_paths)
+		cmd.extend(pv_device_paths)
 		self._verify_existence(cmd, cmd[0], vg_name)
 
 	def test_external_lv_create(self):


