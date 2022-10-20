From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 20 Oct 2022 20:11:35 +0000 (GMT)
Subject: main - lvmdbustest: Add test for wipefs
Message-ID: <20221020201135.41463384BC20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a6ae2d4d8e65452bbdddd9a3cbd317e142fb9f1
Commit:        5a6ae2d4d8e65452bbdddd9a3cbd317e142fb9f1
Parent:        0f56c1ad1262857961aff7b5a0ae6593a3de8db3
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 18 12:26:14 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Oct 20 15:10:35 2022 -0500

lvmdbustest: Add test for wipefs

Ensure that if an external program or user calles wipefs on a PV that we
correctly update the state of the daemon.
---
 test/dbus/lvmdbustest.py | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 41ee2fd1b..f158da571 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2385,6 +2385,40 @@ class TestDbusService(unittest.TestCase):
 		finally:
 			set_exec_mode(g_lvm_shell)
 
+	@staticmethod
+	def _wipe_it(block_device):
+		cmd = ["/usr/sbin/wipefs", '-a', block_device]
+		config = Popen(cmd, stdout=PIPE, stderr=PIPE, close_fds=True, env=os.environ)
+		config.communicate()
+		if config.returncode != 0:
+			return False
+		return True
+
+	def test_wipefs(self):
+		# Ensure we update the status of the daemon if an external process clears a PV
+		pv = self.objs[PV_INT][0]
+		pv_device_path = pv.Pv.Name
+
+		wipe_result = TestDbusService._wipe_it(pv_device_path)
+		self.assertTrue(wipe_result)
+
+		if wipe_result:
+			# Need to wait a bit before the daemon will reflect the change
+			start = time.time()
+			found = True
+			while found and time.time() < start + 10:
+				if (self._lookup(pv_device_path) == "/"):
+					found = False
+
+			print("Note: Time for udev update = %f" % (time.time() - start))
+			# Make sure that the service no longer has it
+			rc = self._lookup(pv_device_path)
+			self.assertEqual(rc, '/')
+
+			# Put it back
+			pv_object_path = self._pv_create(pv_device_path)
+			self.assertNotEqual(pv_object_path, '/')
+
 
 class AggregateResults(object):
 

