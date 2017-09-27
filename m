From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 27 Sep 2017 08:48:41 -0400
Subject: master - lvmdbusd: thread stacks dump support
Message-ID: <201709271248.v8RCmfAu023329@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=32c87d56b12e9b6b8e6e1e7e85178abacf19811a
Commit:        32c87d56b12e9b6b8e6e1e7e85178abacf19811a
Parent:        60e3dbd6d50ce2c28206c96f824a5afc9bb287e6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 25 15:20:03 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Sep 27 07:45:00 2017 -0500

lvmdbusd: thread stacks dump support

If you send a SIGUSR1 (10) to the daemon it will dump all the
threads current stacks to stdout.  This will be useful when the
daemon is apparently hung and not processing requests.

eg.
$ sudo kill -10 <daemon pid>
---
 daemons/lvmdbusd/main.py  |   29 ++++++++++++++++++++------
 daemons/lvmdbusd/utils.py |   48 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 64 insertions(+), 13 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index dc31b6f..7f0a028 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -63,6 +63,24 @@ def check_bb_size(value):
 	return v
 
 
+def install_signal_handlers():
+	# Because of the glib main loop stuff the python signal handler code is
+	# apparently not usable and we need to use the glib calls instead
+	signal_add = None
+
+	if hasattr(GLib, 'unix_signal_add'):
+		signal_add = GLib.unix_signal_add
+	elif hasattr(GLib, 'unix_signal_add_full'):
+		signal_add = GLib.unix_signal_add_full
+
+	if signal_add:
+		signal_add(GLib.PRIORITY_HIGH, signal.SIGHUP, utils.handler, signal.SIGHUP)
+		signal_add(GLib.PRIORITY_HIGH, signal.SIGINT, utils.handler, signal.SIGINT)
+		signal_add(GLib.PRIORITY_HIGH, signal.SIGUSR1, utils.handler, signal.SIGUSR1)
+	else:
+		log_error("GLib.unix_signal_[add|add_full] are NOT available!")
+
+
 def main():
 	start = time.time()
 	# Add simple command line handling
@@ -112,12 +130,7 @@ def main():
 	# List of threads that we start up
 	thread_list = []
 
-	# Install signal handlers
-	for s in [signal.SIGHUP, signal.SIGINT]:
-		try:
-			signal.signal(s, utils.handler)
-		except RuntimeError:
-			pass
+	install_signal_handlers()
 
 	dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
 	dbus.mainloop.glib.threads_init()
@@ -177,5 +190,7 @@ def main():
 			for thread in thread_list:
 				thread.join()
 	except KeyboardInterrupt:
-		utils.handler(signal.SIGINT, None)
+		# If we are unable to register signal handler, we will end up here when
+		# the service gets a ^C or a kill -2 <parent pid>
+		utils.handler(signal.SIGINT)
 	return 0
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index ce2ed22..3c006c4 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -21,6 +21,7 @@ from lvmdbusd import cfg
 from gi.repository import GLib
 import threading
 import traceback
+import signal
 
 STDOUT_TTY = os.isatty(sys.stdout.fileno())
 
@@ -281,12 +282,47 @@ def log_error(msg, *attributes):
 	_common_log(msg, *attributes)
 
 
+def dump_threads_stackframe():
+	ident_to_name = {}
+
+	for thread_object in threading.enumerate():
+		ident_to_name[thread_object.ident] = thread_object
+
+	stacks = []
+	for thread_ident, frame in sys._current_frames().items():
+		stack = traceback.format_list(traceback.extract_stack(frame))
+
+		# There is a possibility that a thread gets created after we have
+		# enumerated all threads, so this lookup table may be incomplete, so
+		# account for this
+		if thread_ident in ident_to_name:
+			thread_name = ident_to_name[thread_ident].name
+		else:
+			thread_name = "unknown"
+
+		stacks.append("Thread: %s" % (thread_name))
+		stacks.append("".join(stack))
+
+	log_error("Dumping thread stack frames!\n" + "\n".join(stacks))
+
+
 # noinspection PyUnusedLocal
-def handler(signum, frame):
-	cfg.run.value = 0
-	log_debug('Signal handler called with signal %d' % signum)
-	if cfg.loop is not None:
-		cfg.loop.quit()
+def handler(signum):
+	try:
+		if signum == signal.SIGUSR1:
+			dump_threads_stackframe()
+		else:
+			cfg.run.value = 0
+			log_debug('Exiting daemon with signal %d' % signum)
+			if cfg.loop is not None:
+				cfg.loop.quit()
+	except:
+		st = traceback.format_exc()
+		log_error("signal handler: exception (logged, not reported!) \n %s" % st)
+
+	# It's important we report that we handled the exception for the exception
+	# handler to continue to work, especially for signal 10 (SIGUSR1)
+	return True
 
 
 def pv_obj_path_generate():
@@ -535,7 +571,7 @@ def add_no_notify(cmdline):
 
 
 def _async_handler(call_back, parameters):
-	params_str = ", ".join([str(x) for x in parameters])
+	params_str = ", ".join(str(x) for x in parameters)
 	log_debug('Main thread execution, callback = %s, parameters = (%s)' %
 				(str(call_back), params_str))
 


