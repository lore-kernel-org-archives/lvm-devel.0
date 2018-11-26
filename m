From: David Teigland <teigland@sourceware.org>
Date: Mon, 26 Nov 2018 17:37:24 -0500
Subject: master - Place the first PE at 1 MiB for all defaults
Message-ID: <201811262237.wAQMbOk3016104@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=904e1e3d26ccb43c19266e96e67f8c10f93eaaa4
Commit:        904e1e3d26ccb43c19266e96e67f8c10f93eaaa4
Parent:        2d1152103f8fce4892380f75f59dd5013bcd84d3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 13 15:00:11 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 26 16:36:50 2018 -0600

Place the first PE at 1 MiB for all defaults

. When using default settings, this commit should change
  nothing.  The first PE continues to be placed at 1 MiB
  resulting in a metadata area size of 1020 KiB (for
  4K page sizes; slightly smaller for larger page sizes.)

. When default_data_alignment is disabled in lvm.conf,
  align pe_start at 1 MiB, based on a default metadata area
  size that adapts to the page size.  Previously, disabling
  this option would result in mda_size that was too small
  for common use, and produced a 64 KiB aligned pe_start.

. Customized pe_start and mda_size values continue to be
  set as before in lvm.conf and command line.

. Remove the configure option for setting default_data_alignment
  at build time.

. Improve alignment related option descriptions.

. Add section about alignment to pvcreate man page.

Previously, DEFAULT_PVMETADATASIZE was 255 sectors.
However, the fact that the config setting named
"default_data_alignment" has a default value of 1 (MiB)
meant that DEFAULT_PVMETADATASIZE was having no effect.

The metadata area size is the space between the start of
the metadata area (page size offset from the start of the
device) and the first PE (1 MiB by default due to
default_data_alignment 1.)  The result is a 1020 KiB metadata
area on machines with 4KiB page size (1024 KiB - 4 KiB),
and smaller on machines with larger page size.

If default_data_alignment was set to 0 (disabled), then
DEFAULT_PVMETADATASIZE 255 would take effect, and produce a
metadata area that was 188 KiB and pe_start of 192 KiB.
This was too small for common use.

This is fixed by making the default metadata area size a
computed value that matches the value produced by
default_data_alignment.
---
 configure.ac                          |   10 --
 include/configure.h.in                |    3 -
 lib/config/config.c                   |    6 +
 lib/config/config.h                   |    2 +
 lib/config/config_settings.h          |   62 +++++++-----
 lib/config/defaults.h                 |   15 +++-
 lib/format_text/format-text.c         |   81 +++++++++-------
 lib/metadata/metadata-exported.h      |   14 ++--
 lib/metadata/metadata.c               |  175 +++++++++++++++++++++++++--------
 lib/metadata/metadata.h               |    7 +-
 lib/metadata/pv.h                     |    4 +-
 man/pvcreate.8_des                    |   87 ++++++++++++++---
 man/vgcreate.8_des                    |    6 +
 test/shell/pe-align.sh                |  144 +++++++++++++++++++++++++++
 test/shell/pvcreate-bootloaderarea.sh |    8 +-
 test/shell/pvcreate-usage.sh          |   42 +++++---
 test/shell/topology-support.sh        |    3 +-
 tools/args.h                          |   31 +++---
 tools/toollib.c                       |    5 +-
 19 files changed, 526 insertions(+), 179 deletions(-)

diff --git a/configure.ac b/configure.ac
index ffec809..3578f7b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1599,15 +1599,6 @@ AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
 		   [Name of default locking directory.])
 
 ################################################################################
-dnl -- Setup default data alignment
-AC_ARG_WITH(default-data-alignment,
-	    AC_HELP_STRING([--with-default-data-alignment=NUM],
-			   [set the default data alignment in MiB [1]]),
-	    DEFAULT_DATA_ALIGNMENT=$withval, DEFAULT_DATA_ALIGNMENT=1)
-AC_DEFINE_UNQUOTED(DEFAULT_DATA_ALIGNMENT, [$DEFAULT_DATA_ALIGNMENT],
-		   [Default data alignment.])
-
-################################################################################
 dnl -- which kernel interface to use (ioctl only)
 AC_MSG_CHECKING(for kernel interface choice)
 AC_ARG_WITH(interface,
@@ -1667,7 +1658,6 @@ AC_SUBST(DEBUG)
 AC_SUBST(DEFAULT_ARCHIVE_SUBDIR)
 AC_SUBST(DEFAULT_BACKUP_SUBDIR)
 AC_SUBST(DEFAULT_CACHE_SUBDIR)
-AC_SUBST(DEFAULT_DATA_ALIGNMENT)
 AC_SUBST(DEFAULT_DM_RUN_DIR)
 AC_SUBST(DEFAULT_LOCK_DIR)
 AC_SUBST(DEFAULT_MIRROR_SEGTYPE)
diff --git a/include/configure.h.in b/include/configure.h.in
index 19c1922..c66b37b 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -45,9 +45,6 @@
 /* Name of default metadata cache subdirectory. */
 #undef DEFAULT_CACHE_SUBDIR
 
-/* Default data alignment. */
-#undef DEFAULT_DATA_ALIGNMENT
-
 /* Define default node creation behavior with dmsetup create */
 #undef DEFAULT_DM_ADD_NODE
 
diff --git a/lib/config/config.c b/lib/config/config.c
index 2e7e9b6..b3e230d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -24,6 +24,7 @@
 #include "lib/misc/lvm-file.h"
 #include "lib/mm/memlock.h"
 #include "lib/label/label.h"
+#include "lib/metadata/metadata.h"
 
 #include <sys/stat.h>
 #include <sys/mman.h>
@@ -2333,6 +2334,11 @@ int load_pending_profiles(struct cmd_context *cmd)
 	return r;
 }
 
+int get_default_metadata_pvmetadatasize_CFG(struct cmd_context *cmd, struct profile *profile)
+{
+	return get_default_pvmetadatasize_sectors();
+}
+
 const char *get_default_devices_cache_dir_CFG(struct cmd_context *cmd, struct profile *profile)
 {
 	static char buf[PATH_MAX];
diff --git a/lib/config/config.h b/lib/config/config.h
index 4c8ddac..c62ea20 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -311,5 +311,7 @@ int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, st
 const char *get_default_allocation_cache_policy_CFG(struct cmd_context *cmd, struct profile *profile);
 #define get_default_unconfigured_allocation_cache_policy_CFG NULL
 uint64_t get_default_allocation_cache_pool_max_chunks_CFG(struct cmd_context *cmd, struct profile *profile);
+int get_default_metadata_pvmetadatasize_CFG(struct cmd_context *cmd, struct profile *profile);
+#define get_default_unconfigured_metadata_pvmetadatasize_CFG NULL
 
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f4f626f..1621608 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -352,16 +352,21 @@ cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devi
 	"detection to execute.\n")
 
 cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_CHUNK_ALIGNMENT, vsn(2, 2, 48), NULL, 0, NULL,
