From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 20 May 2014 14:28:56 +0000 (UTC)
Subject: master - tests: update profiles.sh test for latest changes
Message-ID: <20140520142856.3CEE36011B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83f468be4e8ff6189523eae7de8a087ab42021be
Commit:        83f468be4e8ff6189523eae7de8a087ab42021be
Parent:        9c937e7d54221a783d294768efbaad12473a0265
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 20 14:50:42 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 20 16:27:09 2014 +0200

tests: update profiles.sh test for latest changes

---
 test/shell/profiles.sh |  130 +++++++++++++++++++++++++++---------------------
 1 files changed, 73 insertions(+), 57 deletions(-)

diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index bae13d6..49b8b9c 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -15,12 +15,16 @@
 
 . lib/test
 
-MSG_FAILED_TO_APPLY_PROFILE="Failed to apply configuration profile"
-MSG_IGNORING_INVALID_PROFILE="Ignoring invalid configuration profile"
+MSG_FAILED_TO_APPLY_CMD_PROFILE="Failed to apply command profile"
+MSG_IGNORING_INVALID_CMD_PROFILE="Ignoring invalid command profile"
+MSG_FAILED_TO_APPLY_MDA_PROFILE="Failed to apply metadata profile"
+MSG_IGNORING_INVALID_MDA_PROFILE="Ignoring invalid metadata profile"
 MSG_NOT_PROFILABLE="not customizable by a profile"
+MSG_CMD_PROFILABLE_ONLY="customizable by command profile only, not metadata profile"
+MSG_MDA_PROFILABLE_ONLY="customizable by metadata profile only, not command profile"
 
 # fail if the profile requested by --profile cmdline option is not present
-not pvs --profile nonexistent 2>&1 | grep "$MSG_FAILED_TO_APPLY_PROFILE"
+not pvs --profile nonexistent 2>&1 | grep "$MSG_FAILED_TO_APPLY_CMD_PROFILE"
 
 # config/checks=1: warning message about setting not being profilable +
 #                  summary error message about invalid profile
@@ -28,58 +32,68 @@ not pvs --profile nonexistent 2>&1 | grep "$MSG_FAILED_TO_APPLY_PROFILE"
 aux profileconf invalid 'log/prefix=" "'
 
 aux lvmconf 'config/checks = 0'
-pvs --profile invalid 2>msg
+not pvs --profile invalid 2>msg
 not grep "$MSG_NOT_PROFILABLE" msg
-grep "$MSG_IGNORING_INVALID_PROFILE" msg
+grep "$MSG_IGNORING_INVALID_CMD_PROFILE" msg
+grep "$MSG_FAILED_TO_APPLY_CMD_PROFILE" msg
 
 aux lvmconf 'config/checks = 1'
-pvs --profile invalid 2>msg
+not pvs --profile invalid 2>msg
 grep "$MSG_NOT_PROFILABLE" msg
-grep "$MSG_IGNORING_INVALID_PROFILE" msg
+grep "$MSG_IGNORING_INVALID_CMD_PROFILE" msg
+grep "$MSG_FAILED_TO_APPLY_CMD_PROFILE" msg
 
 aux lvmconf 'allocation/thin_pool_zero = 1'
 
 # all profilable items listed here - should pass
