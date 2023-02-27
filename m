From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 27 Feb 2023 15:09:39 +0000 (GMT)
Subject: main - lvmdbusd: Add lock to prevent concurrent lvm shell access
Message-ID: <20230227150939.39DE53858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0e75bd356a070423754676872b7b6948913be2e
Commit:        b0e75bd356a070423754676872b7b6948913be2e
Parent:        e3b7395af460033493a01d222b52cf8931090f64
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Feb 27 08:57:24 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 27 09:07:43 2023 -0600

lvmdbusd: Add lock to prevent concurrent lvm shell access

There is a window of time where the following can occur.

1. An API request is in process to the lvm shell, we have written some
   command to the lvm shell and we are blocked on that thread waiting
2. A signal arrives to the daemon which causes us to exit.  The signal
   handling code path goes directly to the lvm shell and writes
   "exit\n".  This causes the lvm shell to simply exit.
3. The thread that was waiting for a response gets an EIO as the child
   process has exited.  This bubbles up a failure.

This is addressed by placing a lock in the lvm shell to prevent
concurrent access to the shell.  We also gather additional debug data
when we get an error in the lvm shell read path.  This should help if
the lvm shell exits/crashes on its own.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 78 ++++++++++++++++++++--------------
 1 file changed, 45 insertions(+), 33 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 37d73218b..b8c8fa565 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -18,6 +18,7 @@ import pty
 import sys
 import tempfile
 import time
+import threading
 import select
 
 try:
@@ -107,11 +108,14 @@ class LVMShellProxy(object):
 								else:
 									raise LvmBug(
 										"lvm returned no JSON output!")
-
-			except IOError as ioe:
-				log_debug(str(ioe))
-				self.exit_shell()
-				raise ioe
+			except Exception as e:
+				log_error("While reading from lvm shell we encountered an error %s" % str(e))
+				log_error("stdout= %s\nstderr= %s\n" % (stdout, stderr))
+				if self.lvm_shell.poll() is not None:
+					log_error("Underlying lvm shell process unexpectedly exited: %d" % self.lvm_shell.returncode)
+				else:
+					log_error("Underlying lvm shell process is still present!")
+				raise e
 
 		if keep_reading and cfg.run.value == 0:
 			# We didn't complete as we are shutting down
@@ -131,6 +135,10 @@ class LVMShellProxy(object):
 		tmp_dir = tempfile.mkdtemp(prefix="lvmdbus_")
 		tmp_file = "%s/lvmdbus_report" % (tmp_dir)
 
+		# Create a lock so that we don't step on each other when we are waiting for a command
+		# to finish and some other request comes in concurrently, like to exit the shell.
+		self.shell_lock = threading.RLock()
+
 		# Create a fifo for the report output
 		os.mkfifo(tmp_file, 0o600)
 
@@ -188,7 +196,8 @@ class LVMShellProxy(object):
 			os.unlink(tmp_file)
 			os.rmdir(tmp_dir)
 
-	def get_last_log(self):
+	def _get_last_log(self):
+		# Precondition, lock is held
 		self._write_cmd('lastlog\n')
 		report_json = self._read_response()[1]
 		return get_error_msg(report_json)
@@ -209,28 +218,29 @@ class LVMShellProxy(object):
 		cmd += "\n"
 
 		# run the command by writing it to the shell's STDIN
-		self._write_cmd(cmd)
-
-		# read everything from the STDOUT to the next prompt
-		stdout, report_json, stderr = self._read_response()
-
-		# Parse the report to see what happened
-		if 'log' in report_json:
-			ret_code = int(report_json['log'][-1:][0]['log_ret_code'])
-			# If we have an exported vg we get a log_ret_code == 5 when
-			# we do a 'fullreport'
-			# Note: 0 == error
-			if (ret_code == 1) or (ret_code == 5 and argv[0] == 'fullreport'):
-				rc = 0
-			else:
-				# Depending on where lvm fails the command, it may not have anything
-				# to report for "lastlog", so we need to check for a message in the
-				# report json too.
-				error_msg = self.get_last_log()
-				if error_msg is None:
-					error_msg = get_error_msg(report_json)
+		with self.shell_lock:
+			self._write_cmd(cmd)
+
+			# read everything from the STDOUT to the next prompt
+			stdout, report_json, stderr = self._read_response()
+
+			# Parse the report to see what happened
+			if 'log' in report_json:
+				ret_code = int(report_json['log'][-1:][0]['log_ret_code'])
+				# If we have an exported vg we get a log_ret_code == 5 when
+				# we do a 'fullreport'
+				# Note: 0 == error
+				if (ret_code == 1) or (ret_code == 5 and argv[0] == 'fullreport'):
+					rc = 0
+				else:
+					# Depending on where lvm fails the command, it may not have anything
+					# to report for "lastlog", so we need to check for a message in the
+					# report json too.
+					error_msg = self._get_last_log()
 					if error_msg is None:
-						error_msg = 'No error reason provided! (missing "log" section)'
+						error_msg = get_error_msg(report_json)
+						if error_msg is None:
+							error_msg = 'No error reason provided! (missing "log" section)'
 
 		if debug or rc != 0:
 			log_error(("CMD= %s" % cmd))
@@ -240,12 +250,14 @@ class LVMShellProxy(object):
 		return rc, report_json, error_msg
 
 	def exit_shell(self):
-		try:
-			self._write_cmd('exit\n')
-			self.lvm_shell.wait(1)
-			self.lvm_shell = None
-		except Exception as _e:
-			log_error(str(_e))
+		with self.shell_lock:
+			try:
+				if self.lvm_shell is not None:
+					self._write_cmd('exit\n')
+					self.lvm_shell.wait(1)
+					self.lvm_shell = None
+			except Exception as _e:
+				log_error("exit_shell: %s" % (str(_e)))
 
 	def __del__(self):
 		# Note: When we are shutting down the daemon and the main process has already exited

