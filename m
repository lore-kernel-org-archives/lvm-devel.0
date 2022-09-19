From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:55 +0000 (GMT)
Subject: main - lvmdbusd: Remove exclusionary language
Message-ID: <20220919155755.999E33858C20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b9cc7432ec70461217c081b5d38065236aec887
Commit:        6b9cc7432ec70461217c081b5d38065236aec887
Parent:        c13efb2ffc90853884e77f0d2b28e8d1936c74d0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 9 17:55:27 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbusd: Remove exclusionary language

---
 daemons/lvmdbusd/background.py |  2 +-
 daemons/lvmdbusd/cfg.py        |  2 +-
 daemons/lvmdbusd/cmdhandler.py |  8 ++++----
 daemons/lvmdbusd/fetch.py      |  2 +-
 daemons/lvmdbusd/main.py       | 12 ++++++------
 daemons/lvmdbusd/manager.py    |  2 +-
 daemons/lvmdbusd/request.py    |  2 +-
 daemons/lvmdbusd/utils.py      |  2 +-
 8 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 463bb20d5..21617c47a 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -68,7 +68,7 @@ def _move_merge(interface_name, command, job_state):
 	# the status of the long running operation.
 
 	meta = LvmExecutionMeta(time.time(), 0, command)
-	cfg.blackbox.add(meta)
+	cfg.flightrecorder.add(meta)
 
 	ec, stdout, stderr = call_lvm(command, line_cb=_move_callback,
 									cb_data=job_state)
diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index ee4e41b30..d7a653b54 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -92,7 +92,7 @@ vdo_support = False
 db = None
 
 # lvm flight recorder
-blackbox = None
+flightrecorder = None
 
 # RequestEntry ctor
 create_request_entry = None
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 7b3ad528b..0422f8970 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -90,7 +90,7 @@ class LvmFlightRecorder(object):
 				log_error("LVM dbus flight recorder END")
 
 
-cfg.blackbox = LvmFlightRecorder()
+cfg.flightrecorder = LvmFlightRecorder()
 
 
 def _debug_c(cmd, exit_code, out):
@@ -217,9 +217,9 @@ def time_wrapper(command, debug=False):
 	with cmd_lock:
 		start = time.time()
 		meta = LvmExecutionMeta(start, 0, command)
-		# Add the partial metadata to black box, so if the command hangs
-		# we will see what it was in the block box dump.
-		cfg.blackbox.add(meta)
+		# Add the partial metadata to flight recorder, so if the command hangs
+		# we will see what it was.
+		cfg.flightrecorder.add(meta)
 		results = _t_call(command, debug)
 		ended = time.time()
 		total_time += (ended - start)
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index c17827b5a..740b15fdb 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -183,7 +183,7 @@ class StateUpdate(object):
 			except Exception as e:
 				st = traceback.format_exc()
 				log_error("update_thread exception: \n%s" % st)
-				cfg.blackbox.dump()
+				cfg.flightrecorder.dump()
 				exception_count += 1
 				if exception_count >= 5:
 					for i in queued_requests:
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 5e6f72cdc..5369f1dd5 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -55,7 +55,7 @@ def process_request():
 			utils.log_error("process_request exception: \n%s" % st)
 
 
-def check_bb_size(value):
+def check_fr_size(value):
 	v = int(value)
 	if v < 0:
 		raise argparse.ArgumentTypeError(
@@ -103,11 +103,11 @@ def process_args():
 		default=False,
 		dest='use_lvm_shell')
 	parser.add_argument(
-		"--blackboxsize",
-		help="Size of the black box flight recorder, 0 to disable",
+		"--frsize",
+		help="Size of the flight recorder (num. entries), 0 to disable (signal 12 to dump)",
 		default=10,
-		type=check_bb_size,
-		dest='bb_size')
+		type=check_fr_size,
+		dest='fr_size')
 
 	args = parser.parse_args()
 
@@ -142,7 +142,7 @@ def main():
 	# We create a flight recorder in cmdhandler too, but we replace it here
 	# as the user may be specifying a different size.  The default one in
 	# cmdhandler is for when we are running other code with a different main.
-	cfg.blackbox = LvmFlightRecorder(cfg.args.bb_size)
+	cfg.flightrecorder = LvmFlightRecorder(cfg.args.fr_size)
 
 	log_debug("Using lvm binary: %s" % cfg.LVM_CMD)
 
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 573a3966f..e6b0718c4 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -137,7 +137,7 @@ class Manager(AutomatedProperties):
 		"""
 		Dump the flight recorder to syslog
 		"""
-		cfg.blackbox.dump()
+		cfg.flightrecorder.dump()
 
 	@staticmethod
 	def _lookup_by_lvm_id(key):
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index eaec04c28..e069cfdc1 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -76,7 +76,7 @@ class RequestEntry(object):
 			# have gotten a job by the time we hit an error
 			# Lets get the stacktrace and set that to the error message
 			st = traceback.format_exc()
-			cfg.blackbox.dump()
+			cfg.flightrecorder.dump()
 			log_error("Exception returned to client: \n%s" % st)
 			self.register_error(-1, str(e), e)
 
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index a10fa7864..e12c7fccf 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -351,7 +351,7 @@ def handler(signum):
 			dump_threads_stackframe()
 		# signal 12
 		elif signum == signal.SIGUSR2:
-			cfg.blackbox.dump()
+			cfg.flightrecorder.dump()
 		else:
 			cfg.run.value = 0
 			log_debug('Exiting daemon with signal %d' % signum)

