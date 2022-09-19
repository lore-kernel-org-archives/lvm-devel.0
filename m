From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:17 +0000 (GMT)
Subject: main - lvmdbusd: Add debug circular buffer
Message-ID: <20220919155817.309D03858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0c7220dbbb38c54f3d47afc9748b53438bc154e
Commit:        b0c7220dbbb38c54f3d47afc9748b53438bc154e
Parent:        f65f7da76065b2e36920ae4f866e9e912f74dde2
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 17 17:24:08 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Add debug circular buffer

When the daemon isn't started with --debug we will keep a circular
buffer of the past N number of debug messages which we will output
when we encounter an issue.
---
 daemons/lvmdbusd/cfg.py        |  3 +++
 daemons/lvmdbusd/cmdhandler.py |  2 ++
 daemons/lvmdbusd/fetch.py      |  1 +
 daemons/lvmdbusd/main.py       |  5 ++++-
 daemons/lvmdbusd/manager.py    |  1 +
 daemons/lvmdbusd/request.py    |  1 +
 daemons/lvmdbusd/utils.py      | 38 +++++++++++++++++++++++++++++++++++---
 7 files changed, 47 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index d7a653b54..a758b8a77 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -97,6 +97,9 @@ flightrecorder = None
 # RequestEntry ctor
 create_request_entry = None
 
+# Circular debug log
+debug = None
+
 
 def exit_daemon():
     """
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index b2d3077ad..7605f8298 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -88,6 +88,7 @@ class LvmFlightRecorder(object):
 				for c in reversed(self.queue):
 					log_error(str(c))
 				log_error("LVM dbus flight recorder END")
+				self.queue.clear()
 
 
 cfg.flightrecorder = LvmFlightRecorder()
@@ -176,6 +177,7 @@ def call_lvm(command, debug=False, line_cb=None,
 		return -errno.EINTR, "", "operation interrupted"
 
 
+
 # The actual method which gets called to invoke the lvm command, can vary
 # from forking a new process to using lvm shell
 _t_call = call_lvm
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index f1e9104a8..ed519b660 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -195,6 +195,7 @@ class StateUpdate(object):
 			except Exception as e:
 				st = traceback.format_exc()
 				log_error("update_thread exception: \n%s" % st)
+				cfg.debug.dump()
 				cfg.flightrecorder.dump()
 				exception_count += 1
 				if exception_count >= 5:
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index c58c518d1..3fcabe6b6 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -25,7 +25,7 @@ from .manager import Manager
 import traceback
 import queue
 from . import udevwatch
-from .utils import log_debug, log_error, log_msg
+from .utils import log_debug, log_error, log_msg, DebugMessages
 import argparse
 import os
 import sys
@@ -147,6 +147,9 @@ def main():
 	# cmdhandler is for when we are running other code with a different main.
 	cfg.flightrecorder = LvmFlightRecorder(cfg.args.fr_size)
 
+	# Create a circular buffer for debug logs
+	cfg.debug = DebugMessages()
+
 	log_debug("Using lvm binary: %s" % cfg.LVM_CMD)
 
 	# We will dynamically add interfaces which support vdo if it
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 45e7bb0b8..9c41f0fc3 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -137,6 +137,7 @@ class Manager(AutomatedProperties):
 		"""
 		Dump the flight recorder to syslog
 		"""
+		cfg.debug.dump()
 		cfg.flightrecorder.dump()
 
 	@staticmethod
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index e069cfdc1..546b85b23 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -76,6 +76,7 @@ class RequestEntry(object):
 			# have gotten a job by the time we hit an error
 			# Lets get the stacktrace and set that to the error message
 			st = traceback.format_exc()
+			cfg.debug.dump()
 			cfg.flightrecorder.dump()
 			log_error("Exception returned to client: \n%s" % st)
 			self.register_error(-1, str(e), e)
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 75a5348f5..802f71173 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -10,6 +10,7 @@
 import xml.etree.ElementTree as Et
 import sys
 import inspect
+import collections
 import ctypes
 import errno
 import fcntl
@@ -282,8 +283,28 @@ def parse_tags(tags):
 	return dbus.Array([], signature='s')
 
 
-def _common_log(msg, *attributes):
-	cfg.stdout_lock.acquire()
+class DebugMessages(object):
+
+	def __init__(self, size=5000):
+		self.queue = collections.deque(maxlen=size)
+		self.lock = threading.RLock()
+
+	def add(self, message):
+		with self.lock:
+			self.queue.append(message)
+
+	def dump(self):
+		if cfg.args and not cfg.args.debug:
+			with self.lock:
+				if len(self.queue):
+					log_error("LVM dbus debug messages START last (%d max) messages" % self.queue.maxlen)
+					for m in self.queue:
+						print(m)
+					log_error("LVM dbus debug messages END")
+					self.queue.clear()
+
+
+def _format_log_entry(msg):
 	tid = ctypes.CDLL('libc.so.6').syscall(186)
 
 	if STDOUT_TTY:
@@ -293,6 +314,12 @@ def _common_log(msg, *attributes):
 
 	else:
 		msg = "%d:%d - %s" % (os.getpid(), tid, msg)
+	return msg
+
+
+def _common_log(msg, *attributes):
+	cfg.stdout_lock.acquire()
+	msg = _format_log_entry(msg)
 
 	if STDOUT_TTY and attributes:
 		print(color(msg, *attributes))
@@ -309,6 +336,9 @@ def _common_log(msg, *attributes):
 def log_debug(msg, *attributes):
 	if cfg.args and cfg.args.debug:
 		_common_log(msg, *attributes)
+	else:
+		if cfg.debug:
+			cfg.debug.add(_format_log_entry(msg))
 
 
 def log_error(msg, *attributes):
@@ -348,13 +378,15 @@ def handler(signum):
 	try:
 		# signal 10
 		if signum == signal.SIGUSR1:
+			cfg.debug.dump()
 			dump_threads_stackframe()
 		# signal 12
 		elif signum == signal.SIGUSR2:
+			cfg.debug.dump()
 			cfg.flightrecorder.dump()
 		else:
 			cfg.run.value = 0
-			log_debug('Exiting daemon with signal %d' % signum)
+			log_error('Exiting daemon with signal %d' % signum)
 			if cfg.loop is not None:
 				cfg.loop.quit()
 	except:

