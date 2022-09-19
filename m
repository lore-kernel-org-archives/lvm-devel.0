From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:27 +0000 (GMT)
Subject: main - lvmdbusd: Re-work error handling
Message-ID: <20220919155827.697543858287@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d42bdb07def72d68c05241823979b28952978c05
Commit:        d42bdb07def72d68c05241823979b28952978c05
Parent:        cb32b0a87f9c2c5b9d79f02e59e3925d8350c70b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 31 11:20:49 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Re-work error handling

Introduce an exception which is used for known existing issues with lvm.
This is used to distinguish between errors between lvm itself and lvmdbusd.
In the case of lvm bugs, when we simply retry the operation we will log
very little.  Otherwise, we will dump a full traceback for investigation
when we do the retry.
---
 daemons/lvmdbusd/cmdhandler.py |   4 +-
 daemons/lvmdbusd/fetch.py      |  33 ++++++----
 daemons/lvmdbusd/lv.py         | 133 ++++++++++++++++++++++-------------------
 daemons/lvmdbusd/pv.py         |  29 +++++----
 daemons/lvmdbusd/utils.py      |   9 +++
 daemons/lvmdbusd/vg.py         |  32 ++++++----
 6 files changed, 140 insertions(+), 100 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index fd6ecf326..7a349e87e 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -17,7 +17,7 @@ import os
 
 from lvmdbusd import cfg
 from lvmdbusd.utils import pv_dest_ranges, log_debug, log_error, add_no_notify,\
-			make_non_block, read_decoded, extract_stack_trace
+			make_non_block, read_decoded, extract_stack_trace, LvmBug
 from lvmdbusd.lvm_shell_proxy import LVMShellProxy
 
 try:
@@ -628,7 +628,7 @@ def lvm_full_report_json():
 							(str(joe), out))
 				raise joe
 
-	return None
+	raise LvmBug("'fullreport' exited with code '%d'" % rc)
 
 
 def pv_resize(device, size_bytes, create_options):
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index d1759f7dd..dc527be36 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -11,11 +11,10 @@ from .pv import load_pvs
 from .vg import load_vgs
 from .lv import load_lvs
 from . import cfg
-from .utils import MThreadRunner, log_debug, log_error
+from .utils import MThreadRunner, log_debug, log_error, LvmBug, extract_stack_trace
 import threading
 import queue
 import time
-import traceback
 
 
 def _main_thread_load(refresh=True, emit_signal=True):
@@ -160,6 +159,20 @@ class StateUpdate(object):
 			except queue.Empty:
 				pass
 
+		def _handle_error():
+			nonlocal exception_count
+			exception_count += 1
+
+			if exception_count >= 5:
+				log_error("Too many errors in update_thread, exiting daemon")
+				cfg.debug.dump()
+				cfg.flightrecorder.dump()
+				bailing(e)
+				cfg.exit_daemon()
+			else:
+				# Slow things down when encountering errors
+				time.sleep(1)
+
 		while cfg.run.value != 0:
 			# noinspection PyBroadException
 			try:
@@ -191,18 +204,12 @@ class StateUpdate(object):
 				pass
 			except SystemExit:
 				break
+			except LvmBug as bug:
+				log_error(str(bug))
+				_handle_error()
 			except Exception as e:
-				exception_count += 1
-				if exception_count >= 5:
-					st = traceback.format_exc()
-					log_error("Too many errors in update_thread, exiting daemon (last exception reported): \n %s" % st)
-					cfg.debug.dump()
-					cfg.flightrecorder.dump()
-					bailing(e)
-					cfg.exit_daemon()
-				else:
-					# Slow things down when encountering errors
-					time.sleep(1)
+				log_error("update_thread: \n%s" % extract_stack_trace(e))
+				_handle_error()
 
 		# Make sure to unblock any that may be waiting before we exit this thread
 		# otherwise they hang forever ...
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 8c55f5ffd..134843346 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -10,7 +10,7 @@
 from .automatedproperties import AutomatedProperties
 
 from . import utils
