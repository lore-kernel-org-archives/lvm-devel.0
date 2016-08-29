From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:36 +0000 (UTC)
Subject: master - lvmdbusd: Add support for using lvm shell
Message-ID: <20160829202836.7B61D6190A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2352ff24a55757a70869f443126d67cece0fb0a4
Commit:        2352ff24a55757a70869f443126d67cece0fb0a4
Parent:        a0a2c84a26a9542d32fa7db1f7dcae8ccb8beb88
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Aug 12 15:23:05 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:55 2016 -0500

lvmdbusd: Add support for using lvm shell

With the addition of JSON and the ability to get output which is known to
not contain any extraneous text we can now leverage lvm shell, so that we
don't fork and exec lvm command line repeatedly.
---
 daemons/lvmdbusd/cmdhandler.py      |   53 ++++++---
 daemons/lvmdbusd/lvm_shell_proxy.py |  224 +++++++++++++++++++++-------------
 daemons/lvmdbusd/main.py            |    7 +-
 3 files changed, 177 insertions(+), 107 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index fac582c..0d35782 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -12,6 +12,7 @@ import time
 import threading
 from itertools import chain
 import collections
+import traceback
 
 try:
 	from . import cfg
@@ -119,27 +120,22 @@ def call_lvm(command, debug=False):
 
 def _shell_cfg():
 	global _t_call
-	log_debug('Using lvm shell!')
-	lvm_shell = LVMShellProxy()
-	_t_call = lvm_shell.call_lvm
-
-
-if cfg.USE_SHELL:
-	_shell_cfg()
-else:
-	_t_call = call_lvm
+	try:
+		lvm_shell = LVMShellProxy()
+		_t_call = lvm_shell.call_lvm
+		cfg.USE_SHELL = True
+	except Exception:
+		_t_call = call_lvm
+		log_error(traceback.format_exc())
+		log_error("Unable to utilize lvm shell, dropping back to fork & exec")
 
 
 def set_execution(shell):
 	global _t_call
 	with cmd_lock:
-		_t_call = None
+		_t_call = call_lvm
 		if shell:
-			log_debug('Using lvm shell!')
-			lvm_shell = LVMShellProxy()
-			_t_call = lvm_shell.call_lvm
-		else:
-			_t_call = call_lvm
+			_shell_cfg()
 
 
 def time_wrapper(command, debug=False):
@@ -219,6 +215,13 @@ def pv_remove(device, remove_options):
 	return call(cmd)
 
 
+def _qt(tag_name):
+	# When running in lvm shell you need to quote the tags
+	if cfg.USE_SHELL:
+		return '"%s"' % tag_name
+	return tag_name
+
+
 def _tag(operation, what, add, rm, tag_options):
 	cmd = [operation]
 	cmd.extend(options_to_cli_args(tag_options))
@@ -229,9 +232,11 @@ def _tag(operation, what, add, rm, tag_options):
 		cmd.append(what)
 
 	if add:
-		cmd.extend(list(chain.from_iterable(('--addtag', x) for x in add)))
+		cmd.extend(list(chain.from_iterable(
+			('--addtag', _qt(x)) for x in add)))
 	if rm:
-		cmd.extend(list(chain.from_iterable(('--deltag', x) for x in rm)))
+		cmd.extend(list(chain.from_iterable(
+			('--deltag', _qt(x)) for x in rm)))
 
 	return call(cmd, False)
 
@@ -435,8 +440,11 @@ def supports_json():
 	cmd = ['help']
 	rc, out, err = call(cmd)
 	if rc == 0:
-		if 'fullreport' in err:
+		if cfg.USE_SHELL:
 			return True
+		else:
+			if 'fullreport' in err:
+				return True
 	return False
 
 
@@ -477,7 +485,14 @@ def lvm_full_report_json():
 
 	rc, out, err = call(cmd)
 	if rc == 0:
-		return json.loads(out)
+		# With the current implementation, if we are using the shell then we
+		# are using JSON and JSON is returned back to us as it was parsed to
+		# figure out if we completed OK or not
+		if cfg.USE_SHELL:
+			assert(type(out) == dict)
+			return out
+		else:
+			return json.loads(out)
 	return None
 
 
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 3835c74..d4eff86 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -14,10 +14,20 @@
 import subprocess
 import shlex
 from fcntl import fcntl, F_GETFL, F_SETFL
-from os import O_NONBLOCK
+import os
 import traceback
 import sys
-import re
+import tempfile
+import time
+import select
+import copy
+
+try:
+	from simplejson.scanner import JSONDecodeError
+	import simplejson as json
+except ImportError:
+	import json
+
 
 try:
 	from .cfg import LVM_CMD
@@ -38,42 +48,52 @@ def _quote_arg(arg):
 
 class LVMShellProxy(object):
 	def _read_until_prompt(self):
-		prev_ec = None
 		stdout = ""
