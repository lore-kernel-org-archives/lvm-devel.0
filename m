From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 17 Jun 2021 14:17:01 +0000 (GMT)
Subject: main - lvmdbusd: Handle arbitrary amounts stdout & stderr
Message-ID: <20210617141701.62A273857431@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c474f174cc8b0e855f984bf211f5416b42c644a1
Commit:        c474f174cc8b0e855f984bf211f5416b42c644a1
Parent:        71cb54d92f96b8da318c8f8380e7ce0bdf0a11bf
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 11 10:35:31 2021 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 17 09:14:29 2021 -0500

lvmdbusd: Handle arbitrary amounts stdout & stderr

When exec'ing lvm, it's possible to get large amounts of both stdout
and stderr depending on the state of lvm and the size of the lvm
configuration.  If we allow any of the buffers to fill we can end
up deadlocking the process.  Ensure we are handling stdout & stderr
during lvm execution.

Ref. https://bugzilla.redhat.com/show_bug.cgi?id=1966636

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/background.py         | 71 +++++++++++++++-------------------
 daemons/lvmdbusd/cmdhandler.py         | 65 +++++++++++++++++++++++++------
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 26 ++++---------
 daemons/lvmdbusd/utils.py              | 14 +++++++
 4 files changed, 107 insertions(+), 69 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 3b77a7cc6..32b2cdc38 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -9,13 +9,14 @@
 
 import subprocess
 from . import cfg
-from .cmdhandler import options_to_cli_args, LvmExecutionMeta
+from .cmdhandler import options_to_cli_args, LvmExecutionMeta, call_lvm
 import dbus
 from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug,\
-	add_no_notify
-import os
+					mt_async_call
+from .request import RequestEntry
 import threading
 import time
+import traceback
 
 
 def pv_move_lv_cmd(move_options, lv_full_name,
@@ -39,58 +40,50 @@ def lv_merge_cmd(merge_options, lv_full_name):
 	return cmd
 
 
-def _move_merge(interface_name, command, job_state):
-	# We need to execute these command stand alone by forking & exec'ing
-	# the command always as we will be getting periodic output from them on
-	# the status of the long running operation.
-	command.insert(0, cfg.LVM_CMD)
-
-	# Instruct lvm to not register an event with us
-	command = add_no_notify(command)
+def _load_wrapper(ignored):
+	cfg.load()
 
-	#(self, start, ended, cmd, ec, stdout_txt, stderr_txt)
-	meta = LvmExecutionMeta(time.time(), 0, command, -1000, None, None)
 
-	cfg.blackbox.add(meta)
+def _move_callback(job_state, line_str):
+	try:
+		if line_str.count(':') == 2:
+			(device, ignore, percentage) = line_str.split(':')
 
-	process = subprocess.Popen(command, stdout=subprocess.PIPE,
-								env=os.environ,
-								stderr=subprocess.PIPE, close_fds=True)
+			job_state.Percent = int(round(
+				float(percentage.strip()[:-1]), 1))
 
-	log_debug("Background process for %s is %d" %
-				(str(command), process.pid))
+			# While the move is in progress we need to periodically update
+			# the state to reflect where everything is at.  we will do this
+			# by scheduling the load to occur in the main work queue.
+			r = RequestEntry(
+				-1, _load_wrapper, ("_move_callback: load",), None, None, False)
+			cfg.worker_q.put(r)
+	except ValueError:
+		log_error("Trying to parse percentage which failed for %s" % line_str)
 
-	lines_iterator = iter(process.stdout.readline, b"")
-	for line in lines_iterator:
-		line_str = line.decode("utf-8")
 
-		# Check to see if the line has the correct number of separators
-		try:
-			if line_str.count(':') == 2:
-				(device, ignore, percentage) = line_str.split(':')
-				job_state.Percent = round(
-					float(percentage.strip()[:-1]), 1)
+def _move_merge(interface_name, command, job_state):
+	# We need to execute these command stand alone by forking & exec'ing
+	# the command always as we will be getting periodic output from them on
+	# the status of the long running operation.
 
-				# While the move is in progress we need to periodically update
-				# the state to reflect where everything is at.
-				cfg.load()
-		except ValueError:
-			log_error("Trying to parse percentage which failed for %s" %
-				line_str)
+	meta = LvmExecutionMeta(time.time(), 0, command, -1000, None, None)
+	cfg.blackbox.add(meta)
 
-	out = process.communicate()
+	ec, stdout, stderr = call_lvm(command, line_cb=_move_callback,
+									cb_data=job_state)
 
 	with meta.lock:
 		meta.ended = time.time()
-		meta.ec = process.returncode
-		meta.stderr_txt = out[1]
+		meta.ec = ec
+		meta.stderr_txt = stderr
 
-	if process.returncode == 0:
+	if ec == 0:
 		job_state.Percent = 100
 	else:
 		raise dbus.exceptions.DBusException(
 			interface_name,
-			'Exit code %s, stderr = %s' % (str(process.returncode), out[1]))
+			'Exit code %s, stderr = %s' % (str(ec), stderr))
 
 	cfg.load()
 	return '/'
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 1c15b7888..91f69abcf 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -8,6 +8,7 @@
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 from subprocess import Popen, PIPE
+import select
 import time
 import threading
 from itertools import chain
