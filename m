From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:36 +0000 (GMT)
Subject: main - lvmdbusd: Correct conditional for lvm child process running
Message-ID: <20220630160036.E9CDA38460AE@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=37733cd4eb5116db371ac1ae6e971e3c336c3ddb
Commit:        37733cd4eb5116db371ac1ae6e971e3c336c3ddb
Parent:        db5277c97155632ce83e1125e348eda97c871968
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed May 25 15:51:14 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbusd: Correct conditional for lvm child process running

Poll returns None when process is running, else exit value.  If poll returns
0 we will fail to exit the select loop.
---
 daemons/lvmdbusd/lvm_shell_proxy.py.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py.in b/daemons/lvmdbusd/lvm_shell_proxy.py.in
index 7816daa8b..78fe1e422 100644
--- a/daemons/lvmdbusd/lvm_shell_proxy.py.in
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py.in
@@ -75,7 +75,7 @@ class LVMShellProxy(object):
 						stderr += read_decoded(self.lvm_shell.stderr)
 
 				# Check to see if the lvm process died on us
-				if self.lvm_shell.poll():
+				if self.lvm_shell.poll() is not None:
 					raise Exception(self.lvm_shell.returncode, "%s" % stderr)
 
 				if stdout.endswith(SHELL_PROMPT):

