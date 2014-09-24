From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:02 +0000 (UTC)
Subject: master - cleanup: move printing after backup
Message-ID: <20140924085702.8263361464@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af18e7cfbfee96ff8f5ec2ab795c830b4a6c7da4
Commit:        af18e7cfbfee96ff8f5ec2ab795c830b4a6c7da4
Parent:        9f82a7d11469400fcf5ca01b4444b3ba25ba06b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 14:06:52 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

cleanup: move printing after backup

Print successful result after making backup.
In this place we are sure to not keep memlock.
---
 tools/lvconvert.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 57975d1..0978172 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2216,10 +2216,12 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	lp->lv_to_poll = origin;
 
 	r = 1;
-	log_print_unless_silent("Merging of volume %s started.", lv->name);
 out:
 	backup(lv->vg);
 
+	if (r)
+		log_print_unless_silent("Merging of volume %s started.", lv->name);
+
 	return r;
 }
 
@@ -2296,13 +2298,14 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
-	log_print_unless_silent("Merging of thin snapshot %s will occur on "
-				"next activation of %s.",
-				display_lvname(lv), display_lvname(origin));
 	r = 1;
 out:
 	backup(lv->vg);
 
+	if (r)
+		log_print_unless_silent("Merging of thin snapshot %s will occur on "
+					"next activation of %s.",
+					display_lvname(lv), display_lvname(origin));
 	return r;
 }
 
@@ -3017,18 +3020,18 @@ mda_write:
 		goto out;
 	}
 
-	log_print_unless_silent("Converted %s to %s pool.",
-				display_lvname(pool_lv),
-				(segtype_is_cache_pool(lp->segtype)) ?
-				"cache" : "thin");
-
 	r = 1;
-
 	lp->pool_data_lv = pool_lv;
 
 out:
 	backup(vg);
 
+	if (r)
+		log_print_unless_silent("Converted %s to %s pool.",
+					display_lvname(pool_lv),
+					(segtype_is_cache_pool(lp->segtype)) ?
+					"cache" : "thin");
+
 	return r;
 #if 0
 revert_new_lv:


