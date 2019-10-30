From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:50 -0400
Subject: master - lvmdbustest.py: Create common func. _create_cache_lv
Message-ID: <201910301544.x9UFiodI016825@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=455498f206e60c513ce36083d1f336aad11e33f8
Commit:        455498f206e60c513ce36083d1f336aad11e33f8
Parent:        c786636afba068fc0f560b6dd1dd9dd532c35135
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 9 12:29:52 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Create common func. _create_cache_lv

---
 test/dbus/lvmdbustest.py |   52 ++++++++++++++++++---------------------------
 1 files changed, 21 insertions(+), 31 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 0b7140a..aed5511 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1424,22 +1424,25 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(
 			'/com/redhat/lvmdbus1/CachePool' in cache_pool.object_path)
 
-	def test_cache_lv_create(self):
+	def _create_cache_lv(self):
+		vg, cache_pool = self._create_cache_pool()
 
-		for destroy_cache in [True, False]:
-			vg, cache_pool = self._create_cache_pool()
+		lv_to_cache = self._create_lv(size=mib(8), vg=vg)
 
-			lv_to_cache = self._create_lv(size=mib(8), vg=vg)
+		c_lv_path = self.handle_return(
+			cache_pool.CachePool.CacheLv(
+				dbus.ObjectPath(lv_to_cache.object_path),
+				dbus.Int32(g_tmo),
+				EOD))
 
-			c_lv_path = self.handle_return(
-				cache_pool.CachePool.CacheLv(
-					dbus.ObjectPath(lv_to_cache.object_path),
-					dbus.Int32(g_tmo),
-					EOD))
+		intf = (LV_COMMON_INT, LV_INT, CACHE_LV_INT)
+		cached_lv = ClientProxy(self.bus, c_lv_path, interfaces=intf)
+		return vg, cache_pool, cached_lv
 
-			intf = (LV_COMMON_INT, LV_INT, CACHE_LV_INT)
-			cached_lv = ClientProxy(self.bus, c_lv_path, interfaces=intf)
+	def test_cache_lv_create(self):
 
+		for destroy_cache in [True, False]:
+			vg, _, cached_lv = self._create_cache_lv()
 			uncached_lv_path = self.handle_return(
 				cached_lv.CachedLv.DetachCachePool(
 					dbus.Boolean(destroy_cache),
@@ -1459,31 +1462,18 @@ class TestDbusService(unittest.TestCase):
 		internal state update.
 		:return:
 		"""
-		vg, cache_pool = self._create_cache_pool()
-
-		lv_to_cache = self._create_lv(size=mib(8), vg=vg)
-
-		c_lv_path = self.handle_return(
-			cache_pool.CachePool.CacheLv(
-				dbus.ObjectPath(lv_to_cache.object_path),
-				dbus.Int32(g_tmo),
-				EOD))
+		def verify_cache_lv_count():
+			cur_objs, _ = get_objects()
+			self.assertEqual(len(cur_objs[CACHE_LV_INT]), 2)
+			self._check_consistency()
 
-		# Make sure we only have expected # of cached LV
-		cur_objs, _ = get_objects()
-		self.assertEqual(len(cur_objs[CACHE_LV_INT]), 2)
+		_, _, cached_lv = self._create_cache_lv()
 
-		intf = (LV_COMMON_INT, LV_INT, CACHE_LV_INT)
-		cached_lv = ClientProxy(self.bus, c_lv_path, interfaces=intf)
+		verify_cache_lv_count()
 		new_name = 'renamed_' + cached_lv.LvCommon.Name
-
 		self.handle_return(
 			cached_lv.Lv.Rename(dbus.String(new_name), dbus.Int32(g_tmo), EOD))
-
-		# Make sure we only have expected # of cached LV
-		cur_objs, _ = get_objects()
-		self.assertEqual(len(cur_objs[CACHE_LV_INT]), 2)
-		self._check_consistency()
+		verify_cache_lv_count()
 
 	def test_vg_change(self):
 		vg_proxy = self._vg_create()


