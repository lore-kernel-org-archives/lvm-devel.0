From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:21 +0000 (GMT)
Subject: main - symver: sorting
Message-ID: <20210406200721.A51223857823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14ea63cfc7ba7a8a47197e7fae0c045eda68e749
Commit:        14ea63cfc7ba7a8a47197e7fae0c045eda68e749
Parent:        60eb608d66c2056a78e81f27db3da14139d9faab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 4 11:26:45 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

symver: sorting

---
 libdm/.exported_symbols.DM_1_02_100 |  2 +-
 libdm/.exported_symbols.DM_1_02_101 |  2 +-
 libdm/.exported_symbols.DM_1_02_104 | 12 ++++++------
 libdm/.exported_symbols.DM_1_02_110 |  2 +-
 libdm/.exported_symbols.DM_1_02_128 |  4 ++--
 libdm/.exported_symbols.DM_1_02_138 |  6 +++---
 6 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_100 b/libdm/.exported_symbols.DM_1_02_100
index 00d7d5b10..4564338c8 100644
--- a/libdm/.exported_symbols.DM_1_02_100
+++ b/libdm/.exported_symbols.DM_1_02_100
@@ -1,2 +1,2 @@
-dm_config_value_set_format_flags
 dm_config_value_get_format_flags
+dm_config_value_set_format_flags
diff --git a/libdm/.exported_symbols.DM_1_02_101 b/libdm/.exported_symbols.DM_1_02_101
index 75089ba8b..0bdcfe4c9 100644
--- a/libdm/.exported_symbols.DM_1_02_101
+++ b/libdm/.exported_symbols.DM_1_02_101
@@ -1,2 +1,2 @@
-dm_report_value_cache_set
 dm_report_value_cache_get
+dm_report_value_cache_set
diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index 712fcf2d5..d0bb855b5 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -30,12 +30,12 @@ dm_stats_get_io_nsecs
 dm_stats_get_nr_areas
 dm_stats_get_nr_regions
 dm_stats_get_rd_merges_per_sec
-dm_stats_get_read_nsecs
 dm_stats_get_reads
-dm_stats_get_read_sectors
-dm_stats_get_read_sectors_per_sec
 dm_stats_get_reads_merged
 dm_stats_get_reads_per_sec
+dm_stats_get_read_nsecs
+dm_stats_get_read_sectors
+dm_stats_get_read_sectors_per_sec
 dm_stats_get_region_area_len
 dm_stats_get_region_aux_data
 dm_stats_get_region_len
@@ -50,12 +50,12 @@ dm_stats_get_total_read_nsecs
 dm_stats_get_total_write_nsecs
 dm_stats_get_utilization
 dm_stats_get_weighted_io_nsecs
-dm_stats_get_write_nsecs
 dm_stats_get_writes
-dm_stats_get_write_sectors
-dm_stats_get_write_sectors_per_sec
 dm_stats_get_writes_merged
 dm_stats_get_writes_per_sec
+dm_stats_get_write_nsecs
+dm_stats_get_write_sectors
+dm_stats_get_write_sectors_per_sec
 dm_stats_get_wr_merges_per_sec
 dm_stats_list
 dm_stats_populate
diff --git a/libdm/.exported_symbols.DM_1_02_110 b/libdm/.exported_symbols.DM_1_02_110
index eba56259a..74f6bfb8c 100644
--- a/libdm/.exported_symbols.DM_1_02_110
+++ b/libdm/.exported_symbols.DM_1_02_110
@@ -1,3 +1,3 @@
-dm_report_compact_given_fields
 dm_hold_control_dev
+dm_report_compact_given_fields
 dm_tree_node_size_changed
diff --git a/libdm/.exported_symbols.DM_1_02_128 b/libdm/.exported_symbols.DM_1_02_128
index c3239739b..ad76c459f 100644
--- a/libdm/.exported_symbols.DM_1_02_128
+++ b/libdm/.exported_symbols.DM_1_02_128
@@ -1,5 +1,5 @@
 dm_report_group_create
-dm_report_group_push
-dm_report_group_pop
 dm_report_group_destroy
+dm_report_group_pop
+dm_report_group_push
 dm_report_set_selection
diff --git a/libdm/.exported_symbols.DM_1_02_138 b/libdm/.exported_symbols.DM_1_02_138
index 21e9ad8cc..609c195e4 100644
--- a/libdm/.exported_symbols.DM_1_02_138
+++ b/libdm/.exported_symbols.DM_1_02_138
@@ -1,9 +1,9 @@
+dm_bitset_parse_list
 dm_bit_get_last
 dm_bit_get_prev
 dm_filemapd_mode_from_string
-dm_stats_update_regions_from_fd
-dm_bitset_parse_list
 dm_stats_bind_from_fd
 dm_stats_start_filemapd
-dm_tree_node_add_raid_target_with_params_v2
+dm_stats_update_regions_from_fd
 dm_tree_node_add_cache_target
+dm_tree_node_add_raid_target_with_params_v2


