From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Jun 2016 21:06:37 +0000 (UTC)
Subject: master - lvmdbusd: Add test for DataLv & MetaDataLv
Message-ID: <20160610210637.C773060E6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1febff85783b46b5b044bce6f29ece8413ce934
Commit:        a1febff85783b46b5b044bce6f29ece8413ce934
Parent:        cdf06044e189ec1adeaba101a21598c31752b9cd
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 10 13:36:53 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 10 16:05:03 2016 -0500

lvmdbusd: Add test for DataLv & MetaDataLv

Added tests which expose an issue found with these properties.
---
 test/dbus/lvmdbustest.py |   60 +++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 57 insertions(+), 3 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 4c58552..0cb3bb6 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -158,6 +158,58 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(rc == '/')
 		self.assertEqual(self._refresh(), 0)
 
+
+	def _create_raid5_thin_pool(self, vg = None):
+
+		if not vg:
+			pv_paths = []
+			for pp in self.objs[PV_INT]:
+				pv_paths.append(pp.object_path)
+
+			vg = self._vg_create(pv_paths).Vg
+
+		lv_meta_path = vg.LvCreateRaid(
+			"meta_r5", "raid5", mib(4), 0, 0, -1, {})[0]
+
+		lv_data_path = vg.LvCreateRaid(
+			"data_r5", "raid5", mib(16), 0, 0, -1, {})[0]
+
+		thin_pool_path = vg.CreateThinPool(
+			lv_meta_path, lv_data_path, -1, {})[0]
+
+		# Get thin pool client proxy
+		thin_pool = ClientProxy(self.bus, thin_pool_path)
+
+		return vg, thin_pool
+
+	def test_meta_lv_data_lv_props(self):
+		# Ensure that metadata lv and data lv for thin pools and cache pools
+		# point to a valid LV
+		(vg, thin_pool) = self._create_raid5_thin_pool()
+
+		# Check properties on thin pool
+		self.assertTrue(thin_pool.ThinPool.DataLv != '/')
+		self.assertTrue(thin_pool.ThinPool.MetaDataLv != '/')
+
+		(vg, cache_pool) = self._create_cache_pool(vg)
+
+		self.assertTrue(cache_pool.CachePool.DataLv != '/')
+		self.assertTrue(cache_pool.CachePool.MetaDataLv != '/')
+
+		# Cache the thin pool
+		cached_thin_pool_path = cache_pool.\
+			CachePool.CacheLv(thin_pool.object_path, -1, {})[0]
+
+
+		# Get object proxy for cached thin pool
+		cached_thin_pool_object = ClientProxy(self.bus, cached_thin_pool_path)
+
+		# Check properties on cache pool
+		self.assertTrue(cached_thin_pool_object.ThinPool.DataLv != '/')
+		self.assertTrue(cached_thin_pool_object.ThinPool.MetaDataLv != '/')
+
+		self.assertTrue(cached_thin_pool_path != '/')
+
 	def _lookup(self, lvm_id):
 		return self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(lvm_id)
 
@@ -974,8 +1026,10 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(job_path != '/')
 		self._wait_for_job(job_path)
 
-	def _create_cache_pool(self):
-		vg = self._vg_create().Vg
+	def _create_cache_pool(self, vg=None):
+
+		if not vg:
+			vg = self._vg_create().Vg
 
 		md = self._create_lv(size=(mib(8)), vg=vg)
 		data = self._create_lv(size=(mib(8)), vg=vg)
@@ -985,7 +1039,7 @@ class TestDbusService(unittest.TestCase):
 
 		cp = ClientProxy(self.bus, cache_pool_path)
 
-		return (vg, cp)
+		return vg, cp
 
 	def test_cache_pool_create(self):
 


