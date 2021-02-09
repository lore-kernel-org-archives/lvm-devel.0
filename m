From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  9 Feb 2021 14:06:46 +0000 (GMT)
Subject: stable-2.02 - thinpool: use lv_config_profil for crop_metadata
Message-ID: <20210209140646.91BA33836C73@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cfb9bf13c7073937591fa4dc4a0a93a975016bb1
Commit:        cfb9bf13c7073937591fa4dc4a0a93a975016bb1
Parent:        18677e24c1ab6e9dff36c048d9e3f6a7fe541c4b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 4 23:26:08 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 9 14:45:29 2021 +0100

thinpool: use lv_config_profil for crop_metadata

Better support for thin-pools with individual profiles introduced
in the recent patch b4212be2e7e8797bbf8f9a166347659cc39ba075.
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e48e5d18f..33624148c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5209,7 +5209,7 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 			if (!(seg = get_only_segment_using_this_lv(lv)))
 				return_0;
 
-			max_metadata_size = get_thin_pool_max_metadata_size(cmd, vg->profile, &crop);
+			max_metadata_size = get_thin_pool_max_metadata_size(cmd, lv_config_profile(lv), &crop);
 
 			if (((uint64_t)lp->extents * vg->extent_size) > max_metadata_size) {
 				lp->extents = (max_metadata_size + vg->extent_size - 1) / vg->extent_size;