-	"Align PV data blocks with md device's stripe-width.\n"
-	"This applies if a PV is placed directly on an md device.\n")
-
-cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_DATA_ALIGNMENT, vsn(2, 2, 75), NULL, 0, NULL,
-	"Default alignment of the start of a PV data area in MB.\n"
-	"If set to 0, a value of 64KiB will be used.\n"
-	"Set to 1 for 1MiB, 2 for 2MiB, etc.\n")
+	"Align the start of a PV data area with md device's stripe-width.\n"
+	"This applies if a PV is placed directly on an md device.\n"
+	"default_data_alignment will be overriden if it is not aligned\n"
+	"with the value detected for this setting.\n"
+	"This setting is overriden by data_alignment_detection,\n"
+	"data_alignment, and the --dataalignment option.\n")
+
+cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, FIRST_PE_AT_ONE_MB_IN_MB, vsn(2, 2, 75), NULL, 0, NULL,
+	"Align the start of a PV data area with this number of MiB.\n"
+	"Set to 1 for 1MiB, 2 for 2MiB, etc. Set to 0 to disable.\n"
+	"This setting is overriden by data_alignment and the --dataalignment\n"
+	"option.\n")
 
 cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51), NULL, 0, NULL,
-	"Detect PV data alignment based on sysfs device information.\n"
+	"Align the start of a PV data area with sysfs io properties.\n"
 	"The start of a PV data area will be a multiple of minimum_io_size or\n"
 	"optimal_io_size exposed in sysfs. minimum_io_size is the smallest\n"
 	"request the device can perform without incurring a read-modify-write\n"
@@ -369,25 +374,27 @@ cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CF
 	"preferred unit of receiving I/O, e.g. MD stripe width.\n"
 	"minimum_io_size is used if optimal_io_size is undefined (0).\n"
 	"If md_chunk_alignment is enabled, that detects the optimal_io_size.\n"
-	"This setting takes precedence over md_chunk_alignment.\n")
+	"default_data_alignment and md_chunk_alignment will be overriden\n"
+	"if they are not aligned with the value detected for this setting.\n"
+	"This setting is overriden by data_alignment and the --dataalignment\n"
+	"option.\n")
 
 cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 45), NULL, 0, NULL,
-	"Alignment of the start of a PV data area in KiB.\n"
-	"If a PV is placed directly on an md device and md_chunk_alignment or\n"
-	"data_alignment_detection are enabled, then this setting is ignored.\n"
-	"Otherwise, md_chunk_alignment and data_alignment_detection are\n"
-	"disabled if this is set. Set to 0 to use the default alignment or the\n"
-	"page size, if larger.\n")
+	"Align the start of a PV data area with this number of KiB.\n"
+	"When non-zero, this setting overrides default_data_alignment.\n"
+	"Set to 0 to disable, in which case default_data_alignment\n"
+	"is used to align the first PE in units of MiB.\n"
+	"This setting is overriden by the --dataalignment option.\n")
 
 cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION, vsn(2, 2, 50), NULL, 0, NULL,
-	"Detect PV data alignment offset based on sysfs device information.\n"
-	"The start of a PV aligned data area will be shifted by the\n"
+	"Shift the start of an aligned PV data area based on sysfs information.\n"
+	"After a PV data area is aligned, it will be shifted by the\n"
 	"alignment_offset exposed in sysfs. This offset is often 0, but may\n"
 	"be non-zero. Certain 4KiB sector drives that compensate for windows\n"
 	"partitioning will have an alignment_offset of 3584 bytes (sector 7\n"
 	"is the lowest aligned logical block, the 4KiB sectors start at\n"
 	"LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).\n"
-	"pvcreate --dataalignmentoffset will skip this detection.\n")
+	"This setting is overriden by the --dataalignmentoffset option.\n")
 
 cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19), NULL, 0, NULL,
 	"Ignore DM devices that have I/O suspended while scanning devices.\n"
@@ -1606,12 +1613,19 @@ cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG
 	"and allows you to control which metadata areas are used at the\n"
 	"individual PV level using pvchange --metadataignore y|n.\n")
 
-cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0), NULL, 0, NULL,
-	"Approximate number of sectors to use for each metadata copy.\n"
-	"VGs with large numbers of PVs or LVs, or VGs containing complex LV\n"
-	"structures, may need additional space for VG metadata. The metadata\n"
-	"areas are treated as circular buffers, so unused space becomes filled\n"
-	"with an archive of the most recent previous versions of the metadata.\n")
+cfg_runtime(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(1, 0, 0), 0, NULL,
+	"The default size of the metadata area in units of 512 byte sectors.\n"
+	"The metadata area begins at an offset of the page size from the start\n"
+	"of the device. The first PE is by default at 1 MiB from the start of\n"
+	"the device. The space between these is the default metadata area size.\n"
+	"The actual size of the metadata area may be larger than what is set\n"
+	"here due to default_data_alignment making the first PE a MiB multiple.\n"
+	"The metadata area begins with a 512 byte header and is followed by a\n"
+	"circular buffer used for VG metadata text. The maximum size of the VG\n"
+	"metadata is about half the size of the metadata buffer. VGs with large\n"
+	"numbers of PVs or LVs, or VGs containing complex LV structures, may need\n"
+	"additional space for VG metadata. The --metadatasize option overrides\n"
+	"this setting.\n")
 
 cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69), NULL, 0, NULL,
 	"Ignore metadata areas on a new PV.\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index f3fcb09..fc12626 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -18,8 +18,18 @@
 
 #include "device_mapper/vdo/vdo_limits.h"
 
-#define DEFAULT_PE_ALIGN 2048
-#define DEFAULT_PE_ALIGN_OLD 128
+
+/*
+ * By default the first PE is placed at 1 MiB.
+ *
+ * If default_data_alignment is 2, then the first PE
+ * is placed at 2 * 1 MiB.
+ *
+ * If default_data_alignment is 3, then the first PE
+ * is placed at 3 * 1 MiB.
+ */
+#define FIRST_PE_AT_ONE_MB_IN_SECTORS 2048  /* 1 MiB in 512 byte sectors */
+#define FIRST_PE_AT_ONE_MB_IN_MB         1
 
 #define DEFAULT_ARCHIVE_ENABLED 1
 #define DEFAULT_BACKUP_ENABLED 1
@@ -180,7 +190,6 @@
 #define DEFAULT_RECORD_LVS_HISTORY 0
 #define DEFAULT_LVS_HISTORY_RETENTION_TIME 0
 #define DEFAULT_PVMETADATAIGNORE 0
