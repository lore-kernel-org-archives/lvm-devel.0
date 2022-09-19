From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:46 +0000 (GMT)
Subject: main - lvmdbustest: Include major number 259
Message-ID: <20220919155746.848843858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b4d431631ec8df90d6d5793fbfc26c6999e154c
Commit:        4b4d431631ec8df90d6d5793fbfc26c6999e154c
Parent:        9ffa1ef884f51d08fc6f2b39287a8d566eeed7df
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 8 10:03:52 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbustest: Include major number 259

When you have > 16 partitions for a block device the major number
changes, include them for testing.
---
 test/dbus/lvmdbustest.py | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index aadd036b0..02d4d35d7 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1414,7 +1414,10 @@ class TestDbusService(unittest.TestCase):
 	@staticmethod
 	def _get_devices():
 		context = pyudev.Context()
-		return context.list_devices(subsystem='block', MAJOR='8')
+		bd = context.list_devices(subsystem='block')
+		# Handle block extended major too (259)
+		return [b for b in bd if b.properties.get('MAJOR') == '8' or
+				b.properties.get('MAJOR') == '259']
 
 	def _pv_scan(self, activate, cache, device_paths, major_minors):
 		mgr = self._manager().Manager

