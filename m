From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 Apr 2016 10:59:10 +0000 (UTC)
Subject: master - debug: use display_lvname
Message-ID: <20160418105910.2850B61B7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1c1f60047bb6973eee432ea14f93058a836faac
Commit:        d1c1f60047bb6973eee432ea14f93058a836faac
Parent:        e2ceb90095ab008c13a3d0db0bbf1bc2bd8557f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 18 11:04:06 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 18 12:32:56 2016 +0200

debug: use display_lvname

---
 tools/toollib.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index b1225cd..5e9b4d8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1057,13 +1057,15 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		snapshot_lv = find_snapshot(lv)->lv;
 		if (lv_is_thin_type(snapshot_lv) && !deactivate_lv(cmd, snapshot_lv)) {
 			if (is_change_activating(activate)) {
-				log_error("Refusing to activate merging \"%s\" while snapshot \"%s\" is still active.",
-					  lv->name, find_snapshot(lv)->lv->name);
+				log_error("Refusing to activate merging volume %s while "
+					  "snapshot volume %s is still active.",
+					  display_lvname(lv), display_lvname(snapshot_lv));
 				return 0;
 			}
 
-			log_error("Cannot fully deactivate merging origin \"%s\" while snapshot \"%s\" is still active.",
-				  lv->name, find_snapshot(lv)->lv->name);
+			log_error("Cannot fully deactivate merging origin volume %s while "
+				  "snapshot volume %s is still active.",
+				  display_lvname(lv), display_lvname(snapshot_lv));
 			r = 0; /* and continue to deactivate origin... */
 		}
 	}


