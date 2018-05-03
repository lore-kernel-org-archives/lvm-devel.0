From: David Teigland <teigland@sourceware.org>
Date: Thu, 3 May 2018 18:09:51 -0400
Subject: master - clvmd: saved_vg code and comment formatting
Message-ID: <201805032209.w43M9p8V005177@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4a60fe00444bbb4aa54e32b0bef90a9c4eca704
Commit:        f4a60fe00444bbb4aa54e32b0bef90a9c4eca704
Parent:        822a8b62be8aa2949d07bcc8b41f019a34ea5b57
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 3 11:41:10 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 3 14:54:48 2018 -0500

clvmd: saved_vg code and comment formatting

---
 lib/cache/lvmcache.c |   88 ++++++++++++++++++++++++--------------------------
 1 files changed, 42 insertions(+), 46 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 56ddab8..745e219 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -211,33 +211,32 @@ static void _saved_vg_inval(struct saved_vg *svg, int inval_old, int inval_new)
 {
 	struct vg_list *vgl;
 
-	if (inval_old) {
-		if (svg->saved_vg_old)
-			log_debug_cache("lvmcache: inval saved_vg %s old %p",
-					svg->saved_vg_old->name, svg->saved_vg_old);
-
-		if (svg->saved_vg_old) {
-			if ((vgl = dm_zalloc(sizeof(*vgl)))) {
-				vgl->vg = svg->saved_vg_old;
-				dm_list_add(&svg->saved_vg_to_free, &vgl->list);
-			}
+	/* 
+	 * In practice there appears to only ever be a single invalidated vg,
+	 * so making saved_vg_to_free a list instead of a pointer is overkill.
+	 * But, without proof otherwise, safer to keep the list.
+	 */
+
+	if (inval_old && svg->saved_vg_old) {
+		log_debug_cache("lvmcache: inval saved_vg %s old %p",
+				svg->saved_vg_old->name, svg->saved_vg_old);
+
+		if ((vgl = dm_zalloc(sizeof(*vgl)))) {
+			vgl->vg = svg->saved_vg_old;
+			dm_list_add(&svg->saved_vg_to_free, &vgl->list);
 		}
 
 		svg->saved_vg_old = NULL;
 	}
 
-	if (inval_new) {
-		if (svg->saved_vg_new)
-			log_debug_cache("lvmcache: inval saved_vg %s new pre %p",
-					svg->saved_vg_new->name, svg->saved_vg_new);
+	if (inval_new && svg->saved_vg_new) {
+		log_debug_cache("lvmcache: inval saved_vg %s new pre %p",
+				svg->saved_vg_new->name, svg->saved_vg_new);
 
-		if (svg->saved_vg_new) {
-			if ((vgl = dm_zalloc(sizeof(*vgl)))) {
-				vgl->vg = svg->saved_vg_new;
-				dm_list_add(&svg->saved_vg_to_free, &vgl->list);
-			}
+		if ((vgl = dm_zalloc(sizeof(*vgl)))) {
+			vgl->vg = svg->saved_vg_new;
+			dm_list_add(&svg->saved_vg_to_free, &vgl->list);
 		}
-
 		svg->saved_vg_new = NULL;
 	}
 }
@@ -245,23 +244,22 @@ static void _saved_vg_inval(struct saved_vg *svg, int inval_old, int inval_new)
 static void _saved_vg_free(struct saved_vg *svg, int free_old, int free_new)
 {
 	struct vg_list *vgl, *vgl2;
+	struct volume_group *vg;
 
 	if (free_old) {
-		if (svg->saved_vg_old) {
-			log_debug_cache("lvmcache: free saved_vg %s old %p",
-					svg->saved_vg_old->name, svg->saved_vg_old);
+		if ((vg = svg->saved_vg_old)) {
+			log_debug_cache("lvmcache: free saved_vg old %s %.8s %d old %p",
+					vg->name, (char *)&vg->id, vg->seqno, vg);
 
-			svg->saved_vg_old->saved_in_clvmd = 0;
+			vg->saved_in_clvmd = 0;
+			release_vg(vg);
+			svg->saved_vg_old = NULL;
+			vg = NULL;
 		}
 
-		if (svg->saved_vg_old)
-			release_vg(svg->saved_vg_old);
-
-		svg->saved_vg_old = NULL;
-
 		dm_list_iterate_items_safe(vgl, vgl2, &svg->saved_vg_to_free) {
-			log_debug_cache("lvmcache: free saved_vg_to_free %s %p",
-					vgl->vg->name, vgl->vg);
+			log_debug_cache("lvmcache: free saved_vg_to_free %s %.8s %d %p",
+					vgl->vg->name, (char *)&vgl->vg->id, vgl->vg->seqno, vgl->vg);
 
 			dm_list_del(&vgl->list);
 			vgl->vg->saved_in_clvmd = 0;
@@ -270,17 +268,15 @@ static void _saved_vg_free(struct saved_vg *svg, int free_old, int free_new)
 	}
 
 	if (free_new) {
-		if (svg->saved_vg_new) {
-			log_debug_cache("lvmcache: free saved_vg %s new pre %p",
-					svg->saved_vg_new->name, svg->saved_vg_new);
+		if ((vg = svg->saved_vg_new)) {
+			log_debug_cache("lvmcache: free saved_vg pre %s %.8s %d %p",
+					vg->name, (char *)&vg->id, vg->seqno, vg);
 
-			svg->saved_vg_new->saved_in_clvmd = 0;
+			vg->saved_in_clvmd = 0;
+			release_vg(vg);
+			svg->saved_vg_new = NULL;
+			vg = NULL;
 		}
-
-		if (svg->saved_vg_new)
-			release_vg(svg->saved_vg_new);
-
-		svg->saved_vg_new = NULL;
 	}
 }
 
@@ -419,10 +415,10 @@ struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted)
 
 	if (vg && new) {
 		if (!svg->saved_vg_old)
-			log_debug_cache("lvmcache: get new (pre) saved_vg %d %s %p",
+			log_debug_cache("lvmcache: get new saved_vg %d %s %p",
 					vg->seqno, vg->name, vg);
 		else
-			log_debug_cache("lvmcache: get new (pre) saved_vg %d %s %p old is %d %p",
+			log_debug_cache("lvmcache: get new saved_vg %d %s %p old is %d %p",
 					vg->seqno, vg->name, vg,
 					svg->saved_vg_old->seqno,
 					svg->saved_vg_old);
@@ -484,10 +480,10 @@ struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid)
 
 	if (vg && new) {
 		if (!svg->saved_vg_old)
-			log_debug_cache("lvmcache: get_latest new (pre) saved_vg %d %s %p",
+			log_debug_cache("lvmcache: get_latest new saved_vg %d %s %p",
 					vg->seqno, vg->name, vg);
 		else
-			log_debug_cache("lvmcache: get_latest new (pre) saved_vg %d %s %p old is %d %p",
+			log_debug_cache("lvmcache: get_latest new saved_vg %d %s %p old is %d %p",
 					vg->seqno, vg->name, vg,
 					svg->saved_vg_old->seqno,
 					svg->saved_vg_old);


