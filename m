From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:54:18 -0400
Subject: master - disable LVM1 tests
Message-ID: <201804231354.w3NDsIES001396@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d75aa557845e37f5c4b90ca43c81943bd9b90094
Commit:        d75aa557845e37f5c4b90ca43c81943bd9b90094
Parent:        96a61337b00a250f69e7a8e6ac390c47c36c2c0f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 15 09:54:12 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

disable LVM1 tests

---
 test/lib/flavour-ndev-cluster.sh |    1 -
 test/lib/flavour-ndev-vanilla.sh |    1 -
 test/lib/flavour-udev-cluster.sh |    1 -
 test/lib/flavour-udev-vanilla.sh |    1 -
 4 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/test/lib/flavour-ndev-cluster.sh b/test/lib/flavour-ndev-cluster.sh
index 3082b11..3629069 100644
--- a/test/lib/flavour-ndev-cluster.sh
+++ b/test/lib/flavour-ndev-cluster.sh
@@ -1,2 +1 @@
 export LVM_TEST_LOCKING=3
-export LVM_TEST_LVM1=1
diff --git a/test/lib/flavour-ndev-vanilla.sh b/test/lib/flavour-ndev-vanilla.sh
index c106e61..1899c94 100644
--- a/test/lib/flavour-ndev-vanilla.sh
+++ b/test/lib/flavour-ndev-vanilla.sh
@@ -1,2 +1 @@
 export LVM_TEST_LOCKING=1
-export LVM_TEST_LVM1=1
diff --git a/test/lib/flavour-udev-cluster.sh b/test/lib/flavour-udev-cluster.sh
index 1cab558..a9025a6 100644
--- a/test/lib/flavour-udev-cluster.sh
+++ b/test/lib/flavour-udev-cluster.sh
@@ -1,3 +1,2 @@
 export LVM_TEST_LOCKING=3
 export LVM_TEST_DEVDIR=/dev
-export LVM_TEST_LVM1=1
diff --git a/test/lib/flavour-udev-vanilla.sh b/test/lib/flavour-udev-vanilla.sh
index 6fbdafe..ca778a6 100644
--- a/test/lib/flavour-udev-vanilla.sh
+++ b/test/lib/flavour-udev-vanilla.sh
@@ -1,3 +1,2 @@
 export LVM_TEST_LOCKING=1
 export LVM_TEST_DEVDIR=/dev
-export LVM_TEST_LVM1=1


