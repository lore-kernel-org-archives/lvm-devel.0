From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 11:00:22 -0000
Subject: LVM2 lib/cache/lvmcache.c lib/datastruct/str_l ...
Message-ID: <20090727110022.6156.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 11:00:21

Modified files:
	lib/cache      : lvmcache.c 
	lib/datastruct : str_list.c 
	liblvm         : lvm.h lvm_vg.c 

Log message:
	Update error return and comments for lvm_list_vg_names/uuids.
	
	The two liblvm functions that return a list of vgnames and vguuids use
	cmd->mem to allocate the list.  Make it clear to the caller that this
	memory will be freed when the LVM handle is freed.
	
	Clean up and clarify the return value of the functions.  In the
	case of a memory allocation error, add a couple log_errnos to the internal
	code, and make it clear that memory allocation returns a NULL pointer.
	If there are no VGs in the system, the list returned is an empty list.
	
	Make a note of the fact that currently we return hidden VG names, how
	these can be detected (always start with "#"), and that they should
	not be used.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/str_list.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/lib/cache/lvmcache.c	2009/04/24 12:03:55	1.65
+++ LVM2/lib/cache/lvmcache.c	2009/07/27 11:00:17	1.66
@@ -563,14 +563,14 @@
 	lvmcache_label_scan(cmd, full_scan);
 
 	if (!(vgnames = str_list_create(cmd->mem))) {
-		log_error("vgnames list allocation failed");
+		log_errno(ENOMEM, "vgnames list allocation failed");
 		return NULL;
 	}
 
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (!str_list_add(cmd->mem, vgnames,
 				  dm_pool_strdup(cmd->mem, vginfo->vgname))) {
-			log_error("strlist allocation failed");
+			log_errno(ENOMEM, "strlist allocation failed");
 			return NULL;
 		}
 	}
--- LVM2/lib/datastruct/str_list.c	2008/11/03 22:14:27	1.11
+++ LVM2/lib/datastruct/str_list.c	2009/07/27 11:00:18	1.12
@@ -20,8 +20,10 @@
 {
 	struct dm_list *sl;
 
-	if (!(sl = dm_pool_alloc(mem, sizeof(struct dm_list))))
-		return_NULL;
+	if (!(sl = dm_pool_alloc(mem, sizeof(struct dm_list)))) {
+		log_errno(ENOMEM, "str_list allocation failed");
+		return NULL;
+	}
 
 	dm_list_init(sl);
 
--- LVM2/liblvm/lvm.h	2009/07/27 10:18:51	1.28
+++ LVM2/liblvm/lvm.h	2009/07/27 11:00:18	1.29
@@ -185,8 +185,13 @@
 /**
  * Return the list of volume group names.
  *
+ * The memory allocated for the list is tied to the lvm_t handle and will be
+ * released when lvm_destroy is called.
+ *
  * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
  * To scan the system, use lvm_scan.
+ * NOTE: This function currently returns hidden VG names.  These names always
+ * begin with a "#" and should be filtered out and not used.
  *
  * To process the list, use the dm_list iterator functions.  For example:
  *      vg_t *vg;
@@ -203,23 +208,30 @@
  *
  *
  * \return  A list of struct lvm_str_list
- *          If no VGs exist on the system, NULL is returned.
- *
- * FIXME: handle list memory cleanup
+ *          NULL is returned if unable to allocate memory.
+ *          An empty list (verify with dm_list_empty) is returned if no VGs
+ *          exist on the system.
  */
 struct dm_list *lvm_list_vg_names(lvm_t libh);
 
 /**
  * Return the list of volume group uuids.
  *
+ * The memory allocated for the list is tied to the lvm_t handle and will be
+ * released when lvm_destroy is called.
+ *
  * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
  * To scan the system, use lvm_scan.
+ * NOTE: This function currently returns hidden VG names.  These names always
+ * begin with a "#" and should be filtered out and not used.
  *
  * \param   libh
  *          Handle obtained from lvm_create.
  *
  * \return  List of copied uuid strings.
- *          If no VGs exist on the system, NULL is returned.
+ *          NULL is returned if unable to allocate memory.
+ *          An empty list (verify with dm_list_empty) is returned if no VGs
+ *          exist on the system.
  */
 struct dm_list *lvm_list_vg_uuids(lvm_t libh);
 
--- LVM2/liblvm/lvm_vg.c	2009/07/26 20:29:28	1.17
+++ LVM2/liblvm/lvm_vg.c	2009/07/27 11:00:18	1.18
@@ -240,6 +240,11 @@
 	return name;
 }
 
+/*
+ * FIXME: These functions currently return hidden VGs.  We should either filter
+ * these out and not return them in the list, or export something like
+ * is_orphan_vg and tell the caller to filter.
+ */
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
 	return get_vgnames((struct cmd_context *)libh, 0);


