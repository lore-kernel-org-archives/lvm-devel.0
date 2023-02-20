From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 20 Feb 2023 18:22:17 +0000 (GMT)
Subject: main - lvmdbustest: Check and remove lvm debug collection files
Message-ID: <20230220182217.855093858289@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=993bd2ffc88003aa3392ddbe3364fd887b65b589
Commit:        993bd2ffc88003aa3392ddbe3364fd887b65b589
Parent:        e18d60b336ac881599c1c68d9d3fff1ac8b6515d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Feb 20 11:10:24 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 20 12:01:53 2023 -0600

lvmdbustest: Check and remove lvm debug collection files

In setup/teardown ensure we check for and remove any lvm debug
collection, to prevent FS from filling up.
---
 test/dbus/lvmdbustest.py | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index c07963525..685acd563 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -13,6 +13,7 @@ import signal
 # noinspection PyUnresolvedReferences
 import subprocess
 import unittest
+import tempfile
 from glob import glob
 from subprocess import Popen, PIPE
 
@@ -253,6 +254,15 @@ def read_file_build_hash(fn):
 	return rc
 
 
+def remove_lvm_debug():
+	# If we are running the lvmdbusd daemon and collecting lvm debug data, check and
+	# clean-up after the tests.
+	tmpdir = tempfile.gettempdir()
+	for f in glob("lvmdbusd.lvm.debug.*.log", root_dir=tmpdir):
+		fn = os.path.join(tmpdir, f)
+		os.unlink(fn)
+
+
 class DaemonInfo(object):
 	def __init__(self, pid):
 		# The daemon is running, we have a pid, lets see how it's being run.
@@ -417,6 +427,7 @@ class TestDbusService(unittest.TestCase):
 		self.addCleanup(self.clean_up)
 
 		self.vdo = supports_vdo()
+		remove_lvm_debug()
 
 	def _recurse_vg_delete(self, vg_proxy, pv_proxy, nested_pv_hash):
 		vg_name = str(vg_proxy.Vg.Name)
@@ -481,6 +492,8 @@ class TestDbusService(unittest.TestCase):
 					# print('Re-creating PV=', p)
 					self._pv_create(p)
 
+		remove_lvm_debug()
+
 	def _check_consistency(self):
 		# Only do consistency checks if we aren't running the unit tests
 		# concurrently

