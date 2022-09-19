From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:44 +0000 (GMT)
Subject: main - lvmdbusd: Call readlines instead of readline
Message-ID: <20220919155844.7ADD0385829E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4b7f988d88afa81fd8f1934482444f97a08d9dd
Commit:        a4b7f988d88afa81fd8f1934482444f97a08d9dd
Parent:        8e1e40c499a0e46a0a15b9a6b470adb8fbbbbf4f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 8 15:42:26 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Call readlines instead of readline

Better to drain everything we have now that our IO is line orientated
when using a ptty.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index ed2c7bc9e..0ba0ffe5c 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -69,11 +69,13 @@ class LVMShellProxy(object):
 
 				for r in ready[0]:
 					if r == self.parent_stdout_fd:
-						stdout += self.parent_stdout.readline()
+						for line in self.parent_stdout.readlines():
+							stdout += line
 					elif r == self.report_stream.fileno():
 						report += read_decoded(self.report_stream)
 					elif r == self.parent_stderr_fd:
-						stderr += self.parent_stderr.readline()
+						for line in self.parent_stderr.readlines():
+							stderr += line
 
 				# Check to see if the lvm process died on us
 				if self.lvm_shell.poll() is not None:

