From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 2 Jun 2017 13:51:13 -0400
Subject: master - lvmdbusd: Add background command to flight recorder
Message-ID: <201706021751.v52HpDdW024393@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=699ccc05cacc32b4707bf12dba4ccbb994469048
Commit:        699ccc05cacc32b4707bf12dba4ccbb994469048
Parent:        192d142e1cd38c1593ec76502d8424997ec01ec8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 2 12:25:01 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 2 12:32:51 2017 -0500

lvmdbusd: Add background command to flight recorder

We were not adding background tasks to flight recorder.  Add the meta
data to the flight recorder when we start the command and update the meta
data when the command is finished.  Locking was added to meta data to
prevent concurrent update and returning string representation as these can
happen in two different threads.
---
 daemons/lvmdbusd/background.py |   13 ++++++++++++-
 daemons/lvmdbusd/cmdhandler.py |   14 ++++++++------
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index f7f77d5..90e8b68 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -9,12 +9,13 @@
 
 import subprocess
 from . import cfg
-from .cmdhandler import options_to_cli_args
+from .cmdhandler import options_to_cli_args, LvmExecutionMeta
 import dbus
 from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug,\
 	add_no_notify
 import os
 import threading
+import time
 
 
 def pv_move_lv_cmd(move_options, lv_full_name,
@@ -47,6 +48,11 @@ def _move_merge(interface_name, command, job_state):
 	# Instruct lvm to not register an event with us
 	command = add_no_notify(command)
 
+	#(self, start, ended, cmd, ec, stdout_txt, stderr_txt)
+	meta = LvmExecutionMeta(time.time(), 0, command, -1000, None, None)
+
+	cfg.blackbox.add(meta)
+
 	process = subprocess.Popen(command, stdout=subprocess.PIPE,
 								env=os.environ,
 								stderr=subprocess.PIPE, close_fds=True)
@@ -74,6 +80,11 @@ def _move_merge(interface_name, command, job_state):
 
 	out = process.communicate()
 
+	with meta.lock:
+		meta.ended = time.time()
+		meta.ec = process.returncode
+		meta.stderr_txt = out[1]
+
 	if process.returncode == 0:
 		job_state.Percent = 100
 	else:
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index a883f1e..4fb1670 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -37,6 +37,7 @@ cmd_lock = threading.RLock()
 class LvmExecutionMeta(object):
 
 	def __init__(self, start, ended, cmd, ec, stdout_txt, stderr_txt):
+		self.lock = threading.RLock()
 		self.start = start
 		self.ended = ended
 		self.cmd = cmd
@@ -45,12 +46,13 @@ class LvmExecutionMeta(object):
 		self.stderr_txt = stderr_txt
 
 	def __str__(self):
-		return "EC= %d for %s\n" \
-			"STARTED: %f, ENDED: %f\n" \
-			"STDOUT=%s\n" \
-			"STDERR=%s\n" % \
-			(self.ec, str(self.cmd), self.start, self.ended, self.stdout_txt,
-			self.stderr_txt)
+		with self.lock:
+			return "EC= %d for %s\n" \
+				"STARTED: %f, ENDED: %f\n" \
+				"STDOUT=%s\n" \
+				"STDERR=%s\n" % \
+				(self.ec, str(self.cmd), self.start, self.ended, self.stdout_txt,
+				self.stderr_txt)
 
 
 class LvmFlightRecorder(object):


