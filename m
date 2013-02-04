From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:08:04 +0000 (UTC)
Subject: master - thin: replace is_active with send_messages
Message-ID: <20130204180804.0B7E33523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ed0b6f312e0e9b5566934c5d30f79c1450fba2f
Commit:        8ed0b6f312e0e9b5566934c5d30f79c1450fba2f
Parent:        4af4241ba4f749ee64375e7e80fecf6bda67f1e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 17 10:35:27 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:01:10 2013 +0100

thin: replace is_active with send_messages

Since is_active is only used for thinp
replace struct member with more meaningful
send_messages flag
---
 lib/activate/activate.h    |    2 +-
 lib/activate/dev_manager.c |    3 +--
 lib/thin/thin.c            |    2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 4db7183..df4120c 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -35,7 +35,7 @@ struct lv_activate_opts {
 	int origin_only;
 	int no_merging;
 	int real_pool;
-	int is_activate;
+	int send_messages;
 	int skip_in_use;
 	unsigned revert;
 	unsigned read_only;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index de42b3b..e4cb0c3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2388,8 +2388,6 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	char *dlid;
 	int r = 0;
 
-	laopts->is_activate = (action == ACTIVATE);
-
 	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
 		return_0;
 
@@ -2471,6 +2469,7 @@ out_no_root:
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
 			 struct lv_activate_opts *laopts)
 {
+	laopts->send_messages = 1;
 	if (!_tree_action(dm, lv, laopts, ACTIVATE))
 		return_0;
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 3f74588..8c0ec82 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -305,7 +305,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	 * Also transation_id is checked only when snapshot origin is active.
 	 * (This might change later)
 	 */
-	if (!laopts->is_activate)
+	if (!laopts->send_messages)
 		return 1;
 
 	dm_list_iterate_items(lmsg, &seg->thin_messages) {


