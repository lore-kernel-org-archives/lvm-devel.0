From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:54 +0000 (UTC)
Subject: master - test: Add new flavour definition files.
Message-ID: <20150205134054.100096119C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5a120c4439875c75549da97d2dcd752642fcc50
Commit:        c5a120c4439875c75549da97d2dcd752642fcc50
Parent:        fa46385164e971d998ef89f20162fe547efeaea0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Jun 26 22:34:38 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Add new flavour definition files.

---
 test/lib/flavour-ndev-cluster |    1 +
 test/lib/flavour-ndev-lvmetad |    2 ++
 test/lib/flavour-ndev-vanilla |    1 +
 test/lib/flavour-udev-cluster |    2 ++
 test/lib/flavour-udev-lvmetad |    3 +++
 test/lib/flavour-udev-vanilla |    2 ++
 6 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/test/lib/flavour-ndev-cluster b/test/lib/flavour-ndev-cluster
new file mode 100644
index 0000000..013b02d
--- /dev/null
+++ b/test/lib/flavour-ndev-cluster
@@ -0,0 +1 @@
+LVM_TEST_LOCKING=3
diff --git a/test/lib/flavour-ndev-lvmetad b/test/lib/flavour-ndev-lvmetad
new file mode 100644
index 0000000..6f8c2d4
--- /dev/null
+++ b/test/lib/flavour-ndev-lvmetad
@@ -0,0 +1,2 @@
+LVM_TEST_LOCKING=1
+LVM_TEST_LVMETAD=1
diff --git a/test/lib/flavour-ndev-vanilla b/test/lib/flavour-ndev-vanilla
new file mode 100644
index 0000000..b3f4cee
--- /dev/null
+++ b/test/lib/flavour-ndev-vanilla
@@ -0,0 +1 @@
+LVM_TEST_LOCKING=1
diff --git a/test/lib/flavour-udev-cluster b/test/lib/flavour-udev-cluster
new file mode 100644
index 0000000..7c37616
--- /dev/null
+++ b/test/lib/flavour-udev-cluster
@@ -0,0 +1,2 @@
+LVM_TEST_LOCKING=3
+LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-lvmetad b/test/lib/flavour-udev-lvmetad
new file mode 100644
index 0000000..e1dac52
--- /dev/null
+++ b/test/lib/flavour-udev-lvmetad
@@ -0,0 +1,3 @@
+LVM_TEST_LOCKING=1
+LVM_TEST_LVMETAD=1
+LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-vanilla b/test/lib/flavour-udev-vanilla
new file mode 100644
index 0000000..09d023a
--- /dev/null
+++ b/test/lib/flavour-udev-vanilla
@@ -0,0 +1,2 @@
+LVM_TEST_LOCKING=1
+LVM_TEST_DEVDIR=/dev


