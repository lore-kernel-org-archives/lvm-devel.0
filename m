From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:43 +0000 (GMT)
Subject: main - lvmdbusd: Raise IOError instead of ignoring
Message-ID: <20220919155843.588D3385829C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e1e40c499a0e46a0a15b9a6b470adb8fbbbbf4f
Commit:        8e1e40c499a0e46a0a15b9a6b470adb8fbbbbf4f
Parent:        2c5762038a7d2877dca91593ca212e0e36802dc1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 8 15:41:20 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Raise IOError instead of ignoring

We end up in a bad state if we simply eat IOErrors here.  Exit the lvmshell
process and raise the IOError.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 244fe93f5..ed2c7bc9e 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -108,7 +108,8 @@ class LVMShellProxy(object):
 
 			except IOError as ioe:
 				log_debug(str(ioe))
-				pass
+				self.exit_shell()
+				raise ioe
 
 		if keep_reading and run.value == 0:
 			# We didn't complete as we are shutting down

