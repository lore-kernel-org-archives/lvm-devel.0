From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:49 +0000 (UTC)
Subject: master - cleanup: remove unneeded assign
Message-ID: <20141030230049.5E67D60AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0da749c9a4c488bd336b2c6b3df7d781a812cb47
Commit:        0da749c9a4c488bd336b2c6b3df7d781a812cb47
Parent:        8bf4cd464f499403aacde52b1c1867ebb31714da
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 28 20:09:08 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

cleanup: remove unneeded assign

---
 lib/metadata/lv_manip.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 36bc2d8..49d2300 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5081,7 +5081,6 @@ struct logical_volume *alloc_lv(struct dm_pool *mem)
 		return NULL;
 	}
 
-	lv->snapshot = NULL;
 	dm_list_init(&lv->snapshot_segs);
 	dm_list_init(&lv->segments);
 	dm_list_init(&lv->tags);


