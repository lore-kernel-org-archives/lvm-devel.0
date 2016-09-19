From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 19 Sep 2016 20:38:23 +0000 (UTC)
Subject: master - lvmdbustest.py: Make methods static
Message-ID: <20160919203823.20AA460D98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65f59184c833584e96dd61030db495d33a3e7a4c
Commit:        65f59184c833584e96dd61030db495d33a3e7a4c
Parent:        ac2fc7a366d0e1e5b23115b34b7773eaf7334076
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Sep 16 14:01:18 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Sep 19 15:31:04 2016 -0500

lvmdbustest.py: Make methods static

Changed methods to be static that should be.
---
 test/dbus/lvmdbustest.py |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 6943da5..c6fa4d6 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -141,7 +141,8 @@ class TestDbusService(unittest.TestCase):
 		vg.Remove(-1, {})
 		self.assertEqual(self._refresh(), 0)
 
-	def _pv_remove(self, pv):
+	@staticmethod
+	def _pv_remove(pv):
 		rc = pv.Pv.Remove(-1, {})
 		return rc
 
@@ -149,7 +150,7 @@ class TestDbusService(unittest.TestCase):
 		target = self.objs[PV_INT][0]
 
 		# Remove the PV
-		rc = self._pv_remove(target)
+		rc = TestDbusService._pv_remove(target)
 		self.assertTrue(rc == '/')
 		self.assertEqual(self._refresh(), 0)
 
@@ -926,12 +927,13 @@ class TestDbusService(unittest.TestCase):
 
 		self.assertEqual(self._refresh(), 0)
 
-	def _get_devices(self):
+	@staticmethod
+	def _get_devices():
 		context = pyudev.Context()
 		return context.list_devices(subsystem='block', MAJOR='8')
 
 	def test_pv_scan(self):
-		devices = self._get_devices()
+		devices = TestDbusService._get_devices()
 
 		mgr = self._manager().Manager
 
@@ -1068,7 +1070,8 @@ class TestDbusService(unittest.TestCase):
 		result = vg_proxy.Vg.Change(-1, {'-a': 'n'})
 		self.assertTrue(result == '/')
 
-	def _invalid_vg_lv_name_characters(self):
+	@staticmethod
+	def _invalid_vg_lv_name_characters():
 		bad_vg_lv_set = set(string.printable) - \
 			set(string.ascii_letters + string.digits + '.-_+')
 		return ''.join(bad_vg_lv_set)
@@ -1083,7 +1086,7 @@ class TestDbusService(unittest.TestCase):
 		# VG Name testing...
 		# Go through all bad characters
 		pv_paths = [self.objs[PV_INT][0].object_path]
-		bad_chars = self._invalid_vg_lv_name_characters()
+		bad_chars = TestDbusService._invalid_vg_lv_name_characters()
 		for c in bad_chars:
 			with self.assertRaises(dbus.exceptions.DBusException):
 				mgr.VgCreate("name%s" % (c), pv_paths, -1, {})


