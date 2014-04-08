From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:03:06 +0000 (UTC)
Subject: master - cleanup: libdm drop already zeroed elements
Message-ID: <20140408090306.44C2B60D76@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfbf6b7c122bc1851834daeec8ade6e1becaf454
Commit:        bfbf6b7c122bc1851834daeec8ade6e1becaf454
Parent:        a41ab41b704ace5a82efada9acd76965c6274078
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 7 21:37:58 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:16 2014 +0200

cleanup: libdm drop already zeroed elements

Drop zeroing of zalloc-ed memory.
---
 libdm/libdm-deptree.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 7c4da9b..0a53755 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -503,7 +503,6 @@ static struct dm_tree_node *_create_dm_tree_node(struct dm_tree *dtree,
 	node->info = *info;
 	node->context = context;
 	node->udev_flags = udev_flags;
-	node->activation_priority = 0;
 
 	dm_list_init(&node->uses);
 	dm_list_init(&node->used_by);
@@ -1136,8 +1135,6 @@ struct dm_tree_node *dm_tree_add_new_dev_with_udev_flags(struct dm_tree *dtree,
 
 		dnode->props.major = major;
 		dnode->props.minor = minor;
-		dnode->props.new_name = NULL;
-		dnode->props.size_changed = 0;
 	} else if (strcmp(name, dnode->name)) {
 		/* Do we need to rename node? */
 		if (!(dnode->props.new_name = dm_pool_strdup(dtree->mem, name))) {
@@ -2813,15 +2810,7 @@ static struct load_segment *_add_segment(struct dm_tree_node *dnode, unsigned ty
 
 	seg->type = type;
 	seg->size = size;
-	seg->area_count = 0;
 	dm_list_init(&seg->areas);
-	seg->stripe_size = 0;
-	seg->persistent = 0;
-	seg->chunk_size = 0;
-	seg->cow = NULL;
-	seg->origin = NULL;
-	seg->merge = NULL;
-
 	dm_list_add(&dnode->props.segs, &seg->list);
 	dnode->props.segment_count++;
 


