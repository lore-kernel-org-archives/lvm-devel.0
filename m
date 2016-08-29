From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:55 +0000 (UTC)
Subject: master - lvmdbusd: Handle different daemon options
Message-ID: <20160829202855.706DF601E9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70d4e2e8d50a1d095b2ba1a4286fdcaeb8aa321e
Commit:        70d4e2e8d50a1d095b2ba1a4286fdcaeb8aa321e
Parent:        1d1fe008468bfbab7285b0a559803cf351472e7c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 14:26:16 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:56 2016 -0500

lvmdbusd: Handle different daemon options

- Prevent --lvmshell with --nojson, not a valid combination
- If user is preventing json, then no lvmshell usage
- Return boolean on Manager.UseLvmShell
---
 daemons/lvmdbusd/cmdhandler.py |   10 ++++++++--
 daemons/lvmdbusd/lvmdb.py      |    4 ++--
 daemons/lvmdbusd/main.py       |   13 ++++++++++---
 daemons/lvmdbusd/manager.py    |    4 ++--
 test/dbus/lvmdbustest.py       |   11 ++++++++---
 5 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 5815031..877f17c 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -126,11 +126,13 @@ def _shell_cfg():
 		lvm_shell = LVMShellProxy()
 		_t_call = lvm_shell.call_lvm
 		cfg.SHELL_IN_USE = lvm_shell
+		return True
 	except Exception:
 		_t_call = call_lvm
 		cfg.SHELL_IN_USE = None
 		log_error(traceback.format_exc())
 		log_error("Unable to utilize lvm shell, dropping back to fork & exec")
+		return False
 
 
 def set_execution(shell):
@@ -139,7 +141,7 @@ def set_execution(shell):
 		# If the user requested lvm shell and we are currently setup that
 		# way, just return
 		if cfg.SHELL_IN_USE and shell:
-			return
+			return True
 		else:
 			if not shell and cfg.SHELL_IN_USE:
 				cfg.SHELL_IN_USE.exit_shell()
@@ -147,7 +149,11 @@ def set_execution(shell):
 
 		_t_call = call_lvm
 		if shell:
-			_shell_cfg()
+			if cfg.args.use_json:
+				return _shell_cfg()
+			else:
+				return False
+		return True
 
 
 def time_wrapper(command, debug=False):
diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index 2dc593b..187a930 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -24,7 +24,7 @@ except SystemError:
 
 
 class DataStore(object):
-	def __init__(self, usejson=None):
+	def __init__(self, usejson=True):
 		self.pvs = {}
 		self.vgs = {}
 		self.lvs = {}
@@ -42,7 +42,7 @@ class DataStore(object):
 		# self.refresh()
 		self.num_refreshes = 0
 
-		if usejson is None:
+		if usejson:
 			self.json = cmdhandler.supports_json()
 		else:
 			self.json = usejson
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index d76b5c3..5cf522d 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -25,9 +25,10 @@ from .background import background_reaper
 import traceback
 import queue
 from . import udevwatch
-from .utils import log_debug
+from .utils import log_debug, log_error
 import argparse
 import os
+import sys
 from .refresh import handle_external_event, event_complete
 
 
@@ -102,10 +103,12 @@ def main():
 						help="Dump debug messages", default=False,
 						dest='debug')
 	parser.add_argument("--nojson", action='store_false',
-						help="Do not use LVM JSON output", default=None,
+						help="Do not use LVM JSON output (Note: This "
+							"does not work with --lvmshell", default=True,
 						dest='use_json')
 	parser.add_argument("--lvmshell", action='store_true',
-						help="Use the lvm shell, not fork & exec lvm", default=False,
+						help="Use the lvm shell, not fork & exec lvm",
+						default=False,
 						dest='use_lvm_shell')
 
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
@@ -115,6 +118,10 @@ def main():
 
 	cfg.args = parser.parse_args()
 
+	if cfg.args.use_lvm_shell and not cfg.args.use_json:
+		log_error("You cannot specify --lvmshell and --nojson")
+		sys.exit(1)
+
 	cmdhandler.set_execution(cfg.args.use_lvm_shell)
 
 	# List of threads that we start up
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index e0da824..b141929 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -167,14 +167,14 @@ class Manager(AutomatedProperties):
 
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
-		in_signature='b')
+		in_signature='b', out_signature='b')
 	def UseLvmShell(self, yes_no):
 		"""
 		Allow the client to enable/disable lvm shell, used for testing
 		:param yes_no:
 		:return: Nothing
 		"""
-		cmdhandler.set_execution(yes_no)
+		return dbus.Boolean(cmdhandler.set_execution(yes_no))
 
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 4d0143c..4327a96 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -50,7 +50,7 @@ def set_execution(lvmshell):
 	lvm_manager = dbus.Interface(bus.get_object(
 		BUSNAME, "/com/redhat/lvmdbus1/Manager"),
 		"com.redhat.lvmdbus1.Manager")
-	lvm_manager.UseLvmShell(lvmshell)
+	return lvm_manager.UseLvmShell(lvmshell)
 
 
 # noinspection PyUnresolvedReferences
@@ -1155,13 +1155,18 @@ if __name__ == '__main__':
 	# Test forking & exec new each time
 	test_shell = os.getenv('LVM_DBUS_TEST_SHELL', 1)
 
+	# Default to no lvm shell
 	set_execution(False)
 
 	if test_shell == 0:
 		unittest.main(exit=True)
 	else:
+		print('\n *** Testing fork & exec *** \n')
 		unittest.main(exit=False)
 		# Test lvm shell
 		print('\n *** Testing lvm shell *** \n')
-		set_execution(True)
-		unittest.main()
+		if set_execution(True):
+			unittest.main()
+		else:
+			print("WARNING: Unable to dynamically configure "
+				"service to use lvm shell!")


