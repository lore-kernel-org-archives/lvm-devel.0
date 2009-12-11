From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Dec 2009 13:16:41 -0000
Subject: LVM2 lib/display/display.c lib/filters/filter- ...
Message-ID: <20091211131641.22034.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-12-11 13:16:39

Modified files:
	lib/display    : display.c 
	lib/filters    : filter-persistent.c filter.c 
	lib/format1    : format1.c lvm1-label.c 
	lib/format_pool: format_pool.c pool_label.c 
	lib/format_text: format-text.c 
	lib/locking    : locking.c no_locking.c 
	lib/misc       : lvm-string.c 
	libdm          : libdm-deptree.c 
	tools          : dmsetup.c lvmcmdlib.c pvscan.c 

Log message:
	Cleanup returns for void functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/pool_label.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/lib/display/display.c	2009/11/24 22:55:56	1.108
+++ LVM2/lib/display/display.c	2009/12/11 13:16:37	1.109
@@ -327,8 +327,6 @@
 		  pv->pe_count,
 		  pv->pe_count - pv->pe_alloc_count,
 		  pv->pe_alloc_count, *uuid ? uuid : "none");
-
-	return;
 }
 
 void pvdisplay_segments(const struct physical_volume *pv)
@@ -355,7 +353,6 @@
 	}
 
 	log_print(" ");
-	return;
 }
 
 /* FIXME Include label fields */
@@ -424,8 +421,6 @@
 	log_print("Allocated PE          %u", pv->pe_alloc_count);
 	log_print("PV UUID               %s", *uuid ? uuid : "none");
 	log_print(" ");
-
-	return;
 }
 
 int pvdisplay_short(const struct cmd_context *cmd __attribute((unused)),
@@ -470,7 +465,6 @@
 		  /* FIXME Add num allocated to struct! lv->lv_allocated_le, */
 		  (lv->alloc == ALLOC_CONTIGUOUS ? 2 : 0), lv->read_ahead,
 		  inkernel ? info.major : -1, inkernel ? info.minor : -1);
-	return;
 }
 
 int lvdisplay_full(struct cmd_context *cmd,
@@ -654,7 +648,6 @@
 
 void vgdisplay_extents(const struct volume_group *vg __attribute((unused)))
 {
-	return;
 }
 
 void vgdisplay_full(const struct volume_group *vg)
@@ -729,8 +722,6 @@
 
 	log_print("VG UUID               %s", uuid);
 	log_print(" ");
-
-	return;
 }
 
 void vgdisplay_colons(const struct volume_group *vg)
@@ -779,7 +770,6 @@
 		vg->extent_count - vg->free_count,
 		vg->free_count,
 		uuid[0] ? uuid : "none");
-	return;
 }
 
 void vgdisplay_short(const struct volume_group *vg)
@@ -792,7 +782,6 @@
 			       ((uint64_t) vg->extent_count -
 				vg->free_count) * vg->extent_size),
 		  display_size(vg->cmd, vg_free(vg)));
-	return;
 }
 
 void display_formats(const struct cmd_context *cmd)
--- LVM2/lib/filters/filter-persistent.c	2009/07/08 18:13:32	1.38
+++ LVM2/lib/filters/filter-persistent.c	2009/12/11 13:16:38	1.39
@@ -171,8 +171,6 @@
 
 	if (!first)
 		fprintf(fp, "\n\t]\n");
-
-	return;
 }
 
 int persistent_filter_dump(struct dev_filter *f)
--- LVM2/lib/filters/filter.c	2009/10/27 17:00:46	1.50
+++ LVM2/lib/filters/filter.c	2009/12/11 13:16:38	1.51
@@ -331,5 +331,4 @@
 void lvm_type_filter_destroy(struct dev_filter *f)
 {
 	dm_free(f);
-	return;
 }
--- LVM2/lib/format1/format1.c	2009/07/30 17:45:28	1.114
+++ LVM2/lib/format1/format1.c	2009/12/11 13:16:38	1.115
@@ -480,7 +480,6 @@
 
 static void _format1_destroy_instance(struct format_instance *fid __attribute((unused)))
 {
-	return;
 }
 
 static void _format1_destroy(const struct format_type *fmt)
--- LVM2/lib/format1/lvm1-label.c	2009/07/15 20:02:46	1.21
+++ LVM2/lib/format1/lvm1-label.c	2009/12/11 13:16:38	1.22
@@ -96,7 +96,6 @@
 
 static void _lvm1_destroy_label(struct labeller *l __attribute((unused)), struct label *label __attribute((unused)))
 {
-	return;
 }
 
 static void _lvm1_destroy(struct labeller *l)
