From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:18 +0000 (UTC)
Subject: master - lvmdbusd: Initial support for json output
Message-ID: <20160628192418.A73A360FC2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec45be9976a3c0633d89e0516f7947c305c61e47
Commit:        ec45be9976a3c0633d89e0516f7947c305c61e47
Parent:        79446ffad7358dd8c130ff498514150d1e0ea08b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 3 13:18:21 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:09:28 2016 -0500

lvmdbusd: Initial support for json output

---
 daemons/lvmdbusd/cmdhandler.py |   54 ++++++++++++
 daemons/lvmdbusd/lvmdb.py      |  175 +++++++++++++++++++++++++++++++++++-----
 2 files changed, 209 insertions(+), 20 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 1522ebf..46fb68c 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -22,6 +22,11 @@ except SystemError:
 	from utils import pv_dest_ranges, log_debug, log_error
 	from lvm_shell_proxy import LVMShellProxy
 
+try:
+	import simplejson as json
+except ImportError:
+	import json
+
 SEP = '{|}'
 
 total_time = 0.0
@@ -426,6 +431,55 @@ def lv_detach_cache(lv_full_name, detach_options, destroy_cache):
 	return call(cmd)
 
 
+def supports_json():
+	cmd = ['help']
+	rc, out, err = call(cmd)
+	if rc == 0:
+		if 'fullreport' in err:
+			return True
+	return False
+
+
+def lvm_full_report_json():
+	pv_columns = ['pv_name', 'pv_uuid', 'pv_fmt', 'pv_size', 'pv_free',
+					'pv_used', 'dev_size', 'pv_mda_size', 'pv_mda_free',
+					'pv_ba_start', 'pv_ba_size', 'pe_start', 'pv_pe_count',
+					'pv_pe_alloc_count', 'pv_attr', 'pv_tags', 'vg_name',
+					'vg_uuid']
+
+	pv_seg_columns = ['pv_seg_start', 'pv_seg_size', 'segtype',
+					  'pv_uuid', 'lv_uuid', 'pv_name']
+
+	vg_columns = ['vg_name', 'vg_uuid', 'vg_fmt', 'vg_size', 'vg_free',
+					'vg_sysid', 'vg_extent_size', 'vg_extent_count',
+					'vg_free_count', 'vg_profile', 'max_lv', 'max_pv',
+					'pv_count', 'lv_count', 'snap_count', 'vg_seqno',
+					'vg_mda_count', 'vg_mda_free', 'vg_mda_size',
+					'vg_mda_used_count', 'vg_attr', 'vg_tags']
+
+	lv_columns = ['lv_uuid', 'lv_name', 'lv_path', 'lv_size',
+				'vg_name', 'pool_lv_uuid', 'pool_lv', 'origin_uuid',
+				'origin', 'data_percent',
+				'lv_attr', 'lv_tags', 'vg_uuid', 'lv_active', 'data_lv',
+				'metadata_lv', 'lv_parent', 'lv_role', 'lv_layout']
+
+	lv_seg_columns = ['seg_pe_ranges', 'segtype', 'lv_uuid']
+
+	cmd = _dc('fullreport', [
+		'-o', '/pv/' + ','.join(pv_columns),
+		'-o', '/vg/' + ','.join(vg_columns),
+		'-o', '/lv/' + ','.join(lv_columns),
+		'-o', '/seg/' + ','.join(lv_seg_columns),
+		'-o', '/pvseg/' + ','.join(pv_seg_columns),
+		'--reportformat', 'json'
+	])
+
+	rc, out, err = call(cmd)
+	if rc == 0:
+		return json.loads(out)
+	return None
+
+
 def pv_retrieve_with_segs(device=None):
 	d = []
 	err = ""
diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index d14ae3b..5ac90e3 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -13,6 +13,7 @@ from collections import OrderedDict
 
 import pprint as prettyprint
 import os
+import sys
 
 try:
 	from . import cmdhandler
@@ -23,7 +24,7 @@ except SystemError:
 
 
 class DataStore(object):
