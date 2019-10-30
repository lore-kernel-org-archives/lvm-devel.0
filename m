From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:57 -0400
Subject: master - lvmdbusd: VDO Pool LV representation
Message-ID: <201910301544.x9UFiv88016848@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5971da2c72a6fe2d83f65a7d6ea7f7bf68971dd8
Commit:        5971da2c72a6fe2d83f65a7d6ea7f7bf68971dd8
Parent:        455498f206e60c513ce36083d1f336aad11e33f8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 9 07:49:58 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: VDO Pool LV representation

VDO pool LVs are represented by a new dbus interface VgVdo.  Currently
the interface only has additional VDO properties, but when the
ability to support additional LV creation is added we can add a method
to the interface.
---
 daemons/lvmdbusd/cfg.py        |    3 +
 daemons/lvmdbusd/cmdhandler.py |   16 ++++
 daemons/lvmdbusd/lv.py         |  148 ++++++++++++++++++++++++++++++++++-----
 daemons/lvmdbusd/lvmdb.py.in   |   14 +++-
 daemons/lvmdbusd/main.py       |    2 +-
 daemons/lvmdbusd/utils.py      |   33 ++++++++-
 test/dbus/lvmdbustest.py       |    5 +-
 test/dbus/testlib.py           |    5 ++
 8 files changed, 197 insertions(+), 29 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index b11d9f8..684c2b2 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -51,6 +51,7 @@ VG_VDO_INTERFACE = BASE_INTERFACE + '.VgVdo'
 LV_INTERFACE = BASE_INTERFACE + '.Lv'
 LV_COMMON_INTERFACE = BASE_INTERFACE + '.LvCommon'
 THIN_POOL_INTERFACE = BASE_INTERFACE + '.ThinPool'
+VDO_POOL_INTERFACE = BASE_INTERFACE + '.VdoPool'
 CACHE_POOL_INTERFACE = BASE_INTERFACE + '.CachePool'
 LV_CACHED = BASE_INTERFACE + '.CachedLv'
 SNAPSHOT_INTERFACE = BASE_INTERFACE + '.Snapshot'
@@ -62,6 +63,7 @@ PV_OBJ_PATH = BASE_OBJ_PATH + '/Pv'
 VG_OBJ_PATH = BASE_OBJ_PATH + '/Vg'
 LV_OBJ_PATH = BASE_OBJ_PATH + '/Lv'
 THIN_POOL_PATH = BASE_OBJ_PATH + "/ThinPool"
+VDO_POOL_PATH = BASE_OBJ_PATH + "/VdoPool"
 CACHE_POOL_PATH = BASE_OBJ_PATH + "/CachePool"
 HIDDEN_LV_PATH = BASE_OBJ_PATH + "/HiddenLv"
 MANAGER_OBJ_PATH = BASE_OBJ_PATH + '/Manager'
@@ -72,6 +74,7 @@ pv_id = itertools.count()
 vg_id = itertools.count()
 lv_id = itertools.count()
 thin_id = itertools.count()
+vdo_id = itertools.count()
 cache_pool_id = itertools.count()
 job_id = itertools.count()
 hidden_lv = itertools.count()
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 137027b..67d4321 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -509,6 +509,22 @@ def lvm_full_report_json():
 
 	lv_seg_columns = ['seg_pe_ranges', 'segtype', 'lv_uuid']
 
