From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 22 Sep 2022 13:33:35 +0000 (GMT)
Subject: main - lvmdbusd: Correct lvm shell signal & child process handling
Message-ID: <20220922133335.CCEFA3858400@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36a8fb20bf8a42e7e3227ad85a2b29e0b1432b14
Commit:        36a8fb20bf8a42e7e3227ad85a2b29e0b1432b14
Parent:        c21783d4929ffd60f567ea90c9ae7c644d793d12
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Sep 21 10:05:36 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Sep 22 08:33:06 2022 -0500

lvmdbusd: Correct lvm shell signal & child process handling

Previously when the __del__ method ran on LVMShellProxy we would blindly
call terminate().  This was a race condition as the underlying process
may/maynot be present.  When the process is still present the SIGTERM will
end up being seen by lvmdbusd too.  Re-work the code so that we
first try to wait for the child process to exit and only then if it hasn't
exited will we send it a SIGTERM.  We also ensure that when this is
executed we will briefly ignore a SIGTERM that arrives for the daemon.
---
 daemons/lvmdbusd/cfg.py                |  3 +++
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 32 +++++++++++++++++++++-----------
 daemons/lvmdbusd/utils.py              | 11 +++++++++++
 3 files changed, 35 insertions(+), 11 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 142cfabc7..70edad846 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -45,6 +45,9 @@ worker_q = queue.Queue()
 # Main event loop
 loop = None
 
+# Used to instruct the daemon if we should ignore SIGTERM
+ignore_sigterm = False
+
 BUS_NAME = os.getenv('LVM_DBUS_NAME', 'com.redhat.lvmdbus1')
 BASE_INTERFACE = 'com.redhat.lvmdbus1'
 PV_INTERFACE = BASE_INTERFACE + '.Pv'
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 0ba0ffe5c..ac6d51e65 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -26,7 +26,7 @@ except ImportError:
 	import json
 
 
-from lvmdbusd.cfg import LVM_CMD, run
+import lvmdbusd.cfg as cfg
 from lvmdbusd.utils import log_debug, log_error, add_no_notify, make_non_block,\
 			read_decoded, extract_stack_trace, LvmBug
 
@@ -59,7 +59,7 @@ class LVMShellProxy(object):
 		# a hang.  Keep reading until we get the prompt back and the report
 		# FD does not contain valid JSON
 
-		while keep_reading and run.value != 0:
+		while keep_reading and cfg.run.value != 0:
 			try:
 				rd_fd = [
 					self.parent_stdout_fd,
@@ -113,7 +113,7 @@ class LVMShellProxy(object):
 				self.exit_shell()
 				raise ioe
 
-		if keep_reading and run.value == 0:
+		if keep_reading and cfg.run.value == 0:
 			# We didn't complete as we are shutting down
 			# Try to clean up lvm shell process
 			log_debug("exiting lvm shell as we are shutting down")
@@ -158,7 +158,7 @@ class LVMShellProxy(object):
 
 		# run the lvm shell
 		self.lvm_shell = subprocess.Popen(
-			[LVM_CMD],
+			[cfg.LVM_CMD],
 			stdin=child_stdin_fd,
 			stdout=child_stdout_fd, env=local_env,
 			stderr=child_stderr_fd, close_fds=True,
@@ -259,18 +259,28 @@ class LVMShellProxy(object):
 	def exit_shell(self):
 		try:
 			self._write_cmd('exit\n')
-		except Exception as e:
-			log_error(str(e))
+			self.lvm_shell.wait(1)
+			self.lvm_shell = None
+		except Exception as _e:
+			log_error(str(_e))
 
 	def __del__(self):
-		try:
-			self.lvm_shell.terminate()
-		except:
-			pass
+		# Note: When we are shutting down the daemon and the main process has already exited
+		# and this gets called we have a limited set of things we can do, like we cannot call
+		# log_error as _common_log is None!!!
+		if self.lvm_shell is not None:
+			try:
+				self.lvm_shell.wait(1)
+			except subprocess.TimeoutExpired:
+				print("lvm shell child process did not exit as instructed, sending SIGTERM")
+				cfg.ignore_sigterm = True
+				self.lvm_shell.terminate()
+				child_exit_code = self.lvm_shell.wait(1)
+				print("lvm shell process exited with %d" % child_exit_code)
 
 
 if __name__ == "__main__":
-	print("USING LVM BINARY: %s " % LVM_CMD)
+	print("USING LVM BINARY: %s " % cfg.LVM_CMD)
 
 	try:
 		if len(sys.argv) > 1 and sys.argv[1] == "bisect":
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index dcb3e06bd..5aecb1fff 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -390,6 +390,17 @@ def handler(signum):
 			cfg.debug.dump()
 			cfg.flightrecorder.dump()
 		else:
+			# If we are getting a SIGTERM, and we sent one to the lvm shell we
+			# will ignore this and keep running.
+			if signum == signal.SIGTERM and cfg.ignore_sigterm:
+				# Clear the flag, so we will exit on SIGTERM if we didn't
+				# send it.
+				cfg.ignore_sigterm = False
+				return True
+
+			# If lvm shell is in use, tell it to exit
+			if cfg.SHELL_IN_USE is not None:
+				cfg.SHELL_IN_USE.exit_shell()
 			cfg.run.value = 0
 			log_error('Exiting daemon with signal %d' % signum)
 			if cfg.loop is not None:

