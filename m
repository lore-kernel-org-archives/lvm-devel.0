From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  2 Nov 2016 21:47:57 +0000 (UTC)
Subject: master - lvmdbusd: Return results in main thread
Message-ID: <20161102214757.D919C60AD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24803bbaadd8bd497e2ca337786b01725df61736
Commit:        24803bbaadd8bd497e2ca337786b01725df61736
Parent:        c8e8439b3dc037fd73a2eab94e7e796cfb8283a1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 1 17:48:39 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 2 16:38:00 2016 -0500

lvmdbusd: Return results in main thread

Also introduce some additional new code to execute code other code
in main thread too.

ref. https://bugs.freedesktop.org/show_bug.cgi?id=98521
---
 daemons/lvmdbusd/background.py |    9 +++--
 daemons/lvmdbusd/request.py    |   12 ++++----
 daemons/lvmdbusd/utils.py      |   63 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index ab0ac2a..e8b42fe 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -12,7 +12,8 @@ import subprocess
 from . import cfg
 from .cmdhandler import options_to_cli_args
 import dbus
-from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
+from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug, \
+	mt_async_result
 import traceback
 import os
 
@@ -188,9 +189,9 @@ def wait_thread(job, timeout, cb, cbe):
 	# We need to put the wait on it's own thread, so that we don't block the
 	# entire dbus queue processing thread
 	try:
-		cb(job.state.Wait(timeout))
+		mt_async_result(cb, job.state.Wait(timeout))
 	except Exception as e:
-		cbe("Wait exception: %s" % str(e))
+		mt_async_result(cbe, "Wait exception: %s" % str(e))
 	return 0
 
 
@@ -198,7 +199,7 @@ def add_wait(job, timeout, cb, cbe):
 
 	if timeout == 0:
 		# Users are basically polling, do not create thread
-		cb(job.Complete)
+		mt_async_result(cb, job.Complete)
 	else:
 		t = threading.Thread(
 			target=wait_thread,
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index c48d043..ca45e8c 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -13,7 +13,7 @@ from gi.repository import GLib
 from .job import Job
 from . import cfg
 import traceback
-from .utils import log_error
+from .utils import log_error, mt_async_result
 
 
 class RequestEntry(object):
@@ -57,9 +57,9 @@ class RequestEntry(object):
 		self._job = Job(self, self._job_state)
 		cfg.om.register_object(self._job, True)
 		if self._return_tuple:
-			self.cb(('/', self._job.dbus_object_path()))
+			mt_async_result(self.cb, ('/', self._job.dbus_object_path()))
 		else:
-			self.cb(self._job.dbus_object_path())
+			mt_async_result(self.cb, self._job.dbus_object_path())
 
 	def run_cmd(self):
 		try:
@@ -110,9 +110,9 @@ class RequestEntry(object):
 				if error_rc == 0:
 					if self.cb:
 						if self._return_tuple:
-							self.cb((result, '/'))
+							mt_async_result(self.cb, (result, '/'))
 						else:
-							self.cb(result)
+							mt_async_result(self.cb, result)
 				else:
 					if self.cb_error:
 						if not error_exception:
@@ -123,7 +123,7 @@ class RequestEntry(object):
 							else:
 								error_exception = Exception(error_msg)
 
-						self.cb_error(error_exception)
+						mt_async_result(self.cb_error, error_exception)
 			else:
 				# We have a job and it's complete, indicate that it's done.
 				# TODO: We need to signal the job is done too.
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index ef7e61f..12b797e 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -17,6 +17,8 @@ import datetime
 
 import dbus
 from lvmdbusd import cfg
+from gi.repository import GLib
+import threading
 
 
 STDOUT_TTY = os.isatty(sys.stdout.fileno())
@@ -494,3 +496,64 @@ def validate_tag(interface, tag):
 		raise dbus.exceptions.DBusException(
 			interface, 'tag (%s) contains invalid character, allowable set(%s)'
 			% (tag, _ALLOWABLE_TAG_CH))
+
+
+# The methods below which start with mt_* are used to execute the desired code
+# on the the main thread of execution to alleviate any issues the dbus-python
+# library with regards to multi-threaded access.  Essentially, we are trying to
+# ensure all dbus library interaction is done from the same thread!
+
+
+def _async_result(call_back, results):
+	log_debug('Results = %s' % str(results))
+	call_back(results)
+
+# Return result in main thread
+def mt_async_result(call_back, results):
+	GLib.idle_add(_async_result, call_back, results)
+
+
+# Run the supplied function and arguments on the main thread and wait for them
+# to complete while allowing the ability to get the return value too.
+#
+# Example:
+# result = MThreadRunner(foo, arg1, arg2).done()
+#
+class MThreadRunner(object):
+
+	@staticmethod
+	def runner(obj):
+		obj._run()
+		with obj.cond:
+			obj.function_complete = True
+			obj.cond.notify_all()
+
+	def __init__(self, function, *args):
+		self.f = function
+		self.rc = None
+		self.args = args
+		self.function_complete = False
+		self.cond = threading.Condition(threading.Lock())
+
+	def done(self):
+		GLib.idle_add(MThreadRunner.runner, self)
+		with self.cond:
+			if not self.function_complete:
+				self.cond.wait()
+		return self.rc
+
+	def _run(self):
+		if len(self.args):
+			self.rc = self.f(*self.args)
+		else:
+			self.rc = self.f()
+
+
+def _remove_objects(dbus_objects_rm):
+	for o in dbus_objects_rm:
+		cfg.om.remove_object(o, emit_signal=True)
+
+
+# Remove dbus objects from main thread
+def mt_remove_dbus_objects(objs):
+	MThreadRunner(_remove_objects, objs).done()


