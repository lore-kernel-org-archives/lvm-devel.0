From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:38 +0000 (UTC)
Subject: master - lvmdbusd: Use udev until ExternalEvent occurs
Message-ID: <20160829202838.939EB6114E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4902034c895d26423564175c0636cff8ba4112e1
Commit:        4902034c895d26423564175c0636cff8ba4112e1
Parent:        2352ff24a55757a70869f443126d67cece0fb0a4
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 24 18:29:35 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:55 2016 -0500

lvmdbusd: Use udev until ExternalEvent occurs

The normal mode of operation will be to monitor for udev events until an
ExternalEvent occurs.  In that case the service will disable monitoring
for udev events and use ExternalEvent exclusively.

Note: User specifies --udev the service will always monitor udev regardless
if ExternalEvent is being called too.
---
 daemons/lvmdbusd/cfg.py             |   14 +++++++++-----
 daemons/lvmdbusd/cmdhandler.py      |   24 ++++++++++++++++++------
 daemons/lvmdbusd/lvm_shell_proxy.py |    6 ++++++
 daemons/lvmdbusd/main.py            |   28 ++++++++++++++--------------
 daemons/lvmdbusd/manager.py         |    9 ++++++++-
 daemons/lvmdbusd/udevwatch.py       |   25 ++++++++++++++++---------
 daemons/lvmdbusd/utils.py           |    2 +-
 7 files changed, 72 insertions(+), 36 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 8aec8ae..1d773c3 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -24,14 +24,18 @@ om = None
 # This is the global bus connection
 bus = None
 
+# Command line args
+args = None
+
+# Set to true if we are depending on external events for updates
+ee = False
+
 # Shared state variable across all processes
 run = multiprocessing.Value('i', 1)
 
-# Debug
-DEBUG = True
-
-# Use lvm shell
-USE_SHELL = False
+# If this is set to true, the current setup support lvm shell and we are
+# running in that mode of operation
+SHELL_IN_USE = None
 
 # Lock used by pprint
 stdout_lock = multiprocessing.Lock()
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 0d35782..5815031 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -13,6 +13,7 @@ import threading
 from itertools import chain
 import collections
 import traceback
+import os
 
 try:
 	from . import cfg
@@ -101,7 +102,8 @@ def call_lvm(command, debug=False):
 	# in different locations on the same box
 	command.insert(0, cfg.LVM_CMD)
 
-	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True)
+	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True,
+					env=os.environ)
 	out = process.communicate()
 
 	stdout_text = bytes(out[0]).decode("utf-8")
@@ -111,7 +113,7 @@ def call_lvm(command, debug=False):
 		_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
 	if process.returncode == 0:
-		if cfg.DEBUG and out[1] and len(out[1]) and 'help' not in command:
+		if cfg.args.debug and out[1] and len(out[1]) and 'help' not in command:
 			log_error('WARNING: lvm is out-putting text to STDERR on success!')
 			_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
@@ -123,9 +125,10 @@ def _shell_cfg():
 	try:
 		lvm_shell = LVMShellProxy()
 		_t_call = lvm_shell.call_lvm
-		cfg.USE_SHELL = True
+		cfg.SHELL_IN_USE = lvm_shell
 	except Exception:
 		_t_call = call_lvm
+		cfg.SHELL_IN_USE = None
 		log_error(traceback.format_exc())
 		log_error("Unable to utilize lvm shell, dropping back to fork & exec")
 
@@ -133,6 +136,15 @@ def _shell_cfg():
 def set_execution(shell):
 	global _t_call
 	with cmd_lock:
+		# If the user requested lvm shell and we are currently setup that
+		# way, just return
+		if cfg.SHELL_IN_USE and shell:
+			return
+		else:
+			if not shell and cfg.SHELL_IN_USE:
+				cfg.SHELL_IN_USE.exit_shell()
+				cfg.SHELL_IN_USE = None
+
 		_t_call = call_lvm
 		if shell:
 			_shell_cfg()
@@ -217,7 +229,7 @@ def pv_remove(device, remove_options):
 
 def _qt(tag_name):
 	# When running in lvm shell you need to quote the tags
-	if cfg.USE_SHELL:
+	if cfg.SHELL_IN_USE:
 		return '"%s"' % tag_name
 	return tag_name
 
@@ -440,7 +452,7 @@ def supports_json():
 	cmd = ['help']
 	rc, out, err = call(cmd)
 	if rc == 0:
-		if cfg.USE_SHELL:
+		if cfg.SHELL_IN_USE:
 			return True
 		else:
 			if 'fullreport' in err:
@@ -488,7 +500,7 @@ def lvm_full_report_json():
 		# With the current implementation, if we are using the shell then we
 		# are using JSON and JSON is returned back to us as it was parsed to
 		# figure out if we completed OK or not
-		if cfg.USE_SHELL:
+		if cfg.SHELL_IN_USE:
 			assert(type(out) == dict)
 			return out
 		else:
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index d4eff86..3455342 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -203,6 +203,12 @@ class LVMShellProxy(object):
 
 		return rc, json_result, error_msg
 
