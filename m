From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:35 +0000 (GMT)
Subject: main - lvmdbustest: Check for needed env. variables
Message-ID: <20230310185235.87FA43858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8876290bfc8d11400901e9eac32f6d613b0ed70
Commit:        f8876290bfc8d11400901e9eac32f6d613b0ed70
Parent:        568e8c71d7e39da7494a470400d3f9977c13a1c7
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Mar 10 10:41:50 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbustest: Check for needed env. variables

---
 test/dbus/lvm_error_inject.py | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvm_error_inject.py b/test/dbus/lvm_error_inject.py
index 2849dd29c..098f87070 100755
--- a/test/dbus/lvm_error_inject.py
+++ b/test/dbus/lvm_error_inject.py
@@ -336,8 +336,12 @@ if __name__ == "__main__":
             cmdline.extend(args)
             ec = run_one(cmdline)
         else:
-            SH = LvmShellHandler(cmdline)
-            ec = SH.run()
+            if "LVM_REPORT_FD" in os.environ:
+                SH = LvmShellHandler(cmdline)
+                ec = SH.run()
+            else:
+                debug('running as lvm shell requires: LVM_REPORT_FD to be set')
+                ec = 1
         sys.exit(ec)
     except Exception:
         traceback.print_exc(file=d_out)

