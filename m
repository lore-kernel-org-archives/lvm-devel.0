From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:02 +0100
Subject: [PATCH 02/23] Skip cast of void* for assigment
In-Reply-To: <1259581043-15308-2-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-3-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3404e1a..69b654d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1095,7 +1095,7 @@ static int _create_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 	int r = 1;
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
-		if (!(lvlayer = (struct lv_layer *) dm_tree_node_get_context(child)))
+		if (!(lvlayer = dm_tree_node_get_context(child)))
 			continue;
 
 		/* Detect rename */
-- 
1.6.5.3


