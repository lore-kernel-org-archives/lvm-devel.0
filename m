From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:41:46 -0500
Subject: master - lvmdbustest.py: Add unit test for external VG create
Message-ID: <201703092241.v29MfkGN011978@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43d0fbeba281b1f9f97bf9bcf1149e682f9e6b6d
Commit:        43d0fbeba281b1f9f97bf9bcf1149e682f9e6b6d
Parent:        92b7c329ee6524fdf868a4261025406445744b12
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 8 15:50:46 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbustest.py: Add unit test for external VG create

Ensure a VG created outside of the dbus service is immediately found by
service user.
---
 test/dbus/lvmdbustest.py |   47 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 71b62e1..4788eb3 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -17,6 +17,7 @@ import unittest
 import pyudev
 from testlib import *
 import testlib
+from subprocess import Popen, PIPE
 
 g_tmo = 0
 
@@ -35,6 +36,9 @@ pv_device_list = os.getenv('LVM_DBUSD_PV_DEVICE_LIST', None)
 # Other == Test just lvm shell mode
 test_shell = os.getenv('LVM_DBUSD_TEST_MODE', 1)
 
+# LVM binary to use
+LVM_EXECUTABLE = os.getenv('LVM_BINARY', '/usr/sbin/lvm')
+
 # Empty options dictionary (EOD)
 EOD = dbus.Dictionary({}, signature=dbus.Signature('sv'))
 # Base interfaces on LV objects
@@ -111,6 +115,26 @@ def set_execution(lvmshell, test_result):
 	return rc
 
 
+def call_lvm(command):
+	"""
+	Call lvm executable and return a tuple of exitcode, stdout, stderr
+	:param command:     Command to execute
+	:param debug:       Dump debug to stdout
+	"""
+
+	# Prepend the full lvm executable so that we can run different versions
+	# in different locations on the same box
+	command.insert(0, LVM_EXECUTABLE)
+
+	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True,
+					env=os.environ)
+	out = process.communicate()
+
+	stdout_text = bytes(out[0]).decode("utf-8")
+	stderr_text = bytes(out[1]).decode("utf-8")
+	return process.returncode, stdout_text, stderr_text
+
+
 # noinspection PyUnresolvedReferences
 class TestDbusService(unittest.TestCase):
 	def setUp(self):
@@ -1702,6 +1726,29 @@ class TestDbusService(unittest.TestCase):
 			tag in vg_proxy.Vg.Tags,
 			"%s not in %s" % (tag, str(vg_proxy.Vg.Tags)))
 
+	def _verify_existence(self, cmd, operation, resource_name):
+		ec, stdout, stderr = call_lvm(cmd)
+		if ec == 0:
+			path = self._lookup(resource_name)
+			self.assertTrue(path != '/')
+		else:
+			self.assertTrue(ec == 0, "%s exit code = %d" % (operation, ec))
+			std_err_print(
+				"%s failed with stdout= %s, stderr= %s" %
+				(operation, stdout, stderr))
+
+	def test_external_vg_create(self):
+		# We need to ensure that if a user creates something outside of lvm
+		# dbus service that things are sequenced correctly so that if a dbus
+		# user calls into the service they will find the same information.
+		vg_name = vg_n()
+
+		# Get all the PV device paths
+		pv_paths = [p.Pv.Name for p in self.objs[PV_INT]]
+
+		cmd = ['vgcreate', vg_name]
+		cmd.extend(pv_paths)
+		self._verify_existence(cmd, cmd[0], vg_name)
 
 class AggregateResults(object):
 


