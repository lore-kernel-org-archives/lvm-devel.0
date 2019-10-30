From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:32 -0400
Subject: master - lvmdbusd: Add VgVdo class & assoc. interface
Message-ID: <201910301544.x9UFiWMF016757@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6204955347b2d57ded9e6385aa5118392e182a48
Commit:        6204955347b2d57ded9e6385aa5118392e182a48
Parent:        9d2ef05c5d0b57139d8405a2af947091f2c13942
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Oct 7 16:58:10 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Add VgVdo class & assoc. interface

When VDO support is available we will create VG object instances
which will allow the API user to create VDO pool LVs.
---
 daemons/lvmdbusd/cfg.py        |    1 +
 daemons/lvmdbusd/cmdhandler.py |   20 +++++++++++++++++
 daemons/lvmdbusd/vg.py         |   46 +++++++++++++++++++++++++++++++++++++--
 3 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 13143ef..b11d9f8 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -47,6 +47,7 @@ BUS_NAME = os.getenv('LVM_DBUS_NAME', 'com.redhat.lvmdbus1')
 BASE_INTERFACE = 'com.redhat.lvmdbus1'
 PV_INTERFACE = BASE_INTERFACE + '.Pv'
 VG_INTERFACE = BASE_INTERFACE + '.Vg'
+VG_VDO_INTERFACE = BASE_INTERFACE + '.VgVdo'
 LV_INTERFACE = BASE_INTERFACE + '.Lv'
 LV_COMMON_INTERFACE = BASE_INTERFACE + '.LvCommon'
 THIN_POOL_INTERFACE = BASE_INTERFACE + '.ThinPool'
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index f7f6acd..137027b 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -388,6 +388,16 @@ def vg_create_thin_pool(md_full_name, data_full_name, create_options):
 	return call(cmd)
 
 
+def vg_create_vdo_pool_lv_and_lv(vg_name, pool_name, lv_name, data_size,
+									virtual_size, create_options):
+	cmd = ['lvcreate']
+	cmd.extend(options_to_cli_args(create_options))
+	cmd.extend(['-y', '--type', 'vdo', '-n', lv_name,
+				'-L', '%dB' % data_size, '-V', '%dB' % virtual_size,
+				"%s/%s" % (vg_name, pool_name)])
+	return call(cmd)
+
+
 def lv_remove(lv_path, remove_options):
 	cmd = ['lvremove']
 	cmd.extend(options_to_cli_args(remove_options))
@@ -462,6 +472,16 @@ def supports_json():
 	return False
 
 
+def supports_vdo():
+	cmd = ['segtypes']
+	rc, out, err = call(cmd)
+	if rc == 0:
+		if "vdo" in out:
+			log_debug("We have VDO support")
+			return True
+	return False
+
+
 def lvm_full_report_json():
 	pv_columns = ['pv_name', 'pv_uuid', 'pv_fmt', 'pv_size', 'pv_free',
 					'pv_used', 'dev_size', 'pv_mda_size', 'pv_mda_free',
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index d022ff1..789626c 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -14,7 +14,7 @@ from .utils import pv_obj_path_generate, vg_obj_path_generate, n, \
 	_handle_execute
 import dbus
 from . import cfg
-from .cfg import VG_INTERFACE
+from .cfg import VG_INTERFACE, VG_VDO_INTERFACE
 from . import cmdhandler
 from .request import RequestEntry
 from .loader import common
@@ -47,7 +47,7 @@ def vgs_state_retrieve(selection, cache_refresh=True):
 
 def load_vgs(vg_specific=None, object_path=None, refresh=False,
 		emit_signal=False, cache_refresh=True):
-	return common(vgs_state_retrieve, (Vg,), vg_specific, object_path, refresh,
+	return common(vgs_state_retrieve, (Vg, VgVdo, ), vg_specific, object_path, refresh,
 					emit_signal, cache_refresh)
 
 
@@ -99,7 +99,11 @@ class VgState(State):
 		if not path:
 			path = cfg.om.get_object_path_by_uuid_lvm_id(
 				self.Uuid, self.internal_name, vg_obj_path_generate)
-		return Vg(path, self)
+
+		if cfg.vdo_support:
+			return VgVdo(path, self)
+		else:
+			return Vg(path, self)
 
 	# noinspection PyMethodMayBeStatic
 	def creation_signature(self):
@@ -773,3 +777,39 @@ class Vg(AutomatedProperties):
 	@property
 	def Clustered(self):
 		return self._attribute(5, 'c')
+
+
+class VgVdo(Vg):
+
+	# noinspection PyUnusedLocal,PyPep8Naming
+	def __init__(self, object_path, object_state):
+		super(VgVdo, self).__init__(object_path, vgs_state_retrieve)
+		self.set_interface(VG_VDO_INTERFACE)
+		self._object_path = object_path
+		self.state = object_state
+
+	@staticmethod
+	def _lv_vdo_pool_create_with_lv(uuid, vg_name, pool_name, lv_name,
+									data_size, virtual_size, create_options):
+		Vg.validate_dbus_object(uuid, vg_name)
+		Vg.handle_execute(*cmdhandler.vg_create_vdo_pool_lv_and_lv(
+			vg_name, pool_name, lv_name, data_size, virtual_size,
+			create_options))
+		return Vg.fetch_new_lv(vg_name, pool_name)
+
+	@dbus.service.method(
+		dbus_interface=VG_VDO_INTERFACE,
+		in_signature='ssttia{sv}',
+		out_signature='(oo)',
+		async_callbacks=('cb', 'cbe'))
+	def CreateVdoPoolandLv(self, pool_name, lv_name, data_size, virtual_size,
+							tmo, create_options, cb, cbe):
+		utils.validate_lv_name(VG_VDO_INTERFACE, self.Name, pool_name)
+		utils.validate_lv_name(VG_VDO_INTERFACE, self.Name, lv_name)
+
+		r = RequestEntry(tmo, VgVdo._lv_vdo_pool_create_with_lv,
+							(self.state.Uuid, self.state.lvm_id,
+							pool_name, lv_name, round_size(data_size),
+							round_size(virtual_size),
+							create_options), cb, cbe)
+		cfg.worker_q.put(r)


