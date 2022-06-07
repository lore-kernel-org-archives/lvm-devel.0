From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  7 Jun 2022 15:15:54 +0000 (GMT)
Subject: main - vdo: fix conversion of vdo_slab_size_mb
Message-ID: <20220607151554.2156538133EC@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b070f366ba57a6eb24df03241284732db5047e9
Commit:        1b070f366ba57a6eb24df03241284732db5047e9
Parent:        c302903dbab1d5fd05b344c654bed83c9ecb69f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 31 22:48:38 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 7 17:14:08 2022 +0200

vdo: fix conversion of vdo_slab_size_mb

When converting VDO volume, the parameter vdo_slabSize was
incorrectly copied as vdo_blockMapCacheSize, however this parameter
is then no longer used for any table line creation so the wrong
value was only stored in metadata.

Also use just single get_kb_size_with_unit_ and remove it's duplicate
functionality with get_mb_size_with_unit_.

Use $VERB for vdo remove call.
---
 WHATS_NEW                 |  1 +
 scripts/lvm_import_vdo.sh | 15 +++------------
 2 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 844f69084..fed5faedc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+ Fix vdo_slab_size_mb value for converted VDO volume.
 
 Version 2.03.16 - 18th May 2022
 ===============================
diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index d01766743..c10b3b050 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -125,15 +125,6 @@ get_kb_size_with_unit_() {
 	esac
 }
 
-get_mb_size_with_unit_() {
-	case "$1" in
-	*[mM]) echo $(( ${1%[mM]} )) ;;
-	*[gG]) echo $(( ${1%[gG]} * 1024 )) ;;
-	*[tT]) echo $(( ${1%[tT]} * 1024 * 1024 )) ;;
-	*[pP]) echo $(( ${1%[pP]} * 1024 * 1024 * 1024 )) ;;
-	esac
-}
-
 # Figure out largest possible extent size usable for VG
 # $1   physical size
 # $2   logical size
@@ -328,12 +319,12 @@ allocation {
 	vdo_use_deduplication = $(get_enabled_value_ "$vdo_deduplication")
 	vdo_use_metadata_hints=1
 	vdo_minimum_io_size = $vdo_logicalBlockSize
-	vdo_block_map_cache_size_mb = $(get_mb_size_with_unit_ "$vdo_blockMapCacheSize")
+	vdo_block_map_cache_size_mb = $(( $(get_kb_size_with_unit_ "$vdo_blockMapCacheSize") / 1024 ))
 	vdo_block_map_period = $vdo_blockMapPeriod
 	vdo_check_point_frequency = $vdo_indexCfreq
 	vdo_use_sparse_index = $(get_enabled_value_ "$vdo_indexSparse")
 	vdo_index_memory_size_mb = $(awk "BEGIN {print $vdo_indexMemory * 1024}")
-	vdo_slab_size_mb = $(get_mb_size_with_unit_ "$vdo_blockMapCacheSize")
+	vdo_slab_size_mb = $(( $(get_kb_size_with_unit_ "$vdo_blockMapCacheSize") / 1024 ))
 	vdo_ack_threads = $vdo_ackThreads
 	vdo_bio_threads = $vdo_bioThreads
 	vdo_bio_rotation = $vdo_bioRotationInterval
@@ -417,7 +408,7 @@ EOF
 	# Note: that this is spelled OPPOSITE the other $IS_LV checks.
 	if [ "$IS_LV" = "1" ]; then
 		verbose "Removing now-unused VDO entry from VDO config."
-		dry "$VDO" remove $VDOCONF --force --verbose --name "$VDONAME"
+		dry "$VDO" remove $VDOCONF $VERB --force --name "$VDONAME"
 	fi
 
 	rm -fr "$TEMPDIR"

