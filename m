From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 May 2018 10:28:12 -0400
Subject: master - python: use // for integer division
Message-ID: <201805181428.w4IESCZn012400@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2574c2f3a4a35b7ea3f51dc776cc64ebbe88ba8
Commit:        b2574c2f3a4a35b7ea3f51dc776cc64ebbe88ba8
Parent:        3bbdde808a9dcb55a9ffd092e931dff80814daa7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 18 16:23:10 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 18 16:25:44 2018 +0200

python: use // for integer division

---
 daemons/lvmdbusd/lv.py         |    2 +-
 test/api/python_lvm_unit.py.in |   10 +++++-----
 test/dbus/lvmdbustest.py       |    8 ++++----
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index d73d3d2..ba9499f 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -497,7 +497,7 @@ class Lv(LvCommon):
 		# it is a thin lv
 		if not dbo.IsThinVolume:
 			if optional_size == 0:
-				space = dbo.SizeBytes / 80
+				space = dbo.SizeBytes // 80
 				remainder = space % 512
 				optional_size = space + 512 - remainder
 
diff --git a/test/api/python_lvm_unit.py.in b/test/api/python_lvm_unit.py.in
index 2f9cbb5..78ced7e 100755
--- a/test/api/python_lvm_unit.py.in
+++ b/test/api/python_lvm_unit.py.in
@@ -112,7 +112,7 @@ class TestLvm(unittest.TestCase):
 		for d in device_list:
 			vg.extend(d)
 
-		vg.createLvLinear(name, vg.getSize() / 2)
+		vg.createLvLinear(name, vg.getSize() // 2)
 		vg.close()
 		vg = None
 
@@ -124,14 +124,14 @@ class TestLvm(unittest.TestCase):
 			vg.extend(d)
 
 		vg.createLvThinpool(
-			pool_name, vg.getSize() / 2, 0, 0, lvm.THIN_DISCARDS_PASSDOWN, 1)
+			pool_name, vg.getSize() // 2, 0, 0, lvm.THIN_DISCARDS_PASSDOWN, 1)
 		return vg
 
 	@staticmethod
 	def _create_thin_lv(pv_devices, name):
 		thin_pool_name = 'thin_vg_pool_' + rs(4)
 		vg = TestLvm._create_thin_pool(pv_devices, thin_pool_name)
-		vg.createLvThin(thin_pool_name, name, vg.getSize() / 8)
+		vg.createLvThin(thin_pool_name, name, vg.getSize() // 8)
 		vg.close()
 		vg = None
 
@@ -231,7 +231,7 @@ class TestLvm(unittest.TestCase):
 			curr_size = pv.getSize()
 			dev_size = pv.getDevSize()
 			self.assertTrue(curr_size == dev_size)
-			pv.resize(curr_size / 2)
+			pv.resize(curr_size // 2)
 		with AllowedPVS() as pvs:
 			pv = pvs[0]
 			resized_size = pv.getSize()
@@ -718,7 +718,7 @@ class TestLvm(unittest.TestCase):
 	def test_percent_to_float(self):
 		self.assertEqual(lvm.percentToFloat(0), 0.0)
 		self.assertEqual(lvm.percentToFloat(1000000), 1.0)
-		self.assertEqual(lvm.percentToFloat(1000000 / 2), 0.5)
+		self.assertEqual(lvm.percentToFloat(1000000 // 2), 0.5)
 
 	def test_scan(self):
 		self.assertEqual(lvm.scan(), None)
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index bab9986..5f34847 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1027,7 +1027,7 @@ class TestDbusService(unittest.TestCase):
 			vg.Move(
 				dbus.ObjectPath(location),
 				dbus.Struct((0, 0), signature='tt'),
-				dbus.Array([(dst, pv.PeCount / 2, 0), ], '(ott)'),
+				dbus.Array([(dst, pv.PeCount // 2, 0), ], '(ott)'),
 				dbus.Int32(g_tmo),
 				EOD))
 		self.assertEqual(job, '/')
@@ -1320,7 +1320,7 @@ class TestDbusService(unittest.TestCase):
 
 			original_size = pv.SizeBytes
 
-			new_size = original_size / 2
+			new_size = original_size // 2
 
 			self.handle_return(
 				pv.ReSize(
@@ -1454,7 +1454,7 @@ class TestDbusService(unittest.TestCase):
 
 	@staticmethod
 	def _write_some_data(device_path, size):
-		blocks = int(size / 512)
+		blocks = int(size // 512)
 		block = bytearray(512)
 		for i in range(0, 512):
 			block[i] = i % 255
@@ -1481,7 +1481,7 @@ class TestDbusService(unittest.TestCase):
 							interfaces=(LV_COMMON_INT, LV_INT, SNAPSHOT_INT, ))
 
 		# Write some data to snapshot so merge takes some time
-		TestDbusService._write_some_data(ss.LvCommon.Path, ss_size / 2)
+		TestDbusService._write_some_data(ss.LvCommon.Path, ss_size // 2)
 
 		job_path = self.handle_return(
 			ss.Snapshot.Merge(


