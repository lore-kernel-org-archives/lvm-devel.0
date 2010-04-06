From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  6 Apr 2010 19:53:17 -0400
Subject: [PATCH 2/5] Move increment of vg->pv_count from import_pool_vg() to import_pool_pvs().
In-Reply-To: <1270598000-9771-2-git-send-email-dwysocha@redhat.com>
References: <1270598000-9771-1-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1270598000-9771-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the increment of vg->pv_count next to the place where we add to
vg->pvs.  It looks safe to do this since the only caller of import_pool_vg()
calls import_pool_pvs() immediately afterward, and there is no way
import_pool_vg() can fail (always returns 1).  However, if there's a
memory allocation failure inside import_pool_pvs(), we will end up with
a different count in vg->pv_count that with the original code.  In any
case, vg->pv_count should be as close to dm_list_size(&vg->pvs) as
possible, as is the case everywhere else in the code.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_pool/import_export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 032d428..d464364 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -37,7 +37,6 @@ int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct dm_list
 		    ((pl->pd.pl_blocks) / POOL_PE_SIZE);
 
 		vg->free_count = vg->extent_count;
-		vg->pv_count++;
 
 		if (vg->name)
 			continue;
@@ -120,6 +119,7 @@ int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
 		pl->pv = pvl->pv;
 		pvl->mdas = NULL;
 		pvl->pe_ranges = NULL;
+		vg->pv_count++;
 		dm_list_add(&vg->pvs, &pvl->list);
 	}
 
-- 
1.6.0.6


