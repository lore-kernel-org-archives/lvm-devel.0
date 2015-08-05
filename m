From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  5 Aug 2015 07:30:30 +0000 (UTC)
Subject: master - libdm: Whitespace.
Message-ID: <20150805073030.7150660E1D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f334afb9836a792fd4e277d02ad6f317faa78ab
Commit:        2f334afb9836a792fd4e277d02ad6f317faa78ab
Parent:        88551add9725ab9a6866bce2cd1e4428078d76d1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 5 05:21:58 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 5 05:21:58 2015 +0100

libdm: Whitespace.

---
 libdm/libdevmapper.h |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 11ba0a3..4a1703e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
- * Copyright (C) 2006 Rackable Systems All rights reserved.  
+ * Copyright (C) 2006 Rackable Systems All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -528,12 +528,12 @@ struct dm_tree_node;
 /*
  * Initialise an empty dependency tree.
  *
- * The tree consists of a root node together with one node for each mapped 
+ * The tree consists of a root node together with one node for each mapped
  * device which has child nodes for each device referenced in its table.
  *
  * Every node in the tree has one or more children and one or more parents.
  *
- * The root node is the parent/child of every node that doesn't have other 
+ * The root node is the parent/child of every node that doesn't have other
  * parents/children.
  */
 struct dm_tree *dm_tree_create(void);
@@ -641,7 +641,7 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
  * Skip the filesystem sync when suspending.
  * Does nothing with other functions.
  * Use this when no snapshots are involved.
- */ 
+ */
 void dm_tree_skip_lockfs(struct dm_tree_node *dnode);
 
 /*
@@ -712,7 +712,7 @@ int dm_tree_node_add_crypt_target(struct dm_tree_node *node,
 				  const char *key);
 int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 				   uint64_t size);
- 
+
 /* Mirror log flags */
 #define DM_NOSYNC		0x00000001	/* Known already in sync */
 #define DM_FORCESYNC		0x00000002	/* Force resync */
@@ -1285,7 +1285,7 @@ struct dm_list *dm_list_prev(const struct dm_list *head, const struct dm_list *e
 struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *elem);
 
 /*
- * Given the address v of an instance of 'struct dm_list' called 'head' 
+ * Given the address v of an instance of 'struct dm_list' called 'head'
  * contained in a structure of type t, return the containing structure.
  */
 #define dm_list_struct_base(v, t, head) \
@@ -1317,7 +1317,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
 	for (v = (head)->n; v != head; v = v->n)
 
 /*
- * Set v to each element in a list in turn, starting from the element 
+ * Set v to each element in a list in turn, starting from the element
  * in front of 'start'.
  * You can use this to 'unwind' a list_iterate and back out actions on
  * already-processed elements.
@@ -1372,7 +1372,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
 	dm_list_iterate_items_gen_safe(v, t, (head), list)
 
 /*
- * Walk a list backwards, setting 'v' in turn to the containing structure 
+ * Walk a list backwards, setting 'v' in turn to the containing structure
  * of each item.
  * The containing structure should be the same type as 'v'.
  * The 'struct dm_list' variable within the containing structure is 'field'.
@@ -1383,7 +1383,7 @@ struct dm_list *dm_list_next(const struct dm_list *head, const struct dm_list *e
 	     v = dm_list_struct_base(v->field.p, __typeof__(*v), field))
 
 /*
- * Walk a list backwards, setting 'v' in turn to the containing structure 
+ * Walk a list backwards, setting 'v' in turn to the containing structure
  * of each item.
  * The containing structure should be the same type as 'v'.
  * The list should be 'struct dm_list list' within the containing structure.
@@ -1432,7 +1432,7 @@ int dm_split_words(char *buffer, unsigned max,
 		   unsigned ignore_comments, /* Not implemented */
 		   char **argv);
 
-/* 
+/*
  * Returns -1 if buffer too small
  */
 int dm_snprintf(char *buf, size_t bufsize, const char *format, ...)
@@ -1555,8 +1555,8 @@ typedef enum {
  * Set use_si_units to 1 for a suffix that does distinguish.
  */
 const char *dm_size_to_string(struct dm_pool *mem, uint64_t size,
-			      char unit_type, int use_si_units, 
-			      uint64_t unit_factor, int include_suffix, 
+			      char unit_type, int use_si_units,
+			      uint64_t unit_factor, int include_suffix,
 			      dm_size_suffix_t suffix_type);
 
 /**************************
@@ -1683,7 +1683,7 @@ int dm_timestamp_get(struct dm_timestamp *ts);
 
 /*
  * Compare two timestamps.
- * 
+ *
  * Return: -1 if ts1 is less than ts2
  *  	    0 if ts1 is equal to ts2
  *          1 if ts1 is greater than ts2


