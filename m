From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 1 Mar 2017 18:58:38 -0500
Subject: master - lvmdbustest.py: Use _lookup function
Message-ID: <201703012358.v21NwcAm024422@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=157948b5a5f6f651fa56ec45f71b031c1a132c15
Commit:        157948b5a5f6f651fa56ec45f71b031c1a132c15
Parent:        c25b95e2ef01874e67048f96b1e4928ec12fdb4e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 1 09:35:01 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 1 17:47:04 2017 -0600

lvmdbustest.py: Use _lookup function

Be consistent in using this helper function for dbus object lookups.
---
 test/dbus/lvmdbustest.py |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index af4fef1..20bf38e 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -339,7 +339,8 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(cached_thin_pool_object.ThinPool.MetaDataLv != '/')
 
 	def _lookup(self, lvm_id):
-		return self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(lvm_id)
+		return self.objs[MANAGER_INT][0].\
+			Manager.LookUpByLvmId(dbus.String(lvm_id))
 
 	def test_lookup_by_lvm_id(self):
 		# For the moment lets just lookup what we know about which is PVs
@@ -392,10 +393,8 @@ class TestDbusService(unittest.TestCase):
 	def test_vg_rename(self):
 		vg = self._vg_create().Vg
 
-		mgr = self.objs[MANAGER_INT][0].Manager
-
 		# Do a vg lookup
-		path = mgr.LookUpByLvmId(dbus.String(vg.Name))
+		path = self._lookup(vg.Name)
 
 		vg_name_start = vg.Name
 
@@ -406,7 +405,7 @@ class TestDbusService(unittest.TestCase):
 		for i in range(0, 5):
 			lv_t = self._create_lv(size=mib(4), vg=vg)
 			full_name = "%s/%s" % (vg_name_start, lv_t.LvCommon.Name)
-			lv_path = mgr.LookUpByLvmId(dbus.String(full_name))
+			lv_path = self._lookup(full_name)
 			self.assertTrue(lv_path == lv_t.object_path)
 
 		new_name = 'renamed_' + vg.Name
@@ -417,7 +416,7 @@ class TestDbusService(unittest.TestCase):
 		self._check_consistency()
 
 		# Do a vg lookup
-		path = mgr.LookUpByLvmId(dbus.String(new_name))
+		path = self._lookup(new_name)
 		self.assertTrue(path != '/', "%s" % (path))
 		self.assertTrue(prev_path == path, "%s != %s" % (prev_path, path))
 
@@ -435,14 +434,12 @@ class TestDbusService(unittest.TestCase):
 				lv_proxy.Vg == vg.object_path, "%s != %s" %
 				(lv_proxy.Vg, vg.object_path))
 			full_name = "%s/%s" % (new_name, lv_proxy.Name)
-			lv_path = mgr.LookUpByLvmId(dbus.String(full_name))
+			lv_path = self._lookup(full_name)
 			self.assertTrue(
 				lv_path == lv_proxy.object_path, "%s != %s" %
 				(lv_path, lv_proxy.object_path))
 
 	def _verify_hidden_lookups(self, lv_common_object, vgname):
-		mgr = self.objs[MANAGER_INT][0].Manager
-
 		hidden_lv_paths = lv_common_object.HiddenLvs
 
 		for h in hidden_lv_paths:
@@ -454,7 +451,7 @@ class TestDbusService(unittest.TestCase):
 
 			full_name = "%s/%s" % (vgname, h_lv.Name)
 			# print("Hidden check %s" % (full_name))
-			lookup_path = mgr.LookUpByLvmId(dbus.String(full_name))
+			lookup_path = self._lookup(full_name)
 			self.assertTrue(lookup_path != '/')
 			self.assertTrue(lookup_path == h_lv.object_path)
 
@@ -462,7 +459,7 @@ class TestDbusService(unittest.TestCase):
 			full_name = "%s/%s" % (vgname, h_lv.Name[1:-1])
 			# print("Hidden check %s" % (full_name))
 
-			lookup_path = mgr.LookUpByLvmId(dbus.String(full_name))
+			lookup_path = self._lookup(full_name)
 			self.assertTrue(lookup_path != '/')
 			self.assertTrue(lookup_path == h_lv.object_path)
 
@@ -490,7 +487,7 @@ class TestDbusService(unittest.TestCase):
 
 			full_name = "%s/%s" % (vg_name_start, lv_name)
 
-			lookup_lv_path = mgr.LookUpByLvmId(dbus.String(full_name))
+			lookup_lv_path = self._lookup(full_name)
 			self.assertTrue(
 				thin_lv_path == lookup_lv_path,
 				"%s != %s" % (thin_lv_path, lookup_lv_path))
@@ -518,7 +515,7 @@ class TestDbusService(unittest.TestCase):
 				(lv_proxy.Vg, vg.object_path))
 			full_name = "%s/%s" % (new_name, lv_proxy.Name)
 			# print('Full Name %s' % (full_name))
-			lv_path = mgr.LookUpByLvmId(dbus.String(full_name))
+			lv_path = self._lookup(full_name)
 			self.assertTrue(
 				lv_path == lv_proxy.object_path, "%s != %s" %
 				(lv_path, lv_proxy.object_path))
@@ -643,7 +640,7 @@ class TestDbusService(unittest.TestCase):
 		# Rename a regular LV
 		lv = self._create_lv()
 
-		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(lv.LvCommon.Name)
+		path = self._lookup(lv.LvCommon.Name)
 		prev_path = path
 
 		new_name = 'renamed_' + lv.LvCommon.Name
@@ -651,8 +648,7 @@ class TestDbusService(unittest.TestCase):
 		self.handle_return(lv.Lv.Rename(dbus.String(new_name),
 										dbus.Int32(g_tmo), EOD))
 
-		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(
-			dbus.String(new_name))
+		path = self._lookup(new_name)
 
 		self._check_consistency()
 		self.assertTrue(prev_path == path, "%s != %s" % (prev_path, path))


