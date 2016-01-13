From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:51 +0000 (UTC)
Subject: master - conf: update command_profile_template.profile.in
Message-ID: <20160113134651.9299B60679@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=293abbb8d2f438c84d43f7f80570bd09fc5228ea
Commit:        293abbb8d2f438c84d43f7f80570bd09fc5228ea
Parent:        53b355a24b10d50b5f330d71afa80a491532b07a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 12:15:28 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 12:16:58 2016 +0100

conf: update command_profile_template.profile.in

---
 conf/command_profile_template.profile.in |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/conf/command_profile_template.profile.in b/conf/command_profile_template.profile.in
index 402e30c..57fc6c0 100644
--- a/conf/command_profile_template.profile.in
+++ b/conf/command_profile_template.profile.in
@@ -11,14 +11,22 @@
 # Refer to 'man lvm.conf' for further information about profiles and
 # general configuration file layout.
 #
+allocation {
+	cache_mode="writethrough"
+	cache_settings {
+	}
+}
+
 global {
 	units="h"
 	si_unit_consistency=1
 	suffix=1
 	lvdisplay_shows_full_device_path=0
 }
+
 report {
 	compact_output=0
+	compact_output_cols=""
 	aligned=1
 	buffered=1
 	headings=1
@@ -28,6 +36,7 @@ report {
 	quoted=1
 	colums_as_rows=0
 	binary_values_as_numeric=0
+	time_format="%Y-%m-%d %T %z"
 	devtypes_sort="devtype_name"
 	devtypes_cols="devtype_name,devtype_max_partitions,devtype_description"
 	devtypes_cols_verbose="devtype_name,devtype_max_partitions,devtype_description"
@@ -46,4 +55,5 @@ report {
 	pvsegs_sort="pv_name,pvseg_start"
 	pvsegs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 	pvsegs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
+	mark_invisible_devices=1
 }


