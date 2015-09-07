From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 15:45:32 +0000 (UTC)
Subject: master - cleanup: assign seg_name once
Message-ID: <20150907154532.6392060E5D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ffbf12504d24a25a66de53e11bfcbaac84c51ab5
Commit:        ffbf12504d24a25a66de53e11bfcbaac84c51ab5
Parent:        330cad15678116fadd33737d69d3bba3b926fc30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 09:42:45 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 17:44:08 2015 +0200

cleanup: assign seg_name once

---
 lib/metadata/lv_manip.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 88c516b..832a190 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -251,16 +251,18 @@ static int _lv_layout_and_role_raid(struct dm_pool *mem,
 	if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID]))
 		goto_bad;
 
-	if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID1)) {
+	seg_name = first_seg(lv)->segtype->name;
+
+	if (!strcmp(seg_name, SEG_TYPE_NAME_RAID1)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID1]))
 			goto_bad;
-	} else if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID10)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID10]))
 			goto_bad;
-	} else if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID4)) {
+	} else if (!strcmp(seg_name, SEG_TYPE_NAME_RAID4)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID4]))
 			goto_bad;
-	} else if (!strncmp(seg_name = first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID5, strlen(SEG_TYPE_NAME_RAID5))) {
+	} else if (!strncmp(seg_name, SEG_TYPE_NAME_RAID5, strlen(SEG_TYPE_NAME_RAID5))) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5]))
 			goto_bad;
 
@@ -277,7 +279,7 @@ static int _lv_layout_and_role_raid(struct dm_pool *mem,
 			if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID5_RS]))
 				goto_bad;
 		}
-	} else if (!strncmp(seg_name = first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID6, strlen(SEG_TYPE_NAME_RAID6))) {
+	} else if (!strncmp(seg_name, SEG_TYPE_NAME_RAID6, strlen(SEG_TYPE_NAME_RAID6))) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID6]))
 			goto_bad;
 


