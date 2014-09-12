From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Sep 2014 12:44:51 +0000 (UTC)
Subject: master - raid: add missing backups
Message-ID: <20140912124451.6676060DAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd1fa0e808918b51a690e26de8a8cfff6c307854
Commit:        dd1fa0e808918b51a690e26de8a8cfff6c307854
Parent:        15ba2afdc2d70ee21c2599f0d51a413f0a7afa9b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 11 19:05:40 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:42:57 2014 +0200

raid: add missing backups

Add backup() calls that were missing after successful update
of metadata.
---
 WHATS_NEW                 |    2 ++
 lib/metadata/raid_manip.c |   17 ++++++++++++-----
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 983bc1a..be549b8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.112 - 
 =====================================
+  Add missing backup of lvm2 metadata after some raid modifications.
+  Use vg memory pool for extent allocation.
   Add allocation/physical_extent_size config option for default PE size of VGs.
   Introduce common code to modify metadate and reload updated LV.
   Fix rename of active snapshot volume in cluster.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d39dbc8..91cc0dd 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -13,6 +13,7 @@
  */
 
 #include "lib.h"
+#include "archiver.h"
 #include "metadata.h"
 #include "toolcontext.h"
 #include "segtype.h"
@@ -695,11 +696,13 @@ to be left for these sub-lvs.
 			rebuild_flag_cleared = 1;
 		}
 	}
-	if (rebuild_flag_cleared &&
-	    (!vg_write(lv->vg) || !vg_commit(lv->vg))) {
-		log_error("Failed to clear REBUILD flag for %s/%s components",
-			  lv->vg->name, lv->name);
-		return 0;
+	if (rebuild_flag_cleared) {
+		if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
+			log_error("Failed to clear REBUILD flag for %s/%s components",
+				  lv->vg->name, lv->name);
+			return 0;
+		}
+		backup(lv->vg);
 	}
 
 	return 1;
@@ -978,6 +981,8 @@ static int _raid_remove_images(struct logical_volume *lv,
 			return_0;
 	}
 
+	backup(lv->vg);
+
 	return 1;
 }
 
@@ -1149,6 +1154,8 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
+	backup(lv->vg);
+
 	return 1;
 }
 


