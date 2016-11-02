From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  2 Nov 2016 21:48:06 +0000 (UTC)
Subject: master - lvmdbusd: Stop using threads for job wait
Message-ID: <20161102214806.5B36060B20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96118a2508e1cd3aaf5ba7a0129ff8ecc7ac4af2
Commit:        96118a2508e1cd3aaf5ba7a0129ff8ecc7ac4af2
Parent:        95abadd13c468b56612c1966d28daddfdeee6e2e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 2 14:14:56 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 2 16:39:13 2016 -0500

lvmdbusd: Stop using threads for job wait

Instead of creating a thread to handle the case where a client
is calling job.Wait, we will utilize a timer.  This significantly
reduces the number of threads that get created and destroyed while
the service is running.
---
 daemons/lvmdbusd/background.py |   29 +-------------
 daemons/lvmdbusd/job.py        |   83 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 81 insertions(+), 31 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index e8b42fe..0220b97 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -12,8 +12,7 @@ import subprocess
 from . import cfg
 from .cmdhandler import options_to_cli_args
 import dbus
-from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug, \
-	mt_async_result
+from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
 import traceback
 import os
 
@@ -184,29 +183,3 @@ def add(command, reporting_job):
 	with _rlock:
 		_thread_list.append(t)
 
-
-def wait_thread(job, timeout, cb, cbe):
-	# We need to put the wait on it's own thread, so that we don't block the
-	# entire dbus queue processing thread
-	try:
-		mt_async_result(cb, job.state.Wait(timeout))
-	except Exception as e:
-		mt_async_result(cbe, "Wait exception: %s" % str(e))
-	return 0
-
-
-def add_wait(job, timeout, cb, cbe):
-
-	if timeout == 0:
-		# Users are basically polling, do not create thread
-		mt_async_result(cb, job.Complete)
-	else:
-		t = threading.Thread(
-			target=wait_thread,
-			name="thread job.Wait: %s" % job.dbus_object_path(),
-			args=(job, timeout, cb, cbe)
-		)
-
-		t.start()
-		with _rlock:
-			_thread_list.append(t)
diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index 1158370..81048a6 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -8,12 +8,54 @@
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 from .automatedproperties import AutomatedProperties
-from .utils import job_obj_path_generate
+from .utils import job_obj_path_generate, mt_async_result, log_debug
 from . import cfg
 from .cfg import JOB_INTERFACE
 import dbus
 import threading
-from . import background
+from gi.repository import GLib
+
+
+# Class that handles a client waiting for something to be complete.  We either
+# get a timeout or the operation is done.
+class WaitingClient(object):
+
+	# A timeout occurred
+	@staticmethod
+	def _timeout(wc):
+		with wc.rlock:
+			if wc.in_use:
+				wc.in_use = False
+				# Remove ourselves from waiting client
+				wc.job_state.remove_waiting_client(wc)
+				wc.timer_id = -1
+				mt_async_result(wc.cb, wc.job_state.Complete)
+				wc.job_state = None
+
+	def __init__(self, job_state, tmo, cb, cbe):
+		self.rlock = threading.RLock()
+		self.job_state = job_state
+		self.cb = cb
+		self.cbe = cbe
+		self.in_use = True		# Indicates if object is in play
+		self.timer_id = -1
+		if tmo > 0:
+			self.timer_id = GLib.timeout_add_seconds(
+				tmo, WaitingClient._timeout, self)
+
+	# The job finished before the timer popped and we are being notified that
+	# it's done
+	def notify(self):
+		with self.rlock:
+			if self.in_use:
+				self.in_use = False
+				# Clear timer
+				if self.timer_id != -1:
+					GLib.source_remove(self.timer_id)
+					self.timer_id = -1
+
+				mt_async_result(self.cb, self.job_state.Complete)
+				self.job_state = None
 
 
 # noinspection PyPep8Naming
@@ -27,6 +69,7 @@ class JobState(object):
 		self._cond = threading.Condition(self.rlock)
 		self._ec = 0
 		self._stderr = ''
+		self._waiting_clients = []
 
 		# This is an lvm command that is just taking too long and doesn't
 		# support background operation
@@ -58,6 +101,7 @@ class JobState(object):
 			self._complete = value
 			self._percent = 100
 			self._cond.notify_all()
+			self.notify_waiting_clients()
 
 	@property
 	def GetError(self):
@@ -101,6 +145,35 @@ class JobState(object):
 				return self._request.result()
 			return '/'
 
+	def add_waiting_client(self, client):
+		with self.rlock:
+			# Avoid race condition where it goes complete before we get added
+			# to the list of waiting clients
+			if self.Complete:
+				client.notify()
+			else:
+				self._waiting_clients.append(client)
+
+	def remove_waiting_client(self, client):
+		# If a waiting client timer pops before the job is done we will allow
+		# the client to remove themselves from the list.  As we have a lock
+		# here and a lock in the waiting client too, and they can be obtained
+		# in different orders, a dead lock can occur.
+		# As this remove is really optional, we will try to acquire the lock
+		# and remove.  If we are unsuccessful it's not fatal, we just delay
+		# the time when the objects can be garbage collected by python
+		if self.rlock.acquire(False):
+			try:
+				self._waiting_clients.remove(client)
+			finally:
+				self.rlock.release()
+
+	def notify_waiting_clients(self):
+		with self.rlock:
+			for c in self._waiting_clients:
+				c.notify()
+
+			self._waiting_clients = []
 
 # noinspection PyPep8Naming
 class Job(AutomatedProperties):
@@ -155,7 +228,11 @@ class Job(AutomatedProperties):
 							out_signature='b',
 							async_callbacks=('cb', 'cbe'))
 	def Wait(self, timeout, cb, cbe):
-		background.add_wait(self, timeout, cb, cbe)
+		if timeout == 0 or self.state.Complete:
+			cb(dbus.Boolean(self.state.Complete))
+		else:
+			self.state.add_waiting_client(
+				WaitingClient(self.state, timeout, cb, cbe))
 
 	@property
 	def Result(self):


