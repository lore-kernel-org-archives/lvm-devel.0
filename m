From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:38 +0000 (UTC)
Subject: master - conf: regenerate profile templates
Message-ID: <20160620094138.E4C7460DFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=083e538030e8ee5f8a888d11ddc7f06cd793678c
Commit:        083e538030e8ee5f8a888d11ddc7f06cd793678c
Parent:        92caebab95353e13b37fc724a6f31c23c8fd2cac
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 20 11:25:24 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

conf: regenerate profile templates

---
 conf/command_profile_template.profile.in |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/conf/command_profile_template.profile.in b/conf/command_profile_template.profile.in
index 3e5b031..156dc0d 100644
--- a/conf/command_profile_template.profile.in
+++ b/conf/command_profile_template.profile.in
@@ -16,15 +16,20 @@ allocation {
 	cache_settings {
 	}
 }
-
+log {
+	report_command_log=0
+	command_log_sort="log_seq_num"
+	command_log_cols="log_seq_num,log_type,log_context,log_object_type,log_object_name,log_object_id,log_object_group,log_object_group_id,log_message,log_errno,log_ret_code"
+	command_log_selection="!(log_type=status && message=success)"
+}
 global {
 	units="h"
 	si_unit_consistency=1
 	suffix=1
 	lvdisplay_shows_full_device_path=0
 }
-
 report {
+	output_format="basic"
 	compact_output=0
 	compact_output_cols=""
 	aligned=1
@@ -55,5 +60,15 @@ report {
 	pvsegs_sort="pv_name,pvseg_start"
 	pvsegs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 	pvsegs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
+	vgs_cols_full="vg_all"
+	pvs_cols_full="pv_all"
+	lvs_cols_full="lv_all"
+	pvsegs_cols_full="pvseg_all,pv_uuid,lv_uuid"
+	segs_cols_full="seg_all,lv_uuid"
+	vgs_sort_full="vg_name"
+	pvs_sort_full="pv_name"
+	lvs_sort_full="vg_name,lv_name"
+	pvsegs_sort_full="pv_uuid,pvseg_start"
+	segs_sort_full="lv_uuid,seg_start"
 	mark_hidden_devices=1
 }


