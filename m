From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 20 Dec 2018 11:28:27 -0500
Subject: master - tests/dbus: Re-enable nesting and pvcreate via symlink
Message-ID: <201812201628.wBKGSROK009378@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7034fa4200d63207daa45290150159dd02cf01f
Commit:        a7034fa4200d63207daa45290150159dd02cf01f
Parent:        5bdcafff47ee6a2e57e0c57d18cbc36cf1a2973e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Dec 18 12:43:57 2018 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Dec 20 10:27:30 2018 -0600

tests/dbus: Re-enable nesting and pvcreate via symlink

If we are running the test where the device is /dev/* we will will
run the unit tests 'test_nesting' and 'test_pv_symlinks'.  Otherwise
we will skip them.
---
 test/dbus/lvmdbustest.py |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index d633aa3..9bc1683 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1873,14 +1873,13 @@ class TestDbusService(unittest.TestCase):
 		# when run from lvm2 testsuite. See dbustest.sh.
 		pv_object_path = self.objs[PV_INT][0].object_path
 
-		if not pv_object_path.startswith("/dev"):
-			std_err_print('Skipping test not running in /dev')
-			return
+		if not self.objs[PV_INT][0].Pv.Name.startswith("/dev"):
+			raise unittest.SkipTest('test not running in /dev')
 
 		for i in range(0, 5):
 			pv_object_path = self._create_nested(pv_object_path)
 
-	def DISABLED_test_pv_symlinks(self):
+	def test_pv_symlinks(self):
 		# Lets take one of our test PVs, pvremove it, find a symlink to it
 		# and re-create using the symlink to ensure we return an object
 		# path to it.  Additionally, we will take the symlink and do a lookup
@@ -1891,6 +1890,9 @@ class TestDbusService(unittest.TestCase):
 		pv = self.objs[PV_INT][0]
 		pv_device_path = pv.Pv.Name
 
+		if not pv_device_path.startswith("/dev"):
+			raise unittest.SkipTest('test not running in /dev')
+
 		self._pv_remove(pv)
 
 		# Make sure we no longer find the pv


