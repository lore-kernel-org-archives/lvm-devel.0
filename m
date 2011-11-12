From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Nov 2011 22:44:12 -0000
Subject: LVM2 lib/thin/thin.c libdm/libdevmapper.h libd ...
Message-ID: <20111112224412.25198.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-12 22:44:11

Modified files:
	lib/thin       : thin.c 
	libdm          : libdevmapper.h libdm-deptree.c 
	tools          : lvm.c toollib.c 

Log message:
	Thin remove unused define
	
	Remove DM_THIN_ERROR_DEVICE_ID from API.
	Remove API warning.
	Drop code that was using DM_THIN_ERROR_DEVICE_ID (already commented)
	Remove debug message which slipped in through some previous commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.168&r2=1.169
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.234&r2=1.235

--- LVM2/lib/thin/thin.c	2011/11/10 15:30:59	1.32
+++ LVM2/lib/thin/thin.c	2011/11/12 22:44:10	1.33
@@ -230,8 +230,6 @@
 			return 0;
 		}
 
-		//if (!dm_tree_node_add_thin_target(node, len, pool_dlid,
-		//				    DM_THIN_ERROR_DEVICE_ID))
 		if (!dm_tree_node_add_linear_target(node, len) ||
 		    !dm_tree_node_add_target_area(node, NULL, pool_dlid, 0))
 			return_0;
--- LVM2/libdm/libdevmapper.h	2011/11/03 14:45:01	1.168
+++ LVM2/libdm/libdevmapper.h	2011/11/12 22:44:10	1.169
@@ -535,7 +535,6 @@
 					   uint32_t slog_region_size);
 /* End of Replicator API */
 
-/* API for thin provisioning is experimental, DO NOT USE. */
 /*
  * FIXME: Defines bellow are based on kernel's dm-thin.c defines
  * DATA_DEV_BLOCK_SIZE_MIN_SECTORS (64 * 1024 >> SECTOR_SHIFT)
@@ -571,10 +570,6 @@
  * MAX_DEV_ID ((1 << 24) - 1)
  */
 #define DM_THIN_MAX_DEVICE_ID (UINT32_C((1 << 24) - 1))
-/* Reserved device_id for error (deleted) thin device */
-// FIXME - only needed for in-delete thin is not activated
-#define DM_THIN_ERROR_DEVICE_ID (UINT32_MAX)
-
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
 				 const char *pool_uuid,
--- LVM2/libdm/libdm-deptree.c	2011/11/04 12:39:45	1.145
+++ LVM2/libdm/libdm-deptree.c	2011/11/12 22:44:10	1.146
@@ -3018,19 +3018,14 @@
 	if (!_link_tree_nodes(node, pool))
 		return_0;
 
-	if (device_id == DM_THIN_ERROR_DEVICE_ID) {
-		if (!dm_tree_node_add_error_target(node, size))
-			return_0;
-	} else {
-		if (!_thin_validate_device_id(device_id))
-			return_0;
+	if (!_thin_validate_device_id(device_id))
+		return_0;
 
-		if (!(seg = _add_segment(node, SEG_THIN, size)))
-			return_0;
+	if (!(seg = _add_segment(node, SEG_THIN, size)))
+		return_0;
 
-		seg->pool = pool;
-		seg->device_id = device_id;
-	}
+	seg->pool = pool;
+	seg->device_id = device_id;
 
 	return 1;
 }
--- LVM2/tools/lvm.c	2010/11/11 17:29:06	1.115
+++ LVM2/tools/lvm.c	2011/11/12 22:44:11	1.116
@@ -167,7 +167,6 @@
 
 	stifle_history(find_config_tree_int(cmd, "shell/history_size",
 				       DEFAULT_MAX_HISTORY));
-
 }
 
 static void _write_history(void)
--- LVM2/tools/toollib.c	2011/11/10 12:43:05	1.234
+++ LVM2/tools/toollib.c	2011/11/12 22:44:11	1.235
@@ -329,7 +329,6 @@
 		dm_list_iterate_items(sll, &arg_lvnames) {
 			const char *vg_name = sll->str;
 			const char *lv_name = strchr(vg_name, '/');
-log_error("VGNAME strdup %p %s   %s", lv_name, vg_name,  vgname);
 
 			if ((!lv_name && !strcmp(vg_name, vgname))) {
 				/* Process all LVs in this VG */


