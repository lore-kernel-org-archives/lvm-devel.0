From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:49 +0000 (UTC)
Subject: master - conf: regenerate
Message-ID: <20160113134649.712616066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53b355a24b10d50b5f330d71afa80a491532b07a
Commit:        53b355a24b10d50b5f330d71afa80a491532b07a
Parent:        e168b5de75204a554fcb6f9a3bd25dada2561c86
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 11:58:12 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 12:01:55 2016 +0100

conf: regenerate

---
 conf/example.conf.in |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index b8c0407..f549f15 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1108,9 +1108,9 @@ activation {
 	#     or VG.
 	#   @*
 	#     Selects an LV if a tag defined on the host is also set on the LV
-	#     or VG. See tags/hosttags. If any host tags exist but volume_list
-	#     is not defined, a default single-entry list containing '@*' is
-	#     assumed.
+	#     or VG. See tags/hosttags. If any host tags exist but the volume
+	#     list is not defined, a default single-entry list containing '@*'
+	#     is assumed.
 	# 
 	# Example
 	# volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
@@ -1145,12 +1145,12 @@ activation {
 	#     or VG.
 	#   @*
 	#     Selects an LV if a tag defined on the host is also set on the LV
-	#     or VG. See tags/hosttags. If any host tags exist but volume_list
-	#     is not defined, a default single-entry list containing '@*' is
-	#     assumed.
+	#     or VG. See tags/hosttags. If any host tags exist but the volume
+	#     list is not defined, a default single-entry list containing '@*'
+	#     is assumed.
 	# 
 	# Example
-	# volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
+	# auto_activation_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 	# 
 	# This configuration option does not have a default value defined.
 
@@ -1171,12 +1171,12 @@ activation {
 	#     or VG.
 	#   @*
 	#     Selects an LV if a tag defined on the host is also set on the LV
-	#     or VG. See tags/hosttags. If any host tags exist but volume_list
-	#     is not defined, a default single-entry list containing '@*' is
-	#     assumed.
+	#     or VG. See tags/hosttags. If any host tags exist but the volume
+	#     list is not defined, a default single-entry list containing '@*'
+	#     is assumed.
 	# 
 	# Example
-	# volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
+	# read_only_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 	# 
 	# This configuration option does not have a default value defined.
 
@@ -1808,6 +1808,11 @@ activation {
 	# See 'pvs --segments -o help' for the list of possible fields.
 	# This configuration option has an automatic default value.
 	# pvsegs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
+
+	# Configuration option report/mark_invisible_devices.
+	# Use brackets [] to mark invisible devices.
+	# This configuration option has an automatic default value.
+	# mark_invisible_devices = 1
 # }
 
 # Configuration section dmeventd.


