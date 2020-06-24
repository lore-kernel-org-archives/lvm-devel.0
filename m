From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:43 +0000 (GMT)
Subject: master - cov: use 64bit arithmetic
Message-ID: <20200624130243.C49723939C28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dccaab3d79c0439fff26fd4d98e7f55be5a14318
Commit:        dccaab3d79c0439fff26fd4d98e7f55be5a14318
Parent:        bc39d5bec6fea787a8d8d16fa484084b7d2a7c29
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 10 23:36:06 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

cov: use 64bit arithmetic

Although values of VDO block_map_cache_size, index_memory_size, slab_size
should not overflow here - use proper 64bit math.
---
 lib/report/report.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 74ec74cf7..979cbee52 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3961,7 +3961,7 @@ static int _vdo_ ## vdo_field_name ## _disp (struct dm_report *rh, struct dm_poo
 	if (!seg_is_vdo_pool(seg)) \
 		return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64)); \
 \
-	size = seg->vdo_params.vdo_field_name ## _mb * (1024 * 1024 >> SECTOR_SHIFT); \
+	size = seg->vdo_params.vdo_field_name ## _mb * (UINT64_C(1024) * 1024 >> SECTOR_SHIFT); \
 \
 	return _size64_disp(rh, mem, field, &size, private);\
 }


