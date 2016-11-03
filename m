From: tasleson <tasleson@fedoraproject.org>
Date: Thu,  3 Nov 2016 23:43:01 +0000 (UTC)
Subject: master - lvmdbusd: Take out background thread
Message-ID: <20161103234301.981B560DB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee0c9e7b2306cada41defedd0e5006b0ee2f3a21
Commit:        ee0c9e7b2306cada41defedd0e5006b0ee2f3a21
Parent:        a9ee86ccf2425cbe3f038039c8038db1e1784086
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Nov 3 18:25:12 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 3 18:29:06 2016 -0500

lvmdbusd: Take out background thread

There is no reason to create another background task when the task that
created it is going to block waiting for it to finish.  Instead we will
just execute the logic in the worker thread that is servicing the worker
queue.
---
 daemons/lvmdbusd/background.py |  103 ++++++++++++---------------------------
 daemons/lvmdbusd/job.py        |   29 +-----------
 2 files changed, 33 insertions(+), 99 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 0220b97..fc92b0c 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -13,7 +13,6 @@ from . import cfg
 from .cmdhandler import options_to_cli_args
 import dbus
 from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
-import traceback
 import os
 
 _rlock = threading.RLock()
@@ -41,15 +40,40 @@ def lv_merge_cmd(merge_options, lv_full_name):
 	return cmd
 
 
-def _move_merge(interface_name, cmd, job_state):
-	add(cmd, job_state)
-
-	done = job_state.Wait(-1)
-	if not done:
-		ec, err_msg = job_state.GetError
+def _move_merge(interface_name, command, job_state):
+	# We need to execute these command stand alone by forking & exec'ing
+	# the command always as we will be getting periodic output from them on
+	# the status of the long running operation.
+	command.insert(0, cfg.LVM_CMD)
+	process = subprocess.Popen(command, stdout=subprocess.PIPE,
+								env=os.environ,
+								stderr=subprocess.PIPE, close_fds=True)
+
+	log_debug("Background process for %s is %d" %
+				(str(command), process.pid))
+
+	lines_iterator = iter(process.stdout.readline, b"")
+	for line in lines_iterator:
+		line_str = line.decode("utf-8")
+
+		# Check to see if the line has the correct number of separators
+		try:
+			if line_str.count(':') == 2:
+				(device, ignore, percentage) = line_str.split(':')
+				job_state.Percent = round(
+					float(percentage.strip()[:-1]), 1)
+		except ValueError:
+			log_error("Trying to parse percentage which failed for %s" %
+				line_str)
+
+	out = process.communicate()
+
+	if process.returncode == 0:
+		job_state.Percent = 100
+	else:
 		raise dbus.exceptions.DBusException(
 			interface_name,
-			'Exit code %s, stderr = %s' % (str(ec), err_msg))
+			'Exit code %s, stderr = %s' % (str(process.returncode), out[1]))
 
 	cfg.load()
 	return '/'
@@ -84,8 +108,6 @@ def move(interface_name, lv_name, pv_src_obj, pv_source_range,
 
 				pv_dests.append((pv_dbus_obj.lvm_id, pr[1], pr[2]))
 
-		# Generate the command line for this command, but don't
-		# execute it.
 		cmd = pv_move_lv_cmd(move_options,
 								lv_name,
 								pv_src.lvm_id,
@@ -122,64 +144,3 @@ def background_reaper():
 	return True
 
 
-def background_execute(command, background_job):
-
-	# Wrap this whole operation in an exception handler, otherwise if we
-	# hit a code bug we will silently exit this thread without anyone being
-	# the wiser.
-	try:
-		# We need to execute these command stand alone by forking & exec'ing
-		# the command always!
-		command.insert(0, cfg.LVM_CMD)
-		process = subprocess.Popen(command, stdout=subprocess.PIPE,
-									env=os.environ,
-									stderr=subprocess.PIPE, close_fds=True)
-
-		log_debug("Background process for %s is %d" %
-					(str(command), process.pid))
-
-		lines_iterator = iter(process.stdout.readline, b"")
-		for line in lines_iterator:
-			line_str = line.decode("utf-8")
-
-			# Check to see if the line has the correct number of separators
-			try:
-				if line_str.count(':') == 2:
-					(device, ignore, percentage) = line_str.split(':')
-					background_job.Percent = round(
-						float(percentage.strip()[:-1]), 1)
-			except ValueError:
-				log_error("Trying to parse percentage which failed for %s" %
-					line_str)
-
-		out = process.communicate()
-
-		if process.returncode == 0:
-			background_job.Percent = 100
-		else:
-			log_error("Failed to execute background job %s, STDERR= %s"
-						% (str(command), out[1]))
-
-		background_job.set_result(process.returncode, out[1])
-		log_debug("Background process %d complete!" % process.pid)
-
-	except Exception:
-		# In the unlikely event that we blow up, we need to unblock caller which
-		# is waiting on an answer.
-		st = traceback.format_exc()
-		error = "Exception in background thread: \n%s" % st
-		log_error(error)
-		background_job.set_result(1, error)
-
-
-def add(command, reporting_job):
-	# Create the thread, get it running and then add it to the list
-	t = threading.Thread(
-		target=background_execute,
-		name="thread: " + ' '.join(command),
-		args=(command, reporting_job))
-	t.start()
-
-	with _rlock:
-		_thread_list.append(t)
-
diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index 81048a6..3c3bba0 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -66,7 +66,6 @@ class JobState(object):
 		self._percent = 0
 		self._complete = False
 		self._request = request
-		self._cond = threading.Condition(self.rlock)
 		self._ec = 0
 		self._stderr = ''
 		self._waiting_clients = []
@@ -100,7 +99,6 @@ class JobState(object):
 		with self.rlock:
 			self._complete = value
 			self._percent = 100
-			self._cond.notify_all()
 			self.notify_waiting_clients()
 
 	@property
@@ -115,29 +113,10 @@ class JobState(object):
 			else:
 				return (-1, 'Job is not complete!')
 
-	def set_result(self, ec, msg):
-		with self.rlock:
-			self.Complete = True
-			self._ec = ec
-			self._stderr = msg
-
 	def dtor(self):
 		with self.rlock:
 			self._request = None
 
-	def Wait(self, timeout):
-		try:
-			with self._cond:
-				# Check to see if we are done, before we wait
-				if not self.Complete:
-					if timeout != -1:
-						self._cond.wait(timeout)
-					else:
-						self._cond.wait()
-				return self.Complete
-		except RuntimeError:
-			return False
-
 	@property
 	def Result(self):
 		with self.rlock:
@@ -175,6 +154,7 @@ class JobState(object):
 
 			self._waiting_clients = []
 
+
 # noinspection PyPep8Naming
 class Job(AutomatedProperties):
 	_Percent_meta = ('d', JOB_INTERFACE)
@@ -195,10 +175,6 @@ class Job(AutomatedProperties):
 	def Percent(self):
 		return dbus.Double(float(self.state.Percent))
 
-	@Percent.setter
-	def Percent(self, value):
-		self.state.Percent = value
-
 	@property
 	def Complete(self):
 		return dbus.Boolean(self.state.Complete)
@@ -211,9 +187,6 @@ class Job(AutomatedProperties):
 	def GetError(self):
 		return dbus.Struct(self.state.GetError, signature="(is)")
 
-	def set_result(self, ec, msg):
-		self.state.set_result(ec, msg)
-
 	@dbus.service.method(dbus_interface=JOB_INTERFACE)
 	def Remove(self):
 		if self.state.Complete:


