From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 23 Sep 2022 12:59:06 +0000 (GMT)
Subject: main - lvmdbustest: Add test to stress mode changing
Message-ID: <20220923125906.A316F3857369@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fd05b79aad6ccf89f85bd85f5a4b32e1275ce785
Commit:        fd05b79aad6ccf89f85bd85f5a4b32e1275ce785
Parent:        897b326cccc017b9e033b83d24ddcb007a3922f4
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 22 17:11:45 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Sep 22 17:14:10 2022 -0500

lvmdbustest: Add test to stress mode changing

Add a test to toggle from fork & exec to lvm shell repeatedly, to stress
test it.
---
 test/dbus/lvmdbustest.py | 29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index cf50bc564..41ee2fd1b 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -26,12 +26,14 @@ from testlib import *
 
 g_tmo = 0
 
+g_lvm_shell = False
+
 # Approx. min size
 VDO_MIN_SIZE = mib(8192)
 
 VG_TEST_SUFFIX = "_vg_LvMdBuS_TEST"
 
-EXE_NAME="/lvmdbusd"
+EXE_NAME = "/lvmdbusd"
 
 # Prefix on created objects to enable easier clean-up
 g_prefix = os.getenv('PREFIX', '')
@@ -164,18 +166,24 @@ def get_objects():
 	return _prune(rc, pv_device_list), bus
 
 
+def set_exec_mode(lvmshell):
+	lvm_manager = dbus.Interface(bus.get_object(
+		BUS_NAME, "/com/redhat/lvmdbus1/Manager", introspect=False),
+		"com.redhat.lvmdbus1.Manager")
+	return lvm_manager.UseLvmShell(lvmshell)
+
+
 def set_execution(lvmshell, test_result):
+	global g_lvm_shell
 	if lvmshell:
 		m = 'lvm shell (non-fork)'
 	else:
 		m = "forking & exec'ing"
 
-	lvm_manager = dbus.Interface(bus.get_object(
-		BUS_NAME, "/com/redhat/lvmdbus1/Manager", introspect=False),
-		"com.redhat.lvmdbus1.Manager")
-	rc = lvm_manager.UseLvmShell(lvmshell)
+	rc = set_exec_mode(lvmshell)
 
 	if rc:
+		g_lvm_shell = lvmshell
 		std_err_print('Successfully changed execution mode to "%s"' % m)
 	else:
 		std_err_print('ERROR: Failed to change execution mode to "%s"' % m)
@@ -2355,6 +2363,7 @@ class TestDbusService(unittest.TestCase):
 				self.assertTrue(exited,
 								"Failed to exit after sending signal %f seconds after "
 								"queuing up work for signal %d" % (sleep_amt, signal.SIGINT))
+		set_exec_mode(g_lvm_shell)
 
 	def test_z_singleton_daemon(self):
 		# Ensure we can only have 1 daemon running at a time, daemon should exit with 114 if already running
@@ -2366,6 +2375,16 @@ class TestDbusService(unittest.TestCase):
 			ec = di.start(True)
 			self.assertEqual(ec, 114)
 
+	def test_z_switching(self):
+		# Ensure we can switch from forking to shell repeatedly
+		try:
+			t_mode = True
+			for _ in range(50):
+				t_mode = not t_mode
+				set_exec_mode(t_mode)
+		finally:
+			set_exec_mode(g_lvm_shell)
+
 
 class AggregateResults(object):
 

