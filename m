From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jun 2015 12:48:44 +0000 (UTC)
Subject: master - debug: better tracing messages
Message-ID: <20150615124844.04D246006F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7eb5b069689cc0fe76a95cda2fb850a6a1d2c21
Commit:        e7eb5b069689cc0fe76a95cda2fb850a6a1d2c21
Parent:        9a06ae7b35f4355e7be14b5fae2865b85fc60fc2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 15 14:33:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 15 14:48:06 2015 +0200

debug: better tracing messages

Enhance traced output.
---
 lib/activate/activate.c    |    5 ++++-
 lib/activate/dev_manager.c |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 55956fd..8c89f98 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2010,7 +2010,9 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 
 	log_debug_activation("Resuming LV %s/%s%s%s%s.", lv->vg->name, lv->name,
 			     error_if_not_active ? "" : " if active",
-			     laopts->origin_only ? " without snapshots" : "",
+			     laopts->origin_only ?
+			     (lv_is_thin_pool(lv) ? " pool only" :
+			      lv_is_thin_volume(lv) ? " thin only" : " without snapshots") : "",
 			     laopts->revert ? " (reverting)" : "");
 
 	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
@@ -2272,6 +2274,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (info.exists && !info.suspended && info.live_table &&
 	    (info.read_only == read_only_lv(lv, laopts))) {
 		r = 1;
+		log_debug_activation("Volume is already active.");
 		goto out;
 	}
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1171f4c..9624feb 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3042,7 +3042,10 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 	int r = 0;
 
 	if (action < DM_ARRAY_SIZE(_action_names))
-		log_debug_activation("Creating %s tree for %s.", _action_names[action], lv->name);
+		log_debug_activation("Creating %s%s tree for %s.",
+				     _action_names[action],
+				     (laopts->origin_only) ? " origin-only" : "",
+				     display_lvname(lv));
 
 	/* Some LV can be used for top level tree */
 	/* TODO: add more.... */


