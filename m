From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:51 +0000 (GMT)
Subject: main - lvmdusd: Remove non lvm JSON output support
Message-ID: <20220630160051.A9244386F0D9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d957dcacc3118e9f2d4e83830d6c93b8955fd5f
Commit:        0d957dcacc3118e9f2d4e83830d6c93b8955fd5f
Parent:        73121e3f0712d228e713b71468484ca55d62d93b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 7 08:20:06 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdusd: Remove non lvm JSON output support

---
 daemons/lvmdbusd/cmdhandler.py | 123 +----------------------------------------
 daemons/lvmdbusd/lvmdb.py.in   | 117 +++------------------------------------
 daemons/lvmdbusd/main.py       |  13 ++++-
 3 files changed, 20 insertions(+), 233 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index b88bd9896..8fbcd2e3a 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -220,38 +220,6 @@ def _dc(cmd, args):
 	return c
 
 
-def parse(out):
-	rc = []
-
-	for line in out.split('\n'):
-		# This line includes separators, so process them
-		if SEP in line:
-			elem = line.split(SEP)
-			cleaned_elem = []
-			for e in elem:
-				e = e.strip()
-				cleaned_elem.append(e)
-
-			if len(cleaned_elem) > 1:
-				rc.append(cleaned_elem)
-		else:
-			t = line.strip()
-			if len(t) > 0:
-				rc.append(t)
-	return rc
-
-
-def parse_column_names(out, column_names):
-	lines = parse(out)
-	rc = []
-
-	for i in range(0, len(lines)):
-		d = dict(list(zip(column_names, lines[i])))
-		rc.append(d)
-
-	return rc
-
-
 def options_to_cli_args(options):
 	rc = []
 	for k, v in list(dict(options).items()):
@@ -637,46 +605,6 @@ def lvm_full_report_json():
 	return None
 
 
-def pv_retrieve_with_segs(device=None):
-	d = []
-	err = ""
-	out = ""
-	rc = 0
-
-	columns = ['pv_name', 'pv_uuid', 'pv_fmt', 'pv_size', 'pv_free',
-				'pv_used', 'dev_size', 'pv_mda_size', 'pv_mda_free',
-				'pv_ba_start', 'pv_ba_size', 'pe_start', 'pv_pe_count',
-				'pv_pe_alloc_count', 'pv_attr', 'pv_tags', 'vg_name',
-				'vg_uuid', 'pvseg_start', 'pvseg_size', 'segtype', 'pv_missing']
-
-	# Lvm has some issues where it returns failure when querying pvs when other
-	# operations are in process, see:
-	# https://bugzilla.redhat.com/show_bug.cgi?id=1274085
-	for i in range(0, 10):
-		cmd = _dc('pvs', ['-o', ','.join(columns)])
-
-		if device:
-			cmd.extend(device)
-
-		rc, out, err = call(cmd)
-
-		if rc == 0:
-			d = parse_column_names(out, columns)
-			break
-		else:
-			time.sleep(0.2)
-			log_debug("LVM Bug workaround, retrying pvs command...")
-
-	if rc != 0:
-		msg = "We were unable to get pvs to return without error after " \
-			"trying 10 times, RC=%d, STDERR=(%s), STDOUT=(%s)" % \
-			(rc, err, out)
-		log_error(msg)
-		raise RuntimeError(msg)
-
-	return d
-
-
 def pv_resize(device, size_bytes, create_options):
 	cmd = ['pvresize']
 
@@ -831,53 +759,6 @@ def activate_deactivate(op, name, activate, control_flags, options):
 	return call(cmd)
 
 
