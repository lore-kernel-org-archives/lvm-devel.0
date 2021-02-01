From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 13:38:21 +0000 (GMT)
Subject: stable-2.02 - pool: limit pmspare to 16GiB
Message-ID: <20210201133821.B19493836C59@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=72b12033a9ffb45b858d738b956dc39f71782ecd
Commit:        72b12033a9ffb45b858d738b956dc39f71782ecd
Parent:        586bac0b10d3c1757708129433e8401a4797a7ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 29 23:20:18 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 14:35:53 2021 +0100

pool: limit pmspare to 16GiB

There is not much point to let allocate more then this size
even when i.e. converted LV is bigger then 16GiB (%extent_size)
ATM neither thin-pool nor cache-pool supports bigger metadata.
---
 lib/metadata/pool_manip.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index ead302155..54b824a5e 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -683,6 +683,8 @@ static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg
 int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
 			       struct dm_list *pvh, int poolmetadataspare)
 {
+	/* Max usable size of any spare volume is currently 16GiB rouned to extent size */
+	const uint64_t MAX_SIZE = (UINT64_C(2 * 16) * 1024 * 1024 + vg->extent_size - 1) / vg->extent_size;
 	struct logical_volume *lv = vg->pool_metadata_spare_lv;
 	uint32_t seg_mirrors;
 	struct lv_segment *seg;
@@ -692,8 +694,11 @@ int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
 		/* Find maximal size of metadata LV */
 		dm_list_iterate_items(lvl, &vg->lvs)
 			if (lv_is_pool_metadata(lvl->lv) &&
-			    (lvl->lv->le_count > extents))
+			    (lvl->lv->le_count > extents)) {
 				extents = lvl->lv->le_count;
+				if (extents >= MAX_SIZE)
+					break;
+			}
 
 	if (!poolmetadataspare) {
 		/* TODO: Not showing when lvm.conf would define 'n' ? */
@@ -704,6 +709,9 @@ int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
 		return 1;
 	}
 
+	if (extents > MAX_SIZE)
+		extents = MAX_SIZE;
+
 	if (!lv) {
 		if (!_alloc_pool_metadata_spare(vg, extents, pvh))
 			return_0;


