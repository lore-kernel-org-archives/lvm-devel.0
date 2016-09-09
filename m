From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Sep 2016 19:27:40 +0000 (UTC)
Subject: master - cache: fixed copy&paste from last commit
Message-ID: <20160909192740.5F55861002@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05dc70e22e58114f0313b0eb9f08c6f75dadc03f
Commit:        05dc70e22e58114f0313b0eb9f08c6f75dadc03f
Parent:        ca7921f54b7e58ead6fecee03e6ce8504a0442b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 21:26:38 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 9 21:26:38 2016 +0200

cache: fixed copy&paste from last commit

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9fbd689..2dc0fd8 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1432,7 +1432,7 @@ int dev_manager_cache_status(struct dev_manager *dm,
 							c->total_blocks);
 		(*status)->metadata_usage = dm_make_percent(c->metadata_used_blocks,
 							    c->metadata_total_blocks);
-		(*status)->dirty_usage = (s->cache->used_blocks) ?
+		(*status)->dirty_usage = (c->used_blocks) ?
 			dm_make_percent(c->dirty_blocks,
 					c->used_blocks) : DM_PERCENT_0;
 	}


