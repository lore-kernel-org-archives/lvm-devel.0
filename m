From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 14 Dec 2017 10:53:23 -0500
Subject: master - docs: Add TESTING file
Message-ID: <201712141553.vBEFrNB2011442@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c48d22bd3cddfe540413ed591ea18399c571a852
Commit:        c48d22bd3cddfe540413ed591ea18399c571a852
Parent:        584ff361dff9dc27a05839ac179899a80007b56e
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Dec 14 15:42:34 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 14 16:45:47 2017 +0100

docs: Add TESTING file

---
 TESTING |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/TESTING b/TESTING
new file mode 100644
index 0000000..57932f5
--- /dev/null
+++ b/TESTING
@@ -0,0 +1,62 @@
+LVM2 Test Suite
+===============
+
+The codebase contains many tests in the test subdirectory.
+
+Before running tests
+--------------------
+
+Keep in mind the testsuite MUST run under root user.
+
+It is recommended not to use LVM on the test machine, especially when running
+tests with udev (`make check_system`.)
+
+You MUST disable (or mask) any LVM daemons:
+
+- lvmetad
+- dmeventd
+- lvmpolld
+- lvmdbusd
+- lvmlockd
+- clvmd
+- cmirrord
+
+For running cluster tests, we are using singlenode locking. Pass
+`--with-clvmd=singlenode` to configure.
+
+NOTE: This is useful only for testing, and should not be used in produciton
+code.
+
+To run D-Bus daemon tests, existing D-Bus session is required.
+
+Running tests
+-------------
+
+As root run:
+
+    make check
+
+To run only tests matching a string:
+
+    make check T=test
+
+To skip tests matching a string:
+
+    make check S=test
+
+There are other targets and many environment variables can be used to tweak the
+testsuite - for full list and description run `make -C test help`.
+
+Installing testsuite
+--------------------
+
+It is possible to install and run a testsuite against installed LVM. Run the
+following:
+
+    make -C test install
+
+Then lvm2-testsuite binary can be executed to test installed binaries.
+
+See `lvm2-testsuite --help` for options. The same environment variables can be
+used as with `make check`.
+


