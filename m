From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:08 +0000 (GMT)
Subject: main - lvmdbustest: Add DaemonInfo class
Message-ID: <20220919155808.18A6F385841F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de0258a60054166fd3a2b1732d74e7bae85e92f5
Commit:        de0258a60054166fd3a2b1732d74e7bae85e92f5
Parent:        ec50979b031e85ab155126aae51ab15b255f4be9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Aug 23 10:27:30 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Add DaemonInfo class

This class handles identifying daemon, sending signals to it, and starting
it back up again.
---
 test/dbus/lvmdbustest.py | 182 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 176 insertions(+), 6 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index c4e95b7cc..5c352313d 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -9,23 +9,28 @@
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
+import signal
 # noinspection PyUnresolvedReferences
+import subprocess
+import unittest
+from glob import glob
+from subprocess import Popen, PIPE
+
 import dbus
+import pyudev
 # noinspection PyUnresolvedReferences
 from dbus.mainloop.glib import DBusGMainLoop
-import unittest
-import pyudev
-from testlib import *
+
 import testlib
-from subprocess import Popen, PIPE
-from glob import glob
-import os
+from testlib import *
 
 g_tmo = 0
 
 # Approx. min size
 VDO_MIN_SIZE = mib(8192)
 
+EXE_NAME="/lvmdbusd"
+
 # Prefix on created objects to enable easier clean-up
 g_prefix = os.getenv('PREFIX', '')
 
@@ -210,6 +215,171 @@ def supports_vdo():
 	return True
 
 
+def process_exists(name):
+	# Walk the process table looking for executable 'name'
+	for p in [pid for pid in os.listdir('/proc') if pid.isdigit()]:
+		try:
+			cmdline_args = read_file_split_nuls("/proc/%s/cmdline" % p)
+		except OSError:
+			continue
+		for arg in cmdline_args:
+			if name in arg:
+				return int(p)
+	return None
+
+
+def read_file_split_nuls(fn):
+	with open(fn, "rb") as fh:
+		return [p.decode("utf-8") for p in fh.read().split(b'\x00') if len(p) > 0]
+
+
+def read_file_build_hash(fn):
+	rc = dict()
+	lines = read_file_split_nuls(fn)
+	for line in lines:
+		if line.count("=") == 1:
+			k, v = line.split("=")
+			rc[k] = v
+	return rc
+
+
+class DaemonInfo(object):
+	def __init__(self, pid):
+		# The daemon is running, we have a pid, lets see how it's being run.
+		# When running under systemd, fd 0 -> /dev/null, fd 1&2 -> socket
+		# when ran manually it may have output re-directed to a file etc.
+		# we need the following
+		# command line arguments
+		# cwd
+		# where the output is going (in case it's directed to a file)
+		# Which lvm binary is being used (check LVM_BINARY env. variable)
+		# PYTHONPATH
+		base = "/proc/%d" % pid
+		self.cwd = os.readlink("%s/cwd" % base)
+		self.cmdline = read_file_split_nuls("%s/cmdline" % (base))[1:]
+		self.env = read_file_build_hash("%s/environ" % base)
+		self.stdin = os.readlink("%s/fd/0" % base)
+		self.stdout = os.readlink("%s/fd/1" % base)
+		self.stderr = os.readlink("%s/fd/2" % base)
+
+		if self.cwd == "/" and self.stdin == "/dev/null":
+			self.systemd = True
+		else:
+			self.systemd = False
+
+		self.process = None
+
+	@classmethod
+	def get(cls):
+		pid = process_exists(EXE_NAME)
+		if pid:
+			return cls(pid)
+		return None
+
+	def start(self, expect_fail=False):
+		if self.systemd:
+			pass
+		else:
+			stdin_stream = None
+			stdout_stream = None
+			stderr_stream = None
+			try:
+				stdout_stream = open(self.stdout, "ab")
+				stdin_stream = open(self.stdin, "rb")
+				stderr_stream = open(self.stderr, "ab")
+
+				self.process = Popen(self.cmdline, cwd=self.cwd, stdin=stdin_stream,
+									stdout=stdout_stream, stderr=stderr_stream, env=self.env)
+
+				if expect_fail:
+					# Let's wait a bit to see if this process dies as expected and return the exit code
+					try:
+						self.process.wait(10)
+						return self.process.returncode
+					except subprocess.TimeoutExpired as e:
+						# Process did not fail as expected, lets kill it
+						os.kill(self.process.pid, signal.SIGKILL)
+						self.process.wait(20)
+						raise e
+				else:
+					# This is a hack to set the returncode.  When the Popen object goes out of scope during the unit test
+					# the __del__ method gets called.  As we leave the daemon running the process.returncode
+					# hasn't been set, so it incorrectly raises an exception that the process is still running
+					# which in our case is correct and expected.
+					self.process.returncode = 0
+			finally:
+				# Close these in the parent
+				if stdin_stream:
+					stdin_stream.close()
+				if stderr_stream:
+					stderr_stream.close()
+				if stdout_stream:
+					stdout_stream.close()
+
+		# Make sure daemon is responding to dbus events before returning
+		DaemonInfo._ensure_daemon("Daemon is not responding on dbus within 20 seconds of starting!")
+
+		# During local testing it usually takes ~0.25 seconds for daemon to be ready
+		return None
+
+	@staticmethod
+	def _ensure_no_daemon():
+		start = time.time()
+		pid = process_exists(EXE_NAME)
+		while pid is not None and (time.time() - start) <= 20:
+			time.sleep(0.3)
+			pid = process_exists(EXE_NAME)
+
+		if pid:
+			raise Exception(
+				"lsmd daemon did not exit within 20 seconds, pid = %s" % pid)
+
+	@staticmethod
+	def _ensure_daemon(msg):
+		start = time.time()
+		running = False
+		while True and (time.time() - start) < 20:
+			try:
+				get_objects()
+				running = True
+				break
+			except dbus.exceptions.DBusException:
+				time.sleep(0.2)
+				pass
+		if not running:
+			raise RuntimeError(msg)
+
+	def term_signal(self, sig_number):
+		# Used for signals that we expect with terminate the daemon, eg. SIGINT, SIGKILL
+		if self.process:
+			os.kill(self.process.pid, sig_number)
+			# Note: The following should work, but doesn't!
+			# self.process.send_signal(sig_number)
+			try:
+				self.process.wait(10)
+			except subprocess.TimeoutExpired:
+				std_err_print("Daemon hasn't exited within 10 seconds")
+			if self.process.poll() is None:
+				std_err_print("Daemon still running...")
+			else:
+				self.process = None
+		else:
+			pid = process_exists(EXE_NAME)
+			os.kill(pid, sig_number)
+
+		# Make sure there is no daemon present before we return for things to be "good"
+		DaemonInfo._ensure_no_daemon()
+
+	def non_term_signal(self, sig_number):
+		if sig_number not in [signal.SIGUSR1, signal.SIGUSR2]:
+			raise ValueError("Incorrect signal number! %d" % sig_number)
+		if self.process:
+			os.kill(self.process.pid, sig_number)
+		else:
+			pid = process_exists(EXE_NAME)
+			os.kill(pid, sig_number)
+
+
 # noinspection PyUnresolvedReferences
 class TestDbusService(unittest.TestCase):
 	def setUp(self):

