From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:02 +0000 (UTC)
Subject: master - cache: undefined policy is mq
Message-ID: <20150812124102.45D6C61086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22a1337a9ba1ebf73c3f0b27f621d9d8917bf6cf
Commit:        22a1337a9ba1ebf73c3f0b27f621d9d8917bf6cf
Parent:        969ee25a74b50c42f9a2626b7b8991a3d60f750f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 11 15:19:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:11:18 2015 +0200

cache: undefined policy is mq

If the policy_name is unspecified in metadata,
it's automatically 'mq'.
---
 lib/cache_segtype/cache.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index d74fbf1..93436a3 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -378,7 +378,9 @@ static int _cache_add_target_line(struct dev_manager *dm,
 					   metadata_uuid,
 					   data_uuid,
 					   origin_uuid,
-					   seg->cleaner_policy ? "cleaner" : cache_pool_seg->policy_name,
+					   seg->cleaner_policy ? "cleaner" :
+						   /* undefined policy name -> likely an old "mq" */
+						   cache_pool_seg->policy_name ? : "mq",
 					   seg->cleaner_policy ? NULL : cache_pool_seg->policy_settings,
 					   cache_pool_seg->chunk_size))
 		return_0;


