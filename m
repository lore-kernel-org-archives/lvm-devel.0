From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 1 Mar 2017 18:58:47 -0500
Subject: master - lvmdbustest.py: Re-name validation function
Message-ID: <201703012358.v21Nwlhx023212@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c89d3794c64b674191bb9c767415cc2ba919e3a
Commit:        4c89d3794c64b674191bb9c767415cc2ba919e3a
Parent:        10c3d94159e3a740e22bb3c72fef18cb26bfc19f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 1 17:22:32 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 1 17:47:04 2017 -0600

lvmdbustest.py: Re-name validation function

Make this name generic as we can use for different types.
---
 test/dbus/lvmdbustest.py |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 7ee4a49..0e27ae3 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -229,7 +229,7 @@ class TestDbusService(unittest.TestCase):
 				dbus.Int32(g_tmo),
 				EOD))
 
-		self._validate_vg_lookup(vg_name, vg_path)
+		self._validate_lookup(vg_name, vg_path)
 		self.assertTrue(vg_path is not None and len(vg_path) > 0)
 		return ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
@@ -343,9 +343,10 @@ class TestDbusService(unittest.TestCase):
 		return self.objs[MANAGER_INT][0].\
 			Manager.LookUpByLvmId(dbus.String(lvm_id))
 
-	def _validate_vg_lookup(self, vg_name, object_path):
-		t = self._lookup(vg_name)
-		self.assertTrue(object_path == t, "%s != %s" % (object_path, t))
+	def _validate_lookup(self, lvm_name, object_path):
+		t = self._lookup(lvm_name)
+		self.assertTrue(
+			object_path == t, "%s != %s for %s" % (object_path, t, lvm_name))
 
 	def test_lookup_by_lvm_id(self):
 		# For the moment lets just lookup what we know about which is PVs
@@ -932,7 +933,7 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(vg_job and len(vg_job) > 0)
 
 		vg_path = self._wait_for_job(vg_job)
-		self._validate_vg_lookup(vg_name, vg_path)
+		self._validate_lookup(vg_name, vg_path)
 
 	def _test_expired_timer(self, num_lvs):
 		rc = False
@@ -1521,7 +1522,7 @@ class TestDbusService(unittest.TestCase):
 				dbus.Array(pv_paths, 'o'),
 				dbus.Int32(g_tmo),
 				EOD))
-		self._validate_vg_lookup(vg_name, vg_path)
+		self._validate_lookup(vg_name, vg_path)
 
 		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
@@ -1575,7 +1576,7 @@ class TestDbusService(unittest.TestCase):
 				dbus.Array(pv_paths, 'o'),
 				dbus.Int32(g_tmo),
 				EOD))
-		self._validate_vg_lookup(vg_name, vg_path)
+		self._validate_lookup(vg_name, vg_path)
 
 		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
@@ -1606,7 +1607,7 @@ class TestDbusService(unittest.TestCase):
 				dbus.Array(pv_paths, 'o'),
 				dbus.Int32(g_tmo),
 				EOD))
-		self._validate_vg_lookup(vg_name, vg_path)
+		self._validate_lookup(vg_name, vg_path)
 		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 		for i in range(1, 64):
@@ -1639,7 +1640,7 @@ class TestDbusService(unittest.TestCase):
 				dbus.Array(pv_paths, 'o'),
 				dbus.Int32(g_tmo),
 				EOD))
-		self._validate_vg_lookup(vg_name, vg_path)
+		self._validate_lookup(vg_name, vg_path)
 		vg_proxy = ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
 
 		tag = '--h/K.6g0A4FOEatf3+k_nI/Yp&L_u2oy-=j649x:+dUcYWPEo6.IWT0c'


