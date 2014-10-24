From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:39:55 +0000 (UTC)
Subject: master - cache: validate for locked
Message-ID: <20141024143955.2F18460641@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e57dbfcaa3fdc2aabe7c05f95268a35d6b198ca
Commit:        6e57dbfcaa3fdc2aabe7c05f95268a35d6b198ca
Parent:        d4dab0aa34102527c32d68f69196aaabda5e3711
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 14:58:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cache: validate for locked

Add extra safety.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f5b7931..8b9cf6f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Add extra validate for locked lv within validate_lv_cache_create().
   Add internal lvseg_name() function.
   Skip trying to file lock virtual internal vg name.
   Fix selection on {vg,lv}_permissions fields to properly match selection criteria.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 0a6daf6..837c651 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -104,6 +104,12 @@ int validate_lv_cache_create(const struct logical_volume *pool_lv,
 			return 0;
 		}
 
+		if (lv_is_locked(pool_lv)) {
+			log_error("Cannot use locked cache pool %s.",
+				  display_lvname(pool_lv));
+			return 0;
+		}
+
 		if (origin_lv == pool_lv) {
 			log_error("Can't use same LV %s for cache pool and cache volume.",
 				  display_lvname(pool_lv));
@@ -119,6 +125,12 @@ int validate_lv_cache_create(const struct logical_volume *pool_lv,
 		}
 	}
 
+	if (lv_is_locked(origin_lv)) {
+		log_error("Cannot use locked origin volume %s.",
+			  display_lvname(origin_lv));
+		return 0;
+	}
+
 	/* For now we only support conversion of thin pool data volume */
 	if (!lv_is_visible(origin_lv) && !lv_is_thin_pool_data(origin_lv)) {
 		log_error("Can't convert internal LV %s.", display_lvname(origin_lv));


