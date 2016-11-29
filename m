From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 29 Nov 2016 22:51:29 +0000 (UTC)
Subject: master - lvmdbusd: Simplfy reading streams
Message-ID: <20161129225129.246D1612EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d882edb32d8695ffb1498759649af93f407f39db
Commit:        d882edb32d8695ffb1498759649af93f407f39db
Parent:        25b5413f895bc61357ef4afab255e3125335d4ec
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 29 12:37:59 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 29 16:50:30 2016 -0600

lvmdbusd: Simplfy reading streams

Remove redundant code and make code paths the same for all streams.
---
 daemons/lvmdbusd/lvm_shell_proxy.py |   52 +++++++++++++++++------------------
 1 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 464da79..ae8049f 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -43,6 +43,13 @@ def _quote_arg(arg):
 
 class LVMShellProxy(object):
 
+	@staticmethod
+	def _read(stream):
+		tmp = stream.read()
+		if tmp:
+			return tmp.decode("utf-8")
+		return ''
+
 	# Read until we get prompt back and a result
 	# @param: no_output	Caller expects no output to report FD
 	# Returns stdout, report, stderr (report is JSON!)
@@ -62,29 +69,17 @@ class LVMShellProxy(object):
 			try:
 				rd_fd = [
 					self.lvm_shell.stdout.fileno(),
-					self.report_r,
+					self.report_stream.fileno(),
 					self.lvm_shell.stderr.fileno()]
 				ready = select.select(rd_fd, [], [], 2)
 
 				for r in ready[0]:
 					if r == self.lvm_shell.stdout.fileno():
-						tmp = self.lvm_shell.stdout.read()
-						if tmp:
-							stdout += tmp.decode("utf-8")
-					elif r == self.report_r:
-						while True:
-							tmp = os.read(self.report_r, 16384)
-							if tmp:
-								report += tmp.decode("utf-8")
-								if len(tmp) != 16384:
-									break
-							else:
-								break
-
+						stdout += LVMShellProxy._read(self.lvm_shell.stdout)
+					elif r == self.report_stream.fileno():
+						report += LVMShellProxy._read(self.report_stream)
 					elif r == self.lvm_shell.stderr.fileno():
-						tmp = self.lvm_shell.stderr.read()
-						if tmp:
-							stderr += tmp.decode("utf-8")
+						stderr += LVMShellProxy._read(self.lvm_shell.stderr)
 
 				# Check to see if the lvm process died on us
 				if self.lvm_shell.poll():
@@ -131,6 +126,11 @@ class LVMShellProxy(object):
 		assert (num_written == len(cmd_bytes))
 		self.lvm_shell.stdin.flush()
 
+	@staticmethod
+	def _make_non_block(stream):
+		flags = fcntl(stream, F_GETFL)
+		fcntl(stream, F_SETFL, flags | os.O_NONBLOCK)
+
 	def __init__(self):
 
 		# Create a temp directory
@@ -143,7 +143,10 @@ class LVMShellProxy(object):
 		except FileExistsError:
 			pass
 
-		self.report_r = os.open(tmp_file, os.O_NONBLOCK)
+		# We have to open non-blocking as the other side isn't open until
+		# we actually fork the process.
+		self.report_fd = os.open(tmp_file, os.O_NONBLOCK)
+		self.report_stream = os.fdopen(self.report_fd, 'rb', 0)
 
 		# Setup the environment for using our own socket for reporting
 		local_env = copy.deepcopy(os.environ)
@@ -154,9 +157,6 @@ class LVMShellProxy(object):
 		# when utilizing the lvm shell.
 		local_env["LVM_LOG_FILE_MAX_LINES"] = "0"
 
-		flags = fcntl(self.report_r, F_GETFL)
-		fcntl(self.report_r, F_SETFL, flags | os.O_NONBLOCK)
-
 		# run the lvm shell
 		self.lvm_shell = subprocess.Popen(
 			[LVM_CMD + " 32>%s" % tmp_file],
@@ -164,10 +164,8 @@ class LVMShellProxy(object):
 			stderr=subprocess.PIPE, close_fds=True, shell=True)
 
 		try:
-			flags = fcntl(self.lvm_shell.stdout, F_GETFL)
-			fcntl(self.lvm_shell.stdout, F_SETFL, flags | os.O_NONBLOCK)
-			flags = fcntl(self.lvm_shell.stderr, F_GETFL)
-			fcntl(self.lvm_shell.stderr, F_SETFL, flags | os.O_NONBLOCK)
+			LVMShellProxy._make_non_block(self.lvm_shell.stdout)
+			LVMShellProxy._make_non_block(self.lvm_shell.stderr)
 
 			# wait for the first prompt
 			errors = self._read_until_prompt(no_output=True)[2]
@@ -176,8 +174,8 @@ class LVMShellProxy(object):
 		except:
 			raise
 		finally:
-			# These will get deleted when the FD count goes to zero so we can be
-			# sure to clean up correctly no matter how we finish
+			# These will get deleted when the FD count goes to zero so we
+			# can be sure to clean up correctly no matter how we finish
 			os.unlink(tmp_file)
 			os.rmdir(tmp_dir)
 


