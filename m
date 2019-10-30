From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:01 -0400
Subject: master - lvmdbustest.py: Add basic vdo test
Message-ID: <201910301545.x9UFj16g016868@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89373761c808c21181751d622e987b323355b677
Commit:        89373761c808c21181751d622e987b323355b677
Parent:        ed7e365ae5a2b79bf14a3f9772e8e1f663bb6c4f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 9 16:55:39 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Add basic vdo test

---
 test/dbus/lvmdbustest.py |   54 +++++++++++++++++++++++++++++++++++++++++++++-
 test/dbus/testlib.py     |    1 +
 2 files changed, 54 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 1d340df..f8842ef 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -176,6 +176,15 @@ def call_lvm(command):
 	return process.returncode, stdout_text, stderr_text
 
 
+def supports_vdo():
+	cmd = ['segtypes']
+	rc, out, err = call_lvm(cmd)
+	if rc == 0:
+		if "vdo" in out:
+			return True
+	return False
+
+
 # noinspection PyUnresolvedReferences
 class TestDbusService(unittest.TestCase):
 	def setUp(self):
@@ -198,6 +207,8 @@ class TestDbusService(unittest.TestCase):
 		for p in self.objs[PV_INT]:
 			self.pvs.append(p.Pv.Name)
 
+		self.vdo = supports_vdo()
+
 	def _recurse_vg_delete(self, vg_proxy, pv_proxy, nested_pv_hash):
 
 		for pv_device_name, t in nested_pv_hash.items():
@@ -320,7 +331,12 @@ class TestDbusService(unittest.TestCase):
 
 		self._validate_lookup(vg_name, vg_path)
 		self.assertTrue(vg_path is not None and len(vg_path) > 0)
-		return ClientProxy(self.bus, vg_path, interfaces=(VG_INT, ))
+
+		intf = [VG_INT, ]
+		if self.vdo:
+			intf.append(VG_VDO_INT)
+
+		return ClientProxy(self.bus, vg_path, interfaces=intf)
 
 	def test_vg_create(self):
 		self._vg_create()
@@ -1776,6 +1792,42 @@ class TestDbusService(unittest.TestCase):
 		self.assertEqual(pv_object_path, self._lookup(symlink))
 		self.assertEqual(pv_object_path, self._lookup(pv_device_path))
 
+	def _create_vdo_pool_and_lv(self):
+		pool_name = lv_n("_vdo_pool")
+		lv_name = lv_n()
+
+		vg_proxy = self._vg_create()
+		vdo_pool_object_path = self.handle_return(
+			vg_proxy.VgVdo.CreateVdoPoolandLv(
+				pool_name, lv_name,
+				dbus.UInt64(mib(4096)),
+				dbus.UInt64(mib(8192)),
+				dbus.Int32(g_tmo),
+				EOD))
+
+		self.assertNotEqual(vdo_pool_object_path, "/")
+		self.assertEqual(
+			vdo_pool_object_path,
+			self._lookup("%s/%s" % (vg_proxy.Vg.Name, pool_name)))
+
+		vdo_lv = self._lookup("%s/%s" % (vg_proxy.Vg.Name, lv_name))
+		self.assertNotEqual(vdo_lv, "/")
+		intf = (LV_COMMON_INT, LV_INT, VDOPOOL_INT)
+		pool_lv = ClientProxy(self.bus, vdo_lv, interfaces=intf)
+		return vg_proxy, pool_lv
+
+	def test_vdo_pool_create(self):
+		# Basic vdo sanity testing
+		if not self.vdo:
+			raise unittest.SkipTest('vdo not supported')
+
+		# Do this twice to ensure we are providing the correct flags to force
+		# the operation when if finds an existing vdo signature, which likely
+		# shouldn't exist.
+		for _ in range(0, 2):
+			vg, _ = self._create_vdo_pool_and_lv()
+			self.handle_return(vg.Vg.Remove(dbus.Int32(g_tmo), EOD))
+
 
 class AggregateResults(object):
 
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index e6655a5..bf88beb 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -243,6 +243,7 @@ class ClientProxy(object):
 	Pv = None
 	Lv = None
 	Vg = None
+	VgVdo = None
 
 	@staticmethod
 	def _intf_short_name(nm):


