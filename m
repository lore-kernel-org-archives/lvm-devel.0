From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:03 +0100
Subject: [PATCH 03/23] Simple indent changes to fit 80 chars per line
In-Reply-To: <1259581043-15308-3-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-4-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 69b654d..3071772 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -971,7 +971,8 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		/* Add any LVs used by this segment */
 		for (s = 0; s < seg->area_count; s++)
 			if ((seg_type(seg, s) == AREA_LV) &&
-			    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s), NULL)))
+			    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
+						   NULL)))
 				return_0;
 	}
 
@@ -1018,7 +1019,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return 1;
 
 	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
-		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.", lv->name, layer);
+		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.",
+			  lv->name, layer);
 		return 0;
 	}
 
-- 
1.6.5.3


