From: Tony Asleson <tasleson@sourceware.org>
Date: Fri,  3 Mar 2023 18:03:30 +0000 (GMT)
Subject: main - lvmdbustest: Test duplicate VG rename
Message-ID: <20230303180330.DF4E73858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e27dfd40576f4e2828b169bfe18d8cae9968244
Commit:        8e27dfd40576f4e2828b169bfe18d8cae9968244
Parent:        3e616230f2627d31599d1f4a2c7ff29b5ba86703
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Mar 3 11:17:30 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 3 11:17:30 2023 -0600

lvmdbustest: Test duplicate VG rename

---
 daemons/lvmdbusd/cmdhandler.py |  6 ++++--
 test/dbus/lvmdbustest.py       | 43 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index ea7e300cf..8bc741dc6 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -324,10 +324,12 @@ def vg_rename(vg_uuid, new_name, rename_options):
 	return call(cmd)
 
 
-def vg_remove(vg_name, remove_options):
+def vg_remove(vg_id, remove_options):
 	cmd = ['vgremove']
 	cmd.extend(options_to_cli_args(remove_options))
-	cmd.extend(['-f', vg_name])
+	cmd.extend(['-f', vg_id])
+	# https://bugzilla.redhat.com/show_bug.cgi?id=2175220 is preventing us from doing the following
+	# cmd.extend(['-f', "--select", "vg_uuid=%s" % vg_id])
 	return call(cmd)
 
 
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index ab68e7e5c..b7224df96 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2507,6 +2507,49 @@ class TestDbusService(unittest.TestCase):
 			else:
 				time.sleep(0.1)
 
+	@staticmethod
+	def _is_vg_devices_supported():
+		rc, stdout_txt, stderr_txt = call_lvm(["vgcreate", "--help"])
+		if rc == 0:
+			for line in stdout_txt.split("\n"):
+				if "--devices " in line:
+					return True
+		return False
+
+	@staticmethod
+	def _vg_create_specify_devices(name, device):
+		cmd = [LVM_EXECUTABLE, "vgcreate", "--devices", device, name, device]
+		outcome = Popen(cmd, stdout=PIPE, stderr=PIPE, close_fds=True, env=os.environ)
+		outcome.communicate()
+		if outcome.returncode == 0:
+			return True
+		else:
+			print("Failed to create vg %s, stdout= %s, stderr= %s" % (name, outcome.stdout, outcome.stderr))
+			return False
+
+	def test_duplicate_vg_name(self):
+		# LVM allows duplicate VG names, test handling renames for now
+		if not TestDbusService._is_vg_devices_supported():
+			raise unittest.SkipTest("lvm does not support vgcreate with --device syntax")
+
+		if len(self.objs[PV_INT]) < 2:
+			raise unittest.SkipTest("we need@least 2 PVs to run test")
+
+		vg_name = vg_n()
+		if TestDbusService._vg_create_specify_devices(vg_name, self.objs[PV_INT][0].Pv.Name) and \
+				TestDbusService._vg_create_specify_devices(vg_name, self.objs[PV_INT][1].Pv.Name):
+			objects, _ = get_objects()
+			self.assertEqual(len(objects[VG_INT]), 2)
+
+			if len(objects[VG_INT]) == 2:
+				for vg in objects[VG_INT]:
+					new_name = vg_n()
+					vg.Vg.Rename(dbus.String(new_name), dbus.Int32(g_tmo), EOD)
+					# Ensure we find the renamed VG
+					self.assertNotEqual("/", self._lookup(new_name), "Expecting to find VG='%s'" % new_name)
+		else:
+			self.assertFalse(True, "We failed to create 2 VGs with same name!")
+
 
 class AggregateResults(object):
 

