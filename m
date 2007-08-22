From: agk@sourceware.org <agk@sourceware.org>
Date: Wed, 22 Aug 2007 14:38:41 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/error ...
Message-ID: <20070822143823.1367.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-08-22 14:38:18

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 
	lib/error      : errseg.c 
	lib/filters    : filter-sysfs.c filter.c 
	lib/format1    : disk-rep.c format1.c import-export.c 
	                 lvm1-label.c 
	lib/format_pool: disk_rep.c format_pool.c pool_label.c 
	lib/format_text: format-text.c import_vsn1.c 
	lib/locking    : cluster_locking.c external_locking.c 
	                 file_locking.c locking.c locking.h 
	                 locking_types.h no_locking.c 
	lib/metadata   : lv_alloc.h lv_manip.c metadata-exported.h 
	                 metadata.c mirror.c 
	lib/misc       : lvm-string.c lvm-string.h 
	lib/report     : report.c 
	lib/snapshot   : snapshot.c 
	lib/zero       : zero.c 
	tools          : lvconvert.c lvcreate.c pvck.c reporter.c 
	                 toollib.c toollib.h vgreduce.c vgsplit.c 

Log message:
	Clean up numerous compiler warnings that crept in recently.
	Remove several unused parameters from _allocate().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.689&r2=1.690
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/pool_label.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/external_locking.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking_types.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvck.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2007/08/21 19:56:18	1.689
+++ LVM2/WHATS_NEW	2007/08/22 14:38:15	1.690
@@ -1,10 +1,7 @@
-DO NOT RELEASE UNTIL FOLLOWING FIXED/REVIEWED:
-
-changed text also needs fixing - some poor English
-lvcreate page needs fixing too - emphasis on best behaviour (disk log) got inverted!
-
 Version 2.02.28 -
 ================================
+  Clean up numerous compiler warnings that crept in recently.
+  Remove several unused parameters from _allocate().
   Only permit --force, --verbose and --debug arguments to be repeated.
   Move guts of vgremove into library.
   Fix inconsistent licence notices: executables are GPLv2; libraries LGPLv2.1.
--- LVM2/lib/config/config.c	2007/08/20 20:55:24	1.64
+++ LVM2/lib/config/config.c	2007/08/22 14:38:15	1.65
@@ -156,7 +156,7 @@
 	return 1;
 }
 
-struct config_tree *create_config_tree_from_string(struct cmd_context *cmd,
+struct config_tree *create_config_tree_from_string(struct cmd_context *cmd __attribute((unused)),
 						   const char *config_settings)
 {
 	struct cs *c;
@@ -371,7 +371,7 @@
 
 	va_start(ap, fmt);
 	n = vsnprintf(&buf[0], sizeof buf - 1, fmt, ap);
-	if (n < 0 || n > sizeof buf - 1) {
+	if (n < 0 || n > (int) sizeof buf - 1) {
 		log_error("vsnprintf failed for config line");
 		return 0;
 	}
@@ -1248,13 +1248,13 @@
  * Returns:
  *  # of 'type' tokens in 'str'.
  */
-static unsigned _count_tokens (const char *str, unsigned len, int type)
+static unsigned _count_tokens(const char *str, unsigned len, int type)
 {
 	char c;
 
 	c = _token_type_to_char(type);
 
-	return(count_chars_len(str, len, c));
+	return count_chars_len(str, len, c);
 }
 
 /*
--- LVM2/lib/error/errseg.c	2007/08/20 20:55:25	1.14
+++ LVM2/lib/error/errseg.c	2007/08/22 14:38:16	1.15
@@ -67,7 +67,7 @@
 #endif
 
 static int _errseg_modules_needed(struct dm_pool *mem,
-				  const struct lv_segment *seg,
+				  const struct lv_segment *seg __attribute((unused)),
 				  struct list *modules)
 {
 	if (!str_list_add(mem, modules, "error")) {
--- LVM2/lib/filters/filter-sysfs.c	2007/08/20 20:55:25	1.16
+++ LVM2/lib/filters/filter-sysfs.c	2007/08/22 14:38:16	1.17
@@ -299,7 +299,7 @@
 
 #else
 
-struct dev_filter *sysfs_filter_create(const char *proc)
+struct dev_filter *sysfs_filter_create(const char *proc __attribute((unused)))
 {
 	return NULL;
 }
--- LVM2/lib/filters/filter.c	2007/08/20 20:55:25	1.42
+++ LVM2/lib/filters/filter.c	2007/08/22 14:38:16	1.43
@@ -80,7 +80,7 @@
 	{NULL, 0}
 };
 
-static int _passes_lvm_type_device_filter(struct dev_filter *f,
+static int _passes_lvm_type_device_filter(struct dev_filter *f __attribute((unused)),
 					  struct device *dev)
 {
 	const char *name = dev_name(dev);
--- LVM2/lib/format1/disk-rep.c	2007/08/20 20:55:25	1.67
+++ LVM2/lib/format1/disk-rep.c	2007/08/22 14:38:16	1.68
@@ -653,7 +653,7 @@
 /*
  * assumes the device has been opened.
  */
-static int __write_all_pvd(const struct format_type *fmt,
+static int __write_all_pvd(const struct format_type *fmt __attribute((unused)),
 			   struct disk_list *data)
 {
 	const char *pv_name = dev_name(data->dev);
--- LVM2/lib/format1/format1.c	2007/08/20 20:55:25	1.101
+++ LVM2/lib/format1/format1.c	2007/08/22 14:38:16	1.102
@@ -175,7 +175,7 @@
 
 static struct volume_group *_format1_vg_read(struct format_instance *fid,
 				     const char *vg_name,
-				     struct metadata_area *mda)
+				     struct metadata_area *mda __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 vg_read", 1024 * 10);
 	struct list pvs;
@@ -261,7 +261,7 @@
 }
 
 static int _format1_vg_write(struct format_instance *fid, struct volume_group *vg,
-		     struct metadata_area *mda)
+		     struct metadata_area *mda __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 vg_write", 1024 * 10);
 	struct list pvds;
@@ -284,7 +284,7 @@
 }
 
 static int _format1_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct list *mdas)
+		    struct physical_volume *pv, struct list *mdas __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("lvm1 pv_read", 1024);
 	struct disk_list *dl;
@@ -325,9 +325,9 @@
 static int _format1_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size,
-		     int pvmetadatacopies,
-		     uint64_t pvmetadatasize, struct list *mdas,
-		     struct physical_volume *pv, struct volume_group *vg)
+		     int pvmetadatacopies __attribute((unused)),
+		     uint64_t pvmetadatasize __attribute((unused)), struct list *mdas __attribute((unused)),
+		     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
 {
 	if (pv->size > MAX_PV_SIZE)
 		pv->size--;
@@ -381,7 +381,7 @@
 }
 
 static int _format1_pv_write(const struct format_type *fmt, struct physical_volume *pv,
-		     struct list *mdas, int64_t sector)
+		     struct list *mdas __attribute((unused)), int64_t sector __attribute((unused)))
 {
 	struct dm_pool *mem;
 	struct disk_list *dl;
@@ -470,7 +470,7 @@
 	return 1;
 }
 
-static int _format1_segtype_supported(struct format_instance *fid, 
+static int _format1_segtype_supported(struct format_instance *fid __attribute((unused)), 
 				      const struct segment_type *segtype)
 {
 	if (!(segtype->flags & SEG_FORMAT1_SUPPORT)) {
@@ -487,9 +487,9 @@
 };
 
 static struct format_instance *_format1_create_instance(const struct format_type *fmt,
-						const char *vgname,
-						const char *vgid,
-						void *private)
+						const char *vgname __attribute((unused)),
+						const char *vgid __attribute((unused)),
+						void *private __attribute((unused)))
 {
 	struct format_instance *fid;
 	struct metadata_area *mda;
@@ -516,7 +516,7 @@
 	return fid;
 }
 
-static void _format1_destroy_instance(struct format_instance *fid)
+static void _format1_destroy_instance(struct format_instance *fid __attribute((unused)))
 {
 	return;
 }
--- LVM2/lib/format1/import-export.c	2007/08/20 20:55:25	1.85
+++ LVM2/lib/format1/import-export.c	2007/08/22 14:38:16	1.86
@@ -134,7 +134,7 @@
 	return 1;
 }
 
-int export_pv(struct cmd_context *cmd, struct dm_pool *mem,
+int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute((unused)),
 	      struct volume_group *vg,
 	      struct pv_disk *pvd, struct physical_volume *pv)
 {
@@ -588,7 +588,7 @@
 /*
  * FIXME: More inefficient code.
  */
-int import_snapshots(struct dm_pool *mem, struct volume_group *vg,
+int import_snapshots(struct dm_pool *mem __attribute((unused)), struct volume_group *vg,
 		     struct list *pvds)
 {
 	struct logical_volume *lvs[MAX_LV];
@@ -679,7 +679,7 @@
  * This calculates the nasty pv_number field
  * used by LVM1.
  */
-void export_numbers(struct list *pvds, struct volume_group *vg)
+void export_numbers(struct list *pvds, struct volume_group *vg __attribute((unused)))
 {
 	struct disk_list *dl;
 	int pv_num = 1;
--- LVM2/lib/format1/lvm1-label.c	2007/08/20 20:55:25	1.15
+++ LVM2/lib/format1/lvm1-label.c	2007/08/22 14:38:16	1.16
@@ -30,7 +30,7 @@
 		op);
 }
 
-static int _lvm1_can_handle(struct labeller *l, void *buf, uint64_t sector)
+static int _lvm1_can_handle(struct labeller *l __attribute((unused)), void *buf, uint64_t sector)
 {
 	struct pv_disk *pvd = (struct pv_disk *) buf;
 	uint32_t version;
@@ -48,7 +48,7 @@
 	return 0;
 }
 
-static int _lvm1_write(struct label *label, void *buf)
+static int _lvm1_write(struct label *label __attribute((unused)), void *buf __attribute((unused)))
 {
 	_not_supported("write");
 	return 0;
@@ -85,14 +85,14 @@
 	return 1;
 }
 
-static int _lvm1_initialise_label(struct labeller *l, struct label *label)
+static int _lvm1_initialise_label(struct labeller *l __attribute((unused)), struct label *label)
 {
 	strcpy(label->type, "LVM1");
 
 	return 1;
 }
 
-static void _lvm1_destroy_label(struct labeller *l, struct label *label)
+static void _lvm1_destroy_label(struct labeller *l __attribute((unused)), struct label *label __attribute((unused)))
 {
 	return;
 }
--- LVM2/lib/format_pool/disk_rep.c	2007/08/20 20:55:25	1.10
+++ LVM2/lib/format_pool/disk_rep.c	2007/08/22 14:38:16	1.11
@@ -33,8 +33,8 @@
 #define CPOUT_64(x, y) {(y) = xlate64_be((x));}
 
 static int __read_pool_disk(const struct format_type *fmt, struct device *dev,
-			    struct dm_pool *mem, struct pool_list *pl,
-			    const char *vg_name)
+			    struct dm_pool *mem __attribute((unused)), struct pool_list *pl,
+			    const char *vg_name __attribute((unused)))
 {
 	char buf[512] __attribute((aligned(8)));
 
--- LVM2/lib/format_pool/format_pool.c	2007/08/20 20:55:25	1.10
+++ LVM2/lib/format_pool/format_pool.c	2007/08/22 14:38:16	1.11
@@ -172,7 +172,7 @@
 
 static struct volume_group *_pool_vg_read(struct format_instance *fid,
 				     const char *vg_name,
-				     struct metadata_area *mda)
+				     struct metadata_area *mda __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("pool vg_read", 1024);
 	struct list pds;
@@ -207,18 +207,22 @@
 	return vg;
 }
 
-static int _pool_pv_setup(const struct format_type *fmt,
-		     uint64_t pe_start, uint32_t extent_count,
-		     uint32_t extent_size,
-		     int pvmetadatacopies,
-		     uint64_t pvmetadatasize, struct list *mdas,
-		     struct physical_volume *pv, struct volume_group *vg)
+static int _pool_pv_setup(const struct format_type *fmt __attribute((unused)),
+			  uint64_t pe_start __attribute((unused)),
+			  uint32_t extent_count __attribute((unused)),
+			  uint32_t extent_size __attribute((unused)),
+			  int pvmetadatacopies __attribute((unused)),
+			  uint64_t pvmetadatasize __attribute((unused)),
+			  struct list *mdas __attribute((unused)),
+			  struct physical_volume *pv __attribute((unused)),
+			  struct volume_group *vg __attribute((unused)))
 {
 	return 1;
 }
 
 static int _pool_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, struct list *mdas)
+			 struct physical_volume *pv,
+			 struct list *mdas __attribute((unused)))
 {
 	struct dm_pool *mem = dm_pool_create("pool pv_read", 1024);
 	struct pool_list *pl;
@@ -268,9 +272,9 @@
 /* *INDENT-ON* */
 
 static struct format_instance *_pool_create_instance(const struct format_type *fmt,
-						const char *vgname,
-						const char *vgid,
-						void *private)
+						const char *vgname __attribute((unused)),
+						const char *vgid __attribute((unused)),
+						void *private __attribute((unused)))
 {
 	struct format_instance *fid;
 	struct metadata_area *mda;
@@ -299,7 +303,7 @@
 	return fid;
 }
 
-static void _pool_destroy_instance(struct format_instance *fid)
+static void _pool_destroy_instance(struct format_instance *fid __attribute((unused)))
 {
 	return;
 }
--- LVM2/lib/format_pool/pool_label.c	2007/08/20 20:55:25	1.6
+++ LVM2/lib/format_pool/pool_label.c	2007/08/22 14:38:16	1.7
@@ -29,7 +29,7 @@
 		  op);
 }
 
-static int _pool_can_handle(struct labeller *l, void *buf, uint64_t sector)
+static int _pool_can_handle(struct labeller *l __attribute((unused)), void *buf, uint64_t sector)
 {
 
 	struct pool_disk pd;
@@ -50,7 +50,7 @@
 	return 0;
 }
 
-static int _pool_write(struct label *label, void *buf)
+static int _pool_write(struct label *label __attribute((unused)), void *buf __attribute((unused)))
 {
 	_pool_not_supported("write");
 	return 0;
@@ -64,14 +64,14 @@
 	return read_pool_label(&pl, l, dev, buf, label);
 }
 
-static int _pool_initialise_label(struct labeller *l, struct label *label)
+static int _pool_initialise_label(struct labeller *l __attribute((unused)), struct label *label)
 {
 	strcpy(label->type, "POOL");
 
 	return 1;
 }
 
-static void _pool_destroy_label(struct labeller *l, struct label *label)
+static void _pool_destroy_label(struct labeller *l __attribute((unused)), struct label *label __attribute((unused)))
 {
 	return;
 }
--- LVM2/lib/format_text/format-text.c	2007/08/20 20:55:26	1.81
+++ LVM2/lib/format_text/format-text.c	2007/08/22 14:38:17	1.82
@@ -140,8 +140,8 @@
 	int i;
 	uint64_t offset;
 	uint64_t offset2;
-	uint64_t size;
-	uint64_t size2;
+	size_t size;
+	size_t size2;
 	char *buf=NULL;
 	struct device_area *area;
 	struct mda_context *mdac;
@@ -149,9 +149,8 @@
 
 	mdac = (struct mda_context *) mda->metadata_locn;
 
-	log_print("Found text metadata area, offset=%"PRIu64", size=%"PRIu64,
-		  mdac->area.start,
-		  mdac->area.size);
+	log_print("Found text metadata area: offset=%" PRIu64 ", size=%"
+		  PRIu64, mdac->area.start, mdac->area.size);
 	area = &mdac->area;
 
 	if (!dev_open(area->dev))
@@ -201,12 +200,12 @@
 		/*
 		 * FIXME: We could add more sophisticated metadata detection
 		 */
-		if (maybe_config_section(buf, size+size2)) {
+		if (maybe_config_section(buf, size + size2)) {
 			/* FIXME: Validate region, pull out timestamp?, etc */
 			/* FIXME: Do something with this region */
 			log_verbose ("Found LVM2 metadata record at "
-				     "offset=%"PRIu64", size=%"PRIu64", "
-				     "offset2=%"PRIu64" size2=%"PRIu64,
+				     "offset=%"PRIu64", size=%"PRIsize_t", "
+				     "offset2=%"PRIu64" size2=%"PRIsize_t,
 				     offset, size, offset2, size2);
 			offset = prev_sector;
 			size = SECTOR_SIZE;
@@ -840,8 +839,8 @@
 	return vg;
 }
 
-static int _vg_write_file(struct format_instance *fid, struct volume_group *vg,
-			  struct metadata_area *mda)
+static int _vg_write_file(struct format_instance *fid __attribute((unused)),
+			  struct volume_group *vg, struct metadata_area *mda)
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 
@@ -905,7 +904,7 @@
 	return 1;
 }
 
-static int _vg_commit_file_backup(struct format_instance *fid,
+static int _vg_commit_file_backup(struct format_instance *fid __attribute((unused)),
 				  struct volume_group *vg,
 				  struct metadata_area *mda)
 {
@@ -972,7 +971,8 @@
 	return 1;
 }
 
-static int _vg_remove_file(struct format_instance *fid, struct volume_group *vg,
+static int _vg_remove_file(struct format_instance *fid __attribute((unused)),
+			   struct volume_group *vg __attribute((unused)),
 			   struct metadata_area *mda)
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
@@ -1164,7 +1164,8 @@
 		      uint64_t pe_start, uint64_t pe_end,
 		      int pvmetadatacopies,
 		      uint64_t pvmetadatasize, struct list *mdas,
-		      struct physical_volume *pv, struct volume_group *vg)
+		      struct physical_volume *pv,
+		      struct volume_group *vg __attribute((unused)))
 {
 	uint64_t mda_adjustment, disk_size, alignment;
 	uint64_t start1, mda_size1;	/* First area - start of disk */
--- LVM2/lib/format_text/import_vsn1.c	2007/08/20 20:55:26	1.40
+++ LVM2/lib/format_text/import_vsn1.c	2007/08/22 14:38:17	1.41
@@ -111,7 +111,8 @@
 
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		    struct volume_group *vg, struct config_node *pvn,
-		    struct config_node *vgn, struct dm_hash_table *pv_hash)
+		    struct config_node *vgn __attribute((unused)),
+		    struct dm_hash_table *pv_hash)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -383,12 +384,12 @@
 
 		/* FIXME Cope if LV not yet read in */
 		if ((pv = dm_hash_lookup(pv_hash, cv->v.str))) {
-			if (!set_lv_segment_area_pv(seg, s, pv, cv->next->v.i)) {
+			if (!set_lv_segment_area_pv(seg, s, pv, (uint32_t) cv->next->v.i)) {
 				stack;
 				return 0;
 			}
 		} else if ((lv1 = find_lv(seg->lv->vg, cv->v.str))) {
-			set_lv_segment_area_lv(seg, s, lv1, cv->next->v.i,
+			set_lv_segment_area_lv(seg, s, lv1, (uint32_t) cv->next->v.i,
 					       flags);
 		} else {
 			log_error("Couldn't find volume '%s' "
@@ -469,9 +470,11 @@
 	return 1;
 }
 
-static int _read_lvnames(struct format_instance *fid, struct dm_pool *mem,
+static int _read_lvnames(struct format_instance *fid __attribute((unused)),
+			 struct dm_pool *mem,
 			 struct volume_group *vg, struct config_node *lvn,
-			 struct config_node *vgn, struct dm_hash_table *pv_hash)
+			 struct config_node *vgn __attribute((unused)),
+			 struct dm_hash_table *pv_hash __attribute((unused)))
 {
 	struct logical_volume *lv;
 	struct lv_list *lvl;
@@ -544,9 +547,11 @@
 	return 1;
 }
 
-static int _read_lvsegs(struct format_instance *fid, struct dm_pool *mem,
+static int _read_lvsegs(struct format_instance *fid __attribute((unused)),
+			struct dm_pool *mem,
 			struct volume_group *vg, struct config_node *lvn,
-			struct config_node *vgn, struct dm_hash_table *pv_hash)
+			struct config_node *vgn __attribute((unused)),
+			struct dm_hash_table *pv_hash)
 {
 	struct logical_volume *lv;
 	struct lv_list *lvl;
--- LVM2/lib/locking/cluster_locking.c	2007/08/20 20:55:26	1.18
+++ LVM2/lib/locking/cluster_locking.c	2007/08/22 14:38:17	1.19
@@ -31,7 +31,7 @@
 #include <unistd.h>
 
 #ifndef CLUSTER_LOCKING_INTERNAL
-int lock_resource(struct cmd_context *cmd, const char *resource, int flags);
+int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags);
 void locking_end(void);
 int locking_init(int type, struct config_tree *cf, uint32_t *flags);
 #endif
@@ -295,7 +295,7 @@
 	return 1;
 }
 
-static int _lock_for_cluster(unsigned char cmd, unsigned int flags, char *name)
+static int _lock_for_cluster(unsigned char cmd, uint32_t flags, char *name)
 {
 	int status;
 	int i;
@@ -368,9 +368,9 @@
 /* API entry point for LVM */
 #ifdef CLUSTER_LOCKING_INTERNAL
 static int _lock_resource(struct cmd_context *cmd, const char *resource,
-			  int flags)
+			  uint32_t flags)
 #else
-int lock_resource(struct cmd_context *cmd, const char *resource, int flags)
+int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 #endif
 {
 	char lockname[PATH_MAX];
--- LVM2/lib/locking/external_locking.c	2007/08/20 20:55:26	1.12
+++ LVM2/lib/locking/external_locking.c	2007/08/22 14:38:17	1.13
@@ -23,12 +23,12 @@
 static void (*_reset_fn) (void) = NULL;
 static void (*_end_fn) (void) = NULL;
 static int (*_lock_fn) (struct cmd_context * cmd, const char *resource,
-			int flags) = NULL;
+			uint32_t flags) = NULL;
 static int (*_init_fn) (int type, struct config_tree * cft,
 			uint32_t *flags) = NULL;
 
 static int _lock_resource(struct cmd_context *cmd, const char *resource,
-			  int flags)
+			  uint32_t flags)
 {
 	if (_lock_fn)
 		return _lock_fn(cmd, resource, flags);
--- LVM2/lib/locking/file_locking.c	2007/08/20 20:55:26	1.30
+++ LVM2/lib/locking/file_locking.c	2007/08/22 14:38:17	1.31
@@ -124,7 +124,7 @@
 	siginterrupt(SIGINT, 1);
 }
 
-static int _lock_file(const char *file, int flags)
+static int _lock_file(const char *file, uint32_t flags)
 {
 	int operation;
 	int r = 1;
@@ -204,7 +204,7 @@
 }
 
 static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
-			       int flags)
+			       uint32_t flags)
 {
 	char lockfile[PATH_MAX];
 
--- LVM2/lib/locking/locking.c	2007/08/20 20:55:26	1.39
+++ LVM2/lib/locking/locking.c	2007/08/22 14:38:17	1.40
@@ -118,7 +118,7 @@
 	sigaction(SIGINT, &_oldhandler, NULL);
 }
 
-static void _block_signals(int flags __attribute((unused)))
+static void _block_signals(uint32_t flags __attribute((unused)))
 {
 	sigset_t set;
 
@@ -156,7 +156,7 @@
 	return;
 }
 
-static void _lock_memory(int flags)
+static void _lock_memory(uint32_t flags)
 {
 	if (!(_locking.flags & LCK_PRE_MEMLOCK))
 		return;
@@ -165,7 +165,7 @@
 		memlock_inc();
 }
 
-static void _unlock_memory(int flags)
+static void _unlock_memory(uint32_t flags)
 {
 	if (!(_locking.flags & LCK_PRE_MEMLOCK))
 		return;
@@ -187,7 +187,7 @@
 		_unblock_signals();
 }
 
-static void _update_vg_lock_count(int flags)
+static void _update_vg_lock_count(uint32_t flags)
 {
 	if ((flags & LCK_SCOPE_MASK) != LCK_VG)
 		return;
@@ -313,7 +313,7 @@
  * VG locking is by VG name.
  * FIXME This should become VG uuid.
  */
-static int _lock_vol(struct cmd_context *cmd, const char *resource, int flags)
+static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t flags)
 {
 	_block_signals(flags);
 	_lock_memory(flags);
@@ -331,7 +331,7 @@
 	return 1;
 }
 
-int lock_vol(struct cmd_context *cmd, const char *vol, int flags)
+int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 {
 	char resource[258] __attribute((aligned(8)));
 
--- LVM2/lib/locking/locking.h	2007/08/20 20:55:26	1.33
+++ LVM2/lib/locking/locking.h	2007/08/22 14:38:17	1.34
@@ -35,7 +35,7 @@
  *   Lock/unlock an individual logical volume
  *   char *vol holds lvid
  */
-int lock_vol(struct cmd_context *cmd, const char *vol, int flags);
+int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags);
 
 /*
  * Does the LVM1 driver have this VG active?
@@ -45,37 +45,37 @@
 /*
  * Lock type - these numbers are the same as VMS and the IBM DLM
  */
-#define LCK_TYPE_MASK	0x00000007
+#define LCK_TYPE_MASK	0x00000007U
 
-#define LCK_NULL	0x00000000	/* LCK$_NLMODE */
-#define LCK_READ	0x00000001	/* LCK$_CRMODE */
+#define LCK_NULL	0x00000000U	/* LCK$_NLMODE */
+#define LCK_READ	0x00000001U	/* LCK$_CRMODE */
 					/* LCK$_CWMODE */
-#define LCK_PREAD       0x00000003      /* LCK$_PRMODE */
-#define LCK_WRITE	0x00000004	/* LCK$_PWMODE */
-#define LCK_EXCL	0x00000005	/* LCK$_EXMODE */
-#define LCK_UNLOCK      0x00000006	/* This is ours */
+#define LCK_PREAD       0x00000003U	/* LCK$_PRMODE */
+#define LCK_WRITE	0x00000004U	/* LCK$_PWMODE */
+#define LCK_EXCL	0x00000005U	/* LCK$_EXMODE */
+#define LCK_UNLOCK      0x00000006U	/* This is ours */
 
 /*
  * Lock scope
  */
-#define LCK_SCOPE_MASK	0x00000008
-#define LCK_VG		0x00000000
-#define LCK_LV		0x00000008
+#define LCK_SCOPE_MASK	0x00000008U
+#define LCK_VG		0x00000000U
+#define LCK_LV		0x00000008U
 
 /*
  * Lock bits
  */
-#define LCK_NONBLOCK	0x00000010	/* Don't block waiting for lock? */
-#define LCK_HOLD	0x00000020	/* Hold lock when lock_vol returns? */
-#define LCK_LOCAL	0x00000040	/* Don't propagate to other nodes */
-#define LCK_CLUSTER_VG	0x00000080	/* VG is clustered */
+#define LCK_NONBLOCK	0x00000010U	/* Don't block waiting for lock? */
+#define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
+#define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
+#define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
 
 /*
  * Additional lock bits for cluster communication
  */
-#define LCK_PARTIAL_MODE	0x00000001	/* Running in partial mode */
-#define LCK_MIRROR_NOSYNC_MODE	0x00000002	/* Mirrors don't require sync */
-#define LCK_DMEVENTD_MONITOR_MODE	0x00000004	/* Register with dmeventd */
+#define LCK_PARTIAL_MODE	0x00000001U	/* Running in partial mode */
+#define LCK_MIRROR_NOSYNC_MODE	0x00000002U	/* Mirrors don't require sync */
+#define LCK_DMEVENTD_MONITOR_MODE	0x00000004U	/* Register with dmeventd */
 
 
 /*
--- LVM2/lib/locking/locking_types.h	2007/08/20 20:55:26	1.14
+++ LVM2/lib/locking/locking_types.h	2007/08/22 14:38:17	1.15
@@ -17,7 +17,7 @@
 #include "config.h"
 
 typedef int (*lock_resource_fn) (struct cmd_context * cmd, const char *resource,
-				 int flags);
+				 uint32_t flags);
 
 typedef void (*fin_lock_fn) (void);
 typedef void (*reset_lock_fn) (void);
--- LVM2/lib/locking/no_locking.c	2007/08/20 20:55:26	1.12
+++ LVM2/lib/locking/no_locking.c	2007/08/22 14:38:17	1.13
@@ -37,7 +37,7 @@
 }
 
 static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
-			     int flags)
+			     uint32_t flags)
 {
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
@@ -76,7 +76,7 @@
 	return 1;
 }
 
-int init_no_locking(struct locking_type *locking, struct cmd_context *cmd)
+int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attribute((unused)))
 {
 	locking->lock_resource = _no_lock_resource;
 	locking->reset_locking = _no_reset_locking;
--- LVM2/lib/metadata/lv_alloc.h	2007/08/20 20:55:26	1.16
+++ LVM2/lib/metadata/lv_alloc.h	2007/08/22 14:38:17	1.17
@@ -50,7 +50,6 @@
 				      uint32_t extents,
                                       struct physical_volume *mirrored_pv,
                                       uint32_t mirrored_pe,
-                                      uint32_t status,
                                       struct list *allocatable_pvs,
 				      alloc_policy_t alloc,
 				      struct list *parallel_areas);
--- LVM2/lib/metadata/lv_manip.c	2007/08/21 19:46:36	1.126
+++ LVM2/lib/metadata/lv_manip.c	2007/08/22 14:38:17	1.127
@@ -735,13 +735,13 @@
 					       (le - seg->le) / area_multiple,
 					       area_len, max_seg_len,
 					       only_single_area_segments ? 0 : 0,
-					       only_single_area_segments ? 1 : 0,
-					       top_level_area_index != -1 ? top_level_area_index : s,
+					       only_single_area_segments ? 1U : 0U,
+					       top_level_area_index != -1 ? top_level_area_index : (int) s,
 					       only_single_area_segments, fn,
 					       data)))
 				stack;
 		} else if (seg_type(seg, s) == AREA_PV)
-			if (!(r = fn(cmd, seg_pvseg(seg, s), top_level_area_index != -1 ? top_level_area_index : s, data)))
+			if (!(r = fn(cmd, seg_pvseg(seg, s), top_level_area_index != -1 ? (uint32_t) top_level_area_index : s, data)))
 				stack;
 		if (r != 1)
 			return r;
@@ -813,7 +813,7 @@
 	return 1;
 }
 
-static int _is_condition(struct cmd_context *cmd,
+static int _is_condition(struct cmd_context *cmd __attribute((unused)),
 			 struct pv_segment *pvseg, uint32_t s,
 			 void *data)
 {
@@ -1068,11 +1068,9 @@
  */
 static int _allocate(struct alloc_handle *ah,
 		     struct volume_group *vg,
-		     struct logical_volume *lv, uint32_t status,
+		     struct logical_volume *lv,
 		     uint32_t new_extents,
-		     struct list *allocatable_pvs,
-		     uint32_t stripes, uint32_t mirrors,
-		     const struct segment_type *segtype)
+		     struct list *allocatable_pvs)
 {
 	struct pv_area **areas;
 	uint32_t allocated = lv ? lv->le_count : 0;
@@ -1197,7 +1195,6 @@
 				      uint32_t extents,
 				      struct physical_volume *mirrored_pv,
 				      uint32_t mirrored_pe,
-				      uint32_t status,
 				      struct list *allocatable_pvs,
 				      alloc_policy_t alloc,
 				      struct list *parallel_areas)
@@ -1230,8 +1227,8 @@
 	}
 
 	if (!segtype_is_virtual(segtype) &&
-	    !_allocate(ah, vg, lv, status, (lv ? lv->le_count : 0) + extents,
-		       allocatable_pvs, stripes, mirrors, segtype)) {
+	    !_allocate(ah, vg, lv, (lv ? lv->le_count : 0) + extents,
+		       allocatable_pvs)) {
 		stack;
 		alloc_destroy(ah);
 		return NULL;
@@ -1334,8 +1331,8 @@
 			  struct logical_volume *lv,
 			  struct logical_volume **sub_lvs,
 			  uint32_t mirrors,
-			  const struct segment_type *segtype,
-			  uint32_t status,
+			  const struct segment_type *segtype __attribute((unused)),
+			  uint32_t status __attribute((unused)),
 			  uint32_t region_size,
 			  struct logical_volume *log_lv)
 {
@@ -1431,7 +1428,7 @@
 		return lv_add_virtual_segment(lv, status, extents, segtype);
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0,
-				    extents, mirrored_pv, mirrored_pe, status,
+				    extents, mirrored_pv, mirrored_pe,
 				    allocatable_pvs, alloc, NULL))) {
 		stack;
 		return 0;
@@ -1556,7 +1553,7 @@
 			    void *data)
 {
 	struct lv_segment *seg;
-	int s;
+	uint32_t s;
 
 	list_iterate_items(seg, &lv->segments) {
 		if (seg->log_lv && !func(cmd, seg->log_lv, data))
--- LVM2/lib/metadata/metadata-exported.h	2007/08/21 17:37:53	1.12
+++ LVM2/lib/metadata/metadata-exported.h	2007/08/22 14:38:17	1.13
@@ -323,7 +323,7 @@
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
              uint32_t new_pe_count);
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
-	       int64_t label_sector);
+	       uint64_t label_sector);
 
 struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
 			       uint32_t extent_size, uint32_t max_pv,
@@ -430,9 +430,9 @@
 			 struct logical_volume *log_lv);
 
 int remove_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			 struct list *removable_pvs, int remove_log);
+			 struct list *removable_pvs, unsigned remove_log);
 int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			      struct list *removable_pvs, int remove_log);
+			      struct list *removable_pvs, unsigned remove_log);
 
 int insert_pvmove_mirrors(struct cmd_context *cmd,
 			  struct logical_volume *lv_mirr,
--- LVM2/lib/metadata/metadata.c	2007/08/21 17:38:08	1.133
+++ LVM2/lib/metadata/metadata.c	2007/08/22 14:38:17	1.134
@@ -251,7 +251,7 @@
 
 int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 		     struct volume_group *vg, int consistent,
-		     force_t force)
+		     force_t force __attribute((unused)))
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -466,8 +466,8 @@
 	return 1;
 }
 
-int vg_change_pesize(struct cmd_context *cmd, struct volume_group *vg,
-		     uint32_t new_size)
+int vg_change_pesize(struct cmd_context *cmd __attribute((unused)),
+		     struct volume_group *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
 	struct pv_list *pvl;
@@ -617,8 +617,8 @@
 	return 1;
 }
 
-int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
-		  struct volume_group *vg_to)
+int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
+		  struct volume_group *vg_from, struct volume_group *vg_to)
 {
 	struct metadata_area *mda, *mda2;
 	struct list *mdas_from, *mdas_to;
@@ -1783,7 +1783,7 @@
  *  1 - success
  */
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
-	       int64_t label_sector)
+	       uint64_t label_sector)
 {
 	struct label *label;
 	struct device *dev;
--- LVM2/lib/metadata/mirror.c	2007/08/20 20:55:26	1.40
+++ LVM2/lib/metadata/mirror.c	2007/08/22 14:38:17	1.41
@@ -118,7 +118,7 @@
  * Reduce mirrored_seg to num_mirrors images.
  */
 int remove_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			 struct list *removable_pvs, int remove_log)
+			 struct list *removable_pvs, unsigned remove_log)
 {
 	uint32_t m;
 	uint32_t extents;
@@ -255,7 +255,8 @@
 	return 1;
 }
 
-static int get_mirror_fault_policy(struct cmd_context *cmd, int log_policy)
+static int get_mirror_fault_policy(struct cmd_context *cmd __attribute((unused)),
+				   int log_policy)
 {
 	const char *policy;
 
@@ -347,7 +348,7 @@
 }
 
 int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
-			      struct list *removable_pvs, int remove_log)
+			      struct list *removable_pvs, unsigned remove_log)
 {
 	int r;
 	int insync = 0;
@@ -416,7 +417,7 @@
 				     uint32_t first_area,
 				     uint32_t num_mirrors,
 				     struct logical_volume *lv,
-				     const struct segment_type *segtype,
+				     const struct segment_type *segtype __attribute((unused)),
 				     struct logical_volume **img_lvs)
 {
 	uint32_t m;
@@ -467,7 +468,7 @@
 			 uint32_t num_mirrors,
 			 struct logical_volume *lv,
 			 const struct segment_type *segtype,
-			 uint32_t status,
+			 uint32_t status __attribute((unused)),
 			 uint32_t region_size,
 			 struct logical_volume *log_lv)
 {
@@ -508,7 +509,7 @@
 
 int add_mirror_layers(struct alloc_handle *ah,
 		      uint32_t num_mirrors,
-		      uint32_t existing_mirrors,
+		      uint32_t existing_mirrors __attribute((unused)),
 		      struct logical_volume *lv,
 		      const struct segment_type *segtype)
 {
--- LVM2/lib/misc/lvm-string.c	2007/08/20 20:55:27	1.14
+++ LVM2/lib/misc/lvm-string.c	2007/08/22 14:38:17	1.15
@@ -27,7 +27,7 @@
 	n = vsnprintf(*buffer, *size, fmt, ap);
 	va_end(ap);
 
-	if (n < 0 || (n == *size))
+	if (n < 0 || ((size_t)n == *size))
 		return 0;
 
 	*buffer += n;
@@ -40,10 +40,10 @@
  *
  * Returns:
  *  len - incremented for each char we encounter, whether 'c' or not.
- *  count - number of occurences of 'c'
+ *  count - number of occurrences of 'c'
  */
 void count_chars(const char *str, size_t *len, int *count,
-		 const char c)
+		 const int c)
 {
 	const char *ptr;
 
@@ -56,18 +56,18 @@
  * Count occurences of 'c' in 'str' of length 'size'.
  *
  * Returns:
- *   # of occurences of 'c'
+ *   Number of occurrences of 'c'
  */
-unsigned count_chars_len(const char *str, size_t size, const char c)
+unsigned count_chars_len(const char *str, size_t len, const int c)
 {
-	int i;
-	unsigned count=0;
+	size_t i;
+	unsigned count = 0;
 
-	for (i=0; i < size; i++)
+	for (i = 0; i < len; i++)
 		if (str[i] == c)
 			count++;
-	return count;
 
+	return count;
 }
 
 /*
--- LVM2/lib/misc/lvm-string.h	2007/08/20 20:55:27	1.16
+++ LVM2/lib/misc/lvm-string.h	2007/08/22 14:38:17	1.17
@@ -32,7 +32,7 @@
 int validate_name(const char *n);
 
 void count_chars(const char *str, size_t *len, int *count,
-		 char c);
-unsigned count_chars_len(const char *str, size_t size, char c);
+		 const int c);
+unsigned count_chars_len(const char *str, size_t len, const int c);
 
 #endif
--- LVM2/lib/report/report.c	2007/08/20 20:55:27	1.60
+++ LVM2/lib/report/report.c	2007/08/22 14:38:17	1.61
@@ -62,25 +62,25 @@
 /*
  * Data-munging functions to prepare each data type for display and sorting
  */
-static int _string_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private)
+			const void *data, void *private __attribute((unused)))
 {
 	return dm_report_field_string(rh, field, (const char **) data);
 }
 
-static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			  struct dm_report_field *field,
-			  const void *data, void *private)
+			  const void *data, void *private __attribute((unused)))
 {
 	const char *name = dev_name(*(const struct device **) data);
 
 	return dm_report_field_string(rh, field, &name);
 }
 
-static int _devices_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _devices_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			 struct dm_report_field *field,
-			 const void *data, void *private)
+			 const void *data, void *private __attribute((unused)))
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	unsigned int s;
@@ -141,9 +141,9 @@
 	return 1;
 }
 
-static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _tags_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 		      struct dm_report_field *field,
-		      const void *data, void *private)
+		      const void *data, void *private __attribute((unused)))
 {
 	const struct list *tags = (const struct list *) data;
 	struct str_list *sl;
@@ -218,9 +218,9 @@
 	return _string_disp(rh, mem, field, &pv->fmt->name, private);
 }
 
-static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private)
+			const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
@@ -232,9 +232,9 @@
 	return dm_report_field_uint64(rh, field, &minusone);
 }
 
-static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private)
+			const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
@@ -246,9 +246,9 @@
 	return dm_report_field_uint64(rh, field, &minusone);
 }
 
-static int _lvstatus_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private)
+			  const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
@@ -331,9 +331,9 @@
 	return 1;
 }
 
-static int _pvstatus_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _pvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private)
+			  const void *data, void *private __attribute((unused)))
 {
 	const uint32_t status = *(const uint32_t *) data;
 	char *repstr;
@@ -357,9 +357,9 @@
 	return 1;
 }
 
-static int _vgstatus_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _vgstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private)
+			  const void *data, void *private __attribute((unused)))
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
 	char *repstr;
@@ -401,9 +401,9 @@
 }
 
 static int _segtype_disp(struct dm_report *rh __attribute((unused)),
-			 struct dm_pool *mem,
+			 struct dm_pool *mem __attribute((unused)),
 			 struct dm_report_field *field,
-			 const void *data, void *private)
+			 const void *data, void *private __attribute((unused)))
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
@@ -416,9 +416,9 @@
 	return 1;
 }
 
-static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _origin_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private)
+			const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
@@ -430,9 +430,9 @@
 	return 1;
 }
 
-static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 		       struct dm_report_field *field,
-		       const void *data, void *private)
+		       const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lv_segment *seg;
@@ -450,7 +450,7 @@
 
 static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
-			const void *data, void *private)
+			const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	char *repstr, *lvname;
@@ -482,9 +482,9 @@
 	return 1;
 }
 
-static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private)
+			const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const char *name;
@@ -501,7 +501,7 @@
 	return 1;
 }
 
-static int _size32_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _size32_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
@@ -531,7 +531,8 @@
 	return 1;
 }
 
-static int _size64_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _size64_disp(struct dm_report *rh __attribute((unused)),
+			struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
 {
@@ -684,9 +685,9 @@
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
-static int _uuid_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _uuid_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 		      struct dm_report_field *field,
-		      const void *data, void *private)
+		      const void *data, void *private __attribute((unused)))
 {
 	char *repstr = NULL;
 
@@ -704,16 +705,16 @@
 	return 1;
 }
 
-static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			struct dm_report_field *field,
-			const void *data, void *private)
+			const void *data, void *private __attribute((unused)))
 {
 	return dm_report_field_uint32(rh, field, data);
 }
 
-static int _int32_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _int32_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 		       struct dm_report_field *field,
-		       const void *data, void *private)
+		       const void *data, void *private __attribute((unused)))
 {
 	return dm_report_field_int32(rh, field, data);
 }
@@ -756,9 +757,9 @@
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
-static int _snpercent_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _snpercent_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			   struct dm_report_field *field,
-			   const void *data, void *private)
+			   const void *data, void *private __attribute((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
@@ -806,9 +807,9 @@
 	return 1;
 }
 
-static int _copypercent_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _copypercent_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			     struct dm_report_field *field,
-			     const void *data, void *private)
+			     const void *data, void *private __attribute((unused)))
 {
 	struct logical_volume *lv = (struct logical_volume *) data;
 	float percent;
--- LVM2/lib/snapshot/snapshot.c	2007/08/20 20:55:27	1.21
+++ LVM2/lib/snapshot/snapshot.c	2007/08/22 14:38:18	1.22
@@ -128,7 +128,7 @@
 #endif
 
 static int _snap_modules_needed(struct dm_pool *mem,
-				const struct lv_segment *seg,
+				const struct lv_segment *seg __attribute((unused)),
 				struct list *modules)
 {
 	if (!str_list_add(mem, modules, "snapshot")) {
--- LVM2/lib/zero/zero.c	2007/08/20 20:55:29	1.13
+++ LVM2/lib/zero/zero.c	2007/08/22 14:38:18	1.14
@@ -65,7 +65,7 @@
 #endif
 
 static int _zero_modules_needed(struct dm_pool *mem,
-				const struct lv_segment *seg,
+				const struct lv_segment *seg __attribute((unused)),
 				struct list *modules)
 {
 	if (!str_list_add(mem, modules, "zero")) {
--- LVM2/tools/lvconvert.c	2007/08/21 19:46:36	1.35
+++ LVM2/tools/lvconvert.c	2007/08/22 14:38:18	1.36
@@ -338,9 +338,9 @@
 
 		if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype,
 					    1, lp->mirrors - 1,
-					    corelog ? 0 : 1,
+					    corelog ? 0U : 1U,
 					    lv->le_count * (lp->mirrors - 1),
-					    NULL, 0, 0, lp->pvh,
+					    NULL, 0, lp->pvh,
 					    lp->alloc,
 					    parallel_areas)))
 			return_0;
@@ -390,7 +390,7 @@
 
 			if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0,
 						    0, 1, 0,
-						    NULL, 0, 0, lp->pvh,
+						    NULL, 0, lp->pvh,
 						    lp->alloc,
 						    parallel_areas))) {
 				stack;
@@ -503,7 +503,7 @@
 
 	if (!lp->zero || !(lv->status & LVM_WRITE))
 		log_warn("WARNING: \"%s\" not zeroed", lv->name);
-	else if (!set_lv(cmd, lv, 0, 0)) {
+	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
 		log_error("Aborting. Failed to wipe snapshot "
 			  "exception store.");
 		return 0;
--- LVM2/tools/lvcreate.c	2007/08/21 19:46:36	1.142
+++ LVM2/tools/lvcreate.c	2007/08/22 14:38:18	1.143
@@ -572,7 +572,7 @@
 			log_error("Volume too large (%s) for extent size %s. "
 				  "Upper limit is %s.",
 				  display_size(cmd, tmp_size),
-				  display_size(cmd, vg->extent_size),
+				  display_size(cmd, (uint64_t) vg->extent_size),
 				  display_size(cmd, (uint64_t) UINT32_MAX *
 						   vg->extent_size));
 			return 0;
@@ -707,8 +707,8 @@
 		/* FIXME Calculate how many extents needed for the log */
 
 		if (!(ah = allocate_extents(vg, NULL, lp->segtype, lp->stripes,
-					    lp->mirrors, lp->corelog ? 0 : 1,
-					    lp->extents, NULL, 0, 0,
+					    lp->mirrors, lp->corelog ? 0U : 1U,
+					    lp->extents, NULL, 0,
 					    pvh, lp->alloc, NULL))) {
 			stack;
 			return 0;
@@ -804,7 +804,7 @@
 	}
 
 	if ((lp->zero || lp->snapshot) && activation()) {
-		if (!set_lv(cmd, lv, 0, 0) && lp->snapshot) {
+		if (!set_lv(cmd, lv, UINT64_C(0), 0) && lp->snapshot) {
 			/* FIXME Remove the failed lv we just added */
 			log_error("Aborting. Failed to wipe snapshot "
 				  "exception store. Remove new LV and retry.");
--- LVM2/tools/pvck.c	2007/08/20 20:55:30	1.3
+++ LVM2/tools/pvck.c	2007/08/22 14:38:18	1.4
@@ -32,7 +32,7 @@
 		log_verbose("Scanning %s", argv[i]);
 
 		pv_analyze(cmd, argv[i],
-			   arg_int64_value(cmd, labelsector_ARG,
+			   arg_uint64_value(cmd, labelsector_ARG,
 					   UINT64_C(0)));
 	}
 
--- LVM2/tools/reporter.c	2007/08/20 20:55:30	1.26
+++ LVM2/tools/reporter.c	2007/08/22 14:38:18	1.27
@@ -134,7 +134,8 @@
 }
 
 static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
-		      struct volume_group *vg, int consistent,
+		      struct volume_group *vg,
+		      int consistent __attribute((unused)),
 		      void *handle)
 {
 	if (!vg) {
@@ -146,7 +147,8 @@
 }
 
 static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
-			 struct volume_group *vg, int consistent,
+			 struct volume_group *vg,
+			 int consistent __attribute((unused)),
 			 void *handle)
 {
 	if (!vg) {
--- LVM2/tools/toollib.c	2007/08/20 20:55:30	1.104
+++ LVM2/tools/toollib.c	2007/08/22 14:38:18	1.105
@@ -221,7 +221,7 @@
 }
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    int lock_type, void *handle,
+		    uint32_t lock_type, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle))
@@ -392,7 +392,7 @@
 				list_init(&lvnames);
 				break;
 			} else if (!strncmp(vg_name, vgname, strlen(vgname)) &&
-				   strlen(vgname) == lv_name - vg_name) {
+				   strlen(vgname) == (size_t) (lv_name - vg_name)) {
 				if (!str_list_add(cmd->mem, &lvnames,
 						  dm_pool_strdup(cmd->mem,
 							      lv_name + 1))) {
@@ -463,7 +463,7 @@
 static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			   const char *vgid,
 			   struct list *tags, struct list *arg_vgnames,
-			   int lock_type, int consistent, void *handle,
+			   uint32_t lock_type, int consistent, void *handle,
 			   int ret_max,
 			   int (*process_single) (struct cmd_context * cmd,
 						  const char *vg_name,
@@ -513,7 +513,7 @@
 }
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    int lock_type, int consistent, void *handle,
+		    uint32_t lock_type, int consistent, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   const char *vg_name,
 					   struct volume_group * vg,
@@ -1133,7 +1133,7 @@
  * Attempt metadata recovery
  */
 struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
-				int lock_type)
+				uint32_t lock_type)
 {
 	int consistent = 1;
 
--- LVM2/tools/toollib.h	2007/08/20 20:55:30	1.49
+++ LVM2/tools/toollib.h	2007/08/22 14:38:18	1.50
@@ -24,10 +24,10 @@
 int autobackup(struct volume_group *vg);
 
 struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
-				int lock_type);
+				uint32_t lock_type);
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    int lock_type, int consistent, void *handle,
+		    uint32_t lock_type, int consistent, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   const char *vg_name,
 					   struct volume_group * vg,
@@ -49,7 +49,7 @@
 						      void *handle));
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    int lock_type, void *handle,
+		    uint32_t lock_type, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle));
--- LVM2/tools/vgreduce.c	2007/08/20 20:55:30	1.66
+++ LVM2/tools/vgreduce.c	2007/08/22 14:38:18	1.67
@@ -301,7 +301,7 @@
 				}
 			}
 
-			if ((mimages != mirrored_seg->area_count) || (remove_log)){
+			if ((mimages != mirrored_seg->area_count) || remove_log){
 				if (!reconfigure_mirror_images(mirrored_seg, mimages,
 							       NULL, remove_log)) {
 					stack;
--- LVM2/tools/vgsplit.c	2007/08/20 20:55:30	1.35
+++ LVM2/tools/vgsplit.c	2007/08/22 14:38:18	1.36
@@ -173,7 +173,7 @@
 	struct list *lvh, *lvht;
 	struct logical_volume *lv;
 	struct lv_segment *seg;
-	int i, seg_in, log_in;
+	unsigned s, seg_in, log_in;
 
 	list_iterate_safe(lvh, lvht, &vg_from->lvs) {
 		lv = list_item(lvh, struct lv_list)->lv;
@@ -184,8 +184,8 @@
 		seg = first_seg(lv); 
 
 		seg_in = 0;
-		for (i = 0; i < seg->area_count; i++)
-			if (_lv_is_in_vg(vg_to, seg_lv(seg, i)))
+		for (s = 0; s < seg->area_count; s++)
+			if (_lv_is_in_vg(vg_to, seg_lv(seg, s)))
 			    seg_in++;
 
 		log_in = (!seg->log_lv || _lv_is_in_vg(vg_to, seg->log_lv));


