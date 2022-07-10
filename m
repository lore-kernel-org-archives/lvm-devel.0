From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:12 +0000 (GMT)
Subject: main - vdo: fix conversion of vdo_slab_size_mb 2nd
Message-ID: <20220710232212.B67D2385737B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2667bc25bccaf0f70cc2ded0fd3f25a79cb4f6c
Commit:        d2667bc25bccaf0f70cc2ded0fd3f25a79cb4f6c
Parent:        92b4fcf57f3c6d212d06b72b097e1a06e6efb84b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 11 01:07:24 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

vdo: fix conversion of vdo_slab_size_mb 2nd

Patch 1b070f366ba57a6eb24df03241284732db5047e9 should have
been already fixing this issue but since it the incorrect
patch rebasing the change to vdo_slabSize got lost.
So again now with explicit one-line patch.
---
 scripts/lvm_import_vdo.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index c10b3b050..c4c1d152e 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -324,7 +324,7 @@ allocation {
 	vdo_check_point_frequency = $vdo_indexCfreq
 	vdo_use_sparse_index = $(get_enabled_value_ "$vdo_indexSparse")
 	vdo_index_memory_size_mb = $(awk "BEGIN {print $vdo_indexMemory * 1024}")
-	vdo_slab_size_mb = $(( $(get_kb_size_with_unit_ "$vdo_blockMapCacheSize") / 1024 ))
+	vdo_slab_size_mb = $(( $(get_kb_size_with_unit_ "$vdo_slabSize") / 1024 ))
 	vdo_ack_threads = $vdo_ackThreads
 	vdo_bio_threads = $vdo_bioThreads
 	vdo_bio_rotation = $vdo_bioRotationInterval

