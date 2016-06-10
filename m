From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Jun 2016 21:06:39 +0000 (UTC)
Subject: master - lvmdbusd: Remove duplicate test code
Message-ID: <20160610210639.D782F60E6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d384954adf6355364257045738c9bd6c5dedad5
Commit:        2d384954adf6355364257045738c9bd6c5dedad5
Parent:        a1febff85783b46b5b044bce6f29ece8413ce934
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 10 13:45:59 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 10 16:05:03 2016 -0500

lvmdbusd: Remove duplicate test code

---
 test/dbus/lvmdbustest.py |   30 ++++--------------------------
 1 files changed, 4 insertions(+), 26 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 0cb3bb6..4443b0c 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -158,8 +158,7 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(rc == '/')
 		self.assertEqual(self._refresh(), 0)
 
-
-	def _create_raid5_thin_pool(self, vg = None):
+	def _create_raid5_thin_pool(self, vg=None):
 
 		if not vg:
 			pv_paths = []
@@ -200,7 +199,6 @@ class TestDbusService(unittest.TestCase):
 		cached_thin_pool_path = cache_pool.\
 			CachePool.CacheLv(thin_pool.object_path, -1, {})[0]
 
-
 		# Get object proxy for cached thin pool
 		cached_thin_pool_object = ClientProxy(self.bus, cached_thin_pool_path)
 
@@ -208,8 +206,6 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(cached_thin_pool_object.ThinPool.DataLv != '/')
 		self.assertTrue(cached_thin_pool_object.ThinPool.MetaDataLv != '/')
 
-		self.assertTrue(cached_thin_pool_path != '/')
-
 	def _lookup(self, lvm_id):
 		return self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(lvm_id)
 
@@ -258,9 +254,10 @@ class TestDbusService(unittest.TestCase):
 		mgr = self.objs[MANAGER_INT][0].Manager
 
 		# Do a vg lookup
-		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(vg.Name)
+		path = mgr.LookUpByLvmId(vg.Name)
 
 		vg_name_start = vg.Name
+
 		prev_path = path
 		self.assertTrue(path != '/', "%s" % (path))
 
@@ -317,30 +314,11 @@ class TestDbusService(unittest.TestCase):
 
 	def test_vg_rename_with_thin_pool(self):
 
-		pv_paths = []
-		for pp in self.objs[PV_INT]:
-			pv_paths.append(pp.object_path)
-
-		vg = self._vg_create(pv_paths).Vg
+		(vg, thin_pool) = self._create_raid5_thin_pool()
 
 		vg_name_start = vg.Name
-
 		mgr = self.objs[MANAGER_INT][0].Manager
 
-		# Let's create a thin pool which uses a raid 5 meta and raid5 data
-		# areas
-		lv_meta_path = vg.LvCreateRaid(
-			"meta_r5", "raid5", mib(4), 0, 0, -1, {})[0]
-
-		lv_data_path = vg.LvCreateRaid(
-			"data_r5", "raid5", mib(16), 0, 0, -1, {})[0]
-
-		thin_pool_path = vg.CreateThinPool(
-			lv_meta_path, lv_data_path, -1, {})[0]
-
-		# Lets create some thin LVs
-		thin_pool = ClientProxy(self.bus, thin_pool_path)
-
 		# noinspection PyTypeChecker
 		self._verify_hidden_lookups(thin_pool.LvCommon, vg_name_start)
 


