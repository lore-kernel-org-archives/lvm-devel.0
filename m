From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  5 Feb 2013 14:56:04 +0100
Subject: [PATCH 3/6] thin: report external origin
In-Reply-To: <cover.1360072297.git.zkabelac@redhat.com>
References: <cover.1360072297.git.zkabelac@redhat.com>
Message-ID: <37b5a26a9731e405634d113599fda39b3ba2952b.1360072297.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use the field 'origin' for reporting external origin lv name.

For thin volumes with external origin, report the size of
external origin size via:

  lvs -o+origin_size

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv.c   | 7 ++++++-
 lib/report/report.c | 3 +++
 2 files changed, 9 insertions(+), 1 deletion(-)

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
-- 
1.8.1.2


