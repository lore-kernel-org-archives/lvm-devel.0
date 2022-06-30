From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:43 +0000 (GMT)
Subject: main - lvmdbusd: Remove the use of sub shell for lvm shell
Message-ID: <20220630160043.BB650386F0CF@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a2090655d3ab5abde83b981594ed527e2a7f1f7
Commit:        7a2090655d3ab5abde83b981594ed527e2a7f1f7
Parent:        b3d7aff6a3a8fd55790f61b9b0b33d599841030b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu May 26 10:44:02 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Remove the use of sub shell for lvm shell

This reduces the number of processes and improves security.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 40639442c..1a5051a92 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -129,31 +129,29 @@ class LVMShellProxy(object):
 		except FileExistsError:
 			pass
 
-		# We have to open non-blocking as the other side isn't open until
-		# we actually fork the process.
+		# Open the fifo for use to read and for lvm child process to write to.
 		self.report_fd = os.open(tmp_file, os.O_NONBLOCK)
 		self.report_stream = os.fdopen(self.report_fd, 'rb', 0)
+		lvm_fd = os.open(tmp_file, os.O_WRONLY)
 
-		# Setup the environment for using our own socket for reporting
-		local_env = {}
-		local_env["LC_ALL"] = "C"
-		local_env["LVM_REPORT_FD"] = "32"
-		local_env["LVM_COMMAND_PROFILE"] = "lvmdbusd"
-
-		# Disable the abort logic if lvm logs too much, which easily happens
-		# when utilizing the lvm shell.
-		local_env["LVM_LOG_FILE_MAX_LINES"] = "0"
+		# Set up the environment for using our own socket for reporting and disable the abort
+		# logic if lvm logs too much, which easily happens when utilizing the lvm shell.
+		local_env = {"LC_ALL": "C", "LVM_REPORT_FD": "%s" % lvm_fd, "LVM_COMMAND_PROFILE": "lvmdbusd",
+					 "LVM_LOG_FILE_MAX_LINES": "0"}
 
 		# run the lvm shell
 		self.lvm_shell = subprocess.Popen(
-			[LVM_CMD + " 32>%s" % tmp_file],
+			[LVM_CMD],
 			stdin=subprocess.PIPE, stdout=subprocess.PIPE, env=local_env,
-			stderr=subprocess.PIPE, close_fds=True, shell=True)
+			stderr=subprocess.PIPE, close_fds=True, pass_fds=(lvm_fd,), shell=False)
 
 		try:
 			make_non_block(self.lvm_shell.stdout)
 			make_non_block(self.lvm_shell.stderr)
 
+			# Close our copy of the lvm_fd, child process is open in its process space
+			os.close(lvm_fd)
+
 			# wait for the first prompt
 			errors = self._read_until_prompt(no_output=True)[2]
 			if errors and len(errors):

