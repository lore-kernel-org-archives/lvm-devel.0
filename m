From: Tony Asleson <tasleson@sourceware.org>
Date: Tue, 29 Nov 2022 19:01:37 +0000 (GMT)
Subject: main - lvmdbusd: Add command_log_selection to command line
Message-ID: <20221129190137.621AD3858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e63b0c7262f50ab43fcde1c50b6d880acab68407
Commit:        e63b0c7262f50ab43fcde1c50b6d880acab68407
Parent:        8f60c494515ddccb20e4afb804edb6b9599e65c0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 29 10:04:17 2022 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 29 12:56:55 2022 -0600

lvmdbusd: Add command_log_selection to command line

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=2145114
---
 daemons/lvmdbusd/cmdhandler.py | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 0c7bd8528..9a76db4c9 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -17,7 +17,7 @@ import os
 
 from lvmdbusd import cfg
 from lvmdbusd.utils import pv_dest_ranges, log_debug, log_error, add_no_notify,\
-			make_non_block, read_decoded, extract_stack_trace, LvmBug, add_config_option
+			make_non_block, read_decoded, extract_stack_trace, LvmBug, add_config_option, get_error_msg
 from lvmdbusd.lvm_shell_proxy import LVMShellProxy
 
 try:
@@ -121,6 +121,9 @@ def call_lvm(command, debug=False, line_cb=None,
 	command.insert(0, cfg.LVM_CMD)
 	command = add_no_notify(command)
 
+	# Ensure we get an error message when we fork & exec the lvm command line
+	command = add_config_option(command, "--config", 'log/command_log_selection="log_context!=''"')
+
 	process = Popen(command, stdout=PIPE, stderr=PIPE, close_fds=True,
 					env=os.environ)
 
@@ -167,7 +170,17 @@ def call_lvm(command, debug=False, line_cb=None,
 		if debug or (process.returncode != 0 and (process.returncode != 5 and "fullreport" in command)):
 			_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
-		return process.returncode, stdout_text, stderr_text
+		try:
+			report_json = json.loads(stdout_text)
+		except json.decoder.JSONDecodeError:
+			# Some lvm commands don't return json even though we are asking for it to do so.
+			return process.returncode, stdout_text, stderr_text
+
+		error_msg = get_error_msg(report_json)
+		if error_msg:
+			stderr_text += error_msg
+
+		return process.returncode, report_json, stderr_text
 	else:
 		if cfg.run.value == 0:
 			raise SystemExit
@@ -619,20 +632,8 @@ def lvm_full_report_json():
 	rc, out, err = call(cmd)
 	# When we have an exported vg the exit code of lvs or fullreport will be 5
 	if rc == 0 or rc == 5:
-		# If the 'call' implementation is lvmshell, the out is a dictionary as lvmshell has to
-		# parse the output to get the exit value.  When doing fork & exec, out is a string
-		# representing the JSON.  TODO: Make this consistent between implementations.
-		if cfg.SHELL_IN_USE:
-			assert(type(out) == dict)
-			return out
-		else:
-			try:
-				return json.loads(out)
-			except json.decoder.JSONDecodeError as joe:
-				log_error("JSONDecodeError %s, \n JSON=\n%s\n" %
-							(str(joe), out))
-				raise LvmBug("'fullreport' returned invalid JSON")
-
+		assert(type(out) == dict)
+		return out
 	raise LvmBug("'fullreport' exited with code '%d'" % rc)
 
 

