From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:00 -0500
Subject: master - vdo: update vdo profile
Message-ID: <201901211155.x0LBt0nM024398@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=28f3125aaa1d7843d2ce01d25b172478b0836bba
Commit:        28f3125aaa1d7843d2ce01d25b172478b0836bba
Parent:        f87dd7b12745815c391257afc0b9631c708c2b6c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 18 16:59:43 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:38:00 2019 +0100

vdo: update vdo profile

---
 conf/vdo-small.profile |   41 ++++++++++++++++++++---------------------
 1 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/conf/vdo-small.profile b/conf/vdo-small.profile
index 0bd47b5..2044fc2 100644
--- a/conf/vdo-small.profile
+++ b/conf/vdo-small.profile
@@ -1,25 +1,24 @@
 # Demo configuration for 'VDO' using less memory.
-#
+# ~lvmconfig --type full | grep vdo
 
 allocation {
-	vdo_use_compression = 1
-	vdo_use_deduplication = 1
-	vdo_emulate_512_sectors = 0
-	vdo_block_map_cache_size_mb = 128
-	vdo_block_map_period = 16380
-	vdo_check_point_frequency = 0
-	vdo_use_sparse_index = 0
-	vdo_index_memory_size_mb = 256
-	vdo_use_read_cache = 0
-	vdo_read_cache_size_mb = 0
-	vdo_slab_size_mb = 2048
-
-	vdo_ack_threads = 1
-	vdo_bio_threads = 1
-	vdo_bio_rotation = 64
-	vdo_cpu_threads = 2
-	vdo_hash_zone_threads = 1
-	vdo_logical_threads = 1
-	vdo_physical_threads = 1
-	vdo_write_policy = "auto"
+	vdo_use_compression=1
+	vdo_use_deduplication=1
+	vdo_use_metadata_hints=1
+	vdo_minimum_io_size=4096
+	vdo_block_map_cache_size_mb=128
+	vdo_block_map_period=16380
+	vdo_check_point_frequency=0
+	vdo_use_sparse_index=0
+	vdo_index_memory_size_mb=256
+	vdo_slab_size_mb=2048
+	vdo_ack_threads=1
+	vdo_bio_threads=1
+	vdo_bio_rotation=64
+	vdo_cpu_threads=2
+	vdo_hash_zone_threads=1
+	vdo_logical_threads=1
+	vdo_physical_threads=1
+	vdo_write_policy="auto"
+	vdo_max_discard=1
 }


