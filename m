From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 10 Oct 2016 21:35:14 +0000 (UTC)
Subject: master - lvmdbusd: Ensure tmp dir gets cleaned up
Message-ID: <20161010213514.8149E60640@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f0195ec1ec1113695abdb1ada82dc138bc7488b
Commit:        9f0195ec1ec1113695abdb1ada82dc138bc7488b
Parent:        2e941beb446e71a9278e38eb4d69e19dc4b284f8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Oct 7 13:46:59 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Oct 10 16:31:00 2016 -0500

lvmdbusd: Ensure tmp dir gets cleaned up

Regardless of the outcome of starting up the lvm shell process, lets
ensure we clean up the temp directory and pipe.
---
 daemons/lvmdbusd/lvm_shell_proxy.py |   32 ++++++++++++++++++--------------
 1 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index e615488..6e6d52a 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -129,20 +129,24 @@ class LVMShellProxy(object):
 			[LVM_CMD + " 32>%s" % tmp_file],
 			stdin=subprocess.PIPE, stdout=subprocess.PIPE, env=local_env,
 			stderr=subprocess.PIPE, close_fds=True, shell=True)
-		flags = fcntl(self.lvm_shell.stdout, F_GETFL)
-		fcntl(self.lvm_shell.stdout, F_SETFL, flags | os.O_NONBLOCK)
-		flags = fcntl(self.lvm_shell.stderr, F_GETFL)
-		fcntl(self.lvm_shell.stderr, F_SETFL, flags | os.O_NONBLOCK)
-
-		# wait for the first prompt
-		errors = self._read_until_prompt()[2]
-		if errors and len(errors):
-			raise RuntimeError(errors)
-
-		# These will get deleted when the FD count goes to zero so we can be
-		# sure to clean up correctly no matter how we finish
-		os.unlink(tmp_file)
-		os.rmdir(tmp_dir)
+
+		try:
+			flags = fcntl(self.lvm_shell.stdout, F_GETFL)
+			fcntl(self.lvm_shell.stdout, F_SETFL, flags | os.O_NONBLOCK)
+			flags = fcntl(self.lvm_shell.stderr, F_GETFL)
+			fcntl(self.lvm_shell.stderr, F_SETFL, flags | os.O_NONBLOCK)
+
+			# wait for the first prompt
+			errors = self._read_until_prompt()[2]
+			if errors and len(errors):
+				raise RuntimeError(errors)
+		except:
+			raise
+		finally:
+			# These will get deleted when the FD count goes to zero so we can be
+			# sure to clean up correctly no matter how we finish
+			os.unlink(tmp_file)
+			os.rmdir(tmp_dir)
 
 	def get_error_msg(self):
 		# We got an error, lets go fetch the error message


