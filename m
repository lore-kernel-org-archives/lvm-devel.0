From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  5 Apr 2010 15:51:36 -0400
Subject: [PATCH 2/5] Refactor _read_pv() code that updates vg->extent_count and vg->free_count.
In-Reply-To: <1270497099-13259-2-git-send-email-dwysocha@redhat.com>
References: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1270497099-13259-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Simple refactor to mov code that updates the vg extent counts from a
single pv's counts close to the code that adds a pv to vg->pvs and
updates vg->pv_count.  No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/import_vsn1.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index ae9742a..cf2c9df 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -241,10 +241,6 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		return 0;
 	}
 
-	/* adjust the volume group. */
-	vg->extent_count += pv->pe_count;
-	vg->free_count += pv->pe_count;
-
 	pv->pe_size = vg->extent_size;
 
 	pv->pe_alloc_count = 0;
@@ -273,6 +269,8 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
 
+	vg->extent_count += pv->pe_count;
+	vg->free_count += pv->pe_count;
 	vg->pv_count++;
 	dm_list_add(&vg->pvs, &pvl->list);
 
-- 
1.6.0.6


