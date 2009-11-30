From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:01 +0100
Subject: [PATCH 01/23] Indent changes
In-Reply-To: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-2-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |    4 ++--
 libdm/libdm-deptree.c      |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index af05f5c..3404e1a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -783,7 +783,7 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 
 	sprintf(errid, "missing_%d_%d", segno, s);
 
-	if (!(id = build_dlid(dm, seg->lv->lvid.s, errid))) 
+	if (!(id = build_dlid(dm, seg->lv->lvid.s, errid)))
 		return_NULL;
 
 	if (!(name = build_dm_name(dm->mem, seg->lv->vg->name,
@@ -1269,7 +1269,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 	default:
 		log_error("_tree_action: Action %u not supported.", action);
 		goto out;
-	}	
+	}
 
 	r = 1;
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 1465fd3..a596c83 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -645,7 +645,7 @@ struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
 void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
 				 uint32_t read_ahead,
 				 uint32_t read_ahead_flags)
-{                          
+{
 	dnode->props.read_ahead = read_ahead;
 	dnode->props.read_ahead_flags = read_ahead_flags;
 }
@@ -1064,8 +1064,8 @@ void dm_tree_use_no_flush_suspend(struct dm_tree_node *dnode)
 }
 
 int dm_tree_suspend_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len)
+			     const char *uuid_prefix,
+			     size_t uuid_prefix_len)
 {
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
@@ -1849,7 +1849,7 @@ int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
 
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 					  uint32_t region_size,
-					  unsigned clustered, 
+					  unsigned clustered,
 					  const char *log_uuid,
 					  unsigned area_count,
 					  uint32_t flags)
-- 
1.6.5.3


