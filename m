From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:28 +0000 (GMT)
Subject: main - lvmdbusd: Instruct lvm to output debug to file for fullreport
Message-ID: <20220919155828.8A6C73858288@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85fcbfd9d7697d3954c4f13a791f127205e260ee
Commit:        85fcbfd9d7697d3954c4f13a791f127205e260ee
Parent:        d42bdb07def72d68c05241823979b28952978c05
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 31 15:04:59 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Instruct lvm to output debug to file for fullreport

Historically we have seen a few different errors which occur when we call
fullreport.  Failing exit code and JSON which is missing one or more keys.
Instruct lvm to dump the debug to a file during fullreport calls when we
fork & exec lvm. If we encounter an error, ouput the debug data.
The reason this isn't being done when lvmshell is used is because we
don't have an easy way to test the error paths.

This change is complicated by the following:

1. We don't know if fullreport was good until we evaluate all the JSON.
   This is done a bit after we have called into lvm and returned.
2. We don't want to orphan the debug file used by lvm if the daemon is
   killed. Thus we try to minimize the window where the debug file hasn't
   already been unlinked.  A RFE to pass an open FD to lvm for this
   purpose is outstanding.

The temp. file is:
-rw------. 1 root root /tmp/lvmdbusd.lvm.debug.XXXXXXXX.log
---
 daemons/lvmdbusd/cfg.py        |  4 +++
 daemons/lvmdbusd/cmdhandler.py |  9 ++++-
 daemons/lvmdbusd/fetch.py      |  6 ++++
 daemons/lvmdbusd/main.py       |  4 +++
 daemons/lvmdbusd/utils.py      | 78 +++++++++++++++++++++++++++++++++++-------
 5 files changed, 87 insertions(+), 14 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index a758b8a77..5b342bc20 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -109,3 +109,7 @@ def exit_daemon():
     if run and loop:
         run.value = 0
         loop.quit()
+
+
+# Debug data for lvm
+lvmdebug = None
diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 7a349e87e..102844739 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -17,7 +17,7 @@ import os
 
 from lvmdbusd import cfg
 from lvmdbusd.utils import pv_dest_ranges, log_debug, log_error, add_no_notify,\
-			make_non_block, read_decoded, extract_stack_trace, LvmBug
+			make_non_block, read_decoded, extract_stack_trace, LvmBug, add_config_option
 from lvmdbusd.lvm_shell_proxy import LVMShellProxy
 
 try:
@@ -121,6 +121,12 @@ def call_lvm(command, debug=False, line_cb=None,
 	command.insert(0, cfg.LVM_CMD)
 	command = add_no_notify(command)
 
+	# If we are running the fullreport command, we will ask lvm to output the debug
+	# data, so we can have the required information for lvm to debug the fullreport failures.
+	if "fullreport" in command:
+		fn = cfg.lvmdebug.setup()
+		add_config_option(command, "--config", "log {level=7 file=%s syslog=0}" % fn)
+
 	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True,
 					env=os.environ)
 