-from .utils import vg_obj_path_generate, log_error, _handle_execute
+from .utils import vg_obj_path_generate, log_error, _handle_execute, LvmBug
 import dbus
 from . import cmdhandler
 from . import cfg
@@ -71,67 +71,76 @@ def lvs_state_retrieve(selection, cache_refresh=True):
 	# don't have information available yet.
 	lvs = sorted(cfg.db.fetch_lvs(selection), key=get_key)
 
-	for l in lvs:
-		if cfg.vdo_support:
-			rc.append(LvStateVdo(
-				l['lv_uuid'], l['lv_name'],
-				l['lv_path'], n(l['lv_size']),
-				l['vg_name'],
-				l['vg_uuid'], l['pool_lv_uuid'],
-				l['pool_lv'], l['origin_uuid'], l['origin'],
-				n32(l['data_percent']), l['lv_attr'],
-				l['lv_tags'], l['lv_active'], l['data_lv'],
-				l['metadata_lv'], l['segtype'], l['lv_role'],
-				l['lv_layout'],
-				n32(l['snap_percent']),
-				n32(l['metadata_percent']),
-				n32(l['copy_percent']),
-				n32(l['sync_percent']),
-				n(l['lv_metadata_size']),
-				l['move_pv'],
-				l['move_pv_uuid'],
-				l['vdo_operating_mode'],
-				l['vdo_compression_state'],
-				l['vdo_index_state'],
-				n(l['vdo_used_size']),
-				d(l['vdo_saving_percent']),
-				l['vdo_compression'],
-				l['vdo_deduplication'],
-				l['vdo_use_metadata_hints'],
-				n32(l['vdo_minimum_io_size']),
-				n(l['vdo_block_map_cache_size']),
-				n32(l['vdo_block_map_era_length']),
-				l['vdo_use_sparse_index'],
-				n(l['vdo_index_memory_size']),
-				n(l['vdo_slab_size']),
-				n32(l['vdo_ack_threads']),
-				n32(l['vdo_bio_threads']),
-				n32(l['vdo_bio_rotation']),
-				n32(l['vdo_cpu_threads']),
-				n32(l['vdo_hash_zone_threads']),
-				n32(l['vdo_logical_threads']),
-				n32(l['vdo_physical_threads']),
-				n32(l['vdo_max_discard']),
-				l['vdo_write_policy'],
-				n32(l['vdo_header_size'])))
-		else:
-			rc.append(LvState(
-				l['lv_uuid'], l['lv_name'],
-				l['lv_path'], n(l['lv_size']),
-				l['vg_name'],
-				l['vg_uuid'], l['pool_lv_uuid'],
-				l['pool_lv'], l['origin_uuid'], l['origin'],
-				n32(l['data_percent']), l['lv_attr'],
-				l['lv_tags'], l['lv_active'], l['data_lv'],
-				l['metadata_lv'], l['segtype'], l['lv_role'],
-				l['lv_layout'],
-				n32(l['snap_percent']),
-				n32(l['metadata_percent']),
-				n32(l['copy_percent']),
-				n32(l['sync_percent']),
-				n(l['lv_metadata_size']),
-				l['move_pv'],
-				l['move_pv_uuid']))
+	try:
+		for l in lvs:
+			if cfg.vdo_support:
+				rc.append(LvStateVdo(
+					l['lv_uuid'], l['lv_name'],
+					l['lv_path'], n(l['lv_size']),
+					l['vg_name'],
+					l['vg_uuid'], l['pool_lv_uuid'],
+					l['pool_lv'], l['origin_uuid'], l['origin'],
+					n32(l['data_percent']), l['lv_attr'],
+					l['lv_tags'], l['lv_active'], l['data_lv'],
+					l['metadata_lv'], l['segtype'], l['lv_role'],
+					l['lv_layout'],
+					n32(l['snap_percent']),
+					n32(l['metadata_percent']),
+					n32(l['copy_percent']),
+					n32(l['sync_percent']),
+					n(l['lv_metadata_size']),
+					l['move_pv'],
+					l['move_pv_uuid'],
+					l['vdo_operating_mode'],
+					l['vdo_compression_state'],
+					l['vdo_index_state'],
+					n(l['vdo_used_size']),
+					d(l['vdo_saving_percent']),
+					l['vdo_compression'],
+					l['vdo_deduplication'],
+					l['vdo_use_metadata_hints'],
+					n32(l['vdo_minimum_io_size']),
+					n(l['vdo_block_map_cache_size']),
+					n32(l['vdo_block_map_era_length']),
+					l['vdo_use_sparse_index'],
+					n(l['vdo_index_memory_size']),
+					n(l['vdo_slab_size']),
+					n32(l['vdo_ack_threads']),
+					n32(l['vdo_bio_threads']),
+					n32(l['vdo_bio_rotation']),
+					n32(l['vdo_cpu_threads']),
+					n32(l['vdo_hash_zone_threads']),
+					n32(l['vdo_logical_threads']),
+					n32(l['vdo_physical_threads']),
+					n32(l['vdo_max_discard']),
+					l['vdo_write_policy'],
+					n32(l['vdo_header_size'])))
+			else:
+				rc.append(LvState(
+					l['lv_uuid'], l['lv_name'],
+					l['lv_path'], n(l['lv_size']),
+					l['vg_name'],
+					l['vg_uuid'], l['pool_lv_uuid'],
+					l['pool_lv'], l['origin_uuid'], l['origin'],
+					n32(l['data_percent']), l['lv_attr'],
+					l['lv_tags'], l['lv_active'], l['data_lv'],
+					l['metadata_lv'], l['segtype'], l['lv_role'],
+					l['lv_layout'],
+					n32(l['snap_percent']),
+					n32(l['metadata_percent']),
+					n32(l['copy_percent']),
+					n32(l['sync_percent']),
+					n(l['lv_metadata_size']),
+					l['move_pv'],
+					l['move_pv_uuid']))
+	except KeyError as ke:
+		# Sometimes lvm omits returning one of the keys we requested.
+		key = ke.args[0]
+		if key.startswith("lv_") or key.startswith("vg_") or key.startswith("pool_") or \
+			key.endswith("_percent") or key.startswith("move_") or key.startswith("vdo_") or \
+			key in ["origin_uuid", "segtype", "origin", "data_lv", "metadata_lv"]:
+			raise LvmBug("missing JSON key: '%s'" % key)
+		raise ke
 	return rc
 
 
diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index 8a25cbf5d..2037f9c91 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -18,7 +18,7 @@ from .utils import vg_obj_path_generate, n, pv_obj_path_generate, \
 from .loader import common
 from .request import RequestEntry
 from .state import State
-from .utils import round_size
+from .utils import round_size, LvmBug
 
 
 # noinspection PyUnusedLocal
@@ -28,16 +28,23 @@ def pvs_state_retrieve(selection, cache_refresh=True):
 	if cache_refresh:
 		cfg.db.refresh()
 
-	for p in cfg.db.fetch_pvs(selection):
-		rc.append(
-			PvState(
-				p["pv_name"], p["pv_uuid"], p["pv_name"],
-				p["pv_fmt"], n(p["pv_size"]), n(p["pv_free"]),
-				n(p["pv_used"]), n(p["dev_size"]), n(p["pv_mda_size"]),
-				n(p["pv_mda_free"]), int(p["pv_ba_start"]),
-				n(p["pv_ba_size"]), n(p["pe_start"]),
-				int(p["pv_pe_count"]), int(p["pv_pe_alloc_count"]),
-				p["pv_attr"], p["pv_tags"], p["vg_name"], p["vg_uuid"]))
+	try:
+		for p in cfg.db.fetch_pvs(selection):
+			rc.append(
+				PvState(
+					p["pv_name"], p["pv_uuid"], p["pv_name"],
+					p["pv_fmt"], n(p["pv_size"]), n(p["pv_free"]),
+					n(p["pv_used"]), n(p["dev_size"]), n(p["pv_mda_size"]),
+					n(p["pv_mda_free"]), int(p["pv_ba_start"]),
+					n(p["pv_ba_size"]), n(p["pe_start"]),
+					int(p["pv_pe_count"]), int(p["pv_pe_alloc_count"]),
+					p["pv_attr"], p["pv_tags"], p["vg_name"], p["vg_uuid"]))
+	except KeyError as ke:
+		# Sometimes lvm omits returning one of the keys we requested.
+		key = ke.args[0]
+		if key.startswith("pv") or key.startswith("vg") or (key in ['dev_size', 'pe_start']):
+			raise LvmBug("missing JSON key: '%s'" % key)
+		raise ke
 	return rc
 
 
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index d5c37de46..6c7a25f8d 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -768,3 +768,12 @@ def extract_stack_trace(exception):
 	return ''.join(traceback.format_exception(None, exception, exception.__traceback__))
 
 
