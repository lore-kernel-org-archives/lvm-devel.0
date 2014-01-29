From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 29 Jan 2014 13:59:50 +0000 (UTC)
Subject: master - thin: validate external origin size
Message-ID: <20140129135950.0C3C260F65@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=155405b0e1d310fbc44f263c5e3a5c5d23043207
Commit:        155405b0e1d310fbc44f263c5e3a5c5d23043207
Parent:        8074d8056acd419fd38d53b32db5373df76d825f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 14:27:13 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 29 14:58:13 2014 +0100

thin: validate external origin size

Avoid use of external origin with size unaligned/incompatible with
thin pool chunk size, since the last chunk is not correctly provisioned
when it is overwritten.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |    4 +++-
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/thin_manip.c        |   21 +++++++++++++++++++++
 lib/thin/thin.c                  |    2 ++
 tools/lvconvert.c                |    3 +++
 6 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3a4c7ec..d28ec3c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Prohibit use of external origin with size incompatible with thin pool.
   Avoid trying to convert single to thin pool and volume at the same time.
   Add support for partitions on ZFS zvol.
   Fix unwanted drop of hold flocks on forked children.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2e240fc..a2831cf 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -5980,6 +5980,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 * within the same thin pool
 		 */
 		if (lp->snapshot && (first_seg(org)->pool_lv != pool_lv)) {
+			if (!pool_supports_external_origin(first_seg(pool_lv), org))
+				return_0;
 			if (org->status & LVM_WRITE) {
 				log_error("Cannot use writable LV as the external origin.");
 				return 0; // TODO conversion for inactive
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bdf5c9d..1ebf69f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -682,6 +682,7 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 
 struct logical_volume *find_pool_lv(const struct logical_volume *lv);
 int pool_is_active(const struct logical_volume *pool_lv);
+int pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv);
 int thin_pool_feature_supported(const struct logical_volume *pool_lv, int feature);
 int update_pool_lv(struct logical_volume *lv, int activate);
 int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 1abc2f1..60e93f0 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -252,6 +252,27 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 	return 1;
 }
 
+/*
+ * Validate given external origin could be used with thin pool
+ */
+int pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv)
+{
+	uint32_t csize = pool_seg->chunk_size;
+
+	if ((external_lv->size < csize) || (external_lv->size % csize)) {
+		/* TODO: Validate with thin feature flag once, it will be supported */
+		log_error("Can't use \"%s/%s\" as external origin with \"%s/%s\" pool. "
+			  "Size %s is not a multiple of pool's chunk size %s.",
+			  external_lv->vg->name, external_lv->name,
+			  pool_seg->lv->vg->name, pool_seg->lv->name,
+			  display_size(external_lv->vg->cmd, external_lv->size),
+			  display_size(external_lv->vg->cmd, csize));
+		return 0;
+	}
+
+	return 1;
+}
+
 struct logical_volume *find_pool_lv(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 0b8eaf8..8eaa73d 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -561,6 +561,8 @@ static int _thin_add_target_line(struct dev_manager *dm,
 
 	/* Add external origin LV */
 	if (seg->external_lv) {
+		if (!pool_supports_external_origin(first_seg(seg->pool_lv), seg->external_lv))
+			return_0;
 		if (seg->external_lv->size < seg->lv->size) {
 			/* Validate target supports smaller external origin */
 			if (!_thin_target_present(cmd, first_seg(seg->pool_lv), &attr) ||
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ffbf768..2ab4115 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2483,6 +2483,9 @@ static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 
 	dm_list_init(&lvc.tags);
 
+	if (!pool_supports_external_origin(first_seg(pool_lv), external_lv))
+		return_0;
+
 	if (!(lvc.segtype = get_segtype_from_string(cmd, "thin")))
 		return_0;
 


