From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 27 Sep 2017 08:48:06 -0400
Subject: master - lvmdbusd: Main thread exception logging
Message-ID: <201709271248.v8RCm6IF023296@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2074094e778bfc298fb4cb184b6005e40acd1159
Commit:        2074094e778bfc298fb4cb184b6005e40acd1159
Parent:        090db98828694a00016395cc6c2a25fa1de953f4
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Sep 22 09:59:50 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Sep 27 07:45:00 2017 -0500

lvmdbusd: Main thread exception logging

Make sure that any and all code that executes in the main thread is
wrapped with a try/except block to ensure that at the very least
we log when things are going wrong.
---
 daemons/lvmdbusd/job.py     |    8 ++++----
 daemons/lvmdbusd/request.py |    8 ++++----
 daemons/lvmdbusd/utils.py   |   26 ++++++++++++++++----------
 3 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index 609b747..988b114 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -8,7 +8,7 @@
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 from .automatedproperties import AutomatedProperties
-from .utils import job_obj_path_generate, mt_async_result, mt_run_no_wait
+from .utils import job_obj_path_generate, mt_async_call
 from . import cfg
 from .cfg import JOB_INTERFACE
 import dbus
@@ -30,7 +30,7 @@ class WaitingClient(object):
 				# Remove ourselves from waiting client
 				wc.job_state.remove_waiting_client(wc)
 				wc.timer_id = -1
-				mt_async_result(wc.cb, wc.job_state.Complete)
+				mt_async_call(wc.cb, wc.job_state.Complete)
 				wc.job_state = None
 
 	def __init__(self, job_state, tmo, cb, cbe):
@@ -55,7 +55,7 @@ class WaitingClient(object):
 					GLib.source_remove(self.timer_id)
 					self.timer_id = -1
 
-				mt_async_result(self.cb, self.job_state.Complete)
+				mt_async_call(self.cb, self.job_state.Complete)
 				self.job_state = None
 
 
@@ -188,7 +188,7 @@ class Job(AutomatedProperties):
 	@Complete.setter
 	def Complete(self, value):
 		self.state.Complete = value
-		mt_run_no_wait(Job._signal_complete, self)
+		mt_async_call(Job._signal_complete, self)
 
 	@property
 	def GetError(self):
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index 78392de..eaec04c 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -13,7 +13,7 @@ from gi.repository import GLib
 from .job import Job
 from . import cfg
 import traceback
-from .utils import log_error, mt_async_result
+from .utils import log_error, mt_async_call
 
 
 class RequestEntry(object):
@@ -116,9 +116,9 @@ class RequestEntry(object):
 				if error_rc == 0:
 					if self.cb:
 						if self._return_tuple:
-							mt_async_result(self.cb, (result, '/'))
+							mt_async_call(self.cb, (result, '/'))
 						else:
-							mt_async_result(self.cb, result)
+							mt_async_call(self.cb, result)
 				else:
 					if self.cb_error:
 						if not error_exception:
@@ -129,7 +129,7 @@ class RequestEntry(object):
 							else:
 								error_exception = Exception(error_msg)
 
-						mt_async_result(self.cb_error, error_exception)
+						mt_async_call(self.cb_error, error_exception)
 			else:
 				# We have a job and it's complete, indicate that it's done.
 				self._job.Complete = True
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index c9fbaad..ce2ed22 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -534,20 +534,26 @@ def add_no_notify(cmdline):
 # ensure all dbus library interaction is done from the same thread!
 
 
-def _async_result(call_back, results):
-	log_debug('Results = %s' % str(results))
-	call_back(results)
+def _async_handler(call_back, parameters):
+	params_str = ", ".join([str(x) for x in parameters])
+	log_debug('Main thread execution, callback = %s, parameters = (%s)' %
+				(str(call_back), params_str))
 
+	try:
+		if parameters:
+			call_back(*parameters)
+		else:
+			call_back()
+	except:
+		st = traceback.format_exc()
+		log_error("mt_async_call: exception (logged, not reported!) \n %s" % st)
 
-# Return result in main thread
-def mt_async_result(call_back, results):
-	GLib.idle_add(_async_result, call_back, results)
 
+# Execute the function on the main thread with the provided parameters, do
+# not return *any* value or wait for the execution to complete!
+def mt_async_call(function_call_back, *parameters):
+	GLib.idle_add(_async_handler, function_call_back, parameters)
 
-# Take the supplied function and run it on the main thread and not wait for
-# a result!
-def mt_run_no_wait(function, param):
-	GLib.idle_add(function, param)
 
 # Run the supplied function and arguments on the main thread and wait for them
 # to complete while allowing the ability to get the return value too.


