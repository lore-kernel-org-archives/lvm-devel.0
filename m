From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 09:42:05 +0000 (UTC)
Subject: master - thin: report external origin
Message-ID: <20130223094205.3B1F541D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30c13eff3766eb49f925acabf836470b63d05903
Commit:        30c13eff3766eb49f925acabf836470b63d05903
Parent:        386f3d5a5e6a8b147793c8e59d72c4496144ec2c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 15 15:16:16 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 10:37:01 2013 +0100

thin: report external origin

Use the field 'origin' for reporting external origin lv name.

For thin volumes with external origin, report the size of
external origin size via:

  lvs -o+origin_size
---
 lib/display/display.c |    3 +++
 lib/metadata/lv.c     |    7 ++++++-
 lib/report/report.c   |    3 +++
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index b15ff71..c0d0cd9 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -594,6 +594,9 @@ int lvdisplay_full(struct cmd_context *cmd,
 		if (seg->origin)
 			log_print("LV Thin origin name    %s",
 				  seg->origin->name);
+		if (seg->external_lv)
+			log_print("LV External origin name %s",
+				  seg->origin->name);
 		if (inkernel)
 			thin_active = lv_thin_percent(lv, 0, &thin_percent);
 	} else if (lv_is_thin_pool(lv)) {
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9f6b327..f1c79be 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -169,6 +169,9 @@ char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
 		return lv_name_dup(mem, first_seg(lv)->origin);
 
+	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
+		return lv_name_dup(mem, first_seg(lv)->external_lv);
+
 	return NULL;
 }
 
@@ -282,6 +285,8 @@ uint64_t lv_origin_size(const struct logical_volume *lv)
 {
 	if (lv_is_cow(lv))
 		return (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
+	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
+		return first_seg(lv)->external_lv->size;
 	if (lv_is_origin(lv))
 		return lv->size;
 	return 0;
diff --git a/lib/report/report.c b/lib/report/report.c
index 5a4e4df..633dfe4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -343,6 +343,9 @@ static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
 		return _lvname_disp(rh, mem, field, first_seg(lv)->origin, private);
 
+	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
+		return _lvname_disp(rh, mem, field, first_seg(lv)->external_lv, private);
+
 	dm_report_field_set_value(field, "", NULL);
 	return 1;
 }


