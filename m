From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:59 -0400
Subject: master - tests: add missing file
Message-ID: <201805311414.w4VEExAU031271@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=063d065388b6437b77815cb1d13a72395a46fd45
Commit:        063d065388b6437b77815cb1d13a72395a46fd45
Parent:        abba06fb3b3b813e55ab7f27c6ac8274115083e4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 25 17:02:25 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

tests: add missing file

---
 test/lib/flavour-udev-lvmlockd-test-lvmetad.sh |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/test/lib/flavour-udev-lvmlockd-test-lvmetad.sh b/test/lib/flavour-udev-lvmlockd-test-lvmetad.sh
new file mode 100644
index 0000000..d2a7b4a
--- /dev/null
+++ b/test/lib/flavour-udev-lvmlockd-test-lvmetad.sh
@@ -0,0 +1,9 @@
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMETAD=1
+export LVM_TEST_LVMPOLLD=1
+export LVM_TEST_LVMLOCKD=1
+export LVM_TEST_LVMLOCKD_TEST=1
+export LVM_TEST_DEVDIR=/dev
+
+# FIXME:dct: add option to allow --test with sanlock
+export LVM_TEST_LVMLOCKD_TEST_DLM=1


