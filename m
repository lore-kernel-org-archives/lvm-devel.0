From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:13 -0400
Subject: master - lvmdbustest.py: Add func. _create_thin_lv
Message-ID: <201910301544.x9UFiDDg016693@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=293f6d27951829940f35b6728cfbf3e1b4574ab6
Commit:        293f6d27951829940f35b6728cfbf3e1b4574ab6
Parent:        a4666f63ade186e960c5f70399389e0d2fb28c81
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 15:50:08 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Add func. _create_thin_lv

---
 test/dbus/lvmdbustest.py |   32 +++++++++-----------------------
 1 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index d3e1f53..082c958 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -759,12 +759,7 @@ class TestDbusService(unittest.TestCase):
 		self._check_consistency()
 		self.assertEqual(new_name, tp.LvCommon.Name)
 
-	# noinspection PyUnresolvedReferences
-	def test_lv_on_thin_pool_rename(self):
-		# Rename a LV on a thin Pool
-
-		# This returns a LV with the LV interface, need to get a proxy for
-		# thinpool interface too
+	def _create_thin_lv(self):
 		vg = self._vg_create().Vg
 		tp = self._create_lv(thinpool=True, vg=vg)
 
@@ -773,15 +768,20 @@ class TestDbusService(unittest.TestCase):
 		thin_path = self.handle_return(
 			tp.ThinPool.LvCreate(
 				dbus.String(lv_name),
-				dbus.UInt64(mib(8)),
+				dbus.UInt64(mib(10)),
 				dbus.Int32(g_tmo),
 				EOD)
 		)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), thin_path)
 
 		lv = ClientProxy(self.bus, thin_path,
-							interfaces=(LV_COMMON_INT, LV_INT))
+						 interfaces=(LV_COMMON_INT, LV_INT))
+		return vg, thin_path, lv
 
+	# noinspection PyUnresolvedReferences
+	def test_lv_on_thin_pool_rename(self):
+		# Rename a LV on a thin Pool
+		vg, thin_path, lv = self._create_thin_lv()
 		re_named = 'rename_test' + lv.LvCommon.Name
 		rc = self.handle_return(
 			lv.Lv.Rename(
@@ -1445,21 +1445,7 @@ class TestDbusService(unittest.TestCase):
 
 	def test_snapshot_merge_thin(self):
 		# Create a thin LV, snapshot it and merge it
-		vg = self._vg_create().Vg
-		tp = self._create_lv(thinpool=True, vg=vg)
-		lv_name = lv_n('_thin_lv')
-
-		thin_path = self.handle_return(
-			tp.ThinPool.LvCreate(
-				dbus.String(lv_name),
-				dbus.UInt64(mib(10)),
-				dbus.Int32(g_tmo),
-				EOD))
-
-		self._validate_lookup("%s/%s" % (vg.Name, lv_name), thin_path)
-
-		lv_p = ClientProxy(self.bus, thin_path,
-							interfaces=(LV_INT, LV_COMMON_INT))
+		_vg, _thin_path, lv_p = self._create_thin_lv()
 
 		ss_name = lv_p.LvCommon.Name + '_snap'
 		snapshot_path = self.handle_return(


