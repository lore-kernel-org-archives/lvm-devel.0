From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:52 +0000 (GMT)
Subject: main - lvmdbusd: Re-work flight recorder data
Message-ID: <20220919155752.35EEC3858C55@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05f7fa5a8536d37b6a711ac0baab5bfd105bb0cc
Commit:        05f7fa5a8536d37b6a711ac0baab5bfd105bb0cc
Parent:        ea45ba753eaa168429b9747500e6f31f2856890f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 9 17:43:00 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbusd: Re-work flight recorder data

Introduce a new lock for the flight recorder, so that we can dump it when
a command is block waiting for lvm to complete.  Also in all paths we will
addthe metadata to the flight recorder before it's done, so we will have
it when a command hangs and we dump the flight recorder. Add the missing
bits after the command has finished.

Cleaned up the output too.
---
 daemons/lvmdbusd/background.py |  9 +++------
 daemons/lvmdbusd/cmdhandler.py | 38 +++++++++++++++++++++++++++++---------
 2 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 32b2cdc38..463bb20d5 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -67,16 +67,13 @@ def _move_merge(interface_name, command, job_state):
 	# the command always as we will be getting periodic output from them on
 	# the status of the long running operation.
 
-	meta = LvmExecutionMeta(time.time(), 0, command, -1000, None, None)
+	meta = LvmExecutionMeta(time.time(), 0, command)
 	cfg.blackbox.add(meta)
 
 	ec, stdout, stderr = call_lvm(command, line_cb=_move_callback,
 									cb_data=job_state)
-
-	with meta.lock:
-		meta.ended = time.time()
-		meta.ec = ec
-		meta.stderr_txt = stderr
+	ended = time.time()
+	meta.completed(ended, ec, stdout, stderr)
 
 	if ec == 0:
 		job_state.Percent = 100
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 8fbcd2e3a..0c4d5cb61 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -38,7 +38,7 @@ cmd_lock = threading.RLock()
 
 class LvmExecutionMeta(object):
 
-	def __init__(self, start, ended, cmd, ec, stdout_txt, stderr_txt):
+	def __init__(self, start, ended, cmd, ec=-1000, stdout_txt=None, stderr_txt=None):
 		self.lock = threading.RLock()
 		self.start = start
 		self.ended = ended
@@ -49,26 +49,42 @@ class LvmExecutionMeta(object):
 
 	def __str__(self):
 		with self.lock:
-			return "EC= %d for %s\n" \
-				"STARTED: %f, ENDED: %f\n" \
+			if self.ended == 0:
+				ended_txt = "still running"
+				self.ended = time.time()
+			else:
+				ended_txt = str(time.ctime(self.ended))
+
+			return 'EC= %d for "%s"\n' \
+				"STARTED: %s, ENDED: %s, DURATION: %f\n" \
 				"STDOUT=%s\n" \
 				"STDERR=%s\n" % \
-				(self.ec, str(self.cmd), self.start, self.ended, self.stdout_txt,
-				self.stderr_txt)
+				(self.ec, " ".join(self.cmd), time.ctime(self.start), ended_txt, float(self.ended) - self.start,
+					self.stdout_txt,
+					self.stderr_txt)
+
+	def completed(self, end_time, ec, stdout_txt, stderr_txt):
+		with self.lock:
+			self.ended = end_time
+			self.ec = ec
+			self.stdout_txt = stdout_txt
+			self.stderr_txt = stderr_txt
 
 
 class LvmFlightRecorder(object):
 
 	def __init__(self, size=16):
 		self.queue = collections.deque(maxlen=size)
+		self.lock = threading.RLock()
 
 	def add(self, lvm_exec_meta):
-		self.queue.append(lvm_exec_meta)
+		with self.lock:
+			self.queue.append(lvm_exec_meta)
 
 	def dump(self):
-		with cmd_lock:
+		with self.lock:
 			if len(self.queue):
-				log_error("LVM dbus flight recorder START")
+				log_error("LVM dbus flight recorder START (in order of newest to oldest)")
 				for c in reversed(self.queue):
 					log_error(str(c))
 				log_error("LVM dbus flight recorder END")
@@ -200,11 +216,15 @@ def time_wrapper(command, debug=False):
 
 	with cmd_lock:
 		start = time.time()
+		meta = LvmExecutionMeta(start, 0, command)
+		# Add the partial metadata to black box, so if the command hangs
+		# we will see what it was in the block box dump.
+		cfg.blackbox.add(meta)
 		results = _t_call(command, debug)
 		ended = time.time()
 		total_time += (ended - start)
 		total_count += 1
-		cfg.blackbox.add(LvmExecutionMeta(start, ended, command, *results))
+		meta.completed(ended, *results)
 	return results
 
 

