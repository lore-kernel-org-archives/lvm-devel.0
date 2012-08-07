From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:21 +0000 (UTC)
Subject: master - comments: misc updates
Message-ID: <20120807203022.192893506@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4dab0d3175a9bc6658611f06ba8b0c05b40e06bd
Commit:        4dab0d3175a9bc6658611f06ba8b0c05b40e06bd
Parent:        016997acaf8bc59e5b48e9b33ef2db0596e25063
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 18:34:30 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 18:34:30 2012 +0100

comments: misc updates

Miscellaneous clarifications to comments.
---
 doc/example.conf.in   |    6 +++---
 lib/mm/memlock.c      |    1 +
 libdm/libdevmapper.h  |    6 +++---
 libdm/libdm-deptree.c |    8 ++++----
 4 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index a085014..576397b 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -86,9 +86,9 @@ devices {
     # It is safe to delete the contents: the tools regenerate it.
     # (The old setting 'cache' is still respected if neither of
     # these new ones is present.)
-    # N.B. This type of caching is obsolete and existing .cache
-    # file is removed if the list of devices is obtained from
-    # udev by setting the obtain_device_list_from_udev to 1.
+    # N.B. If obtain_device_list_from_udev is set to 1 the list of
+    # devices is instead obtained from udev and any existing .cache
+    # file is removed.
     cache_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
     cache_file_prefix = ""
 
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index dfc0d42..2240a1d 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -131,6 +131,7 @@ static void _allocate_memory(void)
 	    ((_size_stack * 2) < limit.rlim_cur) &&
 	    ((stack_mem = alloca(_size_stack))))
 		_touch_memory(stack_mem, _size_stack);
+	/* FIXME else warn user setting got ignored */
 
 	if ((temp_malloc_mem = malloc(_size_malloc_tmp)))
 		_touch_memory(temp_malloc_mem, _size_malloc_tmp);
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0786b38..28685b2 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -650,8 +650,8 @@ typedef enum {
 	DM_THIN_MESSAGE_CREATE_THIN,		/* device_id */
 	DM_THIN_MESSAGE_DELETE,			/* device_id */
 	DM_THIN_MESSAGE_SET_TRANSACTION_ID,	/* current_id, new_id */
-	DM_THIN_MESSAGE_RESERVE_METADATA_SNAP,	/* 1.1 */
-	DM_THIN_MESSAGE_RELEASE_METADATA_SNAP,	/* 1.1 */
+	DM_THIN_MESSAGE_RESERVE_METADATA_SNAP,	/* target version >= 1.1 */
+	DM_THIN_MESSAGE_RELEASE_METADATA_SNAP,	/* target version >= 1.1 */
 } dm_thin_message_t;
 
 int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
@@ -663,7 +663,7 @@ int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
  *   ignore      - Disable discard support
  *   no_passdown - Don't pass discard down to underlaying data device,
  *                 just remove the mapping
- * Feature is available for 1.1
+ * Feature is available since version 1.1 of the thin target.
  */
 int dm_tree_node_set_thin_pool_discard(struct dm_tree_node *node,
 				       unsigned ignore,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index acd82ca..031ce5e 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -192,8 +192,8 @@ struct load_segment {
 	uint64_t low_water_mark;	/* Thin_pool */
 	uint32_t data_block_size;       /* Thin_pool */
 	unsigned skip_block_zeroing;	/* Thin_pool */
-	unsigned ignore_discard;	/* Thin_pool 1.1 */
-	unsigned no_discard_passdown;	/* Thin_pool 1.1 */
+	unsigned ignore_discard;	/* Thin_pool target vsn 1.1 */
+	unsigned no_discard_passdown;	/* Thin_pool target vsn 1.1 */
 	uint32_t device_id;		/* Thin */
 
 };
@@ -1411,10 +1411,10 @@ static int _thin_pool_node_message(struct dm_tree_node *dnode, struct thin_messa
 				m->u.m_set_transaction_id.current_id,
 				m->u.m_set_transaction_id.new_id);
 		break;
-	case DM_THIN_MESSAGE_RESERVE_METADATA_SNAP: /* 1.1 */
+	case DM_THIN_MESSAGE_RESERVE_METADATA_SNAP: /* target vsn 1.1 */
 		r = dm_snprintf(buf, sizeof(buf), "reserve_metadata_snap");
 		break;
-	case DM_THIN_MESSAGE_RELEASE_METADATA_SNAP: /* 1.1 */
+	case DM_THIN_MESSAGE_RELEASE_METADATA_SNAP: /* target vsn 1.1 */
 		r = dm_snprintf(buf, sizeof(buf), "release_metadata_snap");
 		break;
 	default:


