From: meyering@sourceware.org <meyering@sourceware.org>
Date: 7 Aug 2007 09:06:08 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20070807090608.2867.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-08-07 09:06:05

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c lvm-functions.h refresh_clvmd.c 
	lib/activate   : activate.c activate.h 
	lib/datastruct : btree.c btree.h list.c list.h str_list.c 
	                 str_list.h 
	lib/display    : display.c display.h 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : toollib.c toollib.h tools.h vgdisplay.c 

Log message:
	Add "const" attributes where possible: first cut.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.678&r2=1.679
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/btree.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/btree.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2007/08/06 20:38:41	1.678
+++ LVM2/WHATS_NEW	2007/08/07 09:06:04	1.679
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Add const attributes where possible, first cut.
   Add support for renaming mirrored LVs.
   Factor out core of lvrename() to lv_rename lvm library function.
   Add --log argument to specify log type for mirrors.
--- LVM2/daemons/clvmd/lvm-functions.c	2007/04/27 17:46:16	1.30
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/08/07 09:06:05	1.31
@@ -431,7 +431,7 @@
 }
 
 /* Check if a VG is un use by LVM1 so we don't stomp on it */
-int do_check_lvm1(char *vgname)
+int do_check_lvm1(const char *vgname)
 {
 	int status;
 
--- LVM2/daemons/clvmd/lvm-functions.h	2006/10/05 13:55:50	1.4
+++ LVM2/daemons/clvmd/lvm-functions.h	2007/08/07 09:06:05	1.5
@@ -24,7 +24,7 @@
 		      char *resource);
 extern int post_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 			char *resource);
-extern int do_check_lvm1(char *vgname);
+extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
 extern int init_lvm(int using_gulm);
 extern void init_lvhash(void);
--- LVM2/daemons/clvmd/refresh_clvmd.c	2006/12/01 23:10:25	1.2
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2007/08/07 09:06:05	1.3
@@ -79,7 +79,7 @@
 }
 
 /* Send a request and return the status */
-static int _send_request(char *inbuf, int inlen, char **retbuf)
+static int _send_request(const char *inbuf, int inlen, char **retbuf)
 {
 	char outbuf[PIPE_BUF];
 	struct clvm_header *outheader = (struct clvm_header *) outbuf;
--- LVM2/lib/activate/activate.c	2007/08/01 20:29:07	1.125
+++ LVM2/lib/activate/activate.c	2007/08/07 09:06:05	1.126
@@ -642,9 +642,9 @@
 	return _lvs_in_vg_activated(vg, 0);
 }
 
-int lvs_in_vg_opened(struct volume_group *vg)
+int lvs_in_vg_opened(const struct volume_group *vg)
 {
-	struct lv_list *lvl;
+	const struct lv_list *lvl;
 	int count = 0;
 
 	if (!activation())
--- LVM2/lib/activate/activate.h	2007/07/18 15:38:57	1.56
+++ LVM2/lib/activate/activate.h	2007/08/07 09:06:05	1.57
@@ -84,7 +84,7 @@
  */
 int lvs_in_vg_activated(struct volume_group *vg);
 int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg);
-int lvs_in_vg_opened(struct volume_group *vg);
+int lvs_in_vg_opened(const struct volume_group *vg);
 
 
 int monitor_dev_for_events(struct cmd_context *cmd,
--- LVM2/lib/datastruct/btree.c	2006/04/19 15:33:05	1.9
+++ LVM2/lib/datastruct/btree.c	2007/08/07 09:06:05	1.10
@@ -55,7 +55,8 @@
 #endif
 }
 
-static struct node **_lookup(struct node **c, uint32_t key, struct node **p)
+static struct node **_lookup(struct node *const *c, uint32_t key,
+			     struct node **p)
 {
 	*p = NULL;
 	while (*c) {
@@ -70,10 +71,10 @@
 			c = &(*c)->r;
 	}
 
-	return c;
+	return (struct node **)c;
 }
 
-void *btree_lookup(struct btree *t, uint32_t k)
+void *btree_lookup(const struct btree *t, uint32_t k)
 {
 	uint32_t key = _shuffle(k);
 	struct node *p, **c = _lookup(&t->root, key, &p);
@@ -102,7 +103,7 @@
 	return 1;
 }
 
