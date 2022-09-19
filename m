From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:56 +0000 (GMT)
Subject: main - lvmdbustest: nesting improvements
Message-ID: <20220919155756.B9CBB3858C2C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cef3c75dd496961cf7f2d2509fd694b9edf28421
Commit:        cef3c75dd496961cf7f2d2509fd694b9edf28421
Parent:        6b9cc7432ec70461217c081b5d38065236aec887
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 10 13:59:11 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbustest: nesting improvements

---
 test/dbus/lvmdbustest.py | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index e7df238ce..4977021b1 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1827,8 +1827,8 @@ class TestDbusService(unittest.TestCase):
 		cmd = ['pvcreate', target.Pv.Name]
 		self._verify_existence(cmd, cmd[0], target.Pv.Name)
 
-	def _create_nested(self, pv_object_path):
-		vg = self._vg_create([pv_object_path])
+	def _create_nested(self, pv_object_path, vg_suffix):
+		vg = self._vg_create([pv_object_path], vg_suffix)
 		pv = ClientProxy(self.bus, pv_object_path, interfaces=(PV_INT,))
 
 		self.assertEqual(pv.Pv.Vg, vg.object_path)
@@ -1838,8 +1838,12 @@ class TestDbusService(unittest.TestCase):
 		lv = self._create_lv(
 			vg=vg.Vg, size=vg.Vg.FreeBytes, suffix="_pv0")
 		device_path = '/dev/%s/%s' % (vg.Vg.Name, lv.LvCommon.Name)
+		dev_info = os.stat(device_path)
+		major = os.major(dev_info.st_rdev)
+		minor = os.minor(dev_info.st_rdev)
+		sysfs = "/sys/dev/block/%d:%d" % (major, minor)
+		self.assertTrue(os.path.exists(sysfs))
 		new_pv_object_path = self._pv_create(device_path)
-
 		vg.update()
 
 		self.assertEqual(lv.LvCommon.Vg, vg.object_path)
@@ -1870,7 +1874,7 @@ class TestDbusService(unittest.TestCase):
 			raise unittest.SkipTest('test not running in /dev')
 
 		for i in range(0, 5):
-			pv_object_path = self._create_nested(pv_object_path)
+			pv_object_path = self._create_nested(pv_object_path, "nest_%d_" % i)
 
 	def test_pv_symlinks(self):
 		# Let's take one of our test PVs, pvremove it, find a symlink to it

