From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:21 +0200
Subject: [PATCH 03/11] Replace ACTIVATE
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <f4375bb058fc7b880ea69c837fc9aa557db5cca2.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mirror/mirrored.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 50e79c3..49b39e7 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -360,8 +360,7 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 	 * Use clustered mirror log for non-exclusive activation
 	 * in clustered VG.
 	 */
-	if ((!(seg->lv->status & ACTIVATE_EXCL) &&
-	      (vg_is_clustered(seg->lv->vg))))
+	if (!laopts->exclusive && vg_is_clustered(seg->lv->vg))
 		clustered = 1;
 
 	if (seg->log_lv) {
-- 
1.7.5.2


