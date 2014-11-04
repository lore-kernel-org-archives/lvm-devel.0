From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Nov 2014 14:32:59 +0000 (UTC)
Subject: master - libdm: allow to activate any pool with tid == 0
Message-ID: <20141104143259.B17CE61089@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89233544e00a0acfad82055b737ebcce41919d58
Commit:        89233544e00a0acfad82055b737ebcce41919d58
Parent:        7092b47ec90571668c30ef38a9ec251adcff2c82
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 09:42:15 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 4 15:28:00 2014 +0100

libdm: allow to activate any pool with tid == 0

When transaction_id is set 0 for thin-pool, libdm avoids validation
of thin-pool, unless there are real messages to be send to thin-pool.
This relaxes strict policy which always required to know
in front transaction_id for the kernel target.

It now allows to activate thin-pool with any transaction_id
(when transaction_id is passed in)

It is now upto application to validate transaction_id from life
thin-pool volume with transaction_id within it's own metadata.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6b5ee3a..0305077 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.91 - 
 ====================================
+  Allow activation of any thin-pool with passed transaction_id == 0.
   Don't print uninitialized stack bytes when non-root uses dm_check_version().
   Fix selection criteria to not match reserved values when using >, <, >=, <.
   Add DM_LIST_HEAD_INIT macro to libdevmapper.h
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 0048b1c..d120bf5 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3757,7 +3757,8 @@ int dm_tree_node_add_thin_pool_target(struct dm_tree_node *node,
 	seg->metadata->props.delay_resume_if_new = 0;
 	seg->pool->props.delay_resume_if_new = 0;
 
-	node->props.send_messages = 1;
+	/* Validate only transaction_id > 0 when activating thin-pool */
+	node->props.send_messages = transaction_id ? 1 : 0;
 	seg->transaction_id = transaction_id;
 	seg->low_water_mark = low_water_mark;
 	seg->data_block_size = data_block_size;
@@ -3826,6 +3827,7 @@ int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
 
 	tm->message.type = type;
 	dm_list_add(&seg->thin_messages, &tm->list);
+	node->props.send_messages = 1;
 
 	return 1;
 }