+class LvmBug(RuntimeError):
+	"""
+	Things that are clearly a bug with lvm itself.
+	"""
+	def __init__(self, msg):
+		super().__init__(msg)
+
+	def __str__(self):
+		return "lvm bug encountered: %s" % ' '.join(self.args)
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 51fd07e8c..928146fdb 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -20,7 +20,7 @@ from .request import RequestEntry
 from .loader import common
 from .state import State
 from . import background
-from .utils import round_size, mt_remove_dbus_objects
+from .utils import round_size, mt_remove_dbus_objects, LvmBug
 from .job import JobState
 
 
@@ -31,17 +31,25 @@ def vgs_state_retrieve(selection, cache_refresh=True):
 	if cache_refresh:
 		cfg.db.refresh()
 
-	for v in cfg.db.fetch_vgs(selection):
-		rc.append(
-			VgState(
-				v['vg_uuid'], v['vg_name'], v['vg_fmt'], n(v['vg_size']),
-				n(v['vg_free']), v['vg_sysid'], n(v['vg_extent_size']),
-				n(v['vg_extent_count']), n(v['vg_free_count']),
-				v['vg_profile'], n(v['max_lv']), n(v['max_pv']),
-				n(v['pv_count']), n(v['lv_count']), n(v['snap_count']),
-				n(v['vg_seqno']), n(v['vg_mda_count']),
-				n(v['vg_mda_free']), n(v['vg_mda_size']),
-				n(v['vg_mda_used_count']), v['vg_attr'], v['vg_tags']))
+	try:
+		for v in cfg.db.fetch_vgs(selection):
+			rc.append(
+				VgState(
+					v['vg_uuid'], v['vg_name'], v['vg_fmt'], n(v['vg_size']),
+					n(v['vg_free']), v['vg_sysid'], n(v['vg_extent_size']),
+					n(v['vg_extent_count']), n(v['vg_free_count']),
+					v['vg_profile'], n(v['max_lv']), n(v['max_pv']),
+					n(v['pv_count']), n(v['lv_count']), n(v['snap_count']),
+					n(v['vg_seqno']), n(v['vg_mda_count']),
+					n(v['vg_mda_free']), n(v['vg_mda_size']),
+					n(v['vg_mda_used_count']), v['vg_attr'], v['vg_tags']))
+	except KeyError as ke:
+		# Sometimes lvm omits returning one of the keys we requested.
+		key = ke.args[0]
+		if key.startswith("vg_") or key.startswith("lv_") or key.startswith("pv_") or \
+			key in ["max_lv", "max_pv", "snap_count"]:
+			raise LvmBug("missing JSON key: '%s'" % key)
+		raise ke
 	return rc
 
 

