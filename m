From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Nov 2014 08:37:08 +0000 (UTC)
Subject: master - thin: add missing 64KB rounding
Message-ID: <20141126083708.BBCC26055B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2de11c9e9e9513fb7d9ab0323370e584d3d3acde
Commit:        2de11c9e9e9513fb7d9ab0323370e584d3d3acde
Parent:        13e2049c32f016cd7f2d93d98fd47178f139fc81
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 26 09:27:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 26 09:29:25 2014 +0100

thin: add missing 64KB rounding

When chunk size needs to be estimated, the code missed to round
to proper 64kb boundaries  (or power of 2 for older thin pool driver).
So for some data and metadata size (i.e. 10GB and 4MB) it resulted
in incorrect chunk size (not being a multiple of 64KB)

Fix it by adding proper rounding and also use 1 routine for 2 places
where the same calculation is made.

Fix also incorrect printed warning that has used 'ffs()'
(which returns first 'least significant' bit in word)
and it was not really giving any useful size info and replace it
with properly estimated chunk size.
---
 WHATS_NEW                   |    1 +
 lib/metadata/thin_manip.c   |   39 ++++++++++++++++++++++++++++++++++-----
 test/shell/lvcreate-thin.sh |   16 ++++++++++++++++
 3 files changed, 51 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e279c38..bd7b7f9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.114 - 
 =====================================
+  Fix missing rounding to 64KB when estimating optimal thin pool chunk size.
   Fix typo in clvmd initscript causing CLVMD_STOP_TIMEOUT variable to be ignored.
   Fix size in pvresize "Resizing to ..." verbose msg to show proper result size.
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index b4aec73..e617b3c 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -394,6 +394,33 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	return ret;
 }
 
+/* Estimate thin pool chunk size from data and metadata size (in sector units) */
+static size_t _estimate_chunk_size(uint64_t data_size, uint64_t metadata_size, int attr)
+{
+	/*
+	 * nr_pool_blocks = data_size / metadata_size
+	 * chunk_size = nr_pool_blocks * 64b / sector_size
+	 */
+	size_t chunk_size = data_size / (metadata_size * (SECTOR_SIZE / 64));
+
+	if (attr & THIN_FEATURE_BLOCK_SIZE) {
+		/* Round up to 64KB */
+		chunk_size += DM_THIN_MIN_DATA_BLOCK_SIZE - 1;
+		chunk_size &= ~(size_t)(DM_THIN_MIN_DATA_BLOCK_SIZE - 1);
+	} else {
+		/* Round up to nearest power of 2 */
+		chunk_size--;
+		chunk_size |= chunk_size >> 1;
+		chunk_size |= chunk_size >> 2;
+		chunk_size |= chunk_size >> 4;
+		chunk_size |= chunk_size >> 8;
+		chunk_size |= chunk_size >> 16;
+		chunk_size++;
+	}
+
+	return chunk_size;
+}
+
 int update_thin_pool_params(const struct segment_type *segtype,
 			    struct volume_group *vg,
 			    unsigned attr, int passed_args,
@@ -465,18 +492,20 @@ int update_thin_pool_params(const struct segment_type *segtype,
 				    display_size(cmd, *chunk_size));
 		} else if (pool_metadata_size > (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2)) {
 			/* Suggest bigger chunk size */
-			estimate_chunk_size = (uint64_t) pool_data_extents * extent_size /
-				(DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2 * (SECTOR_SIZE / UINT64_C(64)));
+			estimate_chunk_size =
+				_estimate_chunk_size((uint64_t) pool_data_extents * extent_size,
+						     (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2), attr);
 			log_warn("WARNING: Chunk size is too small for pool, suggested minimum is %s.",
-				 display_size(cmd, UINT64_C(1) << (ffs(estimate_chunk_size) + 1)));
+				 display_size(cmd, estimate_chunk_size));
 		}
 
 		/* Round up to extent size silently */
 		if (pool_metadata_size % extent_size)
 			pool_metadata_size += extent_size - pool_metadata_size % extent_size;
 	} else {
-		estimate_chunk_size = (uint64_t) pool_data_extents * extent_size /
-			(pool_metadata_size * (SECTOR_SIZE / UINT64_C(64)));
+		estimate_chunk_size =
+			_estimate_chunk_size((uint64_t) pool_data_extents * extent_size,
+					     pool_metadata_size, attr);
 		if (estimate_chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
 			estimate_chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
 		else if (estimate_chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 0433ac8..2884d53 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -261,4 +261,20 @@ lvcreate -L10G --chunksize 256 -T $vg/pool1
 lvcreate -L60G --chunksize 1024 -T $vg/pool2
 check lv_field $vg/pool1_tmeta size "2.50m"
 check lv_field $vg/pool2_tmeta size "3.75m"
+lvremove -ff $vg
+
+# Block size of multiple 64KB needs >= 1.4
+if aux have_thin 1 4 0 ; then
+# Test chunk size is rounded to 64KB boundary
+lvcreate -L10G --poolmetadatasize 4M -T $vg/pool
+check lv_field $vg/pool chunk_size "192.00k"
+fi
+# Old thinpool target required rounding to power of 2
+aux lvmconf "global/thin_disabled_features = [ \"block_size\" ]"
+lvcreate -L10G --poolmetadatasize 4M -T $vg/pool_old
+check lv_field $vg/pool_old chunk_size "256.00k"
+lvremove -ff $vg
+# reset
+#aux lvmconf "global/thin_disabled_features = []"
+
 vgremove -ff $vg


