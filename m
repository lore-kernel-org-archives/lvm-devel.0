From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:32 +0000 (GMT)
Subject: main - lvmdbustest: Shutdown cleanly with "exit"
Message-ID: <20230310185232.2288D385842C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c3b91a513b70e74f21ca40e73f9ad7e3578ac48
Commit:        9c3b91a513b70e74f21ca40e73f9ad7e3578ac48
Parent:        9714f3ec4f3d4526a33781baf706c24930b6f26c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 11:27:19 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbustest: Shutdown cleanly with "exit"

Make the error injection wrapper handle the exit case, so that we can
clean up gracefully when instructed to do so.
---
 test/dbus/lvm_error_inject.py | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/test/dbus/lvm_error_inject.py b/test/dbus/lvm_error_inject.py
index 98520845c..d00b79b05 100755
--- a/test/dbus/lvm_error_inject.py
+++ b/test/dbus/lvm_error_inject.py
@@ -13,10 +13,12 @@
 # systemctl restart lvm2-lvmdbusd
 import copy
 import json
+import multiprocessing
 import os
 import pty
 import random
 import select
+import signal
 import string
 import subprocess
 import sys
@@ -29,6 +31,10 @@ from subprocess import Popen
 
 CS = string.ascii_letters + "\n\t " + string.digits
 
+run = multiprocessing.Value('i', 1)
+
+SH = None
+
 
 def rs(length, character_set=CS):
     return ''.join(random.choice(character_set) for _ in range(length))
@@ -253,10 +259,16 @@ class LvmShellHandler:
             self.report_text_in_progress = ""
 
     def _handle_command(self):
+        global run
         stdin_text = sys.stdin.readline()
         self.last_request = stdin_text
 
         debug("stdin: %s..." % stdin_text[:min(10, len(stdin_text) - 1)])
+
+        if "exit\n" in stdin_text:
+            debug("asking to exit ...")
+            run.value = 0
+
         self.parent_stdin.writelines(stdin_text)
         self.parent_stdin.flush()
 
@@ -267,8 +279,9 @@ class LvmShellHandler:
             queue.extend(line)
 
     def run(self):
+        global run
         select_tmo = 0.2
-        while True:
+        while run.value == 1:
             try:
                 rd_fd = [sys.stdin.fileno(), self.parent_stdout_fd, self.parent_stderr_fd, self.child_report_fd]
                 ready = select.select(rd_fd, [], [], select_tmo)
@@ -305,9 +318,11 @@ class LvmShellHandler:
                     break
             except IOError as ioe:
                 debug("run_cmd:" + str(ioe))
-                pass
 
-        debug("exiting %d " % self.process.returncode)
+        if self.process.poll() is not None:
+            debug("exiting %d " % self.process.returncode)
+        else:
+            debug("lvm process still running, be we are exiting ...")
         return self.process.returncode
 
 
@@ -321,8 +336,8 @@ if __name__ == "__main__":
             cmdline.extend(args)
             ec = run_one(cmdline)
         else:
-            sh = LvmShellHandler(cmdline)
-            ec = sh.run()
+            SH = LvmShellHandler(cmdline)
+            ec = SH.run()
         sys.exit(ec)
     except Exception:
         traceback.print_exc(file=d_out)

