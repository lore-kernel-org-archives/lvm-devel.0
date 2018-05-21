From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 May 2018 06:01:05 -0400
Subject: master - tests: disable symlink test
Message-ID: <201805211001.w4LA15jd002937@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6029d6d8d8198aee17ec8972c333477f2c581bff
Commit:        6029d6d8d8198aee17ec8972c333477f2c581bff
Parent:        25a66737e3c9fee218c84a659d5d9b7a34347e47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 19 12:08:23 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 21 11:59:39 2018 +0200

tests: disable symlink test

It's quite unclear what the test is meant to do - disable it just like
within python test.
---
 test/dbus/lvmdbustest.py |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 5f34847..d633aa3 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1873,10 +1873,14 @@ class TestDbusService(unittest.TestCase):
 		# when run from lvm2 testsuite. See dbustest.sh.
 		pv_object_path = self.objs[PV_INT][0].object_path
 
+		if not pv_object_path.startswith("/dev"):
+			std_err_print('Skipping test not running in /dev')
+			return
+
 		for i in range(0, 5):
 			pv_object_path = self._create_nested(pv_object_path)
 
-	def test_pv_symlinks(self):
+	def DISABLED_test_pv_symlinks(self):
 		# Lets take one of our test PVs, pvremove it, find a symlink to it
 		# and re-create using the symlink to ensure we return an object
 		# path to it.  Additionally, we will take the symlink and do a lookup


