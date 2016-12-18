From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:27 +0000 (UTC)
Subject: master - debug: add debug message showing new lv
Message-ID: <20161218185227.95AAC60E36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c17233af585b4e46a86acca8ddb126beb5faf95
Commit:        8c17233af585b4e46a86acca8ddb126beb5faf95
Parent:        034931f68dec96265519af6f35ea3726ba7eec82
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 18 15:05:18 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:38:51 2016 +0100

debug: add debug message showing new lv

Make trace easier to follow knowing which LV was added to dtree.
---
 lib/activate/dev_manager.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 73229b3..685c055 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2718,6 +2718,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	int save_pending_delete = dm->track_pending_delete;
 	int merge_in_progress = 0;
 
+	log_debug_activation("Adding new LV %s%s%s to dtree", display_lvname(lv),
+			     layer ? "-" : "", layer ? : "");
 	/* LV with pending delete is never put new into a table */
 	if (lv_is_pending_delete(lv) && !_cached_dm_info(dm->mem, dtree, lv, NULL))
 		return 1; /* Replace with error only when already exists */


