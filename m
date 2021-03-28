From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 28 Mar 2021 12:23:12 +0000 (GMT)
Subject: main - tests: test_pv_symlinks works only with /dev dir
Message-ID: <20210328122312.49A81385703C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a550fa3e8747fe01517c1c4c1d81e9406d000ea
Commit:        8a550fa3e8747fe01517c1c4c1d81e9406d000ea
Parent:        afbaab20c72515231740a1a6827d0110c6ff59cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 28 00:18:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 28 00:21:38 2021 +0100

tests: test_pv_symlinks works only with /dev dir

Skip test with LVM_TEST_DEVDIR != /dev
---
 test/dbus/lvmdbustest.py | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 03d5ba5aa..6d692223f 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1861,6 +1861,9 @@ class TestDbusService(unittest.TestCase):
 		pv = self.objs[PV_INT][0]
 		pv_device_path = pv.Pv.Name
 
+		if dm_dev_dir != '/dev':
+			raise unittest.SkipTest('test not running in real /dev')
+
 		if not pv_device_path.startswith("/dev"):
 			raise unittest.SkipTest('test not running in /dev')
 


