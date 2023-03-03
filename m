From: Tony Asleson <tasleson@sourceware.org>
Date: Fri,  3 Mar 2023 18:03:29 +0000 (GMT)
Subject: main - lvmdbustest: Add more info on asserts
Message-ID: <20230303180329.B592D3858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e616230f2627d31599d1f4a2c7ff29b5ba86703
Commit:        3e616230f2627d31599d1f4a2c7ff29b5ba86703
Parent:        95afd315b163143296a1a42d2cad2b1cd762725d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 2 11:44:16 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 2 11:44:16 2023 -0600

lvmdbustest: Add more info on asserts

---
 test/dbus/lvmdbustest.py | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 9a3cb175a..ab68e7e5c 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -446,7 +446,7 @@ class TestDbusService(unittest.TestCase):
 		self.handle_return(vg_proxy.Vg.Remove(dbus.Int32(g_tmo), EOD))
 		if is_nested_pv(pv_proxy.Pv.Name):
 			rc = self._pv_remove(pv_proxy)
-			self.assertTrue(rc == '/')
+			self.assertTrue(rc == '/', "We expected a '/', but got %s when removing a PV" % str(rc))
 
 	def clean_up(self):
 		self.objs, self.bus = get_objects()
@@ -522,7 +522,8 @@ class TestDbusService(unittest.TestCase):
 
 		self._validate_lookup(device, pv_path)
 
-		self.assertTrue(pv_path is not None and len(pv_path) > 0)
+		self.assertTrue(pv_path is not None and len(pv_path) > 0,
+						"When creating a PV we expected the returned path to be valid")
 		return pv_path
 
 	def _manager(self):
@@ -536,7 +537,7 @@ class TestDbusService(unittest.TestCase):
 
 	def test_version(self):
 		rc = self.objs[MANAGER_INT][0].Manager.Version
-		self.assertTrue(rc is not None and len(rc) > 0)
+		self.assertTrue(rc is not None and len(rc) > 0, "Manager.Version is invalid")
 		self._check_consistency()
 
 	def _vg_create(self, pv_paths=None, vg_prefix=None, options=None):
@@ -557,7 +558,7 @@ class TestDbusService(unittest.TestCase):
 				options))
 
 		self._validate_lookup(vg_name, vg_path)
-		self.assertTrue(vg_path is not None and len(vg_path) > 0)
+		self.assertTrue(vg_path is not None and len(vg_path) > 0, "During VG creation, returned path is empty")
 
 		intf = [VG_INT, ]
 		if self.vdo:
@@ -2427,11 +2428,11 @@ class TestDbusService(unittest.TestCase):
 			print("Note: Time for udev update = %f" % (time.time() - start))
 		if present:
 			rc = self._lookup(block_device)
-			self.assertNotEqual(rc, '/')
+			self.assertNotEqual(rc, '/', "Daemon failed to update, missing udev change event?")
 			return True
 		else:
 			rc = self._lookup(block_device)
-			self.assertEqual(rc, '/')
+			self.assertEqual(rc, '/', "Daemon failed to update, missing udev change event?")
 			return True
 
 	def test_wipefs(self):
@@ -2500,7 +2501,8 @@ class TestDbusService(unittest.TestCase):
 			j.update()
 			if j.Complete:
 				(ec, error_msg) = j.GetError
-				self.assertTrue("insufficient free space" in error_msg, error_msg)
+				self.assertTrue("insufficient free space" in error_msg,
+								"We're expecting 'insufficient free space' in \n\"%s\"\n, stderr missing?" % error_msg)
 				break
 			else:
 				time.sleep(0.1)

