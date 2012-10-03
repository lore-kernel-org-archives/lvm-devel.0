From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:45 +0000 (UTC)
Subject: master - libdm: reset delay flag for devs used by thin
Message-ID: <20121003131445.8CE442319@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1946a453297535829d3d698dfa51733d8a223400
Commit:        1946a453297535829d3d698dfa51733d8a223400
Parent:        21c401006c3c12b75354736db9a2f75e7993f489
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 27 16:57:14 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 15:04:41 2012 +0200

libdm: reset delay flag for devs used by thin

Patch clears the flag if thin pool is stacked over mirror.

Since thin pool could be used to stack device over mirrors,
it needs resume properly i.e. mirrors with corelog which are otherwise
unconditionally skipped (for pvmove functionality).
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c46db61..338cfaf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.77 -
 =================================
+  Always reset delay_resume_if_new flag when stacking thin pool.
   Don't create value for dm_config_node and require dm_config_create_value call.
   Check for existing new_name for dmsetup rename.
   Fix memory leak in dmsetup _get_split_name() error path.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index f675d0d..096eba2 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -3107,6 +3107,10 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 	if (!_link_tree_nodes(node, seg->pool))
 		return_0;
 
+	/* Clean flag delay_resume_if_new - so corelog gets resumed */
+	seg->metadata->props.delay_resume_if_new = 0;
+	seg->pool->props.delay_resume_if_new = 0;
+
 	node->props.send_messages = 1;
 	seg->transaction_id = transaction_id;
 	seg->low_water_mark = low_water_mark;