+	if cfg.vdo_support:
+		lv_columns.extend(
+			['vdo_operating_mode', 'vdo_compression_state', 'vdo_index_state',
+				'vdo_used_size', 'vdo_saving_percent']
+		)
+
+		lv_seg_columns.extend(
+			['vdo_compression', 'vdo_deduplication',
+				'vdo_use_metadata_hints', 'vdo_minimum_io_size',
+				'vdo_block_map_cache_size', 'vdo_block_map_era_length',
+				'vdo_use_sparse_index', 'vdo_index_memory_size',
+				'vdo_slab_size', 'vdo_ack_threads', 'vdo_bio_threads',
+				'vdo_bio_rotation', 'vdo_cpu_threads', 'vdo_hash_zone_threads',
+				'vdo_logical_threads', 'vdo_physical_threads',
+				'vdo_max_discard', 'vdo_write_policy', 'vdo_header_size'])
+
 	cmd = _dc('fullreport', [
 		'-a',		# Need hidden too
 		'--configreport', 'pv', '-o', ','.join(pv_columns),
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 9290c19..3018749 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -15,9 +15,9 @@ import dbus
 from . import cmdhandler
 from . import cfg
 from .cfg import LV_INTERFACE, THIN_POOL_INTERFACE, SNAPSHOT_INTERFACE, \
-	LV_COMMON_INTERFACE, CACHE_POOL_INTERFACE, LV_CACHED
+	LV_COMMON_INTERFACE, CACHE_POOL_INTERFACE, LV_CACHED, VDO_POOL_INTERFACE
 from .request import RequestEntry
-from .utils import n, n32
+from .utils import n, n32, d
 from .loader import common
 from .state import State
 from . import background
@@ -74,23 +74,66 @@ def lvs_state_retrieve(selection, cache_refresh=True):
 	lvs = sorted(cfg.db.fetch_lvs(selection), key=get_key)
 
 	for l in lvs:
-		rc.append(LvState(
-			l['lv_uuid'], l['lv_name'],
-			l['lv_path'], n(l['lv_size']),
-			l['vg_name'],
-			l['vg_uuid'], l['pool_lv_uuid'],
-			l['pool_lv'], l['origin_uuid'], l['origin'],
-			n32(l['data_percent']), l['lv_attr'],
-			l['lv_tags'], l['lv_active'], l['data_lv'],
-			l['metadata_lv'], l['segtype'], l['lv_role'],
-			l['lv_layout'],
-			n32(l['snap_percent']),
-			n32(l['metadata_percent']),
-			n32(l['copy_percent']),
-			n32(l['sync_percent']),
-			n(l['lv_metadata_size']),
-			l['move_pv'],
-			l['move_pv_uuid']))
+		if cfg.vdo_support:
+			rc.append(LvStateVdo(
+				l['lv_uuid'], l['lv_name'],
+				l['lv_path'], n(l['lv_size']),
+				l['vg_name'],
+				l['vg_uuid'], l['pool_lv_uuid'],
+				l['pool_lv'], l['origin_uuid'], l['origin'],
+				n32(l['data_percent']), l['lv_attr'],
+				l['lv_tags'], l['lv_active'], l['data_lv'],
+				l['metadata_lv'], l['segtype'], l['lv_role'],
+				l['lv_layout'],
+				n32(l['snap_percent']),
+				n32(l['metadata_percent']),
+				n32(l['copy_percent']),
+				n32(l['sync_percent']),
+				n(l['lv_metadata_size']),
+				l['move_pv'],
+				l['move_pv_uuid'],
+				l['vdo_operating_mode'],
+				l['vdo_compression_state'],
+				l['vdo_index_state'],
+				n(l['vdo_used_size']),
+				d(l['vdo_saving_percent']),
+				l['vdo_compression'],
+				l['vdo_deduplication'],
+				l['vdo_use_metadata_hints'],
+				n32(l['vdo_minimum_io_size']),
+				n(l['vdo_block_map_cache_size']),
+				n32(l['vdo_block_map_era_length']),
+				l['vdo_use_sparse_index'],
+				n(l['vdo_index_memory_size']),
+				n(l['vdo_slab_size']),
+				n32(l['vdo_ack_threads']),
+				n32(l['vdo_bio_threads']),
+				n32(l['vdo_bio_rotation']),
+				n32(l['vdo_cpu_threads']),
+				n32(l['vdo_hash_zone_threads']),
+				n32(l['vdo_logical_threads']),
+				n32(l['vdo_physical_threads']),
+				n32(l['vdo_max_discard']),
+				l['vdo_write_policy'],
+				n32(l['vdo_header_size'])))
+		else:
+			rc.append(LvState(
+				l['lv_uuid'], l['lv_name'],
+				l['lv_path'], n(l['lv_size']),
+				l['vg_name'],
+				l['vg_uuid'], l['pool_lv_uuid'],
+				l['pool_lv'], l['origin_uuid'], l['origin'],
+				n32(l['data_percent']), l['lv_attr'],
+				l['lv_tags'], l['lv_active'], l['data_lv'],
+				l['metadata_lv'], l['segtype'], l['lv_role'],
+				l['lv_layout'],
+				n32(l['snap_percent']),
+				n32(l['metadata_percent']),
+				n32(l['copy_percent']),
+				n32(l['sync_percent']),
+				n(l['lv_metadata_size']),
+				l['move_pv'],
+				l['move_pv_uuid']))
 	return rc
 
 
@@ -194,6 +237,8 @@ class LvState(State):
 	def _object_type_create(self):
 		if self.Attr[0] == 't':
 			return LvThinPool
+		elif self.Attr[0] == 'd':
+			return LvVdoPool
 		elif self.Attr[0] == 'C':
 			if 'pool' in self.layout:
 				return LvCachePool
@@ -220,6 +265,34 @@ class LvState(State):
 		return (klass, path_method)
 
 
+class LvStateVdo(LvState):
+
+	def __init__(self, Uuid, Name, Path, SizeBytes,
+					vg_name, vg_uuid, pool_lv_uuid, PoolLv,
+					origin_uuid, OriginLv, DataPercent, Attr, Tags, active,
+					data_lv, metadata_lv, segtypes, role, layout, SnapPercent,
+					MetaDataPercent, CopyPercent, SyncPercent,
+					MetaDataSizeBytes, move_pv, move_pv_uuid,
+					vdo_operating_mode, vdo_compression_state, vdo_index_state,
+					vdo_used_size,vdo_saving_percent,vdo_compression,
+					vdo_deduplication,vdo_use_metadata_hints,
+					vdo_minimum_io_size,vdo_block_map_cache_size,
+					vdo_block_map_era_length,vdo_use_sparse_index,
+					vdo_index_memory_size,vdo_slab_size,vdo_ack_threads,
+					vdo_bio_threads,vdo_bio_rotation,vdo_cpu_threads,
+					vdo_hash_zone_threads,vdo_logical_threads,
+					vdo_physical_threads,vdo_max_discard,
+					vdo_write_policy,vdo_header_size):
+		super(LvStateVdo, self).__init__(Uuid, Name, Path, SizeBytes,
+					vg_name, vg_uuid, pool_lv_uuid, PoolLv,
+					origin_uuid, OriginLv, DataPercent, Attr, Tags, active,
+					data_lv, metadata_lv, segtypes, role, layout, SnapPercent,
+					MetaDataPercent, CopyPercent, SyncPercent,
+					MetaDataSizeBytes, move_pv, move_pv_uuid)
+
+		utils.init_class_from_arguments(self, "vdo_", snake_to_pascal=True)
+
+
 # noinspection PyPep8Naming
 @utils.dbus_property(LV_COMMON_INTERFACE, 'Uuid', 's')
 @utils.dbus_property(LV_COMMON_INTERFACE, 'Name', 's')
@@ -670,6 +743,43 @@ class Lv(LvCommon):
 			cb, cbe, return_tuple=False)
 		cfg.worker_q.put(r)
 
+# noinspection PyPep8Naming
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'OperatingMode', 's')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'CompressionState', 's')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'IndexState', 's')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'UsedSize', 't')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'SavingPercent', 'd')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'Compression', 's')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'Deduplication', 's')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'UseMetadataHints', 's')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'MinimumIoSize', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'BlockMapCacheSize', "t")
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'BlockMapEraLength', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'UseSparseIndex', 's')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'IndexMemorySize', 't')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'SlabSize', 't')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'AckThreads', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'BioThreads', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'BioRotation', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'CpuThreads', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'HashZoneThreads', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'LogicalThreads', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'PhysicalThreads', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'MaxDiscard', 'u')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'WritePolicy', 's')
+ at utils.dbus_property(VDO_POOL_INTERFACE, 'HeaderSize', 'u')
+class LvVdoPool(Lv):
+	_DataLv_meta = ("o", VDO_POOL_INTERFACE)
+
+	def __init__(self, object_path, object_state):
+		super(LvVdoPool, self).__init__(object_path, object_state)
+		self.set_interface(VDO_POOL_INTERFACE)
+		self._data_lv, _ = self._get_data_meta()
+
+	@property
+	def DataLv(self):
+		return dbus.ObjectPath(self._data_lv)
+
 
 # noinspection PyPep8Naming
 class LvThinPool(Lv):
