From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 24 Apr 2023 22:14:35 +0000 (GMT)
Subject: main - tests: skip some unneeded test
Message-ID: <20230424221435.1B31D3858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8476a09ee5b761d393a26145d2da23615d31579f
Commit:        8476a09ee5b761d393a26145d2da23615d31579f
Parent:        a51b6d5e4269ba4a5b335a3894873c750c2e8384
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 23 19:17:08 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 00:12:31 2023 +0200

tests: skip some unneeded test

Skip irelevant tests for polld & lockd pass.
---
 test/shell/aa-lvmlockd-dlm-prepare.sh     | 2 ++
 test/shell/aa-lvmlockd-idm-prepare.sh     | 2 ++
 test/shell/aa-lvmlockd-sanlock-prepare.sh | 2 ++
 test/shell/allow-mixed-block-sizes.sh     | 1 +
 test/shell/devicesfile-basic.sh           | 2 ++
 test/shell/devicesfile-devname.sh         | 2 ++
 test/shell/devicesfile-edit.sh            | 2 ++
 test/shell/devicesfile-realdevs.sh        | 2 ++
 test/shell/devicesfile-serial.sh          | 2 ++
 test/shell/discards-thin.sh               | 1 +
 test/shell/dmsecuretest.sh                | 1 +
 test/shell/dmstats-create.sh              | 2 +-
 test/shell/dmstats-report.sh              | 2 +-
 test/shell/error-usage.sh                 | 1 +
 test/shell/report-fields.sh               | 2 +-
 test/shell/report-format.sh               | 1 +
 test/shell/report-hidden.sh               | 2 +-
 17 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/test/shell/aa-lvmlockd-dlm-prepare.sh b/test/shell/aa-lvmlockd-dlm-prepare.sh
index 24021f3ef..c261c1d39 100644
--- a/test/shell/aa-lvmlockd-dlm-prepare.sh
+++ b/test/shell/aa-lvmlockd-dlm-prepare.sh
@@ -12,6 +12,8 @@
 
 test_description='Set up things to run tests with dlm'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 [ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
diff --git a/test/shell/aa-lvmlockd-idm-prepare.sh b/test/shell/aa-lvmlockd-idm-prepare.sh
index 8faff3bc2..fc9d75b5b 100644
--- a/test/shell/aa-lvmlockd-idm-prepare.sh
+++ b/test/shell/aa-lvmlockd-idm-prepare.sh
@@ -12,6 +12,8 @@
 
 test_description='Set up things to run tests with idm'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 [ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip;
diff --git a/test/shell/aa-lvmlockd-sanlock-prepare.sh b/test/shell/aa-lvmlockd-sanlock-prepare.sh
index 4d0f9fd94..6db14fe5b 100644
--- a/test/shell/aa-lvmlockd-sanlock-prepare.sh
+++ b/test/shell/aa-lvmlockd-sanlock-prepare.sh
@@ -12,6 +12,8 @@
 
 test_description='Set up things to run tests with sanlock'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 [ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
index 912f87781..d6983cc7c 100644
--- a/test/shell/allow-mixed-block-sizes.sh
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -10,6 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/devicesfile-basic.sh b/test/shell/devicesfile-basic.sh
index 715c579b3..c2ede4735 100644
--- a/test/shell/devicesfile-basic.sh
+++ b/test/shell/devicesfile-basic.sh
@@ -12,6 +12,8 @@
 
 test_description='devices file'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux prepare_devs 7
diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
index 76c978fb0..5fe87c579 100644
--- a/test/shell/devicesfile-devname.sh
+++ b/test/shell/devicesfile-devname.sh
@@ -12,6 +12,8 @@
 
 test_description='devices file with devnames'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux prepare_devs 7
diff --git a/test/shell/devicesfile-edit.sh b/test/shell/devicesfile-edit.sh
index a71ca0c43..126d5b1d6 100644
--- a/test/shell/devicesfile-edit.sh
+++ b/test/shell/devicesfile-edit.sh
@@ -12,6 +12,8 @@
 
 test_description='devices file editing with lvmdevices'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux lvmconf 'devices/scan = "/dev"'
diff --git a/test/shell/devicesfile-realdevs.sh b/test/shell/devicesfile-realdevs.sh
index 23d4bedb4..0f62e9b33 100644
--- a/test/shell/devicesfile-realdevs.sh
+++ b/test/shell/devicesfile-realdevs.sh
@@ -12,6 +12,8 @@
 
 test_description='devices file with real devs'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 #
diff --git a/test/shell/devicesfile-serial.sh b/test/shell/devicesfile-serial.sh
index a88c1906a..94ce3d74a 100644
--- a/test/shell/devicesfile-serial.sh
+++ b/test/shell/devicesfile-serial.sh
@@ -12,6 +12,8 @@
 
 test_description='device id wwid from vpd_pg83'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 test "$DM_DEV_DIR" = "/dev" || skip "Only works with /dev access -> make check LVM_TEST_DEVDIR=/dev"
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index f27d4c3d1..213f713aa 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -15,6 +15,7 @@
 
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
diff --git a/test/shell/dmsecuretest.sh b/test/shell/dmsecuretest.sh
index 6fbdb893c..609fc7cf5 100644
--- a/test/shell/dmsecuretest.sh
+++ b/test/shell/dmsecuretest.sh
@@ -13,6 +13,7 @@
 # Test secure table is not leaking data in user land
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 # AES key matching rot13 string from dmsecuretest.c */
 SECURE="434e0cbab02ca68ffba9268222c3789d703fe62427b78b308518b3228f6a2122"
diff --git a/test/shell/dmstats-create.sh b/test/shell/dmstats-create.sh
index e28c9ef9d..03406aeff 100644
--- a/test/shell/dmstats-create.sh
+++ b/test/shell/dmstats-create.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
-
+SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
diff --git a/test/shell/dmstats-report.sh b/test/shell/dmstats-report.sh
index 965fca80e..bd72f1a61 100644
--- a/test/shell/dmstats-report.sh
+++ b/test/shell/dmstats-report.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
-
+SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index f8a561a37..bc9f30ab9 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -13,6 +13,7 @@
 # Basic usage of zero target
 
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/report-fields.sh b/test/shell/report-fields.sh
index 949e5a579..eb81afc98 100644
--- a/test/shell/report-fields.sh
+++ b/test/shell/report-fields.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/report-format.sh b/test/shell/report-format.sh
index 14b53edfb..e02d61b27 100644
--- a/test/shell/report-format.sh
+++ b/test/shell/report-format.sh
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/report-hidden.sh b/test/shell/report-hidden.sh
index 621eefc54..f38e04867 100644
--- a/test/shell/report-hidden.sh
+++ b/test/shell/report-hidden.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-
+SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest

