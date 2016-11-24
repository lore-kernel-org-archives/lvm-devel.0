From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 24 Nov 2016 00:16:44 +0000 (UTC)
Subject: master - lvmdbusd: Only read whats buffered
Message-ID: <20161124001644.82CE7608F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=064e24bc1e9f5b84a5987febaf0d11e5aeae39e2
Commit:        064e24bc1e9f5b84a5987febaf0d11e5aeae39e2
Parent:        a7404b5b830479e9ff7dd634e015c9ebcdb9b20b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 23 14:49:23 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 23 18:16:11 2016 -0600

lvmdbusd: Only read whats buffered

When reading data from stdout & stderr we were reading until the
reading until we got None back which really isn't needed as the
read will return everything that is available.
---
 daemons/lvmdbusd/lvm_shell_proxy.py |   19 ++++++-------------
 1 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 8d15e10..50f2201 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -64,13 +64,9 @@ class LVMShellProxy(object):
 
 				for r in ready[0]:
 					if r == self.lvm_shell.stdout.fileno():
-						while True:
-							tmp = self.lvm_shell.stdout.read()
-							if tmp:
-								stdout += tmp.decode("utf-8")
-							else:
-								break
-
+						tmp = self.lvm_shell.stdout.read()
+						if tmp:
+							stdout += tmp.decode("utf-8")
 					elif r == self.report_r:
 						while True:
 							tmp = os.read(self.report_r, 16384)
@@ -82,12 +78,9 @@ class LVMShellProxy(object):
 								break
 
 					elif r == self.lvm_shell.stderr.fileno():
-						while True:
-							tmp = self.lvm_shell.stderr.read()
-							if tmp:
-								stderr += tmp.decode("utf-8")
-							else:
-								break
+						tmp = self.lvm_shell.stderr.read()
+						if tmp:
+							stderr += tmp.decode("utf-8")
 
 				# Check to see if the lvm process died on us
 				if self.lvm_shell.poll():


