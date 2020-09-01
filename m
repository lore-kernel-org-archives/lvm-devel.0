From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:01 +0000 (GMT)
Subject: master - gcc: zero-sized array to fexlible array C99
Message-ID: <20200901170201.E33CA3950C5B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fd96f1014b11d073d775ea4777f3b3ba2eb93520
Commit:        fd96f1014b11d073d775ea4777f3b3ba2eb93520
Parent:        cc2218b4014015bd2633454e683293851183e08c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:15:01 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

gcc: zero-sized array to fexlible array C99

Switch remaining zero sized struct to flexible arrays to be C99
complient.

These simple rules should apply:

- The incomplete array type must be the last element within the structure.
- There cannot be an array of structures that contain a flexible array member.
- Structures that contain a flexible array member cannot be used as a member of another structure.
- The structure must contain at least one named member in addition to the flexible array member.

Although some of the code pieces should be still improved.
---
 WHATS_NEW                              | 1 +
 base/data-struct/hash.c                | 2 +-
 base/data-struct/radix-tree-adaptive.c | 2 +-
 daemons/lvmlockd/lvmlockd-internal.h   | 2 +-
 device_mapper/all.h                    | 6 +++---
 device_mapper/misc/dm-ioctl.h          | 8 ++++----
 lib/device/dev-cache.c                 | 2 +-
 lib/format_text/layout.h               | 6 +++---
 lib/label/label.c                      | 2 +-
 lib/metadata/lv_manip.c                | 2 +-
 libdm/datastruct/hash.c                | 2 +-
 libdm/libdevmapper.h                   | 6 +++---
 libdm/libdm-stats.c                    | 2 +-
 libdm/misc/dm-ioctl.h                  | 8 ++++----
 tools/tools.h                          | 2 +-
 15 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3c84ea867..1fffbb5d7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Switch code base to use flexible array syntax.
   Fix 64bit math when calculation cachevol size.
   Preserve uint32_t for seqno handling.
   Switch from mmap to plain read when loading regular files.
diff --git a/base/data-struct/hash.c b/base/data-struct/hash.c
index 0a0541d2e..5ef5ed276 100644
--- a/base/data-struct/hash.c
+++ b/base/data-struct/hash.c
@@ -22,7 +22,7 @@ struct dm_hash_node {
 	void *data;
 	unsigned data_len;
 	unsigned keylen;
-	char key[0];
+	char key[];
 };
 
 struct dm_hash_table {
diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index b9ba4179f..3a46cc14b 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -47,7 +47,7 @@ struct value_chain {
 struct prefix_chain {
 	struct value child;
 	unsigned len;
-	uint8_t prefix[0];
+	uint8_t prefix[];
 };
 
 struct node4 {
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 191c44926..14bdfeed0 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -158,7 +158,7 @@ struct resource {
 	struct list_head locks;
 	struct list_head actions;
 	char lv_args[MAX_ARGS+1];
-	char lm_data[0];		/* lock manager specific data */
+	char lm_data[];			/* lock manager specific data */
 };
 
 #define LD_LF_PERSISTENT 0x00000001
diff --git a/device_mapper/all.h b/device_mapper/all.h
index c3c6219e3..ace3b69a0 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -164,20 +164,20 @@ struct dm_info {
 struct dm_deps {
 	uint32_t count;
 	uint32_t filler;
-	uint64_t device[0];
+	uint64_t device[];
 };
 
 struct dm_names {
 	uint64_t dev;
 	uint32_t next;		/* Offset to next struct from start of this struct */
-	char name[0];
+	char name[];
 };
 
 struct dm_versions {
 	uint32_t next;		/* Offset to next struct from start of this struct */
 	uint32_t version[3];
 
-	char name[0];
+	char name[];
 };
 
 int dm_get_library_version(char *version, size_t size);
diff --git a/device_mapper/misc/dm-ioctl.h b/device_mapper/misc/dm-ioctl.h
index cc2374c36..49954a764 100644
--- a/device_mapper/misc/dm-ioctl.h
+++ b/device_mapper/misc/dm-ioctl.h
@@ -183,7 +183,7 @@ struct dm_target_spec {
 struct dm_target_deps {
 	uint32_t count;	/* Array size */
 	uint32_t padding;	/* unused */
-	uint64_t dev[0];	/* out */
+	uint64_t dev[];		/* out */
 };
 
 /*
@@ -193,7 +193,7 @@ struct dm_name_list {
 	uint64_t dev;
 	uint32_t next;		/* offset to the next record from
 				   the _start_ of this */
-	char name[0];
+	char name[];
 };
 
 /*
@@ -203,7 +203,7 @@ struct dm_target_versions {
         uint32_t next;
         uint32_t version[3];
 
-        char name[0];
+        char name[];
 };
 
 /*
@@ -212,7 +212,7 @@ struct dm_target_versions {
 struct dm_target_msg {
 	uint64_t sector;	/* Device sector */
 
-	char message[0];
+	char message[];
 };
 
 /*
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index c3f7c49be..d4e2658aa 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -35,7 +35,7 @@ struct dev_iter {
 
 struct dir_list {
 	struct dm_list list;
-	char dir[0];
+	char dir[];
 };
 
 static struct {
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index c3dfe8e7a..df7ed3a78 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -33,7 +33,7 @@ struct pv_header_extension {
 	uint32_t version;
 	uint32_t flags;
 	/* NULL-terminated list of bootloader areas */
-	struct disk_locn bootloader_areas_xl[0];
+	struct disk_locn bootloader_areas_xl[];
 } __attribute__ ((packed));
 
 /* Fields with the suffix _xl should be xlate'd wherever they appear */
@@ -46,7 +46,7 @@ struct pv_header {
 
 	/* NULL-terminated list of data areas followed by */
 	/* NULL-terminated list of metadata area headers */
-	struct disk_locn disk_areas_xl[0];	/* Two lists */
+	struct disk_locn disk_areas_xl[];	/* Two lists */
 } __attribute__ ((packed));
 
 /*
@@ -76,7 +76,7 @@ struct mda_header {
 	uint64_t start;		/* Absolute start byte of mda_header */
 	uint64_t size;		/* Size of metadata area */
 
-	struct raw_locn raw_locns[0];	/* NULL-terminated list */
+	struct raw_locn raw_locns[];	/* NULL-terminated list */
 } __attribute__ ((packed));
 
 struct mda_header *raw_read_mda_header(const struct format_type *fmt,
diff --git a/lib/label/label.c b/lib/label/label.c
index 4d369d4f1..8e68f9303 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -43,7 +43,7 @@ struct labeller_i {
 	struct dm_list list;
 
 	struct labeller *l;
-	char name[0];
+	char name[];
 };
 
 static struct dm_list _labellers;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c47ec72e2..95ca2df39 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1798,7 +1798,7 @@ struct alloc_handle {
 	 * Contains area_count lists of areas allocated to data stripes
 	 * followed by log_area_count lists of areas allocated to log stripes.
 	 */
-	struct dm_list alloced_areas[0];
+	struct dm_list alloced_areas[];
 };
 
 /*
diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index 4c940039a..726347ea2 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -20,7 +20,7 @@ struct dm_hash_node {
 	void *data;
 	unsigned data_len;
 	unsigned keylen;
-	char key[0];
+	char key[];
 };
 
 struct dm_hash_table {
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e9b140563..059b96f0b 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -165,20 +165,20 @@ struct dm_info {
 struct dm_deps {
 	uint32_t count;
 	uint32_t filler;
-	uint64_t device[0];
+	uint64_t device[];
 };
 
 struct dm_names {
 	uint64_t dev;
 	uint32_t next;		/* Offset to next struct from start of this struct */
-	char name[0];
+	char name[];
 };
 
 struct dm_versions {
 	uint32_t next;		/* Offset to next struct from start of this struct */
 	uint32_t version[3];
 
-	char name[0];
+	char name[];
 };
 
 int dm_get_library_version(char *version, size_t size);
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 5379bed5e..f8d79d807 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -65,7 +65,7 @@ struct dm_histogram {
 	const struct dm_stats_region *region;
 	uint64_t sum; /* Sum of histogram bin counts. */
 	int nr_bins; /* Number of histogram bins assigned. */
-	struct dm_histogram_bin bins[0];
+	struct dm_histogram_bin bins[];
 };
 
 /*
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index 52a7a93d1..55dee2148 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -183,7 +183,7 @@ struct dm_target_spec {
 struct dm_target_deps {
 	uint32_t count;	/* Array size */
 	uint32_t padding;	/* unused */
-	uint64_t dev[0];	/* out */
+	uint64_t dev[];		/* out */
 };
 
 /*
@@ -193,7 +193,7 @@ struct dm_name_list {
 	uint64_t dev;
 	uint32_t next;		/* offset to the next record from
 				   the _start_ of this */
-	char name[0];
+	char name[];
 };
 
 /*
@@ -203,7 +203,7 @@ struct dm_target_versions {
         uint32_t next;
         uint32_t version[3];
 
-        char name[0];
+        char name[];
 };
 
 /*
@@ -212,7 +212,7 @@ struct dm_target_versions {
 struct dm_target_msg {
 	uint64_t sector;	/* Device sector */
 
-	char message[0];
+	char message[];
 };
 
 /*
diff --git a/tools/tools.h b/tools/tools.h
index 4b944e2fd..befff5708 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -110,7 +110,7 @@ struct arg_values {
 struct arg_value_group_list {
         struct dm_list list;
 	uint32_t prio;
-        struct arg_values arg_values[0];
+	struct arg_values arg_values[];
 };
 
 #define PERMITTED_READ_ONLY 	0x00000002


