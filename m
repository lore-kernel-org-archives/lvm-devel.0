From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:26:39 +0000 (UTC)
Subject: master - conf: add existing report settings to lvm.conf
Message-ID: <20140317132639.D49016138E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9070c196beb32560a4f966c607b08bb6020b1ab
Commit:        f9070c196beb32560a4f966c607b08bb6020b1ab
Parent:        12eb284eecc631096e31384537289a3376617580
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 17 14:24:21 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 17 14:24:21 2014 +0100

conf: add existing report settings to lvm.conf

These settings exist for ages but they were not exposed in lvm.conf
and so majority of users didn't event know about them.
---
 WHATS_NEW            |    1 +
 conf/example.conf.in |  100 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 101 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8571723..8a072dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add existing report settings to lvm.conf.
   Use VG read lock during 'pvscan --cache -aay' autoactivation.
   Issue a VG refresh before autoactivation only if the PV has changed/is new.
   Add flag to lvmetad protocol to indicate the PV scanned has changed/is new.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 1572750..46ae461 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -978,6 +978,106 @@ activation {
     polling_interval = 15
 }
 
+# Reporting settings.
+#
+# report {
+    # Align columns on report output.
+    # aligned=1
+
+    # When buffered reporting is used, the report's content is appended
+    # incrementally for each object being reported until the report is
+    # flushed to output which normally happens at the end of command
+    # execution. Otherwise, if buffering is not used, each object is
+    # reported as soon as its processing is finished.
+    # buffered=1
+
+    # Show headings for columns on report.
+    # headings=1
+
+    # A separator to use on report after each field.
+    # separator=" "
+
+    # Use a field name prefix for each field reported.
+    # prefixes=0
+
+    # Quote field values when using field name prefixes.
+    # quoted=1
+
+    # Output each column as a row. If set, this also implies report/prefixes=1.
+    # colums_as_rows=0
+
+    # Comma separated list of columns to sort by when reporting 'lvm devtypes' command.
+    # See 'lvm devtypes -o help' for the list of possible fields.
+    # devtypes_sort="devtype_name"
+
+    # Comma separated list of columns to report for 'lvm devtypes' command.
+    # See 'lvm devtypes -o help' for the list of possible fields.
+    # devtypes_cols="devtype_name,devtype_max_partitions,devtype_description"
+
+    # Comma separated list of columns to report for 'lvm devtypes' command in verbose mode.
+    # See 'lvm devtypes -o help' for the list of possible fields.
+    # devtypes_cols_verbose="devtype_name,devtype_max_partitions,devtype_description"
+
+    # Comma separated list of columns to sort by when reporting 'lvs' command.
+    # See 'lvs -o help' for the list of possible fields.
+    # lvs_sort="vg_name,lv_name"
+
+    # Comma separated list of columns to report for 'lvs' command.
+    # See 'lvs -o help' for the list of possible fields.
+    # lvs_cols="lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,move_pv,mirror_log,copy_percent,convert_lv"
+
+    # Comma separated list of columns to report for 'lvs' command in verbose mode.
+    # See 'lvs -o help' for the list of possible fields.
+    # lvs_cols_verbose="lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert
+
+    # Comma separated list of columns to sort by when reporting 'vgs' command.
+    # See 'vgs -o help' for the list of possible fields.
+    # vgs_sort="vg_name"
+
+    # Comma separated list of columns to report for 'vgs' command.
+    # See 'vgs -o help' for the list of possible fields.
+    # vgs_cols="vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
+
+    # Comma separated list of columns to report for 'vgs' command in verbose mode.
+    # See 'vgs -o help' for the list of possible fields.
+    # vgs_cols_verbose="vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"
+
+    # Comma separated list of columns to sort by when reporting 'pvs' command.
+    # See 'pvs -o help' for the list of possible fields.
+    # pvs_sort="pv_name"
+
+    # Comma separated list of columns to report for 'pvs' command.
+    # See 'pvs -o help' for the list of possible fields.
+    # pvs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
+
+    # Comma separated list of columns to report for 'pvs' command in verbose mode.
+    # See 'pvs -o help' for the list of possible fields.
+    # pvs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
+
+    # Comma separated list of columns to sort by when reporting 'lvs --segments' command.
+    # See 'lvs --segments -o help' for the list of possible fields.
+    # segs_sort="vg_name,lv_name,seg_start"
+
+    # Comma separated list of columns to report for 'lvs --segments' command.
+    # See 'lvs --segments  -o help' for the list of possible fields.
+    # segs_cols="lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
+
+    # Comma separated list of columns to report for 'lvs --segments' command in verbose mode.
+    # See 'lvs --segments -o help' for the list of possible fields.
+    # segs_cols_verbose="lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
+
+    # Comma separated list of columns to sort by when reporting 'pvs --segments' command.
+    # See 'pvs --segments -o help' for the list of possible fields.
+    # pvsegs_sort="pv_name,pvseg_start"
+
+    # Comma separated list of columns to sort by when reporting 'pvs --segments' command.
+    # See 'pvs --segments -o help' for the list of possible fields.
+    # pvsegs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
+
+    # Comma separated list of columns to sort by when reporting 'pvs --segments' command in verbose mode.
+    # See 'pvs --segments -o help' for the list of possible fields.
+    # pvsegs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
+#}
 
 ####################
 # Advanced section #


