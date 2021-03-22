From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:10 +0000 (GMT)
Subject: dev-next - thin: add extra protection
Message-ID: <20210322153910.8271F385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8cbe4a171e093aa7de9e16115b13ee3852545d07
Commit:        8cbe4a171e093aa7de9e16115b13ee3852545d07
Parent:        d682ad619a50827116fb83ff98efa0e5b8821956
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 09:13:20 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:34:57 2021 +0100

thin: add extra protection

Check explicitely created LV already has thin segment.
As currenlty it's the only user - this patch should have no impact.
---
 lib/metadata/lv_manip.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 84667f445..3fff66b18 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8500,8 +8500,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		if (lp->error_when_full)
 			lv->status |= LV_ERROR_WHEN_FULL;
-	} else if (pool_lv && lv_is_virtual(lv)) { /* going to be a thin volume */
-		seg = first_seg(lv);
+	} else if (pool_lv && lv_is_virtual(lv) && /* not yet thin LV */
+		   (seg = first_seg(lv)) &&
+		   seg_is_thin(seg)) { /* going to be a thin volume */
 		pool_seg = first_seg(pool_lv);
 		if (!(seg->device_id = get_free_pool_device_id(pool_seg)))
 			return_NULL;


