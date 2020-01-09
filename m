From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Jan 2020 14:20:19 -0500
Subject: master - lvmdbusd: Add function to convert LV into a VDO pool
Message-ID: <58526.120010914201500117@us-mta-30.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c496ba6505dda29bb1fb48b326cfd959ab0facd4
Commit:        c496ba6505dda29bb1fb48b326cfd959ab0facd4
Parent:        c3ef41f620418bc9d5932fc6f7284a600e6cebec
Author:        Vojtech Trefny <vtrefny@redhat.com>
AuthorDate:    Mon Jan 6 11:28:41 2020 +0100
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jan 9 13:07:55 2020 -0600

lvmdbusd: Add function to convert LV into a VDO pool

---
 daemons/lvmdbusd/cmdhandler.py |    8 ++++++++
 daemons/lvmdbusd/vg.py         |   32 ++++++++++++++++++++++++++++++++
 test/dbus/lvmdbustest.py       |   38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index aa5199f..7d2f4c4 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -398,6 +398,14 @@ def vg_create_vdo_pool_lv_and_lv(vg_name, pool_name, lv_name, data_size,
 	return call(cmd)
 
 
+def vg_create_vdo_pool(pool_full_name, lv_name, virtual_size, create_options):
+	cmd = ['lvconvert']
+	cmd.extend(options_to_cli_args(create_options))
+	cmd.extend(['--type', 'vdo-pool', '-n', lv_name, '--force', '-y',
+				'-V', '%dB' % virtual_size, pool_full_name])
+	return call(cmd)
+
+
 def lv_remove(lv_path, remove_options):
 	cmd = ['lvremove']
 	cmd.extend(options_to_cli_args(remove_options))
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 789626c..51fd07e 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -813,3 +813,35 @@ class VgVdo(Vg):
 							round_size(virtual_size),
 							create_options), cb, cbe)
 		cfg.worker_q.put(r)
+
+	@staticmethod
+	def _vdo_pool_create(uuid, vg_name, pool_lv, name, virtual_size, create_options):
+		Vg.validate_dbus_object(uuid, vg_name)
+
+		# Retrieve the full name of the pool lv
+		pool = cfg.om.get_object_by_path(pool_lv)
+		if not pool:
+			msg = 'LV with object path %s not present!' % \
+					(pool_lv)
+			raise dbus.exceptions.DBusException(VG_VDO_INTERFACE, msg)
+
+		Vg.handle_execute(*cmdhandler.vg_create_vdo_pool(
+			pool.lv_full_name(), name, virtual_size,
+			create_options))
+		return Vg.fetch_new_lv(vg_name, pool.Name)
+
+	@dbus.service.method(
+		dbus_interface=VG_VDO_INTERFACE,
+		in_signature='ostia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def CreateVdoPool(self, pool_lv, name, virtual_size,
+						tmo, create_options, cb, cbe):
+		utils.validate_lv_name(VG_VDO_INTERFACE, self.Name, name)
+
+		r = RequestEntry(tmo, VgVdo._vdo_pool_create,
+							(self.state.Uuid, self.state.lvm_id,
+							pool_lv, name,
+							round_size(virtual_size),
+							create_options), cb, cbe)
+		cfg.worker_q.put(r)
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index b819a04..8753e65 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1903,6 +1903,44 @@ class TestDbusService(unittest.TestCase):
 			vg, _, _ = self._create_vdo_pool_and_lv()
 			self.handle_return(vg.Vg.Remove(dbus.Int32(g_tmo), EOD))
 
+	def _create_vdo_pool(self):
+		pool_name = lv_n('_vdo_pool')
+		lv_name = lv_n('_vdo_data')
+		vg_proxy = self._vg_create(vg_prefix="vdo_conv_")
+		lv = self._test_lv_create(
+			vg_proxy.Vg.LvCreate,
+			(dbus.String(pool_name), dbus.UInt64(mib(4096)),
+				dbus.Array([], signature='(ott)'), dbus.Int32(g_tmo),
+				EOD), vg_proxy.Vg, LV_BASE_INT)
+		lv_obj_path = self._lookup("%s/%s" % (vg_proxy.Vg.Name, pool_name))
+		self.assertNotEqual(lv_obj_path, "/")
+
+		vdo_pool_path = self.handle_return(
+			vg_proxy.VgVdo.CreateVdoPool(
+				dbus.ObjectPath(lv.object_path), lv_name,
+				dbus.UInt64(mib(8192)),
+				dbus.Int32(g_tmo),
+				EOD))
+
+		self.assertNotEqual(vdo_pool_path, "/")
+		self.assertEqual(
+			vdo_pool_path,
+			self._lookup("%s/%s" % (vg_proxy.Vg.Name, pool_name)))
+		intf = [LV_COMMON_INT, LV_INT]
+		vdo_lv_obj_path = self._lookup("%s/%s" % (vg_proxy.Vg.Name, lv_name))
+		vdo_lv = ClientProxy(self.bus, vdo_lv_obj_path, interfaces=intf)
+		intf.append(VDOPOOL_INT)
+		vdo_pool_lv = ClientProxy(self.bus, vdo_pool_path, interfaces=intf)
+		return vg_proxy, vdo_pool_lv, vdo_lv
+
+	def test_vdo_pool_convert(self):
+		# Basic vdo sanity testing
+		if not self.vdo:
+			raise unittest.SkipTest('vdo not supported')
+
+		vg, _pool, _lv = self._create_vdo_pool()
+		self.handle_return(vg.Vg.Remove(dbus.Int32(g_tmo), EOD))
+
 	def test_vdo_pool_compression_deduplication(self):
 		if not self.vdo:
 			raise unittest.SkipTest('vdo not supported')



