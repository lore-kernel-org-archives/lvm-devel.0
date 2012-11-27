From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 Nov 2012 13:28:45 +0000 (UTC)
Subject: master - thin: fix property discard for lvm2api
Message-ID: <20121127132845.80C8D1405@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0387e70d7698be559d2d7ca8f9cdb8882be7ad0b
Commit:        0387e70d7698be559d2d7ca8f9cdb8882be7ad0b
Parent:        09b7ceea95edb2b54074cbd5d3b2009b5bf1dd4e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 27 11:02:49 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 27 14:09:49 2012 +0100

thin: fix property discard for lvm2api

Discards property is string and may have these values:
  ignore, nopassdown, passdown
---
 WHATS_NEW                |    1 +
 lib/metadata/lv.c        |    5 +++++
 lib/metadata/lv.h        |    1 +
 lib/report/columns.h     |    2 +-
 lib/report/properties.c  |    2 +-
 test/api/thin_percent.c  |   10 ++++++++++
 test/api/thin_percent.sh |    2 +-
 7 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1655a7e..98b5f9e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix lvm2api and return lvseg discards property as string.
   Allow forced vgcfgrestore of lvm2 metadata with thin volumes.
   Recognise STEC skd devices in filter.
   Recognise Violin Memory vtms devices in filter.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4032f34..34b428a 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -123,6 +123,11 @@ char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg)
 	return dm_pool_strdup(mem, seg->segtype->ops->name(seg));
 }
 
+char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	return  dm_pool_strdup(mem, get_pool_discards_name(seg->discards));
+}
+
 uint64_t lvseg_chunksize(const struct lv_segment *seg)
 {
 	uint64_t size;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 0daab62..838b002 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -74,6 +74,7 @@ uint64_t lvseg_start(const struct lv_segment *seg);
 uint64_t lvseg_size(const struct lv_segment *seg);
 uint64_t lvseg_chunksize(const struct lv_segment *seg);
 char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index c83a086..87b22ae 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -141,7 +141,7 @@ FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, region_size, "For mirror
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunksize, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "#Thins", list, 4, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
-FIELD(SEGS, seg, NUM, "Discards", list, 8, discards, discards, "For thin pools, how discards are handled.", 0)
+FIELD(SEGS, seg, STR, "Discards", list, 8, discards, discards, "For thin pools, how discards are handled.", 0)
 FIELD(SEGS, seg, NUM, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
 FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index fe197f5..0cd39ba 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -287,7 +287,7 @@ GET_LVSEG_NUM_PROPERTY_FN(zero, lvseg->zero_new_blocks)
 #define _zero_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(transaction_id, lvseg->transaction_id)
 #define _transaction_id_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(discards, lvseg->discards)
+GET_LVSEG_STR_PROPERTY_FN(discards, lvseg_discards_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _discards_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start, lvseg_start(lvseg))
 #define _seg_start_set _not_implemented_set
diff --git a/test/api/thin_percent.c b/test/api/thin_percent.c
index 2c8b19b..ae511df 100644
--- a/test/api/thin_percent.c
+++ b/test/api/thin_percent.c
@@ -23,6 +23,8 @@ int main(int argc, char *argv[])
 	vg_t vg;
 	lv_t lv;
 	struct lvm_property_value v;
+	struct dm_list *lvsegs;
+	struct lvm_lvseg_list *lvl;
 
 	handle = lvm_init(NULL);
 	assert(handle);
@@ -33,6 +35,14 @@ int main(int argc, char *argv[])
 	lv = lvm_lv_from_name(vg, "pool");
 	assert(lv);
 
+	lvsegs = lvm_lv_list_lvsegs(lv);
+	assert(lvsegs && (dm_list_size(lvsegs) == 1));
+	dm_list_iterate_items(lvl, lvsegs) {
+		v = lvm_lvseg_get_property(lvl->lvseg, "discards");
+		assert(v.is_valid && v.is_string);
+		assert(strcmp(v.value.string, "passdown") == 0);
+	}
+
 	v = lvm_lv_get_property(lv, "data_percent");
 	assert(v.is_valid);
 	assert(v.value.integer == 25 * PERCENT_1);
diff --git a/test/api/thin_percent.sh b/test/api/thin_percent.sh
index 9287cf3..e14e807 100644
--- a/test/api/thin_percent.sh
+++ b/test/api/thin_percent.sh
@@ -30,7 +30,7 @@ dd if=/dev/urandom of="$DM_DEV_DIR/$vg/thin" count=2 bs=256K
 lvcreate -s $vg/thin -n snap
 dd if=/dev/urandom of="$DM_DEV_DIR/$vg/snap" count=3 bs=256K
 
-lvs $vg
+lvs -o+discards $vg
 
 aux apitest thin_percent $vg
 


