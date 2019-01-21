From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:24 -0500
Subject: master - vdo: introduce function for estimation of virtual size
Message-ID: <201901211155.x0LBtOW3024478@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ab031d673d7c75ca1217864dffc3c8e79e97c8f6
Commit:        ab031d673d7c75ca1217864dffc3c8e79e97c8f6
Parent:        022ebb0cfebee4ac8fdbe4e0c61e85db1038a115
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 16 15:34:28 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

vdo: introduce function for estimation of virtual size

---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/vdo_manip.c         |   19 ++++++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f867231..c76e644 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1299,6 +1299,7 @@ const char *get_vdo_compression_state_name(enum dm_vdo_compression_state state);
 const char *get_vdo_index_state_name(enum dm_vdo_index_state state);
 const char *get_vdo_operating_mode_name(enum dm_vdo_operating_mode mode);
 uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg);
+int update_vdo_pool_virtual_size(struct lv_segment *vdo_pool_seg);
 int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_pool_lv,
 			  const char *params, struct lv_status_vdo *status);
 struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 04ab1ab..4be9d2b 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2018-2019 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -91,6 +91,23 @@ uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg)
 				 vdo_pool_seg->vdo_pool_header_size);
 }
 
+int update_vdo_pool_virtual_size(struct lv_segment *vdo_pool_seg)
+{
+	struct seg_list *sl;
+	uint32_t extents = 0;
+
+	/* FIXME: as long as we have only SINGLE VDO with vdo-pool this works */
+	/* after adding support for multiple VDO LVs - this needs heavy rework */
+	dm_list_iterate_items(sl, &vdo_pool_seg->lv->segs_using_this_lv)
+		extents += sl->seg->len;
+
+	/* Only growing virtual/logical VDO size */
+	if (extents > vdo_pool_seg->vdo_pool_virtual_extents)
+		vdo_pool_seg->vdo_pool_virtual_extents = extents;
+
+	return 1;
+}
+
 static int _sysfs_get_kvdo_value(const char *dm_name, const char *vdo_param, uint64_t *value)
 {
 	char path[PATH_MAX];


