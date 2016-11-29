From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 29 Nov 2016 22:51:27 +0000 (UTC)
Subject: master - lvmdbusd: Make lvm shell read more robust
Message-ID: <20161129225127.0F3A96079D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25b5413f895bc61357ef4afab255e3125335d4ec
Commit:        25b5413f895bc61357ef4afab255e3125335d4ec
Parent:        b0bda090054db75995ea350f55b59ae8444690da
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 29 11:07:21 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 29 16:50:30 2016 -0600

lvmdbusd: Make lvm shell read more robust

Make sure JSON is correct before we stop trying to read.
---
 daemons/lvmdbusd/lvm_shell_proxy.py |   98 ++++++++++++++++++-----------------
 1 files changed, 50 insertions(+), 48 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 50f2201..464da79 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -42,18 +42,22 @@ def _quote_arg(arg):
 
 
 class LVMShellProxy(object):
+
+	# Read until we get prompt back and a result
+	# @param: no_output	Caller expects no output to report FD
+	# Returns stdout, report, stderr (report is JSON!)
 	def _read_until_prompt(self, no_output=False):
 		stdout = ""
 		report = ""
 		stderr = ""
 		keep_reading = True
-		extra_passes = 2
+		extra_passes = 3
+		report_json = {}
+		prev_report_len = 0
 
 		# Try reading from all FDs to prevent one from filling up and causing
-		# a hang.  We were assuming that we won't get the lvm prompt back
-		# until we have already received all the output from stderr and the
-		# report descriptor too, this is an incorrect assumption.  Lvm will
-		# return the prompt before we get the report!
+		# a hang.  Keep reading until we get the prompt back and the report
+		# FD does not contain valid JSON
 		while keep_reading:
 			try:
 				rd_fd = [
@@ -87,26 +91,39 @@ class LVMShellProxy(object):
 					raise Exception(self.lvm_shell.returncode, "%s" % stderr)
 
 				if stdout.endswith(SHELL_PROMPT):
-					# It appears that lvm doesn't write the report and flush
-					# that before it writes the shell prompt as occasionally
-					# we get the prompt with no report.
 					if no_output:
 						keep_reading = False
 					else:
-						# Most of the time we have data, if we have none lets
-						# take another spin and hope we get it.
-						if len(report) != 0:
-							keep_reading = False
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
 						else:
+							log_error("RACE!", 'bg_black', 'fg_light_red')
+
+						if keep_reading:
 							extra_passes -= 1
 							if extra_passes <= 0:
-								keep_reading = False
+								if len(report):
+									raise ValueError("Invalid json: %s" %
+														report)
+								else:
+									raise ValueError(
+										"lvm returned no JSON output!")
 
 			except IOError as ioe:
 				log_debug(str(ioe))
 				pass
 
-		return stdout, report, stderr
+		return stdout, report_json, stderr
 
 	def _write_cmd(self, cmd):
 		cmd_bytes = bytes(cmd, "utf-8")
@@ -169,33 +186,24 @@ class LVMShellProxy(object):
 		self._write_cmd('lastlog\n')
 
 		# read everything from the STDOUT to the next prompt
-		stdout, report, stderr = self._read_until_prompt()
-
-		try:
-			log = json.loads(report)
-
-			if 'log' in log:
-				error_msg = ""
-				# Walk the entire log array and build an error string
-				for log_entry in log['log']:
-					if log_entry['log_type'] == "error":
-						if error_msg:
-							error_msg += ', ' + log_entry['log_message']
-						else:
-							error_msg = log_entry['log_message']
+		stdout, report_json, stderr = self._read_until_prompt()
+		if 'log' in report_json:
+			error_msg = ""
+			# Walk the entire log array and build an error string
+			for log_entry in report_json['log']:
+				if log_entry['log_type'] == "error":
+					if error_msg:
+						error_msg += ', ' + log_entry['log_message']
+					else:
+						error_msg = log_entry['log_message']
 
-				return error_msg
+			return error_msg
 
-			return 'No error reason provided! (missing "log" section)'
-		except ValueError:
-			log_error("Invalid JSON returned from LVM")
-			log_error("BEGIN>>\n%s\n<<END" % report)
-			return "Invalid JSON returned from LVM when retrieving exit code"
+		return 'No error reason provided! (missing "log" section)'
 
 	def call_lvm(self, argv, debug=False):
 		rc = 1
 		error_msg = ""
-		json_result = ""
 
 		if self.lvm_shell.poll():
 			raise Exception(
@@ -210,27 +218,21 @@ class LVMShellProxy(object):
 		self._write_cmd(cmd)
 
 		# read everything from the STDOUT to the next prompt
-		stdout, report, stderr = self._read_until_prompt()
+		stdout, report_json, stderr = self._read_until_prompt()
 
 		# Parse the report to see what happened
-		if report and len(report):
-			try:
-				json_result = json.loads(report)
-				if 'log' in json_result:
-					if json_result['log'][-1:][0]['log_ret_code'] == '1':
-						rc = 0
-					else:
-						error_msg = self.get_error_msg()
-			except ValueError:
-				# Bubble up the invalid json.
-				error_msg = "Invalid json %s" % report
+		if 'log' in report_json:
+			if report_json['log'][-1:][0]['log_ret_code'] == '1':
+				rc = 0
+			else:
+				error_msg = self.get_error_msg()
 
 		if debug or rc != 0:
 			log_error(('CMD: %s' % cmd))
 			log_error(("EC = %d" % rc))
 			log_error(("ERROR_MSG=\n %s\n" % error_msg))
 
-		return rc, json_result, error_msg
+		return rc, report_json, error_msg
 
 	def exit_shell(self):
 		try:


