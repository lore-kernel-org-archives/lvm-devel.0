From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Apr 2010 17:25:45 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata ...
Message-ID: <20100413172545.11096.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-13 17:25:45

Modified files:
	lib/metadata   : metadata-exported.h metadata.c metadata.h 

Log message:
	Add del_pvl_from_vgs() and move prototypes into metadata-exported.h
	
	Add a delete function to manage the vg->pvs list.
	
	NOTE: It may be possible to do further cleanup to these add/del functions
	by passing a 'pv' as input instead of 'pv_list'.  The pv_list is used for
	functions which do allocations (lvcreate) while other places in the code
	just manage a list of 'pv' (e.g. import functions, vgextend, etc).
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.332&r2=1.333
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.202&r2=1.203

--- LVM2/lib/metadata/metadata-exported.h	2010/04/09 01:00:11	1.139
+++ LVM2/lib/metadata/metadata-exported.h	2010/04/13 17:25:44	1.140
@@ -470,6 +470,9 @@
 int vg_set_clustered(struct volume_group *vg, int clustered);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
+/* FIXME: Investigate refactoring these functions to take a pv ISO pv_list */
+void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl);
+void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl);
 
 /* FIXME: refactor / unexport when lvremove liblvm refactoring dones */
 int remove_lvs_in_vg(struct cmd_context *cmd,
--- LVM2/lib/metadata/metadata.c	2010/04/08 15:18:35	1.332
+++ LVM2/lib/metadata/metadata.c	2010/04/13 17:25:44	1.333
@@ -145,6 +145,12 @@
 	vg->pv_count++;
 }
 
+void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
+{
+	vg->pv_count--;
+	dm_list_del(&pvl->list);
+}
+
 
 /**
  * add_pv_to_vg - Add a physical volume to a volume group
--- LVM2/lib/metadata/metadata.h	2010/04/06 14:04:57	1.202
+++ LVM2/lib/metadata/metadata.h	2010/04/13 17:25:45	1.203
@@ -377,6 +377,5 @@
 struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv);
-void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl);
 
 #endif


