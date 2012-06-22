From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Jun 2012 11:51:31 +0000 (UTC)
Subject: master - cleanup: use dev_t type
Message-ID: <20120622115131.0B02B1688@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fc4c99b2fc745b0167520f9395e9e2e39c162e8
Commit:        6fc4c99b2fc745b0167520f9395e9e2e39c162e8
Parent:        6bd3864b41fa1cb8e2763185ff860d320c45930f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 21 12:55:30 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 13:50:21 2012 +0200

cleanup: use dev_t type

---
 libdm/libdm-deptree.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6b428d6..91bafe5 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -462,7 +462,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 						 uint16_t udev_flags)
 {
 	struct dm_tree_node *node;
-	uint64_t dev;
+	dev_t dev;
 
 	if (!(node = dm_pool_zalloc(dtree->mem, sizeof(*node)))) {
 		log_error("_create_dm_tree_node alloc failed");
@@ -506,7 +506,7 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 static struct dm_tree_node *_find_dm_tree_node(struct dm_tree *dtree,
 					       uint32_t major, uint32_t minor)
 {
-	uint64_t dev = MKDEV(major, minor);
+	dev_t dev = MKDEV(major, minor);
 
 	return dm_hash_lookup_binary(dtree->devs, (const char *) &dev,
 				  sizeof(dev));


