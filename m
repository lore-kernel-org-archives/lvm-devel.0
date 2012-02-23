From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:42:01 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20120223224201.9161.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:42:00

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 

Log message:
	Use const for lv
	
	lv_is_active doesn't needs modifiable LV struct so keep it const.
	
	Remove lv_send_message() left bits from code -
	they were never released in 2.02.89.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2307&r2=1.2308
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.242&r2=1.243
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/WHATS_NEW	2012/02/23 22:30:20	1.2307
+++ LVM2/WHATS_NEW	2012/02/23 22:41:57	1.2308
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Use const lv pointer for lv_is_active...() functions. 
   Use same signed numbers in _mirrored_transient_status().
   Integrate client-side lvmetad into build.
 
@@ -172,7 +173,6 @@
   Apply appropriate udev flags when suspending/resuming mirror sub-LVs.
   Fix vgsplit to handle mirrored logs.
   Clarify multi-name device filter pattern matching explanation in lvm.conf.
-  Introduce lv_send_message and dev_manager_send_message.
   Introduce revert_lv for better pvmove cleanup.
   Replace incomplete pvmove activation failure recovery code with a message.
   Abort if _finish_pvmove suspend_lvs fails instead of cleaning up incompletely.
--- LVM2/lib/activate/activate.c	2012/02/23 13:11:08	1.242
+++ LVM2/lib/activate/activate.c	2012/02/23 22:42:00	1.243
@@ -194,7 +194,7 @@
 {
 	return 0;
 }
-int lvs_in_vg_activated(struct volume_group *vg)
+int lvs_in_vg_activated(const struct volume_group *vg)
 {
 	return 0;
 }
@@ -242,10 +242,6 @@
 {
 	return 1;
 }
-int lv_send_message(const struct logical_volume *lv, const char *message)
-{
-	return 0;
-}
 int pv_uses_vg(struct physical_volume *pv,
 	       struct volume_group *vg)
 {
@@ -258,23 +254,23 @@
 {
 }
 
-int lv_is_active(struct logical_volume *lv)
+int lv_is_active(const struct logical_volume *lv)
 {
 	return 0;
 }
-int lv_is_active_but_not_locally(struct logical_volume *lv)
+int lv_is_active_but_not_locally(const struct logical_volume *lv)
 {
 	return 0;
 }
-int lv_is_active_exclusive(struct logical_volume *lv)
+int lv_is_active_exclusive(const struct logical_volume *lv)
 {
 	return 0;
 }
-int lv_is_active_exclusive_locally(struct logical_volume *lv)
+int lv_is_active_exclusive_locally(const struct logical_volume *lv)
 {
 	return 0;
 }
-int lv_is_active_exclusive_remotely(struct logical_volume *lv)
+int lv_is_active_exclusive_remotely(const struct logical_volume *lv)
 {
 	return 0;
 }
@@ -293,6 +289,7 @@
 {
 }
 /* dev_manager.c */
+#include "targets.h"
 int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 		   struct dm_tree_node *node, uint32_t start_area,
 		   uint32_t areas)
@@ -842,7 +839,7 @@
 	return r;
 }
 
-static int _lv_active(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lv_active(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	struct lvinfo info;
 
@@ -944,7 +941,7 @@
  * These two functions return the number of visible LVs in the state,
  * or -1 on error.  FIXME Check this.
  */
-int lvs_in_vg_activated(struct volume_group *vg)
+int lvs_in_vg_activated(const struct volume_group *vg)
 {
 	struct lv_list *lvl;
 	int count = 0;
@@ -999,7 +996,7 @@
  *
  * Returns: 0 or 1
  */
-static int _lv_is_active(struct logical_volume *lv,
+static int _lv_is_active(const struct logical_volume *lv,
 			 int *locally, int *exclusive)
 {
 	int r, l, e; /* remote, local, and exclusive */
@@ -1055,32 +1052,32 @@
 	return r || l;
 }
 
-int lv_is_active(struct logical_volume *lv)
+int lv_is_active(const struct logical_volume *lv)
 {
 	return _lv_is_active(lv, NULL, NULL);
 }
 
-int lv_is_active_but_not_locally(struct logical_volume *lv)
+int lv_is_active_but_not_locally(const struct logical_volume *lv)
 {
 	int l;
 	return _lv_is_active(lv, &l, NULL) && !l;
 }
 
-int lv_is_active_exclusive(struct logical_volume *lv)
+int lv_is_active_exclusive(const struct logical_volume *lv)
 {
 	int e;
 
 	return _lv_is_active(lv, NULL, &e) && e;
 }
 
-int lv_is_active_exclusive_locally(struct logical_volume *lv)
+int lv_is_active_exclusive_locally(const struct logical_volume *lv)
 {
 	int l, e;
 
 	return _lv_is_active(lv, &l, &e) && l && e;
 }
 
-int lv_is_active_exclusive_remotely(struct logical_volume *lv)
+int lv_is_active_exclusive_remotely(const struct logical_volume *lv)
 {
 	int l, e;
 
--- LVM2/lib/activate/activate.h	2012/01/25 13:10:26	1.97
+++ LVM2/lib/activate/activate.h	2012/02/23 22:42:00	1.98
@@ -111,14 +111,14 @@
 /*
  * Return number of LVs in the VG that are active.
  */
-int lvs_in_vg_activated(struct volume_group *vg);
+int lvs_in_vg_activated(const struct volume_group *vg);
 int lvs_in_vg_opened(const struct volume_group *vg);
 
-int lv_is_active(struct logical_volume *lv);
-int lv_is_active_but_not_locally(struct logical_volume *lv);
-int lv_is_active_exclusive(struct logical_volume *lv);
-int lv_is_active_exclusive_locally(struct logical_volume *lv);
-int lv_is_active_exclusive_remotely(struct logical_volume *lv);
+int lv_is_active(const struct logical_volume *lv);
+int lv_is_active_but_not_locally(const struct logical_volume *lv);
+int lv_is_active_exclusive(const struct logical_volume *lv);
+int lv_is_active_exclusive_locally(const struct logical_volume *lv);
+int lv_is_active_exclusive_remotely(const struct logical_volume *lv);
 
 int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 		       const char *layer, const char *target_type);


