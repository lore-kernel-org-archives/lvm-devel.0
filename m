From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 26 May 2017 03:14:28 -0400
Subject: master - test: Use _pv suffix for nested devices
Message-ID: <201705260714.v4Q7ESf4004087@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7687ab82c8d71e5d11c915a4dd390249b8124b9a
Commit:        7687ab82c8d71e5d11c915a4dd390249b8124b9a
Parent:        3745b52ed4ff28e553e1372e425491d11cc78031
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri May 26 08:33:39 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri May 26 08:33:39 2017 +0200

test: Use _pv suffix for nested devices

Testsuite uses global_filter to accept only test devices with
suffix matching /_pv[0-9_]*$/ set by generate_config in aux.sh.
---
 test/dbus/lvmdbustest.py |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index e3eeb6e..d9f0f8c 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -716,9 +716,9 @@ class TestDbusService(unittest.TestCase):
 			LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
-	def _create_lv(self, thinpool=False, size=None, vg=None):
+	def _create_lv(self, thinpool=False, size=None, vg=None, suffix=None):
 
-		lv_name = lv_n()
+		lv_name = lv_n(suffix=suffix)
 		interfaces = list(LV_BASE_INT)
 
 		if thinpool:
@@ -1842,7 +1842,8 @@ class TestDbusService(unittest.TestCase):
 		self.assertIn(pv_object_path, vg.Vg.Pvs,
 						"Expecting PV object path in Vg.Pvs")
 
-		lv = self._create_lv(vg=vg.Vg, size=vg.Vg.FreeBytes)
+		lv = self._create_lv(vg=vg.Vg, size=vg.Vg.FreeBytes,
+								suffix="_pv")
 		device_path = '/dev/%s/%s' % (vg.Vg.Name, lv.LvCommon.Name)
 		new_pv_object_path = self._pv_create(device_path)
 