@@ -163,6 +169,7 @@ def call_lvm(command, debug=False, line_cb=None,
 			break
 
 	if process.returncode is not None:
+		cfg.lvmdebug.lvm_complete()
 		if debug or (process.returncode != 0 and (process.returncode != 5 and "fullreport" in command)):
 			_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index dc527be36..199b86073 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -171,6 +171,7 @@ class StateUpdate(object):
 				cfg.exit_daemon()
 			else:
 				# Slow things down when encountering errors
+				cfg.lvmdebug.complete()
 				time.sleep(1)
 
 		while cfg.run.value != 0:
@@ -205,11 +206,16 @@ class StateUpdate(object):
 			except SystemExit:
 				break
 			except LvmBug as bug:
+				# If a lvm bug occurred, we will dump the lvm debug data if
+				# we have it.
+				cfg.lvmdebug.dump()
 				log_error(str(bug))
 				_handle_error()
 			except Exception as e:
 				log_error("update_thread: \n%s" % extract_stack_trace(e))
 				_handle_error()
+			finally:
+				cfg.lvmdebug.complete()
 
 		# Make sure to unblock any that may be waiting before we exit this thread
 		# otherwise they hang forever ...
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index a426a535d..ab66efcc9 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -138,6 +138,10 @@ def main():
 	os.environ["LC_ALL"] = "C"
 	os.environ["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 
+	# Save off the debug data needed for lvm team to debug issues
+	# only used for 'fullreport' at this time.
+	cfg.lvmdebug = utils.LvmDebugData()
+
 	# Add simple command line handling
 	cfg.args = process_args()
 
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 6c7a25f8d..ec40236a5 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -18,6 +18,7 @@ import os
 import stat
 import string
 import datetime
+import tempfile
 
 import dbus
 from lvmdbusd import cfg
@@ -614,6 +615,23 @@ def validate_tag(interface, tag):
 			% (tag, _ALLOWABLE_TAG_CH))
 
 
+def add_config_option(cmdline, key, value):
+	if 'help' in cmdline:
+		return cmdline
+
+	if key in cmdline:
+		for i, arg in enumerate(cmdline):
+			if arg == key:
+				if len(cmdline) <= i + 1:
+					raise dbus.exceptions.DBusException("Missing value for --config option.")
+				cmdline[i + 1] += " %s" % value
+				break
+	else:
+		cmdline.extend([key, value])
+
+	return cmdline
+
+
 def add_no_notify(cmdline):
 	"""
 	Given a command line to execute we will see if `--config` is present, if it
@@ -627,20 +645,11 @@ def add_no_notify(cmdline):
 
 	# Only after we have seen an external event will we disable lvm from sending
 	# us one when we call lvm
+	rv = cmdline
 	if cfg.got_external_event:
-		if 'help' in cmdline:
-			return cmdline
-
-		if '--config' in cmdline:
-			for i, arg in enumerate(cmdline):
-				if arg == '--config':
-					if len(cmdline) <= i+1:
-						raise dbus.exceptions.DBusException("Missing value for --config option.")
-					cmdline[i+1] += " global/notify_dbus=0"
-					break
-		else:
-			cmdline.extend(['--config', 'global/notify_dbus=0'])
-	return cmdline
+		rv = add_config_option(rv, "--config", "global/notify_dbus=0")
+
+	return rv
 
 
 # The methods below which start with mt_* are used to execute the desired code
@@ -777,3 +786,46 @@ class LvmBug(RuntimeError):
 
 	def __str__(self):
 		return "lvm bug encountered: %s" % ' '.join(self.args)
+
+
+class LvmDebugData:
+	def __init__(self):
+		self.fd = -1
+		self.fn = None
+
+	def _remove_file(self):
+		if self.fn is not None:
+			os.unlink(self.fn)
+			self.fn = None
+
+	def _close_fd(self):
+		if self.fd != -1:
+			os.close(self.fd)
+			self.fd = -1
+
+	def setup(self):
+		# Create a secure filename
+		self.fd, self.fn = tempfile.mkstemp(suffix=".log", prefix="lvmdbusd.lvm.debug.")
+		return self.fn
+
+	def lvm_complete(self):
+		# Remove the file ASAP, so we decrease our odds of leaving it
+		# around if the daemon gets killed by a signal -9
+		self._remove_file()
+
+	def dump(self):
+		# Read the file and log it to log_err
+		if self.fd != -1:
+			# How big could the verbose debug get?
+			debug = os.read(self.fd, 1024*1024*5)
+			debug_txt = debug.decode("utf-8")
+			for line in debug_txt.split("\n"):
+				log_error("lvm debug >>> %s" % line)
+			self._close_fd()
+		# In case lvm_complete doesn't get called.
+		self._remove_file()
+
+	def complete(self):
+		self._close_fd()
+		# In case lvm_complete doesn't get called.
+		self._remove_file()

