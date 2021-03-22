From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:09 +0000 (GMT)
Subject: dev-next - cleanup: simplier check first
Message-ID: <20210322153909.5D2493854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d682ad619a50827116fb83ff98efa0e5b8821956
Commit:        d682ad619a50827116fb83ff98efa0e5b8821956
Parent:        a481fdaa3529a85e0cde652f79b98b2337c296cb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 08:56:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:34:57 2021 +0100

cleanup: simplier check first

---
 lib/metadata/lv_manip.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 12b1505df..84667f445 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8471,10 +8471,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	/* Unlock memory if possible */
 	memlock_unlock(vg->cmd);
 
-	if (segtype_is_vdo(create_segtype) && pool_lv) {
+	if (pool_lv && segtype_is_vdo(create_segtype))
 		if (!set_lv_segment_area_lv(first_seg(lv), 0, pool_lv, 0, LV_VDO_POOL))
 			return_NULL;
-	}
 
 	if (lv_is_cache_pool(lv)) {
 		if (!cache_set_params(first_seg(lv),


