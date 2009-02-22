From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Feb 2009 19:00:31 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/format1/ ...
Message-ID: <20090222190031.25083.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-22 19:00:28

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: archiver.c format-text.c text_label.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	man            : lvm.conf.5.in pvcreate.8.in 
	test           : t-pvcreate-usage.sh 
	tools          : args.h commands.h pvcreate.c vgconvert.c 

Log message:
	Add --dataalignment to pvcreate to specify alignment of data area.  (mbroz)
	
	This patch is not fully tested and leaves some related bugs unfixed.
	
	Intended behaviour of the code now:
	
	pe_start in the lvm2 format PV label header is set only by pvcreate (or
	vgconvert -M2) and then preserved in *all* operations thereafter.
	
	In some specialist cases, after the PV is added to a VG, the pe_start
	field in the VG metadata may hold a different value and if so, it
	overrides the other one for as long as the PV is in such a VG.
	
	Currently, the field storing the size of the data area in the PV label
	header always holds 0.  As it only has meaning in the context of a
	volume group, it is calculated whenever the PV is added to a VG (and can
	be derived from extent_size and pe_count in the VG metadata).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1047&r2=1.1048
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.203&r2=1.204
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.188&r2=1.189
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW	2009/02/22 16:13:57	1.1047
+++ LVM2/WHATS_NEW	2009/02/22 19:00:26	1.1048
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Add --dataalignment to pvcreate to specify alignment of data area.
   Exclude LCK_CACHE locks from _vg_lock_count, fixing interrupt unblocking.
   Provide da and mda locations in debug message when writing text format label.
   Mention the restriction on file descriptors at invocation on the lvm man page.
--- LVM2/doc/example.conf	2008/09/19 06:41:57	1.38
+++ LVM2/doc/example.conf	2009/02/22 19:00:26	1.39
@@ -86,7 +86,7 @@
     # If sysfs is mounted (2.6 kernels) restrict device scanning to 
     # the block devices it believes are valid.
     # 1 enables; 0 disables.
-    sysfs_scan = 1	
+    sysfs_scan = 1
 
     # By default, LVM2 will ignore devices used as components of
     # software RAID (md) devices by looking for md superblocks.
@@ -98,6 +98,12 @@
     # 1 enables; 0 disables.
     md_chunk_alignment = 1
 
+    # Alignment (in KB) of start of data area when creating a new PV.
+    # If a PV is placed directly upon an md device and md_chunk_alignment is
+    # enabled this parameter is ignored.
+    # Set to 0 for the default alignment of 64KB or page size, if larger.
+    data_alignment = 0
+
     # If, while scanning the system for PVs, LVM2 encounters a device-mapper
     # device that has its I/O suspended, it waits for it to become accessible.
     # Set this to 1 to skip such devices.  This should only be needed
@@ -129,7 +135,7 @@
     # There are 6 syslog-like log levels currently in use - 2 to 7 inclusive.
     # 7 is the most verbose (LOG_DEBUG).
     level = 0
-    
+
     # Format of output messages
     # Whether or not (1 or 0) to indent messages according to their severity
     indent = 1
@@ -175,7 +181,7 @@
     # Where should archived files go ?
     # Remember to back up this directory regularly!
     archive_dir = "/etc/lvm/archive"
-    
+
     # What is the minimum number of archive files you wish to keep ?
     retain_min = 10
 
@@ -193,7 +199,7 @@
 
 # Miscellaneous global LVM2 settings
 global {
-    
+
     # The file creation mask for any files and directories created.
     # Interpreted as octal if the first digit is zero.
     umask = 077
--- LVM2/lib/format1/format1.c	2008/11/03 22:14:28	1.109
+++ LVM2/lib/format1/format1.c	2009/02/22 19:00:27	1.110
@@ -292,6 +292,7 @@
 static int _format1_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
 		     uint32_t extent_size,
+		     unsigned long data_alignment __attribute((unused)),
 		     int pvmetadatacopies __attribute((unused)),
 		     uint64_t pvmetadatasize __attribute((unused)), struct dm_list *mdas __attribute((unused)),
 		     struct physical_volume *pv, struct volume_group *vg __attribute((unused)))
--- LVM2/lib/format_pool/format_pool.c	2008/11/03 22:14:28	1.18
+++ LVM2/lib/format_pool/format_pool.c	2009/02/22 19:00:27	1.19
@@ -191,6 +191,7 @@
 			  uint64_t pe_start __attribute((unused)),
 			  uint32_t extent_count __attribute((unused)),
 			  uint32_t extent_size __attribute((unused)),
+			  unsigned long data_alignment __attribute((unused)),
 			  int pvmetadatacopies __attribute((unused)),
 			  uint64_t pvmetadatasize __attribute((unused)),
 			  struct dm_list *mdas __attribute((unused)),
--- LVM2/lib/format_text/archiver.c	2008/12/11 03:33:35	1.17
+++ LVM2/lib/format_text/archiver.c	2009/02/22 19:00:27	1.18
@@ -307,7 +307,7 @@
 			return 0;
 		}
 		if (!vg->fid->fmt->ops->
-		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0,
+		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0UL,
 			     UINT64_C(0), &vg->fid->metadata_areas, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pv));
--- LVM2/lib/format_text/format-text.c	2009/01/09 22:44:33	1.100
+++ LVM2/lib/format_text/format-text.c	2009/02/22 19:00:27	1.101
@@ -32,6 +32,7 @@
 
 #include <unistd.h>
 #include <sys/file.h>
+#include <sys/param.h>
 #include <limits.h>
 #include <dirent.h>
 #include <ctype.h>
@@ -1182,7 +1183,7 @@
 	if (!pvmetadatacopies)
 		return 1;
 
-	alignment = pe_align(pv) << SECTOR_SHIFT;
+	alignment = pv->pe_align << SECTOR_SHIFT;
 	disk_size = pv->size << SECTOR_SHIFT;
 	pe_start <<= SECTOR_SHIFT;
 	pe_end <<= SECTOR_SHIFT;
@@ -1296,6 +1297,7 @@
 
 /* Only for orphans */
 /* Set label_sector to -1 if rewriting existing label into same sector */
+/* If mdas is supplied it overwrites existing mdas e.g. used with pvcreate */
 static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv,
 		     struct dm_list *mdas, int64_t label_sector)
 {
@@ -1306,6 +1308,7 @@
 	char buf[MDA_HEADER_SIZE] __attribute((aligned(8)));
 	struct mda_header *mdah = (struct mda_header *) buf;
 	uint64_t adjustment;
+	struct data_area_list *da;
 
 	/* FIXME Test mode don't update cache? */
 
@@ -1342,14 +1345,24 @@
 		dm_list_init(&info->mdas);
 	}
 
-	if (info->das.n)
+	/*
+	 * If no pe_start supplied but PV already exists,
+	 * preserve existing value.
+	 */
+	if (info->das.n) {
+		if (!pv->pe_start)
+			dm_list_iterate_items(da, &info->das)
+				pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
 		del_das(&info->das);
-	else
+	} else
 		dm_list_init(&info->das);
 