-		while not stdout.endswith(SHELL_PROMPT):
-			try:
-				tmp = self.lvm_shell.stdout.read()
-				if tmp:
-					stdout += tmp.decode("utf-8")
-			except IOError:
-				# nothing written yet
-				pass
-
-		# strip the prompt from the STDOUT before returning and grab the exit
-		# code if it's available
-		m = self.re.match(stdout)
-		if m:
-			prev_ec = int(m.group(2))
-			strip_idx = -1 * len(m.group(1))
-		else:
-			strip_idx = -1 * len(SHELL_PROMPT)
-
-		return stdout[:strip_idx], prev_ec
+		report = ""
+		stderr = ""
 
-	def _read_line(self):
-		while True:
+		# Try reading from all FDs to prevent one from filling up and causing
+		# a hang.  We are also assuming that we won't get the lvm prompt back
+		# until we have already received all the output from stderr and the
+		# report descriptor too.
+		while not stdout.endswith(SHELL_PROMPT):
 			try:
-				tmp = self.lvm_shell.stdout.readline()
-				if tmp:
-					return tmp.decode("utf-8")
-			except IOError:
+				rd_fd = [
+					self.lvm_shell.stdout.fileno(),
+					self.report_r,
+					self.lvm_shell.stderr.fileno()]
+				ready = select.select(rd_fd, [], [], 2)
+
+				for r in ready[0]:
+					if r == self.lvm_shell.stdout.fileno():
+						while True:
+							tmp = self.lvm_shell.stdout.read()
+							if tmp:
+								stdout += tmp.decode("utf-8")
+							else:
+								break
+
+					elif r == self.report_r:
+						while True:
+							tmp = os.read(self.report_r, 16384)
+							if tmp:
+								report += tmp.decode("utf-8")
+								if len(tmp) != 16384:
+									break
+
+					elif r == self.lvm_shell.stderr.fileno():
+						while True:
+							tmp = self.lvm_shell.stderr.read()
+							if tmp:
+								stderr += tmp.decode("utf-8")
+							else:
+								break
+
+			except IOError as ioe:
+				log_debug(str(ioe))
 				pass
 
-	def _discard_echo(self, expected):
-		line = ""
-		while line != expected:
-			# GNU readline inserts some interesting characters at times...
-			line += self._read_line().replace(' \r', '')
+		return stdout, report, stderr
 
 	def _write_cmd(self, cmd):
 		cmd_bytes = bytes(cmd, "utf-8")
@@ -81,39 +101,82 @@ class LVMShellProxy(object):
 		assert (num_written == len(cmd_bytes))
 		self.lvm_shell.stdin.flush()
 
-	def _lvm_echos(self):
-		echo = False
-		cmd = "version\n"
-		self._write_cmd(cmd)
-		line = self._read_line()
+	def __init__(self):
 
-		if line == cmd:
-			echo = True
+		# Create a temp directory
+		tmp_dir = tempfile.mkdtemp(prefix="lvmdbus_")
+		tmp_file = "%s/lvmdbus_report" % (tmp_dir)
 
-		self._read_until_prompt()
+		try:
+			# Lets create fifo for the report output
+			os.mkfifo(tmp_file, 0o600)
+		except FileExistsError:
+			pass
 
-		return echo
+		self.report_r = os.open(tmp_file, os.O_NONBLOCK)
+
+		# Setup the environment for using our own socket for reporting
+		local_env = copy.deepcopy(os.environ)
+		local_env["LVM_REPORT_FD"] = "32"
+		local_env["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 
-	def __init__(self):
-		self.re = re.compile(".*(\[(-?[0-9]+)\] lvm> $)", re.DOTALL)
+
+		flags = fcntl(self.report_r, F_GETFL)
+		fcntl(self.report_r, F_SETFL, flags | os.O_NONBLOCK)
 
 		# run the lvm shell
 		self.lvm_shell = subprocess.Popen(
-			[LVM_CMD], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
-			stderr=subprocess.PIPE, close_fds=True)
+			[LVM_CMD + " 32>%s" % tmp_file],
+			stdin=subprocess.PIPE, stdout=subprocess.PIPE, env=local_env,
+			stderr=subprocess.PIPE, close_fds=True, shell=True)
 		flags = fcntl(self.lvm_shell.stdout, F_GETFL)
-		fcntl(self.lvm_shell.stdout, F_SETFL, flags | O_NONBLOCK)
+		fcntl(self.lvm_shell.stdout, F_SETFL, flags | os.O_NONBLOCK)
 		flags = fcntl(self.lvm_shell.stderr, F_GETFL)
-		fcntl(self.lvm_shell.stderr, F_SETFL, flags | O_NONBLOCK)
+		fcntl(self.lvm_shell.stderr, F_SETFL, flags | os.O_NONBLOCK)
 
 		# wait for the first prompt
-		self._read_until_prompt()
+		errors = self._read_until_prompt()[2]
+		if errors and len(errors):
+			raise RuntimeError(errors)
+
+		# These will get deleted when the FD count goes to zero so we can be
+		# sure to clean up correctly no matter how we finish
+		os.unlink(tmp_file)
+		os.rmdir(tmp_dir)
+
+	def get_error_msg(self):
+		# We got an error, lets go fetch the error message
+		self._write_cmd('lastlog\n')
+
+		# read everything from the STDOUT to the next prompt
+		stdout, report, stderr = self._read_until_prompt()
 
