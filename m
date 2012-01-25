From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 13:12:59 -0000
Subject: LVM2/lib activate/activate.c mm/memlock.c
Message-ID: <20120125131259.24480.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 13:12:59

Modified files:
	lib/activate   : activate.c 
	lib/mm         : memlock.c 

Log message:
	Fix compilation with disabled devmapper
	
	During release preparation things has changed, so making sure
	we are compilable with --disable-devmapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.239&r2=1.240
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/lib/activate/activate.c	2012/01/25 13:10:26	1.239
+++ LVM2/lib/activate/activate.c	2012/01/25 13:12:59	1.240
@@ -147,7 +147,7 @@
 {
 	return 0;
 }
-int lvm_dm_prefix_check(const char *sysfs_dir, int major, int minor, const char *prefix)
+int lvm_dm_prefix_check(int major, int minor, const char *prefix)
 {
 	return 0;
 }
@@ -161,6 +161,11 @@
 {
 	return 0;
 }
+int lv_check_not_in_use(struct cmd_context *cmd __attribute__((unused)),
+			struct logical_volume *lv, struct lvinfo *info)
+{
+        return 0;
+}
 int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
 {
 	return 0;
@@ -170,6 +175,25 @@
 {
 	return 0;
 }
+int lv_raid_percent(const struct logical_volume *lv, percent_t *percent)
+{
+	return 0;
+}
+int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
+			 percent_t *percent)
+{
+	return 0;
+}
+int lv_thin_percent(const struct logical_volume *lv, int mapped,
+		    percent_t *percent)
+{
+	return 0;
+}
+int lv_thin_pool_transaction_id(const struct logical_volume *lv,
+				uint64_t *transaction_id)
+{
+	return 0;
+}
 int lvs_in_vg_activated(struct volume_group *vg)
 {
 	return 0;
@@ -184,7 +208,7 @@
 	return 1;
 }
 *******/
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive)
 {
 	return 1;
 }
@@ -260,10 +284,30 @@
 	return 1;
 }
 int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
-			   struct lv_activate_opts *laopts, int monitor)
+			   const struct lv_activate_opts *laopts, int monitor)
 {
 	return 1;
 }
+/* fs.c */
+void fs_unlock(void)
+{
+}
+/* dev_manager.c */
+int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
+		   struct dm_tree_node *node, uint32_t start_area,
+		   uint32_t areas)
+{
+        return 0;
+}
+int device_is_usable(struct device *dev)
+{
+        return 0;
+}
+int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
+		       const char *layer, const char *target_type)
+{
+        return 0;
+}
 #else				/* DEVMAPPER_SUPPORT */
 
 static int _activation = 1;
--- LVM2/lib/mm/memlock.c	2012/01/12 18:29:08	1.48
+++ LVM2/lib/mm/memlock.c	2012/01/25 13:12:59	1.49
@@ -38,12 +38,12 @@
 	return;
 }
 
-void critical_section_inc(struct cmd_context *cmd)
+void critical_section_inc(struct cmd_context *cmd, const char *reason)
 {
 	return;
 }
 
-void critical_section_dec(struct cmd_context *cmd)
+void critical_section_dec(struct cmd_context *cmd, const char *reason)
 {
 	return;
 }


