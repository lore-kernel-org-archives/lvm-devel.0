From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 12 Dec 2017 07:17:50 -0500
Subject: master - lvmdbusd: All tools use detected python3
Message-ID: <201712121217.vBCCHo0r003878@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7272fd221096dbfd07e7ad11f0c938b453de2904
Commit:        7272fd221096dbfd07e7ad11f0c938b453de2904
Parent:        2f4c2a43d49d90875ea31b1507cd0dfcdb049e88
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Dec 12 13:10:51 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Dec 12 13:17:07 2017 +0100

lvmdbusd: All tools use detected python3

- lvmdb.py and lvm_shell_proxy.py can be used as standalone tools, so
  should use detected value.
- clean executable bit on *.in files.
---
 configure                              |    4 +-
 configure.in                           |    2 +
 daemons/lvmdbusd/.gitignore            |    2 +
 daemons/lvmdbusd/lvm_shell_proxy.py    |  269 ----------------
 daemons/lvmdbusd/lvm_shell_proxy.py.in |  269 ++++++++++++++++
 daemons/lvmdbusd/lvmdb.py              |  540 --------------------------------
 daemons/lvmdbusd/lvmdb.py.in           |  540 ++++++++++++++++++++++++++++++++
 7 files changed, 816 insertions(+), 810 deletions(-)

diff --git a/configure b/configure
index 7e2969a..d04b9d3 100755
--- a/configure
+++ b/configure
@@ -15778,7 +15778,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaem
 on/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service script
 s/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/
 Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_h
 at.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16489,6 +16489,8 @@ do
     "daemons/dmfilemapd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmfilemapd/Makefile" ;;
     "daemons/lvmdbusd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/Makefile" ;;
     "daemons/lvmdbusd/lvmdbusd") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/lvmdbusd" ;;
+    "daemons/lvmdbusd/lvmdb.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/lvmdb.py" ;;
+    "daemons/lvmdbusd/lvm_shell_proxy.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/lvm_shell_proxy.py" ;;
     "daemons/lvmdbusd/path.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/path.py" ;;
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "daemons/lvmpolld/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmpolld/Makefile" ;;
diff --git a/configure.in b/configure.in
index 88ee5ad..d879408 100644
--- a/configure.in
+++ b/configure.in
@@ -2187,6 +2187,8 @@ daemons/dmeventd/plugins/thin/Makefile
 daemons/dmfilemapd/Makefile
 daemons/lvmdbusd/Makefile
 daemons/lvmdbusd/lvmdbusd
+daemons/lvmdbusd/lvmdb.py
+daemons/lvmdbusd/lvm_shell_proxy.py
 daemons/lvmdbusd/path.py
 daemons/lvmetad/Makefile
 daemons/lvmpolld/Makefile
diff --git a/daemons/lvmdbusd/.gitignore b/daemons/lvmdbusd/.gitignore
index c0f6b4e..a5a5dd3 100644
--- a/daemons/lvmdbusd/.gitignore
+++ b/daemons/lvmdbusd/.gitignore
@@ -1,2 +1,4 @@
 path.py
 lvmdbusd
