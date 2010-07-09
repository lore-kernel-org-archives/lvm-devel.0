From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jul 2010 15:21:11 -0000
Subject: LVM2 lib/metadata/pv_map.h tools/toollib.h
Message-ID: <20100709152111.8182.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-09 15:21:10

Modified files:
	lib/metadata   : pv_map.h 
	tools          : toollib.h 

Log message:
	Remove superfluous fn prototypes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/lib/metadata/pv_map.h	2010/03/25 21:19:27	1.13
+++ LVM2/lib/metadata/pv_map.h	2010/07/09 15:21:10	1.14
@@ -69,6 +69,5 @@
 void reinsert_reduced_pv_area(struct pv_area *pva);
 
 uint32_t pv_maps_size(struct dm_list *pvms);
-void reinsert_reduced_pv_area(struct pv_area *pva);
 
 #endif
--- LVM2/tools/toollib.h	2010/05/21 12:21:52	1.74
+++ LVM2/tools/toollib.h	2010/07/09 15:21:10	1.75
@@ -96,9 +96,6 @@
 
 struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvs);
 
-int apply_lvname_restrictions(const char *name);
-int is_reserved_lvname(const char *name);
-
 void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
 				 struct volume_group *vg);
 int vgcreate_params_set_from_args(struct cmd_context *cmd,