-aux profileconf valid 'allocation/thin_pool_zero = 0' \
-                      'allocation/thin_pool_discards = "passdown"' \
-                      'allocation/thin_pool_chunk_size = 64'\
-                      'activation/thin_pool_autoextend_threshold = 100' \
-                      'activation/thin_pool_autoextend_percent = 20' \
-                      'global/units = "h"' \
-                      'global/si_unit_consistency = 1' \
-                      'global/suffix = 1' \
-                      'global/lvdisplay_shows_full_device_path = 0' \
-                      'report/aligned = 1' \
-                      'report/buffered = 1' \
-                      'report/headings = 1' \
-                      'report/separator = " "' \
-                      'report/prefixes = 0' \
-                      'report/quoted = 1' \
-                      'report/colums_as_rows = 0' \
-                      'report/devtypes_sort = "devtype_name"' \
-                      'report/devtypes_cols = "devtype_name,devtype_max_partitions,devtype_description"' \
-                      'report/devtypes_cols_verbose = "devtype_name,devtype_max_partitions,devtype_description"' \
-                      'report/lvs_sort = "vg_name,lv_name"' \
-                      'report/lvs_cols = "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,move_pv,mirror_log,copy_percent,convert_lv"' \
-                      'report/lvs_cols_verbose = "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile"' \
-                      'report/vgs_sort = "vg_name"' \
-                      'report/vgs_cols = "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"' \
-                      'report/vgs_cols_verbose = "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"' \
-                      'report/pvs_sort = "pv_name"' \
-                      'report/pvs_cols = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"' \
-                      'report/pvs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"' \
-                      'report/segs_sort = "vg_name,lv_name,seg_start"' \
-                      'report/segs_cols = "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"' \
-                      'report/segs_cols_verbose = "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"' \
-                      'report/pvsegs_sort = "pv_name,pvseg_start"' \
-                      'report/pvsegs_cols = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"' \
-                      'report/pvsegs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"'
-
-aux profileconf extra 'allocation/thin_pool_chunk_size = 128'
-
-pvs --profile valid 2>msg
+aux profileconf valid_cmd_profile 'global/units = "h"' \
+				  'global/si_unit_consistency = 1' \
+				  'global/suffix = 1' \
+				  'global/lvdisplay_shows_full_device_path = 0' \
+                                  'report/aligned = 1' \
+                                  'report/buffered = 1' \
+                                  'report/headings = 1' \
+                                  'report/separator = " "' \
+                                  'report/prefixes = 0' \
+                                  'report/quoted = 1' \
+                                  'report/colums_as_rows = 0' \
+                                  'report/devtypes_sort = "devtype_name"' \
+                                  'report/devtypes_cols = "devtype_name,devtype_max_partitions,devtype_description"' \
+                                  'report/devtypes_cols_verbose = "devtype_name,devtype_max_partitions,devtype_description"' \
+                                  'report/lvs_sort = "vg_name,lv_name"' \
+                                  'report/lvs_cols = "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,move_pv,mirror_log,copy_percent,convert_lv"' \
+                                  'report/lvs_cols_verbose = "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile"' \
+                                  'report/vgs_sort = "vg_name"' \
+                                  'report/vgs_cols = "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"' \
+                                  'report/vgs_cols_verbose = "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"' \
+                                  'report/pvs_sort = "pv_name"' \
+                                  'report/pvs_cols = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"' \
+                                  'report/pvs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"' \
+                                  'report/segs_sort = "vg_name,lv_name,seg_start"' \
+                                  'report/segs_cols = "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"' \
+                                  'report/segs_cols_verbose = "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"' \
+                                  'report/pvsegs_sort = "pv_name,pvseg_start"' \
+                                  'report/pvsegs_cols = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"' \
+                                  'report/pvsegs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"'
+
+aux profileconf valid_mda_profile 'allocation/thin_pool_zero = 0' \
+				  'allocation/thin_pool_discards = "passdown"' \
+				  'allocation/thin_pool_chunk_size = 64'\
+				  'activation/thin_pool_autoextend_threshold = 100' \
+				  'activation/thin_pool_autoextend_percent = 20' \
+
+
+aux profileconf extra_mda_profile 'allocation/thin_pool_chunk_size = 128'
+
+pvs --profile valid_cmd_profile 2>msg
 not grep "$MSG_NOT_PROFILABLE" msg
-not grep "$MSG_IGNORING_INVALID_PROFILE" msg
+not grep "$MSG_IGNORING_INVALID_CMD_PROFILE" msg
+not grep "$MSG_IGNORING_INVALID_MDA_PROFILE" msg
+
+not pvs --profile valid_mda_profile 2>msg
+grep "$MSG_MDA_PROFILABLE_ONLY" msg
+grep "$MSG_IGNORING_INVALID_CMD_PROFILE" msg
+not grep "$MSG_IGNORING_INVALID_MDA_PROFILE" msg
 
 # attaching/detaching profiles to VG/LV
 aux prepare_pvs 1 8
@@ -88,27 +102,29 @@ vgcreate $vg1 "$dev1"
 check vg_field $vg1 vg_profile ""
 lvcreate -l 1 -n $lv1 $vg1
 check lv_field $vg1/$lv1 lv_profile ""
-vgchange --profile valid $vg1
-check vg_field $vg1 vg_profile valid
+vgchange --profile valid_mda_profile $vg1
+check vg_field $vg1 vg_profile valid_mda_profile
 check lv_field $vg1/$lv1 lv_profile ""
-lvchange --profile extra $vg1/$lv1
-check vg_field $vg1 vg_profile valid
-check lv_field $vg1/$lv1 lv_profile extra
+lvchange --profile extra_mda_profile $vg1/$lv1
+check vg_field $vg1 vg_profile valid_mda_profile
+check lv_field $vg1/$lv1 lv_profile extra_mda_profile
 vgchange --detachprofile $vg1
 check vg_field $vg1 vg_profile ""
-check lv_field $vg1/$lv1 lv_profile extra
+check lv_field $vg1/$lv1 lv_profile extra_mda_profile
 lvchange --detachprofile $vg1/$lv1
 check vg_field $vg1 vg_profile ""
 check lv_field $vg1/$lv1 lv_profile ""
 
 # dumpconfig and merged lvm.conf + profile
+aux lvmconf 'global/units="m"'
+aux profileconf extra_cmd_profile 'global/units="h"'
 lvm dumpconfig &>out
-grep 'thin_pool_zero=1' out
-lvm dumpconfig --profile valid --mergedconfig >out
-grep 'thin_pool_zero=0' out
+grep 'units="m"' out
+lvm dumpconfig --profile extra_cmd_profile --mergedconfig >out
+grep 'units="h"' out
 
 # dumpconfig --profilable output must be usable as a profile
-lvm dumpconfig --type profilable --file etc/profile/generated.profile
+lvm dumpconfig --type profilable-command --file etc/profile/generated.profile
 pvs --profile generated &> msg
 not grep "$MSG_NOT_PROFILABLE" msg
-not grep "$MSG_IGNORING_INVALID_PROFILE" msg
+not grep "$MSG_IGNORING_INVALID_CMD_PROFILE" msg