-	def __init__(self):
+	def __init__(self, usejson=None):
 		self.pvs = {}
 		self.vgs = {}
 		self.lvs = {}
@@ -41,6 +42,11 @@ class DataStore(object):
 		# self.refresh()
 		self.num_refreshes = 0
 
+		if usejson is None:
+			self.json = cmdhandler.supports_json()
+		else:
+			self.json = usejson
+
 	@staticmethod
 	def _insert_record(table, key, record, allowed_multiple):
 		if key in table:
@@ -94,6 +100,58 @@ class DataStore(object):
 		return c_pvs, c_lookup, c_pvs_in_vgs
 
 	@staticmethod
+	def _parse_pvs_json(_all):
+
+		c_pvs = OrderedDict()
+		c_lookup = {}
+		c_pvs_in_vgs = {}
+
+		# Each item item in the report is a collection of information pertaining
+		# to the vg
+		for r in _all['report']:
+			tmp_pv = []
+
+			# Get the pv data for this VG.
+			if 'pv' in r:
+				tmp_pv.extend(r['pv'])
+
+				# Sort them
+				sorted_tmp_pv = sorted(tmp_pv, key=lambda pk: pk['pv_name'])
+
+				# Add them to result set
+				for p in sorted_tmp_pv:
+					c_pvs[p['pv_uuid']] = p
+
+				if 'pvseg' in r:
+					for s in r['pvseg']:
+						# TODO Why is json pvseg_start, not pv_seg_start?
+						r = c_pvs[s['pv_uuid']]
+						r.setdefault('pv_seg_start', []).append(s['pvseg_start'])
+						r.setdefault('pvseg_size', []).append(s['pvseg_size'])
+						r.setdefault('segtype', []).append(s['segtype'])
+
+				# TODO: Remove this bug work around when we have orphan segs.
+				for i in c_pvs.values():
+					if 'pv_seg_start' not in i:
+						i['pv_seg_start'] = '0'
+						i['pvseg_size'] = i['pv_pe_count']
+						i['segtype'] = 'free'
+
+		for p in c_pvs.values():
+			# Capture which PVs are associated with which VG
+			if p['vg_uuid'] not in c_pvs_in_vgs:
+				c_pvs_in_vgs[p['vg_uuid']] = []
+
+			if p['vg_name']:
+				c_pvs_in_vgs[p['vg_uuid']].append(
+					(p['pv_name'], p['pv_uuid']))
+
+			# Lookup for translating between /dev/<name> and pv uuid
+			c_lookup[p['pv_name']] = p['pv_uuid']
+
+		return c_pvs, c_lookup, c_pvs_in_vgs
+
+	@staticmethod
 	def _parse_vgs(_vgs):
 		vgs = sorted(_vgs, key=lambda vk: vk['vg_name'])
 
@@ -107,20 +165,31 @@ class DataStore(object):
 		return c_vgs, c_lookup
 
 	@staticmethod
-	def _parse_lvs(_lvs):
-		lvs = sorted(_lvs, key=lambda vk: vk['lv_name'])
+	def _parse_vgs_json(_all):
 
-		c_lvs = OrderedDict()
-		c_lvs_in_vgs = {}
-		c_lvs_hidden = {}
-		c_lv_full_lookup = {}
+		tmp_vg = []
+		for r in _all['report']:
+			# Get the pv data for this VG.
+			if 'vg' in r:
+				tmp_vg.extend(r['vg'])
 
-		for i in lvs:
-			full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
-			c_lv_full_lookup[full_name] = i['lv_uuid']
-			DataStore._insert_record(
-				c_lvs, i['lv_uuid'], i,
-				['seg_pe_ranges', 'segtype'])
+		# Sort for consistent output, however this is optional
+		vgs = sorted(tmp_vg, key=lambda vk: vk['vg_name'])
+
+		c_vgs = OrderedDict()
+		c_lookup = {}
+
+		for i in vgs:
+			c_lookup[i['vg_name']] = i['vg_uuid']
+			c_vgs[i['vg_uuid']] = i
+
+		return c_vgs, c_lookup
+
+	@staticmethod
+	def _parse_lvs_common(c_lvs, c_lv_full_lookup):
+
+		c_lvs_in_vgs = OrderedDict()
+		c_lvs_hidden = OrderedDict()
 
 		for i in c_lvs.values():
 			if i['vg_uuid'] not in c_lvs_in_vgs:
