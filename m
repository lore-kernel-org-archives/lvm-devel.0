From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:14 +0000 (GMT)
Subject: main - lvextend: enable resize of writecached LV
Message-ID: <20210223140414.26D2A3896C30@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ac09fa08aa7a10cc3f807830de5d625d499ed1b1
Commit:        ac09fa08aa7a10cc3f807830de5d625d499ed1b1
Parent:        e43b5f1e3c8b445577b9aebea9afecbe0e9ab9c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 20 22:22:51 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:56:47 2021 +0100

lvextend: enable resize of writecached LV

---
 lib/metadata/lv_manip.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5cad4e07a..9bcab7477 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1465,7 +1465,8 @@ static struct logical_volume *_get_resizable_layer_lv(struct logical_volume *lv)
 	while (lv_is_cache(lv) || /* _corig */
 	       lv_is_integrity(lv) ||
 	       lv_is_thin_pool(lv) || /* _tdata */
-	       lv_is_vdo_pool(lv)) /* _vdata */
+	       lv_is_vdo_pool(lv) || /* _vdata */
+	       lv_is_writecache(lv)) /* _worigin */
 		lv = seg_lv(first_seg(lv), 0);  /* component-level down */
 
 	return lv;
@@ -1479,7 +1480,8 @@ static int _is_layered_lv(struct logical_volume *lv)
 	return (lv_is_cache_origin(lv) ||
 		lv_is_integrity_origin(lv) ||
 		lv_is_thin_pool_data(lv) ||
-		lv_is_vdo_pool_data(lv));
+		lv_is_vdo_pool_data(lv) ||
+		lv_is_writecache_origin(lv));
 }
 
 /* Find the topmost LV in the stack - usually such LV is visible. */
@@ -5173,11 +5175,6 @@ static int _lvresize_check(struct logical_volume *lv,
 	struct volume_group *vg = lv->vg;
 	struct lv_segment *seg = first_seg(lv);
 
-	if (lv_is_writecache(lv)) {
-		log_error("Resize not yet allowed on LVs with writecache attached.");
-		return 0;
-	}
-
 	if (lv_is_external_origin(lv)) {
 		/*
 		 * Since external-origin can be activated read-only,
@@ -5803,6 +5800,11 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 				  display_lvname(lv));
 			return 0;
 		}
+		if (lv_is_writecache(lv)) {
+			/* TODO: detect kernel with support for reduction */
+			log_error("Reduce not yet allowed on LVs with writecache attached.");
+			return 0;
+		}
 	} else if (lp->resize == LV_EXTEND)  {
 		if (lv_is_thin_pool_metadata(lv) &&
 		    (!(seg = find_pool_seg(first_seg(lv))) ||


