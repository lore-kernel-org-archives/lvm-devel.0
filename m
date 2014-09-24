From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:00 +0000 (UTC)
Subject: master - validation: move check for spare correctness
Message-ID: <20140924085700.69BD86109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f82a7d11469400fcf5ca01b4444b3ba25ba06b8
Commit:        9f82a7d11469400fcf5ca01b4444b3ba25ba06b8
Parent:        93fbef1a45948c1f97fe484b4dd65179afa5051d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 11:34:50 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

validation: move check for spare correctness

Check lv feature when we check LVs
---
 lib/metadata/metadata.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 464b8bc..354dc68 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2492,6 +2492,19 @@ int vg_validate(struct volume_group *vg)
 			r = 0;
 		}
 
+		if (lv_is_pool_metadata_spare(lvl->lv)) {
+			if (++spare_count > 1) {
+				log_error(INTERNAL_ERROR "LV %s is %u. pool metadata spare (>1).",
+					  lvl->lv->name, spare_count);
+				r = 0;
+			}
+			if (vg->pool_metadata_spare_lv != lvl->lv) {
+				log_error(INTERNAL_ERROR "LV %s is not vg pool metadata spare.",
+					  lvl->lv->name);
+				r = 0;
+			}
+		}
+
 		if (lv_is_cow(lvl->lv))
 			num_snapshots++;
 
@@ -2590,19 +2603,6 @@ int vg_validate(struct volume_group *vg)
 			r = 0;
 		}
 
-		if (lv_is_pool_metadata_spare(lvl->lv)) {
-			if (++spare_count > 1) {
-				log_error(INTERNAL_ERROR "LV %s is %u. pool metadata spare (>1).",
-					  lvl->lv->name, spare_count);
-				r = 0;
-			}
-			if (vg->pool_metadata_spare_lv != lvl->lv) {
-				log_error(INTERNAL_ERROR "LV %s is not vg pool metadata spare.",
-					  lvl->lv->name);
-				r = 0;
-			}
-		}
-
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);