-	/* Set pe_start to first aligned sector after any metadata
-	 * areas that begin before pe_start */
-	pv->pe_start = pe_align(pv);
+	/*
+	 * If pe_start is still unset, set it to first aligned
+	 * sector after any metadata areas that begin before pe_start.
+	 */
+	if (!pv->pe_start)
+		pv->pe_start = pv->pe_align;
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (pv->dev == mdac->area.dev &&
@@ -1358,9 +1371,9 @@
 		     (pv->pe_start << SECTOR_SHIFT))) {
 			pv->pe_start = (mdac->area.start + mdac->area.size)
 			    >> SECTOR_SHIFT;
-			adjustment = pv->pe_start % pe_align(pv);
+			adjustment = pv->pe_start % pv->pe_align;
 			if (adjustment)
-				pv->pe_start += (pe_align(pv) - adjustment);
+				pv->pe_start += pv->pe_align - adjustment;
 		}
 	}
 	if (!add_da
@@ -1574,7 +1587,7 @@
 /* pvmetadatasize in sectors */
 static int _text_pv_setup(const struct format_type *fmt,
 		     uint64_t pe_start, uint32_t extent_count,
-		     uint32_t extent_size,
+		     uint32_t extent_size, unsigned long data_alignment,
 		     int pvmetadatacopies,
 		     uint64_t pvmetadatasize, struct dm_list *mdas,
 		     struct physical_volume *pv, struct volume_group *vg)
@@ -1665,6 +1678,23 @@
 		/* FIXME Default from config file? vgextend cmdline flag? */
 		pv->status |= ALLOCATABLE_PV;
 	} else {
+		if (pe_start)
+			pv->pe_start = pe_start;
+
+		if (!data_alignment)
+			data_alignment = find_config_tree_int(pv->fmt->cmd,
+						      "devices/data_alignment",
+						      0) * 2;
+
+		if (set_pe_align(pv, data_alignment) != data_alignment &&
+		    data_alignment)
+			log_warn("WARNING: %s: Overriding data alignment to "
+				 "%lu sectors (requested %lu sectors)",
+				 pv_dev_name(pv), pv->pe_align, data_alignment);
+
+		if (pv->pe_start < pv->pe_align)
+			pv->pe_start = pv->pe_align;
+
 		if (extent_count)
 			pe_end = pe_start + extent_count * extent_size - 1;
 		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,
--- LVM2/lib/format_text/text_label.c	2009/02/20 23:19:28	1.23
+++ LVM2/lib/format_text/text_label.c	2009/02/22 19:00:27	1.24
@@ -136,6 +136,12 @@
 		  mda2 ? xlate64(pvhdr->disk_areas_xl[mda2].size) >> SECTOR_SHIFT : 0,
 		  mda2 ? "s)" : "");
 
+	if (da1 < 0) {
+		log_error("Internal error: %s label header currently requires "
+			  "a data area.", dev_name(info->dev));
+		return 0;
+	}
+
 	return 1;
 }
 
--- LVM2/lib/metadata/metadata-exported.h	2009/02/03 16:19:26	1.61
+++ LVM2/lib/metadata/metadata-exported.h	2009/02/22 19:00:27	1.62
@@ -407,6 +407,7 @@
 		      struct device *dev,
 		      struct id *id,
 		      uint64_t size,
+		      unsigned long data_alignment,
 		      uint64_t pe_start,
 		      uint32_t existing_extent_count,
 		      uint32_t existing_extent_size,
--- LVM2/lib/metadata/metadata.c	2009/02/03 16:19:26	1.203
+++ LVM2/lib/metadata/metadata.c	2009/02/22 19:00:27	1.204
@@ -46,6 +46,7 @@
 static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  struct device *dev,
 				  struct id *id, uint64_t size,
+				  unsigned long data_alignment,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -65,19 +66,22 @@
 static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
 						      const struct id *id);
 
-unsigned long pe_align(struct physical_volume *pv)
+unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
 	if (pv->pe_align)
 		goto out;
 
-	pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
+	if (data_alignment)
+		pv->pe_align = data_alignment;
+	else 
+		pv->pe_align = MAX(65536UL, lvm_getpagesize()) >> SECTOR_SHIFT;
 
-	/*
-	 * Align to chunk size of underlying md device if present
-	 */
 	if (!pv->dev)
 		goto out;
 
