From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:13:54 -0400
Subject: master - tests: some missed skip with lvmlockd
Message-ID: <201805311413.w4VEDsWM031102@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a44dceb4895fc3e1b89cad0050bc766250d91a4
Commit:        6a44dceb4895fc3e1b89cad0050bc766250d91a4
Parent:        5ac9f8d631cc6b340f4d3ad2cc35021e42d36ef6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 23 13:04:47 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

tests: some missed skip with lvmlockd

---
 test/shell/dmstats-create.sh         |    1 +
 test/shell/dmstats-report.sh         |    1 +
 test/shell/lv-ancestry.sh            |    1 +
 test/shell/lvconvert-repair-cache.sh |    1 +
 test/shell/process-each-lv.sh        |    2 ++
 test/shell/pv-ext-update.sh          |    1 +
 test/shell/relative-sign-options.sh  |    1 +
 test/shell/vg-check-devs-used.sh     |    1 +
 8 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/test/shell/dmstats-create.sh b/test/shell/dmstats-create.sh
index c16f26f..03406ae 100644
--- a/test/shell/dmstats-create.sh
+++ b/test/shell/dmstats-create.sh
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
diff --git a/test/shell/dmstats-report.sh b/test/shell/dmstats-report.sh
index 0312149..bd72f1a 100644
--- a/test/shell/dmstats-report.sh
+++ b/test/shell/dmstats-report.sh
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
diff --git a/test/shell/lv-ancestry.sh b/test/shell/lv-ancestry.sh
index 732499f..c36f366 100644
--- a/test/shell/lv-ancestry.sh
+++ b/test/shell/lv-ancestry.sh
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 4b9d8b8..6afb7ea 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -13,6 +13,7 @@
 # Test repairing of broken cached LV
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index e9cea81..9482a08 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise toollib process_each_lv'
+
 SKIP_WITH_LVMPOLLD=1
 
 # disable lvmetad logging as it bogs down test systems
@@ -18,6 +19,7 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
+
 aux prepare_devs 10
 
 #
diff --git a/test/shell/pv-ext-update.sh b/test/shell/pv-ext-update.sh
index cfaece7..44f301e 100644
--- a/test/shell/pv-ext-update.sh
+++ b/test/shell/pv-ext-update.sh
@@ -12,6 +12,7 @@
 
 # lvmetad does not handle pool labels so skip test.
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
diff --git a/test/shell/relative-sign-options.sh b/test/shell/relative-sign-options.sh
index 2db281a..2a36f1f 100644
--- a/test/shell/relative-sign-options.sh
+++ b/test/shell/relative-sign-options.sh
@@ -12,6 +12,7 @@
 
 test_description='Exercise toollib process_each_lv'
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 # disable lvmetad logging as it bogs down test systems
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
index 7d44812..9b99ef7 100644
--- a/test/shell/vg-check-devs-used.sh
+++ b/test/shell/vg-check-devs-used.sh
@@ -11,6 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 