diff --git a/daemons/lvmdbusd/lvmdb.py.in b/daemons/lvmdbusd/lvmdb.py.in
index 0155d90..2e7aba9 100644
--- a/daemons/lvmdbusd/lvmdb.py.in
+++ b/daemons/lvmdbusd/lvmdb.py.in
@@ -20,7 +20,7 @@ from lvmdbusd.utils import log_debug, log_error
 
 
 class DataStore(object):
-	def __init__(self, usejson=True):
+	def __init__(self, usejson=True, vdo_support=False):
 		self.pvs = {}
 		self.vgs = {}
 		self.lvs = {}
@@ -43,6 +43,8 @@ class DataStore(object):
 		else:
 			self.json = usejson
 
+		self.vdo_support = vdo_support
+
 	@staticmethod
 	def _insert_record(table, key, record, allowed_multiple):
 		if key in table:
@@ -241,8 +243,7 @@ class DataStore(object):
 
 		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
 
-	@staticmethod
-	def _parse_lvs_json(_all):
+	def _parse_lvs_json(self, _all):
 
 		c_lvs = OrderedDict()
 		c_lv_full_lookup = {}
@@ -262,8 +263,13 @@ class DataStore(object):
 				if 'seg' in r:
 					for s in r['seg']:
 						r = c_lvs[s['lv_uuid']]
-						r.setdefault('seg_pe_ranges', []).append(s['seg_pe_ranges'])
+						r.setdefault('seg_pe_ranges', []).\
+							append(s['seg_pe_ranges'])
 						r.setdefault('segtype', []).append(s['segtype'])
+						if self.vdo_support:
+							for seg_key, seg_val in s.items():
+								if seg_key.startswith("vdo_"):
+									r[seg_key] = seg_val
 
 		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
 
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index c128535..9988143 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -155,7 +155,7 @@ def main():
 	cfg.om = Lvm(BASE_OBJ_PATH)
 	cfg.om.register_object(Manager(MANAGER_OBJ_PATH))
 
-	cfg.db = lvmdb.DataStore(cfg.args.use_json)
+	cfg.db = lvmdb.DataStore(cfg.args.use_json, cfg.vdo_support)
 
 	# Using a thread to process requests, we cannot hang the dbus library
 	# thread that is handling the dbus interface
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 40b8a68..66dfbd6 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -66,8 +66,20 @@ def n32(v):
 	return int(float(v))
 
 
+ at rtype(dbus.Double)
+def d(v):
+	if not v:
+		return 0.0
+	return float(v)
+
+
+def _snake_to_pascal(s):
+	return ''.join(x.title() for x in s.split('_'))
+
+
 # noinspection PyProtectedMember
-def init_class_from_arguments(obj_instance):
+def init_class_from_arguments(
+		obj_instance, begin_suffix=None, snake_to_pascal=False):
 	for k, v in list(sys._getframe(1).f_locals.items()):
 		if k != 'self':
 			nt = k
@@ -78,8 +90,17 @@ def init_class_from_arguments(obj_instance):
 			cur = getattr(obj_instance, nt, v)
 
 			# print 'Init class %s = %s' % (nt, str(v))
-			if not (cur and len(str(cur)) and (v is None or len(str(v))) == 0):
-				setattr(obj_instance, nt, v)
+			if not (cur and len(str(cur)) and (v is None or len(str(v))) == 0)\
+					and (begin_suffix is None or nt.startswith(begin_suffix)):
+
+				if begin_suffix and nt.startswith(begin_suffix):
+					name = nt[len(begin_suffix):]
+					if snake_to_pascal:
+						name = _snake_to_pascal(name)
+
+					setattr(obj_instance, name, v)
+				else:
+					setattr(obj_instance, nt, v)
 
 
 def get_properties(f):
@@ -347,6 +368,8 @@ def lv_object_path_method(name, meta):
 		return _hidden_lv_obj_path_generate
 	elif meta[0][0] == 't':
 		return _thin_pool_obj_path_generate
+	elif meta[0][0] == 'd':
+		return _vdo_pool_object_path_generate
 	elif meta[0][0] == 'C' and 'pool' in meta[1]:
 		return _cache_pool_obj_path_generate
 
@@ -364,6 +387,10 @@ def _thin_pool_obj_path_generate():
 	return cfg.THIN_POOL_PATH + "/%d" % next(cfg.thin_id)
 
 
+def _vdo_pool_object_path_generate():
+	return cfg.VDO_POOL_PATH + "/%d" % next(cfg.vdo_id)
+
+
 def _cache_pool_obj_path_generate():
 	return cfg.CACHE_POOL_PATH + "/%d" % next(cfg.cache_pool_id)
 
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index aed5511..1d340df 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -71,7 +71,8 @@ def lv_n(suffix=None):
 
 
 def _is_testsuite_pv(pv_name):
-	return g_prefix != "" and pv_name[-1].isdigit() and pv_name[:-1].endswith(g_prefix + "pv")
+	return g_prefix != "" and pv_name[-1].isdigit() and \
+			pv_name[:-1].endswith(g_prefix + "pv")
 
 
 def is_nested_pv(pv_name):
@@ -114,7 +115,7 @@ def get_objects():
 	rc = {
 		MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
 		THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
-		CACHE_POOL_INT: [], CACHE_LV_INT: [], VG_VDO_INT: []}
+		CACHE_POOL_INT: [], CACHE_LV_INT: [], VG_VDO_INT: [], VDOPOOL_INT: []}
 
 	object_manager_object = bus.get_object(
 		BUS_NAME, "/com/redhat/lvmdbus1", introspect=False)
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index 872ed80..0335f47 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -27,6 +27,7 @@ VG_INT = BASE_INTERFACE + ".Vg"
 VG_VDO_INT = BASE_INTERFACE + ".VgVdo"
 LV_INT = BASE_INTERFACE + ".Lv"
 THINPOOL_INT = BASE_INTERFACE + ".ThinPool"
+VDOPOOL_INT = BASE_INTERFACE + ".VdoPool"
 SNAPSHOT_INT = BASE_INTERFACE + ".Snapshot"
 LV_COMMON_INT = BASE_INTERFACE + ".LvCommon"
 JOB_INT = BASE_INTERFACE + ".Job"
@@ -240,6 +241,10 @@ class RemoteInterface(object):
 
 
 class ClientProxy(object):
+	Pv = None
+	Lv = None
+	Vg = None
+
 	@staticmethod
 	def _intf_short_name(nm):
 		return nm.split('.')[-1:][0]


