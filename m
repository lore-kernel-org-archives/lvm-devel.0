From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:46 +0000 (UTC)
Subject: master - debug: log tree type is created
Message-ID: <20141110210646.C148760C9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02f49caa3599d74ff9ef850d76fec69569ef9621
Commit:        02f49caa3599d74ff9ef850d76fec69569ef9621
Parent:        f12e3da6393376ed13370a45995bf1950081a954
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 8 23:41:22 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

debug: log tree type is created

Print tree type and use internal_error for unknown type.
---
 lib/activate/dev_manager.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ffd7ff3..1666d41 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2903,12 +2903,18 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *
 static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, action_t action)
 {
+	static const char const _action_names[][24] = {
+		"PRELOAD", "ACTIVATE", "DEACTIVATE", "SUSPEND", "SUSPEND_WITH_LOCKFS", "CLEAN"
+	};
 	const size_t DLID_SIZE = ID_LEN + sizeof(UUID_PREFIX) - 1;
 	struct dm_tree *dtree;
 	struct dm_tree_node *root;
 	char *dlid;
 	int r = 0;
 
+	if (action < DM_ARRAY_SIZE(_action_names))
+		log_debug_activation("Creating %s tree for %s.", _action_names[action], lv->name);
+
 	/* Some LV can be used for top level tree */
 	/* TODO: add more.... */
 	if (lv_is_cache_pool(lv) && !dm_list_empty(&lv->segs_using_this_lv)) {
@@ -2980,7 +2986,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 
 		break;
 	default:
-		log_error("_tree_action: Action %u not supported.", action);
+		log_error(INTERNAL_ERROR "_tree_action: Action %u not supported.", action);
 		goto out;
 	}
 


