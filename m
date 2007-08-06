From: Jim Meyering <jim@meyering.net>
Date: Mon, 06 Aug 2007 17:18:22 +0200
Subject: const correctness, first cut
Message-ID: <87odhkd741.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I find it easier to read code that uses "const" whenever possible.
Then, absence of "const" implies that there is at least one code path
through which the pointed-to data can be modified.  Here's a first cut
at adding some "const" attributes:

In ensuring that things make sense and there are still no compile-time
warnings, I ended up factoring out the function pointer types for a
couple of the iterators, e.g., process_each_lv_in_vg.  Here are the
names I chose:

  typedef int (*process_single_pv) (struct cmd_context *cmd,
  ...

  typedef int (*process_single_lv) (struct cmd_context *cmd,
  ...

I was tempted to use the _fn_t suffix, but technically _t is
a reserved suffix.  However, there is precedent:

  fd_callback_t
  checksum_fn_t
  lvm2_log_fn_t

In writing this, I've decided to go with the _fn_t suffix after all:

  typedef int (*process_single_pv_fn_t) (struct cmd_context *cmd,
  ...

  typedef int (*process_single_lv_fn_t) (struct cmd_context *cmd,
  ...

Speak now if you'd like something else.
Barring objections, I'll commit this in a couple hours.

---
 daemons/clvmd/lvm-functions.c    |    2 +-
 daemons/clvmd/lvm-functions.h    |    2 +-
 daemons/clvmd/refresh_clvmd.c    |    2 +-
 lib/activate/activate.c          |    4 +-
 lib/activate/activate.h          |    2 +-
 lib/datastruct/list.c            |   14 +++++-----
 lib/datastruct/list.h            |   14 +++++-----
 lib/datastruct/str_list.c        |    9 ++++---
 lib/datastruct/str_list.h        |    9 ++++---
 lib/display/display.c            |   49 ++++++++++++++++++++-----------------
 lib/display/display.h            |   36 ++++++++++++++-------------
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    2 +-
 tools/toollib.c                  |   19 ++++++--------
 tools/toollib.h                  |   28 +++++++++++++--------
 tools/tools.h                    |    2 +-
 tools/vgdisplay.c                |    7 +++--
 17 files changed, 107 insertions(+), 96 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 56219ac..b8da034 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -431,7 +431,7 @@ int post_lock_lv(unsigned char command, unsigned char lock_flags,
 }
 
 /* Check if a VG is un use by LVM1 so we don't stomp on it */
-int do_check_lvm1(char *vgname)
+int do_check_lvm1(const char *vgname)
 {
 	int status;
 
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index d04964b..b1e4da1 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -24,7 +24,7 @@ extern int do_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 		      char *resource);
 extern int post_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 			char *resource);
-extern int do_check_lvm1(char *vgname);
+extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
 extern int init_lvm(int using_gulm);
 extern void init_lvhash(void);
diff --git a/daemons/clvmd/refresh_clvmd.c b/daemons/clvmd/refresh_clvmd.c
index 5103ec3..3a455b8 100644
--- a/daemons/clvmd/refresh_clvmd.c
+++ b/daemons/clvmd/refresh_clvmd.c
@@ -79,7 +79,7 @@ static int _open_local_sock(void)
 }
 
 /* Send a request and return the status */
-static int _send_request(char *inbuf, int inlen, char **retbuf)
+static int _send_request(const char *inbuf, int inlen, char **retbuf)
 {
 	char outbuf[PIPE_BUF];
 	struct clvm_header *outheader = (struct clvm_header *) outbuf;
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c262ff3..51f393c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -642,9 +642,9 @@ int lvs_in_vg_activated(struct volume_group *vg)
 	return _lvs_in_vg_activated(vg, 0);
 }
 
-int lvs_in_vg_opened(struct volume_group *vg)
+int lvs_in_vg_opened(const struct volume_group *vg)
 {
-	struct lv_list *lvl;
+	const struct lv_list *lvl;
 	int count = 0;
 
 	if (!activation())
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index c3e9700..76d27e2 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -84,7 +84,7 @@ int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
  */
 int lvs_in_vg_activated(struct volume_group *vg);
 int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg);
-int lvs_in_vg_opened(struct volume_group *vg);
+int lvs_in_vg_opened(const struct volume_group *vg);
 
 
 int monitor_dev_for_events(struct cmd_context *cmd,
diff --git a/lib/datastruct/list.c b/lib/datastruct/list.c
index 17ee0e2..3918cf5 100644
--- a/lib/datastruct/list.c
+++ b/lib/datastruct/list.c
@@ -68,7 +68,7 @@ void list_del(struct list *elem)
 /*
  * Is the list empty?
  */
-int list_empty(struct list *head)
+int list_empty(const struct list *head)
 {
 	return head->n == head;
 }
@@ -76,7 +76,7 @@ int list_empty(struct list *head)
 /*
  * Is this the first element of the list?
  */
-int list_start(struct list *head, struct list *elem)
+int list_start(const struct list *head, const struct list *elem)
 {
 	return elem->p == head;
 }
@@ -84,7 +84,7 @@ int list_start(struct list *head, struct list *elem)
 /*
  * Is this the last element of the list?
  */
-int list_end(struct list *head, struct list *elem)
+int list_end(const struct list *head, const struct list *elem)
 {
 	return elem->n == head;
 }
@@ -92,7 +92,7 @@ int list_end(struct list *head, struct list *elem)
 /*
  * Return first element of the list or NULL if empty
  */
-struct list *list_first(struct list *head)
+struct list *list_first(const struct list *head)
 {
 	return (list_empty(head) ? NULL : head->n);
 }
@@ -100,7 +100,7 @@ struct list *list_first(struct list *head)
 /*
  * Return last element of the list or NULL if empty
  */
-struct list *list_last(struct list *head)
+struct list *list_last(const struct list *head)
 {
 	return (list_empty(head) ? NULL : head->p);
 }
@@ -108,7 +108,7 @@ struct list *list_last(struct list *head)
 /*
  * Return the previous element of the list, or NULL if we've reached the start.
  */
-struct list *list_prev(struct list *head, struct list *elem)
+struct list *list_prev(const struct list *head, const struct list *elem)
 {
 	return (list_start(head, elem) ? NULL : elem->p);
 }
@@ -116,7 +116,7 @@ struct list *list_prev(struct list *head, struct list *elem)
 /*
  * Return the next element of the list, or NULL if we've reached the end.
  */
-struct list *list_next(struct list *head, struct list *elem)
+struct list *list_next(const struct list *head, const struct list *elem)
 {
 	return (list_end(head, elem) ? NULL : elem->n);
 }
diff --git a/lib/datastruct/list.h b/lib/datastruct/list.h
index 316c537..00d4d74 100644
--- a/lib/datastruct/list.h
+++ b/lib/datastruct/list.h
@@ -57,37 +57,37 @@ void list_del(struct list *elem);
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
diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index 94705dc..68660d9 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -66,7 +66,8 @@ int str_list_del(struct list *sll, const char *str)
 	return 1;
 }
 
-int str_list_dup(struct dm_pool *mem, struct list *sllnew, struct list *sllold)
+int str_list_dup(struct dm_pool *mem, struct list *sllnew,
+		 const struct list *sllold)
 {
 	struct str_list *sl;
 
@@ -85,7 +86,7 @@ int str_list_dup(struct dm_pool *mem, struct list *sllnew, struct list *sllold)
 /*
  * Is item on list?
  */
-int str_list_match_item(struct list *sll, const char *str)
+int str_list_match_item(const struct list *sll, const char *str)
 {
 	struct str_list *sl;
 
@@ -99,7 +100,7 @@ int str_list_match_item(struct list *sll, const char *str)
 /*
  * Is at least one item on both lists?
  */
-int str_list_match_list(struct list *sll, struct list *sll2)
+int str_list_match_list(const struct list *sll, const struct list *sll2)
 {
 	struct str_list *sl;
 
@@ -113,7 +114,7 @@ int str_list_match_list(struct list *sll, struct list *sll2)
 /*
  * Do both lists contain the same set of items?
  */
-int str_list_lists_equal(struct list *sll, struct list *sll2)
+int str_list_lists_equal(const struct list *sll, const struct list *sll2)
 {
 	struct str_list *sl;
 
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index 329a1f6..46fb76d 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
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
diff --git a/lib/display/display.c b/lib/display/display.c
index 4b2a0e4..c0f4e5b 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -147,7 +147,8 @@ alloc_policy_t get_alloc_from_string(const char *str)
 }
 
 /* Size supplied in sectors */
-static const char *_display_size(struct cmd_context *cmd, uint64_t size, size_len_t sl)
+static const char *_display_size(const struct cmd_context *cmd,
+				 uint64_t size, size_len_t sl)
 {
 	int s;
 	int suffix = 1, precision;
@@ -217,22 +218,22 @@ static const char *_display_size(struct cmd_context *cmd, uint64_t size, size_le
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
 
@@ -258,9 +259,9 @@ void pvdisplay_colons(struct physical_volume *pv)
 	return;
 }
 
-void pvdisplay_segments(struct physical_volume *pv)
+void pvdisplay_segments(const struct physical_volume *pv)
 {
-	struct pv_segment *pvseg;
+	const struct pv_segment *pvseg;
 
 	if (pv->pe_size)
 		log_print("--- Physical Segments ---");
@@ -286,7 +287,8 @@ void pvdisplay_segments(struct physical_volume *pv)
 }
 
 /* FIXME Include label fields */
-void pvdisplay_full(struct cmd_context *cmd, struct physical_volume *pv,
+void pvdisplay_full(const struct cmd_context *cmd,
+		    const struct physical_volume *pv,
 		    void *handle __attribute((unused)))
 {
 	char uuid[64] __attribute((aligned(8)));
@@ -346,9 +348,9 @@ void pvdisplay_full(struct cmd_context *cmd, struct physical_volume *pv,
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
@@ -373,7 +375,7 @@ int pvdisplay_short(struct cmd_context *cmd __attribute((unused)),
 	return 0;
 }
 
-void lvdisplay_colons(struct logical_volume *lv)
+void lvdisplay_colons(const struct logical_volume *lv)
 {
 	int inkernel;
 	struct lvinfo info;
@@ -393,7 +395,8 @@ void lvdisplay_colons(struct logical_volume *lv)
 	return;
 }
 
-int lvdisplay_full(struct cmd_context *cmd, struct logical_volume *lv,
+int lvdisplay_full(struct cmd_context *cmd,
+		   const struct logical_volume *lv,
 		   void *handle __attribute((unused)))
 {
 	struct lvinfo info;
@@ -535,9 +538,9 @@ void display_stripe(const struct lv_segment *seg, uint32_t s, const char *pre)
 	}
 }
 
-int lvdisplay_segments(struct logical_volume *lv)
+int lvdisplay_segments(const struct logical_volume *lv)
 {
-	struct lv_segment *seg;
+	const struct lv_segment *seg;
 
 	log_print("--- Segments ---");
 
@@ -555,12 +558,12 @@ int lvdisplay_segments(struct logical_volume *lv)
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
@@ -639,7 +642,7 @@ void vgdisplay_full(struct volume_group *vg)
 	return;
 }
 
-void vgdisplay_colons(struct volume_group *vg)
+void vgdisplay_colons(const struct volume_group *vg)
 {
 	uint32_t active_pvs;
 	const char *access;
@@ -691,7 +694,7 @@ void vgdisplay_colons(struct volume_group *vg)
 	return;
 }
 
-void vgdisplay_short(struct volume_group *vg)
+void vgdisplay_short(const struct volume_group *vg)
 {
 	log_print("\"%s\" %-9s [%-9s used / %s free]", vg->name,
 /********* FIXME if "open" print "/used" else print "/idle"???  ******/
@@ -705,18 +708,18 @@ void vgdisplay_short(struct volume_group *vg)
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
diff --git a/lib/display/display.h b/lib/display/display.h
index 7605e15..94f9c0e 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
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
+int pvdisplay_short(const struct cmd_context *cmd,
+		    const struct volume_group *vg,
+		    const struct physical_volume *pv, void *handle);
 
-void lvdisplay_colons(struct logical_volume *lv);
-int lvdisplay_segments(struct logical_volume *lv);
-int lvdisplay_full(struct cmd_context *cmd, struct logical_volume *lv,
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
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5cc7ead..2e7160e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -397,7 +397,7 @@ int vg_add_snapshot(struct format_instance *fid, const char *name,
 
 int vg_remove_snapshot(struct logical_volume *cow);
 
-int vg_check_status(struct volume_group *vg, uint32_t status);
+int vg_check_status(const struct volume_group *vg, uint32_t status);
 
 /*
 * Mirroring functions
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index de42ed3..1a4cc0f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1763,7 +1763,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
  * 0 - fail
  * 1 - success
  */
-int vg_check_status(struct volume_group *vg, uint32_t status)
+int vg_check_status(const struct volume_group *vg, uint32_t status)
 {
 	if ((status & CLUSTERED) &&
 	    (vg->status & CLUSTERED) && !locking_is_clustered() &&
diff --git a/tools/toollib.c b/tools/toollib.c
index 5510e8e..5753aff 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -25,7 +25,7 @@
 #define MIRROR_DISK_VERSION 2
 
 /* Command line args */
-unsigned arg_count(struct cmd_context *cmd, int a)
+unsigned arg_count(const struct cmd_context *cmd, int a)
 {
 	return cmd->args[a].count;
 }
@@ -142,12 +142,12 @@ char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
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
@@ -603,11 +603,8 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
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
diff --git a/tools/toollib.h b/tools/toollib.h
index b67fc40..93ab5b3 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -60,19 +60,25 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
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
-
-int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  struct list *arg_lvnames, struct list *tags,
+			  const struct list *tags, void *handle,
+			  process_single_pv_fn_t process_single);
+
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
diff --git a/tools/tools.h b/tools/tools.h
index bba7e9e..eac7c02 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -147,7 +147,7 @@ int alloc_arg(struct cmd_context *cmd, struct arg *a);
 char yes_no_prompt(const char *prompt, ...);
 
 /* we use the enums to access the switches */
-unsigned int arg_count(struct cmd_context *cmd, int a);
+unsigned int arg_count(const struct cmd_context *cmd, int a);
 const char *arg_value(struct cmd_context *cmd, int a);
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def);
 int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index aa02129..0881906 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -46,10 +46,11 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
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
@@ -98,7 +99,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 **********/
 
 	process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
-			&vgdisplay_single);
+			vgdisplay_single);
 
 /******** FIXME Need to count number processed 
 	  Add this to process_each_vg if arg_count(cmd,activevolumegroups_ARG) ? 
-- 


