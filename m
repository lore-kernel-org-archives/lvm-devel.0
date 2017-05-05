From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 5 May 2017 11:31:03 -0400
Subject: master - lvmdbustest.py: Add PV symlink testing
Message-ID: <201705051531.v45FV3s7030012@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fcce7e16601caf3941fd0d090c03c94ac83a329e
Commit:        fcce7e16601caf3941fd0d090c03c94ac83a329e
Parent:        97d5e192fe899d6c4d50377205db7b37c116900b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed May 3 14:07:13 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri May 5 10:30:06 2017 -0500

lvmdbustest.py: Add PV symlink testing

We fixed this issue once before and it's back, add a test to make
sure it never comes back again!

https://bugzilla.redhat.com/show_bug.cgi?id=1318754
https://bugzilla.redhat.com/show_bug.cgi?id=1445654
---
 test/dbus/lvmdbustest.py |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 50f6ad4..e3eeb6e 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -18,6 +18,8 @@ import pyudev
 from testlib import *
 import testlib
 from subprocess import Popen, PIPE
+from glob import glob
+import os
 
 g_tmo = 0
 
@@ -1865,6 +1867,46 @@ class TestDbusService(unittest.TestCase):
 		for i in range(0, 5):
 			pv_object_path = self._create_nested(pv_object_path)
 
+	def test_pv_symlinks(self):
+		# Lets take one of our test PVs, pvremove it, find a symlink to it
+		# and re-create using the symlink to ensure we return an object
+		# path to it.  Additionally, we will take the symlink and do a lookup
+		# (Manager.LookUpByLvmId) using it and the original device path to
+		# ensure that we can find the PV.
+		symlink = None
+
+		pv = self.objs[PV_INT][0]
+		pv_device_path = pv.Pv.Name
+
+		self._pv_remove(pv)
+
+		# Make sure we no longer find the pv
+		rc = self._lookup(pv_device_path)
+		self.assertEqual(rc, '/')
+
+		# Lets locate a symlink for it
+		devices = glob('/dev/disk/*/*')
+		for d in devices:
+			if pv_device_path == os.path.realpath(d):
+				symlink = d
+				break
+
+		self.assertIsNotNone(symlink, "We expected to find at least 1 symlink!")
+
+		# Make sure symlink look up fails too
+		rc = self._lookup(symlink)
+		self.assertEqual(rc, '/')
+
+		pv_object_path = self._pv_create(symlink)
+		self.assertNotEqual(pv_object_path, '/')
+
+		pv_proxy = ClientProxy(self.bus, pv_object_path, interfaces=(PV_INT, ))
+		self.assertEqual(pv_proxy.Pv.Name, pv_device_path)
+
+		# Lets check symlink lookup
+		self.assertEqual(pv_object_path, self._lookup(symlink))
+		self.assertEqual(pv_object_path, self._lookup(pv_device_path))
+
 
 class AggregateResults(object):
 


