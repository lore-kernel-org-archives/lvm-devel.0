From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:43 +0000 (GMT)
Subject: main - tests: ensure test defines its own etc dir
Message-ID: <20230623160943.A8B503858C36@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39d6a9601fd3d85ac4237a4731297cddfd5ecb1f
Commit:        39d6a9601fd3d85ac4237a4731297cddfd5ecb1f
Parent:        2cb43449ee4c92ae443bd72138fa91bb132aabf7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 20 21:56:28 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:06:22 2023 +0200

tests: ensure test defines its own etc dir

Compilation may configure it's own /etc path so ensure the test
has a defined location for access to this dir during testing.

Also prepare machine_id filei (with the use of uuidgen tool)
for the test.
---
 test/lib/aux.sh      | 3 ++-
 test/lib/inittest.sh | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5a3f0fe44..966707f23 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1538,7 +1538,7 @@ allocation/vdo_slab_size_mb = 128
 allocation/zero_metadata = 0
 backup/archive = 0
 backup/backup = 0
-devices/cache_dir = "$TESTDIR/etc"
+devices/cache_dir = "$LVM_SYSTEM_DIR"
 devices/default_data_alignment = 1
 devices/dir = "$DM_DEV_DIR"
 devices/md_component_detection = 0
@@ -1554,6 +1554,7 @@ global/cache_dump_executable = "$LVM_TEST_CACHE_DUMP_CMD"
 global/cache_repair_executable = "$LVM_TEST_CACHE_REPAIR_CMD"
 global/detect_internal_vg_cache_corruption = 1
 global/fallback_to_local_locking = 0
+global/etc = "$LVM_SYSTEM_DIR"
 global/locking_type=$LVM_TEST_LOCKING
 global/notify_dbus = 0
 global/si_unit_consistency = 1
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index c41f4c5b4..0becf2215 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -124,8 +124,9 @@ DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
 DM_DEBUG_WITH_LINE_NUMBERS=${DM_DEBUG_WITH_LINE_NUMBERS:-1}
 
 export DM_DEFAULT_NAME_MANGLING_MODE DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
-
 mkdir "$LVM_SYSTEM_DIR" "$DM_DEV_DIR"
+MACHINEID=$(uuidgen 2>/dev/null || echo "abcdefabcdefabcdefabcdefabcdefab")
+echo "${MACHINEID//-/}" > "$LVM_SYSTEM_DIR/machine-id"   # remove all '-'
 if test -n "$LVM_TEST_DEVDIR" ; then
 	test -d "$LVM_TEST_DEVDIR" || die "Test device directory LVM_TEST_DEVDIR=\"$LVM_TEST_DEVDIR\" is not valid."
 	DM_DEV_DIR=$LVM_TEST_DEVDIR