-#define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_VGMETADATACOPIES 0
 #define DEFAULT_LABELSECTOR UINT64_C(1)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 7fba881..92a1495 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1791,45 +1791,47 @@ static int _text_pv_initialise(const struct format_type *fmt,
 			       struct pv_create_args *pva,
 			       struct physical_volume *pv)
 {
-	unsigned long data_alignment = pva->data_alignment;
-	unsigned long data_alignment_offset = pva->data_alignment_offset;
-	unsigned long adjustment, final_alignment = 0;
-
-	if (!data_alignment)
-		data_alignment = find_config_tree_int(pv->fmt->cmd, devices_data_alignment_CFG, NULL) * 2;
-
-	if (set_pe_align(pv, data_alignment) != data_alignment &&
-	    data_alignment) {
-		log_error("%s: invalid data alignment of "
-			  "%lu sectors (requested %lu sectors)",
-			  pv_dev_name(pv), pv->pe_align, data_alignment);
-		return 0;
-	}
+	uint64_t data_alignment_sectors = pva->data_alignment;
+	uint64_t data_alignment_offset_sectors = pva->data_alignment_offset;
+	uint64_t adjustment;
+	uint64_t final_alignment_sectors = 0;
 
-	if (set_pe_align_offset(pv, data_alignment_offset) != data_alignment_offset &&
-	    data_alignment_offset) {
-		log_error("%s: invalid data alignment offset of "
-			  "%lu sectors (requested %lu sectors)",
-			  pv_dev_name(pv), pv->pe_align_offset, data_alignment_offset);
-		return 0;
+	log_debug("PV init requested data_alignment_sectors %llu data_alignment_offset_sectors %llu",
+		  (unsigned long long)data_alignment_sectors, (unsigned long long)data_alignment_offset_sectors);
+
+	if (!data_alignment_sectors) {
+		data_alignment_sectors = find_config_tree_int(pv->fmt->cmd, devices_data_alignment_CFG, NULL) * 2;
+		if (data_alignment_sectors)
+			log_debug("PV init config data_alignment_sectors %llu",
+				  (unsigned long long)data_alignment_sectors);
 	}
 
+	/* sets pv->pe_align */
+	set_pe_align(pv, data_alignment_sectors);
+
+	/* sets pv->pe_align_offset */
+	set_pe_align_offset(pv, data_alignment_offset_sectors);
+
 	if (pv->pe_align < pv->pe_align_offset) {
-		log_error("%s: pe_align (%lu sectors) must not be less "
-			  "than pe_align_offset (%lu sectors)",
-			  pv_dev_name(pv), pv->pe_align, pv->pe_align_offset);
+		log_error("%s: pe_align (%llu sectors) must not be less than pe_align_offset (%llu sectors)",
+			  pv_dev_name(pv), (unsigned long long)pv->pe_align, (unsigned long long)pv->pe_align_offset);
 		return 0;
 	}
 
-	final_alignment = pv->pe_align + pv->pe_align_offset;
+	final_alignment_sectors = pv->pe_align + pv->pe_align_offset;
 
-	if (pv->size < final_alignment) {
+	log_debug("PV init final alignment %llu sectors from align %llu align_offset %llu",
+		  (unsigned long long)final_alignment_sectors,
+		  (unsigned long long)pv->pe_align,
+		  (unsigned long long)pv->pe_align_offset);
+
+	if (pv->size < final_alignment_sectors) {
 		log_error("%s: Data alignment must not exceed device size.",
 			  pv_dev_name(pv));
 		return 0;
 	}
 
-	if (pv->size < final_alignment + pva->ba_size) {
+	if (pv->size < final_alignment_sectors + pva->ba_size) {
 		log_error("%s: Bootloader area with data-aligned start must "
 			  "not exceed device size.", pv_dev_name(pv));
 		return 0;
@@ -1846,15 +1848,23 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		 * But we still want to support a PV with BA only!
 		 */
 		if (pva->ba_size) {
-			pv->ba_start = final_alignment;
+			pv->ba_start = final_alignment_sectors;
 			pv->ba_size = pva->ba_size;
 			if ((adjustment = pva->ba_size % pv->pe_align))
 				pv->ba_size += pv->pe_align - adjustment;
 			if (pv->size < pv->ba_start + pv->ba_size)
 				pv->ba_size = pv->size - pv->ba_start;
 			pv->pe_start = pv->ba_start + pv->ba_size;
-		} else
-			pv->pe_start = final_alignment;
+			log_debug("Setting pe start to %llu sectors after ba start %llu size %llu for %s",
+				  (unsigned long long)pv->pe_start,
+				  (unsigned long long)pv->ba_start,
+				  (unsigned long long)pv->ba_size,
+				  pv_dev_name(pv));
+		} else {
+			pv->pe_start = final_alignment_sectors;
+			log_debug("Setting PE start to %llu sectors for %s",
+				  (unsigned long long)pv->pe_start, pv_dev_name(pv));
+		}
 	} else {
 		/*
 		 * Try to keep the value of PE start set to a firm value if
@@ -1864,16 +1874,19 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		 * if possible.
 		 */
 		pv->pe_start = pva->pe_start;
+
+		log_debug("Setting pe start to requested %llu sectors for %s",
+			  (unsigned long long)pv->pe_start, pv_dev_name(pv));
+
 		if (pva->ba_size) {
 			if ((pva->ba_start && pva->ba_start + pva->ba_size > pva->pe_start) ||
-			    (pva->pe_start <= final_alignment) ||
-			    (pva->pe_start - final_alignment < pva->ba_size)) {
-				log_error("%s: Bootloader area would overlap "
-					  "data area.", pv_dev_name(pv));
+			    (pva->pe_start <= final_alignment_sectors) ||
+			    (pva->pe_start - final_alignment_sectors < pva->ba_size)) {
+				log_error("%s: Bootloader area would overlap data area.", pv_dev_name(pv));
 				return 0;
 			}
 
-			pv->ba_start = pva->ba_start ? : final_alignment;
+			pv->ba_start = pva->ba_start ? : final_alignment_sectors;
 			pv->ba_size = pva->ba_size;
 		}
 	}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7f673cd..763b91b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -566,20 +566,20 @@ struct vgnameid_list {
  * Values used by pv_create().
  */
 struct pv_create_args {
-	uint64_t size;
-	uint64_t data_alignment;
-	uint64_t data_alignment_offset;
+	uint64_t size; /* in sectors */
+	uint64_t data_alignment; /* in sectors */
+	uint64_t data_alignment_offset; /* in sectors */
 	uint64_t label_sector;
 	int pvmetadatacopies;
-	uint64_t pvmetadatasize;
+	uint64_t pvmetadatasize; /* in sectors */
 	unsigned metadataignore;
 
 	/* used when restoring */
 	struct id id;
 	struct id *idp;
-	uint64_t ba_start;
-	uint64_t ba_size;
-	uint64_t pe_start;
+	uint64_t ba_start; /* in sectors */
+	uint64_t ba_size; /* in sectors */
+	uint64_t pe_start; /* in sectors */
 	uint32_t extent_count;
 	uint32_t extent_size;
 };
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6c71c74..6a0be85 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -41,36 +41,105 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct volume_group *vg,
 					struct lvmcache_info *info);
 
-static int _alignment_overrides_default(unsigned long data_alignment,
-					unsigned long default_pe_align)
+/*
+ * Historically, DEFAULT_PVMETADATASIZE was 255 for many years,
+ * but that value was only used if default_data_alignment was
+ * disabled.  Using DEFAULT_PVMETADATASIZE 255, pe_start was
+ * rounded up to 192KB from aligning it with 64K
+ * (DEFAULT_PE_ALIGN_OLD 128 sectors).  Given a 4KB mda_start,
+ * and 192KB pe_start, the mda_size between the two was 188KB.
+ * This metadata area size was too small to be a good default,
+ * and disabling default_data_alignment, with no other change,
+ * does not imply that the default mda_size or pe_start should
+ * change.
+ */
+
+int get_default_pvmetadatasize_sectors(void)
 {
-	return data_alignment && (default_pe_align % data_alignment);
+	int pagesize = lvm_getpagesize();
+
+	/*
+	 * This returns the default size of the metadata area in units of
+	 * 512 byte sectors.
+	 *
+	 * We want the default pe_start to consistently be 1 MiB (1024 KiB),
+	 * (even if default_data_alignment is disabled.)
+	 *
+	 * The mda start is at pagesize offset from the start of the device.
+	 *
+	 * The metadata size is the space between mda start and pe_start.
+	 *
+	 * So, if set set default metadata size to 1024 KiB - <pagesize> KiB,
+	 * it will consistently produce pe_start of 1 MiB.
+	 *
+	 * pe_start 1024 KiB = 2048 sectors.
+	 *
+	 * pagesizes:
+	 * 4096 = 8 sectors.
+	 * 8192 = 16 sectors.
+	 * 65536 = 128 sectors.
+	 */
+
+	switch (pagesize) {
+	case 4096:
+		return 2040;
+	case 8192:
+		return 2032;
+	case 65536:
+		return 1920;
+	}
+
+	log_warn("Using metadata size 960 KiB for non-standard page size %d.", pagesize);
+	return 1920;
 }
 
-unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
+#define ONE_MB_IN_SECTORS 2048  /* 2048 * 512 = 1048576 */
+
+void set_pe_align(struct physical_volume *pv, uint64_t data_alignment_sectors)
 {
-	unsigned long default_pe_align, temp_pe_align;
+	uint64_t default_data_alignment_mb;
+	uint64_t pe_align_sectors;
+	uint64_t temp_pe_align_sectors;
+	uint32_t page_size_sectors;
 
 	if (pv->pe_align)
 		goto out;
 
-	if (data_alignment) {
-		/* Always use specified data_alignment */
-		pv->pe_align = data_alignment;
+	if (data_alignment_sectors) {
+		/* Always use specified alignment */
+		log_debug("Requested PE alignment is %llu sectors", (unsigned long long)data_alignment_sectors);
+		pe_align_sectors = data_alignment_sectors;
+		pv->pe_align = data_alignment_sectors;
 		goto out;
 	}
 
-	default_pe_align = find_config_tree_int(pv->fmt->cmd, devices_default_data_alignment_CFG, NULL);
+	/*
+	 * By default the first PE is placed at 1 MiB.
+	 *
+	 * If default_data_alignment is 2, then the first PE
+	 * is placed at 2 * 1 MiB.
+	 *
+	 * If default_data_alignment is 3, then the first PE
+	 * is placed at 3 * 1 MiB.
+	 */
+
+	default_data_alignment_mb = find_config_tree_int(pv->fmt->cmd, devices_default_data_alignment_CFG, NULL);
 
-	if (default_pe_align)
-		/* align on 1 MiB multiple */
-		default_pe_align *= DEFAULT_PE_ALIGN;
+	if (default_data_alignment_mb)
+		pe_align_sectors = default_data_alignment_mb * FIRST_PE_AT_ONE_MB_IN_SECTORS;
 	else
-		/* align on 64 KiB multiple (old default) */
-		default_pe_align = DEFAULT_PE_ALIGN_OLD;
+		pe_align_sectors = FIRST_PE_AT_ONE_MB_IN_SECTORS;
 
-	pv->pe_align = MAX((default_pe_align << SECTOR_SHIFT),
-			   lvm_getpagesize()) >> SECTOR_SHIFT;
+	pv->pe_align = pe_align_sectors;
+	log_debug("Standard PE alignment is %llu sectors", (unsigned long long)pe_align_sectors);
+
+	page_size_sectors = lvm_getpagesize() >> SECTOR_SHIFT;
+	if (page_size_sectors > pe_align_sectors) {
+		/* This shouldn't happen */
+		log_debug("Increasing PE alignment to page size %u sectors", page_size_sectors);
+		pe_align_sectors = page_size_sectors;
+		pv->pe_align = page_size_sectors;
+	}
 
 	if (!pv->dev)
 		goto out;
@@ -79,9 +148,16 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	 * Align to stripe-width of underlying md device if present
 	 */
 	if (find_config_tree_bool(pv->fmt->cmd, devices_md_chunk_alignment_CFG, NULL)) {
-		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->dev_types, pv->dev);
-		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
-			pv->pe_align = temp_pe_align;
+		temp_pe_align_sectors = dev_md_stripe_width(pv->fmt->cmd->dev_types, pv->dev);
+
+		if (temp_pe_align_sectors && (pe_align_sectors % temp_pe_align_sectors)) {
+			log_debug("Adjusting PE alignment from %llu sectors to md stripe width %llu sectors for %s",
+				  (unsigned long long)pe_align_sectors,
+				  (unsigned long long)temp_pe_align_sectors,
+				  dev_name(pv->dev));
+			pe_align_sectors = temp_pe_align_sectors;
+			pv->pe_align = temp_pe_align_sectors;
+		}
 	}
 
 	/*
@@ -92,31 +168,42 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	 *   (e.g. MD's stripe width)
 	 */
 	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_detection_CFG, NULL)) {
-		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->dev_types, pv->dev);
-		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
-			pv->pe_align = temp_pe_align;
+		temp_pe_align_sectors = dev_minimum_io_size(pv->fmt->cmd->dev_types, pv->dev);
 
-		temp_pe_align = dev_optimal_io_size(pv->fmt->cmd->dev_types, pv->dev);
-		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
-			pv->pe_align = temp_pe_align;
+		if (temp_pe_align_sectors && (pe_align_sectors % temp_pe_align_sectors)) {
+			log_debug("Adjusting PE alignment from %llu sectors to mininum io size %llu sectors for %s",
+				  (unsigned long long)pe_align_sectors,
+				  (unsigned long long)temp_pe_align_sectors,
+				  dev_name(pv->dev));
+			pe_align_sectors = temp_pe_align_sectors;
+			pv->pe_align = temp_pe_align_sectors;
+		}
+
+		temp_pe_align_sectors = dev_optimal_io_size(pv->fmt->cmd->dev_types, pv->dev);
+
+		if (temp_pe_align_sectors && (pe_align_sectors % temp_pe_align_sectors)) {
+			log_debug("Adjusting PE alignment from %llu sectors to optimal io size %llu sectors for %s",
+				  (unsigned long long)pe_align_sectors,
+				  (unsigned long long)temp_pe_align_sectors,
+				  dev_name(pv->dev));
+			pe_align_sectors = temp_pe_align_sectors;
+			pv->pe_align = temp_pe_align_sectors;
+		}
 	}
 
 out:
-	log_very_verbose("%s: Setting PE alignment to %lu sectors.",
-			 dev_name(pv->dev), pv->pe_align);
-
-	return pv->pe_align;
+	log_debug("Setting PE alignment to %llu sectors for %s.",
+		  (unsigned long long)pv->pe_align, dev_name(pv->dev));
 }
 
-unsigned long set_pe_align_offset(struct physical_volume *pv,
-				  unsigned long data_alignment_offset)
+void set_pe_align_offset(struct physical_volume *pv, uint64_t data_alignment_offset_sectors)
 {
 	if (pv->pe_align_offset)
 		goto out;
 
-	if (data_alignment_offset) {
+	if (data_alignment_offset_sectors) {
 		/* Always use specified data_alignment_offset */
-		pv->pe_align_offset = data_alignment_offset;
+		pv->pe_align_offset = data_alignment_offset_sectors;
 		goto out;
 	}
 
@@ -128,14 +215,12 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 		/* must handle a -1 alignment_offset; means dev is misaligned */
 		if (align_offset < 0)
 			align_offset = 0;
-		pv->pe_align_offset = MAX(pv->pe_align_offset, align_offset);
+		pv->pe_align_offset = align_offset;
 	}
 
 out:
-	log_very_verbose("%s: Setting PE alignment offset to %lu sectors.",
-			 dev_name(pv->dev), pv->pe_align_offset);
-
-	return pv->pe_align_offset;
+	log_debug("Setting PE alignment offset to %llu sectors for %s.",
+		  (unsigned long long)pv->pe_align_offset, dev_name(pv->dev));
 }
 
 void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
@@ -1355,10 +1440,10 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 	pp->uuid_str = NULL;
 
 	pp->pva.size = 0;
-	pp->pva.data_alignment = UINT64_C(0);
-	pp->pva.data_alignment_offset = UINT64_C(0);
+	pp->pva.data_alignment = 0;
+	pp->pva.data_alignment_offset = 0;
 	pp->pva.pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
-	pp->pva.pvmetadatasize = DEFAULT_PVMETADATASIZE;
+	pp->pva.pvmetadatasize = get_default_pvmetadatasize_sectors();
 	pp->pva.label_sector = DEFAULT_LABELSECTOR;
 	pp->pva.metadataignore = DEFAULT_PVMETADATAIGNORE;
 	pp->pva.ba_start = 0;
@@ -1413,8 +1498,8 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 	unsigned mda_index;
 	struct pv_list *pvl;
 	uint64_t size = pva->size;
-	unsigned long data_alignment = pva->data_alignment;
-	unsigned long data_alignment_offset = pva->data_alignment_offset;
+	uint64_t data_alignment = pva->data_alignment;
+	uint64_t data_alignment_offset = pva->data_alignment_offset;
 	unsigned pvmetadatacopies = pva->pvmetadatacopies;
 	uint64_t pvmetadatasize = pva->pvmetadatasize;
 	unsigned metadataignore = pva->metadataignore;
@@ -1469,6 +1554,10 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
 
