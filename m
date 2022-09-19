From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:39 +0000 (GMT)
Subject: main - lvmdbusd: Use common func. for checking missing LV keys
Message-ID: <20220919155839.E85E33858297@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=feaf46863b4d53ee352b451c8f6f6ce8b77a15cc
Commit:        feaf46863b4d53ee352b451c8f6f6ce8b77a15cc
Parent:        ed9072dad8316e65c22ad4530984174fd488b56c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 8 15:38:31 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Use common func. for checking missing LV keys

---
 daemons/lvmdbusd/lv.py    |  6 ++----
 daemons/lvmdbusd/pv.py    |  4 ++--
 daemons/lvmdbusd/utils.py | 15 +++++++++++++++
 daemons/lvmdbusd/vg.py    |  5 ++---
 4 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 5dd698e29..30c105342 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -21,7 +21,7 @@ from .utils import n, n32, d
 from .loader import common
 from .state import State
 from . import background
-from .utils import round_size, mt_remove_dbus_objects
+from .utils import round_size, mt_remove_dbus_objects, lvm_column_key
 from .job import JobState
 
 
@@ -136,9 +136,7 @@ def lvs_state_retrieve(selection, cache_refresh=True):
 	except KeyError as ke:
 		# Sometimes lvm omits returning one of the keys we requested.
 		key = ke.args[0]
-		if key.startswith("lv_") or key.startswith("vg_") or key.startswith("pool_") or \
-			key.endswith("_percent") or key.startswith("move_") or key.startswith("vdo_") or \
-			key in ["origin_uuid", "segtype", "origin", "data_lv", "metadata_lv"]:
+		if lvm_column_key(key):
 			raise LvmBug("missing JSON key: '%s'" % key)
 		raise ke
 	return rc
diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index 2037f9c91..316ed37b1 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -14,7 +14,7 @@ import dbus
 from .cfg import PV_INTERFACE
 from . import cmdhandler
 from .utils import vg_obj_path_generate, n, pv_obj_path_generate, \
-	lv_object_path_method, _handle_execute
+	lv_object_path_method, _handle_execute, lvm_column_key
 from .loader import common
 from .request import RequestEntry
 from .state import State
@@ -42,7 +42,7 @@ def pvs_state_retrieve(selection, cache_refresh=True):
 	except KeyError as ke:
 		# Sometimes lvm omits returning one of the keys we requested.
 		key = ke.args[0]
-		if key.startswith("pv") or key.startswith("vg") or (key in ['dev_size', 'pe_start']):
+		if lvm_column_key(key):
 			raise LvmBug("missing JSON key: '%s'" % key)
 		raise ke
 	return rc
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 3443bdad7..dcb3e06bd 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -781,6 +781,21 @@ def extract_stack_trace(exception):
 	return ''.join(traceback.format_exception(None, exception, exception.__traceback__))
 
 
+def lvm_column_key(key):
+	# Check LV
+	if key.startswith("lv_") or key.startswith("vg_") or key.startswith("pool_") or \
+			key.endswith("_percent") or key.startswith("move_") or key.startswith("vdo_") or \
+			key in ["origin_uuid", "segtype", "origin", "data_lv", "metadata_lv"]:
+		return True
+	# Check VG
+	if key.startswith("vg_") or key.startswith("lv_") or key.startswith("pv_") or \
+			key in ["max_lv", "max_pv", "snap_count"]:
+		return True
+	# Check PV
+	if key.startswith("pv") or key.startswith("vg") or (key in ['dev_size', 'pe_start']):
+		return True
+	return False
+
 class LvmBug(RuntimeError):
 	"""
 	Things that are clearly a bug with lvm itself.
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 928146fdb..6e7d6ec9b 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -20,7 +20,7 @@ from .request import RequestEntry
 from .loader import common
 from .state import State
 from . import background
-from .utils import round_size, mt_remove_dbus_objects, LvmBug
+from .utils import round_size, mt_remove_dbus_objects, LvmBug, lvm_column_key
 from .job import JobState
 
 
@@ -46,8 +46,7 @@ def vgs_state_retrieve(selection, cache_refresh=True):
 	except KeyError as ke:
 		# Sometimes lvm omits returning one of the keys we requested.
 		key = ke.args[0]
-		if key.startswith("vg_") or key.startswith("lv_") or key.startswith("pv_") or \
-			key in ["max_lv", "max_pv", "snap_count"]:
+		if lvm_column_key(key):
 			raise LvmBug("missing JSON key: '%s'" % key)
 		raise ke
 	return rc

