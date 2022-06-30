From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:41 +0000 (GMT)
Subject: main - lvmdbusd: Change unit test vdo minimum size
Message-ID: <20220630160041.79E4D386F0CB@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=47c61907b4adbdead50f5bb5ac95c0f5d0fe263e
Commit:        47c61907b4adbdead50f5bb5ac95c0f5d0fe263e
Parent:        51d9b686c08d963c61898d407d15abf39f129d72
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed May 25 16:03:27 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Change unit test vdo minimum size

---
 test/dbus/lvmdbustest.py | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 6d692223f..3eef77fd7 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -23,6 +23,9 @@ import os
 
 g_tmo = 0
 
+# Approx. min size
+VDO_MIN_SIZE = mib(8192)
+
 # Prefix on created objects to enable easier clean-up
 g_prefix = os.getenv('PREFIX', '')
 
@@ -1155,7 +1158,7 @@ class TestDbusService(unittest.TestCase):
 				return
 
 		# This may not pass
-		for i in [48, 64, 128]:
+		for i in [64, 128]:
 			yes = self._test_expired_timer(i)
 			if yes:
 				break
@@ -1907,8 +1910,8 @@ class TestDbusService(unittest.TestCase):
 		vdo_pool_object_path = self.handle_return(
 			vg_proxy.VgVdo.CreateVdoPoolandLv(
 				pool_name, lv_name,
-				dbus.UInt64(mib(4096)),		# Appears to be minimum size
-				dbus.UInt64(mib(8192)),
+				dbus.UInt64(VDO_MIN_SIZE),
+				dbus.UInt64(VDO_MIN_SIZE * 2),
 				dbus.Int32(g_tmo),
 				EOD))
 
@@ -1950,7 +1953,7 @@ class TestDbusService(unittest.TestCase):
 		vg_proxy = self._vg_create(vg_prefix="vdo_conv_")
 		lv = self._test_lv_create(
 			vg_proxy.Vg.LvCreate,
-			(dbus.String(pool_name), dbus.UInt64(mib(4096)),
+			(dbus.String(pool_name), dbus.UInt64(VDO_MIN_SIZE),
 				dbus.Array([], signature='(ott)'), dbus.Int32(g_tmo),
 				EOD), vg_proxy.Vg, LV_BASE_INT)
 		lv_obj_path = self._lookup("%s/%s" % (vg_proxy.Vg.Name, pool_name))
@@ -1959,7 +1962,7 @@ class TestDbusService(unittest.TestCase):
 		vdo_pool_path = self.handle_return(
 			vg_proxy.VgVdo.CreateVdoPool(
 				dbus.ObjectPath(lv.object_path), lv_name,
-				dbus.UInt64(mib(8192)),
+				dbus.UInt64(VDO_MIN_SIZE),
 				dbus.Int32(g_tmo),
 				EOD))
 
@@ -2083,6 +2086,7 @@ if __name__ == '__main__':
 		std_err_print('\n*** Testing only lvm shell mode ***\n')
 
 	for g_tmo in [0, 15]:
+		std_err_print('Testing TMO=%d\n' % g_tmo)
 		if mode == 0:
 			if set_execution(False, r):
 				r.register_result(unittest.main(exit=False))

