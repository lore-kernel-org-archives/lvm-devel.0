From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:05 +0000 (GMT)
Subject: main - lvmdbusd: fix hangs on SIGINT
Message-ID: <20220919155805.C92123858418@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d8882db833909bede4b8cbcc81c1c3b9d9b3515
Commit:        3d8882db833909bede4b8cbcc81c1c3b9d9b3515
Parent:        f4cb78a4e1ac2cf7cc30d76e86765618071b2813
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 17 17:21:19 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: fix hangs on SIGINT

Rather than trying to bubble up return codes that get us to exit cleanly
it's better to just raise an exception to bail.  In some cases functions
don't have return codes, so they cannot be checked.
---
 daemons/lvmdbusd/cmdhandler.py         | 20 ++++++++++++------
 daemons/lvmdbusd/fetch.py              | 37 ++++++++++++++++++++++++----------
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 10 +++++++--
 daemons/lvmdbusd/main.py               |  1 +
 4 files changed, 49 insertions(+), 19 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 0422f8970..b2d3077ad 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -6,7 +6,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
-
+import errno
 from subprocess import Popen, PIPE
 import select
 import time
@@ -131,7 +131,7 @@ def call_lvm(command, debug=False, line_cb=None,
 	make_non_block(process.stdout)
 	make_non_block(process.stderr)
 
-	while True:
+	while True and cfg.run.value != 0:
 		try:
 			rd_fd = [process.stdout.fileno(), process.stderr.fileno()]
 			ready = select.select(rd_fd, [], [], 2)
@@ -161,12 +161,20 @@ def call_lvm(command, debug=False, line_cb=None,
 				break
 		except IOError as ioe:
 			log_debug("call_lvm:" + str(ioe))
-			pass
+			break
+
+	if process.returncode is not None:
+		if debug or process.returncode != 0:
+			_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
-	if debug or process.returncode != 0:
-		_debug_c(command, process.returncode, (stdout_text, stderr_text))
+		return process.returncode, stdout_text, stderr_text
+	else:
+		if cfg.run.value == 0:
+			raise Exception("Daemon is exiting!")
+		# We can bail out before the lvm command finished when we get a signal
+		# which is requesting we exit
+		return -errno.EINTR, "", "operation interrupted"
 
-	return process.returncode, stdout_text, stderr_text
 
 # The actual method which gets called to invoke the lvm command, can vary
 # from forking a new process to using lvm shell
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 740b15fdb..f1e9104a8 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -120,8 +120,26 @@ class StateUpdate(object):
 	@staticmethod
 	def update_thread(obj):
 		exception_count = 0
-
 		queued_requests = []
+
+		def set_results(val):
+			nonlocal queued_requests
+			for idx in queued_requests:
+				idx.set_result(val)
+				# Only clear out the requests after we have given them a result
+				# otherwise we can orphan the waiting threads, and they never
+				# wake up if we get an exception
+				queued_requests = []
+
+		def bailing(rv):
+			set_results(rv)
+			try:
+				while True:
+					item = obj.queue.get(False)
+					item.set_result(rv)
+			except queue.Empty:
+				pass
+
 		while cfg.run.value != 0:
 			# noinspection PyBroadException
 			try:
@@ -167,13 +185,7 @@ class StateUpdate(object):
 				num_changes = load(refresh, emit_signal, cache_refresh, log,
 									need_main_thread)
 				# Update is done, let everyone know!
-				for i in queued_requests:
-					i.set_result(num_changes)
-
-				# Only clear out the requests after we have given them a result
-				# otherwise we can orphan the waiting threads and they never
-				# wake up if we get an exception
-				queued_requests = []
+				set_results(num_changes)
 
 				# We retrieved OK, clear exception count
 				exception_count = 0
@@ -186,9 +198,7 @@ class StateUpdate(object):
 				cfg.flightrecorder.dump()
 				exception_count += 1
 				if exception_count >= 5:
-					for i in queued_requests:
-						i.set_result(e)
-
+					bailing(e)
 					log_error("Too many errors in update_thread, exiting daemon")
 					cfg.exit_daemon()
 
@@ -196,6 +206,11 @@ class StateUpdate(object):
 					# Slow things down when encountering errors
 					time.sleep(1)
 
+		# Make sure to unblock any that may be waiting before we exit this thread
+		# otherwise they hang forever ...
+		bailing(Exception("update thread exiting"))
+		log_debug("update thread exiting!")
+
 	def __init__(self):
 		self.lock = threading.RLock()
 		self.queue = queue.Queue()
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 43609047b..ebab57e97 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -26,7 +26,7 @@ except ImportError:
 	import json
 
 
-from lvmdbusd.cfg import LVM_CMD
+from lvmdbusd.cfg import LVM_CMD, run
 from lvmdbusd.utils import log_debug, log_error, add_no_notify, make_non_block,\
 							read_decoded
 
@@ -57,7 +57,7 @@ class LVMShellProxy(object):
 		# a hang.  Keep reading until we get the prompt back and the report
 		# FD does not contain valid JSON
 
-		while keep_reading:
+		while keep_reading and run.value != 0:
 			try:
 				rd_fd = [
 					self.lvm_shell.stdout.fileno(),
@@ -230,6 +230,12 @@ class LVMShellProxy(object):
 			log_error(("EC = %d" % rc))
 			log_error(("ERROR_MSG=\n %s\n" % error_msg))
 
+			if run.value == 0:
+				# Try to clean up lvm shelll process
+				log_debug("exiting lvm shell as we are shutting down")
+				self.exit_shell()
+				raise Exception("Daemon is exiting!")
+
 		return rc, report_json, error_msg
 
 	def exit_shell(self):
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 5369f1dd5..dc6aa2277 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -53,6 +53,7 @@ def process_request():
 		except Exception:
 			st = traceback.format_exc()
 			utils.log_error("process_request exception: \n%s" % st)
+	log_debug("process_request thread exiting!")
 
 
 def check_fr_size(value):

