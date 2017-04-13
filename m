From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 13 Apr 2017 19:03:57 -0400
Subject: master - test: correcting binary usage
Message-ID: <201704132303.v3DN3vEO019004@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa25cfe084adf360c4ab1333a927b49279796f00
Commit:        aa25cfe084adf360c4ab1333a927b49279796f00
Parent:        15c3ad9641deaee64f4c645a87d191adb098035e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 14 01:03:18 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 14 01:03:18 2017 +0200

test: correcting binary usage

Ensure 'test suite' run uses fsadm and dmeventd from compiled dir,
while for 'rpm' installed test use binaries installed in system.
---
 test/lib/aux.sh                |    9 ++++++++-
 test/shell/dmeventd-restart.sh |    5 -----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f12f953..5303adc 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1157,7 +1157,6 @@ global/thin_repair_executable = "$LVM_TEST_THIN_REPAIR_CMD"
 global/use_lvmetad = $LVM_TEST_LVMETAD
 global/use_lvmpolld = $LVM_TEST_LVMPOLLD
 global/use_lvmlockd = $LVM_TEST_LVMLOCKD
-global/fsadm_executable = "$TESTDIR/lib/fsadm"
 log/activation = 1
 log/file = "$TESTDIR/debug.log"
 log/indent = 1
@@ -1166,6 +1165,14 @@ log/overwrite = 1
 log/syslog = 0
 log/verbose = 0
 EOF
+		# For 'rpm' builds use system installed binaries.
+		# For test suite run use binaries from builddir.
+		test -z "${abs_top_builddir+varset}" || {
+			cat >> "$config_values" <<-EOF
+dmeventd/executable = "$abs_top_builddir/test/lib/dmeventd"
+global/fsadm_executable = "$abs_top_builddir/test/lib/fsadm"
+EOF
+		}
 	}
 
 	local v
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 9fad9a8..90f4d9a 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -45,11 +45,6 @@ sleep 7
 not pgrep dmeventd
 rm LOCAL_DMEVENTD
 
-# set dmeventd path
-if test -n "$abs_top_builddir"; then
-    aux lvmconf "dmeventd/executable=\"$abs_top_builddir/test/lib/dmeventd\""
-fi
-
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
 pgrep -o dmeventd >LOCAL_DMEVENTD
 not grep 'already monitored' lvchange.out


