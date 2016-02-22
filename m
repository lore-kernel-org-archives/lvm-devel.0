From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 22 Feb 2016 22:10:58 +0000 (UTC)
Subject: master - lvmdbusd: background.py, fix stdout parse error
Message-ID: <20160222221058.49D5C602B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70d0b210e17884ab8cfc5f2a9be90461afb993c7
Commit:        70d0b210e17884ab8cfc5f2a9be90461afb993c7
Parent:        d7dd8bf9d6ef146d48e5a2d39cf7ae17ca93545b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Feb 22 14:00:30 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 22 16:07:54 2016 -0600

lvmdbusd: background.py, fix stdout parse error

It appears that the output of lvconvert --merge can vary some.  The code
was blowing up as it was trying to parse a line of stdout to retrieve the
% complete, but the line did not have the needed format and an execption
was thrown.  The uncaught exception caused the background thread to exit
without updating the job object, which caused the client to hang forever
waiting.  Added a default exception handler to prevent unhandled execptions
causing hangs and removed the parameter skip_first_line as it's no longer
needed.  The code checks to see if the line can be parsed before doing so.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/background.py |   85 ++++++++++++++++++++++++----------------
 1 files changed, 51 insertions(+), 34 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 16ee7a6..4265154 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -14,8 +14,9 @@ import time
 from .cmdhandler import options_to_cli_args
 import dbus
 from .job import Job, JobState
-from .utils import pv_range_append, pv_dest_ranges
+from .utils import pv_range_append, pv_dest_ranges, log_debug, log_error
 from .request import RequestEntry
+import traceback
 
 _rlock = threading.RLock()
 _thread_list = list()
@@ -48,11 +49,11 @@ def _create_background_dbus_job(job_state):
 	return job_obj.dbus_object_path()
 
 
-def _move_merge(interface_name, cmd, time_out, skip_first_line=False):
+def _move_merge(interface_name, cmd, time_out):
 	# Create job object to be used while running the command
 	rc = '/'
 	job_state = JobState(None)
-	add(cmd, job_state, skip_first_line)
+	add(cmd, job_state)
 
 	if time_out == -1:
 		# Waiting forever
@@ -122,7 +123,7 @@ def merge(interface_name, lv_uuid, lv_name, merge_options, time_out):
 	dbo = cfg.om.get_object_by_uuid_lvm_id(lv_uuid, lv_name)
 	if dbo:
 		cmd = lv_merge_cmd(merge_options, dbo.lvm_id)
-		return _move_merge(interface_name, cmd, time_out, True)
+		return _move_merge(interface_name, cmd, time_out)
 	else:
 		raise dbus.exceptions.DBusException(
 			interface_name,
@@ -154,41 +155,57 @@ def empty_cb(disregard):
 
 
 def background_execute(command, background_job, skip_first_line=False):
-	process = subprocess.Popen(command, stdout=subprocess.PIPE,
-								stderr=subprocess.PIPE, close_fds=True)
-	lines_iterator = iter(process.stdout.readline, b"")
-	for line in lines_iterator:
-		# Merge ouputs a line before updates, move does not
-		if skip_first_line:
-			skip_first_line = False
-			continue
-
-		if len(line) > 10:
-			(device, ignore, percentage) = line.decode("utf-8").split(':')
-			background_job.Percent = round(float(percentage.strip()[:-1]), 1)
-
-	out = process.communicate()
-
-	# print "DEBUG: EC %d, STDOUT %s, STDERR %s" % \
-	#      (process.returncode, out[0], out[1])
-
-	if process.returncode == 0:
-		background_job.Percent = 100
-
-	# Queue up the result so that it gets executed in same thread as others.
-	r = RequestEntry(
-		-1, process_background_result,
-		(background_job, process.returncode, out[1]),
-		empty_cb, empty_cb, False)
-	cfg.worker_q.put(r)
-
 
-def add(command, reporting_job, skip_first_line=False):
+	# Wrap this whole operation in an exception handler, otherwise if we
+	# hit a code bug we will silently exit this thread without anyone being
+	# the wiser.
+	try:
+		process = subprocess.Popen(command, stdout=subprocess.PIPE,
+									stderr=subprocess.PIPE, close_fds=True)
+		lines_iterator = iter(process.stdout.readline, b"")
+		for line in lines_iterator:
+			line_str = line.decode("utf-8")
+
+			# Check to see if the line has the correct number of separators
+			try:
+				if line_str.count(':') == 2:
+					(device, ignore, percentage) = line_str.split(':')
+					background_job.Percent = \
+						round(float(percentage.strip()[:-1]), 1)
+			except ValueError:
+				log_error("Trying to parse percentage which failed for %s" %
+					line_str)
+
+		out = process.communicate()
+
+		if process.returncode == 0:
+			background_job.Percent = 100
+
+		# Queue up the result so that it gets executed in same thread as others.
+		r = RequestEntry(
+			-1, process_background_result,
+			(background_job, process.returncode, out[1]),
+			empty_cb, empty_cb, False)
+		cfg.worker_q.put(r)
+	except Exception:
+		# In the unlikely event that we blew up, lets notify fill out the
+		# job object so that the client doesn't hang potentially forever!
+		st = traceback.format_exc()
+		error = "Exception in background thread: \n%s" % st
+		log_error(error)
+		r = RequestEntry(
+			-1, process_background_result,
+			(background_job, 1, error),
+			empty_cb, empty_cb, False)
+		cfg.worker_q.put(r)
+
+
+def add(command, reporting_job):
 	# Create the thread, get it running and then add it to the list
 	t = threading.Thread(
 		target=background_execute,
 		name="thread: " + ' '.join(command),
-		args=(command, reporting_job, skip_first_line))
+		args=(command, reporting_job))
 	t.start()
 
 	with _rlock:


