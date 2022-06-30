From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:46 +0000 (GMT)
Subject: main - lvmdbusd: Don't require "lvm> " prompt for shell
Message-ID: <20220630160046.08A2D386F0D2@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=691494268502ddb20da2a14568984c0fa4f29f50
Commit:        691494268502ddb20da2a14568984c0fa4f29f50
Parent:        eee89a941eb4e63865356cfe9e513c24cfa8e0f9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 6 09:56:32 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Don't require "lvm> " prompt for shell

Depending on how lvm is compiled, it may not present the "lvm> " prompt
when using the lvm shell.  Don't require it to be present.

Addresses: https://bugzilla.redhat.com/show_bug.cgi?id=2090391
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 83 ++++++++++++++++++----------------
 1 file changed, 43 insertions(+), 40 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 1a5051a92..e106ca36f 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -19,7 +19,6 @@ import sys
 import tempfile
 import time
 import select
-import copy
 
 try:
 	import simplejson as json
@@ -31,8 +30,6 @@ from lvmdbusd.cfg import LVM_CMD
 from lvmdbusd.utils import log_debug, log_error, add_no_notify, make_non_block,\
 							read_decoded
 
-SHELL_PROMPT = "lvm> "
-
 
 def _quote_arg(arg):
 	if len(shlex.split(arg)) > 1:
@@ -43,10 +40,11 @@ def _quote_arg(arg):
 
 class LVMShellProxy(object):
 
-	# Read until we get prompt back and a result
-	# @param: no_output	Caller expects no output to report FD
-	# Returns stdout, report, stderr (report is JSON!)
-	def _read_until_prompt(self, no_output=False):
+	# Read REPORT FD until we have a complete and valid JSON record or give
+	# up trying to get one.
+	#
+	# Returns stdout, report (JSON), stderr
+	def _read_response(self):
 		stdout = ""
 		report = ""
 		stderr = ""
@@ -58,6 +56,7 @@ class LVMShellProxy(object):
 		# Try reading from all FDs to prevent one from filling up and causing
 		# a hang.  Keep reading until we get the prompt back and the report
 		# FD does not contain valid JSON
+
 		while keep_reading:
 			try:
 				rd_fd = [
@@ -78,32 +77,33 @@ class LVMShellProxy(object):
 				if self.lvm_shell.poll() is not None:
 					raise Exception(self.lvm_shell.returncode, "%s" % stderr)
 
-				if stdout.endswith(SHELL_PROMPT):
-					if no_output:
-						keep_reading = False
-					else:
-						cur_report_len = len(report)
-						if cur_report_len != 0:
-							# Only bother to parse if we have more data
-							if prev_report_len != cur_report_len:
-								prev_report_len = cur_report_len
-								# Parse the JSON if it's good we are done,
-								# if not we will try to read some more.
-								try:
-									report_json = json.loads(report)
-									keep_reading = False
-								except ValueError:
-									pass
-
-						if keep_reading:
-							extra_passes -= 1
-							if extra_passes <= 0:
-								if len(report):
-									raise ValueError("Invalid json: %s" %
-														report)
-								else:
-									raise ValueError(
-										"lvm returned no JSON output!")
+				cur_report_len = len(report)
+				if cur_report_len != 0:
+					# Only bother to parse if we have more data and the last 2 characters match expected
+					# complete JSON, prevents excessive JSON parsing attempts
+					if prev_report_len != cur_report_len and report[-2:] == "}\n":
+						prev_report_len = cur_report_len
+
+						# Parse the JSON if it's good we are done,
+						# if not we will try to read some more.
+						try:
+							report_json = json.loads(report)
+							keep_reading = False
+						except ValueError:
+							pass
+
+				# As long as lvm is spewing something on one of the FDs we will
+				# keep trying.  If we get a few timeouts with no activity, and
+				# we don't have valid JSON, we will raise an error.
+				if len(ready) == 0 and keep_reading:
+					extra_passes -= 1
+					if extra_passes <= 0:
+						if len(report):
+							raise ValueError("Invalid json: %s" %
+												report)
+						else:
+							raise ValueError(
+								"lvm returned no JSON output!")
 
 			except IOError as ioe:
 				log_debug(str(ioe))
@@ -118,7 +118,6 @@ class LVMShellProxy(object):
 		self.lvm_shell.stdin.flush()
 
 	def __init__(self):
-
 		# Create a temp directory
 		tmp_dir = tempfile.mkdtemp(prefix="lvmdbus_")
 		tmp_file = "%s/lvmdbus_report" % (tmp_dir)
@@ -139,6 +138,11 @@ class LVMShellProxy(object):
 		local_env = {"LC_ALL": "C", "LVM_REPORT_FD": "%s" % lvm_fd, "LVM_COMMAND_PROFILE": "lvmdbusd",
 					 "LVM_LOG_FILE_MAX_LINES": "0"}
 
+		# If any env variables contain LVM we will propagate them too
+		for k, v in os.environ.items():
+			if "LVM" in k:
+				local_env[k] = v
+
 		# run the lvm shell
 		self.lvm_shell = subprocess.Popen(
 			[LVM_CMD],
@@ -152,10 +156,9 @@ class LVMShellProxy(object):
 			# Close our copy of the lvm_fd, child process is open in its process space
 			os.close(lvm_fd)
 
-			# wait for the first prompt
-			errors = self._read_until_prompt(no_output=True)[2]
-			if errors and len(errors):
-				raise RuntimeError(errors)
+			# Assume we are ready as we may not get the lvm prompt message depending on
+			# if we are using readline or editline.
+
 		except:
 			raise
 		finally:
@@ -169,7 +172,7 @@ class LVMShellProxy(object):
 		self._write_cmd('lastlog\n')
 
 		# read everything from the STDOUT to the next prompt
-		stdout, report_json, stderr = self._read_until_prompt()
+		stdout, report_json, stderr = self._read_response()
 		if 'log' in report_json:
 			error_msg = ""
 			# Walk the entire log array and build an error string
@@ -203,7 +206,7 @@ class LVMShellProxy(object):
 		self._write_cmd(cmd)
 
 		# read everything from the STDOUT to the next prompt
-		stdout, report_json, stderr = self._read_until_prompt()
+		stdout, report_json, stderr = self._read_response()
 
 		# Parse the report to see what happened
 		if 'log' in report_json:

