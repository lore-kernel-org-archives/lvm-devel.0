From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Sep 2011 10:25:23 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/form ...
Message-ID: <20110901102523.14028.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-01 10:25:23

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/format_text: export.c import-export.h 
	lib/metadata   : metadata.h 

Log message:
	Use size_t return type
	
	Since these function returns buffer size - use size_t type for them.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2087&r2=1.2088
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.250&r2=1.251

--- LVM2/WHATS_NEW	2011/08/31 12:47:59	1.2087
+++ LVM2/WHATS_NEW	2011/09/01 10:25:22	1.2088
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Use size_t return type for text_vg_export_raw() and export_vg_to_buffer().
   Add configure --enable-lvmetad for building the (experimental) LVMetaD.
   Fix resource leak when strdup fails in _get_device_status() (2.02.85).
   Directly allocate buffer memory in a pvck scan instead of using a mempool.
--- LVM2/lib/cache/lvmcache.c	2011/08/30 14:55:16	1.117
+++ LVM2/lib/cache/lvmcache.c	2011/09/01 10:25:22	1.118
@@ -102,7 +102,7 @@
 	char uuid[64] __attribute__((aligned(8)));
 	struct lvmcache_vginfo *vginfo;
 	char *data;
-	int size;
+	size_t size;
 
 	if (!(vginfo = vginfo_from_vgid((const char *)&vg->id))) {
 		stack;
@@ -132,7 +132,7 @@
 		return;
 	}
 
-	log_debug("Metadata cache: VG %s (%s) stored (%d bytes%s).",
+	log_debug("Metadata cache: VG %s (%s) stored (%" PRIsize_t " bytes%s).",
 		  vginfo->vgname, uuid, size,
 		  precommitted ? ", precommitted" : "");
 }
--- LVM2/lib/format_text/export.c	2011/08/30 14:55:17	1.83
+++ LVM2/lib/format_text/export.c	2011/09/01 10:25:22	1.84
@@ -775,10 +775,10 @@
 }
 
 /* Returns amount of buffer used incl. terminating NUL */
-int text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
+size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 {
 	struct formatter *f;
-	int r = 0;
+	size_t r = 0;
 
 	_init();
 
@@ -809,7 +809,7 @@
 	return r;
 }
 
-int export_vg_to_buffer(struct volume_group *vg, char **buf)
+size_t export_vg_to_buffer(struct volume_group *vg, char **buf)
 {
 	return text_vg_export_raw(vg, "", buf);
 }
--- LVM2/lib/format_text/import-export.h	2011/08/30 14:55:17	1.27
+++ LVM2/lib/format_text/import-export.h	2011/09/01 10:25:22	1.28
@@ -65,7 +65,7 @@
 int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct dm_config_value *cv);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
-int text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
+size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
 struct volume_group *text_vg_import_file(struct format_instance *fid,
 					 const char *file,
 					 time_t *when, char **desc);
--- LVM2/lib/metadata/metadata.h	2011/08/30 14:55:17	1.250
+++ LVM2/lib/metadata/metadata.h	2011/09/01 10:25:22	1.251
@@ -454,7 +454,7 @@
 /*
  * For internal metadata caching.
  */
-int export_vg_to_buffer(struct volume_group *vg, char **buf);
+size_t export_vg_to_buffer(struct volume_group *vg, char **buf);
 int export_vg_to_config_tree(struct volume_group *vg, struct dm_config_tree **cft);
 struct volume_group *import_vg_from_buffer(const char *buf,
 					   struct format_instance *fid);


