From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:02 +0000 (GMT)
Subject: main - lvmdbustest: Add test for passing log file in options
Message-ID: <20220919155802.683A03858406@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a202c11fffb30ae786e69cebe11186dd4166c88
Commit:        4a202c11fffb30ae786e69cebe11186dd4166c88
Parent:        60e4ba36e0843c9536278ff33ce6dfda9cfd8079
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 17 12:11:07 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Add test for passing log file in options

---
 test/dbus/lvmdbustest.py | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 4977021b1..c03e96c08 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -340,11 +340,14 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(rc is not None and len(rc) > 0)
 		self._check_consistency()
 
-	def _vg_create(self, pv_paths=None, vg_prefix=None):
+	def _vg_create(self, pv_paths=None, vg_prefix=None, options=None):
 
 		if not pv_paths:
 			pv_paths = self._all_pv_object_paths()
 
+		if options is None:
+			options = EOD
+
 		vg_name = vg_n(prefix=vg_prefix)
 
 		vg_path = self.handle_return(
@@ -352,7 +355,7 @@ class TestDbusService(unittest.TestCase):
 				dbus.String(vg_name),
 				dbus.Array(pv_paths, signature=dbus.Signature('o')),
 				dbus.Int32(g_tmo),
-				EOD))
+				options))
 
 		self._validate_lookup(vg_name, vg_path)
 		self.assertTrue(vg_path is not None and len(vg_path) > 0)
@@ -2077,6 +2080,20 @@ class TestDbusService(unittest.TestCase):
 		self._test_lv_method_interface_sequence(
 			self._vdo_pool_lv(), test_ss=False)
 
+	def _log_file_option(self):
+		fn = "/tmp/%s" % rs(8, "_lvm.log")
+		try:
+			options = dbus.Dictionary({}, signature=dbus.Signature('sv'))
+			option_str = "log { level=7 file=%s syslog=0 }" % fn
+			options["config"] = dbus.String(option_str)
+			self._vg_create(None, None, options)
+			self.assertTrue(os.path.exists(fn))
+		finally:
+			if os.path.exists(fn):
+				os.unlink(fn)
+
+	def test_log_file_option(self):
+		self._log_file_option()
 
 class AggregateResults(object):
 