@@ -16,7 +17,8 @@ import traceback
 import os
 
 from lvmdbusd import cfg
-from lvmdbusd.utils import pv_dest_ranges, log_debug, log_error, add_no_notify
+from lvmdbusd.utils import pv_dest_ranges, log_debug, log_error, add_no_notify,\
+							make_non_block, read_decoded
 from lvmdbusd.lvm_shell_proxy import LVMShellProxy
 
 try:
@@ -82,16 +84,23 @@ def _debug_c(cmd, exit_code, out):
 	log_error(("STDERR=\n %s\n" % out[1]))
 
 
-def call_lvm(command, debug=False):
+def call_lvm(command, debug=False, line_cb=None,
+			 cb_data=None):
 	"""
 	Call an executable and return a tuple of exitcode, stdout, stderr
-	:param command:     Command to execute
-	:param debug:       Dump debug to stdout
+	:param command: Command to execute
+	:param debug:   Dump debug to stdout
+	:param line_cb:	Call the supplied function for each line read from
+					stdin, CALL MUST EXECUTE QUICKLY and not *block*
+					otherwise call_lvm function will fail to read
+					stdin/stdout.  Return value of call back is ignored
+	:param cb_data: Supplied to callback to allow caller access to
+								its own data
+
+	# Callback signature
+	def my_callback(my_context, line_read_stdin)
+		pass
 	"""
-	# print 'STACK:'
-	# for line in traceback.format_stack():
-	#    print line.strip()
-
 	# Prepend the full lvm executable so that we can run different versions
 	# in different locations on the same box
 	command.insert(0, cfg.LVM_CMD)
@@ -99,10 +108,44 @@ def call_lvm(command, debug=False):
 
 	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True,
 					env=os.environ)
-	out = process.communicate()
 
-	stdout_text = bytes(out[0]).decode("utf-8")
-	stderr_text = bytes(out[1]).decode("utf-8")
+	stdout_text = ""
+	stderr_text = ""
+	stdout_index = 0
+	make_non_block(process.stdout)
+	make_non_block(process.stderr)
+
+	while True:
+		try:
+			rd_fd = [process.stdout.fileno(), process.stderr.fileno()]
+			ready = select.select(rd_fd, [], [], 2)
+
+			for r in ready[0]:
+				if r == process.stdout.fileno():
+					stdout_text += read_decoded(process.stdout)
+				elif r == process.stderr.fileno():
+					stderr_text += read_decoded(process.stderr)
+
+			if line_cb is not None:
+				# Process the callback for each line read!
+				while True:
+					i = stdout_text.find("\n", stdout_index)
+					if i != -1:
+						try:
+							line_cb(cb_data, stdout_text[stdout_index:i])
+						except:
+							st = traceback.format_exc()
+							log_error("call_lvm: line_cb exception: \n %s" % st)
+						stdout_index = i + 1
+					else:
+						break
+
+			# Check to see if process has terminated, None when running
+			if process.poll() is not None:
+				break
+		except IOError as ioe:
+			log_debug("call_lvm:" + str(ioe))
+			pass
 
 	if debug or process.returncode != 0:
 		_debug_c(command, process.returncode, (stdout_text, stderr_text))
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index b76b336c2..7816daa8b 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -13,7 +13,6 @@
 
 import subprocess
 import shlex
