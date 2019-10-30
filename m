From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:38 -0400
Subject: master - lvmdbustest.py: Add cache LV rename test
Message-ID: <201910301544.x9UFicBZ016779@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5b224d58f7cb72852c0bad87d3a0b4fb9250b132
Commit:        5b224d58f7cb72852c0bad87d3a0b4fb9250b132
Parent:        6204955347b2d57ded9e6385aa5118392e182a48
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 8 08:03:50 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Add cache LV rename test

---
 test/dbus/lvmdbustest.py |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 1e4d40d..c589fd1 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1455,6 +1455,39 @@ class TestDbusService(unittest.TestCase):
 				vg.Remove(dbus.Int32(g_tmo), EOD))
 			self.assertTrue(rc == '/')
 
+	def test_cache_lv_rename(self):
+		"""
+		Make sure that if we rename a cache lv that we correctly handle the
+		internal state update.
+		:return:
+		"""
+		vg, cache_pool = self._create_cache_pool()
+
+		lv_to_cache = self._create_lv(size=mib(8), vg=vg)
+
+		c_lv_path = self.handle_return(
+			cache_pool.CachePool.CacheLv(
+				dbus.ObjectPath(lv_to_cache.object_path),
+				dbus.Int32(g_tmo),
+				EOD))
+
+		# Make sure we only have expected # of cached LV
+		cur_objs, _ = get_objects()
+		self.assertEqual(len(cur_objs[CACHE_LV_INT]), 2)
+
+		cached_lv = ClientProxy(self.bus, c_lv_path,
+								interfaces=(LV_COMMON_INT, LV_INT,
+											CACHE_LV_INT))
+		new_name = 'renamed_' + cached_lv.LvCommon.Name
+
+		self.handle_return(cached_lv.Lv.Rename(dbus.String(new_name),
+												dbus.Int32(g_tmo), EOD))
+
+		# Make sure we only have expected # of cached LV
+		cur_objs, _ = get_objects()
+		self.assertEqual(len(cur_objs[CACHE_LV_INT]), 2)
+		self._check_consistency()
+
 	def test_vg_change(self):
 		vg_proxy = self._vg_create()
 


