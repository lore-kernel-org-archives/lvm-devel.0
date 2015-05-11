From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 13:54:05 +0000 (UTC)
Subject: master - tests: disable lvmetad and lvmpolld
Message-ID: <20150511135405.81F16603E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fabc19b73cb08f1a80bbf558b858110520ee8b53
Commit:        fabc19b73cb08f1a80bbf558b858110520ee8b53
Parent:        b5b3ad14a83b1c5a876b11b27c825d473110d9f5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 15:45:34 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 15:53:21 2015 +0200

tests: disable lvmetad and lvmpolld

Since now we enable those by default when compiled with those daemons,
explicitely disable them in tests when needed.

Alphabetically sort configurables.
---
 test/lib/aux.sh |   60 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index cb0fe4f..0985767 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -816,6 +816,8 @@ generate_config() {
 	fi
 
 	LVM_TEST_LOCKING=${LVM_TEST_LOCKING:-1}
+	LVM_TEST_LVMETAD=${LVM_TEST_LVMETAD:-0}
+	LVM_TEST_LVMPOLLD=${LVM_TEST_LVMPOLLD:-0}
 	if test "$DM_DEV_DIR" = "/dev"; then
 	    LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-0}
 	else
@@ -823,46 +825,48 @@ generate_config() {
 	fi
 	test -f "$config_values" || {
             cat > "$config_values" <<-EOF
-devices/dir = "$DM_DEV_DIR"
-devices/scan = "$DM_DEV_DIR"
-devices/filter = "a|.*|"
-devices/global_filter = [ "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
+activation/checks = 1
+activation/monitoring = 0
+activation/polling_interval = 0
+activation/retry_deactivation = 1
+activation/snapshot_autoextend_percent = 50
+activation/snapshot_autoextend_threshold = 50
+activation/udev_rules = 1
+activation/udev_sync = 1
+activation/verify_udev_operations = $LVM_VERIFY_UDEV
+allocation/wipe_signatures_when_zeroing_new_lvs = 0
+backup/archive = 0
+backup/backup = 0
 devices/cache_dir = "$TESTDIR/etc"
-devices/sysfs_scan = 1
 devices/default_data_alignment = 1
+devices/dir = "$DM_DEV_DIR"
+devices/filter = "a|.*|"
+qdevices/global_filter = [ "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
 devices/md_component_detection  = 0
-log/syslog = 0
-log/indent = 1
-log/level = 9
-log/file = "$TESTDIR/debug.log"
-log/overwrite = 1
-log/activation = 1
-log/verbose = 0
-activation/retry_deactivation = 1
-backup/backup = 0
-backup/archive = 0
+devices/scan = "$DM_DEV_DIR"
+devices/sysfs_scan = 1
 global/abort_on_internal_errors = 1
+global/cache_check_executable = "$LVM_TEST_CACHE_CHECK_CMD"
+global/cache_dump_executable = "$LVM_TEST_CACHE_DUMP_CMD"
+global/cache_repair_executable = "$LVM_TEST_CACHE_REPAIR_CMD"
 global/detect_internal_vg_cache_corruption = 1
+global/fallback_to_local_locking = 0
 global/library_dir = "$TESTDIR/lib"
 global/locking_dir = "$TESTDIR/var/lock/lvm"
 global/locking_type=$LVM_TEST_LOCKING
 global/si_unit_consistency = 1
-global/fallback_to_local_locking = 0
-global/cache_check_executable = "$LVM_TEST_CACHE_CHECK_CMD"
-global/cache_dump_executable = "$LVM_TEST_CACHE_DUMP_CMD"
-global/cache_repair_executable = "$LVM_TEST_CACHE_REPAIR_CMD"
 global/thin_check_executable = "$LVM_TEST_THIN_CHECK_CMD"
 global/thin_dump_executable = "$LVM_TEST_THIN_DUMP_CMD"
 global/thin_repair_executable = "$LVM_TEST_THIN_REPAIR_CMD"
-activation/checks = 1
-activation/udev_sync = 1
-activation/udev_rules = 1
-activation/verify_udev_operations = $LVM_VERIFY_UDEV
-activation/polling_interval = 0
-activation/snapshot_autoextend_percent = 50
-activation/snapshot_autoextend_threshold = 50
-activation/monitoring = 0
-allocation/wipe_signatures_when_zeroing_new_lvs = 0
+global/use_lvmetad = $LVM_TEST_LVMETAD
+global/use_lvmpolld = $LVM_TEST_LVMPOLLD
+log/activation = 1
+log/file = "$TESTDIR/debug.log"
+log/indent = 1
+log/level = 9
+log/overwrite = 1
+log/syslog = 0
+log/verbose = 0
 EOF
 	}
 


