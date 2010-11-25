From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:28 +0100
Subject: [PATCH 24/29] Test for str_list_add
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <6d5dfe12a1e10eccb3bc286ff08c667a8d1ae14c.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Check for success and report error on failure case.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_pool/import_export.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 07f67fd..7884247 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -206,7 +206,10 @@ static int _add_stripe_seg(struct dm_pool *mem,
 			return_0;
 
 	/* add the subpool type to the segment tag list */
-	str_list_add(mem, &seg->tags, _cvt_sptype(usp->type));
+	if (!str_list_add(mem, &seg->tags, _cvt_sptype(usp->type))) {
+		log_error("Allocation failed for str_list.");
+		return 0;
+	}
 
 	dm_list_add(&lv->segments, &seg->list);
 
@@ -240,7 +243,10 @@ static int _add_linear_seg(struct dm_pool *mem,
 		}
 
 		/* add the subpool type to the segment tag list */
-		str_list_add(mem, &seg->tags, _cvt_sptype(usp->type));
+		if (!str_list_add(mem, &seg->tags, _cvt_sptype(usp->type))) {
+			log_error("Allocation failed for str_list.");
+			return 0;
+		}
 
 		if (!set_lv_segment_area_pv(seg, 0, usp->devs[j].pv, 0))
 			return_0;
-- 
1.7.3.2


