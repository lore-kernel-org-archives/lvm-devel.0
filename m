From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:24 +0000 (GMT)
Subject: main - lvmdbustest: Skip test_nesting if scan_lvs is not enabled
Message-ID: <20220919155824.01EC63858281@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5876a1f3fb729d255ea0bc3974d2891381620b3
Commit:        f5876a1f3fb729d255ea0bc3974d2891381620b3
Parent:        e5c41b94b841abe1ce3c23c814f7f7c31048b6e8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 30 12:47:14 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Skip test_nesting if scan_lvs is not enabled

---
 test/dbus/lvmdbustest.py | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 772313246..c932d0830 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2040,6 +2040,17 @@ class TestDbusService(unittest.TestCase):
 
 		return new_pv_object_path
 
+	@staticmethod
+	def _scan_lvs_enabled():
+		cmd = ['lvmconfig',  '--typeconfig', 'full', 'devices/scan_lvs']
+		config = Popen(cmd, stdout=PIPE, stderr=PIPE, close_fds=True, env=os.environ)
+		out = config.communicate()
+		if config.returncode != 0:
+			return False
+		if "scan_lvs=1" == out[0].decode("utf-8").strip():
+			return True
+		return False
+
 	def test_nesting(self):
 		# check to see if we handle an LV becoming a PV which has it's own
 		# LV
@@ -2053,6 +2064,8 @@ class TestDbusService(unittest.TestCase):
 
 		if dm_dev_dir != '/dev':
 			raise unittest.SkipTest('test not running in real /dev')
+		if not TestDbusService._scan_lvs_enabled():
+			raise unittest.SkipTest('scan_lvs=0 in config, unit test requires scan_lvs=1')
 		pv_object_path = self.objs[PV_INT][0].object_path
 		if not self.objs[PV_INT][0].Pv.Name.startswith("/dev"):
 			raise unittest.SkipTest('test not running in /dev')

