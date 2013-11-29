From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 29 Nov 2013 18:15:33 -0500 (EST)
Subject: [LVM2 PATCH v2] incorrect calculation of snapshot space (fwd)
Message-ID: <alpine.LRH.2.02.1311291814060.16583@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

This is the patch for incorrect calculation of snapshot space in lvm2. 
This is the updated that checks target driver version.

We need to get this into RHEL6.5 z-stream as soon as possible because this 
bug is a regression introduced in RHEL6.5.

I created this bug for the issue: 
https://bugzilla.redhat.com/show_bug.cgi?id=1035871

The bug can be tested with this script:
#!/bin/sh
VG=vg1
lvremove -f $VG/origin
set -e
lvcreate -L 2143289344b -n origin $VG
lvcreate -n snap -c 8k -L 2304M -s $VG/origin
dd if=/dev/zero of=/dev/$VG/snap bs=1M count=2044 oflag=direct


The bug happens when these two conditions are met
* origin size is divisible by (chunk_size/16) - so that the last metadata 
  area is filled completely
* the miscalculated snapshot metadata size is divisible by extent size - 
  so that there is no padding to extent boundary which would otherwise 
  save us

Mikulas
---
 lib/metadata/snapshot_manip.c |   52 +++++++++++++++++++++++++++++++++---------
 1 file changed, 41 insertions(+), 11 deletions(-)

Index: LVM2.2.02.104/lib/metadata/snapshot_manip.c
===================================================================
--- LVM2.2.02.104.orig/lib/metadata/snapshot_manip.c	2013-11-28 19:11:00.000000000 +0100
+++ LVM2.2.02.104/lib/metadata/snapshot_manip.c	2013-11-30 00:08:29.000000000 +0100
@@ -31,7 +31,35 @@ int lv_is_cow(const struct logical_volum
 	return (!lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
 }
 
-static uint64_t _cow_max_size(uint64_t origin_size, uint32_t chunk_size)
+/*
+ * Some kernels have a bug that they may leak space in the snapshot on crash.
+ * If the kernel is buggy, we add some extra space.
+ */
+static uint64_t _cow_extra_chunks(struct cmd_context *cmd, uint64_t n_chunks)
+{
+	static int space_leak_bug_fixed = -1;
+	if (space_leak_bug_fixed < 0) {
+		uint32_t maj, min, patchlevel;
+		if (!target_version("snapshot", &maj, &min, &patchlevel) &&
+		    (!module_present(cmd, "snapshot") ||
+		     !target_version("snapshot", &maj, &min, &patchlevel))) {
+			space_leak_bug_fixed = 0;
+			goto x;
+		}
+		space_leak_bug_fixed =
+			(maj > 1 ||
+			(maj == 1 && (min >= 12 ||
+				     (min == 10 && patchlevel >= 2))));
+x:;
+	}
+
+	if (space_leak_bug_fixed)
+		return 0;
+
+	return (n_chunks + 63) / 64;
+}
+
+static uint64_t _cow_max_size(struct cmd_context *cmd, uint64_t origin_size, uint32_t chunk_size)
 {
 	/* Snapshot disk layout:
 	 *    COW is divided into chunks
@@ -40,21 +68,23 @@ static uint64_t _cow_max_size(uint64_t o
 	 *        3rd. chunk is the 1st. data chunk
 	 */
 
-	/* Size of metadata for snapshot in sectors */
-	uint64_t mdata_size = ((origin_size + chunk_size - 1) / chunk_size * 16 + 511) >> SECTOR_SHIFT;
+	uint64_t origin_chunks = (origin_size + chunk_size - 1) / chunk_size;
+
+	uint64_t chunks_per_metadata_area = (uint64_t)chunk_size << (SECTOR_SHIFT - 4);
 
-	/* Sum all chunks - header + metadata size + origin size (aligned on chunk boundary) */
-	uint64_t size = chunk_size +
-		((mdata_size + chunk_size - 1) & ~(uint64_t)(chunk_size - 1)) +
-		((origin_size + chunk_size - 1) & ~(uint64_t)(chunk_size - 1));
+	/*
+	 * Note: if origin_chunks is divisible by chunks_per_metadata_area, we
+	 * need one extra metadata chunk as a terminator.
+	 */
+	uint64_t metadata_chunks = (origin_chunks + chunks_per_metadata_area) / chunks_per_metadata_area;
 
-	/* Does not overflow since size is in sectors (9 bits) */
-	return size;
+	uint64_t n_chunks = 1 + origin_chunks + metadata_chunks;
+	return (n_chunks + _cow_extra_chunks(cmd, n_chunks)) * chunk_size;
 }
 
 uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size)
 {
-	uint64_t size = _cow_max_size(origin->size, chunk_size);
+	uint64_t size = _cow_max_size(origin->vg->cmd, origin->size, chunk_size);
 	uint32_t extent_size = origin->vg->extent_size;
 	uint64_t max_size = (uint64_t) MAX_EXTENT_COUNT * extent_size;
 
@@ -70,7 +100,7 @@ uint32_t cow_max_extents(const struct lo
 int lv_is_cow_covering_origin(const struct logical_volume *lv)
 {
 	return lv_is_cow(lv) &&
-		(lv->size >= _cow_max_size(origin_from_cow(lv)->size, find_snapshot(lv)->chunk_size));
+		(lv->size >= _cow_max_size(lv->vg->cmd, origin_from_cow(lv)->size, find_snapshot(lv)->chunk_size));
 }
 
 int lv_is_visible(const struct logical_volume *lv)


