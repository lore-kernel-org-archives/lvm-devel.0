From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:25 +0000 (UTC)
Subject: master - test: Targets and sources can't have the same name if builddir == srcdir.
Message-ID: <20150205134125.6E55260F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=feb2c7bc4773e88f2fa96ef838e88d5b427835b0
Commit:        feb2c7bc4773e88f2fa96ef838e88d5b427835b0
Parent:        2bc76bcdabe76876c59f9fec61292240993974bc
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 09:10:56 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Targets and sources can't have the same name if builddir == srcdir.

---
 test/Makefile.in                 |    2 +-
 test/lib/flavour-ndev-cluster    |    1 -
 test/lib/flavour-ndev-cluster.sh |    1 +
 test/lib/flavour-ndev-lvmetad    |    2 --
 test/lib/flavour-ndev-lvmetad.sh |    2 ++
 test/lib/flavour-ndev-vanilla    |    1 -
 test/lib/flavour-ndev-vanilla.sh |    1 +
 test/lib/flavour-udev-cluster    |    2 --
 test/lib/flavour-udev-cluster.sh |    2 ++
 test/lib/flavour-udev-lvmetad    |    3 ---
 test/lib/flavour-udev-lvmetad.sh |    3 +++
 test/lib/flavour-udev-vanilla    |    2 --
 test/lib/flavour-udev-vanilla.sh |    2 ++
 13 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index d930888..82adf20 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -171,7 +171,7 @@ lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
 	cp $< $@
 	chmod +x $@
 
-lib/flavour-%: $(srcdir)/lib/flavour-% .lib-dir-stamp
+lib/flavour-%: $(srcdir)/lib/flavour-%.sh .lib-dir-stamp
 	cp $< $@
 
 lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
diff --git a/test/lib/flavour-ndev-cluster b/test/lib/flavour-ndev-cluster
deleted file mode 100644
index 013b02d..0000000
--- a/test/lib/flavour-ndev-cluster
+++ /dev/null
@@ -1 +0,0 @@
-LVM_TEST_LOCKING=3
diff --git a/test/lib/flavour-ndev-cluster.sh b/test/lib/flavour-ndev-cluster.sh
new file mode 100644
index 0000000..013b02d
--- /dev/null
+++ b/test/lib/flavour-ndev-cluster.sh
@@ -0,0 +1 @@
+LVM_TEST_LOCKING=3
diff --git a/test/lib/flavour-ndev-lvmetad b/test/lib/flavour-ndev-lvmetad
deleted file mode 100644
index 6f8c2d4..0000000
--- a/test/lib/flavour-ndev-lvmetad
+++ /dev/null
@@ -1,2 +0,0 @@
-LVM_TEST_LOCKING=1
-LVM_TEST_LVMETAD=1
diff --git a/test/lib/flavour-ndev-lvmetad.sh b/test/lib/flavour-ndev-lvmetad.sh
new file mode 100644
index 0000000..6f8c2d4
--- /dev/null
+++ b/test/lib/flavour-ndev-lvmetad.sh
@@ -0,0 +1,2 @@
+LVM_TEST_LOCKING=1
+LVM_TEST_LVMETAD=1
diff --git a/test/lib/flavour-ndev-vanilla b/test/lib/flavour-ndev-vanilla
deleted file mode 100644
index b3f4cee..0000000
--- a/test/lib/flavour-ndev-vanilla
+++ /dev/null
@@ -1 +0,0 @@
-LVM_TEST_LOCKING=1
diff --git a/test/lib/flavour-ndev-vanilla.sh b/test/lib/flavour-ndev-vanilla.sh
new file mode 100644
index 0000000..b3f4cee
--- /dev/null
+++ b/test/lib/flavour-ndev-vanilla.sh
@@ -0,0 +1 @@
+LVM_TEST_LOCKING=1
diff --git a/test/lib/flavour-udev-cluster b/test/lib/flavour-udev-cluster
deleted file mode 100644
index 7c37616..0000000
--- a/test/lib/flavour-udev-cluster
+++ /dev/null
@@ -1,2 +0,0 @@
-LVM_TEST_LOCKING=3
-LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-cluster.sh b/test/lib/flavour-udev-cluster.sh
new file mode 100644
index 0000000..7c37616
--- /dev/null
+++ b/test/lib/flavour-udev-cluster.sh
@@ -0,0 +1,2 @@
+LVM_TEST_LOCKING=3
+LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-lvmetad b/test/lib/flavour-udev-lvmetad
deleted file mode 100644
index e1dac52..0000000
--- a/test/lib/flavour-udev-lvmetad
+++ /dev/null
@@ -1,3 +0,0 @@
-LVM_TEST_LOCKING=1
-LVM_TEST_LVMETAD=1
-LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-lvmetad.sh b/test/lib/flavour-udev-lvmetad.sh
new file mode 100644
index 0000000..e1dac52
--- /dev/null
+++ b/test/lib/flavour-udev-lvmetad.sh
@@ -0,0 +1,3 @@
+LVM_TEST_LOCKING=1
+LVM_TEST_LVMETAD=1
+LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-vanilla b/test/lib/flavour-udev-vanilla
deleted file mode 100644
index 09d023a..0000000
--- a/test/lib/flavour-udev-vanilla
+++ /dev/null
@@ -1,2 +0,0 @@
-LVM_TEST_LOCKING=1
-LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-vanilla.sh b/test/lib/flavour-udev-vanilla.sh
new file mode 100644
index 0000000..09d023a
--- /dev/null
+++ b/test/lib/flavour-udev-vanilla.sh
@@ -0,0 +1,2 @@
+LVM_TEST_LOCKING=1
+LVM_TEST_DEVDIR=/dev