+	/*
+	 * Sets pv: pe_align, pe_align_offset, pe_start, pe_size
+	 * Does not write to device.
+	 */
 	if (!fmt->ops->pv_initialise(fmt, pva, pv)) {
 		log_error("Format-specific initialisation of physical "
 			  "volume %s failed.", pv_dev_name(pv));
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 164fba2..f578325 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -358,9 +358,10 @@ struct format_handler {
 /*
  * Utility functions
  */
-unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment);
-unsigned long set_pe_align_offset(struct physical_volume *pv,
-				  unsigned long data_alignment_offset);
+
+int get_default_pvmetadatasize_sectors(void);
+void set_pe_align(struct physical_volume *pv, uint64_t data_alignment);
+void set_pe_align_offset(struct physical_volume *pv, uint64_t data_alignment_offset);
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
 
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 61aa54e..c162acd 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -54,8 +54,8 @@ struct physical_volume {
 	uint64_t pe_start;
 	uint32_t pe_count;
 	uint32_t pe_alloc_count;
-	unsigned long pe_align;
-	unsigned long pe_align_offset;
+	uint64_t pe_align;
+	uint64_t pe_align_offset;
 
         /* This is true whenever the represented PV has a label associated. */
         uint64_t is_labelled:1;
diff --git a/man/pvcreate.8_des b/man/pvcreate.8_des
index 1b00e9e..60205c7 100644
--- a/man/pvcreate.8_des
+++ b/man/pvcreate.8_des
@@ -1,21 +1,78 @@
-pvcreate initializes a PV so that it is recognized as belonging to LVM,
-and allows the PV to be used in a VG. A PV can be a disk partition, whole
-disk, meta device, or loopback file.
-
-For DOS disk partitions, the partition id should be set to 0x8e using
-.BR fdisk (8),
-.BR cfdisk (8),
-or a equivalent. For GUID Partition Table (GPT), the id is
-E6D6D379-F507-44C2-A23C-238F2A3DF928. For
-whole disk devices only
-the partition table must be erased, which will effectively destroy all
-data on that disk. This can be done by zeroing the first sector with:
-
-.BI "dd if=/dev/zero of=" PhysicalVolume " bs=512 count=1"
+pvcreate initializes a Physical Volume (PV) on a device so the device is
+recognized as belonging to LVM.  This allows the PV to be used in a Volume
+Group (VG).  An LVM disk label is written to the device, and LVM metadata
+areas are initialized.  A PV can be placed on a whole device or partition.
 
 Use \fBvgcreate\fP(8) to create a new VG on the PV, or \fBvgextend\fP(8)
-to add the PV to existing VG.
+to add the PV to an existing VG.  Use \fBpvremove\fP(8) to remove the LVM
+disk label from the device.
 
 The force option will create a PV without confirmation.  Repeating the
 force option (\fB-ff\fP) will forcibly create a PV, overriding checks that
 normally prevent it, e.g. if the PV is already in a VG.
+
+.B Metadata location, size, and alignment
+
+The LVM disk label begins 512 bytes from the start of the device, and is
+512 bytes in size.
+
+The LVM metadata area begins at an offset (from the start of the device)
+equal to the page size of the machine creating the PV (often 4 KiB.) The
+metadata area contains a 512 byte header and a multi-KiB circular buffer
+that holds text copies of the VG metadata.
+
+With default settings, the first physical extent (PE), which contains LV
+data, is 1 MiB from the start of the device.  This location is controlled
+by \fBdefault_data_alignment\fP in lvm.conf, which is set to 1 (MiB) by
+default.  The pe_start will be a multiple of this many MiB.  This location
+can be checked with:
+.br
+.B pvs -o pe_start
+.I PV
+
+The size of the LVM metadata area is the space between the the start of
+the metadata area and the first PE.  When metadata begins at 4 KiB and the
+first PE is at 1024 KiB, the metadata area size is 1020 KiB.  This can be
+checked with:
+.br
+.B pvs -o mda_size
+.I PV
+
+The mda_size cannot be increased after pvcreate, so if larger metadata is
+needed, it must be set during pvcreate.  Two copies of the VG metadata
+must always fit within the metadata area, so the maximum VG metadata size
+is around half the mda_size.  This can be checked with:
+.br
+.B vgs -o mda_free
+.I VG
+
+A larger metadata area can be set with --metadatasize.  The resulting
+mda_size may be larger than specified due to default_data_alignment
+placing pe_start on a MiB boundary, and the fact that the metadata area
+extends to the first PE.  With metadata starting at 4 KiB and
+default_data_alignment 1 (MiB), setting --metadatasize 2048k results in
+pe_start of 3 MiB and mda_size of 3068 KiB.  Alternatively, --metadatasize
+2044k results in pe_start at 2 MiB and mda_size of 2044 KiB.
+
+The alignment of pe_start described above may be automatically overriden
+based on md device properties or device i/o properties reported in sysfs.
+These automatic adjustments can be enabled/disabled using lvm.conf
+settings md_chunk_alignment and data_alignment_offset_detection.
+
+To use a different pe_start alignment, use the --dataalignment option.
+The --metadatasize option would also typically be used in this case
+because the metadata area size also determines the location of pe_start.
+When using these two options together, pe_start is calculated as:
+metadata area start (page size), plus the specified --metadatasize,
+rounded up to the next multiple of --dataalignment.
+With metadata starting at 4 KiB, --metadatasize 2048k, and --dataalignment 128k,
+pe_start is 2176 KiB and mda_size is 2172 KiB.
+The pe_start of 2176 KiB is the nearest even multiple of 128 KiB that
+provides at least 2048 KiB of metadata space.
+Always check the resulting alignment and metadata size when using
+these options.
+
+To shift an aligned pe_start value, use the --dataaligmentoffset option.
+The pe_start alignment is calculated as described above, and then the
+value specified with --dataaligmentoffset is added to produce the final
+pe_start value.
diff --git a/man/vgcreate.8_des b/man/vgcreate.8_des
index a2d7161..bc63660 100644
--- a/man/vgcreate.8_des
+++ b/man/vgcreate.8_des
@@ -2,3 +2,9 @@ vgcreate creates a new VG on block devices. If the devices were not
 previously intialized as PVs with \fBpvcreate\fP(8), vgcreate will
 inititialize them, making them PVs. The pvcreate options for initializing
 devices are also available with vgcreate.
+
+When vgcreate uses an existing PV, that PV's existing values for metadata
+size, PE start, etc, are used, even if different values are specified in
+the vgcreate command.  To change these values, first use pvremove on the
+device.
+
diff --git a/test/shell/pe-align.sh b/test/shell/pe-align.sh
new file mode 100644
index 0000000..c547188
--- /dev/null
+++ b/test/shell/pe-align.sh
@@ -0,0 +1,144 @@
+
+#!/usr/bin/env bash
+
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='Test pe alignment and metadata sizes'
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 1
+
+# values depend on page size 4K
+
+# In order of strength:
+# --dataalignmentoffset                    (modifies all below)
+# --dataalignment                          (overrides all below)
+# devices/data_alignment                   (overrides all below)
+# devices/data_alignment_offset_detection  (overrides all below)
+# devices/md_chunk_alignment               (overrides all below)
+# devices/default_data_alignment
+
+pvcreate "$dev1"
+check pv_field "$dev1" pe_start 1.00m
+check pv_field "$dev1" mda_size 1020.00k
+pvremove "$dev1"
+
+# default align at 1m is effective even with smaller requested metadata
+pvcreate --metadatasize 100k "$dev1"
+check pv_field "$dev1" pe_start 1.00m
+check pv_field "$dev1" mda_size 1020.00k
+pvremove "$dev1"
+
+# default first pe doesn't depend on on these two settings
+pvcreate --config 'devices {default_data_alignment=0 data_alignment=0}' "$dev1"
+check pv_field "$dev1" pe_start 1.00m
+check pv_field "$dev1" mda_size 1020.00k
+pvremove "$dev1"
+
+# same as previous
+pvcreate --config 'devices {default_data_alignment=1 data_alignment=0}' "$dev1"
+check pv_field "$dev1" pe_start 1.00m
+check pv_field "$dev1" mda_size 1020.00k
+pvremove "$dev1"
+
+# same as previous
+pvcreate --config 'devices {default_data_alignment=0 data_alignment=1024}' "$dev1"
+check pv_field "$dev1" pe_start 1.00m
+check pv_field "$dev1" mda_size 1020.00k
+pvremove "$dev1"
+
+# same as previous
+pvcreate --config 'devices {default_data_alignment=1 data_alignment=1024}' "$dev1"
+check pv_field "$dev1" pe_start 1.00m
+check pv_field "$dev1" mda_size 1020.00k
+pvremove "$dev1"
+
+# combine above
+pvcreate --metadatasize 100k --config 'devices {default_data_alignment=0 data_alignment=0}' "$dev1"
+check pv_field "$dev1" pe_start 1.00m
+check pv_field "$dev1" mda_size 1020.00k
+pvremove "$dev1"
+
+pvcreate --metadatasize 2048k "$dev1"
+check pv_field "$dev1" pe_start 3072.00k --units k
+check pv_field "$dev1" mda_size 3068.00k --units k
+pvremove "$dev1"
+
+pvcreate --metadatasize 2044k "$dev1"
+check pv_field "$dev1" pe_start 2048.00k --units k
+check pv_field "$dev1" mda_size 2044.00k --units k
+pvremove "$dev1"
+
+pvcreate --metadatasize 2048k --config 'devices {default_data_alignment=2}' "$dev1"
+check pv_field "$dev1" pe_start 4.00m
+check pv_field "$dev1" mda_size 4092.00k --units k
+pvremove "$dev1"
+
+pvcreate --metadatasize 100k --config 'devices {default_data_alignment=2}' "$dev1"
+check pv_field "$dev1" pe_start 2048.00k --units k
+check pv_field "$dev1" mda_size 2044.00k --units k
+pvremove "$dev1"
+
+pvcreate --metadatasize 2048k --dataalignment 128k "$dev1"
+check pv_field "$dev1" pe_start 2176.00k --units k
+check pv_field "$dev1" mda_size 2172.00k --units k
+pvremove "$dev1"
+
+pvcreate --metadatasize 2048k --dataalignment 128k --dataalignmentoffset 2k "$dev1"
+check pv_field "$dev1" pe_start 2178.00k --units k
+check pv_field "$dev1" mda_size 2174.00k --units k
+pvremove "$dev1"
+
+pvcreate --metadatasize 2048k --dataalignment 128k --config 'devices {default_data_alignment=0}' "$dev1"
+check pv_field "$dev1" pe_start 2176.00k --units k
+check pv_field "$dev1" mda_size 2172.00k --units k
+pvremove "$dev1"
+
+pvcreate --metadatasize 2048k --dataalignment 128k --config 'devices {default_data_alignment=2}' "$dev1"
+check pv_field "$dev1" pe_start 2176.00k --units k
+check pv_field "$dev1" mda_size 2172.00k --units k
+pvremove "$dev1"
+
+pvcreate --metadatasize 2048k --config 'devices {default_data_alignment=2 data_alignment=128}' "$dev1"
+check pv_field "$dev1" pe_start 2176.00k --units k
+check pv_field "$dev1" mda_size 2172.00k --units k
+pvremove "$dev1"
+
+pvcreate --bootloaderareasize 256k "$dev1"
+check pv_field "$dev1" mda_size 1020.00k --units k
+check pv_field "$dev1" ba_start 1024.00k --units k
+check pv_field "$dev1" ba_size  1024.00k --units k
+check pv_field "$dev1" pe_start 2048.00k --units k
+pvremove "$dev1"
+
+pvcreate --dataalignment 128k --bootloaderareasize 256k "$dev1"
+check pv_field "$dev1" mda_size 1020.00k --units k
+check pv_field "$dev1" ba_start 1024.00k --units k
+check pv_field "$dev1" ba_size  256.00k --units k
+check pv_field "$dev1" pe_start 1280.00k --units k
+pvremove "$dev1"
+
+pvcreate --dataalignment 128k --metadatasize 256k "$dev1"
+check pv_field "$dev1" mda_size 380.00k --units k
+check pv_field "$dev1" ba_start 0k --units k
+check pv_field "$dev1" ba_size  0k --units k
+check pv_field "$dev1" pe_start 384.00k --units k
+pvremove "$dev1"
+
+pvcreate --dataalignment 128k --metadatasize 256k --bootloaderareasize 256k "$dev1"
+check pv_field "$dev1" mda_size 380.00k --units k
+check pv_field "$dev1" ba_start 384.00k --units k
+check pv_field "$dev1" ba_size  256.00k --units k
+check pv_field "$dev1" pe_start 640.00k --units k
+pvremove "$dev1"
+
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index 2e16a5f..cc31812 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -20,7 +20,7 @@ aux prepare_devs 1
 aux lvmconf 'global/suffix=0' 'global/units="b"'
 
 #COMM 'pvcreate sets/aligns bootloader area correctly'
-pvcreate --dataalignment 262144b --bootloaderareasize 614400b "$dev1"
+pvcreate --metadatasize 255s --dataalignment 262144b --bootloaderareasize 614400b "$dev1"
 # ba_start must be aligned based on dataalignment
 # pe_start starts at next dataalignment multiple
 # ba_size is the whole space in between ba_start and pe_start
@@ -33,7 +33,7 @@ dev_size=$(pvs -o pv_size --noheadings "$dev1")
 pv_size=$(( dev_size - 1048576 )) # device size - 1m pe_start = area for data
 
 # try to use the whole data area for bootloader area, remaining data area is zero then (pe_start = pv_size)
-pvcreate --bootloaderareasize ${pv_size}b --dataalignment 1048576b "$dev1"
+pvcreate --metadatasize 255s --bootloaderareasize ${pv_size}b --dataalignment 1048576b "$dev1"
 check pv_field "$dev1" pe_start $dev_size
 check pv_field "$dev1" ba_start 1048576
 check pv_field "$dev1" ba_size $pv_size
@@ -44,13 +44,13 @@ grep "Bootloader area with data-aligned start must not exceed device size" err
 
 # restoring the PV should also restore the bootloader area correctly
 pvremove -ff "$dev1"
-pvcreate --dataalignment 256k --bootloaderareasize 600k "$dev1"
+pvcreate --metadatasize 255s --dataalignment 256k --bootloaderareasize 600k "$dev1"
 vgcreate $SHARED $vg "$dev1"
 vgcfgbackup -f "$TESTDIR/vg_with_ba_backup" "$vg"
 pv_uuid=$(get pv_field "$dev1" pv_uuid)
 vgremove -ff $vg
 pvremove -ff "$dev1"
-pvcreate --dataalignment 256k --restorefile "$TESTDIR/vg_with_ba_backup" --uuid "$pv_uuid" "$dev1"
+pvcreate --metadatasize 255s --dataalignment 256k --restorefile "$TESTDIR/vg_with_ba_backup" --uuid "$pv_uuid" "$dev1"
 check pv_field "$dev1" ba_start "262144"
 check pv_field "$dev1" ba_size "786432"
 check pv_field "$dev1" pe_start "1048576"
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 0a6f1ea..a61a2c3 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -34,14 +34,6 @@ grep "Metadata area size too small" err
 #COMM 'pvcreate accepts metadatasize that is at least the minimum size'
 pvcreate --dataalignment ${MDA_SIZE_MIN}b --metadatasize ${MDA_SIZE_MIN}b "$dev1"
 
-# x. metadatasize 0, defaults to 255
-# FIXME: unable to check default value, not in reporting cmds
-# should default to 255 according to code
-#   check pv_field pv_mda_size 255 
-#COMM 'pvcreate accepts metadatasize 0'
-pvcreate --metadatasize 0 "$dev1"
-pvremove "$dev1"
-
 #Verify vg_mda_size is smaller pv_mda_size
 pvcreate --metadatasize 512k "$dev1"
 pvcreate --metadatasize 96k "$dev2"
@@ -95,20 +87,17 @@ not pvcreate --labelsector 1000000000000 "$dev1"
 #COMM 'pvcreate basic dataalignment sanity checks'
 not pvcreate --dataalignment -1 "$dev1"
 not pvcreate --dataalignment 1e "$dev1"
-if test -n "$LVM_TEST_LVM1" ; then
-not pvcreate -M1 --dataalignment 1 "$dev1"
-fi
 
 #COMM 'pvcreate always rounded up to page size for start of device'
 #pvcreate --metadatacopies 0 --dataalignment 1 "$dev1"
 # amuse shell experts
 #check pv_field "$dev1" pe_start $(($(getconf PAGESIZE)/1024))".00k"
 
-#COMM 'pvcreate sets data offset directly'
-pvcreate --dataalignment 512k "$dev1"
+#COMM 'pvcreate sets data alignment directly'
+pvcreate --dataalignment 512K --config 'metadata {pvmetadatasize=255}' "$dev1"
 check pv_field "$dev1" pe_start "512.00k"
 
-#COMM 'vgcreate $SHARED/vgremove do not modify data offset of existing PV'
+#COMM 'vgcreate/vgremove do not modify data offset of existing PV'
 vgcreate $SHARED $vg "$dev1"  --config 'devices { data_alignment = 1024 }'
 check pv_field "$dev1" pe_start "512.00k"
 vgremove $vg --config 'devices { data_alignment = 1024 }'
@@ -125,6 +114,31 @@ case "$PAGESIZE" in
  *)	pv_align="133.00k" ;;
 esac
 
+# pe_start is a multiple of dataalignment, leaving enough
+# space between mda_start and pe_end for the specified
+# metadata size.
+#
+# With page size 4k, mda_start is rounded up start at 4k.
+# The chosen multiple of data alignment (3.5k) is 38:
+# 3.5k * 38 = 133k for pe_start
+# Space available for metadata between mda_start and pe_end is:
+# 133k - 4k = 129k mda size, which is large enough for the
+# specified mda size of 128k.
+#
+# With page size 8k, mda_start is rouned up to start at 8k.
+# The chosen multiple of data alignment (3.5k) is 39:
+# 3.5k * 39 = 136.5k for pe_start
+# Space available for metadata between mda_start and pe_end is:
+# 136.5k - 8k = 128.5k mda size, which is large enough for the
+# specified mda size of 128k.
+# 
+# With page size 64k, mda_start is rouned up to start at 64k.
+# The chosen multiple of data alignment (3.5k) is 55:
+# 3.5k * 55 = 192.5k for pe_start
+# Space available for metadata between mda_start and pe_end is:
+# 192.5k - 64k = 128.5k mda size, which is large enough for the
+# specified mda size of 128k.
+
 pvcreate --metadatasize 128k --dataalignment 3.5k "$dev1"
 check pv_field "$dev1" pe_start $pv_align
 
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index f8526ad..ffd637f 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -112,7 +112,8 @@ aux prepare_scsi_debug_dev $DEV_SIZE \
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $LOGICAL_BLOCK_SIZE
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/optimal_io_size 786432
 
-aux prepare_pvs 1 $PER_DEV_SIZE
+aux prepare_devs 1 $PER_DEV_SIZE
+pvcreate --metadatasize 255s "${DEVICES[@]}"
 
 # Kernel (3.19) could provide wrong results - in this case skip
 # test with incorrect result - lvm2 can't figure out good values.
diff --git a/tools/args.h b/tools/args.h
index 414d7a8..522cccf 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -84,14 +84,16 @@ arg(binary_ARG, '\0', "binary", 0, 0, 0,
     "the \"unknown\" value which denotes that the value could not be determined).\n")
 
 arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", sizemb_VAL, 0, 0,
-    "Create a separate bootloader area of specified size besides PV's data\n"
-    "area. The bootloader area is an area of reserved space on the PV from\n"
-    "which LVM will not allocate any extents and it's kept untouched. This is\n"
-    "primarily aimed for use with bootloaders to embed their own data or metadata.\n"
+    "Reserve space for the bootloader between the LVM metadata area and the first PE.\n"
+    "The bootloader area is reserved for bootloaders to embed their own data or\n"
+    "metadata; LVM will not use it.\n"
+    "The bootloader area begins where the first PE would otherwise be located.\n"
+    "The first PE is moved out by the size of the bootloader area, and then moved\n"
+    "out further if necessary to match the data alignment.\n"
     "The start of the bootloader area is always aligned, see also --dataalignment\n"
-    "and --dataalignmentoffset. The bootloader area size may eventually\n"
-    "end up increased due to the alignment, but it's never less than the\n"
-    "size that is requested. To see the bootloader area start and size of\n"
+    "and --dataalignmentoffset. The bootloader area may be larger than requested\n"
+    "due to the alignment, but it's never less than the requested size.\n"
+    "To see the bootloader area start and size of\n"
     "an existing PV use pvs -o +pv_ba_start,pv_ba_size.\n")
 
 arg(cache_long_ARG, '\0', "cache", 0, 0, 0,
@@ -173,14 +175,14 @@ arg(configtype_ARG, '\0', "typeconfig", configtype_VAL, 0, 0,
     "Also see \\fBlvm.conf\\fP(5).\n")
 
 arg(dataalignment_ARG, '\0', "dataalignment", sizekb_VAL, 0, 0,
-    "Align the start of the data to a multiple of this number.\n"
-    "Also specify an appropriate Physical Extent size when creating a VG.\n"
-    "To see the location of the first Physical Extent of an existing PV,\n"
-    "use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.\n"
-    "See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.\n")
+    "Align the start of a PV data area with a multiple of this number.\n"
+    "To see the location of the first Physical Extent (PE) of an existing PV,\n"
+    "use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,\n"
+    "see --dataalignmentoffset.\n"
+    "Also specify an appropriate PE size when creating a VG.\n")
 
 arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", sizekb_VAL, 0, 0,
