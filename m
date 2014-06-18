From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Jun 2014 13:00:40 +0000 (UTC)
Subject: master - lvconvert: print warning when not convert thinpool
Message-ID: <20140618130040.B34B9610B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6a4cc9c316ce7c86e664c4dea2192433ff9bab4
Commit:        e6a4cc9c316ce7c86e664c4dea2192433ff9bab4
Parent:        21964f47d5e30d925cd8e80b6402f1a2c69ad673
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 18 14:18:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 18 15:00:18 2014 +0200

lvconvert: print warning when not convert thinpool

Warning about destruction should not be printed,
When we are converting already existing pool
(improving original in-release commit bbf4b2c1c9d)
---
 tools/lvconvert.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e857a70..a2e02d4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2708,22 +2708,24 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_thin_pool(pool_lv) && pool_is_active(pool_lv)) {
+	if (lv_is_thin_pool(pool_lv)) {
+		if (pool_is_active(pool_lv)) {
 		/* If any thin volume is also active - abort here */
-		log_error("Cannot convert pool %s/%s with active thin volumes.",
-			  pool_lv->vg->name, pool_lv->name);
-		return 0;
-	}
-
-	log_warn("WARNING: Converting \"%s/%s\" logical volume to pool's data volume.",
-		 pool_lv->vg->name, pool_lv->name);
-	log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+			log_error("Cannot convert pool %s/%s with active thin volumes.",
+				  pool_lv->vg->name, pool_lv->name);
+			return 0;
+		}
+	} else {
+		log_warn("WARNING: Converting \"%s/%s\" logical volume to pool's data volume.",
+			 pool_lv->vg->name, pool_lv->name);
+		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
 
-	if (!lp->yes &&
-	    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y/n]: ",
-			  pool_lv->vg->name, pool_lv->name) == 'n') {
-		log_error("Conversion aborted.");
-		return 0;
+		if (!lp->yes &&
+		    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y/n]: ",
+				  pool_lv->vg->name, pool_lv->name) == 'n') {
+			log_error("Conversion aborted.");
+			return 0;
+		}
 	}
 
 	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s%s",


