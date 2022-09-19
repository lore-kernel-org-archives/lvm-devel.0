From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:45 +0000 (GMT)
Subject: main - lvmdbustest: Use updated pyudev syntax
Message-ID: <20220919155745.6378B3858D38@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9ffa1ef884f51d08fc6f2b39287a8d566eeed7df
Commit:        9ffa1ef884f51d08fc6f2b39287a8d566eeed7df
Parent:        0887896847807e159a70edc5ac92a4030c13923a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 8 10:02:37 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbustest: Use updated pyudev syntax

Previous syntax has been deprecated.
---
 test/dbus/lvmdbustest.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index e6f6d4891..aadd036b0 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1430,7 +1430,7 @@ class TestDbusService(unittest.TestCase):
 	def test_pv_scan(self):
 
 		def major_minor(d):
-			return (int(d.properties['MAJOR']), int(d.properties['MINOR']))
+			return (int(d.properties.get('MAJOR')), int(d.properties.get('MINOR')))
 
 		devices = TestDbusService._get_devices()
 
@@ -1439,7 +1439,7 @@ class TestDbusService(unittest.TestCase):
 		self.assertEqual(self._pv_scan(False, False, [], []), '/')
 		self._check_consistency()
 
-		block_path = [d.properties['DEVNAME'] for d in devices]
+		block_path = [d.properties.get('DEVNAME') for d in devices]
 		self.assertEqual(self._pv_scan(False, True, block_path, []), '/')
 		self._check_consistency()
 

