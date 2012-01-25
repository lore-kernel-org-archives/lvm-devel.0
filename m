From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 08:51:29 -0000
Subject: LVM2/lib activate/activate.c thin/thin.c
Message-ID: <20120125085129.23825.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 08:51:29

Modified files:
	lib/activate   : activate.c 
	lib/thin       : thin.c 

Log message:
	Comment cleanups
	
	Move comment where it applies and remove unused attribe when the var
	is actually used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.234&r2=1.235
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/lib/activate/activate.c	2012/01/25 08:48:43	1.234
+++ LVM2/lib/activate/activate.c	2012/01/25 08:51:29	1.235
@@ -1502,16 +1502,6 @@
 }
 ***********/
 
- /*
-  * _lv_resume
-  * @cmd
-  * @lvid_s
-  * @origin_only
-  * @exclusive:  This parameter only has an affect in cluster-context.
-  *		 It forces local target type to be used (instead of
-  *		 cluster-aware type).
-  * @error_if_not_active
-  */
 static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		      struct lv_activate_opts *laopts, int error_if_not_active)
 {
@@ -1574,6 +1564,10 @@
  * In a cluster, set exclusive to indicate that only one node is using the
  * device.  Any tables loaded may then use non-clustered targets.
  *
+ * @origin_only
+ * @exclusive   This parameter only has an affect in cluster-context.
+ *              It forces local target type to be used (instead of
+ *              cluster-aware type).
  * Returns success if the device is not active
  */
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
--- LVM2/lib/thin/thin.c	2012/01/24 00:55:04	1.42
+++ LVM2/lib/thin/thin.c	2012/01/25 08:51:29	1.43
@@ -212,11 +212,11 @@
 
 #ifdef DEVMAPPER_SUPPORT
 static int _thin_pool_add_target_line(struct dev_manager *dm,
-				      struct dm_pool *mem __attribute__((unused)),
-				      struct cmd_context *cmd __attribute__((unused)),
+				      struct dm_pool *mem,
+				      struct cmd_context *cmd,
 				      void **target_state __attribute__((unused)),
 				      struct lv_segment *seg,
-				      const struct lv_activate_opts *laopts __attribute__((unused)),
+				      const struct lv_activate_opts *laopts,
 				      struct dm_tree_node *node, uint64_t len,
 				      uint32_t *pvmove_mirror_count __attribute__((unused)))
 {


