From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Nov 2014 12:32:51 +0000 (UTC)
Subject: master - cache: never create new table entry for deleted cache
Message-ID: <20141111123251.EF6AB60092@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a6e3683a292adec96a8e2421c86f4aae4756797
Commit:        9a6e3683a292adec96a8e2421c86f4aae4756797
Parent:        42a3305ec7aac3b1b75098c5d1ea7fa9b92a0477
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 11 11:00:51 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 11 13:32:41 2014 +0100

cache: never create new table entry for deleted cache

---
 lib/activate/dev_manager.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5a07fad..4dc08d2 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2678,6 +2678,10 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	uint32_t read_ahead = lv->read_ahead;
 	uint32_t read_ahead_flags = UINT32_C(0);
 
+	/* LV with pending delete is never put new into a table */
+	if (lv_is_pending_delete(lv) && !_cached_dm_info(dm->mem, dtree, lv, NULL))
+		return 1; /* Replace with error only when already exists */
+
 	if (lv_is_cache_pool(lv) &&
 	    !dm_list_empty(&lv->segs_using_this_lv)) {
 		/* cache pool is 'meta' LV and does not have a real device node */