+	def exit_shell(self):
+		try:
+			self._write_cmd('exit\n')
+		except Exception as e:
+			log_error(str(e))
+
 	def __del__(self):
 		try:
 			self.lvm_shell.terminate()
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 638323a..d76b5c3 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -92,6 +92,7 @@ def process_request():
 
 
 def main():
+	start = time.time()
 	# Add simple command line handling
 	parser = argparse.ArgumentParser()
 	parser.add_argument("--udev", action='store_true',
@@ -112,16 +113,13 @@ def main():
 	# Ensure that we get consistent output for parsing stdout/stderr
 	os.environ["LC_ALL"] = "C"
 
-	args = parser.parse_args()
+	cfg.args = parser.parse_args()
 
-	cfg.DEBUG = args.debug
-	cmdhandler.set_execution(args.use_lvm_shell)
+	cmdhandler.set_execution(cfg.args.use_lvm_shell)
 
 	# List of threads that we start up
 	thread_list = []
 
-	start = time.time()
-
 	# Install signal handlers
 	for s in [signal.SIGHUP, signal.SIGINT]:
 		try:
@@ -144,7 +142,7 @@ def main():
 
 	cfg.load = load
 
-	cfg.db = lvmdb.DataStore(args.use_json)
+	cfg.db = lvmdb.DataStore(cfg.args.use_json)
 
 	# Start up thread to monitor pv moves
 	thread_list.append(
@@ -160,23 +158,25 @@ def main():
 		process.damon = True
 		process.start()
 
+	# Add udev watching
+	if cfg.args.use_udev:
+		log_debug('Utilizing udev to trigger updates')
+
+	# In all cases we are going to monitor for udev until we get an
+	# ExternalEvent.  In the case where we get an external event and the user
+	# didn't specify --udev we will stop monitoring udev
+	udevwatch.add()
+
 	end = time.time()
 	log_debug(
 		'Service ready! total time= %.4f, lvm time= %.4f count= %d' %
 		(end - start, cmdhandler.total_time, cmdhandler.total_count),
 		'bg_black', 'fg_light_green')
 
-	# Add udev watching
-	if args.use_udev:
-		log_debug('Utilizing udev to trigger updates')
-		udevwatch.add()
-
 	try:
 		if cfg.run.value != 0:
 			cfg.loop.run()
-
-			if args.use_udev:
-				udevwatch.remove()
+			udevwatch.remove()
 
 			for process in thread_list:
 				process.join()
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 2388d8a..79254fe 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -17,7 +17,7 @@ from . import cmdhandler
 from .fetch import load_pvs, load_vgs
 from .request import RequestEntry
 from .refresh import event_add
-
+from . import udevwatch
 
 # noinspection PyPep8Naming
 class Manager(AutomatedProperties):
@@ -181,6 +181,13 @@ class Manager(AutomatedProperties):
 		in_signature='s', out_signature='i')
 	def ExternalEvent(self, command):
 
+		# If a user didn't explicitly specify udev, we will turn it off now.
+		if not cfg.args.use_udev:
+			if udevwatch.remove():
+				utils.log_debug("ExternalEvent received, disabling "
+								"udev monitoring")
+				# We are dependent on external events now to stay current!
+				cfg.ee = True
 		event_add((command,))
 		return dbus.Int32(0)
 
diff --git a/daemons/lvmdbusd/udevwatch.py b/daemons/lvmdbusd/udevwatch.py
index c3e6e60..6d56443 100644
--- a/daemons/lvmdbusd/udevwatch.py
+++ b/daemons/lvmdbusd/udevwatch.py
@@ -8,10 +8,12 @@
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 import pyudev
+import threading
 from .refresh import event_add
 from . import cfg
 
 observer = None
+observer_lock = threading.RLock()
 
 
 # noinspection PyUnusedLocal
@@ -40,15 +42,20 @@ def filter_event(action, device):
 
 
 def add():
-	global observer
-	context = pyudev.Context()
-	monitor = pyudev.Monitor.from_netlink(context)
-	monitor.filter_by('block')
-	observer = pyudev.MonitorObserver(monitor, filter_event)
-	observer.start()
+	with observer_lock:
+		global observer
+		context = pyudev.Context()
+		monitor = pyudev.Monitor.from_netlink(context)
+		monitor.filter_by('block')
+		observer = pyudev.MonitorObserver(monitor, filter_event)
+		observer.start()
 
 
 def remove():
-	global observer
-	observer.stop()
-	observer = None
+	with observer_lock:
+		global observer
+		if observer:
+			observer.stop()
+			observer = None
+			return True
+		return False
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 9db7857..65668fc 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -265,7 +265,7 @@ def _common_log(msg, *attributes):
 # @param msg    Message to output to stdout
 # @return None
 def log_debug(msg, *attributes):
-	if cfg.DEBUG:
+	if cfg.args.debug:
 		_common_log(msg, *attributes)
 
 


