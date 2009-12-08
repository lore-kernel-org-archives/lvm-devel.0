From: Milan Broz <mbroz@redhat.com>
Date: Tue,  8 Dec 2009 16:39:50 +0100
Subject: [PATCH 07/10] Call explicitly suspend for temporary mirror layer.
In-Reply-To: <cover.1260284754.git.mbroz@redhat.com>
References: <cover.1260284754.git.mbroz@redhat.com>
Message-ID: <d42cc8e5e331af345e4e7b2fbdd901cc5bada806.1260284754.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The memlock_inc() fix is wrong, memlock count is not
propagated to long living process (clvmd) and just
it underflow there.
Also suspend is needed to pre-load precommited metadata
on other nodes (remapping to error taget in this case).

With explicit suspend we generate lock request and code
can update memlock count.

(Infinitely "locked" memory caused that fs_unlock() was not
called properly and on cluster nodes remains
old links in /dev/mapper for not active devices.)

(N.B. failing of suspend call here is not handled as fatal
error - the LV is going to be removed later anyway.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/mirror.c |   28 +++++++++++-----------------
 1 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 3d757c2..3591df3 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -603,6 +603,14 @@ static int _remove_mirror_images(struct logical_volume *lv,
 		return 0;
 	}
 
+	/*
+	 * Explicitly suspend temporary LV
+	 * This balance memlock_inc() calls and also causes cluster
+	 * lock to properly propagate precommited metadata into dm table.
+	 */
+	if (lv1 && !suspend_lv(lv1->vg->cmd, lv1))
+		log_error("Problem suspending temporary LV %s", lv1->name);
+
 	if (!vg_commit(mirrored_seg->lv->vg)) {
 		resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv);
 		return 0;
@@ -616,23 +624,9 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	 * As it's now detached from mirrored_seg->lv we must resume it
 	 * explicitly.
 	 */
-	if (lv1) {
-		if (!resume_lv(lv1->vg->cmd, lv1)) {
-			log_error("Problem resuming temporary LV, %s", lv1->name);
-			return 0;
-		}
-
-		/*
-		 * The code above calls a suspend_lv once, however we now need
-		 * to resume 2 LVs, due to image removal: the mirror image
-		 * itself here, and now the remaining mirror LV. Since
-		 * suspend_lv/resume_lv call memlock_inc/memlock_dec and these
-		 * need to be balanced, we need to call an extra memlock_inc()
-		 * here to balance for the this extra resume -- the following
-		 * one could otherwise either deadlock due to suspended
-		 * devices, or alternatively drop memlock_count below 0.
-		 */
-		memlock_inc();
+	if (lv1 && !resume_lv(lv1->vg->cmd, lv1)) {
+		log_error("Problem resuming temporary LV, %s", lv1->name);
+		return 0;
 	}
 
 	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
-- 
1.6.5.4


