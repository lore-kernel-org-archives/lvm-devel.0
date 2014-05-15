From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 15 May 2014 07:32:53 +0000 (UTC)
Subject: master - report: Add metadata_percent to lvs_cols.
Message-ID: <20140515073253.AF2AD60EE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5684cfcb1c13129b70ddaf1ee4df95e08bc551a9
Commit:        5684cfcb1c13129b70ddaf1ee4df95e08bc551a9
Parent:        42d7409da2761198781e067b81a4dca86ba27ee9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu May 15 08:32:27 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu May 15 08:32:27 2014 +0100

report: Add metadata_percent to lvs_cols.

---
 WHATS_NEW             |    1 +
 conf/example.conf.in  |    2 +-
 lib/config/defaults.h |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8bcf687..c5cbf37 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Add metadata_percent to lvs_cols.
   Take account of parity areas with alloc anywhere in _calc_required_extents.
   Use proper uint64 casting for calculation of cache metadata size.
   Better support for nesting of blocking signals.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index bc1758d..935d3e7 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1040,7 +1040,7 @@ activation {
 
     # Comma separated list of columns to report for 'lvs' command.
     # See 'lvs -o help' for the list of possible fields.
-    # lvs_cols="lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,move_pv,mirror_log,copy_percent,convert_lv"
+    # lvs_cols="lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
 
     # Comma separated list of columns to report for 'lvs' command in verbose mode.
     # See 'lvs -o help' for the list of possible fields.
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 137b4c8..4200dc8 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -180,7 +180,7 @@
 #define DEFAULT_REP_QUOTED 1
 #define DEFAULT_REP_SEPARATOR " "
 
-#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,move_pv,mirror_log,copy_percent,convert_lv"
+#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
 #define DEFAULT_VGS_COLS "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
 #define DEFAULT_PVS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
 #define DEFAULT_SEGS_COLS "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"


