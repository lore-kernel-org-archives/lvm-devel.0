From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 10 Oct 2016 21:35:12 +0000 (UTC)
Subject: master - lvmdbusd: Ensure lvm shell still exists
Message-ID: <20161010213512.5ED6F60640@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e941beb446e71a9278e38eb4d69e19dc4b284f8
Commit:        2e941beb446e71a9278e38eb4d69e19dc4b284f8
Parent:        088b3d036a73a7d947f6e9b12e8fad8a9f40d97f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Oct 7 13:45:30 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Oct 10 16:31:00 2016 -0500

lvmdbusd: Ensure lvm shell still exists

---
 daemons/lvmdbusd/lvm_shell_proxy.py |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 12e7e36..e615488 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -75,6 +75,8 @@ class LVMShellProxy(object):
 								report += tmp.decode("utf-8")
 								if len(tmp) != 16384:
 									break
+							else:
+								break
 
 					elif r == self.lvm_shell.stderr.fileno():
 						while True:
@@ -84,6 +86,10 @@ class LVMShellProxy(object):
 							else:
 								break
 
+				# Check to see if the lvm process died on us
+				if self.lvm_shell.poll():
+					raise Exception(self.lvm_shell.returncode, "%s" % stderr)
+
 			except IOError as ioe:
 				log_debug(str(ioe))
 				pass
@@ -171,6 +177,11 @@ class LVMShellProxy(object):
 		error_msg = ""
 		json_result = ""
 
+		if self.lvm_shell.poll():
+			raise Exception(
+				self.lvm_shell.returncode,
+				"Underlying lvm shell process is not present!")
+
 		# create the command string
 		cmd = " ".join(_quote_arg(arg) for arg in argv)
 		cmd += "\n"
@@ -222,7 +233,7 @@ if __name__ == "__main__":
 				end = time.time()
 
 				print(("RC: %d" % ret))
-				# print(("OUT:\n%s" % out))
+				print(("OUT:\n%s" % out))
 				print(("ERR:\n%s" % err))
 
 				print("Command     = %f seconds" % (end - start))