-def vg_retrieve(vg_specific):
-	if vg_specific:
-		assert isinstance(vg_specific, list)
-
-	columns = ['vg_name', 'vg_uuid', 'vg_fmt', 'vg_size', 'vg_free',
-				'vg_sysid', 'vg_extent_size', 'vg_extent_count',
-				'vg_free_count', 'vg_profile', 'max_lv', 'max_pv',
-				'pv_count', 'lv_count', 'snap_count', 'vg_seqno',
-				'vg_mda_count', 'vg_mda_free', 'vg_mda_size',
-				'vg_mda_used_count', 'vg_attr', 'vg_tags']
-
-	cmd = _dc('vgs', ['-o', ','.join(columns)])
-
-	if vg_specific:
-		cmd.extend(vg_specific)
-
-	d = []
-	rc, out, err = call(cmd)
-	if rc == 0:
-		d = parse_column_names(out, columns)
-
-	return d
-
-
-def lv_retrieve_with_segments():
-	columns = ['lv_uuid', 'lv_name', 'lv_path', 'lv_size',
-				'vg_name', 'pool_lv_uuid', 'pool_lv', 'origin_uuid',
-				'origin', 'data_percent',
-				'lv_attr', 'lv_tags', 'vg_uuid', 'lv_active', 'data_lv',
-				'metadata_lv', 'seg_pe_ranges', 'segtype', 'lv_parent',
-				'lv_role', 'lv_layout',
-				'snap_percent', 'metadata_percent', 'copy_percent',
-				'sync_percent', 'lv_metadata_size', 'move_pv', 'move_pv_uuid']
-
-	cmd = _dc('lvs', ['-a', '-o', ','.join(columns)])
-	rc, out, err = call(cmd)
-
-	d = []
-
-	if rc == 0:
-		d = parse_column_names(out, columns)
-
-	return d
-
-
 if __name__ == '__main__':
-	pv_data = pv_retrieve_with_segs()
-
-	for p in pv_data:
-		print(str(p))
+	# Leave this for future debug as needed
+	pass
diff --git a/daemons/lvmdbusd/lvmdb.py.in b/daemons/lvmdbusd/lvmdb.py.in
index 2e7aba914..87474d0f3 100644
--- a/daemons/lvmdbusd/lvmdb.py.in
+++ b/daemons/lvmdbusd/lvmdb.py.in
@@ -13,14 +13,13 @@ from collections import OrderedDict
 
 import pprint as prettyprint
 import os
-import sys
 
 from lvmdbusd import cmdhandler
 from lvmdbusd.utils import log_debug, log_error
 
 
 class DataStore(object):
-	def __init__(self, usejson=True, vdo_support=False):
+	def __init__(self, vdo_support=False):
 		self.pvs = {}
 		self.vgs = {}
 		self.lvs = {}
@@ -35,41 +34,9 @@ class DataStore(object):
 		self.lvs_in_vgs = {}
 		self.pvs_in_vgs = {}
 
-		# self.refresh()
 		self.num_refreshes = 0
-
-		if usejson:
-			self.json = cmdhandler.supports_json()
-		else:
-			self.json = usejson
-
 		self.vdo_support = vdo_support
 
-	@staticmethod
-	def _insert_record(table, key, record, allowed_multiple):
-		if key in table:
-			existing = table[key]
-
-			for rec_k, rec_v in record.items():
-				if rec_k in allowed_multiple:
-					# This column name allows us to store multiple value for
-					# each type
-					if not isinstance(existing[rec_k], list):
-						existing_value = existing[rec_k]
-						existing[rec_k] = [existing_value, rec_v]
-					else:
-						existing[rec_k].append(rec_v)
-				else:
-					# If something is not expected to have changing values
-					# lets ensure that
-					if existing[rec_k] != rec_v:
-						raise RuntimeError(
-							"existing[%s]=%s != %s" %
-							(rec_k, str(existing[rec_k]),
-							str(rec_v)))
-		else:
-			table[key] = record
-
 	@staticmethod
 	def _pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup):
 		for p in c_pvs.values():
@@ -84,22 +51,6 @@ class DataStore(object):
 			# Lookup for translating between /dev/<name> and pv uuid
 			c_lookup[p['pv_name']] = p['pv_uuid']
 
-	@staticmethod
-	def _parse_pvs(_pvs):
-		pvs = sorted(_pvs, key=lambda pk: pk['pv_name'])
-
-		c_pvs = OrderedDict()
-		c_lookup = {}
-		c_pvs_in_vgs = {}
-
-		for p in pvs:
-			DataStore._insert_record(
-				c_pvs, p['pv_uuid'], p,
-				['pvseg_start', 'pvseg_size', 'segtype'])
-
-		DataStore._pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup)
-		return c_pvs, c_lookup, c_pvs_in_vgs
-
 	@staticmethod
 	def _parse_pvs_json(_all):
 
@@ -141,28 +92,6 @@ class DataStore(object):
 
 		return c_pvs, c_lookup, c_pvs_in_vgs
 
