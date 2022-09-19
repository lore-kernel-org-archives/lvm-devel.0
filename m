From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:18 +0000 (GMT)
Subject: main - lvmdbusd: WS, imports, grammar
Message-ID: <20220919155818.513AF3858437@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29189948732b4385fa053c94ac2dc31e3cfc3dfa
Commit:        29189948732b4385fa053c94ac2dc31e3cfc3dfa
Parent:        b0c7220dbbb38c54f3d47afc9748b53438bc154e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Aug 25 08:33:50 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: WS, imports, grammar

---
 daemons/lvmdbusd/automatedproperties.py |  1 -
 daemons/lvmdbusd/background.py          |  5 +----
 daemons/lvmdbusd/cmdhandler.py          |  2 --
 daemons/lvmdbusd/lv.py                  | 38 ++++++++++++++++-----------------
 daemons/lvmdbusd/lvm_shell_proxy.py.in  |  2 +-
 daemons/lvmdbusd/lvmdb.py.in            |  2 +-
 6 files changed, 22 insertions(+), 28 deletions(-)

diff --git a/daemons/lvmdbusd/automatedproperties.py b/daemons/lvmdbusd/automatedproperties.py
index d9f2c5e9f..be41502bd 100644
--- a/daemons/lvmdbusd/automatedproperties.py
+++ b/daemons/lvmdbusd/automatedproperties.py
@@ -88,7 +88,6 @@ class AutomatedProperties(dbus.service.Object):
 			cb, cbe, False)
 		cfg.worker_q.put(r)
 
-
 	@staticmethod
 	def _get_all_prop(obj, interface_name):
 		if interface_name in obj.interface(True):
diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 21617c47a..50b19c817 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -7,16 +7,13 @@
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
-import subprocess
 from . import cfg
 from .cmdhandler import options_to_cli_args, LvmExecutionMeta, call_lvm
 import dbus
-from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug,\
-					mt_async_call
+from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
 from .request import RequestEntry
 import threading
 import time
-import traceback
 
 
 def pv_move_lv_cmd(move_options, lv_full_name,
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 7605f8298..11cd0f0cd 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -26,7 +26,6 @@ try:
 except ImportError:
 	import json
 
-SEP = '{|}'
 
 total_time = 0.0
 total_count = 0
@@ -177,7 +176,6 @@ def call_lvm(command, debug=False, line_cb=None,
 		return -errno.EINTR, "", "operation interrupted"
 
 
-
 # The actual method which gets called to invoke the lvm command, can vary
 # from forking a new process to using lvm shell
 _t_call = call_lvm
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index edfdd0d30..349ada006 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -274,15 +274,15 @@ class LvStateVdo(LvState):
 					MetaDataPercent, CopyPercent, SyncPercent,
 					MetaDataSizeBytes, move_pv, move_pv_uuid,
 					vdo_operating_mode, vdo_compression_state, vdo_index_state,
-					vdo_used_size,vdo_saving_percent,vdo_compression,
-					vdo_deduplication,vdo_use_metadata_hints,
-					vdo_minimum_io_size,vdo_block_map_cache_size,
-					vdo_block_map_era_length,vdo_use_sparse_index,
-					vdo_index_memory_size,vdo_slab_size,vdo_ack_threads,
-					vdo_bio_threads,vdo_bio_rotation,vdo_cpu_threads,
-					vdo_hash_zone_threads,vdo_logical_threads,
-					vdo_physical_threads,vdo_max_discard,
-					vdo_write_policy,vdo_header_size):
+					vdo_used_size, vdo_saving_percent, vdo_compression,
+					vdo_deduplication, vdo_use_metadata_hints,
+					vdo_minimum_io_size, vdo_block_map_cache_size,
+					vdo_block_map_era_length, vdo_use_sparse_index,
+					vdo_index_memory_size, vdo_slab_size, vdo_ack_threads,
+					vdo_bio_threads, vdo_bio_rotation, vdo_cpu_threads,
+					vdo_hash_zone_threads, vdo_logical_threads,
+					vdo_physical_threads, vdo_max_discard,
+					vdo_write_policy, vdo_header_size):
 		super(LvStateVdo, self).__init__(Uuid, Name, Path, SizeBytes,
 					vg_name, vg_uuid, pool_lv_uuid, PoolLv,
 					origin_uuid, OriginLv, DataPercent, Attr, Tags, active,
@@ -595,7 +595,7 @@ class Lv(LvCommon):
 				optional_size = space + 512 - remainder
 
 		LvCommon.handle_execute(*cmdhandler.vg_lv_snapshot(
-			lv_name, snapshot_options,name, optional_size))
+			lv_name, snapshot_options, name, optional_size))
 		full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
 		return cfg.om.get_object_path_by_lvm_id(full_name)
 
@@ -635,7 +635,7 @@ class Lv(LvCommon):
 
 		size_change = new_size_bytes - dbo.SizeBytes
 		LvCommon.handle_execute(*cmdhandler.lv_resize(
-			dbo.lvm_id, size_change,pv_dests, resize_options))
+			dbo.lvm_id, size_change, pv_dests, resize_options))
 		return "/"
 
 	@dbus.service.method(
@@ -845,10 +845,10 @@ class LvVdoPool(Lv):
 		cfg.worker_q.put(r)
 
 	@dbus.service.method(
-	dbus_interface=VDO_POOL_INTERFACE,
-	in_signature='ia{sv}',
-	out_signature='o',
-	async_callbacks=('cb', 'cbe'))
+		dbus_interface=VDO_POOL_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
 	def DisableCompression(self, tmo, comp_options, cb, cbe):
 		r = RequestEntry(
 			tmo, LvVdoPool._enable_disable_compression,
@@ -878,10 +878,10 @@ class LvVdoPool(Lv):
 		cfg.worker_q.put(r)
 
 	@dbus.service.method(
-	dbus_interface=VDO_POOL_INTERFACE,
-	in_signature='ia{sv}',
-	out_signature='o',
-	async_callbacks=('cb', 'cbe'))
+		dbus_interface=VDO_POOL_INTERFACE,
+		in_signature='ia{sv}',
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
 	def DisableDeduplication(self, tmo, dedup_options, cb, cbe):
 		r = RequestEntry(
 			tmo, LvVdoPool._enable_disable_deduplication,
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index ebab57e97..66c90c38a 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -166,7 +166,7 @@ class LVMShellProxy(object):
 
 	def get_last_log(self):
 		self._write_cmd('lastlog\n')
-		report_json= self._read_response()[1]
+		report_json = self._read_response()[1]
 		return LVMShellProxy.get_error_msg(report_json)
 
 	@staticmethod
diff --git a/daemons/lvmdbusd/lvmdb.py.in b/daemons/lvmdbusd/lvmdb.py.in
index d462e0cf8..2346d01e9 100644
--- a/daemons/lvmdbusd/lvmdb.py.in
+++ b/daemons/lvmdbusd/lvmdb.py.in
@@ -58,7 +58,7 @@ class DataStore(object):
 		c_lookup = {}
 		c_pvs_in_vgs = {}
 
-		# Each item item in the report is a collection of information pertaining
+		# Each item in the report is a collection of information pertaining
 		# to the vg
 		for r in _all['report']:
 			tmp_pv = []

