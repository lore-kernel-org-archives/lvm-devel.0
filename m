From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:04 -0400
Subject: master - lvmdbustest.py: Add function for lv path check
Message-ID: <201910301544.x9UFi45x016653@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b8d496911765ec07f80eee174623e503506e7401
Commit:        b8d496911765ec07f80eee174623e503506e7401
Parent:        22a22a735fef7bcd0f1acc80e99f500925e3572c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 15:19:51 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Add function for lv path check

---
 test/dbus/lvmdbustest.py |   55 +++++++++++++++++++--------------------------
 1 files changed, 23 insertions(+), 32 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 0384d5e..1ab4ce6 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -489,6 +489,26 @@ class TestDbusService(unittest.TestCase):
 			self.assertTrue(path == '/')
 			self._check_consistency()
 
+	def _verify_lv_paths(self, vg, new_name):
+		"""
+		# Go through each LV and make sure it has the correct path back to the
+		# VG
+		:return:
+		"""
+		lv_paths = vg.Lvs
+
+		for l in lv_paths:
+			lv_proxy = ClientProxy(self.bus, l,
+								   interfaces=(LV_COMMON_INT,)).LvCommon
+			self.assertTrue(
+				lv_proxy.Vg == vg.object_path, "%s != %s" %
+				(lv_proxy.Vg, vg.object_path))
+			full_name = "%s/%s" % (new_name, lv_proxy.Name)
+			lv_path = self._lookup(full_name)
+			self.assertTrue(
+				lv_path == lv_proxy.object_path, "%s != %s" %
+				(lv_path, lv_proxy.object_path))
+
 	# noinspection PyUnresolvedReferences
 	def test_vg_rename(self):
 		vg = self._vg_create().Vg
@@ -524,20 +544,8 @@ class TestDbusService(unittest.TestCase):
 		# VG
 		vg.update()
 
-		lv_paths = vg.Lvs
-		self.assertTrue(len(lv_paths) == 5)
-
-		for l in lv_paths:
-			lv_proxy = ClientProxy(self.bus, l,
-									interfaces=(LV_COMMON_INT,)).LvCommon
-			self.assertTrue(
-				lv_proxy.Vg == vg.object_path, "%s != %s" %
-				(lv_proxy.Vg, vg.object_path))
-			full_name = "%s/%s" % (new_name, lv_proxy.Name)
-			lv_path = self._lookup(full_name)
-			self.assertTrue(
-				lv_path == lv_proxy.object_path, "%s != %s" %
-				(lv_path, lv_proxy.object_path))
+		self.assertTrue(len(vg.Lvs) == 5)
+		self._verify_lv_paths(vg, new_name)
 
 	def _verify_hidden_lookups(self, lv_common_object, vgname):
 		hidden_lv_paths = lv_common_object.HiddenLvs
@@ -602,26 +610,9 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(path == '/')
 		self._check_consistency()
 
-		# Go through each LV and make sure it has the correct path back to the
-		# VG
 		vg.update()
 		thin_pool.update()
-
-		lv_paths = vg.Lvs
-
-		for l in lv_paths:
-			lv_proxy = ClientProxy(self.bus, l,
-									interfaces=(LV_COMMON_INT,)).LvCommon
-			self.assertTrue(
-				lv_proxy.Vg == vg.object_path, "%s != %s" %
-				(lv_proxy.Vg, vg.object_path))
-			full_name = "%s/%s" % (new_name, lv_proxy.Name)
-			# print('Full Name %s' % (full_name))
-			lv_path = self._lookup(full_name)
-			self.assertTrue(
-				lv_path == lv_proxy.object_path, "%s != %s" %
-				(lv_path, lv_proxy.object_path))
-
+		self._verify_lv_paths(vg, new_name)
 		# noinspection PyTypeChecker
 		self._verify_hidden_lookups(thin_pool.LvCommon, new_name)
 