-		# Check to see if the version of LVM we are using is running with
-		# gnu readline which will echo our writes from stdin to stdout
-		self.echo = self._lvm_echos()
+		try:
+			log = json.loads(report)
+
+			if 'log' in log:
+				error_msg = ""
+				# Walk the entire log array and build an error string
+				for log_entry in log['log']:
+					if log_entry['log_type'] == "error":
+						if error_msg:
+							error_msg += ', ' + log_entry['log_message']
+						else:
+							error_msg = log_entry['log_message']
+
+				return error_msg
+
+			return 'No error reason provided! (missing "log" section)'
+		except ValueError:
+			log_error("Invalid JSON returned from LVM")
+			log_error("BEGIN>>\n%s\n<<END" % report)
+			return "Invalid JSON returned from LVM when retrieving exit code"
 
 	def call_lvm(self, argv, debug=False):
+		rc = 1
+		error_msg = ""
+		json_result = ""
+
 		# create the command string
 		cmd = " ".join(_quote_arg(arg) for arg in argv)
 		cmd += "\n"
@@ -121,46 +184,30 @@ class LVMShellProxy(object):
 		# run the command by writing it to the shell's STDIN
 		self._write_cmd(cmd)
 
-		# If lvm is utilizing gnu readline, it echos stdin to stdout
-		if self.echo:
-			self._discard_echo(cmd)
-
 		# read everything from the STDOUT to the next prompt
-		stdout, exit_code = self._read_until_prompt()
+		stdout, report, stderr = self._read_until_prompt()
 
-		# read everything from STDERR if there's something (we waited for the
-		# prompt on STDOUT so there should be all or nothing@this point on
-		# STDERR)
-		stderr = None
-		try:
-			t_error = self.lvm_shell.stderr.read()
-			if t_error:
-				stderr = t_error.decode("utf-8")
-		except IOError:
-			# nothing on STDERR
-			pass
-
-		if exit_code is not None:
-			rc = exit_code
-		else:
-			# LVM does write to stderr even when it did complete successfully,
-			# so without having the exit code in the prompt we can never be
-			# sure.
-			if stderr:
-				rc = 1
-			else:
-				rc = 0
+		# Parse the report to see what happened
+		if report and len(report):
+			json_result = json.loads(report)
+			if 'log' in json_result:
+				if json_result['log'][-1:][0]['log_ret_code'] == '1':
+					rc = 0
+				else:
+					error_msg = self.get_error_msg()
 
 		if debug or rc != 0:
 			log_error(('CMD: %s' % cmd))
 			log_error(("EC = %d" % rc))
-			log_error(("STDOUT=\n %s\n" % stdout))
-			log_error(("STDERR=\n %s\n" % stderr))
+			log_error(("ERROR_MSG=\n %s\n" % error_msg))
 
-		return (rc, stdout, stderr)
+		return rc, json_result, error_msg
 
 	def __del__(self):
-		self.lvm_shell.terminate()
+		try:
+			self.lvm_shell.terminate()
+		except:
+			pass
 
 
 if __name__ == "__main__":
@@ -170,10 +217,15 @@ if __name__ == "__main__":
 		while in_line:
 			in_line = input("lvm> ")
 			if in_line:
-				ret, out, err, = shell.call_lvm(in_line.split())
-				print(("RET: %d" % ret))
-				print(("OUT:\n%s" % out))
+				start = time.time()
+				ret, out, err = shell.call_lvm(in_line.split())
+				end = time.time()
+
+				print(("RC: %d" % ret))
+				#print(("OUT:\n%s" % out))
 				print(("ERR:\n%s" % err))
+
+				print("Command     = %f seconds" % (end - start))
 	except KeyboardInterrupt:
 		pass
 	except EOFError:
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index f28b402..638323a 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -100,10 +100,12 @@ def main():
 	parser.add_argument("--debug", action='store_true',
 						help="Dump debug messages", default=False,
 						dest='debug')
-
 	parser.add_argument("--nojson", action='store_false',
 						help="Do not use LVM JSON output", default=None,
 						dest='use_json')
+	parser.add_argument("--lvmshell", action='store_true',
+						help="Use the lvm shell, not fork & exec lvm", default=False,
+						dest='use_lvm_shell')
 
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
@@ -113,6 +115,7 @@ def main():
 	args = parser.parse_args()
 
 	cfg.DEBUG = args.debug
+	cmdhandler.set_execution(args.use_lvm_shell)
 
 	# List of threads that we start up
 	thread_list = []
@@ -159,7 +162,7 @@ def main():
 
 	end = time.time()
 	log_debug(
-		'Service ready! total time= %.2f, lvm time= %.2f count= %d' %
+		'Service ready! total time= %.4f, lvm time= %.4f count= %d' %
 		(end - start, cmdhandler.total_time, cmdhandler.total_count),
 		'bg_black', 'fg_light_green')
 


