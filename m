From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:31 +0000 (UTC)
Subject: master - lvmdbusd: Fix hang when lvm compiled with 'enable-notify-dbus'
Message-ID: <20160628192431.60CE660FFF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd5d865020acd545712d4bcc0f3236143de4d76d
Commit:        dd5d865020acd545712d4bcc0f3236143de4d76d
Parent:        5274c2f11b9e262588c1dec86609e829618d2e76
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 28 12:07:21 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:09:28 2016 -0500

lvmdbusd: Fix hang when lvm compiled with 'enable-notify-dbus'

The following operations would hang if lvm was compiled with
'enable-notify-dbus' and the client specified -1 for the timeout:

* LV snapshot merge
* VG move
* LV move

This was caused because the implementation of these three dbus methods is
different.  Most of the dbus method calls are executed by gathering information
needed to fulfill it, placing that information on a thread safe queue and
returning.  The results later to be returned to the client with callbacks.
With this approach we can process an arbitrary number of commands without any
of them blocking other dbus commands.  However, the 3 dbus methods listed
above did not utilize this functionality because they were implemented with a
separate thread that handles the fork & exec of lvm.  This is done because these
operations can be very slow to complete.  However, because of this the lvm
command that we were waiting on is trying to call back into the dbus service to
notify it that something changed.  Because the code was blocking the process
that handles the incoming dbus activity the lvm command blocked.  We were stuck
until the client timed-out the connection, which then causes the service to
unblock and continue.  If the client did not have a timeout, we would have been
hung indefinitely.

The fix is to always utilize the worker queue on all dbus methods.  We need to
ensure that lvm is tested with 'enable-notify-dbus' enabled and disabled.
---
 daemons/lvmdbusd/background.py |   77 ++++++++++-----------------------------
 daemons/lvmdbusd/job.py        |    2 +-
 daemons/lvmdbusd/lv.py         |   34 ++++++++++++-----
 daemons/lvmdbusd/request.py    |    5 ++-
 daemons/lvmdbusd/vg.py         |   19 +++++++---
 5 files changed, 62 insertions(+), 75 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 4265154..ca3d60e 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -43,40 +43,22 @@ def lv_merge_cmd(merge_options, lv_full_name):
 	return cmd
 
 
-def _create_background_dbus_job(job_state):
-	job_obj = Job(None, job_state)
-	cfg.om.register_object(job_obj)
-	return job_obj.dbus_object_path()
-
-
-def _move_merge(interface_name, cmd, time_out):
-	# Create job object to be used while running the command
-	rc = '/'
-	job_state = JobState(None)
+def _move_merge(interface_name, cmd, job_state):
 	add(cmd, job_state)
 
-	if time_out == -1:
-		# Waiting forever
-		done = job_state.Wait(time_out)
-		if not done:
-			ec, err_msg = job_state.GetError
-			raise dbus.exceptions.DBusException(
-				interface_name,
-				'Exit code %s, stderr = %s' % (str(ec), err_msg))
-	elif time_out == 0:
-		# Immediately create and return a job
-		rc = _create_background_dbus_job(job_state)
-	else:
-		# Willing to wait for a bit
-		done = job_state.Wait(time_out)
-		if not done:
-			rc = _create_background_dbus_job(job_state)
+	done = job_state.Wait(-1)
+	if not done:
+		ec, err_msg = job_state.GetError
+		raise dbus.exceptions.DBusException(
+			interface_name,
+			'Exit code %s, stderr = %s' % (str(ec), err_msg))
 
-	return rc
+	cfg.load()
+	return '/'
 
 
 def move(interface_name, lv_name, pv_src_obj, pv_source_range,
-			pv_dests_and_ranges, move_options, time_out):
+			pv_dests_and_ranges, move_options, job_state):
 	"""
 	Common code for the pvmove handling.
 	:param interface_name:  What dbus interface we are providing for
@@ -85,8 +67,8 @@ def move(interface_name, lv_name, pv_src_obj, pv_source_range,
 	:param pv_source_range: (0,0 to ignore, else start, end segments)
 	:param pv_dests_and_ranges: Array of PV object paths and start/end segs
 	:param move_options: Hash with optional arguments
-	:param time_out:
-	:return: Object path to job object
+	:param job_state: Used to convey information about jobs between processes
+	:return: '/' When complete, the empty object path
 	"""
 	pv_dests = []
 	pv_src = cfg.om.get_object_by_path(pv_src_obj)
@@ -112,18 +94,18 @@ def move(interface_name, lv_name, pv_src_obj, pv_source_range,
 								pv_source_range,
 								pv_dests)
 
-		return _move_merge(interface_name, cmd, time_out)
+		return _move_merge(interface_name, cmd, job_state)
 	else:
 		raise dbus.exceptions.DBusException(
 			interface_name, 'pv_src_obj (%s) not found' % pv_src_obj)
 
 
-def merge(interface_name, lv_uuid, lv_name, merge_options, time_out):
+def merge(interface_name, lv_uuid, lv_name, merge_options, job_state):
 	# Make sure we have a dbus object representing it
 	dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
 	if dbo:
 		cmd = lv_merge_cmd(merge_options, dbo.lvm_id)
