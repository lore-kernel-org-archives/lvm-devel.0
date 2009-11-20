From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 16:29:10 -0500
Subject: [PATCH 3/5] libdm-deptree-return-failure-deactivate-children
In-Reply-To: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
References: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258752552-1589-3-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Return error immediately to dm_tree_deactivate_children() callers.

Otherwise deactivate_lv can fail silently.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 libdm/libdm-deptree.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6f5355d..91f7177 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1043,11 +1043,12 @@ int dm_tree_deactivate_children(struct dm_tree_node *dnode,
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);
-			continue;
+			return 0;
 		}
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len);
+			if (!dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len))
+				return_0;
 	}
 
 	return 1;
-- 
1.6.5.2


