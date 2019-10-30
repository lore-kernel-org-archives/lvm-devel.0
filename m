From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:49 -0400
Subject: master - lvmdbustest.py: Add nested helper function major_minor
Message-ID: <201910301544.x9UFinfi016819@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c786636afba068fc0f560b6dd1dd9dd532c35135
Commit:        c786636afba068fc0f560b6dd1dd9dd532c35135
Parent:        e1d3a6c552e8d23837c17934a83c3925cd40252d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 9 11:48:00 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Add nested helper function major_minor

---
 test/dbus/lvmdbustest.py |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index a9d7fac..0b7140a 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1316,6 +1316,10 @@ class TestDbusService(unittest.TestCase):
 				EOD))
 
 	def test_pv_scan(self):
+
+		def major_minor(d):
+			return (int(d.properties['MAJOR']), int(d.properties['MINOR']))
+
 		devices = TestDbusService._get_devices()
 
 		self.assertEqual(self._pv_scan(False, True, [], []), '/')
@@ -1327,8 +1331,7 @@ class TestDbusService(unittest.TestCase):
 		self.assertEqual(self._pv_scan(False, True, block_path, []), '/')
 		self._check_consistency()
 
-		mm = [(int(d.properties['MAJOR']), int(d.properties['MINOR']))
-				for d in devices]
+		mm = [major_minor(d) for d in devices]
 
 		self.assertEqual(self._pv_scan(False, True, block_path, mm), '/')
 		self._check_consistency()


