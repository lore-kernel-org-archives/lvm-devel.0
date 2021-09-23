From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Sep 2021 14:52:33 +0000 (GMT)
Subject: main - gcc: use more zero length arrays
Message-ID: <20210923145233.E642D3858D34@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9eafd44734d32207dce7d0b0829e3c94c07d95c9
Commit:        9eafd44734d32207dce7d0b0829e3c94c07d95c9
Parent:        4515acf73430a8734f477b10ae6e3473d02999ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 22 17:05:09 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 22 17:18:50 2021 +0200

gcc: use more zero length arrays

Define last array struct member with zero size.
---
 base/data-struct/hash.c       | 2 +-
 device_mapper/libdm-common.c  | 2 +-
 device_mapper/misc/dm-ioctl.h | 8 ++++----
 lib/activate/fs.c             | 2 +-
 lib/device/dev-cache.c        | 2 +-
 lib/label/label.c             | 2 +-
 libdm/datastruct/hash.c       | 2 +-
 libdm/libdm-common.c          | 2 +-
 libdm/misc/dm-ioctl.h         | 8 ++++----
 libdm/misc/dm-log-userspace.h | 2 +-
 10 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/base/data-struct/hash.c b/base/data-struct/hash.c
index 5fee9cf85..db3dcd543 100644
--- a/base/data-struct/hash.c
+++ b/base/data-struct/hash.c
@@ -23,7 +23,7 @@ struct dm_hash_node {
 	unsigned data_len;
 	unsigned keylen;
 	unsigned hash;
-	char key[];
+	char key[0];
 };
 
 struct dm_hash_table {
diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index af2178e95..a90ece78a 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -1445,7 +1445,7 @@ struct node_op_parms {
 	char *old_name;
 	int warn_if_udev_failed;
 	unsigned rely_on_udev;
-	char names[];
+	char names[0];
 };
 
 static void _store_str(char **pos, char **ptr, const char *str)
diff --git a/device_mapper/misc/dm-ioctl.h b/device_mapper/misc/dm-ioctl.h
index 49954a764..cc2374c36 100644
--- a/device_mapper/misc/dm-ioctl.h
+++ b/device_mapper/misc/dm-ioctl.h
@@ -183,7 +183,7 @@ struct dm_target_spec {
 struct dm_target_deps {
 	uint32_t count;	/* Array size */
 	uint32_t padding;	/* unused */
-	uint64_t dev[];		/* out */
+	uint64_t dev[0];	/* out */
 };
 
 /*
@@ -193,7 +193,7 @@ struct dm_name_list {
 	uint64_t dev;
 	uint32_t next;		/* offset to the next record from
 				   the _start_ of this */
-	char name[];
+	char name[0];
 };
 
 /*
@@ -203,7 +203,7 @@ struct dm_target_versions {
         uint32_t next;
         uint32_t version[3];
 
-        char name[];
+        char name[0];
 };
 
 /*
@@ -212,7 +212,7 @@ struct dm_target_versions {
 struct dm_target_msg {
 	uint64_t sector;	/* Device sector */
 
-	char message[];
+	char message[0];
 };
 
 /*
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 60ced8fb5..3e0692c9d 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -313,7 +313,7 @@ struct fs_op_parms {
 	char *lv_name;
 	char *dev;
 	char *old_lv_name;
-	char names[];
+	char names[0];
 };
 
 static void _store_str(char **pos, char **ptr, const char *str)
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 0d1d4e36f..d454b5b30 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -39,7 +39,7 @@ struct dev_iter {
 
 struct dir_list {
 	struct dm_list list;
-	char dir[];
+	char dir[0];
 };
 
 static struct {
diff --git a/lib/label/label.c b/lib/label/label.c
index 4c243a43d..b5804c738 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -44,7 +44,7 @@ struct labeller_i {
 	struct dm_list list;
 
 	struct labeller *l;
-	char name[];
+	char name[0];
 };
 
 static struct dm_list _labellers;
diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index 67261f8da..054f5c359 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -20,7 +20,7 @@ struct dm_hash_node {
 	void *data;
 	unsigned data_len;
 	unsigned keylen;
-	char key[];
+	char key[0];
 };
 
 struct dm_hash_table {
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 56fb436bc..27be1d02f 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1443,7 +1443,7 @@ struct node_op_parms {
 	char *old_name;
 	int warn_if_udev_failed;
 	unsigned rely_on_udev;
-	char names[];
+	char names[0];
 };
 
 static void _store_str(char **pos, char **ptr, const char *str)
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index 55dee2148..52a7a93d1 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -183,7 +183,7 @@ struct dm_target_spec {
 struct dm_target_deps {
 	uint32_t count;	/* Array size */
 	uint32_t padding;	/* unused */
-	uint64_t dev[];		/* out */
+	uint64_t dev[0];	/* out */
 };
 
 /*
@@ -193,7 +193,7 @@ struct dm_name_list {
 	uint64_t dev;
 	uint32_t next;		/* offset to the next record from
 				   the _start_ of this */
-	char name[];
+	char name[0];
 };
 
 /*
@@ -203,7 +203,7 @@ struct dm_target_versions {
         uint32_t next;
         uint32_t version[3];
 
-        char name[];
+        char name[0];
 };
 
 /*
@@ -212,7 +212,7 @@ struct dm_target_versions {
 struct dm_target_msg {
 	uint64_t sector;	/* Device sector */
 
-	char message[];
+	char message[0];
 };
 
 /*
diff --git a/libdm/misc/dm-log-userspace.h b/libdm/misc/dm-log-userspace.h
index b243194d9..f28fa585e 100644
--- a/libdm/misc/dm-log-userspace.h
+++ b/libdm/misc/dm-log-userspace.h
@@ -412,7 +412,7 @@ struct dm_ulog_request {
 	uint32_t request_type;  /* DM_ULOG_* defined above */
 	uint32_t data_size;     /* How much data (not including this struct) */
 
-	char data[];
+	char data[0];
 };
 
 #endif /* __DM_LOG_USERSPACE_H__ */


