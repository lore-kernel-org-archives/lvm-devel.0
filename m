From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:30:19 +0000 (UTC)
Subject: master - config: make report settings profilable
Message-ID: <20140317133019.3E7FF610FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=455f23586f0125fb2763c0f2f48e79bc08d9e2c0
Commit:        455f23586f0125fb2763c0f2f48e79bc08d9e2c0
Parent:        f9070c196beb32560a4f966c607b08bb6020b1ab
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 17 14:27:49 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 17 14:27:49 2014 +0100

config: make report settings profilable

Users can create several profiles for how the tools report
the output very easily and then just use

  <lvm reporting command> --profile <report_profile_name>
---
 WHATS_NEW                    |    1 +
 conf/default.profile.in      |   28 ++++++++++++++++++++++
 lib/config/config_settings.h |   52 +++++++++++++++++++++---------------------
 3 files changed, 55 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8a072dc..2d91981 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Make report settings profilable.
   Add existing report settings to lvm.conf.
   Use VG read lock during 'pvscan --cache -aay' autoactivation.
   Issue a VG refresh before autoactivation only if the PV has changed/is new.
diff --git a/conf/default.profile.in b/conf/default.profile.in
index 29049ef..0499aef 100644
--- a/conf/default.profile.in
+++ b/conf/default.profile.in
@@ -19,3 +19,31 @@ activation {
 	thin_pool_autoextend_threshold = 100
 	thin_pool_autoextend_percent = 20
 }
+
+report {
+	aligned=1
+	buffered=1
+	headings=1
+	separator=" "
+	prefixes=0
+	quoted=1
+	colums_as_rows=0
+	devtypes_sort="devtype_name"
+	devtypes_cols="devtype_name,devtype_max_partitions,devtype_description"
+	devtypes_cols_verbose="devtype_name,devtype_max_partitions,devtype_description"
+	lvs_sort="vg_name,lv_name"
+	lvs_cols="lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,move_pv,mirror_log,copy_percent,convert_lv"
+	lvs_cols_verbose="lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile"
+	vgs_sort="vg_name"
+	vgs_cols="vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
+	vgs_cols_verbose="vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"
+	pvs_sort="pv_name"
+	pvs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
+	pvs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
+	segs_sort="vg_name,lv_name,seg_start"
+	segs_cols="lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
+	segs_cols_verbose="lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
+	pvsegs_sort="pv_name,pvseg_start"
+	pvsegs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
+	pvsegs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
+}
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f033660..de6ca1b 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -77,7 +77,7 @@ cfg_section(shell_CFG_SECTION, "shell", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
 cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
 cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), NULL)
 cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, CFG_ADVANCED, vsn(1, 0, 0), NULL)
-cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_ADVANCED, vsn(1, 0, 0), NULL)
+cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_ADVANCED | CFG_PROFILABLE, vsn(1, 0, 0), NULL)
 cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3), NULL)
 cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18), NULL)
 
@@ -224,31 +224,31 @@ cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_AD
 cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL)
 cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 
-cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL)
-cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL)
-cfg(report_headings_CFG, "headings", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL)
-cfg(report_separator_CFG, "separator", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_REP_SEPARATOR, vsn(1, 0, 0), NULL)
-cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_PREFIXES, vsn(2, 2, 36), NULL)
-cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL)
-cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL)
-cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL)
-cfg(report_devtypes_cols_CFG, "devtypes_cols", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS, vsn(2, 2, 101), NULL)
-cfg(report_devtypes_cols_verbose_CFG, "devtypes_cols_verbose", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS_VERB, vsn(2, 2, 101), NULL)
-cfg(report_lvs_sort_CFG, "lvs_sort", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LVS_SORT, vsn(1, 0, 0), NULL)
-cfg(report_lvs_cols_CFG, "lvs_cols", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LVS_COLS, vsn(1, 0, 0), NULL)
-cfg(report_lvs_cols_verbose_CFG, "lvs_cols_verbose", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LVS_COLS_VERB, vsn(1, 0, 0), NULL)
-cfg(report_vgs_sort_CFG, "vgs_sort", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_VGS_SORT, vsn(1, 0, 0), NULL)
-cfg(report_vgs_cols_CFG, "vgs_cols", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_VGS_COLS, vsn(1, 0, 0), NULL)
-cfg(report_vgs_cols_verbose_CFG, "vgs_cols_verbose", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_VGS_COLS_VERB, vsn(1, 0, 0), NULL)
-cfg(report_pvs_sort_CFG, "pvs_sort", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_PVS_SORT, vsn(1, 0, 0), NULL)
-cfg(report_pvs_cols_CFG, "pvs_cols", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_PVS_COLS, vsn(1, 0, 0), NULL)
-cfg(report_pvs_cols_verbose_CFG, "pvs_cols_verbose", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_PVS_COLS_VERB, vsn(1, 0, 0), NULL)
-cfg(report_segs_sort_CFG, "segs_sort", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SEGS_SORT, vsn(1, 0, 0), NULL)
-cfg(report_segs_cols_CFG, "segs_cols", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SEGS_COLS, vsn(1, 0, 0), NULL)
-cfg(report_segs_cols_verbose_CFG, "segs_cols_verbose", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SEGS_COLS_VERB, vsn(1, 0, 0), NULL)
-cfg(report_pvsegs_sort_CFG, "pvsegs_sort", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_PVSEGS_SORT, vsn(1, 1, 3), NULL)
-cfg(report_pvsegs_cols_CFG, "pvsegs_cols", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS, vsn(1, 1, 3), NULL)
-cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS_VERB, vsn(1, 1, 3), NULL)
+cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL)
+cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL)
+cfg(report_headings_CFG, "headings", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL)
+cfg(report_separator_CFG, "separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_REP_SEPARATOR, vsn(1, 0, 0), NULL)
+cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_PREFIXES, vsn(2, 2, 36), NULL)
+cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL)
+cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL)
+cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL)
+cfg(report_devtypes_cols_CFG, "devtypes_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS, vsn(2, 2, 101), NULL)
+cfg(report_devtypes_cols_verbose_CFG, "devtypes_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS_VERB, vsn(2, 2, 101), NULL)
+cfg(report_lvs_sort_CFG, "lvs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_SORT, vsn(1, 0, 0), NULL)
+cfg(report_lvs_cols_CFG, "lvs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_COLS, vsn(1, 0, 0), NULL)
+cfg(report_lvs_cols_verbose_CFG, "lvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_COLS_VERB, vsn(1, 0, 0), NULL)
+cfg(report_vgs_sort_CFG, "vgs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_SORT, vsn(1, 0, 0), NULL)
+cfg(report_vgs_cols_CFG, "vgs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_COLS, vsn(1, 0, 0), NULL)
+cfg(report_vgs_cols_verbose_CFG, "vgs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_COLS_VERB, vsn(1, 0, 0), NULL)
+cfg(report_pvs_sort_CFG, "pvs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_SORT, vsn(1, 0, 0), NULL)
+cfg(report_pvs_cols_CFG, "pvs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_COLS, vsn(1, 0, 0), NULL)
+cfg(report_pvs_cols_verbose_CFG, "pvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_COLS_VERB, vsn(1, 0, 0), NULL)
+cfg(report_segs_sort_CFG, "segs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_SORT, vsn(1, 0, 0), NULL)
+cfg(report_segs_cols_CFG, "segs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_COLS, vsn(1, 0, 0), NULL)
+cfg(report_segs_cols_verbose_CFG, "segs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_COLS_VERB, vsn(1, 0, 0), NULL)
+cfg(report_pvsegs_sort_CFG, "pvsegs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_SORT, vsn(1, 1, 3), NULL)
+cfg(report_pvsegs_cols_CFG, "pvsegs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS, vsn(1, 1, 3), NULL)
+cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS_VERB, vsn(1, 1, 3), NULL)
 
 cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_MIRROR_LIB, vsn(1, 2, 3), NULL)
 cfg(dmeventd_raid_library_CFG, "raid_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_RAID_LIB, vsn(2, 2, 87), NULL)


