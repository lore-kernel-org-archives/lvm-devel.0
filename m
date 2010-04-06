From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Apr 2010 14:04:58 -0000
Subject: LVM2/lib format1/import-export.c format_text/i ...
Message-ID: <20100406140458.26322.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-06 14:04:57

Modified files:
	lib/format1    : import-export.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Add add_pvl_to_vgs() - helper function to add a pv to a vg list.
	
	Small refactor of main places in the code where a pv is added to a
	vg into a small function which adds the pv to the list and updates
	the vg counts.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.330&r2=1.331
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.201&r2=1.202

--- LVM2/lib/format1/import-export.c	2010/04/06 14:04:20	1.112
+++ LVM2/lib/format1/import-export.c	2010/04/06 14:04:54	1.113
@@ -437,8 +437,7 @@
 			return_0;
 
 		pvl->pv->fmt = fmt;
-		dm_list_add(&vg->pvs, &pvl->list);
-		vg->pv_count++;
+		add_pvl_to_vgs(vg, pvl);
 	}
 
 	return 1;
--- LVM2/lib/format_text/import_vsn1.c	2010/04/06 14:04:03	1.72
+++ LVM2/lib/format_text/import_vsn1.c	2010/04/06 14:04:54	1.73
@@ -271,8 +271,7 @@
 
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
-	vg->pv_count++;
-	dm_list_add(&vg->pvs, &pvl->list);
+	add_pvl_to_vgs(vg, pvl);
 
 	return 1;
 }
--- LVM2/lib/metadata/metadata.c	2010/04/06 14:03:43	1.330
+++ LVM2/lib/metadata/metadata.c	2010/04/06 14:04:57	1.331
@@ -136,6 +136,13 @@
 	return pv->pe_align_offset;
 }
 
+void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
+{
+	dm_list_add(&vg->pvs, &pvl->list);
+	vg->pv_count++;
+}
+
+
 /**
  * add_pv_to_vg - Add a physical volume to a volume group
  * @vg - volume group to add to
@@ -230,9 +237,7 @@
 	}
 
 	pvl->pv = pv;
-	dm_list_add(&vg->pvs, &pvl->list);
-
-	vg->pv_count++;
+	add_pvl_to_vgs(vg, pvl);
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
 
--- LVM2/lib/metadata/metadata.h	2010/03/31 17:21:40	1.201
+++ LVM2/lib/metadata/metadata.h	2010/04/06 14:04:57	1.202
@@ -377,5 +377,6 @@
 struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv);
+void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl);
 
 #endif


