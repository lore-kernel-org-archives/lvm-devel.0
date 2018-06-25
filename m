From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 25 Jun 2018 09:09:59 -0400
Subject: master - cache: set areas count prior using it
Message-ID: <201806251309.w5PD9xfc031408@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8949903fbb0be370ae7c5d71617d5084e8dddad9
Commit:        8949903fbb0be370ae7c5d71617d5084e8dddad9
Parent:        6b3a4aac0954264c3f054e7dd6c87babca77c244
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 23 11:35:34 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 25 15:07:32 2018 +0200

cache: set areas count prior using it

Set correct counter, so it's not failing on internal error check.
---
 lib/metadata/cache_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index c3bd2ec..e347144 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -623,10 +623,10 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	if (!(cache_seg->areas = dm_pool_zalloc(cache_lv->vg->vgmem, sizeof(*cache_seg->areas))))
 		return_0;
 
+	cache_seg->area_count = 1;
 	if (!set_lv_segment_area_lv(cache_seg, 0, cache_lv, 0, 0))
 		return_0;
 
-	cache_seg->area_count = 1;
 	corigin_lv->le_count = cache_lv->le_count;
 	corigin_lv->size = cache_lv->size;
 	corigin_lv->status |= LV_PENDING_DELETE;


