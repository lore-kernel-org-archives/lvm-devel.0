From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 25 Jun 2018 09:10:02 -0400
Subject: master - cache: use new api function
Message-ID: <201806251310.w5PDA2lL031425@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=357e9f9572361ec2ea89ca0bf165a30545fa747f
Commit:        357e9f9572361ec2ea89ca0bf165a30545fa747f
Parent:        9c0d92d9575da63b38685c385917644d9ac9445d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 23 11:47:33 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 25 15:07:55 2018 +0200

cache: use new api function

---
 lib/metadata/cache_manip.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index e347144..4132e2f 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -620,10 +620,9 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	if (!(cache_seg->segtype = get_segtype_from_string(corigin_lv->vg->cmd, SEG_TYPE_NAME_CACHE)))
 		return_0;
 
-	if (!(cache_seg->areas = dm_pool_zalloc(cache_lv->vg->vgmem, sizeof(*cache_seg->areas))))
+	if (!add_lv_segment_areas(cache_seg, 1))
 		return_0;
 
-	cache_seg->area_count = 1;
 	if (!set_lv_segment_area_lv(cache_seg, 0, cache_lv, 0, 0))
 		return_0;
 


