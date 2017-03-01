From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 1 Mar 2017 18:58:42 -0500
Subject: master - lvmdbustest.py: Verify lookups work immediately after vg create
Message-ID: <201703012358.v21NwgAV009958@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=10c3d94159e3a740e22bb3c72fef18cb26bfc19f
Commit:        10c3d94159e3a740e22bb3c72fef18cb26bfc19f
Parent:        157948b5a5f6f651fa56ec45f71b031c1a132c15
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 1 11:09:51 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 1 17:47:04 2017 -0600

lvmdbustest.py: Verify lookups work immediately after vg create

---
 test/dbus/lvmdbustest.py |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 20bf38e..7ee4a49 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -229,6 +229,7 @@ class TestDbusService(unittest.TestCase):
 				dbus.Int32(g_tmo),
 				EOD))
 
+		self._validate_vg_lookup(vg_name, vg_path)
 		self.assertTrue(vg_path is not None and len(vg_path) > 0)
 		return ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
@@ -342,6 +343,10 @@ class TestDbusService(unittest.TestCase):
 		return self.objs[MANAGER_INT][0].\
 			Manager.LookUpByLvmId(dbus.String(lvm_id))
 
+	def _validate_vg_lookup(self, vg_name, object_path):
+		t = self._lookup(vg_name)
+		self.assertTrue(object_path == t, "%s != %s" % (object_path, t))
+
 	def test_lookup_by_lvm_id(self):
 		# For the moment lets just lookup what we know about which is PVs
 		# When we start testing VGs and LVs we will test lookups for those
@@ -926,7 +931,8 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(vg_path == '/')
 		self.assertTrue(vg_job and len(vg_job) > 0)
 
-		self._wait_for_job(vg_job)
+		vg_path = self._wait_for_job(vg_job)
+		self._validate_vg_lookup(vg_name, vg_path)
 
 	def _test_expired_timer(self, num_lvs):
 		rc = False
@@ -1508,12 +1514,14 @@ class TestDbusService(unittest.TestCase):
 						EOD))
 
 		# Create a VG and try to create LVs with different bad names
+		vg_name = vg_n()
 		vg_path = self.handle_return(
 			mgr.VgCreate(
-				dbus.String(vg_n()),
+				dbus.String(vg_name),
 				dbus.Array(pv_paths, 'o'),
 				dbus.Int32(g_tmo),
 				EOD))
+		self._validate_vg_lookup(vg_name, vg_path)
 
 		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
@@ -1559,13 +1567,16 @@ class TestDbusService(unittest.TestCase):
 	def test_invalid_tags(self):
 		mgr = self.objs[MANAGER_INT][0].Manager
 		pv_paths = [self.objs[PV_INT][0].object_path]
+		vg_name = vg_n()
 
 		vg_path = self.handle_return(
 			mgr.VgCreate(
-				dbus.String(vg_n()),
+				dbus.String(vg_name),
 				dbus.Array(pv_paths, 'o'),
 				dbus.Int32(g_tmo),
 				EOD))
+		self._validate_vg_lookup(vg_name, vg_path)
+
 		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 		for c in self._invalid_tag_characters():
@@ -1587,13 +1598,15 @@ class TestDbusService(unittest.TestCase):
 	def test_tag_names(self):
 		mgr = self.objs[MANAGER_INT][0].Manager
 		pv_paths = [self.objs[PV_INT][0].object_path]
+		vg_name = vg_n()
 
 		vg_path = self.handle_return(
 			mgr.VgCreate(
-				dbus.String(vg_n()),
+				dbus.String(vg_name),
 				dbus.Array(pv_paths, 'o'),
 				dbus.Int32(g_tmo),
 				EOD))
+		self._validate_vg_lookup(vg_name, vg_path)
 		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 		for i in range(1, 64):
@@ -1618,13 +1631,15 @@ class TestDbusService(unittest.TestCase):
 	def test_tag_regression(self):
 		mgr = self.objs[MANAGER_INT][0].Manager
 		pv_paths = [self.objs[PV_INT][0].object_path]
+		vg_name = vg_n()
 
 		vg_path = self.handle_return(
 			mgr.VgCreate(
-				dbus.String(vg_n()),
+				dbus.String(vg_name),
 				dbus.Array(pv_paths, 'o'),
 				dbus.Int32(g_tmo),
 				EOD))
+		self._validate_vg_lookup(vg_name, vg_path)
 		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 		tag = '--h/K.6g0A4FOEatf3+k_nI/Yp&L_u2oy-=j649x:+dUcYWPEo6.IWT0c'


