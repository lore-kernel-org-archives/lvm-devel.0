From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:05:07 +0000 (GMT)
Subject: main - gitignore: update
Message-ID: <20220907130507.D1D0B3858428@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b05d6bd833c463b9a2074b2aa2bdaa531e7ab01
Commit:        6b05d6bd833c463b9a2074b2aa2bdaa531e7ab01
Parent:        19db3b3e456010fe8e2e3815bf12deba690c7303
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 5 12:08:50 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

gitignore: update

---
 .gitignore      | 21 ++++++++++++++++++---
 udev/.gitignore |  1 +
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/.gitignore b/.gitignore
index 8c1672bd2..224d43cd6 100644
--- a/.gitignore
+++ b/.gitignore
@@ -16,6 +16,10 @@
 *.sw*
 *~
 
+# gcov files:
+*.gcda
+*.gcno
+
 .export.sym
 .exported_symbols_generated
 .gdb_history
@@ -39,9 +43,11 @@ make.tmpl
 
 coverity/coverity_model.xml
 
-# gcov files:
-*.gcda
-*.gcno
+/libdm/.symver_check
+
+daemons/clvmd
+daemons/dmfilemapd
+daemons/lvmetad/
 
 tools/man-generator
 tools/man-generator.c
@@ -102,6 +108,8 @@ test/api/thin_percent.t
 test/api/vglist.t
 test/api/vgtest.t
 test/lib/aux
+test/lib/cache-mq.profile
+test/lib/cache-smq.profile
 test/lib/check
 test/lib/clvmd
 test/lib/dm-version-expected
@@ -111,6 +119,7 @@ test/lib/dmstats
 test/lib/fail
 test/lib/flavour-ndev-cluster
 test/lib/flavour-ndev-cluster-lvmpolld
+test/lib/flavour-ndev-devicesfile
 test/lib/flavour-ndev-lvmetad
 test/lib/flavour-ndev-lvmetad-lvmpolld
 test/lib/flavour-ndev-lvmpolld
@@ -120,6 +129,7 @@ test/lib/flavour-udev-cluster-lvmpolld
 test/lib/flavour-udev-lvmetad
 test/lib/flavour-udev-lvmetad-lvmpolld
 test/lib/flavour-udev-lvmlockd-dlm
+test/lib/flavour-udev-lvmlockd-idm
 test/lib/flavour-udev-lvmlockd-sanlock
 test/lib/flavour-udev-lvmlockd-test
 test/lib/flavour-udev-lvmpolld
@@ -132,8 +142,11 @@ test/lib/lvm
 test/lib/lvm-wrapper
 test/lib/lvmchange
 test/lib/lvmdbusd.profile
+test/lib/lvmdevices
 test/lib/lvmetad
 test/lib/lvmpolld
+test/lib/lvm_import_vdo
+test/lib/lvm_vdo_wrapper
 test/lib/not
 test/lib/paths
 test/lib/paths-common
@@ -143,5 +156,7 @@ test/lib/test
 test/lib/thin-performance.profile
 test/lib/utils
 test/lib/version-expected
+test/lib/vgimportdevices
+
 test/unit/dmraid_t.c
 test/unit/unit-test
diff --git a/udev/.gitignore b/udev/.gitignore
index 303d78761..24884bd4e 100644
--- a/udev/.gitignore
+++ b/udev/.gitignore
@@ -1,5 +1,6 @@
 10-dm.rules
 11-dm-lvm.rules
 13-dm-disk.rules
+69-dm-lvm.rules
 69-dm-lvm-metad.rules
 95-dm-notify.rules