+	/*
+	 * Align to chunk size of underlying md device if present
+	 */
 	if (find_config_tree_bool(pv->fmt->cmd, "devices/md_chunk_alignment",
 				  DEFAULT_MD_CHUNK_ALIGNMENT))
 		pv->pe_align = MAX(pv->pe_align,
@@ -146,18 +150,13 @@
 	/* Units of 512-byte sectors */
 	pv->pe_size = vg->extent_size;
 
-	/* FIXME Do proper rounding-up alignment? */
-	/* Reserved space for label; this holds 0 for PVs created by LVM1 */
-	if (pv->pe_start < pe_align(pv))
-		pv->pe_start = pe_align(pv);
-
 	/*
 	 * pe_count must always be calculated by pv_setup
 	 */
 	pv->pe_alloc_count = 0;
 
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
-				     vg->extent_size, 0, UINT64_C(0),
+				     vg->extent_size, 0, 0UL, UINT64_C(0),
 				     &fid->metadata_areas, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
@@ -759,6 +758,7 @@
  * @dev: PV device to initialize
  * @id: PV UUID to use for initialization
  * @size: size of the PV in sectors
+ * @data_alignment: requested alignment of data
  * @pe_start: physical extent start
  * @existing_extent_count
  * @existing_extent_size
@@ -776,13 +776,14 @@
 pv_t *pv_create(const struct cmd_context *cmd,
 		struct device *dev,
 		struct id *id, uint64_t size,
+		unsigned long data_alignment,
 		uint64_t pe_start,
 		uint32_t existing_extent_count,
 		uint32_t existing_extent_size,
 		int pvmetadatacopies,
 		uint64_t pvmetadatasize, struct dm_list *mdas)
 {
-	return _pv_create(cmd->fmt, dev, id, size, pe_start,
+	return _pv_create(cmd->fmt, dev, id, size, data_alignment, pe_start,
 			  existing_extent_count,
 			  existing_extent_size,
 			  pvmetadatacopies,
@@ -826,6 +827,7 @@
 static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  struct device *dev,
 				  struct id *id, uint64_t size,
+				  unsigned long data_alignment,
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
@@ -870,13 +872,14 @@
 	pv->vg_name = fmt->orphan_vg_name;
 
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
-				existing_extent_size,
+				existing_extent_size, data_alignment,
 				pvmetadatacopies, pvmetadatasize, mdas,
 				pv, NULL)) {
 		log_error("%s: Format-specific setup of physical volume "
 			  "failed.", pv_dev_name(pv));
 		goto bad;
 	}
+
 	return pv;
 
       bad:
--- LVM2/lib/metadata/metadata.h	2009/01/26 19:01:32	1.188
+++ LVM2/lib/metadata/metadata.h	2009/02/22 19:00:27	1.189
@@ -209,7 +209,7 @@
 	 */
 	int (*pv_setup) (const struct format_type * fmt,
 			 uint64_t pe_start, uint32_t extent_count,
-			 uint32_t extent_size,
+			 uint32_t extent_size, unsigned long data_alignment,
 			 int pvmetadatacopies,
 			 uint64_t pvmetadatasize, struct dm_list * mdas,
 			 struct physical_volume * pv, struct volume_group * vg);
@@ -263,7 +263,7 @@
 /*
  * Utility functions
  */
-unsigned long pe_align(struct physical_volume *pv);
+unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment);
 int vg_validate(struct volume_group *vg);
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
--- LVM2/man/lvm.conf.5.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvm.conf.5.in	2009/02/22 19:00:28	1.2
@@ -124,14 +124,28 @@
 be careful to avoid recursion within LVM2.  The figure for number 
 of partitions is not currently used in LVM2 - and might never be.
 .IP
-\fBsysfs_scan\fP (em If set to 1 and your kernel supports sysfs and 
+\fBsysfs_scan\fP \(em If set to 1 and your kernel supports sysfs and 
 it is mounted, sysfs will be used as a quick way of filtering out
 block devices that are not present.
 .IP
-\fBmd_component_detection\fP (em If set to 1, LVM2 will ignore devices
+\fBmd_component_detection\fP \(em If set to 1, LVM2 will ignore devices
 used as components of software RAID (md) devices by looking for md
 superblocks. This doesn't always work satisfactorily e.g. if a device 
 has been reused without wiping the md superblocks first.
+.IP
+\fBmd_chunk_alignment\fP \(em If set to 1, and a Physical Volume is placed
+directly upon an md device, LVM2 will align its data blocks with the the
+chunk_size exposed in sysfs.
+.IP
+\fBdata_alignment\fP \(em Default alignment (in KB) of start of data area
+when creating a new Physical Volume using the \fBlvm2\fP format.
+If a Physical Volume is placed directly upon an md device and
+\fBmd_chunk_alignment\fP is enabled this parameter is ignored.
+Set to 0 to use the default alignment of 64KB or the page size, if larger.
+.sp
+To see the location of the first Physical Extent of an existing Physical Volume
+use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
+\fBdata_alignment\fP.
 .TP
 \fBlog\fP \(em Default log settings
 .IP
--- LVM2/man/pvcreate.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/pvcreate.8.in	2009/02/22 19:00:28	1.3
@@ -13,6 +13,7 @@
 .RB [ \-M | \-\-metadatatype type ]
 .RB [ \-\-metadatacopies #copies ]
 .RB [ \-\-metadatasize size ]
+.RB [ \-\-dataalignment alignment ]
 .RB [ \-\-restorefile file ]
 .RB [ \-\-setphysicalvolumesize size ]
 .RB [ \-u | \-\-uuid uuid ]
@@ -89,6 +90,15 @@
 The approximate amount of space to be set aside for each metadata area.
 (The size you specify may get rounded.)
 .TP
+.BR \-\-dataalignment " alignment"
+Align the offset of the start of the data to a multiple of this number.
+You should also specify an appropriate \fBPhysicalExtentSize\fP when creating
+the Volume Group with \fBvgcreate\fP.
+.sp
+To see the location of the first Physical Extent of an existing Physical Volume
+use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
+\fBdata_alignment\fP.
+.TP
 .BR \-\-metadatacopies " copies"
 The number of metadata areas to set aside on each PV.  Currently
 this can be 0, 1 or 2.  
--- LVM2/test/t-pvcreate-usage.sh	2008/11/10 12:43:35	1.4
+++ LVM2/test/t-pvcreate-usage.sh	2009/02/22 19:00:28	1.5
@@ -70,3 +70,57 @@
 # x. BLKGETSIZE64 fails
 # x. set size to value inconsistent with device / PE size
 
+#COMM 'pvcreate basic dataalignment sanity checks'
+not pvcreate --dataalignment -1 $dev1
+not pvcreate -M 1 --dataalignment 1 $dev1
+not pvcreate --dataalignment 1E $dev1
+
+#COMM 'pvcreate always rounded up to page size for start of device'
+pvcreate --metadatacopies 0 --dataalignment 1 $dev1
+# amuse shell experts
+check_pv_field_ $dev1 pe_start $(($(getconf PAGESIZE)/1024))".00K"
+
+#COMM 'pvcreate sets data offset directly'
+pvcreate --dataalignment 512k $dev1
+check_pv_field_ $dev1 pe_start 512.00K
+
+#COMM 'vgcreate/vgremove do not modify data offset of existing PV'
+vgcreate $vg $dev1  --config 'devices { data_alignment = 1024 }'
+check_pv_field_ $dev1 pe_start 512.00K
+vgremove $vg --config 'devices { data_alignment = 1024 }'
+check_pv_field_ $dev1 pe_start 512.00K
+
+#COMM 'pvcreate sets data offset next to mda area'
+pvcreate --metadatasize 100k --dataalignment 100k $dev1
+check_pv_field_ $dev1 pe_start 200.00K
+
+#COMM 'pv with LVM1 compatible data alignment can be convereted'
+#compatible == LVM1_PE_ALIGN == 64k
+pvcreate --dataalignment 256k $dev1
+vgcreate -s 1M $vg $dev1
+vgconvert -M1 $vg
+vgconvert -M2 $vg
+check_pv_field_ $dev1 pe_start 256.00K
+vgremove $vg
+
+#COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
+pvcreate --dataalignment 10k $dev1
+vgcreate -s 1M $vg $dev1
+not vgconvert -M1 $vg
+vgremove $vg
+
+#COMM 'vgcfgrestore allows pe_start=0'
+#basically it produces nonsense, but it tests vgcfgrestore,
+#not that final cfg is usable...
+pvcreate --metadatacopies 0 $dev1
+pvcreate $dev2
+vgcreate $vg $dev1 $dev2
+vgcfgbackup -f "$(pwd)/backup.$$" $vg
+sed 's/pe_start = [0-9]*/pe_start = 0/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
+vgcfgrestore -f "$(pwd)/backup.$$1" $vg
+
+# BUG! this one fails, because now we read only label and vgcfgrestore does
+# not fix pe_start in label and there is no text metadta on this PV
+#check_pv_field_ $dev1 pe_start 0
+check_pv_field_ $dev2 pe_start 0
+vgremove $vg
--- LVM2/tools/args.h	2008/06/24 22:48:53	1.60
+++ LVM2/tools/args.h	2009/02/22 19:00:28	1.61
@@ -56,6 +56,7 @@
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
+arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2008/12/22 09:00:51	1.121
+++ LVM2/tools/commands.h	2009/02/22 19:00:28	1.122
@@ -462,6 +462,7 @@
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
+   "\t[--dataalignment Alignment[kKmMgGtTpPeE]]" "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-u|--uuid uuid] " "\n"
@@ -471,9 +472,9 @@
    "\t[--version] " "\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
-   force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG, metadatacopies_ARG,
-   metadatasize_ARG, physicalvolumesize_ARG, restorefile_ARG, uuidstr_ARG,
-   yes_ARG, zero_ARG)
+   dataalignment_ARG, force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG,
+   metadatacopies_ARG, metadatasize_ARG, physicalvolumesize_ARG,
+   restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
--- LVM2/tools/pvcreate.c	2008/11/03 22:14:30	1.76
+++ LVM2/tools/pvcreate.c	2009/02/22 19:00:28	1.77
@@ -19,6 +19,7 @@
 struct pvcreate_params {
 	int zero;
 	uint64_t size;
+	uint64_t data_alignment;
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;
 	int64_t labelsector;
@@ -177,7 +178,8 @@
 	}
 
 	dm_list_init(&mdas);
-	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size, pp->pe_start,
+	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
+			     pp->data_alignment, pp->pe_start,
 			     pp->extent_count, pp->extent_size,
 			     pp->pvmetadatacopies,
 			     pp->pvmetadatasize,&mdas))) {
@@ -305,8 +307,10 @@
 
 	if (!(cmd->fmt->features & FMT_MDAS) &&
 	    (arg_count(cmd, metadatacopies_ARG) ||
-	     arg_count(cmd, metadatasize_ARG))) {
-		log_error("Metadata parameters only apply to text format");
+	     arg_count(cmd, metadatasize_ARG)   ||
+	     arg_count(cmd, dataalignment_ARG))) {
+		log_error("Metadata and data alignment parameters only "
+			  "apply to text format.");
 		return 0;
 	}
 
@@ -329,6 +333,25 @@
 	}
 	pp->size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
 
+	if (arg_sign_value(cmd, dataalignment_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical volume data alignment may not be negative");
+		return 0;
+	}
+	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
+
+	if (pp->data_alignment > ULONG_MAX) {
+		log_error("Physical volume data alignment is too big.");
+		return 0;
+	}
+
+	if (pp->data_alignment && pp->pe_start) {
+		if (pp->pe_start % pp->data_alignment)
+			log_warn("WARNING: Ignoring data alignment %" PRIu64
+				 " incompatible with --restorefile value (%"
+				 PRIu64").", pp->data_alignment, pp->pe_start);
+		pp->data_alignment = 0;
+	}
+
 	if (arg_sign_value(cmd, metadatasize_ARG, 0) == SIGN_MINUS) {
 		log_error("Metadata size may not be negative");
 		return 0;
@@ -349,7 +372,6 @@
 	return 1;
 }
 
-
 int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i;
--- LVM2/tools/vgconvert.c	2008/11/03 22:14:30	1.31
+++ LVM2/tools/vgconvert.c	2009/02/22 19:00:28	1.32
@@ -133,7 +133,7 @@
 
 		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
-				     &existing_pv->id, size,
+				     &existing_pv->id, size, 0,
 				     pe_start, pv_pe_count(existing_pv),
 				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {


