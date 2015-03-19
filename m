From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Mar 2015 10:25:05 +0000 (UTC)
Subject: master - tests: export shell vars
Message-ID: <20150319102505.ED39060E3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4fa7563853a0f104dec0872760d4acfa08d2554
Commit:        e4fa7563853a0f104dec0872760d4acfa08d2554
Parent:        a13d2614664ba0bc7b5b345e446cfaa38de4c470
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 19 11:23:44 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 19 11:23:44 2015 +0100

tests: export shell vars

Export vars so they are visible in  'aux' calls as well.
(reenables cluster testing)
---
 test/lib/flavour-ndev-cluster.sh |    2 +-
 test/lib/flavour-ndev-lvmetad.sh |    4 ++--
 test/lib/flavour-ndev-vanilla.sh |    2 +-
 test/lib/flavour-udev-cluster.sh |    4 ++--
 test/lib/flavour-udev-lvmetad.sh |    6 +++---
 test/lib/flavour-udev-vanilla.sh |    4 ++--
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/test/lib/flavour-ndev-cluster.sh b/test/lib/flavour-ndev-cluster.sh
index 013b02d..3629069 100644
--- a/test/lib/flavour-ndev-cluster.sh
+++ b/test/lib/flavour-ndev-cluster.sh
@@ -1 +1 @@
-LVM_TEST_LOCKING=3
+export LVM_TEST_LOCKING=3
diff --git a/test/lib/flavour-ndev-lvmetad.sh b/test/lib/flavour-ndev-lvmetad.sh
index 6f8c2d4..cb3c49e 100644
--- a/test/lib/flavour-ndev-lvmetad.sh
+++ b/test/lib/flavour-ndev-lvmetad.sh
@@ -1,2 +1,2 @@
-LVM_TEST_LOCKING=1
-LVM_TEST_LVMETAD=1
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMETAD=1
diff --git a/test/lib/flavour-ndev-vanilla.sh b/test/lib/flavour-ndev-vanilla.sh
index b3f4cee..1899c94 100644
--- a/test/lib/flavour-ndev-vanilla.sh
+++ b/test/lib/flavour-ndev-vanilla.sh
@@ -1 +1 @@
-LVM_TEST_LOCKING=1
+export LVM_TEST_LOCKING=1
diff --git a/test/lib/flavour-udev-cluster.sh b/test/lib/flavour-udev-cluster.sh
index 7c37616..a9025a6 100644
--- a/test/lib/flavour-udev-cluster.sh
+++ b/test/lib/flavour-udev-cluster.sh
@@ -1,2 +1,2 @@
-LVM_TEST_LOCKING=3
-LVM_TEST_DEVDIR=/dev
+export LVM_TEST_LOCKING=3
+export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-lvmetad.sh b/test/lib/flavour-udev-lvmetad.sh
index e1dac52..13be32e 100644
--- a/test/lib/flavour-udev-lvmetad.sh
+++ b/test/lib/flavour-udev-lvmetad.sh
@@ -1,3 +1,3 @@
-LVM_TEST_LOCKING=1
-LVM_TEST_LVMETAD=1
-LVM_TEST_DEVDIR=/dev
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMETAD=1
+export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-vanilla.sh b/test/lib/flavour-udev-vanilla.sh
index 09d023a..ca778a6 100644
--- a/test/lib/flavour-udev-vanilla.sh
+++ b/test/lib/flavour-udev-vanilla.sh
@@ -1,2 +1,2 @@
-LVM_TEST_LOCKING=1
-LVM_TEST_DEVDIR=/dev
+export LVM_TEST_LOCKING=1
+export LVM_TEST_DEVDIR=/dev


