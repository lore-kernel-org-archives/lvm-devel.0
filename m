From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Nov 2015 11:21:15 +0000 (UTC)
Subject: master - cleanup: use display_lvname in pmspare
Message-ID: <20151119112115.2490B60E43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2b00b0a899376b3336e146dc3f4c077726d938a
Commit:        e2b00b0a899376b3336e146dc3f4c077726d938a
Parent:        0a2cadf6b87acd62151451cff8fd596715f00718
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 18 09:14:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 18 22:17:26 2015 +0100

cleanup: use display_lvname in pmspare

Just switch to use display_lvname().
Also squeeze possibly failing strncpy into INTERNAL_ERROR
as lvname always should fit.
---
 lib/metadata/pool_manip.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index a57d90e..fd7edd2 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -709,7 +709,7 @@ int vg_remove_pool_metadata_spare(struct volume_group *vg)
 
 	if (!(lv->status & POOL_METADATA_SPARE)) {
 		log_error(INTERNAL_ERROR "LV %s is not pool metadata spare.",
-			  lv->name);
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -718,10 +718,10 @@ int vg_remove_pool_metadata_spare(struct volume_group *vg)
 	lv_set_visible(lv);
 
 	/* Cut off suffix _pmspare */
-	(void) dm_strncpy(new_name, lv->name, sizeof(new_name));
-	if (!(c = strchr(new_name, '_'))) {
+	if (!dm_strncpy(new_name, lv->name, sizeof(new_name)) ||
+	    !(c = strchr(new_name, '_'))) {
 		log_error(INTERNAL_ERROR "LV %s has no suffix for pool metadata spare.",
-			  new_name);
+			  display_lvname(lv));
 		return 0;
 	}
 	*c = 0;
@@ -735,8 +735,8 @@ int vg_remove_pool_metadata_spare(struct volume_group *vg)
 	}
 
 	log_print_unless_silent("Renaming existing pool metadata spare "
-				"logical volume \"%s/%s\" to \"%s/%s\".",
-                                vg->name, lv->name, vg->name, new_name);
+				"logical volume \"%s\" to \"%s/%s\".",
+                                display_lvname(lv), vg->name, new_name);
 
 	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
 		return_0;