@@ -151,6 +220,55 @@ class DataStore(object):
 		return c_lvs, c_lvs_in_vgs, c_lvs_hidden, c_lv_full_lookup
 
 	@staticmethod
+	def _parse_lvs(_lvs):
+		lvs = sorted(_lvs, key=lambda vk: vk['lv_name'])
+
+		c_lvs = OrderedDict()
+		c_lv_full_lookup = OrderedDict()
+
+		for i in lvs:
+			full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
+			c_lv_full_lookup[full_name] = i['lv_uuid']
+			DataStore._insert_record(
+				c_lvs, i['lv_uuid'], i,
+				['seg_pe_ranges', 'segtype'])
+
+		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
+
+
+	@staticmethod
+	def _parse_lvs_json(_all):
+
+		c_lvs = OrderedDict()
+		c_lv_full_lookup = {}
+
+		# Each item item in the report is a collection of information pertaining
+		# to the vg
+		for r in _all['report']:
+			tmp_lv = []
+			# Get the lv data for this VG.
+			if 'lv' in r:
+				tmp_lv.extend(r['lv'])
+
+				# Sort them
+				sorted_tmp_lv = sorted(tmp_lv, key=lambda vk: vk['lv_name'])
+
+				# Add them to result set
+				for i in sorted_tmp_lv:
+					full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
+					c_lv_full_lookup[full_name] = i['lv_uuid']
+					c_lvs[i['lv_uuid']] = i
+
+				# Add in the segment data
+				if 'seg' in r:
+					for s in r['seg']:
+						r = c_lvs[s['lv_uuid']]
+						r.setdefault('seg_pe_ranges', []).append(s['seg_pe_ranges'])
+						r.setdefault('segtype', []).append(s['segtype'])
+
+		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
+
+	@staticmethod
 	def _make_list(l):
 		if not isinstance(l, list):
 			l = [l]
@@ -278,13 +396,22 @@ class DataStore(object):
 			log_debug("lvmdb - refresh entry")
 
 		# Grab everything first then parse it
-		_raw_pvs = cmdhandler.pv_retrieve_with_segs()
-		_raw_vgs = cmdhandler.vg_retrieve(None)
-		_raw_lvs = cmdhandler.lv_retrieve_with_segments()
+		if self.json:
+			# Do a single lvm retrieve for everything in json
+			a = cmdhandler.lvm_full_report_json()
 
-		_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs(_raw_pvs)
-		_vgs, _vgs_lookup = self._parse_vgs(_raw_vgs)
-		_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs(_raw_lvs)
+			_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs_json(a)
+			_vgs, _vgs_lookup = self._parse_vgs_json(a)
+			_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs_json(a)
+
+		else:
+			_raw_pvs = cmdhandler.pv_retrieve_with_segs()
+			_raw_vgs = cmdhandler.vg_retrieve(None)
+			_raw_lvs = cmdhandler.lv_retrieve_with_segments()
+
+			_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs(_raw_pvs)
+			_vgs, _vgs_lookup = self._parse_vgs(_raw_vgs)
+			_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs(_raw_lvs)
 
 		# Set all
 		self.pvs = _pvs
@@ -389,12 +516,20 @@ class DataStore(object):
 if __name__ == "__main__":
 	pp = prettyprint.PrettyPrinter(indent=4)
 
-	ds = DataStore()
+	use_json = False
+
+	if len(sys.argv) != 1:
+		print(len(sys.argv))
+		use_json = True
+
+	ds = DataStore(use_json)
 	ds.refresh()
 
+	print("PVS")
 	for v in ds.pvs.values():
 		pp.pprint(v)
 
+	print("VGS")
 	for v in ds.vgs.values():
 		pp.pprint(v)
 


