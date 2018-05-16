From: Ricky Elrod <relrod@redhat.com>
Date: Wed, 16 May 2018 18:14:05 -0400
Subject: [PATCH] Fix grammar in output - "less then" -> "less than"
Message-ID: <CAMuUyjQmhqvda_VGC2RcmEP1PqWm3Rpk35BBNtp9mDDLZmN-3A@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

commit 28a8e90fd86069d86da389e4c363ec84efc57f9f (HEAD -> master)
Author: Rick Elrod <relrod@redhat.com>
Date:   Wed May 16 17:53:38 2018 -0400

    Fix grammar in output - "less then" -> "less than"

    This minor patch fixes grammar in a few messages which get
    printed to users. It also fixes the same grammar mistake in
    several comments.

    Signed-off-by: Rick Elrod <relrod@redhat.com>

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 2a54682e7..3ed8ce8b7 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -184,7 +184,7 @@ int update_cache_pool_params(struct cmd_context *cmd,
                         * keep user informed he might be using things
in untintended direction
                         */
                        log_print_unless_silent("Using %s chunk size
instead of default %s, "
-                                               "so cache pool has
less then " FMTu64 " chunks.",
+                                               "so cache pool has
less than " FMTu64 " chunks.",
                                                display_size(cmd,
min_chunk_size),
                                                display_size(cmd, *chunk_size),
                                                max_chunks);
@@ -193,7 +193,7 @@ int update_cache_pool_params(struct cmd_context *cmd,
                        log_verbose("Setting chunk size to %s.",
                                    display_size(cmd, *chunk_size));
        } else if (*chunk_size < min_chunk_size) {
-               log_error("Chunk size %s is less then required minimal
chunk size %s "
+               log_error("Chunk size %s is less than required minimal
chunk size %s "
                          "for a cache pool of %s size and limit "
FMTu64 " chunks.",
                          display_size(cmd, *chunk_size),
                          display_size(cmd, min_chunk_size),
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1cbaf958e..260984056 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1050,7 +1050,7 @@ uint32_t extents_from_size(struct cmd_context
*cmd, uint64_t size,

        if (size > (uint64_t) MAX_EXTENT_COUNT * extent_size) {
                log_error("Volume too large (%s) for extent size %s. "
-                         "Upper limit is less then %s.",
+                         "Upper limit is less than %s.",
                          display_size(cmd, size),
                          display_size(cmd, (uint64_t) extent_size),
                          display_size(cmd, (uint64_t) MAX_EXTENT_COUNT *
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 3dfbcc11f..d2d1384bf 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -228,7 +228,7 @@ int pool_metadata_min_threshold(const struct
lv_segment *pool_seg)
         *
         * In the metadata LV there should be minimum from either 4MiB
of free space
         * or at least 25% of free space, which applies when the size
of thin pool's
-        * metadata is less then 16MiB.
+        * metadata is less than 16MiB.
         */
        const dm_percent_t meta_min = DM_PERCENT_1 * 25;
        dm_percent_t meta_free = dm_make_percent(((4096 * 1024) >>
SECTOR_SHIFT),
diff --git a/test/shell/lvconvert-repair-mirror.sh
b/test/shell/lvconvert-repair-mirror.sh
index 02772213c..b0c199df0 100644
--- a/test/shell/lvconvert-repair-mirror.sh
+++ b/test/shell/lvconvert-repair-mirror.sh
@@ -54,7 +54,7 @@ dd if=/dev/zero of=mnt/zero bs=4K count=100
conv=fdatasync 2>err &

 PERCENT=$(get lv_field $vg/$lv1 copy_percent)
 PERCENT=${PERCENT%%\.*}  # cut decimal
-# and check less then 50% mirror is in sync (could be unusable delay_dev ?)
+# and check less than 50% mirror is in sync (could be unusable delay_dev ?)
 test "$PERCENT" -lt 50 || skip
 #lvs -a -o+devices $vg

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh
b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 212df4b38..3731bf6bf 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -75,7 +75,7 @@ lvcreate -L32M -n $lv3 $vg
 lvchange -an $vg/thin $vg/thin2 $vg/pool

 # Filling 2M metadata volume
-# (Test for less then 25% free space in metadata)
+# (Test for less than 25% free space in metadata)
 fake_metadata_ 400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"

@@ -89,7 +89,7 @@ fail lvcreate -V20 $vg/pool
 lvchange -an $vg/pool

 # Consume more then (100% - 4MiB) out of 32MiB metadata volume  (>87.5%)
-# (Test for less then 4MiB free space in metadata, which is less then 25%)
+# (Test for less than 4MiB free space in metadata, which is less than 25%)
 fake_metadata_ 7400 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv2"
 # Swap volume with restored fake metadata


