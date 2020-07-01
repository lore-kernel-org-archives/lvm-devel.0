From: Vojtech Trefny <vtrefny@redhat.com>
Date: Wed,  1 Jul 2020 13:27:46 +0200
Subject: [PATCH 1/2] lvmdbusd: Add support for LVM writecache
Message-ID: <20200701112747.61278-1-vtrefny@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 daemons/lvmdbusd/cmdhandler.py |  9 +++++++
 daemons/lvmdbusd/lv.py         | 43 ++++++++++++++++++++++++++++++++++
 test/dbus/lvmdbustest.py       | 30 ++++++++++++++++++++++++
 3 files changed, 82 insertions(+)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 7d2f4c4ba..1c15b7888 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -453,6 +453,15 @@ def lv_cache_lv(cache_pool_full_name, lv_full_name, cache_options):
 	return call(cmd)
 
 
+def lv_writecache_lv(cache_lv_full_name, lv_full_name, cache_options):
+	# lvconvert --type writecache --cachevol VG/CacheLV VG/OriginLV
+	cmd = ['lvconvert']
+	cmd.extend(options_to_cli_args(cache_options))
+	cmd.extend(['-y', '--type', 'writecache', '--cachevol',
+				cache_lv_full_name, lv_full_name])
+	return call(cmd)
+
+
 def lv_detach_cache(lv_full_name, detach_options, destroy_cache):
 	cmd = ['lvconvert']
 	if destroy_cache:
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index fd46f348b..f21a332a3 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -743,6 +743,49 @@ class Lv(LvCommon):
 			cb, cbe, return_tuple=False)
 		cfg.worker_q.put(r)
 
+	@staticmethod
+	def _writecache_lv(lv_uuid, lv_name, lv_object_path, cache_options):
+		# Make sure we have a dbus object representing it
+		dbo = LvCommon.validate_dbus_object(lv_uuid, lv_name)
+
+		# Make sure we have dbus object representing lv to cache
+		lv_to_cache = cfg.om.get_object_by_path(lv_object_path)
+
+		if lv_to_cache:
+			fcn = lv_to_cache.lv_full_name()
+			rc, out, err = cmdhandler.lv_writecache_lv(
+				dbo.lv_full_name(), fcn, cache_options)
+			if rc == 0:
+				# When we cache an LV, the cache pool and the lv that is getting
+				# cached need to be removed from the object manager and
+				# re-created as their interfaces have changed!
+				mt_remove_dbus_objects((dbo, lv_to_cache))
+				cfg.load()
+
+				lv_converted = cfg.om.get_object_path_by_lvm_id(fcn)
+			else:
+				raise dbus.exceptions.DBusException(
+					LV_INTERFACE,
+					'Exit code %s, stderr = %s' % (str(rc), err))
+		else:
+			raise dbus.exceptions.DBusException(
+				LV_INTERFACE, 'LV to cache with object path %s not present!' %
+				lv_object_path)
+		return lv_converted
+
+	@dbus.service.method(
+		dbus_interface=LV_INTERFACE,
+		in_signature='oia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def WriteCacheLv(self, lv_object, tmo, cache_options, cb, cbe):
+		r = RequestEntry(
+			tmo, Lv._writecache_lv,
+			(self.Uuid, self.lvm_id, lv_object,
+			cache_options), cb, cbe)
+		cfg.worker_q.put(r)
+
+
 # noinspection PyPep8Naming
 @utils.dbus_property(VDO_POOL_INTERFACE, 'OperatingMode', 's')
 @utils.dbus_property(VDO_POOL_INTERFACE, 'CompressionState', 's')
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 8753e65d0..efa1afb26 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1558,6 +1558,36 @@ class TestDbusService(unittest.TestCase):
 			cached_lv.Lv.Rename(dbus.String(new_name), dbus.Int32(g_tmo), EOD))
 		verify_cache_lv_count()
 
+	def test_writecache_lv(self):
+		vg = self._vg_create().Vg
+		data_lv = self._create_lv(size=mib(16), vg=vg)
+		cache_lv = self._create_lv(size=mib(16), vg=vg)
+
+		# both LVs need to be inactive
+		self.handle_return(data_lv.Lv.Deactivate(
+			dbus.UInt64(0), dbus.Int32(g_tmo), EOD))
+		data_lv.update()
+		self.handle_return(cache_lv.Lv.Deactivate(
+			dbus.UInt64(0), dbus.Int32(g_tmo), EOD))
+		cache_lv.update()
+
+		cached_lv_path = self.handle_return(
+			cache_lv.Lv.WriteCacheLv(
+				dbus.ObjectPath(data_lv.object_path),
+				dbus.Int32(g_tmo),
+				EOD))
+
+		intf = (LV_COMMON_INT, LV_INT, CACHE_LV_INT)
+		cached_lv = ClientProxy(self.bus, cached_lv_path, interfaces=intf)
+		self.assertEqual(cached_lv.LvCommon.SegType, ["writecache"])
+
+		uncached_lv_path = self.handle_return(
+				cached_lv.CachedLv.DetachCachePool(
+					dbus.Boolean(True),
+					dbus.Int32(g_tmo),
+					EOD))
+		self.assertTrue('/com/redhat/lvmdbus1/Lv' in uncached_lv_path)
+
 	def test_vg_change(self):
 		vg_proxy = self._vg_create()
 
-- 
2.25.4


