From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:31 +0000 (GMT)
Subject: dev-next - tests: update dbus test_nesting
Message-ID: <20210331214931.91E513858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93336685f6cf8a178cb83aa1ee113a2a33ca7f5c
Commit:        93336685f6cf8a178cb83aa1ee113a2a33ca7f5c
Parent:        1d6e1d08a887d602234485f0214edc3552e843e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 20:21:57 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 20:39:41 2021 +0100

tests: update dbus test_nesting

Test has to use PV with suffix  pv[0..9]  otherwise
it's ignored by test suite filter.

Better fix for VG names to use prefix LVMTEST.

Skip the test for runs without LVM_TEST_DEVDIR != /dev
---
 test/dbus/lvmdbustest.py | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 6dab312c0..746025903 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -26,6 +26,9 @@ g_tmo = 0
 # Prefix on created objects to enable easier clean-up
 g_prefix = os.getenv('PREFIX', '')
 
+# Check dev dir prefix for test suite  (LVM_TEST_DEVDIR
+dm_dev_dir = os.getenv('DM_DEV_DIR', '/dev')
+
 # Use the session bus instead of the system bus
 use_session = os.getenv('LVM_DBUSD_USE_SESSION', False)
 
@@ -59,10 +62,10 @@ if pv_device_list:
 
 
 def vg_n(prefix=None):
-	name = g_prefix + '_vg'
+	name = rs(8, '_vg')
 	if prefix:
 		name = prefix + name
-	return name
+	return g_prefix + name
 
 
 def lv_n(suffix=None):
@@ -70,7 +73,7 @@ def lv_n(suffix=None):
 		s = '_lv'
 	else:
 		s = suffix
-	return g_prefix + rs(8, s)
+	return rs(8, s)
 
 
 def _is_testsuite_pv(pv_name):
@@ -338,7 +341,7 @@ class TestDbusService(unittest.TestCase):
 		if not pv_paths:
 			pv_paths = self._all_pv_object_paths()
 
-		vg_name = vg_n(prefix=vg_prefix)
+		vg_name = vg_n()
 
 		vg_path = self.handle_return(
 			self.objs[MANAGER_INT][0].Manager.VgCreate(
@@ -1811,7 +1814,7 @@ class TestDbusService(unittest.TestCase):
 			pv_object_path, vg.Vg.Pvs, "Expecting PV object path in Vg.Pvs")
 
 		lv = self._create_lv(
-			vg=vg.Vg, size=vg.Vg.FreeBytes, suffix="_pv")
+			vg=vg.Vg, size=vg.Vg.FreeBytes, suffix="_pv0")
 		device_path = '/dev/%s/%s' % (vg.Vg.Name, lv.LvCommon.Name)
 		new_pv_object_path = self._pv_create(device_path)
 
@@ -1837,6 +1840,9 @@ class TestDbusService(unittest.TestCase):
 		# by editing lvm.conf with "devices/scan_lvs = 1"  As testing
 		# typically utilizes loopback, this test is skipped in
 		# those environments.
+
+		if dm_dev_dir != '/dev':
+			raise unittest.SkipTest('test not running in real /dev')
 		pv_object_path = self.objs[PV_INT][0].object_path
 		if not self.objs[PV_INT][0].Pv.Name.startswith("/dev"):
 			raise unittest.SkipTest('test not running in /dev')


