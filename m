From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 10 Dec 2009 13:53:59 +0100
Subject: [PATCH 3/4] Skip 'return' keyword for void() functions
In-Reply-To: <cover.1260449368.git.zkabelac@redhat.com>
References: <cover.1260449368.git.zkabelac@redhat.com>
Message-ID: <30781ca3122e01887ca0a2b209b0488d350ff8ae.1260449368.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/display/display.c           |   11 -----------
 lib/filters/filter-persistent.c |    2 --
 lib/filters/filter.c            |    1 -
 lib/format1/format1.c           |    1 -
 lib/format1/lvm1-label.c        |    1 -
 lib/format_pool/format_pool.c   |    1 -
 lib/format_pool/pool_label.c    |    1 -
 lib/format_text/format-text.c   |    1 -
 lib/locking/locking.c           |    4 ----
 lib/locking/no_locking.c        |    2 --
 lib/misc/lvm-string.c           |    2 +-
 libdm/libdm-deptree.c           |    4 ++--
 tools/dmsetup.c                 |    1 -
 tools/lvmcmdlib.c               |    2 --
 tools/pvscan.c                  |    1 -
 15 files changed, 3 insertions(+), 32 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 691f1cf..a835327 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -327,8 +327,6 @@ void pvdisplay_colons(const struct physical_volume *pv)
 		  pv->pe_count,
 		  pv->pe_count - pv->pe_alloc_count,
 		  pv->pe_alloc_count, *uuid ? uuid : "none");
-
-	return;
 }
 
 void pvdisplay_segments(const struct physical_volume *pv)
@@ -355,7 +353,6 @@ void pvdisplay_segments(const struct physical_volume *pv)
 	}
 
 	log_print(" ");
-	return;
 }
 
 /* FIXME Include label fields */
@@ -424,8 +421,6 @@ void pvdisplay_full(const struct cmd_context *cmd,
 	log_print("Allocated PE          %u", pv->pe_alloc_count);
 	log_print("PV UUID               %s", *uuid ? uuid : "none");
 	log_print(" ");
-
-	return;
 }
 
 int pvdisplay_short(const struct cmd_context *cmd __attribute((unused)),
@@ -470,7 +465,6 @@ void lvdisplay_colons(const struct logical_volume *lv)
 		  /* FIXME Add num allocated to struct! lv->lv_allocated_le, */
 		  (lv->alloc == ALLOC_CONTIGUOUS ? 2 : 0), lv->read_ahead,
 		  inkernel ? info.major : -1, inkernel ? info.minor : -1);
-	return;
 }
 
 int lvdisplay_full(struct cmd_context *cmd,
@@ -654,7 +648,6 @@ int lvdisplay_segments(const struct logical_volume *lv)
 
 void vgdisplay_extents(const struct volume_group *vg __attribute((unused)))
 {
-	return;
 }
 
 void vgdisplay_full(const struct volume_group *vg)
@@ -729,8 +722,6 @@ void vgdisplay_full(const struct volume_group *vg)
 
 	log_print("VG UUID               %s", uuid);
 	log_print(" ");
-
-	return;
 }
 
 void vgdisplay_colons(const struct volume_group *vg)
@@ -779,7 +770,6 @@ void vgdisplay_colons(const struct volume_group *vg)
 		vg->extent_count - vg->free_count,
 		vg->free_count,
 		uuid[0] ? uuid : "none");
-	return;
 }
 
 void vgdisplay_short(const struct volume_group *vg)
@@ -792,7 +782,6 @@ void vgdisplay_short(const struct volume_group *vg)
 			       ((uint64_t) vg->extent_count -
 				vg->free_count) * vg->extent_size),
 		  display_size(vg->cmd, vg_free(vg)));
