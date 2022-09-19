From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:41 +0000 (GMT)
Subject: main - lvmdbusd: Check for KeyError in refresh
Message-ID: <20220919155841.1593C3858415@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d51fb57f1abf9e24aa8c74df5ffd717e2d45c103
Commit:        d51fb57f1abf9e24aa8c74df5ffd717e2d45c103
Parent:        feaf46863b4d53ee352b451c8f6f6ce8b77a15cc
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 8 15:39:30 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Check for KeyError in refresh

Bubble up a LvmBug if we get a KeyError on a lvm column name.
---
 daemons/lvmdbusd/lvmdb.py.in | 60 ++++++++++++++++++++++++--------------------
 1 file changed, 33 insertions(+), 27 deletions(-)

diff --git a/daemons/lvmdbusd/lvmdb.py.in b/daemons/lvmdbusd/lvmdb.py.in
index 2346d01e9..8d0cc59e1 100644
--- a/daemons/lvmdbusd/lvmdb.py.in
+++ b/daemons/lvmdbusd/lvmdb.py.in
@@ -15,7 +15,7 @@ import pprint as prettyprint
 import os
 
 from lvmdbusd import cmdhandler
-from lvmdbusd.utils import log_debug, log_error
+from lvmdbusd.utils import log_debug, log_error, lvm_column_key, LvmBug
 
 
 class DataStore(object):
@@ -309,32 +309,38 @@ class DataStore(object):
 		:param log  Add debug log entry/exit messages
 		:return: None
 		"""
-		self.num_refreshes += 1
-		if log:
-			log_debug("lvmdb - refresh entry")
-
-		# Grab everything first then parse it
-		# Do a single lvm retrieve for everything in json
-		a = cmdhandler.lvm_full_report_json()
-
-		_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs_json(a)
-		_vgs, _vgs_lookup = self._parse_vgs_json(a)
-		_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs_json(a)
-
-		# Set all
-		self.pvs = _pvs
-		self.pv_path_to_uuid = _pvs_lookup
-		self.vg_name_to_uuid = _vgs_lookup
-		self.lv_full_name_to_uuid = _lvs_lookup
-
-		self.vgs = _vgs
-		self.lvs = _lvs
-		self.lvs_in_vgs = _lvs_in_vgs
-		self.pvs_in_vgs = _pvs_in_vgs
-		self.lvs_hidden = _lvs_hidden
-
-		# Create lookup table for which LV and segments are on each PV
-		self.pv_lvs, self.lv_pvs = self._parse_pv_in_lvs()
+		try:
+			self.num_refreshes += 1
+			if log:
+				log_debug("lvmdb - refresh entry")
+
+			# Grab everything first then parse it
+			# Do a single lvm retrieve for everything in json
+			a = cmdhandler.lvm_full_report_json()
+
+			_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs_json(a)
+			_vgs, _vgs_lookup = self._parse_vgs_json(a)
+			_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs_json(a)
+
+			# Set all
+			self.pvs = _pvs
+			self.pv_path_to_uuid = _pvs_lookup
+			self.vg_name_to_uuid = _vgs_lookup
+			self.lv_full_name_to_uuid = _lvs_lookup
+
+			self.vgs = _vgs
+			self.lvs = _lvs
+			self.lvs_in_vgs = _lvs_in_vgs
+			self.pvs_in_vgs = _pvs_in_vgs
+			self.lvs_hidden = _lvs_hidden
+
+			# Create lookup table for which LV and segments are on each PV
+			self.pv_lvs, self.lv_pvs = self._parse_pv_in_lvs()
+		except KeyError as ke:
+			key = ke.args[0]
+			if lvm_column_key(key):
+				raise LvmBug("missing JSON key: '%s'" % key)
+			raise ke
 
 		if log:
 			log_debug("lvmdb - refresh exit")

