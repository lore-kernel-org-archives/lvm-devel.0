From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:43:38 -0400
Subject: master - lvmdbusd: Remove duplicate error handling code
Message-ID: <201910301543.x9UFhccA016523@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df38eb49aba94308804efdf309c08521165664d0
Commit:        df38eb49aba94308804efdf309c08521165664d0
Parent:        25e7bf021a4e7c5ad5f925b86605bf025ff1a949
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 1 15:17:30 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Remove duplicate error handling code

vg, lv, pv code had the same function for handling command execution.
Move to utility function and abstract the difference.
---
 daemons/lvmdbusd/lv.py    |   10 ++--------
 daemons/lvmdbusd/pv.py    |   10 ++--------
 daemons/lvmdbusd/utils.py |    9 +++++++++
 daemons/lvmdbusd/vg.py    |   11 +++--------
 4 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index c0029b8..f65e7da 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -10,7 +10,7 @@
 from .automatedproperties import AutomatedProperties
 
 from . import utils
-from .utils import vg_obj_path_generate, log_error
+from .utils import vg_obj_path_generate, log_error, _handle_execute
 import dbus
 from . import cmdhandler
 from . import cfg
@@ -275,13 +275,7 @@ class LvCommon(AutomatedProperties):
 
 	@staticmethod
 	def handle_execute(rc, out, err):
-		if rc == 0:
-			cfg.load()
-		else:
-			# Need to work on error handling, need consistent
-			raise dbus.exceptions.DBusException(
-				LV_INTERFACE,
-				'Exit code %s, stderr = %s' % (str(rc), err))
+		_handle_execute(rc, out, err, LV_INTERFACE)
 
 	@staticmethod
 	def validate_dbus_object(lv_uuid, lv_name):
diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index e5f8b9d..9c0f1b2 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -14,7 +14,7 @@ import dbus
 from .cfg import PV_INTERFACE
 from . import cmdhandler
 from .utils import vg_obj_path_generate, n, pv_obj_path_generate, \
-	lv_object_path_method
+	lv_object_path_method, _handle_execute
 from .loader import common
 from .request import RequestEntry
 from .state import State
@@ -144,13 +144,7 @@ class Pv(AutomatedProperties):
 
 	@staticmethod
 	def handle_execute(rc, out, err):
-		if rc == 0:
-			cfg.load()
-		else:
-			# Need to work on error handling, need consistent
-			raise dbus.exceptions.DBusException(
-				PV_INTERFACE,
-				'Exit code %s, stderr = %s' % (str(rc), err))
+		return _handle_execute(rc, out, err, PV_INTERFACE)
 
 	@staticmethod
 	def validate_dbus_object(pv_uuid, pv_name):
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 3c006c4..8d64117 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -26,6 +26,15 @@ import signal
 STDOUT_TTY = os.isatty(sys.stdout.fileno())
 
 
+def _handle_execute(rc, out, err, interface):
+	if rc == 0:
+		cfg.load()
+	else:
+		# Need to work on error handling, need consistent
+		raise dbus.exceptions.DBusException(
+			interface, 'Exit code %s, stderr = %s' % (str(rc), err))
+
+
 def rtype(dbus_type):
 	"""
 	Decorator making sure that the decorated function returns a value of
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 7011ff8..cfcc53b 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -10,7 +10,8 @@
 from .automatedproperties import AutomatedProperties
 
 from . import utils
-from .utils import pv_obj_path_generate, vg_obj_path_generate, n
+from .utils import pv_obj_path_generate, vg_obj_path_generate, n, \
+	_handle_execute
 import dbus
 from . import cfg
 from .cfg import VG_INTERFACE
@@ -154,13 +155,7 @@ class Vg(AutomatedProperties):
 
 	@staticmethod
 	def handle_execute(rc, out, err):
-		if rc == 0:
-			cfg.load()
-		else:
-			# Need to work on error handling, need consistent
-			raise dbus.exceptions.DBusException(
-				VG_INTERFACE,
-				'Exit code %s, stderr = %s' % (str(rc), err))
+		return _handle_execute(rc, out, err, VG_INTERFACE)
 
 	@staticmethod
 	def validate_dbus_object(vg_uuid, vg_name):