-void *btree_get_data(struct btree_iter *it)
+void *btree_get_data(const struct btree_iter *it)
 {
 	return ((struct node *) it)->data;
 }
@@ -114,7 +115,7 @@
 	return n;
 }
 
-struct btree_iter *btree_first(struct btree *t)
+struct btree_iter *btree_first(const struct btree *t)
 {
 	if (!t->root)
 		return NULL;
@@ -122,7 +123,7 @@
 	return (struct btree_iter *) _left(t->root);
 }
 
-struct btree_iter *btree_next(struct btree_iter *it)
+struct btree_iter *btree_next(const struct btree_iter *it)
 {
 	struct node *n = (struct node *) it;
 	uint32_t k = n->key;
--- LVM2/lib/datastruct/btree.h	2005/10/16 23:03:57	1.4
+++ LVM2/lib/datastruct/btree.h	2007/08/07 09:06:05	1.5
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004, 2007 Sistina Software, Inc. All rights reserved.  
  * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -20,13 +20,13 @@
 
 struct btree *btree_create(struct dm_pool *mem);
 
-void *btree_lookup(struct btree *t, uint32_t k);
+void *btree_lookup(const struct btree *t, uint32_t k);
 int btree_insert(struct btree *t, uint32_t k, void *data);
 
 struct btree_iter;
-void *btree_get_data(struct btree_iter *it);
+void *btree_get_data(const struct btree_iter *it);
 
-struct btree_iter *btree_first(struct btree *t);
-struct btree_iter *btree_next(struct btree_iter *it);
+struct btree_iter *btree_first(const struct btree *t);
+struct btree_iter *btree_next(const struct btree_iter *it);
 
 #endif
--- LVM2/lib/datastruct/list.c	2006/04/19 18:12:33	1.1
+++ LVM2/lib/datastruct/list.c	2007/08/07 09:06:05	1.2
@@ -68,7 +68,7 @@
 /*
  * Is the list empty?
  */
-int list_empty(struct list *head)
+int list_empty(const struct list *head)
 {
 	return head->n == head;
 }
@@ -76,7 +76,7 @@
 /*
  * Is this the first element of the list?
  */
-int list_start(struct list *head, struct list *elem)
+int list_start(const struct list *head, const struct list *elem)
 {
 	return elem->p == head;
 }
@@ -84,7 +84,7 @@
 /*
  * Is this the last element of the list?
  */
-int list_end(struct list *head, struct list *elem)
+int list_end(const struct list *head, const struct list *elem)
 {
 	return elem->n == head;
 }
@@ -92,7 +92,7 @@
 /*
  * Return first element of the list or NULL if empty
  */
-struct list *list_first(struct list *head)
+struct list *list_first(const struct list *head)
 {
 	return (list_empty(head) ? NULL : head->n);
 }
@@ -100,7 +100,7 @@
 /*
  * Return last element of the list or NULL if empty
  */
-struct list *list_last(struct list *head)
+struct list *list_last(const struct list *head)
 {
 	return (list_empty(head) ? NULL : head->p);
 }
@@ -108,7 +108,7 @@
 /*
  * Return the previous element of the list, or NULL if we've reached the start.
  */
-struct list *list_prev(struct list *head, struct list *elem)
+struct list *list_prev(const struct list *head, const struct list *elem)
 {
 	return (list_start(head, elem) ? NULL : elem->p);
 }
@@ -116,7 +116,7 @@
 /*
  * Return the next element of the list, or NULL if we've reached the end.
  */
-struct list *list_next(struct list *head, struct list *elem)
+struct list *list_next(const struct list *head, const struct list *elem)
 {
 	return (list_end(head, elem) ? NULL : elem->n);
 }
--- LVM2/lib/datastruct/list.h	2006/04/19 15:33:05	1.23
+++ LVM2/lib/datastruct/list.h	2007/08/07 09:06:05	1.24
@@ -57,37 +57,37 @@
 /*
  * Is the list empty?
  */
-int list_empty(struct list *head);
+int list_empty(const struct list *head);
 
 /*
  * Is this the first element of the list?
  */
-int list_start(struct list *head, struct list *elem);
+int list_start(const struct list *head, const struct list *elem);
 
 /*
  * Is this the last element of the list?
  */
-int list_end(struct list *head, struct list *elem);
+int list_end(const struct list *head, const struct list *elem);
 
 /*
  * Return first element of the list or NULL if empty
  */
-struct list *list_first(struct list *head);
+struct list *list_first(const struct list *head);
 
 /*
  * Return last element of the list or NULL if empty
  */
-struct list *list_last(struct list *head);
+struct list *list_last(const struct list *head);
 
 /*
  * Return the previous element of the list, or NULL if we've reached the start.
  */
-struct list *list_prev(struct list *head, struct list *elem);
+struct list *list_prev(const struct list *head, const struct list *elem);
 
 /*
  * Return the next element of the list, or NULL if we've reached the end.
  */
-struct list *list_next(struct list *head, struct list *elem);
+struct list *list_next(const struct list *head, const struct list *elem);
 
 /*
  * Given the address v of an instance of 'struct list' called 'head' 
--- LVM2/lib/datastruct/str_list.c	2005/10/16 23:03:57	1.6
+++ LVM2/lib/datastruct/str_list.c	2007/08/07 09:06:05	1.7
@@ -66,7 +66,8 @@
 	return 1;
 }
 
-int str_list_dup(struct dm_pool *mem, struct list *sllnew, struct list *sllold)
+int str_list_dup(struct dm_pool *mem, struct list *sllnew,
+		 const struct list *sllold)
 {
 	struct str_list *sl;
 
@@ -85,7 +86,7 @@
 /*
  * Is item on list?
  */
-int str_list_match_item(struct list *sll, const char *str)
+int str_list_match_item(const struct list *sll, const char *str)
 {
 	struct str_list *sl;
 
@@ -99,7 +100,7 @@
 /*
  * Is at least one item on both lists?
  */
-int str_list_match_list(struct list *sll, struct list *sll2)
+int str_list_match_list(const struct list *sll, const struct list *sll2)
 {
 	struct str_list *sl;
 
@@ -113,7 +114,7 @@
 /*
  * Do both lists contain the same set of items?
  */
-int str_list_lists_equal(struct list *sll, struct list *sll2)
+int str_list_lists_equal(const struct list *sll, const struct list *sll2)
 {
 	struct str_list *sl;
 
--- LVM2/lib/datastruct/str_list.h	2005/10/16 23:03:57	1.6
+++ LVM2/lib/datastruct/str_list.h	2007/08/07 09:06:05	1.7
@@ -19,9 +19,10 @@
 struct list *str_list_create(struct dm_pool *mem);
 int str_list_add(struct dm_pool *mem, struct list *sll, const char *str);
 int str_list_del(struct list *sll, const char *str);
-int str_list_match_item(struct list *sll, const char *str);
-int str_list_match_list(struct list *sll, struct list *sll2);
-int str_list_lists_equal(struct list *sll, struct list *sll2);
-int str_list_dup(struct dm_pool *mem, struct list *sllnew, struct list *sllold);
+int str_list_match_item(const struct list *sll, const char *str);
+int str_list_match_list(const struct list *sll, const struct list *sll2);
+int str_list_lists_equal(const struct list *sll, const struct list *sll2);
+int str_list_dup(struct dm_pool *mem, struct list *sllnew,
+		 const struct list *sllold);
 
 #endif
--- LVM2/lib/display/display.c	2007/05/31 20:26:11	1.75
+++ LVM2/lib/display/display.c	2007/08/07 09:06:05	1.76
@@ -147,7 +147,8 @@
 }
 
 /* Size supplied in sectors */
-static const char *_display_size(struct cmd_context *cmd, uint64_t size, size_len_t sl)
+static const char *_display_size(const struct cmd_context *cmd,
+				 uint64_t size, size_len_t sl)
 {
 	int s;
 	int suffix = 1, precision;
@@ -217,22 +218,22 @@
 	return size_buf;
 }
 
-const char *display_size_long(struct cmd_context *cmd, uint64_t size)
+const char *display_size_long(const struct cmd_context *cmd, uint64_t size)
 {
 	return _display_size(cmd, size, SIZE_LONG);
 }
 
-const char *display_size_units(struct cmd_context *cmd, uint64_t size)
+const char *display_size_units(const struct cmd_context *cmd, uint64_t size)
 {
 	return _display_size(cmd, size, SIZE_UNIT);
 }
 
-const char *display_size(struct cmd_context *cmd, uint64_t size)
+const char *display_size(const struct cmd_context *cmd, uint64_t size)
 {
 	return _display_size(cmd, size, SIZE_SHORT);
 }
 
-void pvdisplay_colons(struct physical_volume *pv)
+void pvdisplay_colons(const struct physical_volume *pv)
 {
 	char uuid[64] __attribute((aligned(8)));
 
@@ -258,9 +259,9 @@
 	return;
 }
 
-void pvdisplay_segments(struct physical_volume *pv)
+void pvdisplay_segments(const struct physical_volume *pv)
 {
-	struct pv_segment *pvseg;
+	const struct pv_segment *pvseg;
 
 	if (pv->pe_size)
 		log_print("--- Physical Segments ---");
@@ -286,7 +287,8 @@
 }
 
 /* FIXME Include label fields */
-void pvdisplay_full(struct cmd_context *cmd, struct physical_volume *pv,
+void pvdisplay_full(const struct cmd_context *cmd,
+		    const struct physical_volume *pv,
 		    void *handle __attribute((unused)))
 {
 	char uuid[64] __attribute((aligned(8)));
@@ -346,9 +348,9 @@
 	return;
 }
 
-int pvdisplay_short(struct cmd_context *cmd __attribute((unused)),
-		    struct volume_group *vg __attribute((unused)),
-		    struct physical_volume *pv,
+int pvdisplay_short(const struct cmd_context *cmd __attribute((unused)),
+		    const struct volume_group *vg __attribute((unused)),
+		    const struct physical_volume *pv,
 		    void *handle __attribute((unused)))
 {
 	char uuid[64] __attribute((aligned(8)));
@@ -373,7 +375,7 @@
 	return 0;
 }
 
-void lvdisplay_colons(struct logical_volume *lv)
+void lvdisplay_colons(const struct logical_volume *lv)
 {
 	int inkernel;
 	struct lvinfo info;
@@ -393,7 +395,8 @@
 	return;
 }
 
-int lvdisplay_full(struct cmd_context *cmd, struct logical_volume *lv,
+int lvdisplay_full(struct cmd_context *cmd,
+		   const struct logical_volume *lv,
 		   void *handle __attribute((unused)))
 {
 	struct lvinfo info;
@@ -535,9 +538,9 @@
 	}
 }
 
-int lvdisplay_segments(struct logical_volume *lv)
+int lvdisplay_segments(const struct logical_volume *lv)
 {
-	struct lv_segment *seg;
+	const struct lv_segment *seg;
 
 	log_print("--- Segments ---");
 
@@ -555,12 +558,12 @@
 	return 1;
 }
 
-void vgdisplay_extents(struct volume_group *vg __attribute((unused)))
+void vgdisplay_extents(const struct volume_group *vg __attribute((unused)))
 {
 	return;
 }
 
-void vgdisplay_full(struct volume_group *vg)
+void vgdisplay_full(const struct volume_group *vg)
 {
 	uint32_t access;
 	uint32_t active_pvs;
@@ -639,7 +642,7 @@
 	return;
 }
 
-void vgdisplay_colons(struct volume_group *vg)
+void vgdisplay_colons(const struct volume_group *vg)
 {
 	uint32_t active_pvs;
 	const char *access;
@@ -691,7 +694,7 @@
 	return;
 }
 
-void vgdisplay_short(struct volume_group *vg)
+void vgdisplay_short(const struct volume_group *vg)
 {
 	log_print("\"%s\" %-9s [%-9s used / %s free]", vg->name,
 /********* FIXME if "open" print "/used" else print "/idle"???  ******/
@@ -705,18 +708,18 @@
 	return;
 }
 
-void display_formats(struct cmd_context *cmd)
+void display_formats(const struct cmd_context *cmd)
 {
-	struct format_type *fmt;
+	const struct format_type *fmt;
 
 	list_iterate_items(fmt, &cmd->formats) {
 		log_print("%s", fmt->name);
 	}
 }
 
-void display_segtypes(struct cmd_context *cmd)
+void display_segtypes(const struct cmd_context *cmd)
 {
-	struct segment_type *segtype;
+	const struct segment_type *segtype;
 
 	list_iterate_items(segtype, &cmd->segtypes) {
 		log_print("%s", segtype->name);
--- LVM2/lib/display/display.h	2007/07/18 15:38:57	1.18
+++ LVM2/lib/display/display.h	2007/08/07 09:06:05	1.19
@@ -23,32 +23,34 @@
 uint64_t units_to_bytes(const char *units, char *unit_type);
 
 /* Specify size in KB */
-const char *display_size(struct cmd_context *cmd, uint64_t size);
-const char *display_size_long(struct cmd_context *cmd, uint64_t size);
-const char *display_size_units(struct cmd_context *cmd, uint64_t size);
+const char *display_size(const struct cmd_context *cmd, uint64_t size);
+const char *display_size_long(const struct cmd_context *cmd, uint64_t size);
+const char *display_size_units(const struct cmd_context *cmd, uint64_t size);
 
 char *display_uuid(char *uuidstr);
 void display_stripe(const struct lv_segment *seg, uint32_t s, const char *pre);
 
-void pvdisplay_colons(struct physical_volume *pv);
-void pvdisplay_segments(struct physical_volume *pv);
-void pvdisplay_full(struct cmd_context *cmd, struct physical_volume *pv,
+void pvdisplay_colons(const struct physical_volume *pv);
+void pvdisplay_segments(const struct physical_volume *pv);
+void pvdisplay_full(const struct cmd_context *cmd,
+		    const struct physical_volume *pv,
 		    void *handle);
-int pvdisplay_short(struct cmd_context *cmd, struct volume_group *vg,
-		    struct physical_volume *pv, void *handle);
-
-void lvdisplay_colons(struct logical_volume *lv);
-int lvdisplay_segments(struct logical_volume *lv);
-int lvdisplay_full(struct cmd_context *cmd, struct logical_volume *lv,
+int pvdisplay_short(const struct cmd_context *cmd,
+		    const struct volume_group *vg,
+		    const struct physical_volume *pv, void *handle);
+
+void lvdisplay_colons(const struct logical_volume *lv);
+int lvdisplay_segments(const struct logical_volume *lv);
+int lvdisplay_full(struct cmd_context *cmd, const struct logical_volume *lv,
 		   void *handle);
 
-void vgdisplay_extents(struct volume_group *vg);
-void vgdisplay_full(struct volume_group *vg);
-void vgdisplay_colons(struct volume_group *vg);
-void vgdisplay_short(struct volume_group *vg);
+void vgdisplay_extents(const struct volume_group *vg);
+void vgdisplay_full(const struct volume_group *vg);
+void vgdisplay_colons(const struct volume_group *vg);
+void vgdisplay_short(const struct volume_group *vg);
 
-void display_formats(struct cmd_context *cmd);
-void display_segtypes(struct cmd_context *cmd);
+void display_formats(const struct cmd_context *cmd);
+void display_segtypes(const struct cmd_context *cmd);
 
 /*
  * Allocation policy display conversion routines.
--- LVM2/lib/metadata/metadata-exported.h	2007/08/06 14:57:48	1.6
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/07 09:06:05	1.7
@@ -397,7 +397,7 @@
 
 int vg_remove_snapshot(struct logical_volume *cow);
 
-int vg_check_status(struct volume_group *vg, uint32_t status);
+int vg_check_status(const struct volume_group *vg, uint32_t status);
 
 /*
 * Mirroring functions
--- LVM2/lib/metadata/metadata.c	2007/08/06 21:11:27	1.130
+++ LVM2/lib/metadata/metadata.c	2007/08/07 09:06:05	1.131
@@ -1763,7 +1763,7 @@
  * 0 - fail
  * 1 - success
  */
-int vg_check_status(struct volume_group *vg, uint32_t status)
+int vg_check_status(const struct volume_group *vg, uint32_t status)
 {
 	if ((status & CLUSTERED) &&
 	    (vg->status & CLUSTERED) && !locking_is_clustered() &&
--- LVM2/tools/toollib.c	2007/07/10 17:51:26	1.102
+++ LVM2/tools/toollib.c	2007/08/07 09:06:05	1.103
@@ -25,7 +25,7 @@
 #define MIRROR_DISK_VERSION 2
 
 /* Command line args */
-unsigned arg_count(struct cmd_context *cmd, int a)
+unsigned arg_count(const struct cmd_context *cmd, int a)
 {
 	return cmd->args[a].count;
 }
@@ -142,12 +142,12 @@
 /*
  * Metadata iteration functions
  */
-int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  struct list *arg_lvnames, struct list *tags,
+int process_each_lv_in_vg(struct cmd_context *cmd,
+			  const struct volume_group *vg,
+			  const struct list *arg_lvnames,
+			  const struct list *tags,
 			  void *handle,
-			  int (*process_single) (struct cmd_context * cmd,
-						 struct logical_volume * lv,
-						 void *handle))
+			  process_single_lv_fn_t process_single)
 {
 	int ret_max = 0;
 	int ret = 0;
@@ -603,11 +603,8 @@
 }
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  struct list *tags, void *handle,
-			  int (*process_single) (struct cmd_context * cmd,
-						 struct volume_group * vg,
-						 struct physical_volume * pv,
-						 void *handle))
+			  const struct list *tags, void *handle,
+			  process_single_pv_fn_t process_single)
 {
 	int ret_max = 0;
 	int ret = 0;
--- LVM2/tools/toollib.h	2007/07/18 15:38:58	1.47
+++ LVM2/tools/toollib.h	2007/08/07 09:06:05	1.48
@@ -60,19 +60,25 @@
 						      struct lv_segment * seg,
 						      void *handle));
 
+typedef int (*process_single_pv_fn_t) (struct cmd_context *cmd,
+				  struct volume_group *vg,
+				  struct physical_volume *pv,
+				  void *handle);
+
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  struct list *tags, void *handle,
-			  int (*process_single) (struct cmd_context * cmd,
-						 struct volume_group * vg,
-						 struct physical_volume * pv,
-						 void *handle));
+			  const struct list *tags, void *handle,
+			  process_single_pv_fn_t process_single);
 
-int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  struct list *arg_lvnames, struct list *tags,
+typedef int (*process_single_lv_fn_t) (struct cmd_context *cmd,
+				  struct logical_volume *lv,
+				  void *handle);
+
+int process_each_lv_in_vg(struct cmd_context *cmd,
+			  const struct volume_group *vg,
+			  const struct list *arg_lvnames,
+			  const struct list *tags,
 			  void *handle,
-			  int (*process_single) (struct cmd_context * cmd,
-						 struct logical_volume * lv,
-						 void *handle));
+			  process_single_lv_fn_t process_single);
 
 char *default_vgname(struct cmd_context *cmd);
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
--- LVM2/tools/tools.h	2007/07/18 15:38:58	1.53
+++ LVM2/tools/tools.h	2007/08/07 09:06:05	1.54
@@ -147,7 +147,7 @@
 char yes_no_prompt(const char *prompt, ...);
 
 /* we use the enums to access the switches */
-unsigned int arg_count(struct cmd_context *cmd, int a);
+unsigned int arg_count(const struct cmd_context *cmd, int a);
 const char *arg_value(struct cmd_context *cmd, int a);
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def);
 int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 
--- LVM2/tools/vgdisplay.c	2007/06/19 04:36:12	1.17
+++ LVM2/tools/vgdisplay.c	2007/08/07 09:06:05	1.18
@@ -46,10 +46,11 @@
 		vgdisplay_extents(vg);
 
 		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
-				      &lvdisplay_full);
+				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");
-		process_each_pv_in_vg(cmd, vg, NULL, NULL, &pvdisplay_short);
+		process_each_pv_in_vg(cmd, vg, NULL, NULL,
+				      (process_single_pv_fn_t)pvdisplay_short);
 	}
 
 	check_current_backup(vg);
@@ -98,7 +99,7 @@
 **********/
 
 	process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
-			&vgdisplay_single);
+			vgdisplay_single);
 
 /******** FIXME Need to count number processed 
 	  Add this to process_each_vg if arg_count(cmd,activevolumegroups_ARG) ? 


