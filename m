From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:40:04 -0000
Subject: LVM2 lib/filters/filter-mpath.c lib/metadata/m ...
Message-ID: <20120208114004.1425.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:40:03

Modified files:
	lib/filters    : filter-mpath.c 
	lib/metadata   : mirror.c 
	tools          : vgcfgbackup.c 

Log message:
	Replace snprintf with dm_snprintf
	
	snprintf testing for negative is replaced with dm_snprintf where this
	test really works.
	Add missing test for result of dm_snprintf().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-mpath.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/filters/filter-mpath.c	2011/11/11 16:41:37	1.2
+++ LVM2/lib/filters/filter-mpath.c	2012/02/08 11:40:02	1.3
@@ -60,7 +60,7 @@
 {
 	char path[PATH_MAX], buffer[64];
 
-	if (snprintf(path, sizeof(path), "%s/block/%s/dev", sysfs_dir, kname) < 0)
+	if (dm_snprintf(path, sizeof(path), "%s/block/%s/dev", sysfs_dir, kname) < 0)
 		return_0;
 
 	if (!get_sysfs_string(path, buffer, sizeof(buffer)))
--- LVM2/lib/metadata/mirror.c	2012/02/01 15:05:53	1.176
+++ LVM2/lib/metadata/mirror.c	2012/02/08 11:40:02	1.177
@@ -696,9 +696,11 @@
 		dm_list_iterate_items(lvl, &split_images) {
 			sub_lv = lvl->lv;
 
-			dm_snprintf(format, len, "%s_mimage_%%d",
-				    new_lv->name);
-
+			if (dm_snprintf(format, len, "%s_mimage_%%d",
+					new_lv->name) < 0) {
+				log_error("Failed to build new image name.");
+				return 0;
+			}
 			layer_name = dm_pool_alloc(lv->vg->vgmem, len);
 			if (!layer_name) {
 				log_error("Unable to allocate memory");
--- LVM2/tools/vgcfgbackup.c	2009/09/15 01:38:59	1.31
+++ LVM2/tools/vgcfgbackup.c	2012/02/08 11:40:02	1.32
@@ -28,7 +28,7 @@
 		return NULL;
 	}
 
-	if (snprintf(filename, PATH_MAX, template, vg_name) < 0) {
+	if (dm_snprintf(filename, PATH_MAX, template, vg_name) < 0) {
 		log_error("Error processing filename template %s",
 			   template);
 		dm_free(filename);	