-	@staticmethod
-	def _parse_vgs(_vgs):
-		vgs = sorted(_vgs, key=lambda vk: vk['vg_uuid'])
-
-		c_vgs = OrderedDict()
-		c_lookup = {}
-
-		for i in vgs:
-			vg_name = i['vg_name']
-
-			# Lvm allows duplicate vg names.  When this occurs, each subsequent
-			# matching VG name will be called vg_name:vg_uuid.  Note: ':' is an
-			# invalid character for lvm VG names
-			if vg_name in c_lookup:
-				vg_name = "%s:%s" % (vg_name, i['vg_uuid'])
-				i['vg_name'] = vg_name
-
-			c_lookup[vg_name] = i['vg_uuid']
-			DataStore._insert_record(c_vgs, i['vg_uuid'], i, [])
-
-		return c_vgs, c_lookup
-
 	@staticmethod
 	def _parse_vgs_json(_all):
 
@@ -227,22 +156,6 @@ class DataStore(object):
 
 		return c_lvs, c_lvs_in_vgs, c_lvs_hidden, c_lv_full_lookup
 
-	@staticmethod
-	def _parse_lvs(_lvs):
-		lvs = sorted(_lvs, key=lambda vk: vk['lv_name'])
-
-		c_lvs = OrderedDict()
-		c_lv_full_lookup = OrderedDict()
-
-		for i in lvs:
-			full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
-			c_lv_full_lookup[full_name] = i['lv_uuid']
-			DataStore._insert_record(
-				c_lvs, i['lv_uuid'], i,
-				['seg_pe_ranges', 'segtype'])
-
-		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
-
 	def _parse_lvs_json(self, _all):
 
 		c_lvs = OrderedDict()
@@ -401,22 +314,12 @@ class DataStore(object):
 			log_debug("lvmdb - refresh entry")
 
 		# Grab everything first then parse it
-		if self.json:
-			# Do a single lvm retrieve for everything in json
-			a = cmdhandler.lvm_full_report_json()
-
-			_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs_json(a)
-			_vgs, _vgs_lookup = self._parse_vgs_json(a)
-			_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs_json(a)
-
-		else:
-			_raw_pvs = cmdhandler.pv_retrieve_with_segs()
-			_raw_vgs = cmdhandler.vg_retrieve(None)
-			_raw_lvs = cmdhandler.lv_retrieve_with_segments()
+		# Do a single lvm retrieve for everything in json
+		a = cmdhandler.lvm_full_report_json()
 
-			_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs(_raw_pvs)
-			_vgs, _vgs_lookup = self._parse_vgs(_raw_vgs)
-			_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs(_raw_lvs)
+		_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs_json(a)
+		_vgs, _vgs_lookup = self._parse_vgs_json(a)
+		_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs_json(a)
 
 		# Set all
 		self.pvs = _pvs
@@ -527,13 +430,7 @@ class DataStore(object):
 if __name__ == "__main__":
 	pp = prettyprint.PrettyPrinter(indent=4)
 
-	use_json = False
-
-	if len(sys.argv) != 1:
-		print(len(sys.argv))
-		use_json = True
-
-	ds = DataStore(use_json)
+	ds = DataStore()
 	ds.refresh()
 
 	print("PVS")
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 1e717ef69..597441a9e 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -29,7 +29,7 @@ from .utils import log_debug, log_error
 import argparse
 import os
 import sys
-from .cmdhandler import LvmFlightRecorder, supports_vdo
+from .cmdhandler import LvmFlightRecorder, supports_vdo, supports_json
 from .request import RequestEntry
 
 
@@ -116,6 +116,15 @@ def main():
 	os.environ["LC_ALL"] = "C"
 
 	cfg.args = parser.parse_args()
+
+	if not cfg.args.use_json:
+		log_error("Daemon no longer supports lvm without JSON support, exiting!")
+		sys.exit(1)
+	else:
+		if not supports_json():
+			log_error("Un-supported version of LVM, daemon requires JSON output, exiting!")
+			sys.exit(1)
+
 	cfg.create_request_entry = RequestEntry
 
 	# We create a flight recorder in cmdhandler too, but we replace it here
@@ -157,7 +166,7 @@ def main():
 	cfg.om = Lvm(BASE_OBJ_PATH)
 	cfg.om.register_object(Manager(MANAGER_OBJ_PATH))
 
-	cfg.db = lvmdb.DataStore(cfg.args.use_json, cfg.vdo_support)
+	cfg.db = lvmdb.DataStore(vdo_support=cfg.vdo_support)
 
 	# Using a thread to process requests, we cannot hang the dbus library
 	# thread that is handling the dbus interface