-		return _move_merge(interface_name, cmd, time_out)
+		return _move_merge(interface_name, cmd, job_state)
 	else:
 		raise dbus.exceptions.DBusException(
 			interface_name,
@@ -143,17 +125,6 @@ def background_reaper():
 		time.sleep(3)
 
 
-def process_background_result(job_object, exit_code, error_msg):
-	cfg.load()
-	job_object.set_result(exit_code, error_msg)
-	return None
-
-
-# noinspection PyUnusedLocal
-def empty_cb(disregard):
-	pass
-
-
 def background_execute(command, background_job, skip_first_line=False):
 
 	# Wrap this whole operation in an exception handler, otherwise if we
@@ -181,23 +152,15 @@ def background_execute(command, background_job, skip_first_line=False):
 		if process.returncode == 0:
 			background_job.Percent = 100
 
-		# Queue up the result so that it gets executed in same thread as others.
-		r = RequestEntry(
-			-1, process_background_result,
-			(background_job, process.returncode, out[1]),
-			empty_cb, empty_cb, False)
-		cfg.worker_q.put(r)
+		background_job.set_result(process.returncode, out[1])
+
 	except Exception:
-		# In the unlikely event that we blew up, lets notify fill out the
-		# job object so that the client doesn't hang potentially forever!
+		# In the unlikely event that we blow up, we need to unblock caller which
+		# is waiting on an answer.
 		st = traceback.format_exc()
 		error = "Exception in background thread: \n%s" % st
 		log_error(error)
-		r = RequestEntry(
-			-1, process_background_result,
-			(background_job, 1, error),
-			empty_cb, empty_cb, False)
-		cfg.worker_q.put(r)
+		background_job.set_result(1, error)
 
 
 def add(command, reporting_job):
diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index b16f8e6..d7f8187 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -17,7 +17,7 @@ import threading
 
 # noinspection PyPep8Naming
 class JobState(object):
-	def __init__(self, request):
+	def __init__(self, request=None):
 		self.rlock = threading.RLock()
 
 		self._percent = 0
diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 5c7b3b5..8f063dc 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -22,6 +22,7 @@ from .loader import common
 from .state import State
 from . import background
 from .utils import round_size
+from .job import JobState
 
 
 # Try and build a key for a LV, so that we sort the LVs with least dependencies
@@ -444,14 +445,21 @@ class Lv(LvCommon):
 	@dbus.service.method(
 		dbus_interface=LV_INTERFACE,
 		in_signature='o(tt)a(ott)ia{sv}',
-		out_signature='o')
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
 	def Move(self, pv_src_obj, pv_source_range,
 				pv_dests_and_ranges,
-				tmo, move_options):
-		return background.move(
-			LV_INTERFACE, self.lvm_id, pv_src_obj,
-			pv_source_range, pv_dests_and_ranges,
-			move_options, tmo)
+				tmo, move_options, cb, cbe):
+
+		job_state = JobState()
+
+		r = RequestEntry(
+				tmo, background.move,
+				(LV_INTERFACE, self.lvm_id, pv_src_obj, pv_source_range,
+				pv_dests_and_ranges, move_options, job_state), cb, cbe, False,
+				job_state)
+
+		cfg.worker_q.put(r)
 
 	@staticmethod
 	def _snap_shot(lv_uuid, lv_name, name, optional_size,
@@ -875,7 +883,13 @@ class LvSnapShot(Lv):
 	@dbus.service.method(
 		dbus_interface=SNAPSHOT_INTERFACE,
 		in_signature='ia{sv}',
-		out_signature='o')
-	def Merge(self, tmo, merge_options):
-		return background.merge(SNAPSHOT_INTERFACE, self.Uuid, self.lvm_id,
-								merge_options, tmo)
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def Merge(self, tmo, merge_options, cb, cbe):
+		job_state = JobState()
+
+		r = RequestEntry(tmo, background.merge,
+							(SNAPSHOT_INTERFACE, self.Uuid, self.lvm_id,
+							merge_options, job_state), cb, cbe, False,
+							job_state)
+		cfg.worker_q.put(r)
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index 3e29b82..ce6a6ef 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -18,7 +18,7 @@ from .utils import log_error
 
 class RequestEntry(object):
 	def __init__(self, tmo, method, arguments, cb, cb_error,
-			return_tuple=True):
+			return_tuple=True, job_state=None):
 		self.tmo = tmo
 		self.method = method
 		self.arguments = arguments
@@ -33,6 +33,7 @@ class RequestEntry(object):
 		self._rc = 0
 		self._rc_error = None
 		self._return_tuple = return_tuple
+		self._job_state = job_state
 
 		if self.tmo < 0:
 			# Client is willing to block forever
@@ -53,7 +54,7 @@ class RequestEntry(object):
 		r.timer_expired()
 
 	def _return_job(self):
-		self._job = Job(self)
+		self._job = Job(self, self._job_state)
 		cfg.om.register_object(self._job, True)
 		if self._return_tuple:
 			self.cb(('/', self._job.dbus_object_path()))
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index c700667..4cc938e 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -20,6 +20,7 @@ from .loader import common
 from .state import State
 from . import background
 from .utils import round_size
+from .job import JobState
 
 
 # noinspection PyUnusedLocal
@@ -352,12 +353,20 @@ class Vg(AutomatedProperties):
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
 		in_signature='o(tt)a(ott)ia{sv}',
-		out_signature='o')
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
 	def Move(self, pv_src_obj, pv_source_range, pv_dests_and_ranges,
-			tmo, move_options):
-		return background.move(
-			VG_INTERFACE, None, pv_src_obj, pv_source_range,
-			pv_dests_and_ranges, move_options, tmo)
+			tmo, move_options, cb, cbe):
+
+		job_state = JobState()
+
+		r = RequestEntry(
+				tmo, background.move,
+				(VG_INTERFACE, None, pv_src_obj, pv_source_range,
+				pv_dests_and_ranges, move_options, job_state), cb, cbe, False,
+				job_state)
+
+		cfg.worker_q.put(r)
 
 	@staticmethod
 	def _lv_create(uuid, vg_name, name, size_bytes, pv_dests_and_ranges,


