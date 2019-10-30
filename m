From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:20 -0400
Subject: master - lvmdbustest.py: Add func. _pv_scan
Message-ID: <201910301544.x9UFiKxQ016720@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c5f4f2efb64944ea8a1eae0eee46069d8328324f
Commit:        c5f4f2efb64944ea8a1eae0eee46069d8328324f
Parent:        69d48479759693b8118e2a32b53cab8a9758e21f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 16:11:18 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Add func. _pv_scan

---
 test/dbus/lvmdbustest.py |   77 +++++++++++----------------------------------
 1 files changed, 19 insertions(+), 58 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 497a605..92e4331 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1314,75 +1314,36 @@ class TestDbusService(unittest.TestCase):
 		context = pyudev.Context()
 		return context.list_devices(subsystem='block', MAJOR='8')
 
-	def test_pv_scan(self):
-		devices = TestDbusService._get_devices()
-
+	def _pv_scan(self, activate, cache, device_paths, major_minors):
 		mgr = self._manager().Manager
+		return self.handle_return(
+			mgr.PvScan(
+				dbus.Boolean(activate),
+				dbus.Boolean(cache),
+				dbus.Array(device_paths, 's'),
+				dbus.Array(major_minors, '(ii)'),
+				dbus.Int32(g_tmo),
+				EOD))
 
-		self.assertEqual(
-			self.handle_return(
-				mgr.PvScan(
-					dbus.Boolean(False),
-					dbus.Boolean(True),
-					dbus.Array([], 's'),
-					dbus.Array([], '(ii)'),
-					dbus.Int32(g_tmo),
-					EOD)), '/')
+	def test_pv_scan(self):
+		devices = TestDbusService._get_devices()
 
+		self.assertEqual(self._pv_scan(False, True, [], []), '/')
 		self._check_consistency()
-		self.assertEqual(
-			self.handle_return(
-				mgr.PvScan(
-					dbus.Boolean(False),
-					dbus.Boolean(False),
-					dbus.Array([], 's'),
-					dbus.Array([], '(ii)'),
-					dbus.Int32(g_tmo),
-					EOD)), '/')
-
+		self.assertEqual(self._pv_scan(False, False, [], []), '/')
 		self._check_consistency()
 
-		block_path = []
-		for d in devices:
-			block_path.append(d.properties['DEVNAME'])
-
-		self.assertEqual(
-			self.handle_return(
-				mgr.PvScan(
-					dbus.Boolean(False),
-					dbus.Boolean(True),
-					dbus.Array(block_path, 's'),
-					dbus.Array([], '(ii)'),
-					dbus.Int32(g_tmo),
-					EOD)), '/')
-
+		block_path = [d.properties['DEVNAME'] for d in devices]
+		self.assertEqual(self._pv_scan(False, True, block_path, []), '/')
 		self._check_consistency()
 
-		mm = []
-		for d in devices:
-			mm.append((int(d.properties['MAJOR']), int(d.properties['MINOR'])))
-
-		self.assertEqual(
-			self.handle_return(
-				mgr.PvScan(
-					dbus.Boolean(False),
-					dbus.Boolean(True),
-					dbus.Array(block_path, 's'),
-					dbus.Array(mm, '(ii)'),
-					dbus.Int32(g_tmo),
-					EOD)), '/')
+		mm = [(int(d.properties['MAJOR']), int(d.properties['MINOR']))
+				for d in devices]
 
+		self.assertEqual(self._pv_scan(False, True, block_path, mm), '/')
 		self._check_consistency()
 
-		self.assertEqual(
-			self.handle_return(
-				mgr.PvScan(
-					dbus.Boolean(False),
-					dbus.Boolean(True),
-					dbus.Array([], 's'),
-					dbus.Array(mm, '(ii)'),
-					dbus.Int32(g_tmo),
-					EOD)), '/')
+		self.assertEqual(self._pv_scan(False, True, [], mm), '/')
 		self._check_consistency()
 
 	@staticmethod


