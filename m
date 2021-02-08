From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:44:59 +0000 (GMT)
Subject: main - thinpool: use lv_config_profil for crop_metadata
Message-ID: <20210208224459.47F2B384A02A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99e168162aeac82d8ed4634add4bdd05cf208315
Commit:        99e168162aeac82d8ed4634add4bdd05cf208315
Parent:        2be585b79c71b8f70c0252af5f09dbd5e6103030
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 4 23:26:08 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:18:44 2021 +0100

thinpool: use lv_config_profil for crop_metadata

Better support for thin-pools with individual profiles introduced
in the recent patch b4212be2e7e8797bbf8f9a166347659cc39ba075.
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 29c95ff63..1ab9627dc 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5585,7 +5585,7 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 			if (!(seg = get_only_segment_using_this_lv(lv)))
 				return_0;
 
-			max_metadata_size = get_thin_pool_max_metadata_size(cmd, vg->profile, &crop);
+			max_metadata_size = get_thin_pool_max_metadata_size(cmd, lv_config_profile(lv), &crop);
 
 			if (((uint64_t)lp->extents * vg->extent_size) > max_metadata_size) {
 				lp->extents = (max_metadata_size + vg->extent_size - 1) / vg->extent_size;


