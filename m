From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:10 +0000 (UTC)
Subject: master - cache: check activation of volume activated
Message-ID: <20141006133310.A0F016016C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b37203c8193ea47d2de1033b5e57ae5bd1360df4
Commit:        b37203c8193ea47d2de1033b5e57ae5bd1360df4
Parent:        75119d85b3dfe9f53187f37130fd6d215705c166
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 23:48:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:06 2014 +0200

cache: check activation of volume activated

volume_list may silently skip activation which is then still reported as
success.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |   15 ++++++++++-----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a11fa16..275d666 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Properly check if activation of removed cached LV really activated.
   Lvremoving cached LV removes cachepool (keep with lvconvert --splitcache).
   Always remove spare LV with last removed pool volume.
   Support lvconvert --splitcache and --uncache of cached LV.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 80214c9..ed08726 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -229,11 +229,16 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		return 0;
 	}
 
-	/* Active volume is needed (writeback only?) */
-	if (!lv_is_active_locally(cache_lv) &&
-	    !activate_lv_excl_local(cache_lv->vg->cmd, cache_lv)) {
-		log_error("Failed to active cache locally %s.", cache_lv->name);
-		return 0;
+	/* Localy active volume is needed (writeback only?) */
+	if (!lv_is_active_locally(cache_lv)) {
+		cache_lv->status |= LV_TEMPORARY;
+		if (!activate_lv_excl_local(cache_lv->vg->cmd, cache_lv) ||
+		    !lv_is_active_locally(cache_lv)) {
+			log_error("Failed to active cache locally %s.",
+				  display_lvname(cache_lv));
+			return 0;
+		}
+		cache_lv->status &= ~LV_TEMPORARY;
 	}
 
 	/*


