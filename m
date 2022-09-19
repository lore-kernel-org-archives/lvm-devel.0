From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:34 +0000 (GMT)
Subject: main - lvmdbusd: Use pseudo tty to get "lvm>" prompt again
Message-ID: <20220919155834.40EEC3858290@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3d13c50d7adb838675929968317f9e42a2f485f
Commit:        b3d13c50d7adb838675929968317f9e42a2f485f
Parent:        664a06650db5acca2ac9a285e6ebddbde6157300
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Sep 6 16:23:06 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Use pseudo tty to get "lvm>" prompt again

When lvm is compiled with editline, if the file descriptors don't look like
a tty, then no "lvm> " prompt is done.  Having lvm output the shell prompt
when consuming JSON on a report file descriptor is very useful in
determining if lvm command is complete.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 112 ++++++++++++++++++---------------
 1 file changed, 63 insertions(+), 49 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
old mode 100644
new mode 100755
index 77c0078ee..9696a70a5
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -14,11 +14,11 @@
 import subprocess
 import shlex
 import os
+import pty
 import sys
 import tempfile
 import time
 import select
-from .utils import extract_stack_trace
 
 try:
 	import simplejson as json
@@ -28,7 +28,9 @@ except ImportError:
 
 from lvmdbusd.cfg import LVM_CMD, run
 from lvmdbusd.utils import log_debug, log_error, add_no_notify, make_non_block,\
-							read_decoded
+			read_decoded, extract_stack_trace, LvmBug
+
+SHELL_PROMPT = "lvm> "
 
 
 def _quote_arg(arg):
@@ -44,7 +46,7 @@ class LVMShellProxy(object):
 	# up trying to get one.
 	#
 	# Returns stdout, report (JSON), stderr
-	def _read_response(self):
+	def _read_response(self, no_output=False):
 		stdout = ""
 		report = ""
 		stderr = ""
@@ -60,50 +62,49 @@ class LVMShellProxy(object):
 		while keep_reading and run.value != 0:
 			try:
 				rd_fd = [
-					self.lvm_shell.stdout.fileno(),
+					self.parent_stdout_fd,
 					self.report_stream.fileno(),
-					self.lvm_shell.stderr.fileno()]
+					self.parent_stderr_fd]
 				ready = select.select(rd_fd, [], [], 2)
 
 				for r in ready[0]:
-					if r == self.lvm_shell.stdout.fileno():
-						stdout += read_decoded(self.lvm_shell.stdout)
+					if r == self.parent_stdout_fd:
+						stdout += self.parent_stdout.readline()
 					elif r == self.report_stream.fileno():
 						report += read_decoded(self.report_stream)
-					elif r == self.lvm_shell.stderr.fileno():
-						stderr += read_decoded(self.lvm_shell.stderr)
+					elif r == self.parent_stderr_fd:
+						stderr += self.parent_stderr.readline()
 
 				# Check to see if the lvm process died on us
 				if self.lvm_shell.poll() is not None:
 					raise Exception(self.lvm_shell.returncode, "%s" % stderr)
 
-				cur_report_len = len(report)
-				if cur_report_len != 0:
-					# Only bother to parse if we have more data and the last 2 characters match expected
-					# complete JSON, prevents excessive JSON parsing attempts
-					if prev_report_len != cur_report_len and report[-2:] == "}\n":
-						prev_report_len = cur_report_len
-
-						# Parse the JSON if it's good we are done,
-						# if not we will try to read some more.
-						try:
-							report_json = json.loads(report)
-							keep_reading = False
-						except ValueError:
-							pass
-
-				# As long as lvm is spewing something on one of the FDs we will
-				# keep trying.  If we get a few timeouts with no activity, and
-				# we don't have valid JSON, we will raise an error.
-				if len(ready) == 0 and keep_reading:
-					extra_passes -= 1
-					if extra_passes <= 0:
-						if len(report):
-							raise ValueError("Invalid json: %s" %
-												report)
-						else:
-							raise ValueError(
-								"lvm returned no JSON output!")
+				if stdout.endswith(SHELL_PROMPT):
+					if no_output:
+						keep_reading = False
+					else:
+						cur_report_len = len(report)
+						if cur_report_len != 0:
+							# Only bother to parse if we have more data
+							if prev_report_len != cur_report_len:
+								prev_report_len = cur_report_len
+								# Parse the JSON if it's good we are done,
+								# if not we will try to read some more.
+								try:
+									report_json = json.loads(report)
+									keep_reading = False
+								except ValueError:
+									pass
+
+						if keep_reading:
+							extra_passes -= 1
+							if extra_passes <= 0:
+								if len(report):
+									raise LvmBug("Invalid json: %s" %
+														report)
+								else:
+									raise LvmBug(
+										"lvm returned no JSON output!")
 
 			except IOError as ioe:
 				log_debug(str(ioe))
@@ -119,10 +120,8 @@ class LVMShellProxy(object):
 		return stdout, report_json, stderr
 
 	def _write_cmd(self, cmd):
-		cmd_bytes = bytes(cmd, "utf-8")
-		num_written = self.lvm_shell.stdin.write(cmd_bytes)
-		assert (num_written == len(cmd_bytes))
-		self.lvm_shell.stdin.flush()
+		self.parent_stdin.write(cmd)
+		self.parent_stdin.flush()
 
 	def __init__(self):
 		# Create a temp directory
@@ -147,22 +146,37 @@ class LVMShellProxy(object):
 			if "LVM" in k:
 				local_env[k] = v
 
+		self.parent_stdin_fd, child_stdin_fd = pty.openpty()
+		self.parent_stdout_fd, child_stdout_fd = pty.openpty()
+		self.parent_stderr_fd, child_stderr_fd = pty.openpty()
+		self.parent_stdin = os.fdopen(self.parent_stdin_fd, "w")
+		self.parent_stdout = os.fdopen(self.parent_stdout_fd, "r")
+		self.parent_stderr = os.fdopen(self.parent_stderr_fd, "r")
+
 		# run the lvm shell
 		self.lvm_shell = subprocess.Popen(
 			[LVM_CMD],
-			stdin=subprocess.PIPE, stdout=subprocess.PIPE, env=local_env,
-			stderr=subprocess.PIPE, close_fds=True, pass_fds=(lvm_fd,), shell=False)
+			stdin=child_stdin_fd,
+			stdout=child_stdout_fd, env=local_env,
+			stderr=child_stderr_fd, close_fds=True,
+			pass_fds=(lvm_fd,), shell=False)
 
 		try:
-			make_non_block(self.lvm_shell.stdout)
-			make_non_block(self.lvm_shell.stderr)
+			make_non_block(self.parent_stdout_fd)
+			make_non_block(self.parent_stderr_fd)
 
-			# Close our copy of the lvm_fd, child process is open in its process space
+			# Close our copies of the child FDs there were created with the fork, we don't need them open.
 			os.close(lvm_fd)
-
-			# Assume we are ready as we may not get the lvm prompt message depending on
-			# if we are using readline or editline.
-
+			os.close(child_stdin_fd)
+			os.close(child_stdout_fd)
+			os.close(child_stderr_fd)
+
+			# wait for the first prompt
+			log_debug("waiting for first prompt...")
+			errors = self._read_response(no_output=True)[2]
+			if errors and len(errors):
+				raise LvmBug(errors)
+			log_debug("lvm prompt read!!!")
 		except:
 			raise
 		finally:

