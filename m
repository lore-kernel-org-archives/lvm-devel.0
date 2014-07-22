From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:42:03 +0000 (UTC)
Subject: master - cleanup: show better messages
Message-ID: <20140722204203.96D556024D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7d81e11574baad841def2fc1efb7a22ea44cd3e
Commit:        d7d81e11574baad841def2fc1efb7a22ea44cd3e
Parent:        894eda4707dbcf9e160922d95621703c0fa58f94
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 22 17:29:53 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 22 22:41:40 2014 +0200

cleanup: show better messages

---
 lib/metadata/cache_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index e6b6551..184df79 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -41,8 +41,8 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 	}
 
 	if (*chunk_size & (DM_CACHE_MIN_DATA_BLOCK_SIZE - 1)) {
-		log_error("Chunk size must be a multiple of %u sectors.",
-			  DM_CACHE_MIN_DATA_BLOCK_SIZE);
+		log_error("Chunk size must be a multiple of %s.",
+			  display_size(vg->cmd, DM_CACHE_MIN_DATA_BLOCK_SIZE));
 		return 0;
 	}
 


