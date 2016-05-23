From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 May 2016 23:58:34 +0000 (UTC)
Subject: master - metadata: Tidy merge.c
Message-ID: <20160523235834.DB12B60FE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c872852cdbc4c3f9572379bc87e1455b28fbe6f
Commit:        8c872852cdbc4c3f9572379bc87e1455b28fbe6f
Parent:        498da2414b90098eb78cdd8c87bda7b022240fda
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue May 24 00:57:48 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue May 24 00:57:48 2016 +0100

metadata: Tidy merge.c

---
 lib/metadata/merge.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 62fc70a..7aed002 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -455,13 +455,14 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				seg_found++;
 		}
 		if (seg_is_replicator(seg) && lv == seg->rlog_lv)
-				seg_found++;
+			seg_found++;
 		if (seg->log_lv == lv)
 			seg_found++;
 		if (seg->metadata_lv == lv || seg->pool_lv == lv)
 			seg_found++;
 		if (seg_is_thin_volume(seg) && (seg->origin == lv || seg->external_lv == lv))
 			seg_found++;
+
 		if (!seg_found) {
 			log_error("LV %s is used by LV %s:%" PRIu32 "-%" PRIu32
 				  ", but missing ptr from %s to %s",
@@ -480,10 +481,11 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 
 		seg_found = 0;
 		dm_list_iterate_items(seg2, &seg->lv->segments)
-			if (sl->seg == seg2) {
+			if (seg == seg2) {
 				seg_found++;
 				break;
 			}
+
 		if (!seg_found) {
 			log_error("LV segment %s:%" PRIu32 "-%" PRIu32
 				  " is incorrectly listed as being used by LV %s",