-    "Shift the start of the data area by this additional offset.\n")
+    "Shift the start of the PV data area by this additional offset.\n")
 
 arg(deduplication_ARG, '\0', "deduplication", bool_VAL, 0, 0,
     "Controls whether deduplication is enabled or disable for VDO volume.\n"
@@ -488,8 +490,7 @@ arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", pvmetadatacopies_VAL, 0, 0,
     "The number of metadata areas to set aside on a PV for storing VG metadata.\n"
     "When 2, one copy of the VG metadata is stored at the front of the PV\n"
     "and a second copy is stored at the end.\n"
-    "When 1, one copy of the VG metadata is stored at the front of the PV\n"
-    "(starting in the 5th sector).\n"
+    "When 1, one copy of the VG metadata is stored@the front of the PV.\n"
     "When 0, no copies of the VG metadata are stored on the given PV.\n"
     "This may be useful in VGs containing many PVs (this places limitations\n"
     "on the ability to use vgsplit later.)\n")
diff --git a/tools/toollib.c b/tools/toollib.c
index 2ab4b62..6c38eb2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4757,8 +4757,11 @@ int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *p
 	}
 
 	pp->pva.pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
-	if (!pp->pva.pvmetadatasize)
+	if (!pp->pva.pvmetadatasize) {
 		pp->pva.pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
+		if (!pp->pva.pvmetadatasize)
+			pp->pva.pvmetadatasize = get_default_pvmetadatasize_sectors();
+	}
 
 	pp->pva.pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
 	if (pp->pva.pvmetadatacopies < 0)


