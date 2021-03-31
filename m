From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:22 +0000 (GMT)
Subject: dev-next - tests: dbus update
Message-ID: <20210331214922.6E36D3857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25c665d5559e77c1eb0f67527fa95419a84b7553
Commit:        25c665d5559e77c1eb0f67527fa95419a84b7553
Parent:        6db533c4393e1e8ca02e957c529afaf67fa7e20b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 13:13:26 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 13:13:26 2021 +0100

tests: dbus update

Always use  PREFIX for vg header - all tests must use this prefix,
VGs without are not allowed.

Modify pv_symlink test - as the test was checking unsupportable
combination - since lvm2 commands withing testsuite are only
allowed to manipulate with /dev/mapper/LVMTESTXXXX path -
nothing else allowed and fails on being filtered.
---
 test/dbus/lvmdbustest.py | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index efa1afb26..6dab312c0 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -59,7 +59,7 @@ if pv_device_list:
 
 
 def vg_n(prefix=None):
-	name = rs(8, '_vg')
+	name = g_prefix + '_vg'
 	if prefix:
 		name = prefix + name
 	return name
@@ -1838,7 +1838,6 @@ class TestDbusService(unittest.TestCase):
 		# typically utilizes loopback, this test is skipped in
 		# those environments.
 		pv_object_path = self.objs[PV_INT][0].object_path
-
 		if not self.objs[PV_INT][0].Pv.Name.startswith("/dev"):
 			raise unittest.SkipTest('test not running in /dev')
 
@@ -1867,8 +1866,9 @@ class TestDbusService(unittest.TestCase):
 
 		# Lets locate a symlink for it
 		devices = glob('/dev/disk/*/*')
+		rp_pv_device_path = os.path.realpath(pv_device_path)
 		for d in devices:
-			if pv_device_path == os.path.realpath(d):
+			if rp_pv_device_path == os.path.realpath(d):
 				symlink = d
 				break
 
@@ -1878,14 +1878,16 @@ class TestDbusService(unittest.TestCase):
 		rc = self._lookup(symlink)
 		self.assertEqual(rc, '/')
 
-		pv_object_path = self._pv_create(symlink)
+		### pv_object_path = self._pv_create(symlink)
+		### Test is limited by filter rules and must use  /dev/mapper/LVMTEST path
+		pv_object_path = self._pv_create(pv_device_path)
+
 		self.assertNotEqual(pv_object_path, '/')
 
 		pv_proxy = ClientProxy(self.bus, pv_object_path, interfaces=(PV_INT, ))
 		self.assertEqual(pv_proxy.Pv.Name, pv_device_path)
 
 		# Lets check symlink lookup
-		self.assertEqual(pv_object_path, self._lookup(symlink))
 		self.assertEqual(pv_object_path, self._lookup(pv_device_path))
 
 	def _create_vdo_pool_and_lv(self, vg_prefix="vdo_"):