-	return;
 }
 
 void display_formats(const struct cmd_context *cmd)
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index b24850b..d91ed13 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -171,8 +171,6 @@ static void _write_array(struct pfilter *pf, FILE *fp, const char *path,
 
 	if (!first)
 		fprintf(fp, "\n\t]\n");
-
-	return;
 }
 
 int persistent_filter_dump(struct dev_filter *f)
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index 889b416..b33d099 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -331,5 +331,4 @@ struct dev_filter *lvm_type_filter_create(const char *proc,
 void lvm_type_filter_destroy(struct dev_filter *f)
 {
 	dm_free(f);
-	return;
 }
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 887906c..b6a2c15 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -480,7 +480,6 @@ static struct format_instance *_format1_create_instance(const struct format_type
 
 static void _format1_destroy_instance(struct format_instance *fid __attribute((unused)))
 {
-	return;
 }
 
 static void _format1_destroy(const struct format_type *fmt)
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index eeb929c..bf25ce0 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -96,7 +96,6 @@ static int _lvm1_initialise_label(struct labeller *l __attribute((unused)), stru
 
 static void _lvm1_destroy_label(struct labeller *l __attribute((unused)), struct label *label __attribute((unused)))
 {
-	return;
 }
 
 static void _lvm1_destroy(struct labeller *l)
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 0d3f918..26321c1 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -281,7 +281,6 @@ static struct format_instance *_pool_create_instance(const struct format_type *f
 
 static void _pool_destroy_instance(struct format_instance *fid __attribute((unused)))
 {
-	return;
 }
 
 static void _pool_destroy(const struct format_type *fmt)
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 5b43375..7b4cfac 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -73,7 +73,6 @@ static int _pool_initialise_label(struct labeller *l __attribute((unused)), stru
 
 static void _pool_destroy_label(struct labeller *l __attribute((unused)), struct label *label __attribute((unused)))
 {
-	return;
 }
 
 static void _label_pool_destroy(struct labeller *l)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 5dacb21..2c75054 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1593,7 +1593,6 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 
 static void _text_destroy_instance(struct format_instance *fid __attribute((unused)))
 {
-	return;
 }
 
 static void _free_dirs(struct dm_list *dir_list)
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 7bf3f78..ad1c2db 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -145,8 +145,6 @@ static void _block_signals(uint32_t flags __attribute((unused)))
 	}
 
 	_signals_blocked = 1;
-
-	return;
 }
 
 static void _unblock_signals(void)
@@ -161,8 +159,6 @@ static void _unblock_signals(void)
 	}
 
 	_signals_blocked = 0;
-
-	return;
 }
 
 static void _lock_memory(lv_operation_t lv_op)
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index f4a14ad..85374b3 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -27,12 +27,10 @@
 
 static void _no_fin_locking(void)
 {
-	return;
 }
 
 static void _no_reset_locking(void)
 {
-	return;
 }
 
 static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index c75a9a7..5a7de96 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -125,7 +125,7 @@ static void _unquote_characters(char *src, const int orig_char,
  */
 static void _quote_hyphens(char **out, const char *src)
 {
-	return _quote_characters(out, src, '-', '-', 0);
+	_quote_characters(out, src, '-', '-', 0);
 }
 
 /*
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index a596c83..2691c38 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -268,7 +268,7 @@ static int _add_to_toplevel(struct dm_tree_node *node)
 
 static void _remove_from_toplevel(struct dm_tree_node *node)
 {
-	return _unlink_nodes(&node->dtree->root, node);
+	_unlink_nodes(&node->dtree->root, node);
 }
 
 static int _add_to_bottomlevel(struct dm_tree_node *node)
@@ -278,7 +278,7 @@ static int _add_to_bottomlevel(struct dm_tree_node *node)
 
 static void _remove_from_bottomlevel(struct dm_tree_node *node)
 {
-	return _unlink_nodes(node, &node->dtree->root);
+	_unlink_nodes(node, &node->dtree->root);
 }
 
 static int _link_tree_nodes(struct dm_tree_node *parent, struct dm_tree_node *child)
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b5568f0..3232b86 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2571,7 +2571,6 @@ static void _usage(FILE *out)
 	fprintf(out, "Tree options are: ascii, utf, vt100; compact, inverted, notrunc;\n"
 		     "                  [no]device, active, open, rw and uuid.\n");
 	fprintf(out, "\n");
-	return;
 }
 
 static void _losetup_usage(FILE *out)
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index bbdf08c..580aad9 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -102,8 +102,6 @@ void lvm2_log_level(void *handle, int level)
 	struct cmd_context *cmd = (struct cmd_context *) handle;
 
 	cmd->default_settings.verbose = level - VERBOSE_BASE_LEVEL;
-
-	return;
 }
 
 void lvm2_log_fn(lvm2_log_fn_t log_fn)
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 775ba29..cbeccb7 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -94,7 +94,6 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 		  display_size(cmd, (uint64_t) (pv_pe_count(pv) -
 						pv_pe_alloc_count(pv)) *
 					   pv_pe_size(pv)));
-	return;
 }
 
 int pvscan(struct cmd_context *cmd, int argc __attribute((unused)),
-- 
1.6.5.3


