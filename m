From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:10:38 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c
Message-ID: <20120213111038.13067.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:10:37

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 

Log message:
	Add check for rimage name allocation failure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2288&r2=1.2289
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2012/02/13 11:09:25	1.2288
+++ LVM2/WHATS_NEW	2012/02/13 11:10:37	1.2289
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Add check for rimage name allocation failure in _raid_add_images().
   Add check for mda_copy failure in _text_pv_setup().
   Add check for _mirrored_init_target failure.
   Add free_orphan_vg.
--- LVM2/lib/metadata/raid_manip.c	2012/01/24 14:33:38	1.21
+++ LVM2/lib/metadata/raid_manip.c	2012/02/13 11:10:37	1.22
@@ -655,7 +655,10 @@
 			if (l == dm_list_last(&data_lvs)) {
 				lvl = dm_list_item(l, struct lv_list);
 				len = strlen(lv->name) + strlen("_rimage_XXX");
-				name = dm_pool_alloc(lv->vg->vgmem, len);
+				if (!(name = dm_pool_alloc(lv->vg->vgmem, len))) {
+					log_error("Failed to allocate rimage name.");
+					return 0;
+				}
 				sprintf(name, "%s_rimage_%u", lv->name, count);
 				lvl->lv->name = name;
 				continue;


