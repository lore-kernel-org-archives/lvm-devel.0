From: dongmao zhang <dmzhang@suse.com>
Date: Thu, 26 Sep 2013 18:53:31 +0800
Subject: [PATCH 4/4] cluster LVM use flag DM_SUPPORT_DELAY_FLUSH
In-Reply-To: <cover.1380191958.git.dmzhang@suse.com>
References: <cover.1380191958.git.dmzhang@suse.com>
Message-ID: <7fb3d42f15d41bd7c1d3107802d162cd823551ba.1380191958.git.dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/mirror/mirrored.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index c3eb27b..af69859 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -378,6 +378,10 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 	if (_block_on_error_available && !(seg->status & PVMOVE))
 		log_flags |= DM_BLOCK_ON_ERROR;
 
+	/*clustered log support delay flush*/
+	if(clustered)
+		log_flags |= DM_SUPPORT_DELAY_FLUSH;
+
 	return dm_tree_node_add_mirror_target_log(node, region_size, clustered, log_dlid, area_count, log_flags);
 }
 
-- 
1.7.3.4


