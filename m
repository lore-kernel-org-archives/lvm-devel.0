From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:29 +0000 (GMT)
Subject: main - lvmdbustest: Correctly set up env. for error injection
Message-ID: <20230310185229.D4E853858416@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2359023009db40112f4220899f0983684d897765
Commit:        2359023009db40112f4220899f0983684d897765
Parent:        70a5ebc052e7873761c04679ed8e57cd5f20e91a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 11:23:47 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbustest: Correctly set up env. for error injection

---
 test/dbus/lvm_error_inject.py | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/dbus/lvm_error_inject.py b/test/dbus/lvm_error_inject.py
index 00653d67f..d87286740 100755
--- a/test/dbus/lvm_error_inject.py
+++ b/test/dbus/lvm_error_inject.py
@@ -183,6 +183,8 @@ class LvmShellHandler:
 
         env = copy.deepcopy(os.environ)
         env["LVM_REPORT_FD"] = "%s" % str(passed_report_fd)
+        env["LC_ALL"] = "C"
+        env["LVM_COMMAND_PROFILE"] = "lvmdbusd"
 
         self.parent_stdin_fd, child_stdin_fd = pty.openpty()
         self.parent_stdout_fd, child_stdout_fd = pty.openpty()

