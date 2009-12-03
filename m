From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  3 Dec 2009 13:17:33 -0500
Subject: [PATCH] Remove incorrect code at the bottom of _lv_reduce.
Message-ID: <1259864253-19362-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Makes no sense to be calling lv_setup if we're removing an LV.
I suspect this code always succeeds and this is why it does not
matter here.  Even so, it is misleading / incorrect to be doing
this so remove it.
NOTE: Untested.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv_manip.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c440278..8a8a44e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -435,9 +435,6 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 	/* Remove the LV if it is now empty */
 	if (!lv->le_count && !unlink_lv_from_vg(lv))
 		return_0;
-	else if (lv->vg->fid->fmt->ops->lv_setup &&
-		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
-		return_0;
 
 	return 1;
 }
-- 
1.6.0.6


