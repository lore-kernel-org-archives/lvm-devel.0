From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:45 +0000 (GMT)
Subject: main - aux: add configuration for thin_restore and check_restore
Message-ID: <20230623160945.EA3103858C36@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1d5fba666ccc6f3189d492ba01896f79cf6176f
Commit:        a1d5fba666ccc6f3189d492ba01896f79cf6176f
Parent:        aed91e49aec64f8375583c7e0febd7b689e69e29
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 14:43:36 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:06:22 2023 +0200

aux: add configuration for thin_restore and check_restore

---
 test/lib/aux.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 966707f23..6e4a1d74e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1552,6 +1552,7 @@ global/abort_on_internal_errors = 1
 global/cache_check_executable = "$LVM_TEST_CACHE_CHECK_CMD"
 global/cache_dump_executable = "$LVM_TEST_CACHE_DUMP_CMD"
 global/cache_repair_executable = "$LVM_TEST_CACHE_REPAIR_CMD"
+global/cache_restore_executable = "$LVM_TEST_CACHE_RESTORE_CMD"
 global/detect_internal_vg_cache_corruption = 1
 global/fallback_to_local_locking = 0
 global/etc = "$LVM_SYSTEM_DIR"
@@ -1561,6 +1562,7 @@ global/si_unit_consistency = 1
 global/thin_check_executable = "$LVM_TEST_THIN_CHECK_CMD"
 global/thin_dump_executable = "$LVM_TEST_THIN_DUMP_CMD"
 global/thin_repair_executable = "$LVM_TEST_THIN_REPAIR_CMD"
+global/thin_restore_executable = "$LVM_TEST_THIN_RESTORE_CMD"
 global/use_lvmpolld = $LVM_TEST_LVMPOLLD
 global/use_lvmlockd = $LVM_TEST_LVMLOCKD
 log/activation = 1

