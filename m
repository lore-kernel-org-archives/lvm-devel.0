From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:47 +0000 (GMT)
Subject: main - tests: more system defaults for installed tests
Message-ID: <20210322215347.406533857828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d2ad4419a58536696474dbdfb241204d561dcf6
Commit:        8d2ad4419a58536696474dbdfb241204d561dcf6
Parent:        f1858d209d7b6f0e0db232567c886cfcf374dba1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 20 23:50:16 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:36:37 2021 +0100

tests: more system defaults for installed tests

When testing installed binaries on system, use more 'built-in'
predefined settings to usethem with their  compiled-in values.

Also it's better to use same locking dir so the system's pvscan
is not unexpectedly interferring with test commands.
---
 test/lib/aux.sh | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 8c727e8c6..ae173b8da 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1299,8 +1299,6 @@ activation/polling_interval = 1
 activation/retry_deactivation = 1
 activation/snapshot_autoextend_percent = 50
 activation/snapshot_autoextend_threshold = 50
-activation/udev_rules = 1
-activation/udev_sync = 1
 activation/verify_udev_operations = $LVM_VERIFY_UDEV
 activation/raid_region_size = 512
 allocation/wipe_signatures_when_zeroing_new_lvs = 0
@@ -1324,8 +1322,6 @@ global/cache_dump_executable = "$LVM_TEST_CACHE_DUMP_CMD"
 global/cache_repair_executable = "$LVM_TEST_CACHE_REPAIR_CMD"
 global/detect_internal_vg_cache_corruption = 1
 global/fallback_to_local_locking = 0
-global/library_dir = "$TESTDIR/lib"
-global/locking_dir = "$TESTDIR/var/lock/lvm"
 global/locking_type=$LVM_TEST_LOCKING
 global/notify_dbus = 0
 global/si_unit_consistency = 1
@@ -1342,12 +1338,18 @@ log/overwrite = 1
 log/syslog = 0
 log/verbose = 0
 EOF
-		# For 'rpm' builds use system installed binaries.
+		# For 'rpm' builds use system installed binaries
+		# and libraries and locking dir and some more built-in
+		# defaults
 		# For test suite run use binaries from builddir.
 		test -z "${abs_top_builddir+varset}" || {
 			cat >> "$config_values" <<-EOF
 dmeventd/executable = "$abs_top_builddir/test/lib/dmeventd"
+activation/udev_rules = 1
+activation/udev_sync = 1
 global/fsadm_executable = "$abs_top_builddir/test/lib/fsadm"
+global/library_dir = "$TESTDIR/lib"
+global/locking_dir = "$TESTDIR/var/lock/lvm"
 EOF
 		}
 	}


