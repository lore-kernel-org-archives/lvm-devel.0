From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  5 Apr 2010 15:51:35 -0400
Subject: [PATCH 1/5] Add pv to vg->pvs after check for maximum value of vg->extent_count.
In-Reply-To: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
References: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1270497099-13259-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In add_pv_to_vg(), we should only add the pv to vg->pvs after all
internal checks have passed.  The check for vg->extent_count exeeding
maximum was after we added the pv to the list, so this function could
return a state of vg->pvs that did not reflect other parameters such
as vg->pv_count.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a12a8c8..9e6d9ba 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -220,9 +220,6 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
 
-	pvl->pv = pv;
-	dm_list_add(&vg->pvs, &pvl->list);
-
 	if ((uint64_t) vg->extent_count + pv->pe_count > UINT32_MAX) {
 		log_error("Unable to add %s to %s: new extent count (%"
 			  PRIu64 ") exceeds limit (%" PRIu32 ").",
@@ -232,6 +229,9 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		return 0;
 	}
 
+	pvl->pv = pv;
+	dm_list_add(&vg->pvs, &pvl->list);
+
 	vg->pv_count++;
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
-- 
1.6.0.6


