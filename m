From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Jan 2020 14:20:15 -0500
Subject: master - lvmdbusd: Add VDO enable/disable compress & dedup
Message-ID: <18846.120010914201200141@us-mta-250.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c3ef41f620418bc9d5932fc6f7284a600e6cebec
Commit:        c3ef41f620418bc9d5932fc6f7284a600e6cebec
Parent:        87e88078c993a149af6d2f104998c508b7aee9be
Author:        Vojtech Trefny <vtrefny@redhat.com>
AuthorDate:    Fri Dec 27 15:29:15 2019 +0100
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jan 9 13:07:47 2020 -0600

lvmdbusd: Add VDO enable/disable compress & dedup

Added methods to vdo pool interface to allow enabling and
disabling of VDO:
 * Compression
 * Deduplication
---
 daemons/lvmdbusd/cmdhandler.py |   22 +++++++++++++
 daemons/lvmdbusd/lv.py         |   66 ++++++++++++++++++++++++++++++++++++++++
 test/dbus/lvmdbustest.py       |   32 ++++++++++++++++++-
 3 files changed, 118 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index e0bb105..aa5199f 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -460,6 +460,28 @@ def lv_detach_cache(lv_full_name, detach_options, destroy_cache):
 	return call(cmd)
 
 
+def lv_vdo_compression(lv_path, enable, comp_options):
+	cmd = ['lvchange', '--compression']
+	if enable:
+		cmd.append('y')
+	else:
+		cmd.append('n')
+	cmd.extend(options_to_cli_args(comp_options))
+	cmd.append(lv_path)
+	return call(cmd)
+
+
+def lv_vdo_deduplication(lv_path, enable, dedup_options):
+	cmd = ['lvchange', '--deduplication']
+	if enable:
+		cmd.append('y')
+	else:
+		cmd.append('n')
+	cmd.extend(options_to_cli_args(dedup_options))
+	cmd.append(lv_path)
+	return call(cmd)
+
+
 def supports_json():
 	cmd = ['help']
 	rc, out, err = call(cmd)
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 3018749..fd46f34 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -780,6 +780,72 @@ class LvVdoPool(Lv):
 	def DataLv(self):
 		return dbus.ObjectPath(self._data_lv)
 
+	@staticmethod
+	def _enable_disable_compression(pool_uuid, pool_name, enable, comp_options):
+		# Make sure we have a dbus object representing it
+		LvCommon.validate_dbus_object(pool_uuid, pool_name)
+		# Rename the logical volume
+		LvCommon.handle_execute(*cmdhandler.lv_vdo_compression(
+			pool_name, enable, comp_options))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=VDO_POOL_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def EnableCompression(self, tmo, comp_options, cb, cbe):
+		r = RequestEntry(
+			tmo, LvVdoPool._enable_disable_compression,
+			(self.Uuid, self.lvm_id, True, comp_options),
+			cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+	dbus_interface=VDO_POOL_INTERFACE,
+	in_signature='ia{sv}',
+	out_signature='o',
+	async_callbacks=('cb', 'cbe'))
+	def DisableCompression(self, tmo, comp_options, cb, cbe):
+		r = RequestEntry(
+			tmo, LvVdoPool._enable_disable_compression,
+			(self.Uuid, self.lvm_id, False, comp_options),
+			cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _enable_disable_deduplication(pool_uuid, pool_name, enable, dedup_options):
+		# Make sure we have a dbus object representing it
+		LvCommon.validate_dbus_object(pool_uuid, pool_name)
+		# Rename the logical volume
+		LvCommon.handle_execute(*cmdhandler.lv_vdo_deduplication(
+			pool_name, enable, dedup_options))
+		return '/'
+
+	@dbus.service.method(
+		dbus_interface=VDO_POOL_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def EnableDeduplication(self, tmo, dedup_options, cb, cbe):
+		r = RequestEntry(
+			tmo, LvVdoPool._enable_disable_deduplication,
+			(self.Uuid, self.lvm_id, True, dedup_options),
+			cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(
+	dbus_interface=VDO_POOL_INTERFACE,
+	in_signature='ia{sv}',
+	out_signature='o',
+	async_callbacks=('cb', 'cbe'))
+	def DisableDeduplication(self, tmo, dedup_options, cb, cbe):
+		r = RequestEntry(
+			tmo, LvVdoPool._enable_disable_deduplication,
+			(self.Uuid, self.lvm_id, False, dedup_options),
+			cb, cbe, False)
+		cfg.worker_q.put(r)
+
 
 # noinspection PyPep8Naming
 class LvThinPool(Lv):
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 8215968..b819a04 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1858,11 +1858,11 @@ class TestDbusService(unittest.TestCase):
 		self.assertEqual(pv_object_path, self._lookup(symlink))
 		self.assertEqual(pv_object_path, self._lookup(pv_device_path))
 
-	def _create_vdo_pool_and_lv(self):
+	def _create_vdo_pool_and_lv(self, vg_prefix="vdo_"):
 		pool_name = lv_n("_vdo_pool")
 		lv_name = lv_n()
 
-		vg_proxy = self._vg_create(vg_prefix="vdo_")
+		vg_proxy = self._vg_create(vg_prefix=vg_prefix)
 		vdo_pool_object_path = self.handle_return(
 			vg_proxy.VgVdo.CreateVdoPoolandLv(
 				pool_name, lv_name,
@@ -1903,6 +1903,34 @@ class TestDbusService(unittest.TestCase):
 			vg, _, _ = self._create_vdo_pool_and_lv()
 			self.handle_return(vg.Vg.Remove(dbus.Int32(g_tmo), EOD))
 
+	def test_vdo_pool_compression_deduplication(self):
+		if not self.vdo:
+			raise unittest.SkipTest('vdo not supported')
+
+		vg, pool, _lv = self._create_vdo_pool_and_lv(vg_prefix="vdo2_")
+
+		# compression and deduplication should be enabled by default
+		self.assertEqual(pool.VdoPool.Compression, "enabled")
+		self.assertEqual(pool.VdoPool.Deduplication, "enabled")
+
+		self.handle_return(
+			pool.VdoPool.DisableCompression(dbus.Int32(g_tmo), EOD))
+		self.handle_return(
+			pool.VdoPool.DisableDeduplication(dbus.Int32(g_tmo), EOD))
+		pool.update()
+		self.assertEqual(pool.VdoPool.Compression, "")
+		self.assertEqual(pool.VdoPool.Deduplication, "")
+
+		self.handle_return(
+			pool.VdoPool.EnableCompression(dbus.Int32(g_tmo), EOD))
+		self.handle_return(
+			pool.VdoPool.EnableDeduplication(dbus.Int32(g_tmo), EOD))
+		pool.update()
+		self.assertEqual(pool.VdoPool.Compression, "enabled")
+		self.assertEqual(pool.VdoPool.Deduplication, "enabled")
+
+		self.handle_return(vg.Vg.Remove(dbus.Int32(g_tmo), EOD))
+
 	def _test_lv_method_interface(self, lv):
 		self._rename_lv_test(lv)
 		self._test_activate_deactivate(lv)