--- LVM2/lib/format_pool/format_pool.c	2009/07/30 17:45:29	1.25
+++ LVM2/lib/format_pool/format_pool.c	2009/12/11 13:16:38	1.26
@@ -281,7 +281,6 @@
 
 static void _pool_destroy_instance(struct format_instance *fid __attribute((unused)))
 {
-	return;
 }
 
 static void _pool_destroy(const struct format_type *fmt)
--- LVM2/lib/format_pool/pool_label.c	2008/01/30 13:59:59	1.8
+++ LVM2/lib/format_pool/pool_label.c	2009/12/11 13:16:38	1.9
@@ -73,7 +73,6 @@
 
 static void _pool_destroy_label(struct labeller *l __attribute((unused)), struct label *label __attribute((unused)))
 {
-	return;
 }
 
 static void _label_pool_destroy(struct labeller *l)
--- LVM2/lib/format_text/format-text.c	2009/11/24 22:55:56	1.116
+++ LVM2/lib/format_text/format-text.c	2009/12/11 13:16:38	1.117
@@ -1593,7 +1593,6 @@
 
 static void _text_destroy_instance(struct format_instance *fid __attribute((unused)))
 {
-	return;
 }
 
 static void _free_dirs(struct dm_list *dir_list)
--- LVM2/lib/locking/locking.c	2009/11/23 10:55:14	1.67
+++ LVM2/lib/locking/locking.c	2009/12/11 13:16:38	1.68
@@ -145,8 +145,6 @@
 	}
 
 	_signals_blocked = 1;
-
-	return;
 }
 
 static void _unblock_signals(void)
@@ -161,8 +159,6 @@
 	}
 
 	_signals_blocked = 0;
-
-	return;
 }
 
 static void _lock_memory(lv_operation_t lv_op)
--- LVM2/lib/locking/no_locking.c	2009/09/14 22:47:49	1.19
+++ LVM2/lib/locking/no_locking.c	2009/12/11 13:16:38	1.20
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
--- LVM2/lib/misc/lvm-string.c	2008/03/12 16:03:22	1.17
+++ LVM2/lib/misc/lvm-string.c	2009/12/11 13:16:39	1.18
@@ -125,7 +125,7 @@
  */
 static void _quote_hyphens(char **out, const char *src)
 {
-	return _quote_characters(out, src, '-', '-', 0);
+	_quote_characters(out, src, '-', '-', 0);
 }
 
 /*
--- LVM2/libdm/libdm-deptree.c	2009/12/03 09:58:30	1.63
+++ LVM2/libdm/libdm-deptree.c	2009/12/11 13:16:39	1.64
@@ -268,7 +268,7 @@
 
 static void _remove_from_toplevel(struct dm_tree_node *node)
 {
-	return _unlink_nodes(&node->dtree->root, node);
+	_unlink_nodes(&node->dtree->root, node);
 }
 
 static int _add_to_bottomlevel(struct dm_tree_node *node)
@@ -278,7 +278,7 @@
 
 static void _remove_from_bottomlevel(struct dm_tree_node *node)
 {
-	return _unlink_nodes(node, &node->dtree->root);
+	_unlink_nodes(node, &node->dtree->root);
 }
 
 static int _link_tree_nodes(struct dm_tree_node *parent, struct dm_tree_node *child)
--- LVM2/tools/dmsetup.c	2009/12/11 13:04:30	1.129
+++ LVM2/tools/dmsetup.c	2009/12/11 13:16:39	1.130
@@ -2571,7 +2571,6 @@
 	fprintf(out, "Tree options are: ascii, utf, vt100; compact, inverted, notrunc;\n"
 		     "                  [no]device, active, open, rw and uuid.\n");
 	fprintf(out, "\n");
-	return;
 }
 
 static void _losetup_usage(FILE *out)
--- LVM2/tools/lvmcmdlib.c	2009/11/19 01:11:57	1.10
+++ LVM2/tools/lvmcmdlib.c	2009/12/11 13:16:39	1.11
@@ -102,8 +102,6 @@
 	struct cmd_context *cmd = (struct cmd_context *) handle;
 
 	cmd->default_settings.verbose = level - VERBOSE_BASE_LEVEL;
-
-	return;
 }
 
 void lvm2_log_fn(lvm2_log_fn_t log_fn)
--- LVM2/tools/pvscan.c	2009/09/14 22:47:49	1.48
+++ LVM2/tools/pvscan.c	2009/12/11 13:16:39	1.49
@@ -94,7 +94,6 @@
 		  display_size(cmd, (uint64_t) (pv_pe_count(pv) -
 						pv_pe_alloc_count(pv)) *
 					   pv_pe_size(pv)));
-	return;
 }
 
 int pvscan(struct cmd_context *cmd, int argc __attribute((unused)),


