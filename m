From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 Aug 2014 14:47:31 +0000 (UTC)
Subject: master - cache: fix allocation size
Message-ID: <20140827144731.073DA60DE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22bfac5dc24f0f10be270cf86e9d7bc2d627cc6c
Commit:        22bfac5dc24f0f10be270cf86e9d7bc2d627cc6c
Parent:        8b9eb95ea9d2a950286f622f6d2d571c76642654
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 27 16:45:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 27 16:47:14 2014 +0200

cache: fix allocation size

Commit 0b3d0e79f694ac9dc5a29270b2f791a250980058 caused regression
in allocation of cache pool. This patch is restoring corect size
for allocation.
---
 lib/metadata/lv_manip.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a5614f6..baf431f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1655,8 +1655,10 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 		ah->region_size = 0;
 		ah->mirror_logs_separate =
 			find_config_tree_bool(cmd, allocation_cache_pool_metadata_require_separate_pvs_CFG, NULL);
-		if (!ah->mirror_logs_separate)
+		if (!ah->mirror_logs_separate) {
 			ah->alloc_and_split_meta = 1;
+			total_extents += ah->log_len;
+		}
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :


