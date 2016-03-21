From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 21 Mar 2016 22:34:02 +0000 (UTC)
Subject: master - lvmdbusd: Add lvm flight recorder
Message-ID: <20160321223402.0B9A06072A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca28ea88bedbc0ecb64e5579c1b3076b9a7cd533
Commit:        ca28ea88bedbc0ecb64e5579c1b3076b9a7cd533
Parent:        a0c7875c547fb8a420d789271f5e6660210e749f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Mar 21 17:22:56 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 21 17:28:51 2016 -0500

lvmdbusd: Add lvm flight recorder

To help out with debug, when an exception is thrown in the dbus service we
will dump all the information we have on the last 16 commands that were
executed along with the stack strace.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/cfg.py        |    3 ++
 daemons/lvmdbusd/cmdhandler.py |   46 +++++++++++++++++++++++++++++++++++++--
 daemons/lvmdbusd/request.py    |    1 +
 3 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index bde6a64..8aec8ae 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -78,3 +78,6 @@ load = None
 
 # Global cached state
 db = None
+
+# lvm flight recorder
+blackbox = None
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 370fb61..1522ebf 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -11,6 +11,7 @@ from subprocess import Popen, PIPE
 import time
 import threading
 from itertools import chain
+import collections
 
 try:
 	from . import cfg
@@ -28,13 +29,51 @@ total_count = 0
 
 # We need to prevent different threads from using the same lvm shell
 # at the same time.
-cmd_lock = threading.Lock()
+cmd_lock = threading.RLock()
 
 # The actual method which gets called to invoke the lvm command, can vary
 # from forking a new process to using lvm shell
 _t_call = None
 
 
+class LvmExecutionMeta(object):
+
+	def __init__(self, start, ended, cmd, ec, stdout_txt, stderr_txt):
+		self.start = start
+		self.ended = ended
+		self.cmd = cmd
+		self.ec = ec
+		self.stdout_txt = stdout_txt
+		self.stderr_txt = stderr_txt
+
+	def __str__(self):
+		return "EC= %d for %s\n" \
+			"STARTED: %f, ENDED: %f\n" \
+			"STDOUT=%s\n" \
+			"STDERR=%s\n" % \
+			(self.ec, str(self.cmd), self.start, self.ended, self.stdout_txt,
+			self.stderr_txt)
+
+
+class LvmFlightRecorder(object):
+
+	def __init__(self):
+		self.queue = collections.deque(maxlen=16)
+
+	def add(self, lvm_exec_meta):
+		self.queue.append(lvm_exec_meta)
+
+	def dump(self):
+		with cmd_lock:
+			log_error("LVM dbus flight recorder START")
+			for c in self.queue:
+				log_error(str(c))
+			log_error("LVM dbus flight recorder END")
+
+
+cfg.blackbox = LvmFlightRecorder()
+
+
 def _debug_c(cmd, exit_code, out):
 	log_error('CMD= %s' % ' '.join(cmd))
 	log_error(("EC= %d" % exit_code))
@@ -105,9 +144,10 @@ def time_wrapper(command, debug=False):
 	with cmd_lock:
 		start = time.time()
 		results = _t_call(command, debug)
-		total_time += (time.time() - start)
+		ended = time.time()
+		total_time += (ended - start)
 		total_count += 1
-
+		cfg.blackbox.add(LvmExecutionMeta(start, ended, command, *results))
 	return results
 
 
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index cf258f1..02f8c88 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -69,6 +69,7 @@ class RequestEntry(object):
 			# have gotten a job by the time we hit an error
 			# Lets get the stacktrace and set that to the error message
 			st = traceback.format_exc()
+			cfg.blackbox.dump()
 			log_error("Exception returned to client: \n%s" % st)
 			self.register_error(-1, str(e), e)
 


