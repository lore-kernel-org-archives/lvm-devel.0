From: David Teigland <teigland@sourceware.org>
Date: Thu, 3 May 2018 18:09:45 -0400
Subject: master - clvmd: don't save cft and buf for saved_vg
Message-ID: <201805032209.w43M9jnh005165@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=822a8b62be8aa2949d07bcc8b41f019a34ea5b57
Commit:        822a8b62be8aa2949d07bcc8b41f019a34ea5b57
Parent:        c016b573ee32ff836f1d427d5cf58eb6480cf7b8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 3 10:50:38 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 3 14:54:48 2018 -0500

clvmd: don't save cft and buf for saved_vg

---
 lib/cache/lvmcache.c |   38 --------------------------------------
 1 files changed, 0 insertions(+), 38 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 506bcdf..56ddab8 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -87,11 +87,7 @@ struct saved_vg {
 	 */
 	char vgid[ID_LEN + 1];
 	int saved_vg_committed;
-	char *saved_vg_old_buf;
-	struct dm_config_tree *saved_vg_old_cft;
 	struct volume_group *saved_vg_old;
-	char *saved_vg_new_buf;
-	struct dm_config_tree *saved_vg_new_cft;
 	struct volume_group *saved_vg_new;
 	struct dm_list saved_vg_to_free;
 };
@@ -220,11 +216,6 @@ static void _saved_vg_inval(struct saved_vg *svg, int inval_old, int inval_new)
 			log_debug_cache("lvmcache: inval saved_vg %s old %p",
 					svg->saved_vg_old->name, svg->saved_vg_old);
 
-		if (svg->saved_vg_old_buf)
-			dm_free(svg->saved_vg_old_buf);
-		if (svg->saved_vg_old_cft)
-			dm_config_destroy(svg->saved_vg_old_cft);
-
 		if (svg->saved_vg_old) {
 			if ((vgl = dm_zalloc(sizeof(*vgl)))) {
 				vgl->vg = svg->saved_vg_old;
@@ -232,8 +223,6 @@ static void _saved_vg_inval(struct saved_vg *svg, int inval_old, int inval_new)
 			}
 		}
 
-		svg->saved_vg_old_buf = NULL;
-		svg->saved_vg_old_cft = NULL;
 		svg->saved_vg_old = NULL;
 	}
 
@@ -242,11 +231,6 @@ static void _saved_vg_inval(struct saved_vg *svg, int inval_old, int inval_new)
 			log_debug_cache("lvmcache: inval saved_vg %s new pre %p",
 					svg->saved_vg_new->name, svg->saved_vg_new);
 
-		if (svg->saved_vg_new_buf)
-			dm_free(svg->saved_vg_new_buf);
-		if (svg->saved_vg_new_cft)
-			dm_config_destroy(svg->saved_vg_new_cft);
-
 		if (svg->saved_vg_new) {
 			if ((vgl = dm_zalloc(sizeof(*vgl)))) {
 				vgl->vg = svg->saved_vg_new;
@@ -254,8 +238,6 @@ static void _saved_vg_inval(struct saved_vg *svg, int inval_old, int inval_new)
 			}
 		}
 
-		svg->saved_vg_new_buf = NULL;
-		svg->saved_vg_new_cft = NULL;
 		svg->saved_vg_new = NULL;
 	}
 }
@@ -272,15 +254,9 @@ static void _saved_vg_free(struct saved_vg *svg, int free_old, int free_new)
 			svg->saved_vg_old->saved_in_clvmd = 0;
 		}
 
-		if (svg->saved_vg_old_buf)
-			dm_free(svg->saved_vg_old_buf);
-		if (svg->saved_vg_old_cft)
-			dm_config_destroy(svg->saved_vg_old_cft);
 		if (svg->saved_vg_old)
 			release_vg(svg->saved_vg_old);
 
-		svg->saved_vg_old_buf = NULL;
-		svg->saved_vg_old_cft = NULL;
 		svg->saved_vg_old = NULL;
 
 		dm_list_iterate_items_safe(vgl, vgl2, &svg->saved_vg_to_free) {
@@ -301,15 +277,9 @@ static void _saved_vg_free(struct saved_vg *svg, int free_old, int free_new)
 			svg->saved_vg_new->saved_in_clvmd = 0;
 		}
 
-		if (svg->saved_vg_new_buf)
-			dm_free(svg->saved_vg_new_buf);
-		if (svg->saved_vg_new_cft)
-			dm_config_destroy(svg->saved_vg_new_cft);
 		if (svg->saved_vg_new)
 			release_vg(svg->saved_vg_new);
 
-		svg->saved_vg_new_buf = NULL;
-		svg->saved_vg_new_cft = NULL;
 		svg->saved_vg_new = NULL;
 	}
 }
@@ -396,18 +366,10 @@ void lvmcache_save_vg(struct volume_group *vg, int precommitted)
 	save_vg->saved_in_clvmd = 1;
 
 	if (old) {
-		/*
-		svg->saved_vg_old_buf = save_buf;
-		svg->saved_vg_old_cft = save_cft;
-		*/
 		svg->saved_vg_old = save_vg;
 		log_debug_cache("lvmcache: saved old vg %s seqno %d %p",
 				save_vg->name, save_vg->seqno, save_vg);
 	} else {
-		/*
-		svg->saved_vg_new_buf = save_buf;
-		svg->saved_vg_new_cft = save_cft;
-		*/
 		svg->saved_vg_new = save_vg;
 		log_debug_cache("lvmcache: saved pre vg %s seqno %d %p",
 				save_vg->name, save_vg->seqno, save_vg);


