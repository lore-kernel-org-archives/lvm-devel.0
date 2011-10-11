From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 08:51:57 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20111011085157.27379.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 08:51:56

Modified files:
	lib/thin       : thin.c 

Log message:
	Reindent some thin functions

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/lib/thin/thin.c	2011/10/06 11:06:36	1.15
+++ LVM2/lib/thin/thin.c	2011/10/11 08:51:56	1.16
@@ -43,8 +43,9 @@
 	return seg->segtype->name;
 }
 
-static int _thin_pool_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
-			struct dm_hash_table *pv_hash __attribute__((unused)))
+static int _thin_pool_text_import(struct lv_segment *seg,
+				  const struct dm_config_node *sn,
+				  struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const char *lv_name;
 	struct logical_volume *pool_data_lv, *pool_metadata_lv;
@@ -113,13 +114,13 @@
 
 #ifdef DEVMAPPER_SUPPORT
 static int _thin_pool_add_target_line(struct dev_manager *dm,
-				 struct dm_pool *mem __attribute__((unused)),
-				 struct cmd_context *cmd __attribute__((unused)),
-				 void **target_state __attribute__((unused)),
-				 struct lv_segment *seg,
-				 const struct lv_activate_opts *laopts __attribute__((unused)),
-				 struct dm_tree_node *node, uint64_t len,
-				 uint32_t *pvmove_mirror_count __attribute__((unused)))
+				      struct dm_pool *mem __attribute__((unused)),
+				      struct cmd_context *cmd __attribute__((unused)),
+				      void **target_state __attribute__((unused)),
+				      struct lv_segment *seg,
+				      const struct lv_activate_opts *laopts __attribute__((unused)),
+				      struct dm_tree_node *node, uint64_t len,
+				      uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	char *metadata_dlid, *pool_dlid;
 
@@ -147,8 +148,9 @@
 	return seg->segtype->name;
 }
 
-static int _thin_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
-			struct dm_hash_table *pv_hash __attribute__((unused)))
+static int _thin_text_import(struct lv_segment *seg,
+			     const struct dm_config_node *sn,
+			     struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const char *lv_name;
 	struct logical_volume *pool_lv;


