From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed,  9 Mar 2016 10:10:35 +0000 (UTC)
Subject: master - test: Comment out incorrect lockd setup
Message-ID: <20160309101035.3387A607B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb968ee875a232c8ca19c6277c0fcb223cbed93b
Commit:        cb968ee875a232c8ca19c6277c0fcb223cbed93b
Parent:        c6e1845f769851edbfeb88105ec37e9fe5ad3424
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 9 10:56:39 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 9 10:58:21 2016 +0100

test: Comment out incorrect lockd setup

---
 test/lib/aux.sh                        |    8 +++-----
 test/lib/flavour-udev-lvmlockd-test.sh |    3 +++
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5911eaf..021eb81 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -108,9 +108,6 @@ prepare_sanlock() {
 	fi
 }
 
-# FIXME: add option to allow --test with sanlock
-LVM_TEST_LVMLOCKD_TEST_DLM=1
-
 prepare_lvmlockd() {
 	if pgrep lvmlockd ; then
 		echo "Cannot run while existing lvmlockd process exists"
@@ -965,8 +962,9 @@ generate_config() {
 	LVM_TEST_LVMETAD=${LVM_TEST_LVMETAD:-0}
 	LVM_TEST_LVMPOLLD=${LVM_TEST_LVMPOLLD:-0}
 	LVM_TEST_LVMLOCKD=${LVM_TEST_LVMLOCKD:-0}
-	LVM_TEST_LOCK_TYPE_SANLOCK=${LVM_TEST_LOCK_TYPE_SANLOCK:-0}
-	LVM_TEST_LOCK_TYPE_DLM=${LVM_TEST_LOCK_TYPE_DLM:-0}
+        # FIXME:dct: This is harmful! Variables are unused here and are tested not being empty elsewhere:
+	#LVM_TEST_LOCK_TYPE_SANLOCK=${LVM_TEST_LOCK_TYPE_SANLOCK:-0}
+	#LVM_TEST_LOCK_TYPE_DLM=${LVM_TEST_LOCK_TYPE_DLM:-0}
 	if test "$DM_DEV_DIR" = "/dev"; then
 	    LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-0}
 	else
diff --git a/test/lib/flavour-udev-lvmlockd-test.sh b/test/lib/flavour-udev-lvmlockd-test.sh
index 60b67b1..17ef516 100644
--- a/test/lib/flavour-udev-lvmlockd-test.sh
+++ b/test/lib/flavour-udev-lvmlockd-test.sh
@@ -4,3 +4,6 @@ export LVM_TEST_LVMPOLLD=1
 export LVM_TEST_LVMLOCKD=1
 export LVM_TEST_LVMLOCKD_TEST=1
 export LVM_TEST_DEVDIR=/dev
+
+# FIXME:dct: add option to allow --test with sanlock
+LVM_TEST_LVMLOCKD_TEST_DLM=1