+lvmdb.py
+lvm_shell_proxy.py
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
deleted file mode 100755
index a26dd70..0000000
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ /dev/null
@@ -1,269 +0,0 @@
-#!/usr/bin/env python3
-
-# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program. If not, see <http://www.gnu.org/licenses/>.
-#
-# Copyright 2015-2016, Vratislav Podzimek <vpodzime@redhat.com>
-
-import subprocess
-import shlex
-from fcntl import fcntl, F_GETFL, F_SETFL
-import os
-import traceback
-import sys
-import tempfile
-import time
-import select
-import copy
-
-try:
-	import simplejson as json
-except ImportError:
-	import json
-
-
-from lvmdbusd.cfg import LVM_CMD
-from lvmdbusd.utils import log_debug, log_error, add_no_notify
-
-SHELL_PROMPT = "lvm> "
-
-
-def _quote_arg(arg):
-	if len(shlex.split(arg)) > 1:
-		return '"%s"' % arg
-	else:
-		return arg
-
-
-class LVMShellProxy(object):
-
-	@staticmethod
-	def _read(stream):
-		tmp = stream.read()
-		if tmp:
-			return tmp.decode("utf-8")
-		return ''
-
-	# Read until we get prompt back and a result
-	# @param: no_output	Caller expects no output to report FD
-	# Returns stdout, report, stderr (report is JSON!)
-	def _read_until_prompt(self, no_output=False):
-		stdout = ""
-		report = ""
-		stderr = ""
-		keep_reading = True
-		extra_passes = 3
-		report_json = {}
-		prev_report_len = 0
-
-		# Try reading from all FDs to prevent one from filling up and causing
-		# a hang.  Keep reading until we get the prompt back and the report
-		# FD does not contain valid JSON
-		while keep_reading:
-			try:
-				rd_fd = [
-					self.lvm_shell.stdout.fileno(),
-					self.report_stream.fileno(),
-					self.lvm_shell.stderr.fileno()]
-				ready = select.select(rd_fd, [], [], 2)
-
-				for r in ready[0]:
-					if r == self.lvm_shell.stdout.fileno():
-						stdout += LVMShellProxy._read(self.lvm_shell.stdout)
-					elif r == self.report_stream.fileno():
-						report += LVMShellProxy._read(self.report_stream)
-					elif r == self.lvm_shell.stderr.fileno():
-						stderr += LVMShellProxy._read(self.lvm_shell.stderr)
-
-				# Check to see if the lvm process died on us
-				if self.lvm_shell.poll():
-					raise Exception(self.lvm_shell.returncode, "%s" % stderr)
-
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
-
-			except IOError as ioe:
-				log_debug(str(ioe))
-				pass
-
-		return stdout, report_json, stderr
-
-	def _write_cmd(self, cmd):
-		cmd_bytes = bytes(cmd, "utf-8")
-		num_written = self.lvm_shell.stdin.write(cmd_bytes)
-		assert (num_written == len(cmd_bytes))
-		self.lvm_shell.stdin.flush()
-
-	@staticmethod
-	def _make_non_block(stream):
-		flags = fcntl(stream, F_GETFL)
-		fcntl(stream, F_SETFL, flags | os.O_NONBLOCK)
-
-	def __init__(self):
-
-		# Create a temp directory
-		tmp_dir = tempfile.mkdtemp(prefix="lvmdbus_")
-		tmp_file = "%s/lvmdbus_report" % (tmp_dir)
-
-		try:
-			# Lets create fifo for the report output
-			os.mkfifo(tmp_file, 0o600)
-		except FileExistsError:
-			pass
-
-		# We have to open non-blocking as the other side isn't open until
-		# we actually fork the process.
-		self.report_fd = os.open(tmp_file, os.O_NONBLOCK)
-		self.report_stream = os.fdopen(self.report_fd, 'rb', 0)
-
-		# Setup the environment for using our own socket for reporting
-		local_env = copy.deepcopy(os.environ)
-		local_env["LVM_REPORT_FD"] = "32"
-		local_env["LVM_COMMAND_PROFILE"] = "lvmdbusd"
-
-		# Disable the abort logic if lvm logs too much, which easily happens
-		# when utilizing the lvm shell.
-		local_env["LVM_LOG_FILE_MAX_LINES"] = "0"
-
-		# run the lvm shell
-		self.lvm_shell = subprocess.Popen(
-			[LVM_CMD + " 32>%s" % tmp_file],
-			stdin=subprocess.PIPE, stdout=subprocess.PIPE, env=local_env,
-			stderr=subprocess.PIPE, close_fds=True, shell=True)
-
-		try:
-			LVMShellProxy._make_non_block(self.lvm_shell.stdout)
-			LVMShellProxy._make_non_block(self.lvm_shell.stderr)
-
-			# wait for the first prompt
-			errors = self._read_until_prompt(no_output=True)[2]
-			if errors and len(errors):
-				raise RuntimeError(errors)
-		except:
-			raise
-		finally:
-			# These will get deleted when the FD count goes to zero so we
-			# can be sure to clean up correctly no matter how we finish
-			os.unlink(tmp_file)
-			os.rmdir(tmp_dir)
-
-	def get_error_msg(self):
-		# We got an error, lets go fetch the error message
-		self._write_cmd('lastlog\n')
-
-		# read everything from the STDOUT to the next prompt
-		stdout, report_json, stderr = self._read_until_prompt()
-		if 'log' in report_json:
-			error_msg = ""
-			# Walk the entire log array and build an error string
-			for log_entry in report_json['log']:
-				if log_entry['log_type'] == "error":
-					if error_msg:
-						error_msg += ', ' + log_entry['log_message']
-					else:
-						error_msg = log_entry['log_message']
-
-			return error_msg
-
-		return 'No error reason provided! (missing "log" section)'
-
-	def call_lvm(self, argv, debug=False):
-		rc = 1
-		error_msg = ""
-
-		if self.lvm_shell.poll():
-			raise Exception(
-				self.lvm_shell.returncode,
-				"Underlying lvm shell process is not present!")
-
-		argv = add_no_notify(argv)
-
-		# create the command string
-		cmd = " ".join(_quote_arg(arg) for arg in argv)
-		cmd += "\n"
-
-		# run the command by writing it to the shell's STDIN
-		self._write_cmd(cmd)
-
-		# read everything from the STDOUT to the next prompt
-		stdout, report_json, stderr = self._read_until_prompt()
-
-		# Parse the report to see what happened
-		if 'log' in report_json:
-			if report_json['log'][-1:][0]['log_ret_code'] == '1':
-				rc = 0
-			else:
-				error_msg = self.get_error_msg()
-
-		if debug or rc != 0:
-			log_error(('CMD: %s' % cmd))
-			log_error(("EC = %d" % rc))
-			log_error(("ERROR_MSG=\n %s\n" % error_msg))
-
-		return rc, report_json, error_msg
-
-	def exit_shell(self):
-		try:
-			self._write_cmd('exit\n')
-		except Exception as e:
-			log_error(str(e))
-
-	def __del__(self):
-		try:
-			self.lvm_shell.terminate()
-		except:
-			pass
-
-
-if __name__ == "__main__":
-	shell = LVMShellProxy()
-	in_line = "start"
-	try:
-		while in_line:
-			in_line = input("lvm> ")
-			if in_line:
-				start = time.time()
-				ret, out, err = shell.call_lvm(in_line.split())
-				end = time.time()
-
-				print(("RC: %d" % ret))
-				print(("OUT:\n%s" % out))
-				print(("ERR:\n%s" % err))
-
-				print("Command     = %f seconds" % (end - start))
-	except KeyboardInterrupt:
-		pass
-	except EOFError:
-		pass
-	except Exception:
-		traceback.print_exc(file=sys.stdout)
diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
new file mode 100644
index 0000000..203de6f
--- /dev/null
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -0,0 +1,269 @@
+#!@PYTHON3@
+
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+#
+# Copyright 2015-2016, Vratislav Podzimek <vpodzime@redhat.com>
+
+import subprocess
+import shlex
+from fcntl import fcntl, F_GETFL, F_SETFL
+import os
+import traceback
+import sys
+import tempfile
+import time
+import select
+import copy
+
+try:
+	import simplejson as json
+except ImportError:
+	import json
+
+
+from lvmdbusd.cfg import LVM_CMD
+from lvmdbusd.utils import log_debug, log_error, add_no_notify
+
+SHELL_PROMPT = "lvm> "
+
+
+def _quote_arg(arg):
+	if len(shlex.split(arg)) > 1:
+		return '"%s"' % arg
+	else:
+		return arg
+
+
+class LVMShellProxy(object):
+
+	@staticmethod
+	def _read(stream):
+		tmp = stream.read()
+		if tmp:
+			return tmp.decode("utf-8")
+		return ''
+
+	# Read until we get prompt back and a result
+	# @param: no_output	Caller expects no output to report FD
+	# Returns stdout, report, stderr (report is JSON!)
+	def _read_until_prompt(self, no_output=False):
+		stdout = ""
+		report = ""
+		stderr = ""
+		keep_reading = True
+		extra_passes = 3
+		report_json = {}
+		prev_report_len = 0
+
+		# Try reading from all FDs to prevent one from filling up and causing
+		# a hang.  Keep reading until we get the prompt back and the report
+		# FD does not contain valid JSON
+		while keep_reading:
+			try:
+				rd_fd = [
+					self.lvm_shell.stdout.fileno(),
+					self.report_stream.fileno(),
+					self.lvm_shell.stderr.fileno()]
+				ready = select.select(rd_fd, [], [], 2)
+
+				for r in ready[0]:
+					if r == self.lvm_shell.stdout.fileno():
+						stdout += LVMShellProxy._read(self.lvm_shell.stdout)
+					elif r == self.report_stream.fileno():
+						report += LVMShellProxy._read(self.report_stream)
+					elif r == self.lvm_shell.stderr.fileno():
+						stderr += LVMShellProxy._read(self.lvm_shell.stderr)
+
+				# Check to see if the lvm process died on us
+				if self.lvm_shell.poll():
+					raise Exception(self.lvm_shell.returncode, "%s" % stderr)
+
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
+									raise ValueError("Invalid json: %s" %
+														report)
+								else:
+									raise ValueError(
+										"lvm returned no JSON output!")
+
+			except IOError as ioe:
+				log_debug(str(ioe))
+				pass
+
+		return stdout, report_json, stderr
+
+	def _write_cmd(self, cmd):
+		cmd_bytes = bytes(cmd, "utf-8")
+		num_written = self.lvm_shell.stdin.write(cmd_bytes)
+		assert (num_written == len(cmd_bytes))
+		self.lvm_shell.stdin.flush()
+
+	@staticmethod
+	def _make_non_block(stream):
+		flags = fcntl(stream, F_GETFL)
+		fcntl(stream, F_SETFL, flags | os.O_NONBLOCK)
+
+	def __init__(self):
+
+		# Create a temp directory
+		tmp_dir = tempfile.mkdtemp(prefix="lvmdbus_")
+		tmp_file = "%s/lvmdbus_report" % (tmp_dir)
+
+		try:
+			# Lets create fifo for the report output
+			os.mkfifo(tmp_file, 0o600)
+		except FileExistsError:
+			pass
+
+		# We have to open non-blocking as the other side isn't open until
+		# we actually fork the process.
+		self.report_fd = os.open(tmp_file, os.O_NONBLOCK)
+		self.report_stream = os.fdopen(self.report_fd, 'rb', 0)
+
+		# Setup the environment for using our own socket for reporting
+		local_env = copy.deepcopy(os.environ)
+		local_env["LVM_REPORT_FD"] = "32"
+		local_env["LVM_COMMAND_PROFILE"] = "lvmdbusd"
+
+		# Disable the abort logic if lvm logs too much, which easily happens
+		# when utilizing the lvm shell.
+		local_env["LVM_LOG_FILE_MAX_LINES"] = "0"
+
+		# run the lvm shell
+		self.lvm_shell = subprocess.Popen(
+			[LVM_CMD + " 32>%s" % tmp_file],
+			stdin=subprocess.PIPE, stdout=subprocess.PIPE, env=local_env,
+			stderr=subprocess.PIPE, close_fds=True, shell=True)
+
+		try:
+			LVMShellProxy._make_non_block(self.lvm_shell.stdout)
+			LVMShellProxy._make_non_block(self.lvm_shell.stderr)
+
+			# wait for the first prompt
+			errors = self._read_until_prompt(no_output=True)[2]
+			if errors and len(errors):
+				raise RuntimeError(errors)
+		except:
+			raise
+		finally:
+			# These will get deleted when the FD count goes to zero so we
+			# can be sure to clean up correctly no matter how we finish
+			os.unlink(tmp_file)
+			os.rmdir(tmp_dir)
+
+	def get_error_msg(self):
+		# We got an error, lets go fetch the error message
+		self._write_cmd('lastlog\n')
+
+		# read everything from the STDOUT to the next prompt
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
+
+			return error_msg
+
+		return 'No error reason provided! (missing "log" section)'
+
+	def call_lvm(self, argv, debug=False):
+		rc = 1
+		error_msg = ""
+
+		if self.lvm_shell.poll():
+			raise Exception(
+				self.lvm_shell.returncode,
+				"Underlying lvm shell process is not present!")
+
+		argv = add_no_notify(argv)
+
+		# create the command string
+		cmd = " ".join(_quote_arg(arg) for arg in argv)
+		cmd += "\n"
+
+		# run the command by writing it to the shell's STDIN
+		self._write_cmd(cmd)
+
+		# read everything from the STDOUT to the next prompt
+		stdout, report_json, stderr = self._read_until_prompt()
+
+		# Parse the report to see what happened
+		if 'log' in report_json:
+			if report_json['log'][-1:][0]['log_ret_code'] == '1':
+				rc = 0
+			else:
+				error_msg = self.get_error_msg()
+
+		if debug or rc != 0:
+			log_error(('CMD: %s' % cmd))
+			log_error(("EC = %d" % rc))
+			log_error(("ERROR_MSG=\n %s\n" % error_msg))
+
+		return rc, report_json, error_msg
+
+	def exit_shell(self):
+		try:
+			self._write_cmd('exit\n')
+		except Exception as e:
+			log_error(str(e))
+
+	def __del__(self):
+		try:
+			self.lvm_shell.terminate()
+		except:
+			pass
+
+
+if __name__ == "__main__":
+	shell = LVMShellProxy()
+	in_line = "start"
+	try:
+		while in_line:
+			in_line = input("lvm> ")
+			if in_line:
+				start = time.time()
+				ret, out, err = shell.call_lvm(in_line.split())
+				end = time.time()
+
+				print(("RC: %d" % ret))
+				print(("OUT:\n%s" % out))
+				print(("ERR:\n%s" % err))
+
+				print("Command     = %f seconds" % (end - start))
+	except KeyboardInterrupt:
+		pass
+	except EOFError:
+		pass
+	except Exception:
+		traceback.print_exc(file=sys.stdout)
diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
deleted file mode 100755
index 974e7d7..0000000
--- a/daemons/lvmdbusd/lvmdb.py
+++ /dev/null
@@ -1,540 +0,0 @@
-#!/usr/bin/env python3
-
-# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program. If not, see <http://www.gnu.org/licenses/>.
-
-from collections import OrderedDict
-
-import pprint as prettyprint
-import os
-import sys
-
-from lvmdbusd import cmdhandler
-from lvmdbusd.utils import log_debug, log_error
-
-
-class DataStore(object):
-	def __init__(self, usejson=True):
-		self.pvs = {}
-		self.vgs = {}
-		self.lvs = {}
-		self.pv_lvs = {}
-		self.lv_pvs = {}
-		self.lvs_hidden = {}
-
-		self.pv_path_to_uuid = {}
-		self.vg_name_to_uuid = {}
-		self.lv_full_name_to_uuid = {}
-
-		self.lvs_in_vgs = {}
-		self.pvs_in_vgs = {}
-
-		# self.refresh()
-		self.num_refreshes = 0
-
-		if usejson:
-			self.json = cmdhandler.supports_json()
-		else:
-			self.json = usejson
-
-	@staticmethod
-	def _insert_record(table, key, record, allowed_multiple):
-		if key in table:
-			existing = table[key]
-
-			for rec_k, rec_v in record.items():
-				if rec_k in allowed_multiple:
-					# This column name allows us to store multiple value for
-					# each type
-					if not isinstance(existing[rec_k], list):
-						existing_value = existing[rec_k]
-						existing[rec_k] = [existing_value, rec_v]
-					else:
-						existing[rec_k].append(rec_v)
-				else:
-					# If something is not expected to have changing values
-					# lets ensure that
-					if existing[rec_k] != rec_v:
-						raise RuntimeError(
-							"existing[%s]=%s != %s" %
-							(rec_k, str(existing[rec_k]),
-							str(rec_v)))
-		else:
-			table[key] = record
-
-	@staticmethod
-	def _pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup):
-		for p in c_pvs.values():
-			# Capture which PVs are associated with which VG
-			if p['vg_uuid'] not in c_pvs_in_vgs:
-				c_pvs_in_vgs[p['vg_uuid']] = []
-
-			if p['vg_name']:
-				c_pvs_in_vgs[p['vg_uuid']].append(
-					(p['pv_name'], p['pv_uuid']))
-
-			# Lookup for translating between /dev/<name> and pv uuid
-			c_lookup[p['pv_name']] = p['pv_uuid']
-
-	@staticmethod
-	def _parse_pvs(_pvs):
-		pvs = sorted(_pvs, key=lambda pk: pk['pv_name'])
-
-		c_pvs = OrderedDict()
-		c_lookup = {}
-		c_pvs_in_vgs = {}
-
-		for p in pvs:
-			DataStore._insert_record(
-				c_pvs, p['pv_uuid'], p,
-				['pvseg_start', 'pvseg_size', 'segtype'])
-
-		DataStore._pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup)
-		return c_pvs, c_lookup, c_pvs_in_vgs
-
-	@staticmethod
-	def _parse_pvs_json(_all):
-
-		c_pvs = OrderedDict()
-		c_lookup = {}
-		c_pvs_in_vgs = {}
-
-		# Each item item in the report is a collection of information pertaining
-		# to the vg
-		for r in _all['report']:
-			tmp_pv = []
-
-			# Get the pv data for this VG.
-			if 'pv' in r:
-				tmp_pv.extend(r['pv'])
-
-				# Sort them
-				sorted_tmp_pv = sorted(tmp_pv, key=lambda pk: pk['pv_name'])
-
-				# Add them to result set
-				for p in sorted_tmp_pv:
-					c_pvs[p['pv_uuid']] = p
-
-				if 'pvseg' in r:
-					for s in r['pvseg']:
-						r = c_pvs[s['pv_uuid']]
-						r.setdefault('pvseg_start', []).append(s['pvseg_start'])
-						r.setdefault('pvseg_size', []).append(s['pvseg_size'])
-						r.setdefault('segtype', []).append(s['segtype'])
-
-				# TODO: Remove this bug work around when we have orphan segs.
-				for i in c_pvs.values():
-					if 'pvseg_start' not in i:
-						i['pvseg_start'] = '0'
-						i['pvseg_size'] = i['pv_pe_count']
-						i['segtype'] = 'free'
-
-		DataStore._pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup)
-
-		return c_pvs, c_lookup, c_pvs_in_vgs
-
-	@staticmethod
-	def _parse_vgs(_vgs):
-		vgs = sorted(_vgs, key=lambda vk: vk['vg_name'])
-
-		c_vgs = OrderedDict()
-		c_lookup = {}
-
-		for i in vgs:
-			c_lookup[i['vg_name']] = i['vg_uuid']
-			DataStore._insert_record(c_vgs, i['vg_uuid'], i, [])
-
-		return c_vgs, c_lookup
-
-	@staticmethod
-	def _parse_vgs_json(_all):
-
-		tmp_vg = []
-		for r in _all['report']:
-			# Get the pv data for this VG.
-			if 'vg' in r:
-				tmp_vg.extend(r['vg'])
-
-		# Sort for consistent output, however this is optional
-		vgs = sorted(tmp_vg, key=lambda vk: vk['vg_name'])
-
-		c_vgs = OrderedDict()
-		c_lookup = {}
-
-		for i in vgs:
-			c_lookup[i['vg_name']] = i['vg_uuid']
-			c_vgs[i['vg_uuid']] = i
-
-		return c_vgs, c_lookup
-
-	@staticmethod
-	def _parse_lvs_common(c_lvs, c_lv_full_lookup):
-
-		c_lvs_in_vgs = OrderedDict()
-		c_lvs_hidden = OrderedDict()
-
-		for i in c_lvs.values():
-			if i['vg_uuid'] not in c_lvs_in_vgs:
-				c_lvs_in_vgs[i['vg_uuid']] = []
-
-			c_lvs_in_vgs[
-				i['vg_uuid']].append(
-					(i['lv_name'],
-					(i['lv_attr'], i['lv_layout'], i['lv_role']),
-					i['lv_uuid']))
-
-			if i['lv_parent']:
-				# Lookup what the parent refers too
-				parent_name = i['lv_parent']
-				full_parent_name = "%s/%s" % (i['vg_name'], parent_name)
-				if full_parent_name not in c_lv_full_lookup:
-					parent_name = '[%s]' % (parent_name)
-					full_parent_name = "%s/%s" % (i['vg_name'], parent_name)
-
-				parent_uuid = c_lv_full_lookup[full_parent_name]
-
-				if parent_uuid not in c_lvs_hidden:
-					c_lvs_hidden[parent_uuid] = []
-
-				c_lvs_hidden[parent_uuid].append(
-					(i['lv_uuid'], i['lv_name']))
-
-		return c_lvs, c_lvs_in_vgs, c_lvs_hidden, c_lv_full_lookup
-
-	@staticmethod
-	def _parse_lvs(_lvs):
-		lvs = sorted(_lvs, key=lambda vk: vk['lv_name'])
-
-		c_lvs = OrderedDict()
-		c_lv_full_lookup = OrderedDict()
-
-		for i in lvs:
-			full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
-			c_lv_full_lookup[full_name] = i['lv_uuid']
-			DataStore._insert_record(
-				c_lvs, i['lv_uuid'], i,
-				['seg_pe_ranges', 'segtype'])
-
-		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
-
-	@staticmethod
-	def _parse_lvs_json(_all):
-
-		c_lvs = OrderedDict()
-		c_lv_full_lookup = {}
-
-		# Each item item in the report is a collection of information pertaining
-		# to the vg
-		for r in _all['report']:
-			# Get the lv data for this VG.
-			if 'lv' in r:
-				# Add them to result set
-				for i in r['lv']:
-					full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
-					c_lv_full_lookup[full_name] = i['lv_uuid']
-					c_lvs[i['lv_uuid']] = i
-
-				# Add in the segment data
-				if 'seg' in r:
-					for s in r['seg']:
-						r = c_lvs[s['lv_uuid']]
-						r.setdefault('seg_pe_ranges', []).append(s['seg_pe_ranges'])
-						r.setdefault('segtype', []).append(s['segtype'])
-
-		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
-
-	@staticmethod
-	def _make_list(l):
-		if not isinstance(l, list):
-			l = [l]
-		return l
-
-	@staticmethod
-	def _parse_seg_entry(se, segtype):
-		if se:
-			# print("_parse_seg_entry %s %s" % (str(se), str(segtype)))
-			device, segs = se.split(":")
-			start, end = segs.split('-')
-			return (device, (start, end), segtype)
-		else:
-			return ("", (), segtype)
-
-	@staticmethod
-	def _build_segments(l, seg_types):
-		rc = []
-		l = DataStore._make_list(l)
-		s = DataStore._make_list(seg_types)
-
-		assert len(l) == len(s)
-		ls = list(zip(l, s))
-
-		for i in ls:
-			if ' ' in i[0]:
-				tmp = i[0].split(' ')
-				for t in tmp:
-					rc.append(DataStore._parse_seg_entry(t, i[1]))
-			else:
-				rc.append(DataStore._parse_seg_entry(*i))
-		return rc
-
-	@staticmethod
-	def _pv_device_lv_entry(table, pv_device, lv_uuid, meta, lv_attr,
-							segment_info):
-
-		if pv_device not in table:
-			table[pv_device] = {}
-
-		if lv_uuid not in table[pv_device]:
-			table[pv_device][lv_uuid] = {}
-			table[pv_device][lv_uuid]['segs'] = [segment_info]
-			table[pv_device][lv_uuid]['name'] = meta
-			table[pv_device][lv_uuid]['meta'] = lv_attr
-		else:
-			table[pv_device][lv_uuid]['segs'].append(segment_info)
-
-	@staticmethod
-	def _pv_device_lv_format(pv_device_lvs):
-		rc = {}
-
-		for pv_device, pd in pv_device_lvs.items():
-			lvs = []
-			for lv_uuid, ld in sorted(pd.items()):
-				lvs.append((lv_uuid, ld['name'], ld['meta'], ld['segs']))
-
-			rc[pv_device] = lvs
-		return rc
-
-	@staticmethod
-	def _lvs_device_pv_entry(table, lv_uuid, pv_device, pv_uuid, segment_info):
-		if lv_uuid not in table:
-			table[lv_uuid] = {}
-
-		if pv_device not in table[lv_uuid]:
-			table[lv_uuid][pv_device] = {}
-			table[lv_uuid][pv_device]['segs'] = [segment_info]
-			table[lv_uuid][pv_device]['pv_uuid'] = pv_uuid
-		else:
-			table[lv_uuid][pv_device]['segs'].append(segment_info)
-
-	@staticmethod
-	def _lvs_device_pv_format(lvs_device_pvs):
-		rc = {}
-
-		for lv_uuid, ld in lvs_device_pvs.items():
-			pvs = []
-			for pv_device, pd in sorted(ld.items()):
-				pvs.append((pd['pv_uuid'], pv_device, pd['segs']))
-
-			rc[lv_uuid] = pvs
-		return rc
-
-	def _parse_pv_in_lvs(self):
-		pv_device_lvs = {}  # What LVs are stored on a PV
-		lvs_device_pv = {}  # Where LV data is stored
-
-		for i in self.lvs.values():
-			segs = self._build_segments(i['seg_pe_ranges'], i['segtype'])
-			for s in segs:
-				# We are referring to physical device
-				if '/dev/' in s[0]:
-					device, r, seg_type = s
-
-					DataStore._pv_device_lv_entry(
-						pv_device_lvs, device, i['lv_uuid'], i['lv_name'],
-						(i['lv_attr'], i['lv_layout'], i['lv_role']),
-						(r[0], r[1], seg_type))
-
-					# (pv_name, pv_segs, pv_uuid)
-					DataStore._lvs_device_pv_entry(
-						lvs_device_pv, i['lv_uuid'], device,
-						self.pv_path_to_uuid[device], (r[0], r[1], seg_type))
-				else:
-					# TODO Handle the case where the segments refer to a LV
-					# and not a PV
-					pass
-					# print("Handle this %s %s %s" % (s[0], s[1], s[2]))
-
-		# Convert form to needed result for consumption
-		pv_device_lvs_result = DataStore._pv_device_lv_format(pv_device_lvs)
-		lvs_device_pv_result = DataStore._lvs_device_pv_format(lvs_device_pv)
-
-		return pv_device_lvs_result, lvs_device_pv_result
-
-	def refresh(self, log=True):
-		"""
-		Go out and query lvm for the latest data in as few trips as possible
-		:param log  Add debug log entry/exit messages
-		:return: None
-		"""
-		self.num_refreshes += 1
-		if log:
-			log_debug("lvmdb - refresh entry")
-
-		# Grab everything first then parse it
-		if self.json:
-			# Do a single lvm retrieve for everything in json
-			a = cmdhandler.lvm_full_report_json()
-
-			_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs_json(a)
-			_vgs, _vgs_lookup = self._parse_vgs_json(a)
-			_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs_json(a)
-
-		else:
-			_raw_pvs = cmdhandler.pv_retrieve_with_segs()
-			_raw_vgs = cmdhandler.vg_retrieve(None)
-			_raw_lvs = cmdhandler.lv_retrieve_with_segments()
-
-			_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs(_raw_pvs)
-			_vgs, _vgs_lookup = self._parse_vgs(_raw_vgs)
-			_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs(_raw_lvs)
-
-		# Set all
-		self.pvs = _pvs
-		self.pv_path_to_uuid = _pvs_lookup
-		self.vg_name_to_uuid = _vgs_lookup
-		self.lv_full_name_to_uuid = _lvs_lookup
-
-		self.vgs = _vgs
-		self.lvs = _lvs
-		self.lvs_in_vgs = _lvs_in_vgs
-		self.pvs_in_vgs = _pvs_in_vgs
-		self.lvs_hidden = _lvs_hidden
-
-		# Create lookup table for which LV and segments are on each PV
-		self.pv_lvs, self.lv_pvs = self._parse_pv_in_lvs()
-
-		if log:
-			log_debug("lvmdb - refresh exit")
-
-	def fetch_pvs(self, pv_name):
-		if not pv_name:
-			return self.pvs.values()
-		else:
-			rc = []
-			for s in pv_name:
-				# Ths user could be using a symlink instead of the actual
-				# block device, make sure we are using actual block device file
-				# if the pv name isn't in the lookup
-				if s not in self.pv_path_to_uuid:
-					s = os.path.realpath(s)
-				rc.append(self.pvs[self.pv_path_to_uuid[s]])
-			return rc
-
-	def pv_missing(self, pv_uuid):
-		if pv_uuid in self.pvs:
-			if self.pvs[pv_uuid]['pv_missing'] == '':
-				return False
-		return True
-
-	def fetch_vgs(self, vg_name):
-		if not vg_name:
-			return self.vgs.values()
-		else:
-			rc = []
-			for s in vg_name:
-				rc.append(self.vgs[self.vg_name_to_uuid[s]])
-			return rc
-
-	def fetch_lvs(self, lv_names):
-		try:
-			if not lv_names:
-				return self.lvs.values()
-			else:
-				rc = []
-				for s in lv_names:
-					rc.append(self.lvs[self.lv_full_name_to_uuid[s]])
-				return rc
-		except KeyError as ke:
-			log_error("Key %s not found!" % (str(lv_names)))
-			log_error("lv name to uuid lookup")
-			for keys in sorted(self.lv_full_name_to_uuid.keys()):
-				log_error("%s" % (keys))
-			log_error("lvs entries by uuid")
-			for keys in sorted(self.lvs.keys()):
-				log_error("%s" % (keys))
-			raise ke
-
-	def pv_pe_segments(self, pv_uuid):
-		pv = self.pvs[pv_uuid]
-		return list(zip(pv['pvseg_start'], pv['pvseg_size']))
-
-	def pv_contained_lv(self, pv_device):
-		rc = []
-		if pv_device in self.pv_lvs:
-			rc = self.pv_lvs[pv_device]
-		return rc
-
-	def lv_contained_pv(self, lv_uuid):
-		rc = []
-		if lv_uuid in self.lv_pvs:
-			rc = self.lv_pvs[lv_uuid]
-		return rc
-
-	def lvs_in_vg(self, vg_uuid):
-		# Return an array of
-		# (lv_name, (lv_attr, lv_layout, lv_role), lv_uuid)
-		rc = []
-		if vg_uuid in self.lvs_in_vgs:
-			rc = self.lvs_in_vgs[vg_uuid]
-		return rc
-
-	def pvs_in_vg(self, vg_uuid):
-		# Returns an array of (pv_name, pv_uuid)
-		rc = []
-		if vg_uuid in self.pvs_in_vgs:
-			rc = self.pvs_in_vgs[vg_uuid]
-		return rc
-
-	def hidden_lvs(self, lv_uuid):
-		# For a specified LV, return a list of hidden lv_uuid, lv_name
-		# for it
-		rc = []
-		if lv_uuid in self.lvs_hidden:
-			rc = self.lvs_hidden[lv_uuid]
-		return rc
-
-
-if __name__ == "__main__":
-	pp = prettyprint.PrettyPrinter(indent=4)
-
-	use_json = False
-
-	if len(sys.argv) != 1:
-		print(len(sys.argv))
-		use_json = True
-
-	ds = DataStore(use_json)
-	ds.refresh()
-
-	print("PVS")
-	for v in ds.pvs.values():
-		pp.pprint(v)
-		print('PV missing is %s' % ds.pv_missing(v['pv_uuid']))
-
-	print("VGS")
-	for v in ds.vgs.values():
-		pp.pprint(v)
-
-	print("LVS")
-	for v in ds.lvs.values():
-		pp.pprint(v)
-
-	print("LVS in VG")
-	for k, v in ds.lvs_in_vgs.items():
-		print("VG uuid = %s" % (k))
-		pp.pprint(v)
-
-	print("pv_in_lvs")
-	for k, v in ds.pv_lvs.items():
-		print("PV %s contains LVS:" % (k))
-		pp.pprint(v)
-
-	for k, v in ds.lv_pvs.items():
-		print("LV device = %s" % (k))
-		pp.pprint(v)
diff --git a/daemons/lvmdbusd/lvmdb.py.in b/daemons/lvmdbusd/lvmdb.py.in
new file mode 100644
index 0000000..13ee391
--- /dev/null
+++ b/daemons/lvmdbusd/lvmdb.py.in
@@ -0,0 +1,540 @@
+#!@PYTHON3@
+
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from collections import OrderedDict
+
+import pprint as prettyprint
+import os
+import sys
+
+from lvmdbusd import cmdhandler
+from lvmdbusd.utils import log_debug, log_error
+
+
+class DataStore(object):
+	def __init__(self, usejson=True):
+		self.pvs = {}
+		self.vgs = {}
+		self.lvs = {}
+		self.pv_lvs = {}
+		self.lv_pvs = {}
+		self.lvs_hidden = {}
+
+		self.pv_path_to_uuid = {}
+		self.vg_name_to_uuid = {}
+		self.lv_full_name_to_uuid = {}
+
+		self.lvs_in_vgs = {}
+		self.pvs_in_vgs = {}
+
+		# self.refresh()
+		self.num_refreshes = 0
+
+		if usejson:
+			self.json = cmdhandler.supports_json()
+		else:
+			self.json = usejson
+
+	@staticmethod
+	def _insert_record(table, key, record, allowed_multiple):
+		if key in table:
+			existing = table[key]
+
+			for rec_k, rec_v in record.items():
+				if rec_k in allowed_multiple:
+					# This column name allows us to store multiple value for
+					# each type
+					if not isinstance(existing[rec_k], list):
+						existing_value = existing[rec_k]
+						existing[rec_k] = [existing_value, rec_v]
+					else:
+						existing[rec_k].append(rec_v)
+				else:
+					# If something is not expected to have changing values
+					# lets ensure that
+					if existing[rec_k] != rec_v:
+						raise RuntimeError(
+							"existing[%s]=%s != %s" %
+							(rec_k, str(existing[rec_k]),
+							str(rec_v)))
+		else:
+			table[key] = record
+
+	@staticmethod
+	def _pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup):
+		for p in c_pvs.values():
+			# Capture which PVs are associated with which VG
+			if p['vg_uuid'] not in c_pvs_in_vgs:
+				c_pvs_in_vgs[p['vg_uuid']] = []
+
+			if p['vg_name']:
+				c_pvs_in_vgs[p['vg_uuid']].append(
+					(p['pv_name'], p['pv_uuid']))
+
+			# Lookup for translating between /dev/<name> and pv uuid
+			c_lookup[p['pv_name']] = p['pv_uuid']
+
+	@staticmethod
+	def _parse_pvs(_pvs):
+		pvs = sorted(_pvs, key=lambda pk: pk['pv_name'])
+
+		c_pvs = OrderedDict()
+		c_lookup = {}
+		c_pvs_in_vgs = {}
+
+		for p in pvs:
+			DataStore._insert_record(
+				c_pvs, p['pv_uuid'], p,
+				['pvseg_start', 'pvseg_size', 'segtype'])
+
+		DataStore._pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup)
+		return c_pvs, c_lookup, c_pvs_in_vgs
+
+	@staticmethod
+	def _parse_pvs_json(_all):
+
+		c_pvs = OrderedDict()
+		c_lookup = {}
+		c_pvs_in_vgs = {}
+
+		# Each item item in the report is a collection of information pertaining
+		# to the vg
+		for r in _all['report']:
+			tmp_pv = []
+
+			# Get the pv data for this VG.
+			if 'pv' in r:
+				tmp_pv.extend(r['pv'])
+
+				# Sort them
+				sorted_tmp_pv = sorted(tmp_pv, key=lambda pk: pk['pv_name'])
+
+				# Add them to result set
+				for p in sorted_tmp_pv:
+					c_pvs[p['pv_uuid']] = p
+
+				if 'pvseg' in r:
+					for s in r['pvseg']:
+						r = c_pvs[s['pv_uuid']]
+						r.setdefault('pvseg_start', []).append(s['pvseg_start'])
+						r.setdefault('pvseg_size', []).append(s['pvseg_size'])
+						r.setdefault('segtype', []).append(s['segtype'])
+
+				# TODO: Remove this bug work around when we have orphan segs.
+				for i in c_pvs.values():
+					if 'pvseg_start' not in i:
+						i['pvseg_start'] = '0'
+						i['pvseg_size'] = i['pv_pe_count']
+						i['segtype'] = 'free'
+
+		DataStore._pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup)
+
+		return c_pvs, c_lookup, c_pvs_in_vgs
+
+	@staticmethod
+	def _parse_vgs(_vgs):
+		vgs = sorted(_vgs, key=lambda vk: vk['vg_name'])
+
+		c_vgs = OrderedDict()
+		c_lookup = {}
+
+		for i in vgs:
+			c_lookup[i['vg_name']] = i['vg_uuid']
+			DataStore._insert_record(c_vgs, i['vg_uuid'], i, [])
+
+		return c_vgs, c_lookup
+
+	@staticmethod
+	def _parse_vgs_json(_all):
+
+		tmp_vg = []
+		for r in _all['report']:
+			# Get the pv data for this VG.
+			if 'vg' in r:
+				tmp_vg.extend(r['vg'])
+
+		# Sort for consistent output, however this is optional
+		vgs = sorted(tmp_vg, key=lambda vk: vk['vg_name'])
+
+		c_vgs = OrderedDict()
+		c_lookup = {}
+
+		for i in vgs:
+			c_lookup[i['vg_name']] = i['vg_uuid']
+			c_vgs[i['vg_uuid']] = i
+
+		return c_vgs, c_lookup
+
+	@staticmethod
+	def _parse_lvs_common(c_lvs, c_lv_full_lookup):
+
+		c_lvs_in_vgs = OrderedDict()
+		c_lvs_hidden = OrderedDict()
+
+		for i in c_lvs.values():
+			if i['vg_uuid'] not in c_lvs_in_vgs:
+				c_lvs_in_vgs[i['vg_uuid']] = []
+
+			c_lvs_in_vgs[
+				i['vg_uuid']].append(
+					(i['lv_name'],
+					(i['lv_attr'], i['lv_layout'], i['lv_role']),
+					i['lv_uuid']))
+
+			if i['lv_parent']:
+				# Lookup what the parent refers too
+				parent_name = i['lv_parent']
+				full_parent_name = "%s/%s" % (i['vg_name'], parent_name)
+				if full_parent_name not in c_lv_full_lookup:
+					parent_name = '[%s]' % (parent_name)
+					full_parent_name = "%s/%s" % (i['vg_name'], parent_name)
+
+				parent_uuid = c_lv_full_lookup[full_parent_name]
+
+				if parent_uuid not in c_lvs_hidden:
+					c_lvs_hidden[parent_uuid] = []
+
+				c_lvs_hidden[parent_uuid].append(
+					(i['lv_uuid'], i['lv_name']))
+
+		return c_lvs, c_lvs_in_vgs, c_lvs_hidden, c_lv_full_lookup
+
+	@staticmethod
+	def _parse_lvs(_lvs):
+		lvs = sorted(_lvs, key=lambda vk: vk['lv_name'])
+
+		c_lvs = OrderedDict()
+		c_lv_full_lookup = OrderedDict()
+
+		for i in lvs:
+			full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
+			c_lv_full_lookup[full_name] = i['lv_uuid']
+			DataStore._insert_record(
+				c_lvs, i['lv_uuid'], i,
+				['seg_pe_ranges', 'segtype'])
+
+		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
+
+	@staticmethod
+	def _parse_lvs_json(_all):
+
+		c_lvs = OrderedDict()
+		c_lv_full_lookup = {}
+
+		# Each item item in the report is a collection of information pertaining
+		# to the vg
+		for r in _all['report']:
+			# Get the lv data for this VG.
+			if 'lv' in r:
+				# Add them to result set
+				for i in r['lv']:
+					full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
+					c_lv_full_lookup[full_name] = i['lv_uuid']
+					c_lvs[i['lv_uuid']] = i
+
+				# Add in the segment data
+				if 'seg' in r:
+					for s in r['seg']:
+						r = c_lvs[s['lv_uuid']]
+						r.setdefault('seg_pe_ranges', []).append(s['seg_pe_ranges'])
+						r.setdefault('segtype', []).append(s['segtype'])
+
+		return DataStore._parse_lvs_common(c_lvs, c_lv_full_lookup)
+
+	@staticmethod
+	def _make_list(l):
+		if not isinstance(l, list):
+			l = [l]
+		return l
+
+	@staticmethod
+	def _parse_seg_entry(se, segtype):
+		if se:
+			# print("_parse_seg_entry %s %s" % (str(se), str(segtype)))
+			device, segs = se.split(":")
+			start, end = segs.split('-')
+			return (device, (start, end), segtype)
+		else:
+			return ("", (), segtype)
+
+	@staticmethod
+	def _build_segments(l, seg_types):
+		rc = []
+		l = DataStore._make_list(l)
+		s = DataStore._make_list(seg_types)
+
+		assert len(l) == len(s)
+		ls = list(zip(l, s))
+
+		for i in ls:
+			if ' ' in i[0]:
+				tmp = i[0].split(' ')
+				for t in tmp:
+					rc.append(DataStore._parse_seg_entry(t, i[1]))
+			else:
+				rc.append(DataStore._parse_seg_entry(*i))
+		return rc
+
+	@staticmethod
+	def _pv_device_lv_entry(table, pv_device, lv_uuid, meta, lv_attr,
+							segment_info):
+
+		if pv_device not in table:
+			table[pv_device] = {}
+
+		if lv_uuid not in table[pv_device]:
+			table[pv_device][lv_uuid] = {}
+			table[pv_device][lv_uuid]['segs'] = [segment_info]
+			table[pv_device][lv_uuid]['name'] = meta
+			table[pv_device][lv_uuid]['meta'] = lv_attr
+		else:
+			table[pv_device][lv_uuid]['segs'].append(segment_info)
+
+	@staticmethod
+	def _pv_device_lv_format(pv_device_lvs):
+		rc = {}
+
+		for pv_device, pd in pv_device_lvs.items():
+			lvs = []
+			for lv_uuid, ld in sorted(pd.items()):
+				lvs.append((lv_uuid, ld['name'], ld['meta'], ld['segs']))
+
+			rc[pv_device] = lvs
+		return rc
+
+	@staticmethod
+	def _lvs_device_pv_entry(table, lv_uuid, pv_device, pv_uuid, segment_info):
+		if lv_uuid not in table:
+			table[lv_uuid] = {}
+
+		if pv_device not in table[lv_uuid]:
+			table[lv_uuid][pv_device] = {}
+			table[lv_uuid][pv_device]['segs'] = [segment_info]
+			table[lv_uuid][pv_device]['pv_uuid'] = pv_uuid
+		else:
+			table[lv_uuid][pv_device]['segs'].append(segment_info)
+
+	@staticmethod
+	def _lvs_device_pv_format(lvs_device_pvs):
+		rc = {}
+
+		for lv_uuid, ld in lvs_device_pvs.items():
+			pvs = []
+			for pv_device, pd in sorted(ld.items()):
+				pvs.append((pd['pv_uuid'], pv_device, pd['segs']))
+
+			rc[lv_uuid] = pvs
+		return rc
+
+	def _parse_pv_in_lvs(self):
+		pv_device_lvs = {}  # What LVs are stored on a PV
+		lvs_device_pv = {}  # Where LV data is stored
+
+		for i in self.lvs.values():
+			segs = self._build_segments(i['seg_pe_ranges'], i['segtype'])
+			for s in segs:
+				# We are referring to physical device
+				if '/dev/' in s[0]:
+					device, r, seg_type = s
+
+					DataStore._pv_device_lv_entry(
+						pv_device_lvs, device, i['lv_uuid'], i['lv_name'],
+						(i['lv_attr'], i['lv_layout'], i['lv_role']),
+						(r[0], r[1], seg_type))
+
+					# (pv_name, pv_segs, pv_uuid)
+					DataStore._lvs_device_pv_entry(
+						lvs_device_pv, i['lv_uuid'], device,
+						self.pv_path_to_uuid[device], (r[0], r[1], seg_type))
+				else:
+					# TODO Handle the case where the segments refer to a LV
+					# and not a PV
+					pass
+					# print("Handle this %s %s %s" % (s[0], s[1], s[2]))
+
+		# Convert form to needed result for consumption
+		pv_device_lvs_result = DataStore._pv_device_lv_format(pv_device_lvs)
+		lvs_device_pv_result = DataStore._lvs_device_pv_format(lvs_device_pv)
+
+		return pv_device_lvs_result, lvs_device_pv_result
+
+	def refresh(self, log=True):
+		"""
+		Go out and query lvm for the latest data in as few trips as possible
+		:param log  Add debug log entry/exit messages
+		:return: None
+		"""
+		self.num_refreshes += 1
+		if log:
+			log_debug("lvmdb - refresh entry")
+
+		# Grab everything first then parse it
+		if self.json:
+			# Do a single lvm retrieve for everything in json
+			a = cmdhandler.lvm_full_report_json()
+
+			_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs_json(a)
+			_vgs, _vgs_lookup = self._parse_vgs_json(a)
+			_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs_json(a)
+
+		else:
+			_raw_pvs = cmdhandler.pv_retrieve_with_segs()
+			_raw_vgs = cmdhandler.vg_retrieve(None)
+			_raw_lvs = cmdhandler.lv_retrieve_with_segments()
+
+			_pvs, _pvs_lookup, _pvs_in_vgs = self._parse_pvs(_raw_pvs)
+			_vgs, _vgs_lookup = self._parse_vgs(_raw_vgs)
+			_lvs, _lvs_in_vgs, _lvs_hidden, _lvs_lookup = self._parse_lvs(_raw_lvs)
+
+		# Set all
+		self.pvs = _pvs
+		self.pv_path_to_uuid = _pvs_lookup
+		self.vg_name_to_uuid = _vgs_lookup
+		self.lv_full_name_to_uuid = _lvs_lookup
+
+		self.vgs = _vgs
+		self.lvs = _lvs
+		self.lvs_in_vgs = _lvs_in_vgs
+		self.pvs_in_vgs = _pvs_in_vgs
+		self.lvs_hidden = _lvs_hidden
+
+		# Create lookup table for which LV and segments are on each PV
+		self.pv_lvs, self.lv_pvs = self._parse_pv_in_lvs()
+
+		if log:
+			log_debug("lvmdb - refresh exit")
+
+	def fetch_pvs(self, pv_name):
+		if not pv_name:
+			return self.pvs.values()
+		else:
+			rc = []
+			for s in pv_name:
+				# Ths user could be using a symlink instead of the actual
+				# block device, make sure we are using actual block device file
+				# if the pv name isn't in the lookup
+				if s not in self.pv_path_to_uuid:
+					s = os.path.realpath(s)
+				rc.append(self.pvs[self.pv_path_to_uuid[s]])
+			return rc
+
+	def pv_missing(self, pv_uuid):
+		if pv_uuid in self.pvs:
+			if self.pvs[pv_uuid]['pv_missing'] == '':
+				return False
+		return True
+
+	def fetch_vgs(self, vg_name):
+		if not vg_name:
+			return self.vgs.values()
+		else:
+			rc = []
+			for s in vg_name:
+				rc.append(self.vgs[self.vg_name_to_uuid[s]])
+			return rc
+
+	def fetch_lvs(self, lv_names):
+		try:
+			if not lv_names:
+				return self.lvs.values()
+			else:
+				rc = []
+				for s in lv_names:
+					rc.append(self.lvs[self.lv_full_name_to_uuid[s]])
+				return rc
+		except KeyError as ke:
+			log_error("Key %s not found!" % (str(lv_names)))
+			log_error("lv name to uuid lookup")
+			for keys in sorted(self.lv_full_name_to_uuid.keys()):
+				log_error("%s" % (keys))
+			log_error("lvs entries by uuid")
+			for keys in sorted(self.lvs.keys()):
+				log_error("%s" % (keys))
+			raise ke
+
+	def pv_pe_segments(self, pv_uuid):
+		pv = self.pvs[pv_uuid]
+		return list(zip(pv['pvseg_start'], pv['pvseg_size']))
+
+	def pv_contained_lv(self, pv_device):
+		rc = []
+		if pv_device in self.pv_lvs:
+			rc = self.pv_lvs[pv_device]
+		return rc
+
+	def lv_contained_pv(self, lv_uuid):
+		rc = []
+		if lv_uuid in self.lv_pvs:
+			rc = self.lv_pvs[lv_uuid]
+		return rc
+
+	def lvs_in_vg(self, vg_uuid):
+		# Return an array of
+		# (lv_name, (lv_attr, lv_layout, lv_role), lv_uuid)
+		rc = []
+		if vg_uuid in self.lvs_in_vgs:
+			rc = self.lvs_in_vgs[vg_uuid]
+		return rc
+
+	def pvs_in_vg(self, vg_uuid):
+		# Returns an array of (pv_name, pv_uuid)
+		rc = []
+		if vg_uuid in self.pvs_in_vgs:
+			rc = self.pvs_in_vgs[vg_uuid]
+		return rc
+
+	def hidden_lvs(self, lv_uuid):
+		# For a specified LV, return a list of hidden lv_uuid, lv_name
+		# for it
+		rc = []
+		if lv_uuid in self.lvs_hidden:
+			rc = self.lvs_hidden[lv_uuid]
+		return rc
+
+
+if __name__ == "__main__":
+	pp = prettyprint.PrettyPrinter(indent=4)
+
+	use_json = False
+
+	if len(sys.argv) != 1:
+		print(len(sys.argv))
+		use_json = True
+
+	ds = DataStore(use_json)
+	ds.refresh()
+
+	print("PVS")
+	for v in ds.pvs.values():
+		pp.pprint(v)
+		print('PV missing is %s' % ds.pv_missing(v['pv_uuid']))
+
+	print("VGS")
+	for v in ds.vgs.values():
+		pp.pprint(v)
+
+	print("LVS")
+	for v in ds.lvs.values():
+		pp.pprint(v)
+
+	print("LVS in VG")
+	for k, v in ds.lvs_in_vgs.items():
+		print("VG uuid = %s" % (k))
+		pp.pprint(v)
+
+	print("pv_in_lvs")
+	for k, v in ds.pv_lvs.items():
+		print("PV %s contains LVS:" % (k))
+		pp.pprint(v)
+
+	for k, v in ds.lv_pvs.items():
+		print("LV device = %s" % (k))
+		pp.pprint(v)
diff --git a/daemons/lvmdbusd/lvmdbusd.in b/daemons/lvmdbusd/lvmdbusd.in
old mode 100755
new mode 100644


