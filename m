From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:32 +0200
Subject: [PATCH 05/13] Replicator: use dm_tree_suspend_children
In-Reply-To: <1254751240-17431-4-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-3-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-4-git-send-email-zkabelac@redhat.com>
Message-ID: <1254751240-17431-5-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Before of suspend/deactivation of replicator_dev node
the suspend of replicator node is mandatory.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 19deab8..55daf14 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1169,6 +1169,7 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root)
 			continue;
 
 		dm_tree_set_cookie(root, 0);
+		dm_tree_suspend_children(root, uuid, strlen(uuid), 1);
 		r = dm_tree_deactivate_children(root, uuid, strlen(uuid));
 		if (!dm_udev_wait(dm_tree_get_cookie(root)))
 			stack;
@@ -1208,6 +1209,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 	case DEACTIVATE:
  		/* Deactivate LV and all devices it references that nothing else has open. */
 		dm_tree_set_cookie(root, 0);
+		dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1, 1);
 		r = dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
 		if (!dm_udev_wait(dm_tree_get_cookie(root)))
 			stack;
-- 
1.6.5.rc2