-from fcntl import fcntl, F_GETFL, F_SETFL
 import os
 import traceback
 import sys
@@ -29,7 +28,8 @@ except ImportError:
 
 
 from lvmdbusd.cfg import LVM_CMD
-from lvmdbusd.utils import log_debug, log_error, add_no_notify
+from lvmdbusd.utils import log_debug, log_error, add_no_notify, make_non_block,\
+							read_decoded
 
 SHELL_PROMPT = "lvm> "
 
@@ -43,13 +43,6 @@ def _quote_arg(arg):
 
 class LVMShellProxy(object):
 
-	@staticmethod
-	def _read(stream):
-		tmp = stream.read()
-		if tmp:
-			return tmp.decode("utf-8")
-		return ''
-
 	# Read until we get prompt back and a result
 	# @param: no_output	Caller expects no output to report FD
 	# Returns stdout, report, stderr (report is JSON!)
@@ -75,11 +68,11 @@ class LVMShellProxy(object):
 
 				for r in ready[0]:
 					if r == self.lvm_shell.stdout.fileno():
-						stdout += LVMShellProxy._read(self.lvm_shell.stdout)
+						stdout += read_decoded(self.lvm_shell.stdout)
 					elif r == self.report_stream.fileno():
-						report += LVMShellProxy._read(self.report_stream)
+						report += read_decoded(self.report_stream)
 					elif r == self.lvm_shell.stderr.fileno():
-						stderr += LVMShellProxy._read(self.lvm_shell.stderr)
+						stderr += read_decoded(self.lvm_shell.stderr)
 
 				# Check to see if the lvm process died on us
 				if self.lvm_shell.poll():
@@ -124,11 +117,6 @@ class LVMShellProxy(object):
 		assert (num_written == len(cmd_bytes))
 		self.lvm_shell.stdin.flush()
 
-	@staticmethod
-	def _make_non_block(stream):
-		flags = fcntl(stream, F_GETFL)
-		fcntl(stream, F_SETFL, flags | os.O_NONBLOCK)
-
 	def __init__(self):
 
 		# Create a temp directory
@@ -162,8 +150,8 @@ class LVMShellProxy(object):
 			stderr=subprocess.PIPE, close_fds=True, shell=True)
 
 		try:
-			LVMShellProxy._make_non_block(self.lvm_shell.stdout)
-			LVMShellProxy._make_non_block(self.lvm_shell.stderr)
+			make_non_block(self.lvm_shell.stdout)
+			make_non_block(self.lvm_shell.stderr)
 
 			# wait for the first prompt
 			errors = self._read_until_prompt(no_output=True)[2]
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 66dfbd691..cc221fc2d 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -14,6 +14,7 @@ import ctypes
 import os
 import string
 import datetime
+from fcntl import fcntl, F_GETFL, F_SETFL
 
 import dbus
 from lvmdbusd import cfg
@@ -681,3 +682,16 @@ def _remove_objects(dbus_objects_rm):
 # Remove dbus objects from main thread
 def mt_remove_dbus_objects(objs):
 	MThreadRunner(_remove_objects, objs).done()
+
+
+# Make stream non-blocking
+def make_non_block(stream):
+	flags = fcntl(stream, F_GETFL)
+	fcntl(stream, F_SETFL, flags | os.O_NONBLOCK)
+
+
+def read_decoded(stream):
+	tmp = stream.read()
+	if tmp:
+		return tmp.decode("utf-8")
+	return ''


