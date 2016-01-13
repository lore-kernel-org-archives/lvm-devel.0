From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 14:37:28 +0000 (UTC)
Subject: master - cleanup: rename 'invisible devices' to 'hidden devices'
Message-ID: <20160113143728.E1AF060E0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a81881965f1c990632c13699f2184cd1680cf39
Commit:        9a81881965f1c990632c13699f2184cd1680cf39
Parent:        1417ed304bf7db0bda167ee83cfbb4126ba4913d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 15:37:15 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 15:37:15 2016 +0100

cleanup: rename 'invisible devices' to 'hidden devices'

---
 conf/command_profile_template.profile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/conf/command_profile_template.profile.in b/conf/command_profile_template.profile.in
index 57fc6c0..3e5b031 100644
--- a/conf/command_profile_template.profile.in
+++ b/conf/command_profile_template.profile.in
@@ -55,5 +55,5 @@ report {
 	pvsegs_sort="pv_name,pvseg_start"
 	pvsegs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 	pvsegs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
-	mark_invisible_devices=1
+	mark_hidden_devices=1
 }


