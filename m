From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  1 Apr 2014 09:48:56 +0000 (UTC)
Subject: master - tests: update profiles.sh for recent changes
Message-ID: <20140401094856.386DA60CD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a30219a8c0ba2d9f5ce6402ff2edbd0ece263166
Commit:        a30219a8c0ba2d9f5ce6402ff2edbd0ece263166
Parent:        13009adbf266b5e72eeb882286b43948b15cd49b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 1 11:48:49 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 1 11:48:49 2014 +0200

tests: update profiles.sh for recent changes

---
 test/shell/profiles.sh |   37 ++++++++++++++++++++++++++++++++++++-
 1 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index 654e04f..bae13d6 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -44,7 +44,36 @@ aux profileconf valid 'allocation/thin_pool_zero = 0' \
                       'allocation/thin_pool_discards = "passdown"' \
                       'allocation/thin_pool_chunk_size = 64'\
                       'activation/thin_pool_autoextend_threshold = 100' \
-                      'activation/thin_pool_autoextend_percent = 20'
+                      'activation/thin_pool_autoextend_percent = 20' \
+                      'global/units = "h"' \
+                      'global/si_unit_consistency = 1' \
+                      'global/suffix = 1' \
+                      'global/lvdisplay_shows_full_device_path = 0' \
+                      'report/aligned = 1' \
+                      'report/buffered = 1' \
+                      'report/headings = 1' \
+                      'report/separator = " "' \
+                      'report/prefixes = 0' \
+                      'report/quoted = 1' \
+                      'report/colums_as_rows = 0' \
+                      'report/devtypes_sort = "devtype_name"' \
+                      'report/devtypes_cols = "devtype_name,devtype_max_partitions,devtype_description"' \
+                      'report/devtypes_cols_verbose = "devtype_name,devtype_max_partitions,devtype_description"' \
+                      'report/lvs_sort = "vg_name,lv_name"' \
+                      'report/lvs_cols = "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,move_pv,mirror_log,copy_percent,convert_lv"' \
+                      'report/lvs_cols_verbose = "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile"' \
+                      'report/vgs_sort = "vg_name"' \
+                      'report/vgs_cols = "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"' \
+                      'report/vgs_cols_verbose = "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"' \
+                      'report/pvs_sort = "pv_name"' \
+                      'report/pvs_cols = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"' \
+                      'report/pvs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"' \
+                      'report/segs_sort = "vg_name,lv_name,seg_start"' \
+                      'report/segs_cols = "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"' \
+                      'report/segs_cols_verbose = "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"' \
+                      'report/pvsegs_sort = "pv_name,pvseg_start"' \
+                      'report/pvsegs_cols = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"' \
+                      'report/pvsegs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"'
 
 aux profileconf extra 'allocation/thin_pool_chunk_size = 128'
 
@@ -77,3 +106,9 @@ lvm dumpconfig &>out
 grep 'thin_pool_zero=1' out
 lvm dumpconfig --profile valid --mergedconfig >out
 grep 'thin_pool_zero=0' out
+
+# dumpconfig --profilable output must be usable as a profile
+lvm dumpconfig --type profilable --file etc/profile/generated.profile
+pvs --profile generated &> msg
+not grep "$MSG_NOT_PROFILABLE" msg
+not grep "$MSG_IGNORING_INVALID_PROFILE" msg


