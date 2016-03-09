From: okozina <okozina@fedoraproject.org>
Date: Wed,  9 Mar 2016 12:00:04 +0000 (UTC)
Subject: master - test: skip unrelated tests while testing lvmpolld
Message-ID: <20160309120004.9D27E60363@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55d1105fc9f7e81bdca0f4d489d157b79350cac8
Commit:        55d1105fc9f7e81bdca0f4d489d157b79350cac8
Parent:        5434e9f5ea697de7fe8785476f9e94f8615012f8
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Mar 9 12:32:10 2016 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Mar 9 12:59:45 2016 +0100

test: skip unrelated tests while testing lvmpolld

---
 test/api/vgtest.sh                       |    1 +
 test/shell/dmstats-create.sh             |    2 ++
 test/shell/dmstats-report.sh             |    2 ++
 test/shell/format-lvm1.sh                |    2 ++
 test/shell/lv-ancestry.sh                |    2 ++
 test/shell/process-each-duplicate-pvs.sh |    1 +
 test/shell/process-each-vg.sh            |    2 ++
 test/shell/process-each-vgreduce.sh      |    1 +
 test/shell/pvcreate-restore.sh           |    1 +
 test/shell/thin-overprovisioning.sh      |    1 +
 10 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/api/vgtest.sh b/test/api/vgtest.sh
index a262c26..13bf505 100644
--- a/test/api/vgtest.sh
+++ b/test/api/vgtest.sh
@@ -14,6 +14,7 @@
 #
 
 SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
diff --git a/test/shell/dmstats-create.sh b/test/shell/dmstats-create.sh
index 028bec7..a52cd34 100644
--- a/test/shell/dmstats-create.sh
+++ b/test/shell/dmstats-create.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 # Don't attempt to test stats with driver < 4.33.00
diff --git a/test/shell/dmstats-report.sh b/test/shell/dmstats-report.sh
index 702ea61..56f913d 100644
--- a/test/shell/dmstats-report.sh
+++ b/test/shell/dmstats-report.sh
@@ -9,6 +9,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 # Don't attempt to test stats with driver < 4.33.00
diff --git a/test/shell/format-lvm1.sh b/test/shell/format-lvm1.sh
index 2b6e1a2..a310b12 100644
--- a/test/shell/format-lvm1.sh
+++ b/test/shell/format-lvm1.sh
@@ -11,6 +11,8 @@
 
 test_description='Test lvm1 format'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux prepare_devs 1
diff --git a/test/shell/lv-ancestry.sh b/test/shell/lv-ancestry.sh
index febaf40..0e0cc79 100644
--- a/test/shell/lv-ancestry.sh
+++ b/test/shell/lv-ancestry.sh
@@ -10,6 +10,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux have_thin 1 0 0 || skip
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index cf0ca2d..47e1043 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -8,6 +8,7 @@
 test_description='Test duplicate PVs'
 
 SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
diff --git a/test/shell/process-each-vg.sh b/test/shell/process-each-vg.sh
index 22244a6..6d7b716 100644
--- a/test/shell/process-each-vg.sh
+++ b/test/shell/process-each-vg.sh
@@ -11,6 +11,8 @@
 
 test_description='Exercise toollib process_each_vg'
 
+SKIP_WITH_LVMPOLLD=1
+
 . lib/inittest
 
 aux prepare_devs 6
diff --git a/test/shell/process-each-vgreduce.sh b/test/shell/process-each-vgreduce.sh
index 6df8c56..e9f024a 100644
--- a/test/shell/process-each-vgreduce.sh
+++ b/test/shell/process-each-vgreduce.sh
@@ -12,6 +12,7 @@
 test_description='Exercise toollib process_each_pv with vgreduce'
 
 SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
diff --git a/test/shell/pvcreate-restore.sh b/test/shell/pvcreate-restore.sh
index ac0469e..7a4a57c 100644
--- a/test/shell/pvcreate-restore.sh
+++ b/test/shell/pvcreate-restore.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
diff --git a/test/shell/thin-overprovisioning.sh b/test/shell/thin-overprovisioning.sh
index 73accfe..8a396b6 100644
--- a/test/shell/thin-overprovisioning.sh
+++ b/test/shell/thin-overprovisioning.sh
@@ -12,6 +12,7 @@
 # Test warns when thin pool is overprovisiong
 
 SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 


